create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  catalog_node_id uuid not null references catalog_nodes (id) on delete cascade,
  prompt text not null,
  options text[] not null,
  correct_index int not null,
  explanation text,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists questions_catalog_node_idx
  on questions (catalog_node_id, order_index);

alter table questions enable row level security;

create policy "questions are publicly readable"
  on questions for select
  using (true);
