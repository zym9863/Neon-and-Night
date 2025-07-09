<template>
  <div
    class="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
    :class="{
      'animate-pulse-slow': emotion.intensity > 7,
      'animate-twinkle': emotion.intensity <= 7
    }"
    @click="handleClick"
    @mouseenter="showTooltip = true"
    @mouseleave="showTooltip = false"
  >
    <!-- 光点主体 -->
    <div
      class="relative transition-all duration-500 group-hover:scale-125"
      :style="{
        filter: `brightness(${emotion.intensity * 10}%) drop-shadow(0 0 ${glowSize}px ${emotion.color})`
      }"
    >
      <!-- 光点核心 -->
      <div
        class="rounded-full"
        :class="lightSizeClass"
        :style="{
          backgroundColor: emotion.color,
          boxShadow: `0 0 ${glowSize * 2}px ${emotion.color}, inset 0 0 ${glowSize}px rgba(255, 255, 255, 0.2)`
        }"
      ></div>
      
      <!-- 光环效果 -->
      <div
        class="absolute inset-0 rounded-full opacity-30 animate-ping"
        :style="{
          backgroundColor: emotion.color,
          animationDuration: `${3 + emotion.intensity}s`
        }"
      ></div>
      
      <!-- 共鸣计数 -->
      <div
        v-if="emotion.resonance_count > 0"
        class="absolute -top-2 -right-2 w-5 h-5 bg-neon-pink rounded-full flex items-center justify-center text-xs font-bold text-white"
      >
        {{ emotion.resonance_count > 9 ? '9+' : emotion.resonance_count }}
      </div>
      
      <!-- 情绪强度指示器 -->
      <div
        class="absolute -bottom-1 -right-1 w-3 h-3 rounded-full border border-white/50"
        :style="{ backgroundColor: getIntensityColor(emotion.intensity) }"
      ></div>
    </div>
    
    <!-- 工具提示 -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="showTooltip && interactive"
        class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-3 px-3 py-2 glass-effect rounded-lg text-sm text-white whitespace-nowrap z-50 pointer-events-none max-w-xs"
      >
        <div class="font-medium">{{ getEmotionText(emotion.emotion_type) }}的光点</div>
        <div class="text-gray-300 text-xs mt-1">
          {{ emotion.anonymous_content }}
        </div>
        <div class="text-gray-400 text-xs mt-1">
          强度 {{ emotion.intensity }}/10 · {{ emotion.resonance_count }} 次共鸣
        </div>
        <div class="text-gray-500 text-xs">
          {{ formatDate(emotion.created_at) }}
        </div>
        
        <!-- 工具提示箭头 -->
        <div class="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-white/20"></div>
      </div>
    </Transition>
    
    <!-- 共鸣按钮 -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <button
        v-if="showTooltip && interactive"
        @click.stop="handleResonance"
        class="absolute top-full left-1/2 transform -translate-x-1/2 mt-2 px-3 py-1 bg-neon-purple/80 hover:bg-neon-purple text-white text-xs rounded-full transition-all duration-200 flex items-center space-x-1"
      >
        <HeartIcon class="w-3 h-3" />
        <span>发送共鸣</span>
      </button>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { HeartIcon } from '@heroicons/vue/24/outline'
import type { GalaxyEmotion } from '~/types'

interface Props {
  emotion: GalaxyEmotion
  size?: 'small' | 'medium' | 'large'
  interactive?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'medium',
  interactive: true
})

const emit = defineEmits<{
  click: [emotion: GalaxyEmotion]
  resonance: [emotion: GalaxyEmotion]
}>()

const showTooltip = ref(false)

// 光点大小
const lightSize = computed(() => {
  const baseSize = props.emotion.intensity + 3
  switch (props.size) {
    case 'small': return Math.max(baseSize * 0.7, 4)
    case 'large': return baseSize * 1.5
    default: return baseSize
  }
})

const lightSizeClass = computed(() => {
  const size = lightSize.value
  if (size <= 6) return 'w-2 h-2'
  if (size <= 10) return 'w-3 h-3'
  if (size <= 14) return 'w-4 h-4'
  return 'w-5 h-5'
})

// 光晕大小
const glowSize = computed(() => {
  return lightSize.value * 0.8
})

// 获取强度颜色
const getIntensityColor = (intensity: number) => {
  if (intensity <= 3) return '#4ade80' // 绿色 - 低强度
  if (intensity <= 6) return '#fbbf24' // 黄色 - 中强度
  if (intensity <= 8) return '#f97316' // 橙色 - 高强度
  return '#ef4444' // 红色 - 极高强度
}

// 获取情绪文本
const getEmotionText = (emotionType: string) => {
  const emotionMap = {
    pain: '痛苦',
    joy: '快乐',
    sadness: '悲伤',
    love: '爱意',
    hope: '希望',
    nostalgia: '怀念'
  }
  return emotionMap[emotionType as keyof typeof emotionMap] || '未知'
}

// 格式化日期
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  
  return date.toLocaleDateString('zh-CN')
}

// 处理点击
const handleClick = (event: MouseEvent) => {
  event.stopPropagation()
  if (props.interactive) {
    emit('click', props.emotion)
  }
}

// 处理共鸣
const handleResonance = (event: MouseEvent) => {
  event.stopPropagation()
  if (props.interactive) {
    emit('resonance', props.emotion)
  }
}
</script>
