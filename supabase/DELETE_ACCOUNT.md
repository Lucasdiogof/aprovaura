# Account deletion — audit and deploy notes

Referenced from `supabase/functions/delete-account/index.ts`. Covers the
schema audit that justified skipping a cleanup RPC, and exactly what to run
to deploy the function.

## Schema audit: every table that references `auth.users`

Checked every `create table` across `supabase/*.sql` (2026-09-24). Content
tables (`catalog_nodes`, `questions`, `dossiers`, `dossier_questions`) have
no `user_id` column — not user-owned, not relevant here. Every user-owned
table already has a **direct** `on delete cascade` straight to `auth.users`:

| Table | FK | Cascade |
|---|---|---|
| `profiles` | `id → auth.users(id)` | ✅ `on delete cascade` |
| `user_xp` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `xp_awards` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `user_streaks` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `user_question_progress` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `user_question_favorites` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `user_region_progress` | `user_id → auth.users(id)` | ✅ `on delete cascade` |
| `question_reports` | `user_id → auth.users(id)` | ✅ `on delete cascade` |

No exceptions, no `restrict`/`no action`, nothing indirect. Unlike Match
Queue, Aura has no teams or data shared between users — nothing here needs
anonymizing instead of deleting. Deleting the `auth.users` row cascades
through every one of these automatically; there is nothing left for a
pre-cleanup RPC to do.

`essay_*` / `mock_exam_*` tables (Redação, Montar Simulado) don't exist yet
— nothing to audit there. **Whoever builds those must give their user-owned
tables the same `on delete cascade`, or this audit goes stale.**

## Storage audit

`grep -rl "storage\|bucket" supabase/*.sql lib` returns nothing. Aura has
never used Supabase Storage — no bucket, no policy, no upload call anywhere
in the app (the profile `avatar_url` column is a plain text URL, not a
Storage object reference). There is nothing to delete or transfer
ownership of before removing a user, and no risk of Storage blocking the
deletion.

## Deploying the function

The Supabase CLI wasn't installed for this project before now. It's
available as a local dev dependency (`package.json`), so every command
below runs through `npx` — nothing installed globally.

```bash
# One-time: log into your Supabase account (opens a browser)
npx supabase login

# One-time: link this folder to the Aura project
npx supabase link --project-ref cesuqfgrtcitatxvokez

# Deploy (or redeploy after any edit to index.ts)
npx supabase functions deploy delete-account
```

No `supabase secrets set` needed: `SUPABASE_URL` and `SUPABASE_ANON_KEY` /
`SUPABASE_SERVICE_ROLE_KEY` are injected automatically into every Edge
Function by Supabase. If deploy or a live call fails with something like
"SUPABASE_SERVICE_ROLE_KEY is undefined", check **Project Settings → Edge
Functions → Secrets** in the dashboard for the exact name your project
currently auto-injects and adjust the one `Deno.env.get(...)` call in
`index.ts` accordingly — everything else about the function stays the
same.

## What this deliberately does not do

- No soft delete — this removes the real `auth.users` row.
- No new SQL migration — every cascade needed already exists.
- No change to `applicationId`/bundle id/Firebase/Supabase project/API
  keys/deep links — none of those reference "aura" as an identifier that
  would need to change for this feature.
