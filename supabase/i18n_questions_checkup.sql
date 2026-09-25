-- Read-only checkup for the question translation phases (i18n FASES 5-11,
-- one subject per phase). Changes nothing. Safe to run after any of the
-- i18n_questions_<subject>.sql files, any number of times.
--
-- One result (the SQL Editor only shows the last one):
--   * "coverage: <subject>" rows -- "complete" for every subject whose
--     phase already ran; a subject not translated yet shows how many are
--     missing, which is expected (the app falls back to pt-BR for it).
--   * every other row is an integrity check and should say "ok".

select * from (
  select 'coverage: ' || c.subject as check,
    case
      when count(*) filter (where en.question_id is null
                              or es.question_id is null) = 0
        then 'complete (' || count(*) || ' questions)'
      else 'en missing ' || count(*) filter (where en.question_id is null)
        || ', es missing ' || count(*) filter (where es.question_id is null)
        || ' of ' || count(*)
    end as result
  from questions q
  join catalog_nodes c on c.id = q.catalog_node_id
  left join question_translations en
    on en.question_id = q.id and en.locale = 'en'
  left join question_translations es
    on es.question_id = q.id and es.locale = 'es'
  group by c.subject
  order by c.subject
) coverage

union all

select 'every translation has the same number of options as the original',
  case when not exists (
    select 1 from question_translations t
    join questions q on q.id = t.question_id
    where cardinality(t.options) <> cardinality(q.options)
  ) then 'ok' else 'MISMATCH' end as result

union all

select 'no blank prompt or option',
  case when not exists (
    select 1 from question_translations t
    where btrim(t.prompt) = ''
       or exists (select 1 from unnest(t.options) o where btrim(o) = '')
  ) then 'ok' else 'BLANK' end

union all

select 'explanation translated iff the original has one',
  case when not exists (
    select 1 from question_translations t
    join questions q on q.id = t.question_id
    where (nullif(btrim(q.explanation), '') is null)
       <> (nullif(btrim(t.explanation), '') is null)
  ) then 'ok' else 'MISMATCH' end

union all

select 'correct_index still valid for every question',
  case when not exists (
    select 1 from questions
    where correct_index < 0 or correct_index >= cardinality(options)
  ) then 'ok' else 'INVALID' end

union all

-- The RPC the app calls returns the translation for en, keeps the original
-- for pt-BR, and never changes which option is the correct one.
select 'get_catalog_questions(en) returns the translation',
  case when exists (
    select 1
    from question_translations t
    join questions q on q.id = t.question_id
    join get_catalog_questions(q.catalog_node_id, null, 'en') r
      on r.id = q.id
    where t.locale = 'en' and r.prompt = t.prompt
      and r.options[r.correct_index + 1] = t.options[q.correct_index + 1]
  ) then 'ok'
  when not exists (select 1 from question_translations) then 'ok (nothing translated yet)'
  else 'NOT TRANSLATED' end

union all

select 'get_catalog_questions(pt-BR) still returns the original',
  case when not exists (
    select 1
    from question_translations t
    join questions q on q.id = t.question_id
    join get_catalog_questions(q.catalog_node_id, null, 'pt-BR') r
      on r.id = q.id
    where r.prompt <> q.prompt or r.options <> q.options
       or r.correct_index <> q.correct_index
  ) then 'ok' else 'PT-BR CHANGED' end;
