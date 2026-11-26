-- Correção de redação com múltiplos provedores gratuitos e fallback automático.
-- Configuração, circuit breaker e consumo vivem no banco: o dono inverte a prioridade, liga/desliga
-- provedores e acompanha o consumo SEM publicar nova versão do app nem redeployar a função.
-- Nada aqui guarda texto de redação, resposta do provedor, chave ou identificador de aluno.
-- Rollback: supabase/rollbacks/20261207000100_essay_ai_providers.down.sql

-- 1. Provedores ------------------------------------------------------------------------------------
create table if not exists essay_ai_providers (
  provider text primary key check (provider in ('google', 'groq', 'cloudflare')),
  enabled boolean not null default false,            -- tudo nasce DESLIGADO: ativar é decisão do dono
  priority integer not null default 100,             -- menor = mais prioritário (Plano A)
  model text not null,
  timeout_ms integer not null default 40000 check (timeout_ms between 5000 and 90000),
  budget_unit text not null check (budget_unit in ('tokens', 'neurons', 'requests')),
  daily_budget bigint not null check (daily_budget >= 0),           -- teto interno (< franquia gratuita)
  daily_request_limit integer not null check (daily_request_limit >= 0),
  reset_tz text not null default 'UTC',              -- fuso em que a franquia do provedor zera
  breaker_threshold integer not null default 3 check (breaker_threshold between 1 and 20),
  recovery_seconds integer not null default 300 check (recovery_seconds between 30 and 86400),
  consecutive_failures integer not null default 0,
  open_until timestamptz,                            -- breaker aberto até; passado = meia-abertura (sonda)
  cooldown_until timestamptz,                        -- 429 / Retry-After / franquia esgotada
  last_error text,                                   -- só o CÓDIGO do motivo
  last_error_at timestamptz,
  last_success_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists essay_ai_usage (
  provider text not null references essay_ai_providers (provider) on delete cascade,
  day date not null,
  requests integer not null default 0,
  successes integer not null default 0,
  failures integer not null default 0,
  fallbacks integer not null default 0,              -- vezes em que este provedor assumiu após falha de outro
  cost_used bigint not null default 0,               -- na unidade do provedor (tokens/neurons/requests)
  latency_ms_total bigint not null default 0,        -- soma das chamadas bem-sucedidas
  primary key (provider, day)
);

alter table essay_ai_providers enable row level security;
alter table essay_ai_usage enable row level security;   -- sem policy: só service_role e funções definer

-- Limites gratuitos: Groq gpt-oss-120b 1.000 req/dia e 200K tokens/dia; Cloudflare Workers AI 10.000
-- neurons/dia (no plano Free, estourar dá ERRO, nunca cobrança); Gemini free depende do painel do projeto.
-- Os tetos abaixo deixam ~10% de margem e podem ser ajustados por admin_essay_ai_set.
insert into essay_ai_providers (provider, enabled, priority, model, budget_unit, daily_budget, daily_request_limit, reset_tz)
values
  ('groq',       false, 1, 'openai/gpt-oss-120b',                     'tokens',   180000, 900,  'UTC'),
  ('cloudflare', false, 2, '@cf/meta/llama-3.3-70b-instruct-fp8-fast', 'neurons',  9000,   2000, 'UTC'),
  ('google',     false, 3, 'gemini-3.8-flash',                        'requests', 200,    200,  'America/Los_Angeles')
on conflict (provider) do nothing;

-- 2. Funções do orquestrador (somente service_role) ---------------------------------------------------
create or replace function _essay_ai_day(p_tz text) returns date
language sql stable as $$ select (now() at time zone p_tz)::date $$;

-- Provedores elegíveis AGORA, na ordem de prioridade: ligado, breaker fechado (ou em meia-abertura),
-- sem cooldown e com franquia interna sobrando. Nenhum fallback depende de falha conhecida: provedor
-- com breaker aberto nem entra na lista.
create or replace function essay_ai_plan()
returns table (provider text, model text, timeout_ms integer, budget_left bigint)
language sql stable security definer set search_path = public, pg_temp as $$
  select p.provider, p.model, p.timeout_ms,
         p.daily_budget - coalesce(u.cost_used, 0)
  from essay_ai_providers p
  left join essay_ai_usage u on u.provider = p.provider and u.day = _essay_ai_day(p.reset_tz)
  where p.enabled
    and (p.open_until is null or p.open_until <= now())
    and (p.cooldown_until is null or p.cooldown_until <= now())
    and coalesce(u.requests, 0) < p.daily_request_limit
    and coalesce(u.cost_used, 0) < p.daily_budget
  order by p.priority, p.provider;
$$;

-- Registra o desfecho de UMA chamada ao provedor. Falhas de conteúdo (invalid_output) contam nas
-- estatísticas mas não abrem o breaker: um texto malicioso não pode derrubar o provedor para todos.
create or replace function essay_ai_report(
  p_provider text, p_ok boolean, p_reason text, p_latency_ms integer, p_cost bigint,
  p_fallback boolean default false, p_retry_after integer default null
) returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v essay_ai_providers%rowtype; v_day date; v_fail integer; v_secs integer;
begin
  select * into v from essay_ai_providers p where p.provider = p_provider for update;
  if not found then return; end if;
  v_day := _essay_ai_day(v.reset_tz);
  insert into essay_ai_usage (provider, day) values (p_provider, v_day) on conflict do nothing;
  update essay_ai_usage set
    requests = requests + 1,
    successes = successes + (p_ok)::int,
    failures = failures + (not p_ok)::int,
    fallbacks = fallbacks + (p_ok and coalesce(p_fallback, false))::int,
    cost_used = cost_used + greatest(coalesce(p_cost, 0), 0),
    latency_ms_total = latency_ms_total + case when p_ok then greatest(coalesce(p_latency_ms, 0), 0) else 0 end
  where provider = p_provider and day = v_day;

  if p_ok then
    update essay_ai_providers set consecutive_failures = 0, open_until = null, cooldown_until = null,
      last_success_at = now(), updated_at = now() where provider = p_provider;
    return;
  end if;

  v_fail := v.consecutive_failures + (p_reason <> 'invalid_output')::int;
  v_secs := case
    when p_reason in ('auth', 'model_gone') then 3600                      -- chave/modelo: não adianta insistir
    when p_reason in ('rate_limited', 'quota_exhausted') then null
    when v_fail >= v.breaker_threshold and p_reason <> 'invalid_output' then v.recovery_seconds
  end;
  update essay_ai_providers set
    consecutive_failures = v_fail,
    last_error = left(coalesce(p_reason, 'unexpected'), 40), last_error_at = now(),
    open_until = case when v_secs is not null then now() + make_interval(secs => v_secs) else open_until end,
    cooldown_until = case when p_reason in ('rate_limited', 'quota_exhausted')
      then now() + make_interval(secs => least(greatest(coalesce(p_retry_after, 60), 5), 3600)) else cooldown_until end,
    updated_at = now()
  where provider = p_provider;
end $$;

-- 3. Falha total não consome a cota diária ------------------------------------------------------------
-- Qualquer passagem para 'failed' (falha dos dois provedores, timeout, correção presa enterrada pelo
-- start_essay_evaluation) devolve o débito da submission; a retentativa debita de novo ao começar.
create or replace function essay_release_quota_on_failure() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  delete from essay_evaluation_quota where submission_id = new.id;
  return new;
end $$;

drop trigger if exists essay_release_quota_on_failure on essay_submissions;
create trigger essay_release_quota_on_failure
  after update of status on essay_submissions
  for each row when (new.status = 'failed' and old.status is distinct from 'failed')
  execute function essay_release_quota_on_failure();

-- 4. Administração (portal): leitura e ajuste, sempre auditados ----------------------------------------
create or replace function admin_essay_ai_overview() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  perform require_admin();
  return jsonb_build_object(
    'generated_at', now(),
    'providers', coalesce((
      select jsonb_agg(jsonb_build_object(
        'provider', p.provider, 'enabled', p.enabled, 'priority', p.priority, 'model', p.model,
        'role', case when p.enabled and p.rn = 1 then 'primary' when p.enabled then 'secondary' else 'off' end,
        'breaker', case when p.open_until is not null and p.open_until > now() then 'open'
                        when p.open_until is not null then 'half_open' else 'closed' end,
        'open_until', p.open_until, 'cooldown_until', p.cooldown_until,
        'consecutive_failures', p.consecutive_failures,
        'last_error', p.last_error, 'last_error_at', p.last_error_at, 'last_success_at', p.last_success_at,
        'budget_unit', p.budget_unit, 'daily_budget', p.daily_budget, 'daily_request_limit', p.daily_request_limit,
        'timeout_ms', p.timeout_ms, 'breaker_threshold', p.breaker_threshold, 'recovery_seconds', p.recovery_seconds,
        'today', jsonb_build_object('requests', coalesce(t.requests, 0), 'successes', coalesce(t.successes, 0),
          'failures', coalesce(t.failures, 0), 'fallbacks', coalesce(t.fallbacks, 0),
          'cost_used', coalesce(t.cost_used, 0),
          'budget_used_pct', case when p.daily_budget > 0 then round(100.0 * coalesce(t.cost_used, 0) / p.daily_budget, 1) end),
        'last_7_days', jsonb_build_object('successes', coalesce(w.successes, 0), 'failures', coalesce(w.failures, 0),
          'fallbacks', coalesce(w.fallbacks, 0),
          'avg_latency_ms', case when coalesce(w.successes, 0) > 0 then round(w.latency / w.successes) end)
      ) order by p.priority, p.provider)
      from (select e.*, row_number() over (partition by e.enabled order by e.priority, e.provider) rn
            from essay_ai_providers e) p
      left join essay_ai_usage t on t.provider = p.provider and t.day = _essay_ai_day(p.reset_tz)
      left join lateral (
        select sum(u.successes) successes, sum(u.failures) failures, sum(u.fallbacks) fallbacks,
               sum(u.latency_ms_total)::numeric latency
        from essay_ai_usage u where u.provider = p.provider and u.day >= _essay_ai_day(p.reset_tz) - 6
      ) w on true
    ), '[]'::jsonb));
end $$;

-- Campos ajustáveis: enabled, priority, model, timeout_ms, daily_budget, daily_request_limit,
-- breaker_threshold, recovery_seconds; reset_breaker=true limpa o breaker e o cooldown.
create or replace function admin_essay_ai_set(p_provider text, p_patch jsonb, p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb; v_key text;
begin
  perform require_admin();
  if not exists (select 1 from essay_ai_providers where provider = p_provider) then
    raise exception 'provider not found' using errcode = 'P0013';
  end if;
  for v_key in select jsonb_object_keys(p_patch) loop
    if v_key not in ('enabled', 'priority', 'model', 'timeout_ms', 'daily_budget', 'daily_request_limit',
                     'breaker_threshold', 'recovery_seconds', 'reset_breaker') then
      raise exception 'unknown field %', v_key using errcode = 'P0030';
    end if;
  end loop;
  select to_jsonb(p) - 'updated_at' into v_before from essay_ai_providers p where provider = p_provider;
  update essay_ai_providers set
    enabled = coalesce((p_patch ->> 'enabled')::boolean, enabled),
    priority = coalesce((p_patch ->> 'priority')::integer, priority),
    model = coalesce(nullif(btrim(p_patch ->> 'model'), ''), model),
    timeout_ms = coalesce((p_patch ->> 'timeout_ms')::integer, timeout_ms),
    daily_budget = coalesce((p_patch ->> 'daily_budget')::bigint, daily_budget),
    daily_request_limit = coalesce((p_patch ->> 'daily_request_limit')::integer, daily_request_limit),
    breaker_threshold = coalesce((p_patch ->> 'breaker_threshold')::integer, breaker_threshold),
    recovery_seconds = coalesce((p_patch ->> 'recovery_seconds')::integer, recovery_seconds),
    consecutive_failures = case when (p_patch ->> 'reset_breaker')::boolean then 0 else consecutive_failures end,
    open_until = case when (p_patch ->> 'reset_breaker')::boolean then null else open_until end,
    cooldown_until = case when (p_patch ->> 'reset_breaker')::boolean then null else cooldown_until end,
    updated_at = now()
  where provider = p_provider;
  perform audit_event('essay_ai.update', 'essay_ai_provider', p_provider, v_before, p_patch, nullif(btrim(p_note), ''));
end $$;

-- Inverte a ordem de uma vez: admin_essay_ai_set_order('{cloudflare,groq}') => Plano A = cloudflare.
create or replace function admin_essay_ai_set_order(p_order text[], p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb; i integer;
begin
  perform require_admin();
  if array_length(p_order, 1) is null or (select count(distinct x) from unnest(p_order) x) <> array_length(p_order, 1)
     or exists (select 1 from unnest(p_order) x where x not in (select provider from essay_ai_providers)) then
    raise exception 'invalid order' using errcode = 'P0030';
  end if;
  select jsonb_object_agg(provider, priority) into v_before from essay_ai_providers;
  for i in 1 .. array_length(p_order, 1) loop
    update essay_ai_providers set priority = i, updated_at = now() where provider = p_order[i];
  end loop;
  perform audit_event('essay_ai.order', 'essay_ai_provider', 'order', v_before, to_jsonb(p_order), nullif(btrim(p_note), ''));
end $$;

select app_grant_functions(array['essay_ai_plan', 'essay_ai_report'], array['service_role']);
select app_grant_functions(array['admin_essay_ai_overview', 'admin_essay_ai_set', 'admin_essay_ai_set_order'],
                           array['authenticated']);
revoke all on function _essay_ai_day(text) from public, anon, authenticated;
revoke all on function essay_release_quota_on_failure() from public, anon, authenticated;
