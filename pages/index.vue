<template>
  <div class="min-h-screen flex items-center justify-center bg-space-900">
    <div class="text-center">
      <h1 class="text-4xl font-bold neon-text mb-4">霓虹夜空</h1>
      <p class="text-gray-300 mb-8">一个私密的情感记录与共鸣空间</p>
      
      <div class="space-y-4">
        <NuxtLink 
          to="/auth/login"
          class="block w-full py-3 px-6 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300"
        >
          进入星空
        </NuxtLink>
        
        <NuxtLink 
          to="/auth/register"
          class="block w-full py-3 px-6 border border-neon-cyan text-neon-cyan rounded-lg font-medium hover:bg-neon-cyan hover:text-space-900 transition-all duration-300"
        >
          创建新星空
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
  auth: false
})

const user = useSupabaseUser()

// 如果用户已登录，重定向到星空页面
watch(user, (newUser) => {
  if (newUser) {
    navigateTo('/sky')
  }
}, { immediate: true })

useHead({
  title: '霓虹夜空 - 情感记录与共鸣空间'
})
</script>
