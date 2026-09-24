-- Lets a user flag a question as wrong/broken/confusing from inside the
-- quiz. No FK to `questions` on purpose: a report can come from the
-- regular catalog quiz, quick practice, review, favorites or an
-- Atualidades dossier, and dossier questions live in a separate table
-- (dossier_questions). question_prompt is a snapshot taken at report time
-- so reviewing reports later doesn't depend on the question still
-- existing or joining across two different tables.
--
-- No reason/comment field yet -- keeping this to what the quiz screen can
-- ship without turning this phase into a whole reporting UI. Add one
-- later if it turns out to be needed.

create table if not exists question_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  question_id uuid not null,
  question_prompt text not null,
  created_at timestamptz not null default now()
);

create index if not exists question_reports_question_idx
  on question_reports (question_id);

alter table question_reports enable row level security;

drop policy if exists "users can report a question" on question_reports;
create policy "users can report a question"
  on question_reports for insert
  with check (auth.uid() = user_id);

drop policy if exists "users can read their own reports" on question_reports;
create policy "users can read their own reports"
  on question_reports for select
  using (auth.uid() = user_id);
