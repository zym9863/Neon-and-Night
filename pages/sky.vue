<template>
  <div class="min-h-screen relative">
    <!-- 星空背景 -->
    <NightSkyBackground />
    
    <!-- 主要内容 -->
    <div class="relative z-10 pt-20 pb-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- 页面标题 -->
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold neon-text mb-4">我的星空</h1>
          <p class="text-gray-300 max-w-2xl mx-auto">
            在这里记录你的情感瞬间，每一段记忆都会化作夜空中闪烁的星辰
          </p>
        </div>

        <!-- 统计信息 -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-cyan mb-2">{{ stats.total_stars }}</div>
            <div class="text-gray-300 text-sm">记忆星辰</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-purple mb-2">{{ stats.galaxy_emotions }}</div>
            <div class="text-gray-300 text-sm">银河共鸣</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-pink mb-2">{{ stats.received_resonances }}</div>
            <div class="text-gray-300 text-sm">收到共鸣</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-yellow mb-2">{{ stats.sealed_stars }}</div>
            <div class="text-gray-300 text-sm">封存记忆</div>
          </div>
        </div>

        <!-- 操作按钮 -->
        <div class="flex flex-col sm:flex-row gap-4 mb-8 justify-center">
          <button
            @click="showCreateModal = true"
            class="px-6 py-3 bg-gradient-to-r from-neon-purple to-neon-pink rounded-lg font-medium text-white hover:from-neon-pink hover:to-neon-purple transition-all duration-300 flex items-center justify-center space-x-2"
          >
            <PlusIcon class="h-5 w-5" />
            <span>创建新记忆</span>
          </button>
          
          <NuxtLink
            to="/galaxy"
            class="px-6 py-3 border border-neon-cyan text-neon-cyan rounded-lg font-medium hover:bg-neon-cyan hover:text-space-900 transition-all duration-300 flex items-center justify-center space-x-2"
          >
            <SparklesIcon class="h-5 w-5" />
            <span>探索银河</span>
          </NuxtLink>
        </div>

        <!-- 星空画布 -->
        <div class="relative">
          <div
            ref="skyCanvas"
            class="w-full h-96 md:h-[500px] glass-effect rounded-2xl overflow-hidden relative cursor-crosshair"
            @click="handleCanvasClick"
          >
            <!-- 记忆星辰 -->
            <MemoryStar
              v-for="memory in memories"
              :key="memory.id"
              :memory="memory"
              :style="{
                left: `${memory.position_x}%`,
                top: `${memory.position_y}%`
              }"
              @click="handleStarClick"
              @update="handleStarUpdate"
            />
            
            <!-- 空状态 -->
            <div
              v-if="memories.length === 0 && !loading"
              class="absolute inset-0 flex items-center justify-center"
            >
              <div class="text-center">
                <StarIcon class="h-16 w-16 text-gray-500 mx-auto mb-4" />
                <p class="text-gray-400 mb-4">你的星空还很空旷</p>
                <button
                  @click="showCreateModal = true"
                  class="px-4 py-2 bg-neon-purple text-white rounded-lg hover:bg-neon-pink transition-colors"
                >
                  创建第一颗星辰
                </button>
              </div>
            </div>
            
            <!-- 加载状态 -->
            <div
              v-if="loading"
              class="absolute inset-0 flex items-center justify-center"
            >
              <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-neon-purple"></div>
            </div>
          </div>
        </div>

        <!-- 记忆列表 -->
        <div class="mt-8">
          <h2 class="text-2xl font-bold text-white mb-6">记忆时光轴</h2>
          <MemoryTimeline
            :memories="memories"
            @memory-click="handleStarClick"
            @share-to-galaxy="handleShareToGalaxy"
            @edit-memory="handleStarClick"
          />
        </div>
      </div>
    </div>

    <!-- 创建记忆模态框 -->
    <CreateMemoryModal
      v-model:show="showCreateModal"
      @created="handleMemoryCreated"
    />

    <!-- 记忆详情模态框 -->
    <MemoryDetailModal
      v-model:show="showDetailModal"
      :memory="selectedMemory"
      @updated="handleMemoryUpdated"
      @deleted="handleMemoryDeleted"
    />
  </div>
