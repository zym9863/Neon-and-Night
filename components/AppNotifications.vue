<template>
  <!-- 通知面板 -->
  <Teleport to="body">
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 translate-x-full"
      enter-to-class="opacity-100 translate-x-0"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 translate-x-0"
      leave-to-class="opacity-0 translate-x-full"
    >
      <div
        v-if="notificationStore.showPanel"
        class="fixed inset-y-0 right-0 z-50 w-80 glass-effect border-l border-white/20 shadow-2xl"
      >
        <!-- 面板头部 -->
        <div class="flex items-center justify-between p-4 border-b border-white/20">
          <h3 class="text-lg font-semibold text-white">通知</h3>
          <div class="flex items-center space-x-2">
            <button
              v-if="unreadCount > 0"
              @click="markAllAsRead"
              class="text-xs text-neon-cyan hover:text-neon-blue transition-colors"
            >
              全部已读
            </button>
            <button
              @click="notificationStore.closePanel()"
              class="p-1 text-gray-400 hover:text-white transition-colors"
            >
              <XMarkIcon class="h-5 w-5" />
            </button>
          </div>
        </div>

        <!-- 通知列表 -->
        <div class="flex-1 overflow-y-auto">
          <div v-if="loading" class="p-4 text-center">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-neon-purple mx-auto"></div>
            <p class="text-gray-400 mt-2">加载中...</p>
          </div>

          <div v-else-if="notifications.length === 0" class="p-8 text-center">
            <BellIcon class="h-12 w-12 text-gray-500 mx-auto mb-4" />
            <p class="text-gray-400">暂无通知</p>
          </div>

          <div v-else class="divide-y divide-white/10">
            <div
              v-for="notification in notifications"
              :key="notification.id"
              class="p-4 hover:bg-white/5 transition-colors cursor-pointer"
              :class="{ 'bg-white/5': !notification.is_read }"
              @click="handleNotificationClick(notification)"
            >
              <div class="flex items-start space-x-3">
                <!-- 通知图标 -->
                <div class="flex-shrink-0 mt-1">
                  <div
                    class="h-2 w-2 rounded-full"
                    :class="notification.is_read ? 'bg-gray-500' : 'bg-neon-pink'"
                  ></div>
                </div>

                <!-- 通知内容 -->
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-white">
                    {{ notification.title }}
                  </p>
                  <p class="text-sm text-gray-300 mt-1">
                    {{ notification.message }}
                  </p>
                  <p class="text-xs text-gray-500 mt-2">
                    {{ formatTime(notification.created_at) }}
                  </p>
                </div>

                <!-- 删除按钮 -->
                <button
                  @click.stop="deleteNotification(notification.id)"
                  class="flex-shrink-0 p-1 text-gray-400 hover:text-red-400 transition-colors"
                >
                  <TrashIcon class="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- 遮罩层 -->
    <Transition
      enter-active-class="transition-opacity ease-linear duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-opacity ease-linear duration-200"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="notificationStore.showPanel"
        class="fixed inset-0 bg-black/50 z-40"
        @click="notificationStore.closePanel()"
      ></div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { XMarkIcon, BellIcon, TrashIcon } from '@heroicons/vue/24/outline'
import type { Notification } from '~/types'

const notificationStore = useNotificationStore()
const router = useRouter()

const notifications = computed(() => notificationStore.notifications)
const loading = computed(() => notificationStore.loading)
const unreadCount = computed(() => notificationStore.unreadCount)

// 格式化时间
const formatTime = (dateString: string) => {
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

// 处理通知点击
const handleNotificationClick = async (notification: Notification) => {
  // 标记为已读
  if (!notification.is_read) {
    await notificationStore.markAsRead(notification.id)
  }

  // 根据通知类型跳转到相应页面
  if (notification.related_id) {
    switch (notification.type) {
      case 'resonance_received':
        await router.push('/sky')
        break
      case 'capsule_unlocked':
        await router.push('/capsules')
        break
      case 'memory_reminder':
        await router.push('/sky')
        break
    }
  }

  // 关闭通知面板
  notificationStore.closePanel()
}

// 标记所有为已读
const markAllAsRead = async () => {
  await notificationStore.markAllAsRead()
}

// 删除通知
const deleteNotification = async (notificationId: string) => {
  await notificationStore.deleteNotification(notificationId)
}

// 初始化通知系统
onMounted(() => {
  notificationStore.initialize()
})
</script>
