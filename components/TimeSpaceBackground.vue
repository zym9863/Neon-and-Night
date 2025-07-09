<template>
  <div class="fixed inset-0 overflow-hidden pointer-events-none">
    <!-- 时空渐变背景 -->
    <div class="absolute inset-0 bg-gradient-to-br from-indigo-900/30 via-space-900 to-purple-900/30"></div>
    
    <!-- 时间波纹 -->
    <div class="absolute inset-0">
      <div
        v-for="ripple in timeRipples"
        :key="ripple.id"
        class="absolute rounded-full border border-white/10"
        :style="{
          left: `${ripple.x}%`,
          top: `${ripple.y}%`,
          width: `${ripple.size}px`,
          height: `${ripple.size}px`,
          transform: 'translate(-50%, -50%)',
          animationDelay: `${ripple.delay}s`,
          animationDuration: `${ripple.duration}s`
        }"
        :class="ripple.animation"
      ></div>
    </div>
    
    <!-- 时钟粒子 -->
    <div class="absolute inset-0">
      <div
        v-for="particle in clockParticles"
        :key="particle.id"
        class="absolute w-1 h-1 bg-blue-300 rounded-full opacity-30"
        :style="{
          left: `${particle.x}%`,
          top: `${particle.y}%`,
          animationDelay: `${particle.delay}s`,
          animationDuration: `${particle.duration}s`
        }"
        :class="particle.animation"
      ></div>
    </div>
    
    <!-- 时间线条 -->
    <div class="absolute inset-0 opacity-20">
      <div
        v-for="line in timeLines"
        :key="line.id"
        class="absolute bg-gradient-to-r from-transparent via-cyan-400 to-transparent"
        :style="{
          left: `${line.x}%`,
          top: `${line.y}%`,
          width: `${line.width}px`,
          height: '1px',
          transform: `rotate(${line.angle}deg)`,
          animationDelay: `${line.delay}s`,
          animationDuration: `${line.duration}s`
        }"
        :class="line.animation"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface TimeRipple {
  id: number
  x: number
  y: number
  size: number
  delay: number
  duration: number
  animation: string
}

interface ClockParticle {
  id: number
  x: number
  y: number
  delay: number
  duration: number
  animation: string
}

interface TimeLine {
  id: number
  x: number
  y: number
  width: number
  angle: number
  delay: number
  duration: number
  animation: string
}

const timeRipples = ref<TimeRipple[]>([])
const clockParticles = ref<ClockParticle[]>([])
const timeLines = ref<TimeLine[]>([])

// 生成时间波纹
const generateTimeRipples = (count: number) => {
  const ripples: TimeRipple[] = []
  
  for (let i = 0; i < count; i++) {
    ripples.push({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: Math.random() * 200 + 50,
      delay: Math.random() * 10,
      duration: Math.random() * 8 + 4,
      animation: 'animate-ping'
    })
  }
  
  return ripples
}

// 生成时钟粒子
const generateClockParticles = (count: number) => {
  const particles: ClockParticle[] = []
  const animations = ['animate-float', 'animate-pulse-slow', 'animate-bounce-slow']
  
  for (let i = 0; i < count; i++) {
    particles.push({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      delay: Math.random() * 5,
      duration: Math.random() * 6 + 3,
      animation: animations[Math.floor(Math.random() * animations.length)]
    })
  }
  
  return particles
}

// 生成时间线条
const generateTimeLines = (count: number) => {
  const lines: TimeLine[] = []
  
  for (let i = 0; i < count; i++) {
    lines.push({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      width: Math.random() * 150 + 50,
      angle: Math.random() * 360,
      delay: Math.random() * 8,
      duration: Math.random() * 12 + 6,
      animation: 'animate-pulse-slow'
    })
  }
  
  return lines
}

onMounted(() => {
  timeRipples.value = generateTimeRipples(8)
  clockParticles.value = generateClockParticles(15)
  timeLines.value = generateTimeLines(6)
})
</script>
