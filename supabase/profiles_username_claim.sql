-- Nome de usuário: a mesma regra no banco que no app, e a conta nasce com
-- ele numa só transação. Complementa profiles_username_unique.sql (índice
-- único em lower(btrim(username))), que precisa ter rodado antes.
--
-- Idempotente: pode rodar de novo sem efeito.

-- 1. A regra do produto (lib/shared/utils/validators.dart: usernamePattern):
--    3 a 20 caracteres de A-Z, a-z, 0-9, "." e "_". Nulo continua aceito só
--    para perfis antigos, criados antes de o nome de usuário ser obrigatório.
alter table profiles drop constraint if exists profiles_username_format;
alter table profiles add constraint profiles_username_format
  check (username is null or username ~ '^[A-Za-z0-9._]{3,20}$');

-- 2. Disponibilidade: só sim/não, nunca dados de perfil. Quem está logado não
--    conta a si mesmo ("Minha conta" pode manter o próprio nome, em qualquer
--    caixa). Sem login (cadastro), auth.uid() é nulo e ninguém é excluído.
create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select not exists (
    select 1
    from profiles
    where username is not null
      and lower(btrim(username)) = lower(btrim(p_username))
      and (auth.uid() is null or id <> auth.uid())
  );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text)
  to anon, authenticated;

-- 3. A conta e o perfil (nome + nome de usuário) na MESMA transação. O app
--    manda os dois em raw_user_meta_data no signUp. Se o nome já foi pego
--    (alguém o gravou entre a checagem e o cadastro), o índice único recusa o
--    insert, o erro sobe e o Supabase Auth desfaz a criação da conta: nada
--    fica pela metade, o e-mail continua livre e a pessoa só escolhe outro.
--    Sem nome de usuário nos metadados (a versão do app já publicada), não faz
--    nada e o app cria o perfil como sempre fez.
create or replace function public.claim_username_on_signup()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_username text := nullif(btrim(new.raw_user_meta_data ->> 'username'), '');
begin
  if v_username is null then
    return new;
  end if;
  insert into public.profiles (id, name, username)
  values (
    new.id,
    coalesce(btrim(new.raw_user_meta_data ->> 'name'), ''),
    v_username
  );
  return new;
end;
$$;

revoke all on function public.claim_username_on_signup() from public;

drop trigger if exists on_auth_user_created_claim_username on auth.users;
create trigger on_auth_user_created_claim_username
  after insert on auth.users
  for each row execute function public.claim_username_on_signup();
