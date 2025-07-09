<template>
  <div class="fixed inset-0 overflow-hidden pointer-events-none">
    <!-- 深空渐变背景 -->
    <div class="absolute inset-0 bg-gradient-to-br from-purple-900/20 via-space-900 to-blue-900/20"></div>
    
    <!-- 星云效果 -->
    <div class="absolute inset-0 opacity-30">
      <div class="nebula nebula-1"></div>
      <div class="nebula nebula-2"></div>
      <div class="nebula nebula-3"></div>
    </div>
    
    <!-- 银河系旋臂 -->
    <div class="absolute inset-0 opacity-20">
      <div class="galaxy-arm arm-1"></div>
      <div class="galaxy-arm arm-2"></div>
      <div class="galaxy-arm arm-3"></div>
    </div>
    
    <!-- 远景星星 -->
    <canvas
      ref="canvasRef"
      class="absolute inset-0 w-full h-full opacity-60"
      :width="canvasWidth"
      :height="canvasHeight"
    ></canvas>
    
    <!-- 漂浮粒子 -->
    <div class="absolute inset-0">
      <div
        v-for="particle in particles"
        :key="particle.id"
        class="absolute w-1 h-1 bg-white rounded-full opacity-40"
        :style="{
          left: `${particle.x}%`,
          top: `${particle.y}%`,
          animationDelay: `${particle.delay}s`,
          animationDuration: `${particle.duration}s`
        }"
        :class="particle.animation"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface BackgroundStar {
  x: number
  y: number
  size: number
  brightness: number
  twinkleSpeed: number
  color: string
}

interface Particle {
  id: number
  x: number
  y: number
  delay: number
  duration: number
  animation: string
}

const canvasRef = ref<HTMLCanvasElement>()
const canvasWidth = ref(0)
const canvasHeight = ref(0)
const stars = ref<BackgroundStar[]>([])
const particles = ref<Particle[]>([])
const animationId = ref<number>()

// 生成背景星星
const generateStars = (count: number) => {
  const newStars: BackgroundStar[] = []
  const colors = ['#ffffff', '#e6f3ff', '#fff0e6', '#f0e6ff', '#e6fff0']
  
  for (let i = 0; i < count; i++) {
    newStars.push({
      x: Math.random() * canvasWidth.value,
      y: Math.random() * canvasHeight.value,
      size: Math.random() * 1.5 + 0.3,
      brightness: Math.random() * 0.6 + 0.2,
      twinkleSpeed: Math.random() * 0.015 + 0.005,
      color: colors[Math.floor(Math.random() * colors.length)]
    })
  }
  
  return newStars
}

// 生成漂浮粒子
const generateParticles = (count: number) => {
  const newParticles: Particle[] = []
  const animations = ['animate-float', 'animate-pulse-slow', 'animate-bounce-slow']
  
  for (let i = 0; i < count; i++) {
    newParticles.push({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      delay: Math.random() * 5,
      duration: Math.random() * 10 + 5,
      animation: animations[Math.floor(Math.random() * animations.length)]
    })
  }
  
  return newParticles
}

// 绘制星星
const drawStars = (ctx: CanvasRenderingContext2D, time: number) => {
  stars.value.forEach(star => {
    const twinkle = Math.sin(time * star.twinkleSpeed) * 0.4 + 0.6
    const alpha = star.brightness * twinkle
    
    ctx.save()
    ctx.globalAlpha = alpha
    ctx.fillStyle = star.color
    ctx.shadowBlur = star.size * 1.5
    ctx.shadowColor = star.color
    
    ctx.beginPath()
    ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2)
    ctx.fill()
    
    ctx.restore()
  })
}

// 动画循环
const animate = (time: number) => {
  const canvas = canvasRef.value
  if (!canvas) return
  
  const ctx = canvas.getContext('2d')
  if (!ctx) return
  
  // 清空画布
  ctx.clearRect(0, 0, canvasWidth.value, canvasHeight.value)
  
  // 绘制星星
  drawStars(ctx, time)
  
  animationId.value = requestAnimationFrame(animate)
}

// 调整画布大小
const resizeCanvas = () => {
  canvasWidth.value = window.innerWidth
  canvasHeight.value = window.innerHeight
  
  // 重新生成星星和粒子
  stars.value = generateStars(Math.floor((canvasWidth.value * canvasHeight.value) / 12000))
  particles.value = generateParticles(20)
}

onMounted(() => {
  resizeCanvas()
  
  // 开始动画
  animationId.value = requestAnimationFrame(animate)
  
  // 监听窗口大小变化
  window.addEventListener('resize', resizeCanvas)
})

onUnmounted(() => {
  if (animationId.value) {
    cancelAnimationFrame(animationId.value)
  }
  window.removeEventListener('resize', resizeCanvas)
})
</script>

<style scoped>
.nebula {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  filter: blur(100px);
  animation: nebula-drift 30s ease-in-out infinite;
}

.nebula-1 {
  background: radial-gradient(circle, rgba(138, 43, 226, 0.3) 0%, transparent 70%);
  top: 10%;
  left: 20%;
  width: 40%;
  height: 40%;
  animation-delay: 0s;
}

.nebula-2 {
  background: radial-gradient(circle, rgba(75, 0, 130, 0.2) 0%, transparent 70%);
  top: 50%;
  right: 10%;
  width: 50%;
  height: 50%;
  animation-delay: -10s;
}

.nebula-3 {
  background: radial-gradient(circle, rgba(25, 25, 112, 0.15) 0%, transparent 70%);
  bottom: 20%;
  left: 10%;
  width: 60%;
  height: 60%;
  animation-delay: -20s;
}

.galaxy-arm {
  position: absolute;
  width: 200%;
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transform-origin: left center;
  animation: galaxy-rotation 60s linear infinite;
}

.arm-1 {
  top: 30%;
  left: 50%;
  transform: rotate(0deg);
  animation-delay: 0s;
}

.arm-2 {
  top: 50%;
  left: 50%;
  transform: rotate(120deg);
  animation-delay: -20s;
}

.arm-3 {
  top: 70%;
  left: 50%;
  transform: rotate(240deg);
  animation-delay: -40s;
}

@keyframes nebula-drift {
  0%, 100% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(20px, -30px) scale(1.1);
  }
  66% {
    transform: translate(-15px, 20px) scale(0.9);
  }
}

@keyframes galaxy-rotation {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
