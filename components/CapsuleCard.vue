<template>
  <div
    class="glass-effect rounded-lg p-6 hover:bg-white/10 transition-all duration-300 cursor-pointer group"
    @click="$emit('view', capsule)"
  >
    <div class="flex items-start space-x-4">
      <!-- 胶囊状态图标 -->
      <div class="flex-shrink-0">
        <div
          class="w-12 h-12 rounded-full flex items-center justify-center"
          :class="statusClass"
        >
          <component :is="statusIcon" class="w-6 h-6" />
        </div>
      </div>
      
      <!-- 胶囊信息 -->
      <div class="flex-1 min-w-0">
        <!-- 标题和状态 -->
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-lg font-semibold text-white group-hover:text-neon-cyan transition-colors">
            {{ capsule.memory_stars?.title || '未命名记忆' }}
          </h3>
          <span
            class="px-2 py-1 text-xs rounded-full"
            :class="statusBadgeClass"
          >
            {{ statusText }}
          </span>
        </div>
        
        <!-- 记忆预览 -->
        <p class="text-gray-300 text-sm mb-3 line-clamp-2">
          {{ getContentPreview() }}
        </p>
        
        <!-- 时间信息 -->
        <div class="space-y-2">
          <div class="flex items-center space-x-4 text-xs text-gray-400">
            <div class="flex items-center space-x-1">
              <CalendarIcon class="w-3 h-3" />
              <span>封存于 {{ formatDate(capsule.sealed_at) }}</span>
            </div>
            <div class="flex items-center space-x-1">
              <component :is="getEmotionIcon()" class="w-3 h-3" />
              <span>{{ getEmotionText() }}</span>
            </div>
          </div>
          
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-1 text-xs">
              <ClockIcon class="w-3 h-3 text-gray-400" />
              <span class="text-gray-400">
                {{ capsule.is_unlocked ? '已于' : '将于' }} {{ formatDate(capsule.unlock_at) }} {{ capsule.is_unlocked ? '解锁' : '解锁' }}
              </span>
            </div>
            
            <!-- 倒计时 -->
            <div v-if="!capsule.is_unlocked && timeRemaining" class="text-xs">
              <span class="text-neon-cyan font-medium">{{ timeRemaining }}</span>
            </div>
          </div>
        </div>
        
        <!-- 解锁消息 -->
        <div v-if="capsule.is_unlocked && capsule.unlock_message" class="mt-3 p-3 bg-green-500/20 border border-green-500/50 rounded-lg">
          <p class="text-green-200 text-sm">{{ capsule.unlock_message }}</p>
        </div>
      </div>
      
      <!-- 操作按钮 -->
      <div class="flex-shrink-0 flex flex-col space-y-2">
        <button
          v-if="canUnlock"
          @click.stop="$emit('unlock', capsule)"
          class="px-3 py-1 bg-neon-green text-white text-xs rounded-lg hover:bg-green-500 transition-colors"
        >
          立即解锁
        </button>
        
        <button
          @click.stop="$emit('view', capsule)"
          class="px-3 py-1 border border-gray-600 text-gray-300 text-xs rounded-lg hover:bg-gray-600 hover:text-white transition-colors"
        >
          查看详情
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  ClockIcon, 
  CalendarIcon,
  LockClosedIcon, 
  LockOpenIcon,
  CheckCircleIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SunIcon,
  SparklesIcon
} from '@heroicons/vue/24/outline'
import type { TimeCapsule } from '~/types'

interface Props {
  capsule: TimeCapsule
}

const props = defineProps<Props>()

defineEmits<{
  unlock: [capsule: TimeCapsule]
  view: [capsule: TimeCapsule]
}>()

// 状态相关计算属性
const statusIcon = computed(() => {
  if (props.capsule.is_unlocked) return CheckCircleIcon
  return canUnlock.value ? LockOpenIcon : LockClosedIcon
})

const statusClass = computed(() => {
  if (props.capsule.is_unlocked) return 'bg-green-500/20 text-green-400'
  return canUnlock.value ? 'bg-yellow-500/20 text-yellow-400' : 'bg-gray-500/20 text-gray-400'
})

const statusBadgeClass = computed(() => {
  if (props.capsule.is_unlocked) return 'bg-green-500/20 text-green-400'
  return canUnlock.value ? 'bg-yellow-500/20 text-yellow-400' : 'bg-gray-500/20 text-gray-400'
})

const statusText = computed(() => {
  if (props.capsule.is_unlocked) return '已解锁'
  return canUnlock.value ? '可解锁' : '封存中'
})

// 是否可以解锁
const canUnlock = computed(() => {
  if (props.capsule.is_unlocked) return false
  return new Date(props.capsule.unlock_at) <= new Date()
})

// 剩余时间
const timeRemaining = computed(() => {
  if (props.capsule.is_unlocked) return null
  
  const now = new Date()
  const unlockTime = new Date(props.capsule.unlock_at)
  const diff = unlockTime.getTime() - now.getTime()
  
  if (diff <= 0) return '可立即解锁'
  
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  
  if (days > 0) return `${days}天后`
  if (hours > 0) return `${hours}小时后`
  if (minutes > 0) return `${minutes}分钟后`
  return '即将解锁'
})

// 获取内容预览
const getContentPreview = () => {
  const memory = props.capsule.memory_stars
  if (!memory) return '记忆内容已丢失'
  
  if (memory.content) {
    return memory.content.length > 80 
      ? memory.content.substring(0, 80) + '...'
      : memory.content
  }
  
  return '一段珍贵的记忆'
}

// 获取情绪图标
const getEmotionIcon = () => {
  const emotionType = props.capsule.memory_stars?.emotion_type
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
const getEmotionText = () => {
  const emotionType = props.capsule.memory_stars?.emotion_type
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
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
