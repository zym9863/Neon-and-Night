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
        v-if="show && memory"
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
              v-if="show && memory"
              class="relative w-full max-w-2xl glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 标题栏 -->
              <div class="flex items-center justify-between mb-6">
                <div class="flex items-center space-x-3">
                  <div
                    class="w-4 h-4 rounded-full"
                    :style="{ backgroundColor: memory.color, boxShadow: `0 0 8px ${memory.color}` }"
                  ></div>
                  <h3 class="text-xl font-bold text-white">{{ memory.title }}</h3>
                  <span
                    v-if="memory.is_sealed"
                    class="px-2 py-1 bg-gray-600 text-gray-200 text-xs rounded-full flex items-center space-x-1"
                  >
                    <LockClosedIcon class="w-3 h-3" />
                    <span>已封存</span>
                  </span>
                </div>
                <button
                  @click="closeModal"
                  class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-white/10"
                >
                  <XMarkIcon class="h-5 w-5" />
                </button>
              </div>

              <!-- 记忆内容 -->
              <div class="mb-6">
                <!-- 文字内容 -->
                <div v-if="memory.content_type === 'text'" class="prose prose-invert max-w-none">
                  <p class="text-gray-200 leading-relaxed whitespace-pre-wrap">{{ memory.content }}</p>
                </div>
                
                <!-- 图片内容 -->
                <div v-else-if="memory.content_type === 'image' && memory.media_url" class="text-center">
                  <img
                    :src="memory.media_url"
                    :alt="memory.title"
                    class="max-w-full max-h-96 rounded-lg mx-auto shadow-lg"
                  />
                  <p v-if="memory.content" class="text-gray-300 mt-4">{{ memory.content }}</p>
                </div>
                
                <!-- 音频内容 -->
                <div v-else-if="memory.content_type === 'audio' && memory.media_url" class="text-center">
                  <audio controls class="w-full mb-4">
                    <source :src="memory.media_url" type="audio/mpeg">
                    您的浏览器不支持音频播放。
                  </audio>
                  <p v-if="memory.content" class="text-gray-300">{{ memory.content }}</p>
                </div>
              </div>

              <!-- 记忆信息 -->
              <div class="grid grid-cols-2 gap-4 mb-6 p-4 bg-white/5 rounded-lg">
                <div>
                  <div class="text-gray-400 text-sm">情绪类型</div>
                  <div class="text-white font-medium flex items-center space-x-2">
                    <component :is="emotionIcon" class="w-4 h-4" />
                    <span>{{ emotionTypeText }}</span>
                  </div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">创建时间</div>
                  <div class="text-white font-medium">{{ formatDate(memory.created_at) }}</div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">星辰亮度</div>
                  <div class="text-white font-medium">{{ memory.brightness }}%</div>
                </div>
                <div>
                  <div class="text-gray-400 text-sm">位置坐标</div>
                  <div class="text-white font-medium">
                    ({{ Math.round(memory.position_x) }}, {{ Math.round(memory.position_y) }})
                  </div>
                </div>
              </div>

              <!-- 亮度调节 -->
              <div class="mb-6">
                <label class="block text-sm font-medium text-gray-300 mb-3">
                  调整星辰亮度 ({{ localBrightness }}%)
                </label>
                <div class="flex items-center space-x-4">
                  <SunIcon class="w-4 h-4 text-gray-400" />
                  <input
                    v-model="localBrightness"
                    type="range"
                    min="0"
                    max="100"
                    class="flex-1 h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer slider"
                    @change="updateBrightness"
                  />
                  <SunIcon class="w-5 h-5 text-yellow-400" />
                </div>
                <div class="text-xs text-gray-400 mt-2">
                  调暗星辰可以象征情绪的淡化与和解
                </div>
              </div>

              <!-- 操作按钮 -->
              <div class="flex flex-wrap gap-3">
                <button
                  v-if="!memory.is_sealed"
                  @click="showSealModal = true"
                  class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-500 transition-colors flex items-center space-x-2"
                >
                  <LockClosedIcon class="w-4 h-4" />
                  <span>封存记忆</span>
                </button>
                
                <button
                  v-if="memory.is_sealed && canUnseal"
                  @click="unsealMemory"
                  class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-500 transition-colors flex items-center space-x-2"
                >
                  <LockOpenIcon class="w-4 h-4" />
                  <span>解封记忆</span>
                </button>
                
                <button
                  @click="shareToGalaxy"
                  class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-500 transition-colors flex items-center space-x-2"
                >
                  <SparklesIcon class="w-4 h-4" />
                  <span>投放银河</span>
                </button>
                
                <button
                  @click="showDeleteConfirm = true"
                  class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-500 transition-colors flex items-center space-x-2"
                >
                  <TrashIcon class="w-4 h-4" />
                  <span>删除记忆</span>
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </Transition>

    <!-- 封存确认模态框 -->
    <SealMemoryModal
      v-model:show="showSealModal"
      :memory="memory"
      @sealed="handleMemorySealed"
    />

    <!-- 删除确认模态框 -->
    <ConfirmModal
      v-model:show="showDeleteConfirm"
      title="删除记忆"
      message="确定要删除这段记忆吗？此操作无法撤销。"
      confirm-text="删除"
      confirm-class="bg-red-600 hover:bg-red-500"
      @confirm="deleteMemory"
    />
  </Teleport>
