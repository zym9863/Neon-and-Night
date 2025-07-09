<template>
  <div class="min-h-screen relative">
    <!-- 时空背景 -->
    <TimeSpaceBackground />
    
    <!-- 主要内容 -->
    <div class="relative z-10 pt-20 pb-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- 页面标题 -->
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold neon-text mb-4">时间胶囊</h1>
          <p class="text-gray-300 max-w-2xl mx-auto">
            这里保存着你封存的记忆，等待着时间的钥匙来解锁
          </p>
        </div>

        <!-- 统计信息 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-cyan mb-2">{{ totalCapsules }}</div>
            <div class="text-gray-300 text-sm">总胶囊数</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-yellow mb-2">{{ sealedCapsules }}</div>
            <div class="text-gray-300 text-sm">封存中</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-green mb-2">{{ unlockedCapsules }}</div>
            <div class="text-gray-300 text-sm">已解锁</div>
          </div>
        </div>

        <!-- 胶囊列表 -->
        <div class="space-y-6">
          <!-- 即将解锁的胶囊 -->
          <div v-if="upcomingCapsules.length > 0">
            <h2 class="text-2xl font-bold text-white mb-4 flex items-center space-x-2">
              <ClockIcon class="w-6 h-6 text-neon-yellow" />
              <span>即将解锁</span>
            </h2>
            <div class="grid gap-4">
              <CapsuleCard
                v-for="capsule in upcomingCapsules"
                :key="capsule.id"
                :capsule="capsule"
                @unlock="handleUnlock"
                @view="handleView"
              />
            </div>
          </div>

          <!-- 已解锁的胶囊 -->
          <div v-if="unlockedCapsulesData.length > 0">
            <h2 class="text-2xl font-bold text-white mb-4 flex items-center space-x-2">
              <LockOpenIcon class="w-6 h-6 text-neon-green" />
              <span>已解锁</span>
            </h2>
            <div class="grid gap-4">
              <CapsuleCard
                v-for="capsule in unlockedCapsulesData"
                :key="capsule.id"
                :capsule="capsule"
                @unlock="handleUnlock"
                @view="handleView"
              />
            </div>
          </div>

          <!-- 长期封存的胶囊 -->
          <div v-if="longTermCapsules.length > 0">
            <h2 class="text-2xl font-bold text-white mb-4 flex items-center space-x-2">
              <LockClosedIcon class="w-6 h-6 text-gray-400" />
              <span>长期封存</span>
            </h2>
            <div class="grid gap-4">
              <CapsuleCard
                v-for="capsule in longTermCapsules"
                :key="capsule.id"
                :capsule="capsule"
                @unlock="handleUnlock"
                @view="handleView"
              />
            </div>
          </div>

          <!-- 空状态 -->
          <div v-if="capsules.length === 0 && !loading" class="text-center py-12">
            <div class="w-24 h-24 mx-auto mb-6 rounded-full bg-gradient-to-br from-gray-700 to-gray-800 flex items-center justify-center">
              <ArchiveBoxIcon class="w-12 h-12 text-gray-400" />
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">还没有时间胶囊</h3>
            <p class="text-gray-400 mb-6">封存一些记忆，让时间来治愈它们</p>
            <NuxtLink
              to="/sky"
              class="inline-flex items-center px-4 py-2 bg-neon-purple text-white rounded-lg hover:bg-neon-pink transition-colors"
            >
              去创建记忆
            </NuxtLink>
          </div>

          <!-- 加载状态 -->
          <div v-if="loading" class="text-center py-12">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-neon-purple mx-auto mb-4"></div>
            <p class="text-gray-400">加载中...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 胶囊详情模态框 -->
    <CapsuleDetailModal
      v-model:show="showDetailModal"
      :capsule="selectedCapsule"
      @unlocked="handleCapsuleUnlocked"
    />
  </div>
</template>

