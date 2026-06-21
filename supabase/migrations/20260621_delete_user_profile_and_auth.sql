create or replace function public.delete_user_account()
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;

  -- Both deletes run in the same transaction. If Auth deletion fails, the
  -- profile deletion is rolled back automatically.
  delete from public."Users"
  where id = current_user_id;

  delete from auth.users
  where id = current_user_id;

  if not found then
    raise exception 'Authenticated user was not found';
  end if;

  return true;
end;
$$;

revoke all on function public.delete_user_account() from public;
grant execute on function public.delete_user_account() to authenticated;

-- Keep the previous function name as a compatibility wrapper.
create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  perform public.delete_user_account();
end;
$$;

revoke all on function public.delete_current_user() from public;
grant execute on function public.delete_current_user() to authenticated;

notify pgrst, 'reload schema';
