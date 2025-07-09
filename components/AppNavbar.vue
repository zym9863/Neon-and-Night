<template>
  <nav class="fixed top-0 left-0 right-0 z-50 glass-effect border-b border-white/10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <div class="flex items-center">
          <NuxtLink to="/sky" class="text-xl font-bold neon-text">
            霓虹夜空
          </NuxtLink>
        </div>

        <!-- 导航菜单 -->
        <div class="hidden md:block">
          <div class="ml-10 flex items-baseline space-x-4">
            <NuxtLink
              to="/sky"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/sky' }"
            >
              我的星空
            </NuxtLink>
            <NuxtLink
              to="/galaxy"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/galaxy' }"
            >
              银河共鸣
            </NuxtLink>
            <NuxtLink
              to="/capsules"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/capsules' }"
            >
              时间胶囊
            </NuxtLink>
          </div>
        </div>

        <!-- 用户菜单 -->
        <div class="flex items-center space-x-4">
          <!-- 通知按钮 -->
          <button
            @click="toggleNotifications"
            class="relative p-2 text-gray-300 hover:text-white transition-colors"
          >
            <BellIcon class="h-6 w-6" />
            <span
              v-if="unreadCount > 0"
              class="absolute -top-1 -right-1 h-5 w-5 bg-neon-pink rounded-full flex items-center justify-center text-xs font-bold"
            >
              {{ unreadCount > 9 ? '9+' : unreadCount }}
            </span>
          </button>

          <!-- 用户头像菜单 -->
          <div class="relative" ref="userMenuRef">
            <button
              @click="toggleUserMenu"
              class="flex items-center space-x-2 p-2 rounded-lg hover:bg-white/10 transition-colors"
            >
              <div class="h-8 w-8 rounded-full bg-gradient-to-r from-neon-purple to-neon-pink flex items-center justify-center">
                <span class="text-sm font-bold text-white">
                  {{ userInitial }}
                </span>
              </div>
              <ChevronDownIcon class="h-4 w-4 text-gray-300" />
            </button>

            <!-- 用户菜单下拉 -->
            <Transition
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <div
                v-if="showUserMenu"
                class="absolute right-0 mt-2 w-48 glass-effect rounded-lg shadow-lg py-1 border border-white/20"
              >
                <hr class="my-1 border-white/20">
                <button
                  @click="handleSignOut"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-300 hover:bg-white/10 hover:text-white transition-colors"
                >
                  退出登录
                </button>
              </div>
            </Transition>
          </div>

          <!-- 移动端菜单按钮 -->
          <button
            @click="toggleMobileMenu"
            class="md:hidden p-2 text-gray-300 hover:text-white transition-colors"
          >
            <Bars3Icon v-if="!showMobileMenu" class="h-6 w-6" />
            <XMarkIcon v-else class="h-6 w-6" />
          </button>
        </div>
      </div>

      <!-- 移动端菜单 -->
      <Transition
        enter-active-class="transition ease-out duration-100"
        enter-from-class="transform opacity-0 scale-95"
        enter-to-class="transform opacity-100 scale-100"
        leave-active-class="transition ease-in duration-75"
        leave-from-class="transform opacity-100 scale-100"
        leave-to-class="transform opacity-0 scale-95"
      >
        <div v-if="showMobileMenu" class="md:hidden">
          <div class="px-2 pt-2 pb-3 space-y-1 border-t border-white/20">
            <NuxtLink
              to="/sky"
              class="mobile-nav-link"
              :class="{ 'mobile-nav-link-active': $route.path === '/sky' }"
              @click="showMobileMenu = false"
            >
              我的星空
            </NuxtLink>
            <NuxtLink
              to="/galaxy"
              class="mobile-nav-link"
              :class="{ 'mobile-nav-link-active': $route.path === '/galaxy' }"
              @click="showMobileMenu = false"
            >
              银河共鸣
            </NuxtLink>
            <NuxtLink
              to="/capsules"
              class="mobile-nav-link"
              :class="{ 'mobile-nav-link-active': $route.path === '/capsules' }"
              @click="showMobileMenu = false"
            >
              时间胶囊
            </NuxtLink>
          </div>
        </div>
      </Transition>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { BellIcon, ChevronDownIcon, Bars3Icon, XMarkIcon } from '@heroicons/vue/24/outline'
import { onClickOutside } from '@vueuse/core'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()

const showUserMenu = ref(false)
const showMobileMenu = ref(false)
const userMenuRef = ref()

// 用户初始字母
const userInitial = computed(() => {
  const profile = authStore.userProfile
  if (profile?.username) {
    return profile.username.charAt(0).toUpperCase()
  }
  if (profile?.email) {
    return profile.email.charAt(0).toUpperCase()
  }
  return 'U'
})

// 未读通知数量
const unreadCount = computed(() => notificationStore.unreadCount)

// 切换用户菜单
const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

// 切换移动端菜单
const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
}

// 切换通知面板
const toggleNotifications = () => {
  notificationStore.togglePanel()
}

// 登出
const handleSignOut = async () => {
  await authStore.signOut()
}

// 点击外部关闭菜单
onClickOutside(userMenuRef, () => {
  showUserMenu.value = false
})

// 路由变化时关闭移动端菜单
watch(() => useRoute().path, () => {
  showMobileMenu.value = false
})
</script>

<style scoped>
.nav-link {
  padding-left: 0.75rem;
  padding-right: 0.75rem;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #d1d5db;
  transition-property: color, background-color, border-color, text-decoration-color, fill, stroke;
  transition-duration: 150ms;
}
.nav-link:hover {
  color: #fff;
  background-color: rgba(255,255,255,0.1);
}

.nav-link-active {
  color: #67e8f9;
  background-color: rgba(255,255,255,0.1);
}

.mobile-nav-link {
  display: block;
  padding-left: 0.75rem;
  padding-right: 0.75rem;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  border-radius: 0.375rem;
  font-size: 1rem;
  font-weight: 500;
  color: #d1d5db;
  transition-property: color, background-color, border-color, text-decoration-color, fill, stroke;
  transition-duration: 150ms;
}
.mobile-nav-link:hover {
  color: #fff;
  background-color: rgba(255,255,255,0.1);
}

.mobile-nav-link-active {
  color: #67e8f9;
  background-color: rgba(255,255,255,0.1);
}
</style>
