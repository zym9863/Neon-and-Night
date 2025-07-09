<template>
  <div id="app" class="min-h-screen bg-space-900">
    <NuxtRouteAnnouncer />
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// 设置页面元信息
useHead({
  htmlAttrs: {
    lang: 'zh-CN'
  },
  bodyAttrs: {
    class: 'antialiased'
  }
})

// 初始化应用
onMounted(() => {
  // 可以在这里添加全局初始化逻辑
  console.log('霓虹夜空应用已启动')
})
</script>
