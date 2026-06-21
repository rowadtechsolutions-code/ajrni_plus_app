# Supabase handoff

## Required deployment steps

1. The app defaults to the public anon key used by the official Ajrni Plus
   website. For another environment, run Flutter with:

   ```text
   --dart-define=SUPABASE_URL=https://PROJECT.supabase.co
   --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

2. Run `migrations/20260621_auth_profiles_and_rls.sql` in the Supabase SQL
   Editor. It creates user/office profiles from Auth metadata and adds the
   required RLS policies.

3. Verify the `cars` table exposes these required columns:

   - `id uuid`
   - `office_id uuid` referencing `"Offices"(id)`
   - `is_active boolean`
   - `created_at timestamptz`

   The live schema currently uses `name`, `brand`, `model`, `year`, `price`,
   `fuel_type`, `transmission`, `seats`, `color`, `image`, `images`,
   `office_id`, `status`, and `is_active`. The model also accepts compatible
   legacy aliases.

4. Public car and office images should be public Storage URLs, or signed URLs
   that remain valid while displayed.

## Implemented flows

- User and office registration through Supabase Auth.
- Profile creation in `"Users"` or `"Offices"`.
- Email-confirmation-safe profile trigger.
- Session restoration and local session cache.
- User/office routing.
- Active cars and offices.
- User favorites with optimistic updates.
- Office call and WhatsApp actions.
- Car booking WhatsApp message with car, office, price, and customer data.
