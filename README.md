[English](/README_EN.md) | [中文](/README.md)

# 霓虹夜空 (Neon Night Sky) 🌌

一个私密的情感记录与共鸣空间 - 将你的情感记录为星辰，在银河中寻找共鸣。

## ✨ 项目概述

霓虹夜空是一个独特的情感记录与分享平台，用户可以：
- 📝 将情感记录为夜空中的星辰
- 🌟 通过不同的颜色和亮度表达情感强度
- 🌌 在匿名化的银河中寻找情感共鸣
- 🔐 密封私密记忆，设置解封时间
- 💫 与他人的情感产生共鸣和连接

## 🚀 技术栈

### 前端框架
- **Nuxt 3** - 基于 Vue 3 的全栈框架
- **Vue 3** - 现代化的前端框架
- **TypeScript** - 类型安全的 JavaScript 超集
- **Tailwind CSS** - 实用优先的 CSS 框架

### 后端服务
- **Supabase** - 开源的 Firebase 替代方案
- **PostgreSQL** - 关系型数据库
- **Row Level Security (RLS)** - 数据行级安全控制

### 动画与交互
- **Three.js** - 3D 图形库，用于渲染星空背景
- **GSAP** - 高性能动画库
- **Headless UI** - 无样式 UI 组件库

### 状态管理
- **Pinia** - Vue 3 的状态管理库
- **VueUse** - Vue 组合式 API 工具集

## 🏗️ 项目结构

```
Neon-and-Night/
├── app.vue                 # 应用根组件
├── nuxt.config.ts          # Nuxt 配置文件
├── package.json            # 项目依赖和脚本
├── tailwind.config.js      # Tailwind CSS 配置
├── assets/
│   └── css/
│       └── main.css        # 全局样式
├── components/             # Vue 组件
│   ├── AppNavbar.vue       # 导航栏
│   ├── GalaxyBackground.vue # 银河背景
│   ├── MemoryStar.vue      # 记忆星辰
│   ├── TimeSpaceBackground.vue # 时空背景
│   └── ...
├── composables/            # Vue 组合式函数
│   └── useSupabase.ts      # Supabase 客户端
├── layouts/
│   └── default.vue         # 默认布局
├── middleware/
│   └── auth.ts             # 认证中间件
├── pages/                  # 页面路由
│   ├── index.vue           # 首页
│   ├── capsules.vue        # 时间胶囊
│   ├── galaxy.vue          # 银河情感
│   ├── sky.vue             # 个人星空
│   └── auth/               # 认证页面
├── stores/                 # Pinia 状态管理
│   ├── auth.ts             # 认证状态
│   └── notification.ts     # 通知状态
├── supabase/               # Supabase 配置
│   └── migrations/         # 数据库迁移
└── types/                  # TypeScript 类型定义
    ├── database.ts         # 数据库类型
    └── index.ts            # 通用类型
```

## 🎨 核心功能

### 1. 情感记录（记忆星辰）
- 创建文本、图片、音频形式的情感记录
- 选择情感类型：痛苦、快乐、怀念、希望、悲伤、爱情
- 设置星辰亮度（情感强度）和颜色
- 在个人星空中自由摆放位置

### 2. 银河情感共鸣
- 记忆匿名化处理后进入银河空间
- 其他用户可以与情感产生共鸣
- 查看情感详情和共鸣统计
- 发现相似情感体验

### 3. 时间胶囊功能
- 密封私密记忆，设置未来解封时间
- 创建给未来自己的消息
- 胶囊到期自动解封提醒

### 4. 个人星空
- 可视化展示所有个人记忆
- 时间线形式查看记忆演变
- 星辰闪烁效果展示活跃度

## 🛠️ 开发环境设置

### 环境要求
- Node.js >= 18.0.0
- pnpm >= 8.0.0
- Supabase 账户和项目

### 1. 克隆项目
```bash
git clone https://github.com/zym9863/neon-and-night.git
cd Neon-and-Night
```

### 2. 安装依赖
```bash
pnpm install
```

### 3. 环境变量配置
创建 `.env` 文件并配置以下变量：
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 4. 数据库设置
运行数据库迁移：
```bash
# 在 Supabase 控制台的 SQL 编辑器中执行
# supabase/migrations/ 目录下的 SQL 文件
```

### 5. 启动开发服务器
```bash
pnpm dev
```

应用将在 `http://localhost:3000` 启动。

## 📦 构建与部署

### 开发构建
```bash
pnpm build
```

### 生成静态站点
```bash
pnpm generate
```

### 预览构建结果
```bash
pnpm preview
```

## 🎯 页面路由

- `/` - 首页
- `/auth/login` - 登录页面
- `/auth/register` - 注册页面
- `/auth/callback` - 认证回调
- `/sky` - 个人星空（需要认证）
- `/galaxy` - 银河情感（需要认证）
- `/capsules` - 时间胶囊（需要认证）

## 🔒 安全特性

- **行级安全策略 (RLS)** - 确保用户只能访问自己的数据
- **匿名化处理** - 银河情感中的内容经过匿名化处理
- **认证中间件** - 保护需要登录的页面
- **数据验证** - 前后端双重数据验证

## 🌟 特色亮点

1. **沉浸式星空体验** - 使用 Three.js 创建真实的 3D 星空背景
2. **情感可视化** - 通过颜色、亮度、位置表达情感状态
3. **匿名社交** - 在保护隐私的同时寻找情感共鸣
4. **时间胶囊** - 跨越时间维度的情感记录
5. **响应式设计** - 适配各种设备和屏幕尺寸

## 🤝 贡献指南

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📝 许可证

本项目采用 MIT 许可证。详情请查看 `LICENSE` 文件。

## 🐛 问题反馈

如果您发现任何问题或有功能建议，请在 [Issues](https://github.com/zym9863/neon-and-night/issues) 中提交。

---

**霓虹夜空** - 让每一个情感都成为夜空中最亮的星 ⭐️
