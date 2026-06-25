-- Run once in Supabase SQL Editor after reviewing existing policies.

create or replace function public.handle_new_ajrni_account()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  account_type text := coalesce(new.raw_user_meta_data ->> 'account_type', 'user');
begin
  if account_type = 'office' then
    insert into public."Offices" (
      id,
      office_name,
      email,
      phone_number,
      country,
      city,
      commercial_registration_number
    )
    values (
      new.id,
      new.raw_user_meta_data ->> 'office_name',
      new.email,
      new.raw_user_meta_data ->> 'phone_number',
      new.raw_user_meta_data ->> 'country',
      new.raw_user_meta_data ->> 'city',
      new.raw_user_meta_data ->> 'commercial_registration_number'
    )
    on conflict (id) do update set
      office_name = excluded.office_name,
      email = excluded.email,
      phone_number = excluded.phone_number,
      country = excluded.country,
      city = excluded.city,
      commercial_registration_number =
        excluded.commercial_registration_number;
  else
    insert into public."Users" (
      id,
      full_name,
      email,
      phone_number,
      country,
      city
    )
    values (
      new.id,
      new.raw_user_meta_data ->> 'full_name',
      new.email,
      new.raw_user_meta_data ->> 'phone_number',
      new.raw_user_meta_data ->> 'country',
      new.raw_user_meta_data ->> 'city'
    )
    on conflict (id) do update set
      full_name = excluded.full_name,
      email = excluded.email,
      phone_number = excluded.phone_number,
      country = excluded.country,
      city = excluded.city;
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_ajrni on auth.users;
create trigger on_auth_user_created_ajrni
after insert or update of raw_user_meta_data on auth.users
for each row execute function public.handle_new_ajrni_account();

alter table public."Users" enable row level security;
alter table public."Offices" enable row level security;
alter table public."Favorites" enable row level security;
alter table public.cars enable row level security;

drop policy if exists "users_read_own_profile" on public."Users";
create policy "users_read_own_profile"
on public."Users" for select
to authenticated
using (auth.uid() = id);

drop policy if exists "users_update_own_profile" on public."Users";
create policy "users_update_own_profile"
on public."Users" for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "users_insert_own_profile" on public."Users";
create policy "users_insert_own_profile"
on public."Users" for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "users_delete_own_profile" on public."Users";
create policy "users_delete_own_profile"
on public."Users" for delete
to authenticated
using (auth.uid() = id);

drop policy if exists "offices_read_active_or_own" on public."Offices";
create policy "offices_read_active_or_own"
on public."Offices" for select
to anon, authenticated
using (is_active = true or auth.uid() = id);

drop policy if exists "offices_update_own_profile" on public."Offices";
create policy "offices_update_own_profile"
on public."Offices" for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "offices_insert_own_profile" on public."Offices";
create policy "offices_insert_own_profile"
on public."Offices" for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "cars_read_active_or_owned" on public.cars;
create policy "cars_read_active_or_owned"
on public.cars for select
to anon, authenticated
using (is_active = true or auth.uid() = office_id);

drop policy if exists "favorites_read_own" on public."Favorites";
create policy "favorites_read_own"
on public."Favorites" for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "favorites_insert_own" on public."Favorites";
create policy "favorites_insert_own"
on public."Favorites" for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "favorites_delete_own" on public."Favorites";
create policy "favorites_delete_own"
on public."Favorites" for delete
to authenticated
using (auth.uid() = user_id);

create or replace function public.delete_current_user()
returns void
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

  delete from public."Users"
  where id = current_user_id;

  delete from auth.users
  where id = current_user_id;
end;
$$;

revoke all on function public.delete_current_user() from public;
grant execute on function public.delete_current_user() to authenticated;
