[English](/README_EN.md) | [中文](/README.md)

# Neon Night Sky (霓虹夜空) 🌌

A private space for emotional journaling and resonance - record your feelings as stars and find resonance in the galaxy.

## ✨ Project Overview

Neon Night Sky is a unique platform for recording and sharing emotions. Users can:
- 📝 Record emotions as stars in the night sky
- 🌟 Express emotional intensity through different colors and brightness
- 🌌 Find emotional resonance in an anonymized galaxy
- 🔐 Seal private memories and set unlock times
- 💫 Connect and resonate with others' emotions

## 🚀 Tech Stack

### Frontend
- **Nuxt 3** - Full-stack framework based on Vue 3
- **Vue 3** - Modern frontend framework
- **TypeScript** - Type-safe JavaScript superset
- **Tailwind CSS** - Utility-first CSS framework

### Backend
- **Supabase** - Open-source Firebase alternative
- **PostgreSQL** - Relational database
- **Row Level Security (RLS)** - Row-level data security

### Animation & Interaction
- **Three.js** - 3D graphics library for starry backgrounds
- **GSAP** - High-performance animation library
- **Headless UI** - Unstyled UI component library

### State Management
- **Pinia** - State management for Vue 3
- **VueUse** - Vue composition API utilities

## 🏗️ Project Structure

```
Neon-and-Night/
├── app.vue                 # Root component
├── nuxt.config.ts          # Nuxt config
├── package.json            # Dependencies & scripts
├── tailwind.config.js      # Tailwind CSS config
├── assets/
│   └── css/
│       └── main.css        # Global styles
├── components/             # Vue components
│   ├── AppNavbar.vue       # Navbar
│   ├── GalaxyBackground.vue # Galaxy background
│   ├── MemoryStar.vue      # Memory star
│   ├── TimeSpaceBackground.vue # Time-space background
│   └── ...
├── composables/            # Vue composables
│   └── useSupabase.ts      # Supabase client
├── layouts/
│   └── default.vue         # Default layout
├── middleware/
│   └── auth.ts             # Auth middleware
├── pages/                  # Page routes
│   ├── index.vue           # Home
│   ├── capsules.vue        # Time capsules
│   ├── galaxy.vue          # Galaxy emotions
│   ├── sky.vue             # Personal sky
│   └── auth/               # Auth pages
├── stores/                 # Pinia stores
│   ├── auth.ts             # Auth state
│   └── notification.ts     # Notification state
├── supabase/               # Supabase config
│   └── migrations/         # DB migrations
└── types/                  # TypeScript types
    ├── database.ts         # DB types
    └── index.ts            # Common types
```

## 🎨 Core Features

### 1. Emotional Journaling (Memory Stars)
- Create text, image, or audio emotion records
- Choose emotion type: pain, joy, nostalgia, hope, sadness, love
- Set star brightness (intensity) and color
- Freely place stars in your personal sky

### 2. Galaxy Resonance
- Memories are anonymized and enter the galaxy
- Others can resonate with emotions
- View emotion details and resonance stats
- Discover similar emotional experiences

### 3. Time Capsule
- Seal private memories, set future unlock time
- Create messages for your future self
- Automatic unlock reminders when capsule expires

### 4. Personal Sky
- Visualize all personal memories
- View memory evolution as a timeline
- Star twinkle effect shows activity

## 🛠️ Development Setup

### Requirements
- Node.js >= 18.0.0
- pnpm >= 8.0.0
- Supabase account & project

### 1. Clone the project
```bash
git clone https://github.com/zym9863/neon-and-night.git
cd Neon-and-Night
```

### 2. Install dependencies
```bash
pnpm install
```

### 3. Environment variables
Create a `.env` file and set:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 4. Database setup
Run migrations:
```bash
# Execute SQL files in supabase/migrations/ via Supabase SQL editor
```

### 5. Start dev server
```bash
pnpm dev
```

App runs at `http://localhost:3000`.

## 📦 Build & Deploy

### Build for development
```bash
pnpm build
```

### Generate static site
```bash
pnpm generate
```

### Preview build
```bash
pnpm preview
```

## 🎯 Page Routes

- `/` - Home
- `/auth/login` - Login
- `/auth/register` - Register
- `/auth/callback` - Auth callback
- `/sky` - Personal sky (auth required)
- `/galaxy` - Galaxy emotions (auth required)
- `/capsules` - Time capsules (auth required)

## 🔒 Security Features

- **Row Level Security (RLS)** - Users can only access their own data
- **Anonymization** - Galaxy emotions are anonymized
- **Auth middleware** - Protects authenticated pages
- **Data validation** - Double validation on frontend & backend

## 🌟 Highlights

1. **Immersive starry experience** - Real 3D starry sky with Three.js
2. **Emotion visualization** - Express emotions via color, brightness, position
3. **Anonymous social** - Find resonance while protecting privacy
4. **Time capsule** - Emotional records across time
5. **Responsive design** - Works on all devices

## 🤝 Contributing

1. Fork this repo
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Create a Pull Request

## 📝 License

MIT License. See `LICENSE` for details.

## 🐛 Issues

Found a bug or have a suggestion? Submit via [Issues](https://github.com/zym9863/neon-and-night/issues).

---

**Neon Night Sky** - Let every emotion become the brightest star in the night sky ⭐️
