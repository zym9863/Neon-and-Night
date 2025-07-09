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
        v-if="show && capsule"
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
              v-if="show && capsule"
              class="relative w-full max-w-2xl glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 标题栏 -->
              <div class="flex items-center justify-between mb-6">
                <div class="flex items-center space-x-3">
                  <div
                    class="w-8 h-8 rounded-full flex items-center justify-center"
                    :class="statusClass"
                  >
                    <component :is="statusIcon" class="w-5 h-5" />
                  </div>
                  <h3 class="text-xl font-bold text-white">
                    {{ capsule.memory_stars?.title || '时间胶囊' }}
                  </h3>
                </div>
                <button
                  @click="closeModal"
                  class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-white/10"
                >
                  <XMarkIcon class="h-5 w-5" />
                </button>
              </div>

              <!-- 胶囊状态 -->
              <div class="mb-6 p-4 rounded-lg" :class="statusBgClass">
                <div class="flex items-center space-x-3">
                  <component :is="statusIcon" class="w-6 h-6" :class="statusTextClass" />
                  <div>
                    <p class="font-medium" :class="statusTextClass">{{ statusTitle }}</p>
                    <p class="text-sm" :class="statusTextClass">{{ statusDescription }}</p>
                  </div>
                </div>
              </div>

              <!-- 记忆内容 -->
              <div v-if="capsule.is_unlocked && capsule.memory_stars" class="mb-6">
                <h4 class="text-lg font-semibold text-white mb-3">封存的记忆</h4>
                <div class="prose prose-invert max-w-none">
                  <p class="text-gray-200 leading-relaxed whitespace-pre-wrap">
                    {{ capsule.memory_stars.content }}
                  </p>
                </div>
              </div>

              <!-- 时间信息 -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 p-4 bg-white/5 rounded-lg">
                <div>
                  <div class="text-gray-400 text-sm">封存时间</div>
                  <div class="text-white font-medium">{{ formatDate(capsule.sealed_at) }}</div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">{{ capsule.is_unlocked ? '解锁时间' : '预计解锁' }}</div>
                  <div class="text-white font-medium">{{ formatDate(capsule.unlock_at) }}</div>
                </div>
                <div v-if="capsule.memory_stars">
                  <div class="text-gray-400 text-sm">情绪类型</div>
                  <div class="text-white font-medium flex items-center space-x-2">
                    <component :is="getEmotionIcon()" class="w-4 h-4" />
                    <span>{{ getEmotionText() }}</span>
                  </div>
                </div>
                <div v-if="!capsule.is_unlocked && timeRemaining">
                  <div class="text-gray-400 text-sm">剩余时间</div>
                  <div class="text-neon-cyan font-medium">{{ timeRemaining }}</div>
                </div>
              </div>

              <!-- 解锁消息 -->
              <div v-if="capsule.is_unlocked && capsule.unlock_message" class="mb-6 p-4 bg-green-500/20 border border-green-500/50 rounded-lg">
                <h4 class="text-green-200 font-medium mb-2">来自过去的留言</h4>
                <p class="text-green-300">{{ capsule.unlock_message }}</p>
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
                  v-if="canUnlock"
                  @click="handleUnlock"
                  :disabled="unlocking"
                  class="flex-1 px-4 py-3 bg-gradient-to-r from-neon-green to-green-500 rounded-lg font-medium text-white hover:from-green-500 hover:to-green-600 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span v-if="unlocking">解锁中...</span>
                  <span v-else>立即解锁</span>
                </button>
                
                <NuxtLink
                  v-if="capsule.is_unlocked"
                  to="/sky"
                  class="flex-1 px-4 py-3 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300 text-center"
                >
                  查看记忆
                </NuxtLink>
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
  LockClosedIcon, 
  LockOpenIcon,
  CheckCircleIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SunIcon,
  ClockIcon,
  SparklesIcon
} from '@heroicons/vue/24/outline'
import type { TimeCapsule } from '~/types'

interface Props {
  show: boolean
  capsule: TimeCapsule | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:show': [value: boolean]
  unlocked: [capsule: TimeCapsule]
}>()

const { supabase, user } = useSupabase()
const unlocking = ref(false)

// 状态相关计算属性
const canUnlock = computed(() => {
  if (!props.capsule || props.capsule.is_unlocked) return false
  return new Date(props.capsule.unlock_at) <= new Date()
})

const statusIcon = computed(() => {
  if (!props.capsule) return LockClosedIcon
  if (props.capsule.is_unlocked) return CheckCircleIcon
  return canUnlock.value ? LockOpenIcon : LockClosedIcon
})

const statusClass = computed(() => {
  if (!props.capsule) return 'bg-gray-500/20 text-gray-400'
  if (props.capsule.is_unlocked) return 'bg-green-500/20 text-green-400'
  return canUnlock.value ? 'bg-yellow-500/20 text-yellow-400' : 'bg-gray-500/20 text-gray-400'
})

const statusBgClass = computed(() => {
  if (!props.capsule) return 'bg-gray-500/20 border border-gray-500/50'
  if (props.capsule.is_unlocked) return 'bg-green-500/20 border border-green-500/50'
  return canUnlock.value ? 'bg-yellow-500/20 border border-yellow-500/50' : 'bg-gray-500/20 border border-gray-500/50'
})

const statusTextClass = computed(() => {
  if (!props.capsule) return 'text-gray-400'
  if (props.capsule.is_unlocked) return 'text-green-300'
  return canUnlock.value ? 'text-yellow-300' : 'text-gray-400'
})

const statusTitle = computed(() => {
  if (!props.capsule) return '未知状态'
  if (props.capsule.is_unlocked) return '胶囊已解锁'
  return canUnlock.value ? '胶囊可解锁' : '胶囊封存中'
})

const statusDescription = computed(() => {
  if (!props.capsule) return ''
  if (props.capsule.is_unlocked) return '这段记忆已经重新可见'
  return canUnlock.value ? '时间已到，可以解锁查看记忆' : '等待时间流逝，记忆将在指定时间解锁'
})

// 剩余时间
const timeRemaining = computed(() => {
  if (!props.capsule || props.capsule.is_unlocked) return null
  
  const now = new Date()
  const unlockTime = new Date(props.capsule.unlock_at)
  const diff = unlockTime.getTime() - now.getTime()
  
  if (diff <= 0) return '可立即解锁'
  
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  
  if (days > 0) return `${days}天 ${hours}小时`
  if (hours > 0) return `${hours}小时 ${minutes}分钟`
  if (minutes > 0) return `${minutes}分钟`
  return '即将解锁'
})

// 获取情绪图标
const getEmotionIcon = () => {
  const emotionType = props.capsule?.memory_stars?.emotion_type
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
  const emotionType = props.capsule?.memory_stars?.emotion_type
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
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 处理解锁
const handleUnlock = async () => {
  if (!props.capsule || !user.value || !canUnlock.value) return

  unlocking.value = true
  try {
    const { data, error } = await supabase
      .rpc('unlock_time_capsule', { capsule_id: props.capsule.id })

    if (error) {
      console.error('解锁胶囊失败:', error)
      return
    }

    if (data) {
      // 更新胶囊状态
      const updatedCapsule = { ...props.capsule, is_unlocked: true }
      emit('unlocked', updatedCapsule)
      
      console.log('胶囊解锁成功')
    }
  } catch (error) {
    console.error('解锁胶囊异常:', error)
  } finally {
    unlocking.value = false
  }
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
