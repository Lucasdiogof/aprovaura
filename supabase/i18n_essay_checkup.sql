-- Read-only checkup for i18n_essay_translations.sql. One result set:
-- every row must say ok = true.
select 'themes ' || l.locale as item,
       count(tt.essay_theme_id) || '/' || (select count(*) from essay_themes) as detail,
       count(tt.essay_theme_id) = (select count(*) from essay_themes) as ok
from (values ('en'), ('es')) l(locale)
left join essay_theme_translations tt on tt.locale = l.locale
group by l.locale
union all
select 'supporting_texts length mismatch',
       count(*)::text,
       count(*) = 0
from essay_theme_translations tt
join essay_themes t on t.id = tt.essay_theme_id
where jsonb_array_length(tt.supporting_texts) <> jsonb_array_length(t.supporting_texts)
union all
select 'blank title or prompt',
       count(*)::text,
       count(*) = 0
from essay_theme_translations
where coalesce(btrim(title), '') = '' or coalesce(btrim(prompt), '') = ''
order by item;
