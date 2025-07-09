<template>
  <div class="fixed inset-0 overflow-hidden pointer-events-none">
    <!-- 渐变背景 -->
    <div class="absolute inset-0 bg-gradient-to-b from-space-900 via-space-800 to-space-700"></div>
    
    <!-- 星空画布 -->
    <canvas
      ref="canvasRef"
      class="absolute inset-0 w-full h-full"
      :width="canvasWidth"
      :height="canvasHeight"
    ></canvas>
    
    <!-- 流星效果 -->
    <div class="absolute inset-0">
      <div
        v-for="meteor in meteors"
        :key="meteor.id"
        class="absolute w-1 h-1 bg-white rounded-full opacity-80"
        :style="{
          left: `${meteor.x}%`,
          top: `${meteor.y}%`,
          transform: `rotate(${meteor.angle}deg)`,
          boxShadow: `0 0 6px 2px rgba(255, 255, 255, 0.6), 0 0 12px 4px rgba(255, 255, 255, 0.3)`
        }"
      >
        <div class="absolute w-20 h-0.5 bg-gradient-to-r from-white to-transparent -translate-y-0.5"></div>
      </div>
    </div>
    
    <!-- 极光效果 -->
    <div class="absolute inset-0 opacity-30">
      <div class="aurora aurora-1"></div>
      <div class="aurora aurora-2"></div>
      <div class="aurora aurora-3"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Star {
  x: number
  y: number
  size: number
  brightness: number
  twinkleSpeed: number
  color: string
}

interface Meteor {
  id: number
  x: number
  y: number
  angle: number
  speed: number
}

const canvasRef = ref<HTMLCanvasElement>()
const canvasWidth = ref(0)
const canvasHeight = ref(0)
const stars = ref<Star[]>([])
const meteors = ref<Meteor[]>([])
const animationId = ref<number>()

// 生成随机星星
const generateStars = (count: number) => {
  const newStars: Star[] = []
  const colors = ['#ffffff', '#ffeaa7', '#74b9ff', '#fd79a8', '#fdcb6e', '#e17055']
  
  for (let i = 0; i < count; i++) {
    newStars.push({
      x: Math.random() * canvasWidth.value,
      y: Math.random() * canvasHeight.value,
      size: Math.random() * 2 + 0.5,
      brightness: Math.random() * 0.8 + 0.2,
      twinkleSpeed: Math.random() * 0.02 + 0.01,
      color: colors[Math.floor(Math.random() * colors.length)]
    })
  }
  
  return newStars
}

// 生成流星
const generateMeteor = (): Meteor => {
  return {
    id: Date.now() + Math.random(),
    x: Math.random() * 120 - 20, // 从屏幕外开始
    y: Math.random() * 50,
    angle: Math.random() * 30 + 15, // 15-45度角
    speed: Math.random() * 2 + 1
  }
}

// 绘制星星
const drawStars = (ctx: CanvasRenderingContext2D, time: number) => {
  stars.value.forEach(star => {
    const twinkle = Math.sin(time * star.twinkleSpeed) * 0.3 + 0.7
    const alpha = star.brightness * twinkle
    
    ctx.save()
    ctx.globalAlpha = alpha
    ctx.fillStyle = star.color
    ctx.shadowBlur = star.size * 2
    ctx.shadowColor = star.color
    
    ctx.beginPath()
    ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2)
    ctx.fill()
    
    // 绘制十字光芒
    if (star.size > 1) {
      ctx.strokeStyle = star.color
      ctx.lineWidth = 0.5
      ctx.globalAlpha = alpha * 0.6
      
      const length = star.size * 3
      ctx.beginPath()
      ctx.moveTo(star.x - length, star.y)
      ctx.lineTo(star.x + length, star.y)
      ctx.moveTo(star.x, star.y - length)
      ctx.lineTo(star.x, star.y + length)
      ctx.stroke()
    }
    
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

// 更新流星位置
const updateMeteors = () => {
  meteors.value = meteors.value.filter(meteor => {
    meteor.x += meteor.speed
    meteor.y += meteor.speed * 0.5
    return meteor.x < 120 && meteor.y < 100
  })
  
  // 随机生成新流星
  if (Math.random() < 0.003) { // 0.3% 概率
    meteors.value.push(generateMeteor())
  }
}

// 调整画布大小
const resizeCanvas = () => {
  canvasWidth.value = window.innerWidth
  canvasHeight.value = window.innerHeight
  
  // 重新生成星星
  stars.value = generateStars(Math.floor((canvasWidth.value * canvasHeight.value) / 8000))
}

// 流星更新定时器
const meteorTimer = setInterval(updateMeteors, 50)

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
  clearInterval(meteorTimer)
  window.removeEventListener('resize', resizeCanvas)
})
</script>

<style scoped>
.aurora {
  position: absolute;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(0, 255, 150, 0.1), transparent);
  animation: aurora-move 20s ease-in-out infinite;
}

.aurora-1 {
  background: linear-gradient(90deg, transparent, rgba(255, 0, 150, 0.08), transparent);
  animation-delay: 0s;
  animation-duration: 25s;
}

.aurora-2 {
  background: linear-gradient(90deg, transparent, rgba(0, 150, 255, 0.06), transparent);
  animation-delay: -8s;
  animation-duration: 30s;
}

.aurora-3 {
  background: linear-gradient(90deg, transparent, rgba(150, 255, 0, 0.04), transparent);
  animation-delay: -16s;
  animation-duration: 35s;
}

@keyframes aurora-move {
  0%, 100% {
    transform: translateX(-100%) skewX(-15deg);
    opacity: 0;
  }
  50% {
    transform: translateX(100%) skewX(15deg);
    opacity: 1;
  }
}
</style>
