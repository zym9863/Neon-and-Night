<template>
  <div class="min-h-screen flex items-center justify-center bg-space-900 relative overflow-hidden">
    <!-- 背景星空效果 -->
    <div class="absolute inset-0">
      <div class="stars-bg"></div>
    </div>
    
    <!-- 登录表单 -->
    <div class="relative z-10 w-full max-w-md">
      <div class="glass-effect rounded-2xl p-8 shadow-2xl">
        <!-- 标题 -->
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold neon-text mb-2">霓虹夜空</h1>
          <p class="text-gray-300">进入你的私密星空</p>
        </div>

        <!-- 登录表单 -->
        <form @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-300 mb-2">
              邮箱地址
            </label>
            <input
              id="email"
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400"
              placeholder="输入你的邮箱"
            />
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-gray-300 mb-2">
              密码
            </label>
            <input
              id="password"
              v-model="form.password"
              type="password"
              required
              class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-lg focus:outline-none focus:ring-2 focus:ring-neon-purple focus:border-transparent text-white placeholder-gray-400"
              placeholder="输入你的密码"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 px-4 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              登录中...
            </span>
            <span v-else>登录</span>
          </button>
        </form>

        <!-- 分隔线 -->
        <div class="my-6 flex items-center">
          <div class="flex-1 border-t border-white/20"></div>
          <span class="px-4 text-gray-400 text-sm">或</span>
          <div class="flex-1 border-t border-white/20"></div>
        </div>

        <!-- 注册链接 -->
        <div class="text-center">
          <p class="text-gray-400">
            还没有账户？
            <NuxtLink to="/auth/register" class="text-neon-cyan hover:text-neon-blue transition-colors">
              创建新账户
            </NuxtLink>
          </p>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="mt-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg">
          <p class="text-red-300 text-sm">{{ error }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { LoginForm } from '~/types'

definePageMeta({
  layout: false,
  auth: false
})

const { supabase } = useSupabase()
const router = useRouter()

const form = reactive<LoginForm>({
  email: '',
  password: ''
})

const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''

  try {
    const { error: authError } = await supabase.auth.signInWithPassword({
      email: form.email,
      password: form.password
    })

    if (authError) {
      error.value = authError.message
    } else {
      await router.push('/sky')
    }
  } catch (err) {
    error.value = '登录失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

// 页面标题
useHead({
  title: '登录 - 霓虹夜空'
})
</script>

<style scoped>
.stars-bg {
  background: radial-gradient(2px 2px at 20px 30px, #eee, transparent),
              radial-gradient(2px 2px at 40px 70px, rgba(255, 255, 255, 0.8), transparent),
              radial-gradient(1px 1px at 90px 40px, #fff, transparent),
              radial-gradient(1px 1px at 130px 80px, rgba(255, 255, 255, 0.6), transparent),
              radial-gradient(2px 2px at 160px 30px, #ddd, transparent);
  background-repeat: repeat;
  background-size: 200px 100px;
  animation: stars-move 20s linear infinite;
}

@keyframes stars-move {
  from {
    transform: translateY(0);
  }
  to {
    transform: translateY(-100px);
  }
}
</style>
