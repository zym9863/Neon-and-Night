export interface Database {
  public: {
    Tables: {
      user_profiles: {
        Row: {
          id: string
          username: string | null
          avatar_url: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          username?: string | null
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          username?: string | null
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      memory_stars: {
        Row: {
          id: string
          user_id: string
          title: string
          content: string
          content_type: 'text' | 'image' | 'audio'
          media_url: string | null
          emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          brightness: number
          position_x: number
          position_y: number
          color: string
          is_sealed: boolean
          seal_until: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          content: string
          content_type: 'text' | 'image' | 'audio'
          media_url?: string | null
          emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          brightness?: number
          position_x: number
          position_y: number
          color?: string
          is_sealed?: boolean
          seal_until?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          content?: string
          content_type?: 'text' | 'image' | 'audio'
          media_url?: string | null
          emotion_type?: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          brightness?: number
          position_x?: number
          position_y?: number
          color?: string
          is_sealed?: boolean
          seal_until?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      galaxy_emotions: {
        Row: {
          id: string
          original_memory_id: string
          emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          anonymous_content: string
          color: string
          intensity: number
          position_x: number
          position_y: number
          resonance_count: number
          created_at: string
          expires_at: string | null
        }
        Insert: {
          id?: string
          original_memory_id: string
          emotion_type: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          anonymous_content: string
          color: string
          intensity?: number
          position_x: number
          position_y: number
          resonance_count?: number
          created_at?: string
          expires_at?: string | null
        }
        Update: {
          id?: string
          original_memory_id?: string
          emotion_type?: 'pain' | 'joy' | 'nostalgia' | 'hope' | 'sadness' | 'love'
          anonymous_content?: string
          color?: string
          intensity?: number
          position_x?: number
          position_y?: number
          resonance_count?: number
          created_at?: string
          expires_at?: string | null
        }
      }
      resonances: {
        Row: {
          id: string
          galaxy_emotion_id: string
          sender_id: string | null
          receiver_id: string
          resonance_type: string
          message: string | null
          is_anonymous: boolean
          created_at: string
        }
        Insert: {
          id?: string
          galaxy_emotion_id: string
          sender_id?: string | null
          receiver_id: string
          resonance_type?: string
          message?: string | null
          is_anonymous?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          galaxy_emotion_id?: string
          sender_id?: string | null
          receiver_id?: string
          resonance_type?: string
          message?: string | null
          is_anonymous?: boolean
          created_at?: string
        }
      }
      time_capsules: {
        Row: {
          id: string
          user_id: string
          memory_star_id: string
          sealed_at: string
          unlock_at: string
          is_unlocked: boolean
          unlock_message: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          memory_star_id: string
          sealed_at?: string
          unlock_at: string
          is_unlocked?: boolean
          unlock_message?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          memory_star_id?: string
          sealed_at?: string
          unlock_at?: string
          is_unlocked?: boolean
          unlock_message?: string | null
          created_at?: string
        }
      }
      notifications: {
        Row: {
          id: string
          user_id: string
          type: 'resonance_received' | 'capsule_unlocked' | 'memory_reminder'
          title: string
          message: string
          is_read: boolean
          related_id: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          type: 'resonance_received' | 'capsule_unlocked' | 'memory_reminder'
          title: string
          message: string
          is_read?: boolean
          related_id?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          type?: 'resonance_received' | 'capsule_unlocked' | 'memory_reminder'
          title?: string
          message?: string
          is_read?: boolean
          related_id?: string | null
          created_at?: string
        }
      }
      night_sky_configs: {
        Row: {
          user_id: string
          background_theme: 'classic' | 'aurora' | 'nebula' | 'cosmic'
          star_density: number
          animation_speed: number
          show_constellation_lines: boolean
          music_enabled: boolean
          ambient_sounds: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          user_id: string
          background_theme?: 'classic' | 'aurora' | 'nebula' | 'cosmic'
          star_density?: number
          animation_speed?: number
          show_constellation_lines?: boolean
          music_enabled?: boolean
          ambient_sounds?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          user_id?: string
          background_theme?: 'classic' | 'aurora' | 'nebula' | 'cosmic'
          star_density?: number
          animation_speed?: number
          show_constellation_lines?: boolean
          music_enabled?: boolean
          ambient_sounds?: boolean
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      generate_star_position: {
        Args: Record<PropertyKey, never>
        Returns: {
          x: number
          y: number
        }[]
      }
      get_emotion_color: {
        Args: {
          emotion_type: string
        }
        Returns: string
      }
      anonymize_memory_content: {
        Args: {
          content: string
          emotion_type: string
        }
        Returns: string
      }
      check_unlockable_capsules: {
        Args: Record<PropertyKey, never>
        Returns: {
          capsule_id: string
          user_id: string
          memory_star_id: string
        }[]
      }
      unlock_time_capsule: {
        Args: {
          capsule_id: string
        }
        Returns: boolean
      }
      get_user_sky_stats: {
        Args: {
          user_uuid: string
        }
        Returns: {
          total_stars: number
          sealed_stars: number
          galaxy_emotions: number
          received_resonances: number
          sent_resonances: number
          unlocked_capsules: number
        }[]
      }
      cleanup_expired_galaxy_emotions: {
        Args: Record<PropertyKey, never>
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
  }
}
