-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建用户配置表
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建记忆星辰表
CREATE TABLE memory_stars (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  content_type TEXT CHECK (content_type IN ('text', 'image', 'audio')) NOT NULL,
  media_url TEXT,
  emotion_type TEXT CHECK (emotion_type IN ('pain', 'joy', 'nostalgia', 'hope', 'sadness', 'love')) NOT NULL,
  brightness INTEGER CHECK (brightness >= 0 AND brightness <= 100) DEFAULT 50,
  position_x REAL NOT NULL,
  position_y REAL NOT NULL,
  color TEXT NOT NULL DEFAULT '#ffffff',
  is_sealed BOOLEAN DEFAULT FALSE,
  seal_until TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建银河情绪表（匿名化的记忆）
CREATE TABLE galaxy_emotions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  original_memory_id UUID REFERENCES memory_stars(id) ON DELETE CASCADE NOT NULL,
  emotion_type TEXT CHECK (emotion_type IN ('pain', 'joy', 'nostalgia', 'hope', 'sadness', 'love')) NOT NULL,
  anonymous_content TEXT NOT NULL, -- 匿名化处理后的内容摘要
  color TEXT NOT NULL,
  intensity INTEGER CHECK (intensity >= 1 AND intensity <= 10) DEFAULT 5,
  position_x REAL NOT NULL,
  position_y REAL NOT NULL,
  resonance_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE -- 可选的过期时间
);

-- 创建共鸣表
CREATE TABLE resonances (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  galaxy_emotion_id UUID REFERENCES galaxy_emotions(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- 可为空保持匿名
  receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  resonance_type TEXT DEFAULT 'pulse',
  message TEXT, -- 可选的简短消息
  is_anonymous BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建时间胶囊表
CREATE TABLE time_capsules (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  memory_star_id UUID REFERENCES memory_stars(id) ON DELETE CASCADE NOT NULL,
  sealed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unlock_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_unlocked BOOLEAN DEFAULT FALSE,
  unlock_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建通知表
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT CHECK (type IN ('resonance_received', 'capsule_unlocked', 'memory_reminder')) NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  related_id UUID, -- 相关的记忆或共鸣ID
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建夜空配置表
CREATE TABLE night_sky_configs (
  user_id UUID REFERENCES auth.users(id) PRIMARY KEY,
  background_theme TEXT DEFAULT 'classic' CHECK (background_theme IN ('classic', 'aurora', 'nebula', 'cosmic')),
  star_density INTEGER DEFAULT 50 CHECK (star_density >= 0 AND star_density <= 100),
  animation_speed INTEGER DEFAULT 50 CHECK (animation_speed >= 0 AND animation_speed <= 100),
  show_constellation_lines BOOLEAN DEFAULT FALSE,
  music_enabled BOOLEAN DEFAULT TRUE,
  ambient_sounds BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引以提高查询性能
CREATE INDEX idx_memory_stars_user_id ON memory_stars(user_id);
CREATE INDEX idx_memory_stars_created_at ON memory_stars(created_at DESC);
CREATE INDEX idx_memory_stars_emotion_type ON memory_stars(emotion_type);
CREATE INDEX idx_galaxy_emotions_created_at ON galaxy_emotions(created_at DESC);
CREATE INDEX idx_galaxy_emotions_emotion_type ON galaxy_emotions(emotion_type);
CREATE INDEX idx_resonances_receiver_id ON resonances(receiver_id);
CREATE INDEX idx_resonances_created_at ON resonances(created_at DESC);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_time_capsules_user_id ON time_capsules(user_id);
CREATE INDEX idx_time_capsules_unlock_at ON time_capsules(unlock_at);

-- 创建更新时间戳的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间戳触发器
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_memory_stars_updated_at BEFORE UPDATE ON memory_stars FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_night_sky_configs_updated_at BEFORE UPDATE ON night_sky_configs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
