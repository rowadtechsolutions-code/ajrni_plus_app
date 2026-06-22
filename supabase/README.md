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

3. Run `migrations/20260622_password_reset_email_check.sql` in the Supabase
   SQL Editor. This is required to check whether the email exists in Auth
   before sending a password-reset message.

4. Add `https://www.ajrniplus.com/auth/update-password` to **Authentication >
   URL Configuration > Redirect URLs**. The website must handle the Supabase
   password-recovery callback on this URL and display its new-password form.
   The Flutter app sends recovery requests using the implicit auth flow so the
   website receives the access and refresh tokens in the URL fragment.

5. Verify the `cars` table exposes these required columns:

   - `id uuid`
   - `office_id uuid` referencing `"Offices"(id)`
   - `is_active boolean`
   - `created_at timestamptz`

   The live schema currently uses `name`, `brand`, `model`, `year`, `price`,
   `fuel_type`, `transmission`, `seats`, `color`, `image`, `images`,
   `office_id`, `status`, and `is_active`. The model also accepts compatible
   legacy aliases.

6. Public car and office images should be public Storage URLs, or signed URLs
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
