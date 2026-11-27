-- Testes da migration 20261209000100_content_classification (rodar em banco DESCARTÁVEL, nunca em produção).
-- Uso: tool/db/content_classification_check.sh  (sobe Postgres vazio, aplica tudo, roda isto, roda rollback e reaplica)
\set ON_ERROR_STOP on
create or replace function _expect_error(p_sql text, p_label text) returns void language plpgsql as $$
begin
  begin execute p_sql; exception when others then return; end;
  raise exception 'ESPERADO ERRO e não houve: %', p_label;
end $$;

-- Acervo legado simulado + dados de usuário que precisam sobreviver.
insert into auth.users (id, email) values ('00000000-0000-0000-0000-0000000000a1', 'u@teste.invalid');
insert into catalog_nodes (id, subject, title) values
  ('00000000-0000-0000-0000-0000000000c1', 'matematica', 'Raiz teste'),
  ('00000000-0000-0000-0000-0000000000c2', 'dir_penal', 'Penas');
insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000c1', 'q1', array['a','b','c','d'], 0, 'e'),
  ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-0000000000c1', 'q2', array['a','b','c','d'], 1, 'e'),
  ('00000000-0000-0000-0000-0000000000d3', '00000000-0000-0000-0000-0000000000c1', 'q3', array['a','b','c','d'], 2, 'e');
insert into user_question_progress (user_id, question_id, is_correct) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000d1', true);
insert into user_question_favorites (user_id, question_id) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000d2');
create temp table _snap as select md5(string_agg(q::text, '|' order by id)) h, count(*) n from questions q;

-- 1) Classificação múltipla individual sem duplicar entidade; total único não soma em duplicidade.
insert into question_categories (question_id, category) values
  ('00000000-0000-0000-0000-0000000000d1', 'enem'), ('00000000-0000-0000-0000-0000000000d1', 'vestibular'),
  ('00000000-0000-0000-0000-0000000000d1', 'concurso'), ('00000000-0000-0000-0000-0000000000d2', 'enem');
do $$ begin
  if (select unique_questions from content_coverage where category = 'enem') <> 2 then raise exception 'enem'; end if;
  if (select unique_questions from content_coverage where category = 'concurso') <> 1 then raise exception 'concurso'; end if;
  if (select unique_questions from content_coverage where category = 'total_unico') <> 3 then raise exception 'total único'; end if;
  if (select unique_questions from content_coverage where category = 'sem_categoria') <> 1 then raise exception 'sem categoria'; end if;
end $$;
select _expect_error($$insert into question_categories values ('00000000-0000-0000-0000-0000000000d1','enem')$$, 'categoria repetida');
select _expect_error($$insert into question_categories values ('00000000-0000-0000-0000-0000000000d3','todas')$$, 'categoria inválida (sem "Todas")');
insert into catalog_node_categories (catalog_node_id, category) values ('00000000-0000-0000-0000-0000000000c2', 'concurso');

-- 2) Proveniência: banca/ano só com origem oficial documentada.
insert into question_provenance (question_id, origin) values ('00000000-0000-0000-0000-0000000000d1', 'legado_nao_registrado');
select _expect_error($$insert into question_provenance (question_id, origin, banca) values ('00000000-0000-0000-0000-0000000000d2','autoral','Banca X')$$, 'banca inventada');
select _expect_error($$insert into question_provenance (question_id, origin, exam_year) values ('00000000-0000-0000-0000-0000000000d2','autoral',2020)$$, 'ano inventado');
select _expect_error($$insert into question_provenance (question_id, origin, banca) values ('00000000-0000-0000-0000-0000000000d2','oficial_autorizada','B')$$, 'oficial sem licença/URL');
insert into question_provenance (question_id, origin, banca, exam_year, source_url, license, consulted_at)
  values ('00000000-0000-0000-0000-0000000000d3', 'oficial_autorizada', 'B', 2020, 'https://x.invalid', 'domínio público', current_date);

