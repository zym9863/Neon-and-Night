<template>
  <div class="min-h-screen relative">
    <!-- 银河背景 -->
    <GalaxyBackground />
    
    <!-- 主要内容 -->
    <div class="relative z-10 pt-20 pb-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- 页面标题 -->
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold neon-text mb-4">银河共鸣</h1>
          <p class="text-gray-300 max-w-2xl mx-auto">
            在这里感受来自陌生人的情感共鸣，每一个光点都是一颗匿名的心灵
          </p>
        </div>

        <!-- 情绪过滤器 -->
        <div class="flex flex-wrap justify-center gap-3 mb-8">
          <button
            v-for="emotion in emotionFilters"
            :key="emotion.value"
            @click="toggleEmotionFilter(emotion.value)"
            class="px-4 py-2 rounded-full border transition-all duration-200 flex items-center space-x-2"
            :class="selectedEmotions.includes(emotion.value) 
              ? 'border-neon-purple bg-neon-purple/20 text-neon-purple' 
              : 'border-white/20 text-gray-300 hover:border-white/40'"
          >
            <component :is="emotion.icon" class="w-4 h-4" />
            <span>{{ emotion.label }}</span>
          </button>
          <button
            @click="clearFilters"
            class="px-4 py-2 rounded-full border border-gray-600 text-gray-400 hover:border-gray-500 hover:text-gray-300 transition-colors"
          >
            清除筛选
          </button>
        </div>

        <!-- 银河画布 -->
        <div class="relative">
          <div
            ref="galaxyCanvas"
            class="w-full h-96 md:h-[600px] glass-effect rounded-2xl overflow-hidden relative"
          >
            <!-- 情绪光点 -->
            <GalaxyEmotion
              v-for="emotion in filteredEmotions"
              :key="emotion.id"
              :emotion="emotion"
              :style="{
                left: `${emotion.position_x}%`,
                top: `${emotion.position_y}%`
              }"
              @click="handleEmotionClick"
              @resonance="handleResonance"
            />
            
            <!-- 空状态 -->
            <div
              v-if="filteredEmotions.length === 0 && !loading"
              class="absolute inset-0 flex items-center justify-center"
            >
              <div class="text-center">
                <SparklesIcon class="h-16 w-16 text-gray-500 mx-auto mb-4" />
                <p class="text-gray-400 mb-4">银河中还没有情绪光点</p>
                <p class="text-gray-500 text-sm">去创建一些记忆并投放到银河吧</p>
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

        <!-- 统计信息 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-8">
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-cyan mb-2">{{ galaxyEmotions.length }}</div>
            <div class="text-gray-300 text-sm">情绪光点</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-pink mb-2">{{ totalResonances }}</div>
            <div class="text-gray-300 text-sm">总共鸣数</div>
          </div>
          <div class="glass-effect rounded-lg p-6 text-center">
            <div class="text-2xl font-bold text-neon-yellow mb-2">{{ myResonances }}</div>
            <div class="text-gray-300 text-sm">我的共鸣</div>
          </div>
        </div>

        <!-- 最近的共鸣 -->
        <div class="mt-8">
          <h2 class="text-2xl font-bold text-white mb-6">最近的共鸣</h2>
          <RecentResonances :resonances="recentResonances" />
        </div>
      </div>
    </div>

    <!-- 情绪详情模态框 -->
    <EmotionDetailModal
      v-model:show="showDetailModal"
      :emotion="selectedEmotion"
      @resonance="handleResonance"
    />
  </div>
</template>

