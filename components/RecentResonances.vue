<template>
  <div class="space-y-4">
    <div v-if="resonances.length === 0" class="text-center py-8">
      <HeartIcon class="h-12 w-12 text-gray-500 mx-auto mb-4" />
      <p class="text-gray-400">还没有发送过共鸣</p>
      <p class="text-gray-500 text-sm mt-2">去银河中寻找共鸣的光点吧</p>
    </div>
    
    <div v-else class="grid gap-4">
      <div
        v-for="resonance in resonances"
        :key="resonance.id"
        class="glass-effect rounded-lg p-4 hover:bg-white/10 transition-all duration-300"
      >
        <div class="flex items-start space-x-4">
          <!-- 共鸣图标 -->
          <div class="flex-shrink-0 mt-1">
            <div
              class="w-8 h-8 rounded-full flex items-center justify-center"
              :style="{ 
                backgroundColor: getEmotionColor(resonance.galaxy_emotions?.emotion_type),
                boxShadow: `0 0 8px ${getEmotionColor(resonance.galaxy_emotions?.emotion_type)}`
              }"
            >
              <HeartIcon class="w-4 h-4 text-white" />
            </div>
          </div>
          
          <!-- 共鸣内容 -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center space-x-2 mb-2">
              <span class="text-white font-medium">
                向{{ getEmotionText(resonance.galaxy_emotions?.emotion_type) }}光点发送了共鸣
              </span>
              <span class="px-2 py-1 bg-neon-purple/20 text-neon-purple text-xs rounded-full">
                光脉冲
              </span>
            </div>
            
            <p class="text-gray-300 text-sm mb-2">
              {{ resonance.galaxy_emotions?.anonymous_content }}
            </p>
            
            <div class="flex items-center space-x-4 text-xs text-gray-400">
              <div>
                {{ formatRelativeTime(resonance.created_at) }}
              </div>
              <div v-if="resonance.is_anonymous" class="flex items-center space-x-1">
                <EyeSlashIcon class="w-3 h-3" />
                <span>匿名共鸣</span>
              </div>
            </div>
          </div>
          
          <!-- 状态指示器 -->
          <div class="flex-shrink-0">
            <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse" title="已送达"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { HeartIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'
import type { Resonance } from '~/types'

interface Props {
  resonances: Resonance[]
}

defineProps<Props>()

// 获取情绪颜色
const getEmotionColor = (emotionType?: string) => {
  if (!emotionType) return '#ffffff'
  
  const colorMap = {
    pain: '#ff006e',
    joy: '#ffbe0b',
    sadness: '#3a86ff',
    love: '#ff006e',
    hope: '#06ffa5',
    nostalgia: '#8338ec'
  }
  return colorMap[emotionType as keyof typeof colorMap] || '#ffffff'
}

// 获取情绪文本
const getEmotionText = (emotionType?: string) => {
  if (!emotionType) return '未知'
  
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

// 格式化相对时间
const formatRelativeTime = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  
  return date.toLocaleDateString('zh-CN')
}
</script>
