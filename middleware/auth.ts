export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  // 如果用户未登录且不是在认证页面，重定向到登录页
  if (!user.value && !to.path.startsWith('/auth')) {
    return navigateTo('/auth/login')
  }

  // 如果用户已登录且在认证页面，重定向到主页面
  if (user.value && to.path.startsWith('/auth')) {
    return navigateTo('/sky')
  }
})
