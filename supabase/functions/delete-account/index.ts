import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const jwt = authHeader.slice(7)

  // Create service-role client WITHOUT overriding Authorization in global headers.
  // This ensures supabase.auth.admin.* methods use the service_role key, not the user JWT.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Verify the caller by passing the JWT explicitly.
  const { data: { user }, error: userError } = await supabase.auth.getUser(jwt)

  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const userId = user.id

  // 1. Delete from Favorites
  const { error: favError } = await supabase.from('Favorites').delete().eq('user_id', userId)
  if (favError) {
    return new Response(JSON.stringify({ error: `Failed to delete favorites: ${favError.message}` }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // 2. Delete from Users
  const { error: userDeleteError } = await supabase.from('Users').delete().eq('id', userId)
  if (userDeleteError) {
    return new Response(JSON.stringify({ error: `Failed to delete user profile: ${userDeleteError.message}` }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // 3. Delete from auth.users using Admin API (requires service_role key)
  const { error: authDeleteError } = await supabase.auth.admin.deleteUser(userId)
  if (authDeleteError) {
    return new Response(JSON.stringify({ error: `Failed to delete auth user: ${authDeleteError.message}` }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
})
