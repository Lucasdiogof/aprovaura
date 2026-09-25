-- Read-only checkup for i18n_atualidades_translations.sql. One result set:
-- every row must say ok = true.
select 'dossiers ' || l.locale as item,
       count(t.dossier_id) || '/' || (select count(*) from dossiers) as detail,
       count(t.dossier_id) = (select count(*) from dossiers) as ok
from (values ('en'), ('es')) l(locale)
left join dossier_translations t on t.locale = l.locale
group by l.locale
union all
select 'dossier questions ' || l.locale,
       count(t.dossier_question_id) || '/' || (select count(*) from dossier_questions),
       count(t.dossier_question_id) = (select count(*) from dossier_questions)
from (values ('en'), ('es')) l(locale)
left join dossier_question_translations t on t.locale = l.locale
group by l.locale
union all
select 'option count mismatch',
       count(*)::text,
       count(*) = 0
from dossier_question_translations t
join dossier_questions q on q.id = t.dossier_question_id
where cardinality(t.options) <> cardinality(q.options)
union all
select 'blank title or prompt',
       count(*)::text,
       count(*) = 0
from (
  select title as s from dossier_translations
  union all select prompt from dossier_question_translations
) x
where coalesce(btrim(s), '') = ''
order by item;
