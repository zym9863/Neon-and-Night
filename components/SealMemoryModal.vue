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
              class="relative w-full max-w-md glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 标题 -->
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-white flex items-center space-x-2">
                  <LockClosedIcon class="w-6 h-6 text-gray-400" />
                  <span>封存记忆</span>
                </h3>
                <button
                  @click="closeModal"
                  class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-white/10"
                >
                  <XMarkIcon class="h-5 w-5" />
                </button>
              </div>

              <!-- 说明 -->
              <div class="mb-6 p-4 bg-blue-500/20 border border-blue-500/50 rounded-lg">
                <p class="text-blue-200 text-sm">
                  封存记忆将把它放入时间胶囊中，在指定时间之前无法查看。这象征着对过于沉重记忆的暂时告别。
                </p>
              </div>

              <!-- 记忆信息 -->
              <div class="mb-6 p-4 bg-white/5 rounded-lg">
                <div class="flex items-center space-x-3 mb-2">
                  <div
                    class="w-3 h-3 rounded-full"
                    :style="{ backgroundColor: memory.color }"
                  ></div>
                  <span class="text-white font-medium">{{ memory.title }}</span>
                </div>
                <p class="text-gray-300 text-sm">
                  {{ getContentPreview(memory) }}
                </p>
              </div>

              <!-- 封存选项 -->
              <form @submit.prevent="handleSubmit" class="space-y-6">
                <!-- 封存类型 -->
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-3">
                    封存方式
                  </label>
                  <div class="space-y-3">
                    <label class="flex items-center space-x-3 cursor-pointer">
                      <input
                        v-model="sealType"
                        type="radio"
                        value="permanent"
                        class="w-4 h-4 text-neon-purple bg-transparent border-gray-600 focus:ring-neon-purple focus:ring-2"
                      />
                      <span class="text-white">永久封存</span>
                    </label>
                    <label class="flex items-center space-x-3 cursor-pointer">
                      <input
                        v-model="sealType"
                        type="radio"
                        value="timed"
                        class="w-4 h-4 text-neon-purple bg-transparent border-gray-600 focus:ring-neon-purple focus:ring-2"
                      />
                      <span class="text-white">定时解封</span>
                    </label>
                  </div>
                </div>

                <!-- 解封时间 -->
                <div v-if="sealType === 'timed'">
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    解封时间
                  </label>
                  <input
                    v-model="unlockDate"
                    type="datetime-local"
                    :min="minDate"
                    required
                    class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white"
                  />
                  <p class="text-xs text-gray-400 mt-2">
                    选择一个未来的时间点来自动解封这段记忆
                  </p>
                </div>

                <!-- 封存留言 -->
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    给未来的自己留言 (可选)
                  </label>
                  <textarea
                    v-model="message"
                    rows="3"
                    maxlength="500"
                    class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400 resize-none"
                    placeholder="写下一些话给未来重新看到这段记忆的自己..."
                  ></textarea>
                  <div class="text-right text-xs text-gray-400 mt-1">
                    {{ message.length }}/500
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
                    :disabled="loading"
                    class="flex-1 px-4 py-3 bg-gradient-to-r from-gray-600 to-gray-700 rounded-lg font-medium text-white hover:from-gray-500 hover:to-gray-600 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <span v-if="loading" class="flex items-center justify-center">
                      <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      封存中...
                    </span>
                    <span v-else>确认封存</span>
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
import { LockClosedIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import type { MemoryStar } from '~/types'

interface Props {
  show: boolean
  memory: MemoryStar | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:show': [value: boolean]
  sealed: [memory: MemoryStar]
}>()

const { supabase, user } = useSupabase()

const sealType = ref<'permanent' | 'timed'>('timed')
const unlockDate = ref('')
const message = ref('')
const loading = ref(false)

// 最小日期（明天）
const minDate = computed(() => {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return tomorrow.toISOString().slice(0, 16)
})

// 获取内容预览
const getContentPreview = (memory: MemoryStar) => {
  if (memory.content_type === 'text') {
    return memory.content.length > 50 
      ? memory.content.substring(0, 50) + '...'
      : memory.content
  } else {
    return `${memory.content_type === 'image' ? '图片' : '音频'}记忆`
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!props.memory || !user.value) return

  loading.value = true
  try {
    const sealUntil = sealType.value === 'timed' ? unlockDate.value : null

    // 更新记忆状态
    const { data: memoryData, error: memoryError } = await supabase
      .from('memory_stars')
      .update({
        is_sealed: true,
        seal_until: sealUntil
      })
      .eq('id', props.memory.id)
      .eq('user_id', user.value.id)
      .select()
      .single()

    if (memoryError) {
      console.error('封存记忆失败:', memoryError)
      return
    }

    // 如果是定时封存，创建时间胶囊
    if (sealType.value === 'timed' && unlockDate.value) {
      const { error: capsuleError } = await supabase
        .from('time_capsules')
        .insert({
          user_id: user.value.id,
          memory_star_id: props.memory.id,
          unlock_at: unlockDate.value,
          unlock_message: message.value || '时间胶囊已解锁，你可以重新查看这段记忆了'
        })

      if (capsuleError) {
        console.error('创建时间胶囊失败:', capsuleError)
        // 不阻止封存操作，只是记录错误
      }
    }

    emit('sealed', memoryData)
    closeModal()
  } catch (error) {
    console.error('封存记忆异常:', error)
  } finally {
    loading.value = false
  }
}

// 关闭模态框
const closeModal = () => {
  emit('update:show', false)
  // 重置表单
  sealType.value = 'timed'
  unlockDate.value = ''
  message.value = ''
}

// 处理背景点击
const handleBackdropClick = (event: MouseEvent) => {
  if (event.target === event.currentTarget) {
    closeModal()
  }
}
</script>
