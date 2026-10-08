# 3Bhai

Three brothers. One kitchen. Zero food waste.
Flutter (Android + iOS), Clean Architecture, Supabase backend.

> Full step-by-step guide (USB debugging, APK, iOS): see **HOW_TO_RUN.md**.
> Supabase + Gemini setup and a map of every file: see **SETUP_SUPABASE_GEMINI.md**.
> Database scripts to paste into Supabase: see **supabase/sql/**.

## Quick start (demo mode, no accounts needed)

Requires Flutter 3.27 or newer.

```bash
flutter pub get
flutter test
flutter run
```

Without Supabase keys the app runs in demo mode: any valid email + password
works, recipes come from the free TheMealDB API, and history is kept on the
phone separately for each email.

## Go live: one key, works for everyone, private history per user

### 1. Create a Supabase project, then run the database script once
In the Supabase dashboard open SQL Editor and run, in order,
`supabase/sql/01_search_history.sql` then `supabase/sql/02_storage_recipe_images.sql`
(optionally `03_verify.sql` to check). They create:
- `search_history` with Row Level Security: a user can only read, add or
  delete **their own** rows.
- the `recipe-images` Storage bucket (users may only write inside a folder
  named after their own user id).

In Authentication > Providers > Email, turn off "Confirm email" while testing.

### 2. Put your secret API keys in ONE place (the developer does this once)
```bash
cp supabase/.env.example supabase/.env     # fill in the keys you have
supabase link --project-ref YOUR-PROJECT-REF
supabase secrets set --env-file supabase/.env
supabase functions deploy find-recipes
```
That is it. Every user of the app now gets recipes through your keys.
No user ever types or sees a key.

Why not paste the key into Dart code? Anything inside an APK/IPA can be
extracted in minutes, and a leaked shared key means someone else spends your
quota. Edge Function secrets stay on the server.

What the function does (`supabase/functions/find-recipes/index.ts`):
Spoonacular (if you set its key) -> TheMealDB -> Gemini AI fallback.
It also rejects anonymous callers and limits each user to 10 searches a minute.

### 3. Give the app your PUBLIC project URL and anon key
```bash
cp env/dev.example.json env/dev.json       # fill in URL + anon key
flutter run --dart-define-from-file=env/dev.json
```
The URL and anon key are public by design; the data is protected by RLS.
`env/dev.json` is git-ignored.

## Chef Bhai chat
Every user has a private chat thread with an AI cooking assistant. It is limited to cooking, food and 3Bhai topics (two-stage check on the server), see SETUP_SUPABASE_GEMINI.md section 8.

## How privacy works

| Thing | Where | Protection |
|---|---|---|
| Spoonacular / Gemini keys | Edge Function secrets | Never in the app |
| Who can call the function | Supabase JWT check | Logged-in users only, rate limited |
| Search history | `search_history` table | RLS: `auth.uid() = user_id` |
| Chat messages | `chat_messages` table | RLS read/delete own only; only the function can insert |
| Recipe image links | stored as public https URLs | No image bytes in the database |
| Sessions | supabase_flutter | Restored on restart; Android backup disabled |

## Structure

```
lib/
  core/        config, theme, failures, validators, shared widgets
  features/
    auth/      domain / data (Supabase + demo) / presentation
    recipe/    domain / data (Edge Function, TheMealDB, history) / presentation
    chat/      domain / data (Supabase, demo) / presentation (ChatCubit, ChatPage)
supabase/      migrations, config, find-recipes Edge Function, .env.example
assets/        logo (images/ for the app, branding/ for SVG + icon sources)
test/          validators, cubits, ranking, history isolation, catalog
```
