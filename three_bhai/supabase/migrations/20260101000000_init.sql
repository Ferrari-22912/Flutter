-- 3Bhai  |  STEP 1 of 2  |  Per-user recipe history
-- Supabase dashboard > SQL Editor > New query > paste this whole file > Run.
-- Safe to run more than once.

create table if not exists public.search_history (
  id          uuid primary key default gen_random_uuid(),
  -- Filled automatically from the logged-in user's token. The app never sends it.
  user_id     uuid not null default auth.uid()
              references auth.users (id) on delete cascade,
  ingredients text[]      not null,
  source      text        not null,
  recipes     jsonb       not null default '[]'::jsonb,
  created_at  timestamptz not null default now(),
  constraint search_history_size_chk check (octet_length(recipes::text) < 500000),
  constraint search_history_ingredients_chk
    check (cardinality(ingredients) between 1 and 20)
);

create index if not exists search_history_user_created_idx
  on public.search_history (user_id, created_at desc);

-- Row Level Security: each user can only touch their own rows.
alter table public.search_history enable row level security;

drop policy if exists "Users read own history"   on public.search_history;
drop policy if exists "Users insert own history" on public.search_history;
drop policy if exists "Users delete own history" on public.search_history;

create policy "Users read own history" on public.search_history
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users insert own history" on public.search_history
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users delete own history" on public.search_history
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- No UPDATE policy on purpose: history rows are immutable.
-- Anonymous (not logged in) visitors get no access at all.
revoke all on public.search_history from anon;
grant select, insert, delete on public.search_history to authenticated;
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
-- 3Bhai  |  STEP 3 of 3  |  Private chat with "Chef Bhai" (one thread per user)
-- Supabase dashboard > SQL Editor > New query > paste this whole file > Run.
-- Safe to run more than once.

create table if not exists public.chat_messages (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  role       text not null check (role in ('user', 'assistant')),
  content    text not null check (char_length(content) between 1 and 4000),
  -- false when the question was outside cooking/food/3Bhai. Such turns are
  -- kept for the user to see but never fed back to the AI as context.
  on_topic   boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists chat_messages_user_created_idx
  on public.chat_messages (user_id, created_at);

alter table public.chat_messages enable row level security;

drop policy if exists "Users read own chat"   on public.chat_messages;
drop policy if exists "Users delete own chat" on public.chat_messages;

create policy "Users read own chat" on public.chat_messages
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users delete own chat" on public.chat_messages
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- There is deliberately NO insert/update policy for users. Only the
-- `chef-chat` Edge Function (service role) can write messages, so nobody can
-- forge an "assistant" reply or edit history from the app or the REST API.
revoke all on public.chat_messages from anon;
revoke insert, update on public.chat_messages from authenticated;
grant select, delete on public.chat_messages to authenticated;
