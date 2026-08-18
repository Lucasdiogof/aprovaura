create table if not exists dossier_questions (
  id uuid primary key default gen_random_uuid(),
  dossier_id uuid not null references dossiers (id) on delete cascade,
  prompt text not null,
  options text[] not null,
  correct_index int not null,
  explanation text,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists dossier_questions_dossier_idx
  on dossier_questions (dossier_id, order_index);

alter table dossier_questions enable row level security;

create policy "dossier questions are publicly readable"
  on dossier_questions for select
  using (true);
