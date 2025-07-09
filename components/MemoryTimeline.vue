<template>
  <div class="space-y-6">
    <div v-if="memories.length === 0" class="text-center py-12">
      <ClockIcon class="h-16 w-16 text-gray-500 mx-auto mb-4" />
      <p class="text-gray-400">还没有记忆记录</p>
    </div>
    
    <div v-else class="relative">
      <!-- 时间线 -->
      <div class="absolute left-8 top-0 bottom-0 w-0.5 bg-gradient-to-b from-neon-purple via-neon-pink to-neon-cyan"></div>
      
      <!-- 记忆项目 -->
      <div
        v-for="(memory, index) in memories"
        :key="memory.id"
        class="relative flex items-start space-x-6 pb-8"
      >
        <!-- 时间线节点 -->
        <div class="relative flex-shrink-0">
          <div
            class="w-4 h-4 rounded-full border-2 border-white/20 flex items-center justify-center"
            :style="{ 
              backgroundColor: memory.color,
              boxShadow: `0 0 12px ${memory.color}`,
              borderColor: memory.color
            }"
          >
            <div class="w-2 h-2 rounded-full bg-white"></div>
          </div>
          
          <!-- 连接线到下一个节点 -->
          <div
            v-if="index < memories.length - 1"
            class="absolute top-4 left-1/2 transform -translate-x-1/2 w-0.5 h-8 bg-gradient-to-b from-current to-transparent opacity-30"
            :style="{ color: memory.color }"
          ></div>
        </div>
        
        <!-- 记忆卡片 -->
        <div
          class="flex-1 glass-effect rounded-lg p-4 hover:bg-white/10 transition-all duration-300 cursor-pointer group"
          @click="$emit('memoryClick', memory)"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <!-- 标题和状态 -->
              <div class="flex items-center space-x-3 mb-2">
                <h3 class="text-lg font-semibold text-white group-hover:text-neon-cyan transition-colors">
                  {{ memory.title }}
                </h3>
                <span
                  v-if="memory.is_sealed"
                  class="px-2 py-1 bg-gray-600 text-gray-200 text-xs rounded-full flex items-center space-x-1"
                >
                  <LockClosedIcon class="w-3 h-3" />
                  <span>封存</span>
                </span>
              </div>
              
              <!-- 内容预览 -->
              <p class="text-gray-300 text-sm mb-3 line-clamp-2">
                {{ getContentPreview(memory) }}
              </p>
              
              <!-- 元信息 -->
              <div class="flex items-center space-x-4 text-xs text-gray-400">
                <div class="flex items-center space-x-1">
                  <component :is="getEmotionIcon(memory.emotion_type)" class="w-3 h-3" />
                  <span>{{ getEmotionText(memory.emotion_type) }}</span>
                </div>
                <div class="flex items-center space-x-1">
                  <component :is="getContentTypeIcon(memory.content_type)" class="w-3 h-3" />
                  <span>{{ getContentTypeText(memory.content_type) }}</span>
                </div>
                <div>
                  亮度 {{ memory.brightness }}%
                </div>
                <div>
                  {{ formatRelativeTime(memory.created_at) }}
                </div>
              </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
              <button
                @click.stop="$emit('shareToGalaxy', memory)"
                class="p-2 text-gray-400 hover:text-purple-400 transition-colors rounded-lg hover:bg-white/10"
                title="投放银河"
              >
                <SparklesIcon class="w-4 h-4" />
              </button>
              <button
                @click.stop="$emit('editMemory', memory)"
                class="p-2 text-gray-400 hover:text-blue-400 transition-colors rounded-lg hover:bg-white/10"
                title="编辑记忆"
              >
                <PencilIcon class="w-4 h-4" />
              </button>
            </div>
          </div>
          
          <!-- 媒体预览 -->
          <div v-if="memory.media_url" class="mt-3">
            <img
              v-if="memory.content_type === 'image'"
              :src="memory.media_url"
              :alt="memory.title"
              class="w-full max-w-xs h-32 object-cover rounded-lg"
            />
            <div
              v-else-if="memory.content_type === 'audio'"
              class="flex items-center space-x-3 p-3 bg-white/5 rounded-lg"
            >
              <MicrophoneIcon class="w-5 h-5 text-gray-400" />
              <span class="text-sm text-gray-300">音频记忆</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  ClockIcon,
  LockClosedIcon,
  SparklesIcon,
  PencilIcon,
  MicrophoneIcon,
  DocumentTextIcon,
  PhotoIcon,
  HeartIcon,
  FaceSmileIcon,
  FaceFrownIcon,
  SunIcon
} from '@heroicons/vue/24/outline'
import type { MemoryStar } from '~/types'

interface Props {
  memories: MemoryStar[]
}

defineProps<Props>()

defineEmits<{
  memoryClick: [memory: MemoryStar]
  shareToGalaxy: [memory: MemoryStar]
  editMemory: [memory: MemoryStar]
}>()

// 获取内容预览
const getContentPreview = (memory: MemoryStar) => {
  if (memory.content_type === 'text') {
    return memory.content.length > 100 
      ? memory.content.substring(0, 100) + '...'
      : memory.content
  } else {
    return memory.content || `${getContentTypeText(memory.content_type)}记忆`
  }
}

// 获取情绪图标
const getEmotionIcon = (emotionType: string) => {
  switch (emotionType) {
    case 'love': return HeartIcon
    case 'joy': return FaceSmileIcon
    case 'pain': 
    case 'sadness': return FaceFrownIcon
    case 'hope': return SunIcon
    case 'nostalgia': return ClockIcon
    default: return SparklesIcon
  }
}

// 获取情绪文本
const getEmotionText = (emotionType: string) => {
  const emotionMap = {
    pain: '痛苦',
    joy: '快乐',
    sadness: '悲伤',
    love: '爱意',
    hope: '希望',
    nostalgia: '怀念'
  }
  return emotionMap[emotionType as keyof typeof emotionMap] || '未知'
}

// 获取内容类型图标
const getContentTypeIcon = (contentType: string) => {
  switch (contentType) {
    case 'image': return PhotoIcon
    case 'audio': return MicrophoneIcon
    default: return DocumentTextIcon
  }
}

// 获取内容类型文本
const getContentTypeText = (contentType: string) => {
  const typeMap = {
    text: '文字',
    image: '图片',
    audio: '音频'
  }
  return typeMap[contentType as keyof typeof typeMap] || '未知'
}

// 格式化相对时间
const formatRelativeTime = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const months = Math.floor(days / 30)
  const years = Math.floor(days / 365)
  
  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 30) return `${days}天前`
  if (months < 12) return `${months}个月前`
  return `${years}年前`
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
