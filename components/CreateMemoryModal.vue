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
        v-if="show"
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
              v-if="show"
              class="relative w-full max-w-lg glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 标题 -->
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-white">创建新记忆</h3>
                <button
                  @click="closeModal"
                  class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-white/10"
                >
                  <XMarkIcon class="h-5 w-5" />
                </button>
              </div>

              <!-- 表单 -->
              <form @submit.prevent="handleSubmit" class="space-y-6">
                <!-- 标题 -->
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    记忆标题
                  </label>
                  <input
                    v-model="form.title"
                    type="text"
                    required
                    maxlength="100"
                    class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400"
                    placeholder="给这段记忆起个名字..."
                  />
                </div>

                <!-- 内容类型选择 -->
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    记忆类型
                  </label>
                  <div class="grid grid-cols-3 gap-3">
                    <button
                      v-for="type in contentTypes"
                      :key="type.value"
                      type="button"
                      @click="form.content_type = type.value"
                      class="p-3 rounded-lg border transition-all duration-200 flex flex-col items-center space-y-2"
                      :class="form.content_type === type.value 
                        ? 'border-neon-purple bg-neon-purple/20 text-neon-purple' 
                        : 'border-white/20 text-gray-300 hover:border-white/40'"
                    >
                      <component :is="type.icon" class="h-6 w-6" />
                      <span class="text-sm">{{ type.label }}</span>
                    </button>
                  </div>
                </div>

                <!-- 内容输入 -->
                <div v-if="form.content_type === 'text'">
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    记忆内容
                  </label>
                  <textarea
                    v-model="form.content"
                    required
                    rows="4"
                    maxlength="2000"
                    class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400 resize-none"
                    placeholder="记录下这个瞬间的感受..."
                  ></textarea>
                  <div class="text-right text-xs text-gray-400 mt-1">
                    {{ form.content.length }}/2000
                  </div>
                </div>

                <!-- 文件上传 -->
                <div v-else>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    上传{{ form.content_type === 'image' ? '图片' : '录音' }}
                  </label>
                  <div
                    class="border-2 border-dashed border-white/20 rounded-lg p-6 text-center hover:border-white/40 transition-colors cursor-pointer"
                    @click="triggerFileInput"
                    @dragover.prevent
                    @drop.prevent="handleFileDrop"
                  >
                    <input
                      ref="fileInput"
                      type="file"
                      :accept="form.content_type === 'image' ? 'image/*' : 'audio/*'"
                      @change="handleFileSelect"
                      class="hidden"
                    />
                    
                    <div v-if="!selectedFile">
                      <component 
                        :is="form.content_type === 'image' ? PhotoIcon : MicrophoneIcon" 
                        class="h-12 w-12 text-gray-400 mx-auto mb-4" 
                      />
                      <p class="text-gray-300">
                        点击或拖拽上传{{ form.content_type === 'image' ? '图片' : '录音文件' }}
                      </p>
                      <p class="text-gray-500 text-sm mt-2">
                        {{ form.content_type === 'image' ? '支持 JPG, PNG, GIF 格式' : '支持 MP3, WAV, M4A 格式' }}
                      </p>
                    </div>
                    
                    <div v-else class="text-green-400">
                      <CheckCircleIcon class="h-12 w-12 mx-auto mb-4" />
                      <p>{{ selectedFile.name }}</p>
                      <button
                        type="button"
                        @click.stop="selectedFile = null"
                        class="text-red-400 hover:text-red-300 text-sm mt-2"
                      >
                        移除文件
                      </button>
                    </div>
                  </div>
                  
                  <!-- 文字描述 -->
                  <div class="mt-4">
                    <label class="block text-sm font-medium text-gray-300 mb-2">
                      简短描述 (可选)
                    </label>
                    <input
                      v-model="form.content"
                      type="text"
                      maxlength="200"
                      class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400"
                      placeholder="为这个文件添加一些描述..."
                    />
                  </div>
                </div>

                <!-- 情绪类型 -->
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    情绪类型
                  </label>
                  <div class="grid grid-cols-3 gap-3">
                    <button
                      v-for="emotion in emotionTypes"
                      :key="emotion.value"
                      type="button"
                      @click="form.emotion_type = emotion.value"
                      class="p-3 rounded-lg border transition-all duration-200 flex flex-col items-center space-y-2"
                      :class="form.emotion_type === emotion.value 
                        ? 'border-neon-purple bg-neon-purple/20 text-neon-purple' 
                        : 'border-white/20 text-gray-300 hover:border-white/40'"
                    >
                      <component :is="emotion.icon" class="h-5 w-5" />
                      <span class="text-xs">{{ emotion.label }}</span>
                    </button>
                  </div>
                </div>

                <!-- 提交按钮 -->
                <div class="flex space-x-3 pt-4">
                  <button
                    type="button"
                    @click="closeModal"
                    class="flex-1 px-4 py-3 border border-gray-600 text-gray-300 rounded-lg hover:bg-gray-600 hover:text-white transition-colors"
                  >
                    取消
                  </button>
                  <button
                    type="submit"
                    :disabled="loading || !isFormValid"
                    class="flex-1 px-4 py-3 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <span v-if="loading" class="flex items-center justify-center">
                      <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      创建中...
                    </span>
                    <span v-else>创建星辰</span>
                  </button>
                </div>
              </form>
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
  DocumentTextIcon, 
  PhotoIcon, 
  MicrophoneIcon,
  CheckCircleIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SparklesIcon,
  SunIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'
