<template>
  <div
    class="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
    :class="{
      'animate-pulse-slow': memory.is_sealed,
      'animate-twinkle': !memory.is_sealed
    }"
    @click="handleClick"
    @mouseenter="showTooltip = true"
    @mouseleave="showTooltip = false"
  >
    <!-- 星辰主体 -->
    <div
      class="relative transition-all duration-300 group-hover:scale-110"
      :style="{
        filter: `brightness(${memory.brightness}%) drop-shadow(0 0 ${glowSize}px ${memory.color})`
      }"
    >
      <!-- 星辰核心 -->
      <div
        class="rounded-full"
        :class="starSizeClass"
        :style="{
          backgroundColor: memory.color,
          boxShadow: `0 0 ${glowSize * 2}px ${memory.color}, inset 0 0 ${glowSize}px rgba(255, 255, 255, 0.3)`
        }"
      ></div>
      
      <!-- 十字光芒 -->
      <div
        class="absolute inset-0 flex items-center justify-center pointer-events-none"
        :style="{ color: memory.color }"
      >
        <div
          class="absolute bg-current opacity-60"
          :style="{
            width: `${starSize * 3}px`,
            height: '1px',
            boxShadow: `0 0 ${glowSize}px currentColor`
          }"
        ></div>
        <div
          class="absolute bg-current opacity-60"
          :style="{
            width: '1px',
            height: `${starSize * 3}px`,
            boxShadow: `0 0 ${glowSize}px currentColor`
          }"
        ></div>
      </div>
      
      <!-- 封存状态指示器 -->
      <div
        v-if="memory.is_sealed"
        class="absolute -top-1 -right-1 w-3 h-3 bg-gray-500 rounded-full border border-gray-300"
        title="已封存"
      >
        <LockClosedIcon class="w-2 h-2 text-white m-0.5" />
      </div>
      
      <!-- 情绪类型图标 -->
      <div
        class="absolute -bottom-1 -right-1 w-4 h-4 rounded-full flex items-center justify-center text-xs opacity-80"
        :style="{ backgroundColor: memory.color }"
      >
        <component :is="emotionIcon" class="w-2.5 h-2.5 text-white" />
      </div>
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
        class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-3 py-2 glass-effect rounded-lg text-sm text-white whitespace-nowrap z-50 pointer-events-none"
        style="min-width: max-content"
      >
        <div class="font-medium">{{ memory.title }}</div>
        <div class="text-gray-300 text-xs mt-1">
          {{ formatDate(memory.created_at) }}
        </div>
        <div class="text-gray-400 text-xs">
          {{ emotionTypeText }} · 亮度 {{ memory.brightness }}%
        </div>
        
        <!-- 工具提示箭头 -->
        <div class="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-white/20"></div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { 
  HeartIcon, 
  FaceSmileIcon, 
  FaceFrownIcon, 
  SparklesIcon, 
  SunIcon, 
  ClockIcon,
  LockClosedIcon 
} from '@heroicons/vue/24/outline'
import type { MemoryStar } from '~/types'

interface Props {
  memory: MemoryStar
  size?: 'small' | 'medium' | 'large'
  interactive?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'medium',
  interactive: true
})

const emit = defineEmits<{
  click: [memory: MemoryStar]
  update: [memory: MemoryStar]
}>()

const showTooltip = ref(false)

// 星辰大小
const starSize = computed(() => {
  switch (props.size) {
    case 'small': return 8
    case 'large': return 20
    default: return 12
  }
})

const starSizeClass = computed(() => {
  switch (props.size) {
    case 'small': return 'w-2 h-2'
    case 'large': return 'w-5 h-5'
    default: return 'w-3 h-3'
  }
})

// 光晕大小
const glowSize = computed(() => {
  return starSize.value * (props.memory.brightness / 100) * 0.8
})

// 情绪图标
const emotionIcon = computed(() => {
  switch (props.memory.emotion_type) {
    case 'love': return HeartIcon
    case 'joy': return FaceSmileIcon
    case 'pain': 
    case 'sadness': return FaceFrownIcon
    case 'hope': return SunIcon
    case 'nostalgia': return ClockIcon
    default: return SparklesIcon
  }
})

// 情绪类型文本
const emotionTypeText = computed(() => {
  const emotionMap = {
    pain: '痛苦',
    joy: '快乐',
    sadness: '悲伤',
    love: '爱意',
    hope: '希望',
    nostalgia: '怀念'
  }
  return emotionMap[props.memory.emotion_type] || '未知'
})

// 格式化日期
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// 处理点击
const handleClick = (event: MouseEvent) => {
  event.stopPropagation()
  if (props.interactive) {
    emit('click', props.memory)
  }
}
</script>