-- 3) Lote em staging + permissões.
insert into content_batches (code, description) values ('T1', 'teste');
insert into content_question_staging (batch_id, source_key, subject, topic_key, categories, prompt, options, correct_index, explanation, difficulty, validation_state, provenance, reference_date)
select b.id, k, 'dir_penal', 'dir_penal.penas', array['concurso','enem'], 'Pergunta ' || k, array['a','b','c','d'], 1, 'Explicação ' || k, 'medio', st,
       '{"origin":"autoral"}'::jsonb, date '2026-11-27'
from content_batches b, (values ('k1','publicavel'), ('k2','publicavel'), ('k3','rascunho'), ('k4','rejeitada'), ('k5','revisao_especializada_pendente')) v(k, st)
where b.code = 'T1';
set role anon;
select _expect_error($$select * from content_question_staging$$, 'anon lendo staging');
select _expect_error($$select * from content_batches$$, 'anon lendo lotes');
select _expect_error($$select * from question_provenance$$, 'anon lendo proveniência');
select _expect_error($$select content_promote_batch('T1', '{}'::jsonb)$$, 'anon promovendo');
reset role;
set role authenticated;
select _expect_error($$select content_promote_batch('T1', '{}'::jsonb)$$, 'authenticated promovendo');
select _expect_error($$select * from content_question_staging$$, 'authenticated lendo staging');
reset role;
do $$ begin perform 1 from content_categories; end $$;

-- 4) Promoção: só 'publicavel'; mapa obrigatório; idempotente; catálogo ativo intacto antes.
select _expect_error($$select content_promote_batch('T1', '{}'::jsonb)$$, 'promoção sem mapa de tópico');
do $$ declare n int; begin
  n := content_promote_batch('T1', '{"dir_penal.penas":"00000000-0000-0000-0000-0000000000c2"}'::jsonb);
  if n <> 2 then raise exception 'promovidas % (esperado 2)', n; end if;
  if (select count(*) from questions) <> 5 then raise exception 'total questions'; end if;
  if (select count(*) from question_categories qc join content_question_staging s on s.promoted_question_id = qc.question_id) <> 4 then raise exception 'categorias promovidas'; end if;
  if (select count(*) from question_provenance where batch_id is not null) <> 2 then raise exception 'proveniência promovida'; end if;
  if content_promote_batch('T1', '{"dir_penal.penas":"00000000-0000-0000-0000-0000000000c2"}'::jsonb) <> 0 then raise exception 'não idempotente'; end if;
  if exists (select 1 from questions where prompt in ('Pergunta k3','Pergunta k4','Pergunta k5')) then raise exception 'pendente/rejeitada vazou para o catálogo'; end if;
  if (select status from content_batches where code = 'T1') <> 'promovido' then raise exception 'status lote'; end if;
end $$;
-- legado intacto
do $$ begin
  if (select md5(string_agg(q::text, '|' order by id)) from questions q where id in ('00000000-0000-0000-0000-0000000000d1','00000000-0000-0000-0000-0000000000d2','00000000-0000-0000-0000-0000000000d3'))
     is distinct from (select h from _snap) then raise exception 'legado alterado'; end if;
end $$;

-- 5) Reversão segura: bloqueia com histórico; remove só o lote quando limpo; legado e progresso preservados.
insert into user_question_progress (user_id, question_id, is_correct)
  select '00000000-0000-0000-0000-0000000000a1', promoted_question_id, false from content_question_staging where source_key = 'k1';
select _expect_error($$select content_unpromote_batch('T1')$$, 'reverter lote com histórico');
delete from user_question_progress where question_id = (select promoted_question_id from content_question_staging where source_key = 'k1');
do $$ begin
  if content_unpromote_batch('T1') <> 2 then raise exception 'unpromote'; end if;
  if (select count(*) from questions) <> 3 then raise exception 'questions após unpromote'; end if;
  if (select count(*) from user_question_progress) <> 1 or (select count(*) from user_question_favorites) <> 1 then raise exception 'dados de usuário alterados'; end if;
end $$;
select 'content_classification_tests OK' as resultado;
