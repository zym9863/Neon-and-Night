-- 创建函数：生成随机星空位置
CREATE OR REPLACE FUNCTION public.generate_star_position()
RETURNS TABLE(x REAL, y REAL) AS $$
BEGIN
  RETURN QUERY SELECT 
    (RANDOM() * 100)::REAL as x,
    (RANDOM() * 100)::REAL as y;
END;
$$ LANGUAGE plpgsql;

-- 创建函数：根据情绪类型生成颜色
CREATE OR REPLACE FUNCTION public.get_emotion_color(emotion_type TEXT)
RETURNS TEXT AS $$
BEGIN
  CASE emotion_type
    WHEN 'pain' THEN RETURN '#ff006e';      -- 霓虹粉
    WHEN 'sadness' THEN RETURN '#3a86ff';   -- 霓虹蓝
    WHEN 'joy' THEN RETURN '#ffbe0b';       -- 霓虹黄
    WHEN 'love' THEN RETURN '#ff006e';      -- 霓虹粉
    WHEN 'hope' THEN RETURN '#06ffa5';      -- 霓虹青
    WHEN 'nostalgia' THEN RETURN '#8338ec'; -- 霓虹紫
    ELSE RETURN '#ffffff';                   -- 默认白色
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- 创建函数：匿名化记忆内容
CREATE OR REPLACE FUNCTION public.anonymize_memory_content(content TEXT, emotion_type TEXT)
RETURNS TEXT AS $$
DECLARE
  emotion_prefix TEXT;
  content_length INTEGER;
  anonymous_content TEXT;
BEGIN
  content_length := LENGTH(content);
  
  -- 根据情绪类型设置前缀
  CASE emotion_type
    WHEN 'pain' THEN emotion_prefix := '一段关于痛苦的记忆';
    WHEN 'sadness' THEN emotion_prefix := '一段关于悲伤的记忆';
    WHEN 'joy' THEN emotion_prefix := '一段关于快乐的记忆';
    WHEN 'love' THEN emotion_prefix := '一段关于爱的记忆';
    WHEN 'hope' THEN emotion_prefix := '一段关于希望的记忆';
    WHEN 'nostalgia' THEN emotion_prefix := '一段关于怀念的记忆';
    ELSE emotion_prefix := '一段情感记忆';
  END CASE;
  
  -- 根据内容长度生成匿名描述
  IF content_length < 50 THEN
    anonymous_content := emotion_prefix || '，简短而深刻';
  ELSIF content_length < 200 THEN
    anonymous_content := emotion_prefix || '，承载着复杂的情感';
  ELSE
    anonymous_content := emotion_prefix || '，充满了丰富的细节和深层的感受';
  END IF;
  
  RETURN anonymous_content;
END;
$$ LANGUAGE plpgsql;

-- 创建函数：检查时间胶囊是否可以解锁
CREATE OR REPLACE FUNCTION public.check_unlockable_capsules()
RETURNS TABLE(capsule_id UUID, user_id UUID, memory_star_id UUID) AS $$
BEGIN
  RETURN QUERY 
  SELECT tc.id, tc.user_id, tc.memory_star_id
  FROM time_capsules tc
  WHERE tc.unlock_at <= NOW() 
    AND tc.is_unlocked = FALSE;
END;
$$ LANGUAGE plpgsql;

-- 创建函数：解锁时间胶囊并发送通知
CREATE OR REPLACE FUNCTION public.unlock_time_capsule(capsule_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  capsule_record time_capsules%ROWTYPE;
  memory_title TEXT;
BEGIN
  -- 获取胶囊信息
  SELECT * INTO capsule_record FROM time_capsules WHERE id = capsule_id;
  
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- 检查是否可以解锁
  IF capsule_record.unlock_at > NOW() OR capsule_record.is_unlocked = TRUE THEN
    RETURN FALSE;
  END IF;
  
  -- 获取记忆标题
  SELECT title INTO memory_title FROM memory_stars WHERE id = capsule_record.memory_star_id;
  
  -- 解锁胶囊
  UPDATE time_capsules 
  SET is_unlocked = TRUE, unlock_message = '时间胶囊已解锁，你可以重新查看这段记忆了'
  WHERE id = capsule_id;
  
  -- 发送通知
  INSERT INTO notifications (user_id, type, title, message, related_id)
  VALUES (
    capsule_record.user_id,
    'capsule_unlocked',
    '时间胶囊已解锁',
    '你封存的记忆"' || COALESCE(memory_title, '未命名记忆') || '"现在可以查看了',
    capsule_id
  );
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建函数：获取用户的星空统计
CREATE OR REPLACE FUNCTION public.get_user_sky_stats(user_uuid UUID)
RETURNS TABLE(
  total_stars INTEGER,
  sealed_stars INTEGER,
  galaxy_emotions INTEGER,
  received_resonances INTEGER,
  sent_resonances INTEGER,
  unlocked_capsules INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*)::INTEGER FROM memory_stars WHERE user_id = user_uuid) as total_stars,
    (SELECT COUNT(*)::INTEGER FROM memory_stars WHERE user_id = user_uuid AND is_sealed = TRUE) as sealed_stars,
    (SELECT COUNT(*)::INTEGER FROM galaxy_emotions ge 
     JOIN memory_stars ms ON ge.original_memory_id = ms.id 
     WHERE ms.user_id = user_uuid) as galaxy_emotions,
    (SELECT COUNT(*)::INTEGER FROM resonances r
     JOIN galaxy_emotions ge ON r.galaxy_emotion_id = ge.id
     JOIN memory_stars ms ON ge.original_memory_id = ms.id
     WHERE ms.user_id = user_uuid) as received_resonances,
    (SELECT COUNT(*)::INTEGER FROM resonances WHERE sender_id = user_uuid) as sent_resonances,
    (SELECT COUNT(*)::INTEGER FROM time_capsules WHERE user_id = user_uuid AND is_unlocked = TRUE) as unlocked_capsules;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建函数：清理过期的银河情绪
CREATE OR REPLACE FUNCTION public.cleanup_expired_galaxy_emotions()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM galaxy_emotions 
  WHERE expires_at IS NOT NULL AND expires_at < NOW();
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建定时任务：每小时检查并解锁时间胶囊
-- 注意：这需要在 Supabase 中手动设置 cron job
-- SELECT cron.schedule('unlock-capsules', '0 * * * *', 'SELECT public.unlock_time_capsule(capsule_id) FROM public.check_unlockable_capsules();');

-- 创建定时任务：每天清理过期的银河情绪
-- SELECT cron.schedule('cleanup-expired-emotions', '0 2 * * *', 'SELECT public.cleanup_expired_galaxy_emotions();');
