-- Checkup de profiles_username_unique.sql + profiles_username_claim.sql.
--
-- Parte 1 (só leitura): estrutura e permissões.
-- Parte 2 (simulação, TUDO DESFEITO): cria dois usuários de teste em
-- auth.users disputando o mesmo nome, confere o comportamento e termina com
-- um erro proposital que desfaz tudo. O resultado vem na mensagem do erro:
-- "CHECKUP OK ..." ou "CHECKUP FALHOU: ...". Nada fica gravado.

select check_name, passed from (
  select 'índice único em lower(btrim(username))' as check_name,
    exists (
      select 1 from pg_indexes
      where tablename = 'profiles' and indexname = 'profiles_username_lower_key'
        and indexdef ilike '%unique%lower(btrim(username))%'
    ) as passed
  union all
  select 'constraint de formato ^[A-Za-z0-9._]{3,20}$',
    exists (
      select 1 from pg_constraint
      where conname = 'profiles_username_format'
        and pg_get_constraintdef(oid) like '%[A-Za-z0-9._]{3,20}%'
    )
  union all
  select 'is_username_available: security definer que devolve só boolean',
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'is_username_available'
        and p.prosecdef and p.prorettype = 'boolean'::regtype
        and not p.proretset
    )
  union all
  select 'anon e authenticated podem chamar is_username_available',
    has_function_privilege('anon', 'public.is_username_available(text)', 'execute')
    and has_function_privilege('authenticated', 'public.is_username_available(text)', 'execute')
  union all
  select 'anon NÃO lê profiles direto (RLS: cada um só o próprio)',
    (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass)
    and not exists (
      select 1 from pg_policies
      where tablename = 'profiles' and cmd = 'SELECT'
        and (roles @> '{anon}' or qual = 'true')
    )
  union all
  select 'trigger de reserva do nome em auth.users ativo',
    exists (
      select 1 from pg_trigger
      where tgname = 'on_auth_user_created_claim_username'
        and tgrelid = 'auth.users'::regclass and tgenabled = 'O'
    )
  union all
  select 'nenhum nome de usuário duplicado (sem diferenciar caixa)',
    not exists (
      select 1 from profiles
      where username is not null and btrim(username) <> ''
      group by lower(btrim(username)) having count(*) > 1
    )
) c;

do $$
declare
  u1 uuid := gen_random_uuid();
  u2 uuid := gen_random_uuid();
  u3 uuid := gen_random_uuid();
  refused boolean := false;
  bad_format_refused boolean := false;
begin
  -- A cria a conta com Checkup_Race: conta e perfil juntos.
  insert into auth.users (id, email, aud, role, raw_user_meta_data)
  values (u1, 'checkup-a@example.invalid', 'authenticated', 'authenticated',
          '{"name": "A", "username": "Checkup_Race"}');
  if not exists (
    select 1 from public.profiles where id = u1 and username = 'Checkup_Race'
  ) then
    raise exception 'CHECKUP FALHOU: a conta nasceu sem o perfil';
  end if;

  -- B tenta o mesmo nome em outra caixa: o cadastro inteiro é recusado.
  begin
    insert into auth.users (id, email, aud, role, raw_user_meta_data)
    values (u2, 'checkup-b@example.invalid', 'authenticated', 'authenticated',
            '{"name": "B", "username": "checkup_race"}');
  exception when unique_violation then
    refused := true;
  end;
  if not refused then
    raise exception 'CHECKUP FALHOU: nome duplicado aceito';
  end if;
  if exists (select 1 from auth.users where id = u2) then
    raise exception 'CHECKUP FALHOU: a conta de B ficou criada sem perfil';
  end if;

  -- Formato inválido também é recusado pelo banco.
  begin
    insert into auth.users (id, email, aud, role, raw_user_meta_data)
    values (u3, 'checkup-c@example.invalid', 'authenticated', 'authenticated',
            '{"name": "C", "username": "com espaço"}');
  exception when check_violation then
    bad_format_refused := true;
  end;
  if not bad_format_refused then
    raise exception 'CHECKUP FALHOU: formato inválido aceito';
  end if;

  -- Disponibilidade: para o dono (logado como A), o próprio nome em outra
  -- caixa está livre; para outra pessoa e para anon, está ocupado.
  perform set_config('request.jwt.claims', json_build_object('sub', u1)::text, true);
  if not public.is_username_available('CHECKUP_RACE') then
    raise exception 'CHECKUP FALHOU: o dono não pode manter o próprio nome';
  end if;
  perform set_config('request.jwt.claims', json_build_object('sub', gen_random_uuid())::text, true);
  if public.is_username_available('checkup_race') then
    raise exception 'CHECKUP FALHOU: nome de outro aparece livre';
  end if;
  perform set_config('request.jwt.claims', '', true);
  if public.is_username_available('checkup_race') then
    raise exception 'CHECKUP FALHOU: nome ocupado aparece livre sem login';
  end if;

  raise exception 'CHECKUP OK: conta+perfil atômicos, duplicado recusado sem deixar conta, formato validado, dono mantém o nome (tudo desfeito)';
end $$;
