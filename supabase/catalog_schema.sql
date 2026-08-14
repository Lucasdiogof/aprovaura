-- Aura content catalog: one self-referencing tree per subject.
-- Region/Theme/Activity (Geography) and Area/Theme/Activity (Math) are all
-- just nodes at different depths of the same tree, since different subjects
-- need different hierarchy depths (see project_aura_geography_content_structure
-- and project_aura_lesson_platform memory notes).

create table if not exists catalog_nodes (
  id uuid primary key default gen_random_uuid(),
  subject text not null,
  parent_id uuid references catalog_nodes (id) on delete cascade,
  title text not null,
  description text,
  icon text,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists catalog_nodes_subject_parent_idx
  on catalog_nodes (subject, parent_id, order_index);

alter table catalog_nodes enable row level security;

-- Content is reference data, not user data: anyone (including anonymous
-- visitors) can read it. It is only ever written by hand via SQL, never by
-- the app itself, so no insert/update/delete policy is defined here.
create policy "catalog_nodes are publicly readable"
  on catalog_nodes for select
  using (true);
