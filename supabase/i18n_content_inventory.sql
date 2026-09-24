-- Read-only inventory for the i18n FASE 1 audit. Doesn't change anything.
-- Real row counts per content table, so the translation effort (and the
-- migration's phase sizing) is planned against the real database instead
-- of guessed from seed files.

select 'catalog_nodes' as table_name, count(*)::int as rows from catalog_nodes
union all
select 'questions', count(*) from questions
union all
select 'dossiers', count(*) from dossiers
union all
select 'dossier_questions', count(*) from dossier_questions
union all
select 'essay_themes', count(*) from essay_themes
union all
select 'essay_themes (official)', count(*) from essay_themes where source_type = 'official'
union all
select 'essay_themes (practice)', count(*) from essay_themes where source_type = 'practice'
union all
-- Distinct subjects in play today, for sizing "how many Subject-label
-- strings need a Spanish translation" (client-side enum, not a query, but
-- this confirms nothing exists in the DB that the enum doesn't already
-- cover).
select 'distinct catalog subjects', count(distinct subject) from catalog_nodes
union all
select 'distinct dossier areas', count(distinct area) from dossiers
order by table_name;
