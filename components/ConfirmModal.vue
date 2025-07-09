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
              class="relative w-full max-w-md glass-effect rounded-2xl p-6 shadow-2xl border border-white/20"
              @click.stop
            >
              <!-- 图标 -->
              <div class="flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-red-500/20">
                <ExclamationTriangleIcon class="w-6 h-6 text-red-400" />
              </div>

              <!-- 标题 -->
              <h3 class="text-lg font-semibold text-white text-center mb-2">
                {{ title }}
              </h3>

              <!-- 消息 -->
              <p class="text-gray-300 text-center mb-6">
                {{ message }}
              </p>

              <!-- 按钮 -->
              <div class="flex space-x-3">
                <button
                  @click="closeModal"
                  class="flex-1 px-4 py-3 border border-gray-600 text-gray-300 rounded-lg hover:bg-gray-600 hover:text-white transition-colors"
                >
                  {{ cancelText }}
                </button>
                <button
                  @click="handleConfirm"
                  :class="confirmClass"
                  class="flex-1 px-4 py-3 rounded-lg font-medium text-white transition-colors"
                >
                  {{ confirmText }}
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
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

interface Props {
  show: boolean
  title: string
  message: string
  confirmText?: string
  cancelText?: string
  confirmClass?: string
}

const props = withDefaults(defineProps<Props>(), {
  confirmText: '确认',
  cancelText: '取消',
  confirmClass: 'bg-red-600 hover:bg-red-500'
})

const emit = defineEmits<{
  'update:show': [value: boolean]
  confirm: []
}>()

// 处理确认
const handleConfirm = () => {
  emit('confirm')
  closeModal()
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
