-- Google Play Billing: homologação restrita a usuários autorizados + conciliação de assinaturas em retenção.
-- Compra nativa só é liberada para todos quando o provedor está habilitado em PRODUÇÃO; o ambiente sandbox
-- (homologação) vale apenas para quem está em payment_test_users. Nada aqui liga a monetização.
create table if not exists payment_test_users (
  user_id uuid primary key references auth.users (id) on delete cascade,
  note text,
  created_at timestamptz not null default now()
);
alter table payment_test_users enable row level security; -- sem policies: só service role / funções definer

create or replace function payment_provider_allowed(p_uid uuid, p_provider text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from payment_providers_config c
    where c.provider = p_provider and c.enabled
      and (c.environment = 'production'
           or (p_uid is not null and exists (select 1 from payment_test_users t where t.user_id = p_uid))));
$$;
revoke all on function payment_provider_allowed(uuid, text) from public, anon, authenticated;

create or replace function get_purchase_config() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'enabled', coalesce((select jsonb_object_agg(provider, e) from (
        select provider, case when provider = 'mercadopago' then bool_or(enabled)
                              else payment_provider_allowed(auth.uid(), provider) end e
        from payment_providers_config group by provider) t), '{}'::jsonb),
    'catalog', coalesce((select jsonb_agg(jsonb_build_object('plan', plan, 'provider', provider,
        'product_id', external_product_id, 'base_plan_id', base_plan_id, 'reference_price_cents', price_cents))
        from payment_catalog where active and environment = 'production'), '[]'::jsonb));
$$;

create or replace function get_purchase_account_token() returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_uid uuid := auth.uid(); v_t uuid;
begin
  if v_uid is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if must_verify_email(v_uid) then
    raise sqlstate 'PT403' using message = 'email_unverified', hint = 'Confirm your e-mail first.';
  end if;
  if not (payment_provider_allowed(v_uid, 'google') or payment_provider_allowed(v_uid, 'apple')) then
    raise sqlstate 'PT403' using message = 'purchases_disabled', hint = 'Purchases are not enabled for this account.';
  end if;
  insert into purchase_account_tokens (user_id) values (v_uid) on conflict (user_id) do nothing;
  select token into v_t from purchase_account_tokens where user_id = v_uid;
  return v_t;
end $$;

-- Conciliação: Google em retenção/pausa (expired) por até 60 dias continua sendo relido (permite recuperação).
create or replace function service_subscriptions_to_check(p_limit integer default 50) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from (
    select id, provider, environment, original_ref, user_id, plan, state, period_end from provider_subscriptions
    where (provider <> 'mercadopago' or original_ref not like 'pix:%')
      and (state in ('pending', 'active', 'grace', 'canceled')
           or (provider = 'google' and state = 'expired' and period_end > now() - interval '60 days'))
      and (last_checked_at is null or last_checked_at < now() - interval '12 hours')
      and (period_end is null or period_end < now() + interval '2 days')
    order by last_checked_at nulls first limit least(greatest(p_limit, 1), 200)) s;
$$;
notify pgrst, 'reload schema';