<script setup lang="ts">
import { 
  ClockIcon, 
  LockOpenIcon, 
  LockClosedIcon, 
  ArchiveBoxIcon 
} from '@heroicons/vue/24/outline'
import type { TimeCapsule } from '~/types'

definePageMeta({
  title: '时间胶囊'
})

const { supabase, user } = useSupabase()

const capsules = ref<TimeCapsule[]>([])
const loading = ref(false)
const showDetailModal = ref(false)
const selectedCapsule = ref<TimeCapsule | null>(null)

// 统计信息
const totalCapsules = computed(() => capsules.value.length)
const sealedCapsules = computed(() => 
  capsules.value.filter(c => !c.is_unlocked).length
)
const unlockedCapsules = computed(() => 
  capsules.value.filter(c => c.is_unlocked).length
)

// 分类胶囊
const upcomingCapsules = computed(() => {
  const now = new Date()
  const oneWeek = 7 * 24 * 60 * 60 * 1000
  
  return capsules.value.filter(capsule => {
    if (capsule.is_unlocked) return false
    const unlockTime = new Date(capsule.unlock_at)
    const timeDiff = unlockTime.getTime() - now.getTime()
    return timeDiff > 0 && timeDiff <= oneWeek
  }).sort((a, b) => new Date(a.unlock_at).getTime() - new Date(b.unlock_at).getTime())
})

const unlockedCapsulesData = computed(() => 
  capsules.value.filter(c => c.is_unlocked)
    .sort((a, b) => new Date(b.unlock_at).getTime() - new Date(a.unlock_at).getTime())
)

const longTermCapsules = computed(() => {
  const now = new Date()
  const oneWeek = 7 * 24 * 60 * 60 * 1000
  
  return capsules.value.filter(capsule => {
    if (capsule.is_unlocked) return false
    const unlockTime = new Date(capsule.unlock_at)
    const timeDiff = unlockTime.getTime() - now.getTime()
    return timeDiff > oneWeek
  }).sort((a, b) => new Date(a.unlock_at).getTime() - new Date(b.unlock_at).getTime())
})

// 获取时间胶囊列表
const fetchCapsules = async () => {
  if (!user.value) return

  loading.value = true
  try {
    const { data, error } = await supabase
      .from('time_capsules')
      .select(`
        *,
        memory_stars (
          title,
          content,
          emotion_type,
          color,
          created_at
        )
      `)
      .eq('user_id', user.value.id)
      .order('unlock_at', { ascending: true })

    if (error) {
      console.error('获取时间胶囊失败:', error)
      return
    }

    capsules.value = data || []
  } catch (error) {
    console.error('获取时间胶囊异常:', error)
  } finally {
    loading.value = false
  }
}

// 处理解锁
const handleUnlock = async (capsule: TimeCapsule) => {
  if (!user.value) return

  try {
    const { data, error } = await supabase
      .rpc('unlock_time_capsule', { capsule_id: capsule.id })

    if (error) {
      console.error('解锁胶囊失败:', error)
      return
    }

    if (data) {
      // 更新本地状态
      const index = capsules.value.findIndex(c => c.id === capsule.id)
      if (index > -1) {
        capsules.value[index].is_unlocked = true
      }
      
      console.log('胶囊解锁成功')
    }
  } catch (error) {
    console.error('解锁胶囊异常:', error)
  }
}

// 处理查看
const handleView = (capsule: TimeCapsule) => {
  selectedCapsule.value = capsule
  showDetailModal.value = true
}

// 处理胶囊解锁事件
const handleCapsuleUnlocked = (capsule: TimeCapsule) => {
  const index = capsules.value.findIndex(c => c.id === capsule.id)
  if (index > -1) {
    capsules.value[index] = capsule
  }
}

// 初始化
onMounted(async () => {
  await fetchCapsules()
})

// 页面标题
useHead({
  title: '时间胶囊 - 霓虹夜空'
})
</script>
