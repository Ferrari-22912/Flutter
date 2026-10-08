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
