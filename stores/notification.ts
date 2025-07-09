import { defineStore } from 'pinia'
import type { Notification } from '~/types'

export const useNotificationStore = defineStore('notification', () => {
  const { supabase, user } = useSupabase()
  
  const notifications = ref<Notification[]>([])
  const loading = ref(false)
  const showPanel = ref(false)

  // 未读通知数量
  const unreadCount = computed(() => 
    notifications.value.filter(n => !n.is_read).length
  )

  // 获取通知列表
  const fetchNotifications = async () => {
    if (!user.value) return

    loading.value = true
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', user.value.id)
        .order('created_at', { ascending: false })
        .limit(50)

      if (error) {
        console.error('获取通知失败:', error)
        return
      }

      notifications.value = data || []
    } catch (error) {
      console.error('获取通知异常:', error)
    } finally {
      loading.value = false
    }
  }

  // 标记通知为已读
  const markAsRead = async (notificationId: string) => {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('id', notificationId)
        .eq('user_id', user.value.id)

      if (error) {
        console.error('标记通知已读失败:', error)
        return false
      }

      // 更新本地状态
      const notification = notifications.value.find(n => n.id === notificationId)
      if (notification) {
        notification.is_read = true
      }

      return true
    } catch (error) {
      console.error('标记通知已读异常:', error)
      return false
    }
  }

  // 标记所有通知为已读
  const markAllAsRead = async () => {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('user_id', user.value.id)
        .eq('is_read', false)

      if (error) {
        console.error('标记所有通知已读失败:', error)
        return false
      }

      // 更新本地状态
      notifications.value.forEach(n => {
        n.is_read = true
      })

      return true
    } catch (error) {
      console.error('标记所有通知已读异常:', error)
      return false
    }
  }

  // 删除通知
  const deleteNotification = async (notificationId: string) => {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', user.value.id)

      if (error) {
        console.error('删除通知失败:', error)
        return false
      }

      // 更新本地状态
      const index = notifications.value.findIndex(n => n.id === notificationId)
      if (index > -1) {
        notifications.value.splice(index, 1)
      }

      return true
    } catch (error) {
      console.error('删除通知异常:', error)
      return false
    }
  }

  // 切换通知面板显示状态
  const togglePanel = () => {
    showPanel.value = !showPanel.value
  }

  // 关闭通知面板
  const closePanel = () => {
    showPanel.value = false
  }

  // 监听实时通知
  const subscribeToNotifications = () => {
    if (!user.value) return

    const channel = supabase
      .channel('notifications')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          filter: `user_id=eq.${user.value.id}`
        },
        (payload) => {
          const newNotification = payload.new as Notification
          notifications.value.unshift(newNotification)
          
          // 显示浏览器通知
          if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(newNotification.title, {
              body: newNotification.message,
              icon: '/favicon.ico'
            })
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }

  // 请求通知权限
  const requestNotificationPermission = async () => {
    if ('Notification' in window && Notification.permission === 'default') {
      await Notification.requestPermission()
    }
  }

  // 初始化
  const initialize = async () => {
    await fetchNotifications()
    await requestNotificationPermission()
    return subscribeToNotifications()
  }

  return {
    notifications: readonly(notifications),
    loading: readonly(loading),
    showPanel: readonly(showPanel),
    unreadCount,
    fetchNotifications,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    togglePanel,
    closePanel,
    subscribeToNotifications,
    requestNotificationPermission,
    initialize
  }
})
