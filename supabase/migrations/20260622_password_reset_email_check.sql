create or replace function public.is_email_registered(email_value text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from auth.users
    where lower(email) = lower(trim(email_value))
  );
$$;

revoke all on function public.is_email_registered(text) from public;
grant execute on function public.is_email_registered(text) to anon;
grant execute on function public.is_email_registered(text) to authenticated;

notify pgrst, 'reload schema';
