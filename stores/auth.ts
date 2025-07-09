import { defineStore } from 'pinia'
import type { User } from '~/types'

export const useAuthStore = defineStore('auth', () => {
  const { supabase, user: supabaseUser } = useSupabase()
  
  const userProfile = ref<User | null>(null)
  const loading = ref(false)

  // 获取用户配置信息
  const fetchUserProfile = async () => {
    if (!supabaseUser.value) return null

    loading.value = true
    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', supabaseUser.value.id)
        .single()

      if (error) {
        console.error('获取用户配置失败:', error)
        return null
      }

      userProfile.value = {
        id: data.id,
        email: supabaseUser.value.email || '',
        username: data.username,
        avatar_url: data.avatar_url,
        created_at: data.created_at,
        updated_at: data.updated_at
      }

      return userProfile.value
    } catch (error) {
      console.error('获取用户配置异常:', error)
      return null
    } finally {
      loading.value = false
    }
  }

  // 更新用户配置
  const updateUserProfile = async (updates: Partial<Pick<User, 'username' | 'avatar_url'>>) => {
    if (!supabaseUser.value) return false

    loading.value = true
    try {
      const { error } = await supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', supabaseUser.value.id)

      if (error) {
        console.error('更新用户配置失败:', error)
        return false
      }

      // 重新获取用户配置
      await fetchUserProfile()
      return true
    } catch (error) {
      console.error('更新用户配置异常:', error)
      return false
    } finally {
      loading.value = false
    }
  }

  // 登出
  const signOut = async () => {
    loading.value = true
    try {
      const { error } = await supabase.auth.signOut()
      if (error) {
        console.error('登出失败:', error)
        return false
      }
      
      userProfile.value = null
      await navigateTo('/auth/login')
      return true
    } catch (error) {
      console.error('登出异常:', error)
      return false
    } finally {
      loading.value = false
    }
  }

  // 监听用户状态变化
  watch(supabaseUser, async (newUser) => {
    if (newUser) {
      await fetchUserProfile()
    } else {
      userProfile.value = null
    }
  }, { immediate: true })

  return {
    userProfile: readonly(userProfile),
    loading: readonly(loading),
    fetchUserProfile,
    updateUserProfile,
    signOut
  }
})