<script setup lang="ts">
import { 
  SparklesIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SunIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'
import type { GalaxyEmotion, Resonance } from '~/types'

definePageMeta({
  title: '银河共鸣'
})

const { supabase, user } = useSupabase()

const galaxyEmotions = ref<GalaxyEmotion[]>([])
const recentResonances = ref<Resonance[]>([])
const selectedEmotions = ref<string[]>([])
const loading = ref(false)
const showDetailModal = ref(false)
const selectedEmotion = ref<GalaxyEmotion | null>(null)
const galaxyCanvas = ref<HTMLElement>()

// 情绪过滤器
const emotionFilters = [
  { value: 'joy', label: '快乐', icon: FaceSmileIcon },
  { value: 'love', label: '爱意', icon: HeartIcon },
  { value: 'hope', label: '希望', icon: SunIcon },
  { value: 'nostalgia', label: '怀念', icon: ClockIcon },
  { value: 'sadness', label: '悲伤', icon: FaceFrownIcon },
  { value: 'pain', label: '痛苦', icon: SparklesIcon }
]

// 过滤后的情绪
const filteredEmotions = computed(() => {
  if (selectedEmotions.value.length === 0) {
    return galaxyEmotions.value
  }
  return galaxyEmotions.value.filter(emotion => 
    selectedEmotions.value.includes(emotion.emotion_type)
  )
})

// 统计信息
const totalResonances = computed(() => 
  galaxyEmotions.value.reduce((sum, emotion) => sum + emotion.resonance_count, 0)
)

const myResonances = computed(() => recentResonances.value.length)

// 获取银河情绪
const fetchGalaxyEmotions = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('galaxy_emotions')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(100)

    if (error) {
      console.error('获取银河情绪失败:', error)
      return
    }

    galaxyEmotions.value = data || []
  } catch (error) {
    console.error('获取银河情绪异常:', error)
  } finally {
    loading.value = false
  }
}

// 获取最近的共鸣
const fetchRecentResonances = async () => {
  if (!user.value) return

  try {
    const { data, error } = await supabase
      .from('resonances')
      .select(`
        *,
        galaxy_emotions (
          anonymous_content,
          emotion_type,
          color
        )
      `)
      .eq('sender_id', user.value.id)
      .order('created_at', { ascending: false })
      .limit(20)

    if (error) {
      console.error('获取最近共鸣失败:', error)
      return
    }

    recentResonances.value = data || []
  } catch (error) {
    console.error('获取最近共鸣异常:', error)
  }
}

// 切换情绪过滤器
const toggleEmotionFilter = (emotionType: string) => {
  const index = selectedEmotions.value.indexOf(emotionType)
  if (index > -1) {
    selectedEmotions.value.splice(index, 1)
  } else {
    selectedEmotions.value.push(emotionType)
  }
}

// 清除过滤器
const clearFilters = () => {
  selectedEmotions.value = []
}

// 处理情绪点击
const handleEmotionClick = (emotion: GalaxyEmotion) => {
  selectedEmotion.value = emotion
  showDetailModal.value = true
}

// 处理共鸣
const handleResonance = async (emotion: GalaxyEmotion) => {
  if (!user.value) return

  try {
    // 获取原始记忆的作者
    const { data: memoryData, error: memoryError } = await supabase
      .from('memory_stars')
      .select('user_id')
      .eq('id', emotion.original_memory_id)
      .single()

    if (memoryError) {
      console.error('获取记忆作者失败:', memoryError)
      return
    }

    // 发送共鸣
    const { error } = await supabase
      .from('resonances')
      .insert({
        galaxy_emotion_id: emotion.id,
        sender_id: user.value.id,
        receiver_id: memoryData.user_id,
        resonance_type: 'pulse',
        is_anonymous: true
      })

    if (error) {
      console.error('发送共鸣失败:', error)
      return
    }

    // 更新本地状态
    const emotionIndex = galaxyEmotions.value.findIndex(e => e.id === emotion.id)
    if (emotionIndex > -1) {
      galaxyEmotions.value[emotionIndex].resonance_count += 1
    }

    // 刷新最近共鸣
    await fetchRecentResonances()

    console.log('共鸣发送成功')
  } catch (error) {
    console.error('发送共鸣异常:', error)
  }
}

// 初始化
onMounted(async () => {
  await Promise.all([
    fetchGalaxyEmotions(),
    fetchRecentResonances()
  ])
})

// 页面标题
useHead({
  title: '银河共鸣 - 霓虹夜空'
})
</script>
