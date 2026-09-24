-- i18n FASE 2: translation tables for en/es. pt-BR is NOT duplicated here
-- -- it stays exactly where it already lives (catalog_nodes.title,
-- questions.prompt, etc.), which is the fallback every RPC in
-- i18n_*_rpcs.sql falls back to. Adding a row here is the only thing a
-- future translation phase needs to do; no schema change, no touching the
-- original content.
--
-- Same shape for every one of the five tables: (entity_id, locale) as the
-- primary key -- one row is "the en (or es) translation of this entity",
-- full stop. RLS mirrors the table each one translates (public read,
-- write only by hand via SQL, same posture as catalog_nodes/questions
-- themselves -- translations are reference content too).
--
-- Idempotent: safe to run again. Depends on catalog_schema.sql,
-- questions_schema.sql, dossiers_schema.sql, dossier_questions_schema.sql,
-- essays.sql already being applied.

-- ---------------------------------------------------------------------------
-- catalog_nodes -> catalog_node_translations
-- ---------------------------------------------------------------------------
create table if not exists catalog_node_translations (
  catalog_node_id uuid not null references catalog_nodes (id) on delete cascade,
  locale text not null check (locale in ('en', 'es')),
  title text not null,
  description text,
  primary key (catalog_node_id, locale)
);

alter table catalog_node_translations enable row level security;

drop policy if exists "catalog node translations are publicly readable"
  on catalog_node_translations;
create policy "catalog node translations are publicly readable"
  on catalog_node_translations for select
  using (true);

-- ---------------------------------------------------------------------------
-- questions -> question_translations
-- ---------------------------------------------------------------------------
-- No `explanation` NOT NULL requirement (the original column is nullable
-- too), but prompt/options ARE required here: a translation row that only
-- half-exists isn't a usable translation -- see the "atomic" rule in
-- i18n_catalog_questions_rpcs.sql for how a mismatched options count is
-- treated as if the row didn't exist at all.
create table if not exists question_translations (
  question_id uuid not null references questions (id) on delete cascade,
  locale text not null check (locale in ('en', 'es')),
  prompt text not null,
  options text[] not null,
  explanation text,
  primary key (question_id, locale)
);

alter table question_translations enable row level security;

drop policy if exists "question translations are publicly readable"
  on question_translations;
create policy "question translations are publicly readable"
  on question_translations for select
  using (true);

-- ---------------------------------------------------------------------------
-- dossiers -> dossier_translations
-- ---------------------------------------------------------------------------
create table if not exists dossier_translations (
  dossier_id uuid not null references dossiers (id) on delete cascade,
  locale text not null check (locale in ('en', 'es')),
  title text not null,
  summary text,
  context text,
  what_happened text,
  why_it_happened text,
  who_is_involved text,
  consequences text,
  key_takeaways text,
  primary key (dossier_id, locale)
);

alter table dossier_translations enable row level security;

drop policy if exists "dossier translations are publicly readable"
  on dossier_translations;
create policy "dossier translations are publicly readable"
  on dossier_translations for select
  using (true);

-- ---------------------------------------------------------------------------
-- dossier_questions -> dossier_question_translations
-- ---------------------------------------------------------------------------
create table if not exists dossier_question_translations (
  dossier_question_id uuid not null
    references dossier_questions (id) on delete cascade,
  locale text not null check (locale in ('en', 'es')),
  prompt text not null,
  options text[] not null,
  explanation text,
  primary key (dossier_question_id, locale)
);

alter table dossier_question_translations enable row level security;

drop policy if exists "dossier question translations are publicly readable"
  on dossier_question_translations;
create policy "dossier question translations are publicly readable"
  on dossier_question_translations for select
  using (true);

-- ---------------------------------------------------------------------------
-- essay_themes -> essay_theme_translations
-- ---------------------------------------------------------------------------
-- Translates the THEME only (title/description/prompt/supporting_texts).
-- The essay the user writes (essay_drafts.body, essay_submissions.body) is
-- never touched by this table and never auto-translated -- see
-- i18n_essay_rpcs.sql for where that boundary is enforced.
--
-- supporting_texts keeps the exact same jsonb shape as
-- essay_themes.supporting_texts ([{ "title", "body", "source" }, ...]):
-- the check below only guarantees it's still an array, same as the
-- original column's own constraint. A translation is free to omit a
-- supporting text's "source" (it's a citation, sources don't get
-- retranslated) but must keep "body" for every block it includes.
create table if not exists essay_theme_translations (
  essay_theme_id uuid not null references essay_themes (id) on delete cascade,
  locale text not null check (locale in ('en', 'es')),
  title text not null,
  description text,
  prompt text not null,
  supporting_texts jsonb not null default '[]'::jsonb
    check (jsonb_typeof(supporting_texts) = 'array'),
  primary key (essay_theme_id, locale)
);

alter table essay_theme_translations enable row level security;

drop policy if exists "essay theme translations are publicly readable"
  on essay_theme_translations;
create policy "essay theme translations are publicly readable"
  on essay_theme_translations for select
  using (true);