</template>

<script setup lang="ts">
import { 
  XMarkIcon, 
  LockClosedIcon, 
  LockOpenIcon,
  SparklesIcon,
  TrashIcon,
  SunIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'
import type { MemoryStar } from '~/types'

interface Props {
  show: boolean
  memory: MemoryStar | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:show': [value: boolean]
  updated: [memory: MemoryStar]
  deleted: [memoryId: string]
}>()

const { supabase, user } = useSupabase()

const localBrightness = ref(0)
const showSealModal = ref(false)
const showDeleteConfirm = ref(false)

// 监听记忆变化，更新本地亮度
watch(() => props.memory, (newMemory) => {
  if (newMemory) {
    localBrightness.value = newMemory.brightness
  }
}, { immediate: true })

// 情绪图标
const emotionIcon = computed(() => {
  if (!props.memory) return SparklesIcon
  
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
  if (!props.memory) return ''
  
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

// 是否可以解封
const canUnseal = computed(() => {
  if (!props.memory?.is_sealed) return false
  if (!props.memory.seal_until) return true
  return new Date(props.memory.seal_until) <= new Date()
})

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

// 更新亮度
const updateBrightness = async () => {
  if (!props.memory || !user.value) return

  try {
    const { data, error } = await supabase
      .from('memory_stars')
      .update({ brightness: localBrightness.value })
      .eq('id', props.memory.id)
      .eq('user_id', user.value.id)
      .select()
      .single()

    if (error) {
      console.error('更新亮度失败:', error)
      return
    }

    emit('updated', data)
  } catch (error) {
    console.error('更新亮度异常:', error)
  }
}

// 解封记忆
const unsealMemory = async () => {
  if (!props.memory || !user.value) return

  try {
    const { data, error } = await supabase
      .from('memory_stars')
      .update({ 
        is_sealed: false,
        seal_until: null
      })
      .eq('id', props.memory.id)
      .eq('user_id', user.value.id)
      .select()
      .single()

    if (error) {
      console.error('解封记忆失败:', error)
      return
    }

    emit('updated', data)
  } catch (error) {
    console.error('解封记忆异常:', error)
  }
}

// 投放到银河
const shareToGalaxy = async () => {
  if (!props.memory || !user.value) return

  try {
    // 生成匿名内容
    const { data: anonymousContent } = await supabase
      .rpc('anonymize_memory_content', {
        content: props.memory.content,
        emotion_type: props.memory.emotion_type
      })

    // 生成随机位置
    const position = {
      x: Math.random() * 100,
      y: Math.random() * 100
    }

    const { error } = await supabase
      .from('galaxy_emotions')
      .insert({
        original_memory_id: props.memory.id,
        emotion_type: props.memory.emotion_type,
        anonymous_content: anonymousContent || '一段匿名的情感记忆',
        color: props.memory.color,
        intensity: Math.floor(props.memory.brightness / 10),
        position_x: position.x,
        position_y: position.y
      })

    if (error) {
      console.error('投放银河失败:', error)
      return
    }

    // 显示成功提示
    // TODO: 添加成功提示
    console.log('成功投放到银河')
  } catch (error) {
    console.error('投放银河异常:', error)
  }
}

// 删除记忆
const deleteMemory = async () => {
  if (!props.memory || !user.value) return

  try {
    const { error } = await supabase
      .from('memory_stars')
      .delete()
      .eq('id', props.memory.id)
      .eq('user_id', user.value.id)

    if (error) {
      console.error('删除记忆失败:', error)
      return
    }

    emit('deleted', props.memory.id)
    closeModal()
  } catch (error) {
    console.error('删除记忆异常:', error)
  }
}

// 处理记忆封存
const handleMemorySealed = (memory: MemoryStar) => {
  emit('updated', memory)
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

<style scoped>
.slider::-webkit-slider-thumb {
  appearance: none;
  height: 20px;
  width: 20px;
  border-radius: 50%;
  background: linear-gradient(45deg, #8338ec, #3a86ff);
  cursor: pointer;
  box-shadow: 0 0 10px rgba(131, 56, 236, 0.5);
}

.slider::-moz-range-thumb {
  height: 20px;
  width: 20px;
  border-radius: 50%;
  background: linear-gradient(45deg, #8338ec, #3a86ff);
  cursor: pointer;
  border: none;
  box-shadow: 0 0 10px rgba(131, 56, 236, 0.5);
}
</style>
