// 用户类型
export interface User {
  id: string
  email: string
  username?: string
  avatar_url?: string
  created_at: string
  updated_at: string
}

// 记忆星辰类型
export interface MemoryStar {
  id: string
  user_id: string
  title: string
  content: string
  content_type: 'text' | 'image' | 'audio'
  media_url?: string
  emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
  brightness: number // 0-100, 星辰亮度
  position_x: number // 在夜空中的位置
  position_y: number
  color: string // 星辰颜色
  is_sealed: boolean // 是否被封存
  seal_until?: string // 封存到什么时候
  created_at: string
  updated_at: string
}

// 共鸣类型
export interface Resonance {
  id: string
  memory_star_id: string
  sender_id?: string // 发送共鸣的用户ID（可为空，保持匿名）
  receiver_id: string // 接收共鸣的用户ID
  resonance_type: 'pulse' // 光脉冲类型
  message?: string // 可选的简短消息
  is_anonymous: boolean
  created_at: string
}

// 银河中的匿名情绪光点
export interface GalaxyEmotion {
  id: string
  original_memory_id: string
  emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
  anonymous_content: string // 匿名化的内容摘要
  color: string
  intensity: number // 情绪强度
  position_x: number
  position_y: number
  resonance_count: number // 收到的共鸣数量
  created_at: string
  expires_at?: string // 可选的过期时间
}

// 时间胶囊类型
export interface TimeCapsule {
  id: string
  user_id: string
  memory_star_id: string
  sealed_at: string
  unlock_at: string
  is_unlocked: boolean
  unlock_message?: string
  created_at: string
}

// 通知类型
export interface Notification {
  id: string
  user_id: string
  type: 'resonance_received' | 'capsule_unlocked' | 'memory_reminder'
  title: string
  message: string
  is_read: boolean
  related_id?: string // 相关的记忆或共鸣ID
  created_at: string
}

// 星空配置类型
export interface NightSkyConfig {
  user_id: string
  background_theme: 'classic' | 'aurora' | 'nebula' | 'cosmic'
  star_density: number // 背景星星密度
  animation_speed: number // 动画速度
  show_constellation_lines: boolean
  music_enabled: boolean
  ambient_sounds: boolean
}

// API 响应类型
export interface ApiResponse<T> {
  data?: T
  error?: string
  message?: string
}

// 分页类型
export interface PaginatedResponse<T> {
  data: T[]
  count: number
  page: number
  limit: number
  total_pages: number
}

// 表单类型
export interface CreateMemoryForm {
  title: string
  content: string
  content_type: 'text' | 'image' | 'audio'
  emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
  media_file?: File
}

export interface LoginForm {
  email: string
  password: string
}

export interface RegisterForm {
  email: string
  password: string
  username?: string
}

// 组件 Props 类型
export interface StarComponentProps {
  memory: MemoryStar
  size?: 'small' | 'medium' | 'large'
  interactive?: boolean
  showTooltip?: boolean
}

export interface GalaxyLightProps {
  emotion: GalaxyEmotion
  size?: 'small' | 'medium' | 'large'
  interactive?: boolean
}

// 动画配置类型
export interface AnimationConfig {
  duration: number
  easing: string
  delay?: number
  repeat?: number
}

// 3D 场景配置
export interface SceneConfig {
  camera: {
    position: [number, number, number]
    fov: number
  }
  lights: {
    ambient: number
    directional: {
      intensity: number
      position: [number, number, number]
    }
  }
  particles: {
    count: number
    size: number
    speed: number
  }
}
