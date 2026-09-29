-- Checkup (só leitura) de profiles_username_unique.sql.
select check_name, passed from (
  select 'índice único em lower(username) existe' as check_name,
    exists (
      select 1 from pg_indexes
      where tablename = 'profiles' and indexname = 'profiles_username_lower_key'
    ) as passed
  union all
  select 'is_username_available existe e é security definer',
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'is_username_available'
        and p.prosecdef
    )
  union all
  select 'anon pode executar is_username_available',
    has_function_privilege('anon', 'public.is_username_available(text)', 'execute')
  union all
  select 'nome inexistente aparece como disponível',
    public.is_username_available('__checkup_nome_que_nao_existe__')
  union all
  select 'nenhum nome de usuário duplicado',
    not exists (
      select 1 from profiles
      where username is not null and btrim(username) <> ''
      group by lower(btrim(username)) having count(*) > 1
    )
) c;
