-- 启用 RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE memory_stars ENABLE ROW LEVEL SECURITY;
ALTER TABLE galaxy_emotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE resonances ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_capsules ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE night_sky_configs ENABLE ROW LEVEL SECURITY;

-- 用户配置表策略
CREATE POLICY "用户只能查看自己的配置" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "用户只能更新自己的配置" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "用户可以插入自己的配置" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 记忆星辰表策略
CREATE POLICY "用户只能查看自己的记忆星辰" ON memory_stars
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "用户只能创建自己的记忆星辰" ON memory_stars
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户只能更新自己的记忆星辰" ON memory_stars
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "用户只能删除自己的记忆星辰" ON memory_stars
  FOR DELETE USING (auth.uid() = user_id);

-- 银河情绪表策略（公开可读，但只有原作者可以删除）
CREATE POLICY "所有用户都可以查看银河情绪" ON galaxy_emotions
  FOR SELECT USING (true);

CREATE POLICY "只有认证用户可以创建银河情绪" ON galaxy_emotions
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "只有原记忆的作者可以删除银河情绪" ON galaxy_emotions
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM memory_stars 
      WHERE memory_stars.id = galaxy_emotions.original_memory_id 
      AND memory_stars.user_id = auth.uid()
    )
  );

-- 共鸣表策略
CREATE POLICY "用户可以查看发送给自己的共鸣" ON resonances
  FOR SELECT USING (auth.uid() = receiver_id);

CREATE POLICY "用户可以查看自己发送的共鸣" ON resonances
  FOR SELECT USING (auth.uid() = sender_id);

CREATE POLICY "认证用户可以发送共鸣" ON resonances
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 时间胶囊表策略
CREATE POLICY "用户只能查看自己的时间胶囊" ON time_capsules
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "用户只能创建自己的时间胶囊" ON time_capsules
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户只能更新自己的时间胶囊" ON time_capsules
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "用户只能删除自己的时间胶囊" ON time_capsules
  FOR DELETE USING (auth.uid() = user_id);

-- 通知表策略
CREATE POLICY "用户只能查看自己的通知" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "系统可以创建通知" ON notifications
  FOR INSERT WITH CHECK (true);

CREATE POLICY "用户只能更新自己的通知" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "用户只能删除自己的通知" ON notifications
  FOR DELETE USING (auth.uid() = user_id);

-- 夜空配置表策略
CREATE POLICY "用户只能查看自己的夜空配置" ON night_sky_configs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "用户只能更新自己的夜空配置" ON night_sky_configs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "用户可以插入自己的夜空配置" ON night_sky_configs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 创建函数：自动创建用户配置
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username)
  VALUES (NEW.id, NEW.email);
  
  INSERT INTO public.night_sky_configs (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器：用户注册时自动创建配置
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 创建函数：更新银河情绪的共鸣计数
CREATE OR REPLACE FUNCTION public.update_resonance_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE galaxy_emotions 
    SET resonance_count = resonance_count + 1 
    WHERE id = NEW.galaxy_emotion_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE galaxy_emotions 
    SET resonance_count = resonance_count - 1 
    WHERE id = OLD.galaxy_emotion_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器：共鸣变化时更新计数
CREATE TRIGGER on_resonance_change
  AFTER INSERT OR DELETE ON resonances
  FOR EACH ROW EXECUTE FUNCTION public.update_resonance_count();

-- 创建函数：发送共鸣通知
CREATE OR REPLACE FUNCTION public.send_resonance_notification()
RETURNS TRIGGER AS $$
DECLARE
  receiver_user_id UUID;
BEGIN
  -- 获取接收者的用户ID
  SELECT ms.user_id INTO receiver_user_id
  FROM galaxy_emotions ge
  JOIN memory_stars ms ON ge.original_memory_id = ms.id
  WHERE ge.id = NEW.galaxy_emotion_id;
  
  -- 创建通知
  INSERT INTO notifications (user_id, type, title, message, related_id)
  VALUES (
    receiver_user_id,
    'resonance_received',
    '你的星辰收到了共鸣',
    '有人向你的情绪光点发送了温柔的光脉冲',
    NEW.id
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器：发送共鸣时创建通知
CREATE TRIGGER on_resonance_sent
  AFTER INSERT ON resonances
  FOR EACH ROW EXECUTE FUNCTION public.send_resonance_notification();
