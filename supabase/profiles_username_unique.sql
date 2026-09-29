-- Nome de usuário único (sem diferenciar maiúsculas) e checagem de
-- disponibilidade para o cadastro.
--
-- O cadastro valida o nome de usuário em tempo real, antes de a pessoa ter
-- sessão: a RLS de `profiles` só deixa cada um ler o próprio perfil, então a
-- tela não consegue ver os nomes dos outros. `is_username_available` responde
-- só sim/não, sem expor nenhum dado do perfil, e pode ser chamada sem login.
--
-- O índice único é a garantia de verdade: duas pessoas que testarem o mesmo
-- nome ao mesmo tempo não conseguem as duas gravá-lo.
--
-- Idempotente: pode rodar de novo sem efeito.

create unique index if not exists profiles_username_lower_key
  on profiles (lower(btrim(username)))
  where username is not null and btrim(username) <> '';

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
  );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text)
  to anon, authenticated;
