-- Aura's Atualidades content model — deliberately NOT part of catalog_nodes.
-- Unlike the other subjects, this content ages: each dossiê needs a
-- validity window and real sources, per the design discussed for Atualidades.
--
-- No content is seeded by this file on purpose — dossiês need real,
-- fact-checked, sourced content, which isn't something to fabricate.
-- This just prepares the table for real content later.

create table if not exists dossiers (
  id uuid primary key default gen_random_uuid(),
  area text not null,
  title text not null,
  summary text,
  context text,
  what_happened text,
  why_it_happened text,
  who_is_involved text,
  consequences text,
  key_takeaways text,
  sources text[] not null default '{}',
  read_minutes int,
  status text not null default 'current',
  reference_period_start date,
  reference_period_end date,
  order_index int not null default 0,
  published_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists dossiers_area_idx on dossiers (area, order_index);

alter table dossiers enable row level security;

create policy "dossiers are publicly readable"
  on dossiers for select
  using (true);

-- Reuses the generic set_profiles_updated_at() trigger function created by
-- profiles_schema.sql (its body is generic — just sets updated_at = now() —
-- despite the name, so no need to duplicate it here).
create trigger dossiers_set_updated_at
  before update on dossiers
  for each row
  execute function set_profiles_updated_at();
