<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition ease-out duration-300"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition ease-in duration-200"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="show && emotion"
        class="fixed inset-0 z-50 overflow-y-auto"
        @click="handleBackdropClick"
      >
        <!-- 背景遮罩 -->
        <div class="fixed inset-0 bg-black/70 backdrop-blur-sm"></div>
        
        <!-- 模态框内容 -->
        <div class="flex min-h-full items-center justify-center p-4">
          <Transition
            enter-active-class="transition ease-out duration-300"
            enter-from-class="opacity-0 scale-95"
            enter-to-class="opacity-100 scale-100"
            leave-active-class="transition ease-in duration-200"
            leave-from-class="opacity-100 scale-100"
            leave-to-class="opacity-0 scale-95"
          >
            <div
              v-if="show && emotion"
              class="relative w-full max-w-lg glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 标题栏 -->
              <div class="flex items-center justify-between mb-6">
                <div class="flex items-center space-x-3">
                  <div
                    class="w-6 h-6 rounded-full animate-pulse"
                    :style="{ 
                      backgroundColor: emotion.color, 
                      boxShadow: `0 0 12px ${emotion.color}` 
                    }"
                  ></div>
                  <h3 class="text-xl font-bold text-white">
                    {{ getEmotionText(emotion.emotion_type) }}的光点
                  </h3>
                </div>
                <button
                  @click="closeModal"
                  class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-white/10"
                >
                  <XMarkIcon class="h-5 w-5" />
                </button>
              </div>

              <!-- 情绪内容 -->
              <div class="mb-6">
                <div class="prose prose-invert max-w-none">
                  <p class="text-gray-200 leading-relaxed">{{ emotion.anonymous_content }}</p>
                </div>
              </div>

              <!-- 情绪信息 -->
              <div class="grid grid-cols-2 gap-4 mb-6 p-4 bg-white/5 rounded-lg">
                <div>
                  <div class="text-gray-400 text-sm">情绪类型</div>
                  <div class="text-white font-medium flex items-center space-x-2">
                    <component :is="getEmotionIcon(emotion.emotion_type)" class="w-4 h-4" />
                    <span>{{ getEmotionText(emotion.emotion_type) }}</span>
                  </div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">情绪强度</div>
                  <div class="text-white font-medium flex items-center space-x-2">
                    <div class="flex space-x-1">
                      <div
                        v-for="i in 10"
                        :key="i"
                        class="w-2 h-2 rounded-full"
                        :class="i <= emotion.intensity ? 'bg-neon-purple' : 'bg-gray-600'"
                      ></div>
                    </div>
                    <span>{{ emotion.intensity }}/10</span>
                  </div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">收到共鸣</div>
                  <div class="text-white font-medium">{{ emotion.resonance_count }} 次</div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">漂浮时间</div>
                  <div class="text-white font-medium">{{ formatDate(emotion.created_at) }}</div>
                </div>
              </div>

              <!-- 共鸣说明 -->
              <div class="mb-6 p-4 bg-purple-500/20 border border-purple-500/50 rounded-lg">
                <div class="flex items-start space-x-3">
                  <HeartIcon class="w-5 h-5 text-purple-300 mt-0.5 flex-shrink-0" />
                  <div>
                    <p class="text-purple-200 text-sm font-medium mb-1">关于光脉冲共鸣</p>
                    <p class="text-purple-300 text-xs">
                      发送光脉冲是一种温柔的回应方式，代表"我听到了你的声音"或"我理解这种感受"。
                      你的共鸣是匿名的，对方只会知道有人与他们产生了共鸣。
                    </p>
                  </div>
                </div>
              </div>

              <!-- 操作按钮 -->
              <div class="flex space-x-3">
                <button
                  @click="closeModal"
                  class="flex-1 px-4 py-3 border border-gray-600 text-gray-300 rounded-lg hover:bg-gray-600 hover:text-white transition-colors"
                >
                  关闭
                </button>
                <button
                  @click="handleResonance"
                  :disabled="resonanceSent"
                  class="flex-1 px-4 py-3 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                >
                  <HeartIcon class="w-4 h-4" />
                  <span>{{ resonanceSent ? '已发送共鸣' : '发送光脉冲' }}</span>
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { 
  XMarkIcon, 
  HeartIcon,
  SparklesIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SunIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'
import type { GalaxyEmotion } from '~/types'

interface Props {
  show: boolean
  emotion: GalaxyEmotion | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:show': [value: boolean]
  resonance: [emotion: GalaxyEmotion]
}>()

const resonanceSent = ref(false)

// 监听情绪变化，重置共鸣状态
watch(() => props.emotion, () => {
  resonanceSent.value = false
})

// 获取情绪图标
const getEmotionIcon = (emotionType: string) => {
  switch (emotionType) {
    case 'love': return HeartIcon
    case 'joy': return FaceSmileIcon
    case 'pain': 
    case 'sadness': return FaceFrownIcon
    case 'hope': return SunIcon
    case 'nostalgia': return ClockIcon
    default: return SparklesIcon
  }
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
  
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (hours < 1) return '不到1小时前'
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  
  return date.toLocaleDateString('zh-CN')
}

// 处理共鸣
const handleResonance = () => {
  if (!props.emotion || resonanceSent.value) return
  
  emit('resonance', props.emotion)
  resonanceSent.value = true
  
  // 2秒后关闭模态框
  setTimeout(() => {
    closeModal()
  }, 2000)
}

// 关闭模态框
const closeModal = () => {
  emit('update:show', false)
}

// 处理背景点击
const handleBackdropClick = (event: MouseEvent) => {
  if (event.target === event.currentTarget) {
    closeModal()
  }
}
</script>
