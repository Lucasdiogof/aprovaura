#!/usr/bin/env bash
# Valida as migrações comerciais (14) num Postgres descartável e VAZIO (Docker), sem tocar em produção.
# Base legada (profiles/essays) vem dos .sql raiz mínimos necessários; auth/roles do Supabase são stubs.
set -u
cd "$(dirname "$0")/../.."
NAME=aura-empty-check
docker rm -f $NAME >/dev/null 2>&1
docker run -d --name $NAME -e POSTGRES_PASSWORD=x postgres:16-alpine >/dev/null
for i in $(seq 1 30); do docker exec $NAME pg_isready -U postgres >/dev/null 2>&1 && break; sleep 1; done
sleep 2
psqlx() { docker exec -i $NAME psql -U postgres -v ON_ERROR_STOP=1 -q "$@"; }
psqlx <<'SQL'
create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls; create role authenticator noinherit login;
create schema auth; create schema extensions; create extension if not exists pgcrypto with schema extensions;
create table auth.users (id uuid primary key default gen_random_uuid(), email text, email_confirmed_at timestamptz,
  raw_user_meta_data jsonb default '{}', created_at timestamptz default now(), last_sign_in_at timestamptz, banned_until timestamptz);
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
create function auth.jwt() returns jsonb language sql stable as $$ select '{}'::jsonb $$;
create function auth.role() returns text language sql stable as $$ select current_setting('role', true) $$;
grant usage on schema public, auth to anon, authenticated, service_role;
SQL
FILES="${BASE_FILES:-supabase/profiles_schema.sql supabase/catalog_schema.sql supabase/questions_schema.sql supabase/difficulty_schema.sql supabase/progress_schema.sql supabase/essays.sql supabase/xp_schema.sql supabase/quiz_xp_ledger.sql supabase/streaks_schema.sql supabase/favorites_schema.sql supabase/error_review_schema.sql supabase/mock_exams.sql}"
for f in $FILES supabase/migrations/*.sql; do
  if psqlx -f - < "$f" >/tmp/empty_db_out.txt 2>&1; then echo "OK   $f"; else echo "FAIL $f"; head -5 /tmp/empty_db_out.txt; break; fi
done
docker rm -f $NAME >/dev/null 2>&1
