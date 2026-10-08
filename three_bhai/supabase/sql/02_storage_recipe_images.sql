-- 3Bhai  |  STEP 2 of 2  |  Storage bucket "recipe-images"
-- Supabase dashboard > SQL Editor > New query > paste this whole file > Run.
-- Images live in the bucket; only their public https links go in the database.
-- A user may only upload into a folder named after their own user id.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('recipe-images', 'recipe-images', true, 5242880,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "Public read recipe images"      on storage.objects;
drop policy if exists "Users upload own recipe images" on storage.objects;
drop policy if exists "Users update own recipe images" on storage.objects;
drop policy if exists "Users delete own recipe images" on storage.objects;

create policy "Public read recipe images" on storage.objects
  for select using (bucket_id = 'recipe-images');

create policy "Users upload own recipe images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'recipe-images'
              and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "Users update own recipe images" on storage.objects
  for update to authenticated
  using (bucket_id = 'recipe-images'
         and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "Users delete own recipe images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'recipe-images'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
