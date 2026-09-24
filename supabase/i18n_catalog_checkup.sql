-- Read-only checkup for i18n FASE 4 (catalog translations). Changes
-- nothing. Run after i18n_catalog_translations.sql; every row should say
-- "ok".

-- 1. Every catalog node has an en and an es translation.
select 'every node has ' || l.locale as check,
  case when not exists (
    select 1 from catalog_nodes c
    where not exists (
      select 1 from catalog_node_translations t
      where t.catalog_node_id = c.id and t.locale = l.locale
    )
  ) then 'ok'
  else 'MISSING ' || (
    select count(*) from catalog_nodes c
    where not exists (
      select 1 from catalog_node_translations t
      where t.catalog_node_id = c.id and t.locale = l.locale
    )
  )::text end as result
from (values ('en'), ('es')) as l(locale)

union all

-- 2. No blank titles.
select 'no blank translated title',
  case when not exists (
    select 1 from catalog_node_translations where btrim(title) = ''
  ) then 'ok' else 'BLANK TITLE' end

union all

-- 3. A description is translated exactly when the original has one (never
-- a translated description for a node that shows none in pt-BR, never a
-- pt-BR description left untranslated).
select 'description present iff original has one',
  case when not exists (
    select 1
    from catalog_node_translations t
    join catalog_nodes c on c.id = t.catalog_node_id
    where (nullif(btrim(c.description), '') is null)
       <> (nullif(btrim(t.description), '') is null)
  ) then 'ok' else 'MISMATCH' end

union all

-- 4. The RPC the app calls actually returns the translation, and pt-BR
-- still returns the original.
select 'catalog_children(en) returns the translated title',
  case when exists (
    select 1
    from catalog_nodes c
    join catalog_node_translations t
      on t.catalog_node_id = c.id and t.locale = 'en'
    join catalog_children(c.subject, null, 'en') r on r.id = c.id
    where c.parent_id is null and r.title = t.title
  ) then 'ok' else 'NOT TRANSLATED' end

union all

select 'catalog_children(pt-BR) still returns the original title',
  case when not exists (
    select 1
    from catalog_nodes c
    join catalog_children(c.subject, null, 'pt-BR') r on r.id = c.id
    where c.parent_id is null and r.title <> c.title
  ) then 'ok' else 'PT-BR CHANGED' end;