import type { CreateMemoryForm, MemoryStar } from '~/types'

interface Props {
  show: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:show': [value: boolean]
  created: [memory: MemoryStar]
}>()

const { supabase, user } = useSupabase()

const form = reactive<CreateMemoryForm>({
  title: '',
  content: '',
  content_type: 'text',
  emotion_type: 'joy'
})

const loading = ref(false)
const selectedFile = ref<File | null>(null)
const fileInput = ref<HTMLInputElement>()

// 内容类型选项
const contentTypes = [
  { value: 'text', label: '文字', icon: DocumentTextIcon },
  { value: 'image', label: '图片', icon: PhotoIcon },
  { value: 'audio', label: '录音', icon: MicrophoneIcon }
] as const

// 情绪类型选项
const emotionTypes = [
  { value: 'joy', label: '快乐', icon: FaceSmileIcon },
  { value: 'love', label: '爱意', icon: HeartIcon },
  { value: 'hope', label: '希望', icon: SunIcon },
  { value: 'nostalgia', label: '怀念', icon: ClockIcon },
  { value: 'sadness', label: '悲伤', icon: FaceFrownIcon },
  { value: 'pain', label: '痛苦', icon: SparklesIcon }
] as const

// 表单验证
const isFormValid = computed(() => {
  if (!form.title.trim()) return false
  if (form.content_type === 'text' && !form.content.trim()) return false
  if (form.content_type !== 'text' && !selectedFile.value) return false
  return true
})

// 触发文件选择
const triggerFileInput = () => {
  fileInput.value?.click()
}

// 处理文件选择
const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    selectedFile.value = file
  }
}

// 处理文件拖拽
const handleFileDrop = (event: DragEvent) => {
  const file = event.dataTransfer?.files[0]
  if (file) {
    selectedFile.value = file
  }
}

// 生成随机位置
const generatePosition = () => {
  return {
    x: Math.random() * 80 + 10, // 10-90%
    y: Math.random() * 80 + 10  // 10-90%
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!user.value || !isFormValid.value) return

  loading.value = true
  try {
    let mediaUrl = null

    // 如果有文件，先上传
    if (selectedFile.value) {
      const fileExt = selectedFile.value.name.split('.').pop()
      const fileName = `${user.value.id}/${Date.now()}.${fileExt}`
      
      const { error: uploadError } = await supabase.storage
        .from('memories')
        .upload(fileName, selectedFile.value)

      if (uploadError) {
        console.error('文件上传失败:', uploadError)
        throw new Error('文件上传失败')
      }

      const { data: { publicUrl } } = supabase.storage
        .from('memories')
        .getPublicUrl(fileName)
      
      mediaUrl = publicUrl
    }

    // 生成位置和颜色
    const position = generatePosition()
    const { data: colorData } = await supabase
      .rpc('get_emotion_color', { emotion_type: form.emotion_type })
    
    // 创建记忆
    const { data, error } = await supabase
      .from('memory_stars')
      .insert({
        user_id: user.value.id,
        title: form.title,
        content: form.content || (selectedFile.value ? selectedFile.value.name : ''),
        content_type: form.content_type,
        media_url: mediaUrl,
        emotion_type: form.emotion_type,
        position_x: position.x,
        position_y: position.y,
        color: colorData || '#ffffff',
        brightness: 75 // 默认亮度
      })
      .select()
      .single()

    if (error) {
      console.error('创建记忆失败:', error)
      throw new Error('创建记忆失败')
    }

    emit('created', data)
    closeModal()
  } catch (error) {
    console.error('创建记忆异常:', error)
    // 这里可以添加错误提示
  } finally {
    loading.value = false
  }
}

// 关闭模态框
const closeModal = () => {
  emit('update:show', false)
  // 重置表单
  Object.assign(form, {
    title: '',
    content: '',
    content_type: 'text',
    emotion_type: 'joy'
  })
  selectedFile.value = null
}

// 处理背景点击
const handleBackdropClick = (event: MouseEvent) => {
  if (event.target === event.currentTarget) {
    closeModal()
  }
}
</script>
