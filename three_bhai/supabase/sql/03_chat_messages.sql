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