</template>

<script setup lang="ts">
import { PlusIcon, SparklesIcon, StarIcon } from '@heroicons/vue/24/outline'
import type { MemoryStar } from '~/types'

definePageMeta({
  title: '我的星空'
})

const { supabase, user } = useSupabase()

const memories = ref<MemoryStar[]>([])
const stats = ref({
  total_stars: 0,
  sealed_stars: 0,
  galaxy_emotions: 0,
  received_resonances: 0,
  sent_resonances: 0,
  unlocked_capsules: 0
})
const loading = ref(false)
const showCreateModal = ref(false)
const showDetailModal = ref(false)
const selectedMemory = ref<MemoryStar | null>(null)
const skyCanvas = ref<HTMLElement>()

// 获取记忆列表
const fetchMemories = async () => {
  if (!user.value) return

  loading.value = true
  try {
    const { data, error } = await supabase
      .from('memory_stars')
      .select('*')
      .eq('user_id', user.value.id)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('获取记忆失败:', error)
      return
    }

    memories.value = data || []
  } catch (error) {
    console.error('获取记忆异常:', error)
  } finally {
    loading.value = false
  }
}

// 获取统计信息
const fetchStats = async () => {
  if (!user.value) return

  try {
    const { data, error } = await supabase
      .rpc('get_user_sky_stats', { user_uuid: user.value.id })

    if (error) {
      console.error('获取统计信息失败:', error)
      return
    }

    if (data && data.length > 0) {
      stats.value = data[0]
    }
  } catch (error) {
    console.error('获取统计信息异常:', error)
  }
}

// 处理画布点击
const handleCanvasClick = (event: MouseEvent) => {
  if (!skyCanvas.value) return

  const rect = skyCanvas.value.getBoundingClientRect()
  const x = ((event.clientX - rect.left) / rect.width) * 100
  const y = ((event.clientY - rect.top) / rect.height) * 100

  // 如果点击的不是星辰，显示创建模态框
  const target = event.target as HTMLElement
  if (target === skyCanvas.value) {
    showCreateModal.value = true
  }
}

// 处理星辰点击
const handleStarClick = (memory: MemoryStar) => {
  selectedMemory.value = memory
  showDetailModal.value = true
}

// 处理星辰更新
const handleStarUpdate = (memory: MemoryStar) => {
  const index = memories.value.findIndex(m => m.id === memory.id)
  if (index > -1) {
    memories.value[index] = memory
  }
}

// 处理记忆创建
const handleMemoryCreated = (memory: MemoryStar) => {
  memories.value.unshift(memory)
  fetchStats()
}

// 处理记忆更新
const handleMemoryUpdated = (memory: MemoryStar) => {
  handleStarUpdate(memory)
  fetchStats()
}

// 处理记忆删除
const handleMemoryDeleted = (memoryId: string) => {
  const index = memories.value.findIndex(m => m.id === memoryId)
  if (index > -1) {
    memories.value.splice(index, 1)
  }
  fetchStats()
}

// 处理分享到银河
const handleShareToGalaxy = async (memory: MemoryStar) => {
  if (!user.value) return

  try {
    // 生成匿名内容
    const { data: anonymousContent } = await supabase
      .rpc('anonymize_memory_content', {
        content: memory.content,
        emotion_type: memory.emotion_type
      })

    // 生成随机位置
    const position = {
      x: Math.random() * 100,
      y: Math.random() * 100
    }

    const { error } = await supabase
      .from('galaxy_emotions')
      .insert({
        original_memory_id: memory.id,
        emotion_type: memory.emotion_type,
        anonymous_content: anonymousContent || '一段匿名的情感记忆',
        color: memory.color,
        intensity: Math.floor(memory.brightness / 10),
        position_x: position.x,
        position_y: position.y
      })

    if (error) {
      console.error('投放银河失败:', error)
      return
    }

    // 显示成功提示
    console.log('成功投放到银河')
  } catch (error) {
    console.error('投放银河异常:', error)
  }
}

// 初始化
onMounted(async () => {
  await Promise.all([
    fetchMemories(),
    fetchStats()
  ])
})

// 页面标题
useHead({
  title: '我的星空 - 霓虹夜空'
})
</script>
