-- Endurece question_reports (auditoria 2026-09-27). Rodar DEPOIS de
-- question_reports.sql. Idempotente: pode rodar de novo sem efeito colateral.
--
-- 1. Indice em user_id: a policy de SELECT filtra por auth.uid() = user_id e
--    o "on delete cascade" de auth.users varre por user_id -- sem indice,
--    os dois fazem seq scan na tabela inteira.
-- 2. Limite de INSERT: qualquer usuario logado podia inserir quantos reports
--    quisesse, com question_prompt de qualquer tamanho. Agora:
--    - o mesmo usuario reportando a mesma questao de novo em 24h e ignorado
--      em silencio (o insert "da certo" e nada duplica -- o app nao muda);
--    - no maximo 30 reports por usuario por hora (errcode AR429);
--    - question_prompt limitado a 10000 caracteres (enunciados longos do
--      ENEM cabem com folga).

create index if not exists question_reports_user_created_idx
  on public.question_reports (user_id, created_at desc);

alter table public.question_reports
  drop constraint if exists question_reports_prompt_length;
alter table public.question_reports
  add constraint question_reports_prompt_length
  check (char_length(question_prompt) <= 10000) not valid;

create or replace function public.question_reports_limit_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.question_reports
    where user_id = new.user_id
      and question_id = new.question_id
      and created_at > now() - interval '24 hours'
  ) then
    return null;
  end if;

  if (
    select count(*) from public.question_reports
    where user_id = new.user_id
      and created_at > now() - interval '1 hour'
  ) >= 30 then
    raise exception 'too many question reports' using errcode = 'AR429';
  end if;

  return new;
end;
$$;

revoke execute on function public.question_reports_limit_insert()
  from public, anon, authenticated;

drop trigger if exists question_reports_limit_insert on public.question_reports;
create trigger question_reports_limit_insert
  before insert on public.question_reports
  for each row execute function public.question_reports_limit_insert();

-- Checkup (so leitura): deve devolver 3 linhas com ok = true.
select 'index user_id' as item,
       to_regclass('public.question_reports_user_created_idx') is not null as ok
union all
select 'constraint prompt length',
       exists (select 1 from pg_constraint
               where conname = 'question_reports_prompt_length')
union all
select 'trigger limit insert',
       exists (select 1 from pg_trigger
               where tgname = 'question_reports_limit_insert'
                 and not tgisinternal);
