alter table public.cars enable row level security;

drop policy if exists "cars_insert_owned" on public.cars;
create policy "cars_insert_owned"
on public.cars for insert
to authenticated
with check (
  auth.uid() = owner_id
  and auth.uid() = office_id
);

drop policy if exists "cars_update_owned" on public.cars;
create policy "cars_update_owned"
on public.cars for update
to authenticated
using (auth.uid() = owner_id or auth.uid() = office_id)
with check (auth.uid() = owner_id and auth.uid() = office_id);

drop policy if exists "cars_delete_owned" on public.cars;
create policy "cars_delete_owned"
on public.cars for delete
to authenticated
using (auth.uid() = owner_id or auth.uid() = office_id);

-- The existing public `cars` Storage bucket is used by the website and app.
-- Add owner-folder policies when storage.objects RLS is enabled.
drop policy if exists "dealer_upload_own_car_images" on storage.objects;
create policy "dealer_upload_own_car_images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'cars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "dealer_update_own_car_images" on storage.objects;
create policy "dealer_update_own_car_images"
on storage.objects for update
to authenticated
using (
  bucket_id = 'cars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "dealer_delete_own_car_images" on storage.objects;
create policy "dealer_delete_own_car_images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'cars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "dealer_upload_own_office_images" on storage.objects;
create policy "dealer_upload_own_office_images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'Offices'
  and (storage.foldername(name))[1] = 'offices'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "dealer_update_own_office_images" on storage.objects;
create policy "dealer_update_own_office_images"
on storage.objects for update
to authenticated
using (
  bucket_id = 'Offices'
  and (storage.foldername(name))[1] = 'offices'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "dealer_delete_own_office_images" on storage.objects;
create policy "dealer_delete_own_office_images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'Offices'
  and (storage.foldername(name))[1] = 'offices'
  and (storage.foldername(name))[2] = auth.uid()::text
);
