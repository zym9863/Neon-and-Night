import type { Database } from '~/types/database'

export const useSupabase = () => {
  const supabase = useSupabaseClient<Database>()
  const user = useSupabaseUser()

  return {
    supabase,
    user
  }
}
