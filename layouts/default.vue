<template>
  <div class="min-h-screen bg-space-900 relative overflow-hidden">
    <!-- 导航栏 -->
    <AppNavbar />
    
    <!-- 主要内容区域 -->
    <main class="relative z-10">
      <slot />
    </main>
    
    <!-- 通知组件 -->
    <AppNotifications />
  </div>
</template>

<script setup lang="ts">
// 确保用户已登录
definePageMeta({
  middleware: 'auth'
})

// 初始化用户状态
const authStore = useAuthStore()
onMounted(() => {
  authStore.fetchUserProfile()
})
</script>
