#!/usr/bin/env bash
# Valida a migration de classificação/proveniência num Postgres descartável (Docker): aplica todas as migrations,
# roda os testes, executa o rollback, confere, reaplica. NÃO toca em produção nem no stack de QA.
set -u
cd "$(dirname "$0")/../.."
export KEEP=1 PORT=${PORT:-55433}
export BASE_FILES="supabase/profiles_schema.sql supabase/catalog_schema.sql supabase/questions_schema.sql supabase/difficulty_schema.sql supabase/progress_schema.sql supabase/essays.sql supabase/xp_schema.sql supabase/quiz_xp_ledger.sql supabase/streaks_schema.sql supabase/favorites_schema.sql supabase/error_review_schema.sql supabase/mock_exams.sql supabase/question_reports.sql"
NAME=aura-empty-check
bash tool/db/empty_db_check.sh | tail -30
psqlx() { docker exec -i $NAME psql -U postgres -v ON_ERROR_STOP=1 -q "$@"; }
echo "--- testes"; psqlx -t < tool/db/content_classification_tests.sql || { echo FALHOU; docker rm -f $NAME >/dev/null; exit 1; }
echo "--- export de lotes (staging)"; for f in tool/content/batches/*/export/staging_*.sql; do [ -f "$f" ] && psqlx -f - < "$f" && psqlx -t -c "select count(*) as staging_publicavel from content_question_staging where validation_state='publicavel' and batch_id in (select id from content_batches where status='em_staging');" && psqlx -t -c "select count(*) as questions_visiveis_ao_app_de_lote from questions q join content_question_staging s on s.promoted_question_id=q.id;"; done
echo "--- rollback"; psqlx -f - < supabase/rollbacks/20261209000100_content_classification.down.sql || { echo FALHOU_ROLLBACK; exit 1; }
psqlx -t -c "select count(*) from information_schema.tables where table_schema='public' and table_name in ('question_categories','question_provenance','content_batches','content_question_staging','catalog_node_categories','content_categories');"
echo "--- reaplicando"; psqlx -f - < supabase/migrations/20261209000100_content_classification.sql && echo REAPLICOU_OK
docker rm -f $NAME >/dev/null
