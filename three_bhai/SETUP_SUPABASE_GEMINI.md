# Supabase + Gemini setup for 3Bhai

Do this once as the developer. After it, every user can sign up, search recipes
and chat with Chef Bhai, each with their own private data, and nobody ever
types an API key.

## 1. Where everything is in the project

| What | File / folder |
|---|---|
| Database scripts (paste into Supabase) | `supabase/sql/01_search_history.sql`, `02_storage_recipe_images.sql`, `03_chat_messages.sql`, `04_verify.sql` |
| Same scripts as one CLI migration | `supabase/migrations/20260101000000_init.sql` |
| Recipe engine (Spoonacular, TheMealDB, Gemini fallback) | `supabase/functions/find-recipes/index.ts` |
| Chef Bhai chat (Gemini, cooking topics only) | `supabase/functions/chef-chat/index.ts` |
| Where secret keys go | `supabase/.env.example` (copy to `supabase/.env`) |
| Function settings | `supabase/config.toml` |
| App's public Supabase URL + anon key | `env/dev.example.json` (copy to `env/dev.json`) |
| Flutter: reads those two values | `lib/core/config/app_config.dart` |
| Flutter: starts Supabase | `lib/main.dart` |
| Flutter: login / sign up / logout | `lib/features/auth/data/repositories/supabase_auth_repository.dart` |
| Flutter: private recipe history | `lib/features/recipe/data/repositories/supabase_history_repository.dart` |
| Flutter: calls the recipe function | `lib/features/recipe/data/datasources/edge_function_recipe_data_source.dart` |
| Flutter: private chat + calls chat function | `lib/features/chat/data/repositories/supabase_chat_repository.dart` |
| Flutter: switch between demo and Supabase | `lib/app.dart` (the `useSupabase` checks) |

## 2. Create the Supabase project
1. Go to supabase.com, sign in, **New project**. Save the database password.
2. **Authentication > Providers > Email**: keep Email on, turn **off** "Confirm email" while testing.
3. **Project Settings > API** (or the "Connect" button): copy the **Project URL** and the **anon public key**.

## 3. Create the tables
Dashboard > **SQL Editor** > **New query**. Paste each file's whole content and click **Run**, in this order:
1. `supabase/sql/01_search_history.sql`
2. `supabase/sql/02_storage_recipe_images.sql`
3. `supabase/sql/03_chat_messages.sql`
4. `supabase/sql/04_verify.sql` (optional; both tables should show `rowsecurity = true`)

## 4. Get a Gemini key
1. Open https://aistudio.google.com/apikey and sign in with a Google account.
2. **Create API key**, copy it.
3. Optional test (replace YOUR_KEY):
   `curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" -H "x-goog-api-key: YOUR_KEY" -H "Content-Type: application/json" -d "{\"contents\":[{\"parts\":[{\"text\":\"Say hi\"}]}]}"`
4. The free tier has daily limits. If Google retires the model name later, set `GEMINI_MODEL` to a current one in the secrets below.

## 5. Store the keys on the server (one time)
**Option A: Supabase CLI** (install from supabase.com/docs/guides/cli)

    copy supabase\.env.example supabase\.env        (Mac/Linux: cp)
    # edit supabase/.env and paste GEMINI_API_KEY=... (and SPOONACULAR_API_KEY if you have one)
    supabase login
    supabase link --project-ref YOUR-PROJECT-REF
    supabase secrets set --env-file supabase/.env
    supabase functions deploy find-recipes
    supabase functions deploy chef-chat

Your project ref is the part of the URL before `.supabase.co`.

**Option B: dashboard only**
- **Edge Functions > Secrets**: add `GEMINI_API_KEY` (and optionally `SPOONACULAR_API_KEY`, `GEMINI_MODEL`).
- **Edge Functions > Deploy a new function > Via Editor**: name it exactly `find-recipes`, paste `supabase/functions/find-recipes/index.ts`, Deploy. Repeat with name `chef-chat` and its file. Leave "Verify JWT" on.

## 6. Give the app the public values
    copy env\dev.example.json env\dev.json
Edit `env/dev.json` with your Project URL and anon key, then:

    flutter run --dart-define-from-file=env/dev.json
    flutter build apk --release --dart-define-from-file=env/dev.json

Without `env/dev.json` the app runs in demo mode (a banner says so).

## 7. How privacy works
- Every user has one private chat thread and their own recipe history, stored with their user id.
- Row Level Security lets a user read and delete only their own rows.
- Users cannot insert chat rows at all; only the `chef-chat` function (service role) writes them, so replies cannot be forged.
- Chat history sent to Gemini is loaded from the database by user id, never taken from the phone.
- Keys live only in Edge Function secrets, never in the app.

## 8. How Chef Bhai stays on topic
1. A small classifier call decides if the message is about cooking, food or 3Bhai. If not, Gemini's chat model is never called and a fixed polite refusal is returned.
2. The answering call has a locked system instruction and must also confirm `onTopic`; otherwise its text is discarded.
3. Off-topic turns are never reused as context, so users cannot "train" the chat off course.
4. Limits: 500 characters per message, 10 messages a minute, 150 a day per user.

No AI filter is perfect, but unclear cases are treated as off-topic. To tighten further, edit `SYSTEM_INSTRUCTION` and the classifier prompt in `supabase/functions/chef-chat/index.ts` and redeploy.

## 9. Troubleshooting
| Message in the app | Cause and fix |
|---|---|
| "Chef chat is not set up yet" | `GEMINI_API_KEY` secret missing, or `chef-chat` not deployed |
| "Your session expired" | Log out and in again |
| "Confirm your email" | Turn off Confirm email (step 2) or click the email link |
| Recipes always from TheMealDB | No Spoonacular key set; that is fine |
| Chat shows "Demo mode" | App started without `--dart-define-from-file=env/dev.json` |
