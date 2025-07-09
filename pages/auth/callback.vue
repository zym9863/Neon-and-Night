<template>
  <div class="min-h-screen flex items-center justify-center bg-space-900">
    <div class="text-center">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-neon-purple mx-auto mb-4"></div>
      <p class="text-white">正在验证登录状态...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
  auth: false
})

const router = useRouter()

onMounted(async () => {
  // 等待一下让 Supabase 处理回调
  await new Promise(resolve => setTimeout(resolve, 1000))
  
  // 重定向到主页面
  await router.push('/sky')
})

useHead({
  title: '登录验证 - 霓虹夜空'
})
</script>
