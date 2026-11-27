#!/usr/bin/env bash
# Testa o backfill de categorias num Postgres DESCARTÁVEL: cria 2.609 questões sintéticas com os ids reais (só ids, sem conteúdo),
# aplica o SQL 2x (idempotência), confere contagens e que nada de questions foi alterado. Não toca produção.
set -u
cd "$(dirname "$0")/../.."
export KEEP=1 PORT=${PORT:-55433}
export BASE_FILES="supabase/profiles_schema.sql supabase/catalog_schema.sql supabase/questions_schema.sql supabase/difficulty_schema.sql supabase/progress_schema.sql supabase/essays.sql supabase/xp_schema.sql supabase/quiz_xp_ledger.sql supabase/streaks_schema.sql supabase/favorites_schema.sql supabase/error_review_schema.sql supabase/mock_exams.sql supabase/question_reports.sql"
NAME=aura-empty-check
bash tool/db/empty_db_check.sh | tail -3
psqlx() { docker exec -i $NAME psql -U postgres -v ON_ERROR_STOP=1 -q -t "$@"; }
python - <<'PY' > /tmp/ids.sql
import json
ids=[json.loads(l)["id"] for l in open("tool/content/registro/backfill_categorias.jsonl",encoding="utf-8")]
print("insert into catalog_nodes(id,subject,title) values ('00000000-0000-0000-0000-000000000001','teste','t');")
print("insert into questions(id,catalog_node_id,prompt,options,correct_index) select i,'00000000-0000-0000-0000-000000000001','p',array['a','b','c','d'],0 from unnest(array[%s]::uuid[]) i;" % ",".join("'%s'"%i for i in ids))
PY
psqlx < /tmp/ids.sql
before=$(psqlx -c "select md5(string_agg(id::text||prompt||correct_index,',' order by id)) from questions")
psqlx -c "select count(*) as questoes from questions"
psqlx -f - < supabase/backfill/20261210000100_backfill_question_categories.sql
a=$(psqlx -c "select count(*) from question_categories")
psqlx -f - < supabase/backfill/20261210000100_backfill_question_categories.sql
b=$(psqlx -c "select count(*) from question_categories")
after=$(psqlx -c "select md5(string_agg(id::text||prompt||correct_index,',' order by id)) from questions")
echo "1a aplicacao=$a 2a aplicacao=$b (idempotente se iguais)"; echo "questions inalteradas: $([ "$before" = "$after" ] && echo SIM || echo NAO)"
psqlx -c "select category, count(*) from question_categories group by 1 order by 1"
psqlx -c "select count(*) as sem_categoria from questions q where not exists (select 1 from question_categories c where c.question_id=q.id)"
docker rm -f $NAME >/dev/null
