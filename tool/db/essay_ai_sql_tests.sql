-- Testes SQL da correção de redação multi-provedor (circuit breaker, franquias, cota, admin).
-- Rodar num Postgres DESCARTÁVEL com as migrações aplicadas (tool/db/empty_db_check.sh, KEEP=1):
--   docker exec -i aura-empty-check psql -U postgres -v ON_ERROR_STOP=1 -q < tool/db/essay_ai_sql_tests.sql
-- Tudo roda numa transação revertida no fim. Texto sintético; nenhum dado real.
begin;

create or replace function _t(p_name text, p_ok boolean) returns void language plpgsql as $$
begin
  if not p_ok then raise exception 'FALHOU: %', p_name; end if;
  raise notice 'ok   %', p_name;
end $$;
create or replace function _plan() returns text language sql as $$
  select coalesce(string_agg(provider, ',' order by ord), '') from (select provider, row_number() over () ord from essay_ai_plan()) x $$;

-- 1. Tudo nasce desligado
select _t('nasce tudo desligado: plano vazio', _plan() = '');

-- 2. Ordem e desligamento individual
update essay_ai_providers set enabled = true where provider in ('groq', 'cloudflare');
select _t('plano A=groq, B=cloudflare', _plan() = 'groq,cloudflare');
update essay_ai_providers set priority = 1 where provider = 'cloudflare';
update essay_ai_providers set priority = 2 where provider = 'groq';
select _t('prioridade invertida sem deploy', _plan() = 'cloudflare,groq');
update essay_ai_providers set priority = 1 where provider = 'groq';
update essay_ai_providers set priority = 2 where provider = 'cloudflare';
update essay_ai_providers set enabled = false where provider = 'groq';
select _t('desligar um provedor individualmente', _plan() = 'cloudflare');
update essay_ai_providers set enabled = true where provider = 'groq';

-- 3. Circuit breaker: abre no limite, fica fora do plano, meia-abertura e recuperação
select essay_ai_report('groq', false, 'provider_unavailable', 100, 0);
select essay_ai_report('groq', false, 'provider_unavailable', 100, 0);
select _t('2 falhas não abrem o breaker', _plan() = 'groq,cloudflare');
select essay_ai_report('groq', false, 'provider_unavailable', 100, 0);
select _t('3ª falha abre: plano vai direto ao B', _plan() = 'cloudflare');
select _t('breaker open no admin', (select open_until > now() from essay_ai_providers where provider = 'groq'));
update essay_ai_providers set open_until = now() - interval '1 second' where provider = 'groq';
select _t('período de recuperação vencido: A volta ao plano (sonda)', _plan() = 'groq,cloudflare');
select essay_ai_report('groq', true, null, 800, 4000, false);
select _t('sucesso fecha o breaker', (select open_until is null and consecutive_failures = 0 from essay_ai_providers where provider = 'groq'));
select _t('último erro guardado só como código', (select last_error = 'provider_unavailable' from essay_ai_providers where provider = 'groq'));

-- 4. Falha de conteúdo não abre o breaker (texto malicioso não derruba o provedor)
select essay_ai_report('groq', false, 'invalid_output', 50, 0) from generate_series(1, 6);
select _t('invalid_output nunca abre o breaker', _plan() = 'groq,cloudflare');

-- 5. 429 e Retry-After
select essay_ai_report('groq', false, 'rate_limited', 50, 0, false, 90);
select _t('429 coloca A em cooldown', _plan() = 'cloudflare');
select _t('cooldown respeita Retry-After (~90 s)',
  (select cooldown_until between now() + interval '80 seconds' and now() + interval '100 seconds'
   from essay_ai_providers where provider = 'groq'));
select essay_ai_report('cloudflare', false, 'rate_limited', 50, 0, false, 999999);
select _t('Retry-After absurdo é limitado a 1 h',
  (select cooldown_until <= now() + interval '3601 seconds' from essay_ai_providers where provider = 'cloudflare'));
select _t('ambos em cooldown: plano vazio (correções interrompidas)', _plan() = '');
update essay_ai_providers set cooldown_until = null;
select _t('cooldown vencido: retorno automático', _plan() = 'groq,cloudflare');

-- 6. Auth / modelo descontinuado: espera longa
select essay_ai_report('cloudflare', false, 'auth', 10, 0);
select _t('falha de autenticação abre breaker por ~1 h',
  (select open_until > now() + interval '59 minutes' from essay_ai_providers where provider = 'cloudflare'));
update essay_ai_providers set open_until = null, consecutive_failures = 0;

-- 7. Franquia interna (tokens) e limite de requisições
select essay_ai_report('groq', true, null, 500, 175000, false);
select _t('abaixo do teto ainda elegível', _plan() = 'groq,cloudflare');
select essay_ai_report('groq', true, null, 500, 6000, false);
select _t('teto diário de tokens esgotado tira o A do plano', _plan() = 'cloudflare');
select _t('consumo estimado acumulado', (select cost_used = 185000 from essay_ai_usage where provider = 'groq' and day = _essay_ai_day('UTC')));
update essay_ai_providers set daily_request_limit = 1 where provider = 'cloudflare';
select essay_ai_report('cloudflare', true, null, 700, 300, true);
select _t('limite de requisições esgota o B: plano vazio', _plan() = '');
select _t('fallback contabilizado', (select fallbacks = 1 and successes = 1 from essay_ai_usage where provider = 'cloudflare'));

-- 8. Falha total devolve a cota diária
insert into auth.users (id, email, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000a1', 'aluno-sintetico@example.test', now()),
  ('00000000-0000-0000-0000-0000000000ad', 'admin-sintetico@example.test', now());
insert into essay_themes (id, title, prompt) values ('00000000-0000-0000-0000-0000000000b1', 'Tema sintético', 'Proposta sintética');
insert into essay_submissions (id, user_id, theme_id, body, word_count) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000b1', 'texto sintético', 3),
  ('00000000-0000-0000-0000-0000000000c2', '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000b1', 'texto sintético 2', 3);
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-0000000000a1', true);
select count(*) from start_essay_evaluation('00000000-0000-0000-0000-0000000000c1');
select _t('início debita a cota', (select used = 1 from get_essay_quota()));
select fail_essay_evaluation('00000000-0000-0000-0000-0000000000c1', 'provider_unavailable');
select _t('falha dos dois provedores NÃO consome a cota', (select used = 0 from get_essay_quota()));
select _t('redação preservada em failed',
  (select status = 'failed' and body = 'texto sintético' from essay_submissions where id = '00000000-0000-0000-0000-0000000000c1'));
select count(*) from start_essay_evaluation('00000000-0000-0000-0000-0000000000c1');
select _t('retentativa debita uma vez', (select used = 1 from get_essay_quota()));
-- correção presa (stale) enterrada pelo start: também devolve a cota e a retentativa debita de novo
update essay_submissions set evaluation_started_at = now() - interval '1 day' where id = '00000000-0000-0000-0000-0000000000c1';
select count(*) from start_essay_evaluation('00000000-0000-0000-0000-0000000000c1');
select _t('correção presa não gera débito duplo', (select used = 1 from get_essay_quota()));
-- concluída pelo Plano B conta UMA correção
select complete_essay_evaluation('00000000-0000-0000-0000-0000000000c1',
  '{"c1":{"score":120},"c2":{"score":120},"c3":{"score":120},"c4":{"score":120},"c5":{"score":120},"competencies":[],"general_feedback":"ok"}'::jsonb,
  'cloudflare', '@cf/meta/llama-3.3-70b-instruct-fp8-fast', 'essay-enem-v3');
select _t('fallback concluído = 1 correção no limite', (select used = 1 from get_essay_quota()));
select _t('provider/model gravados na avaliação', (select provider = 'cloudflare' from essay_evaluations where submission_id = '00000000-0000-0000-0000-0000000000c1'));
select _t('duplicata não regrava nem recobra',
  (select total_score = 600 from complete_essay_evaluation('00000000-0000-0000-0000-0000000000c1', '{"c1":{"score":0},"c2":{"score":0},"c3":{"score":0},"c4":{"score":0},"c5":{"score":0}}'::jsonb, 'groq', 'x', 'v')));

-- 8b. Três correções diárias compartilhadas, concorrência e duplicidade
insert into essay_submissions (id, user_id, theme_id, body, word_count)
select ('00000000-0000-0000-0000-0000000000d' || i)::uuid, '00000000-0000-0000-0000-0000000000a1',
       '00000000-0000-0000-0000-0000000000b1', 'texto sintético ' || i, 3 from generate_series(3, 5) i;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-0000000000a1', true);
select count(*) from start_essay_evaluation('00000000-0000-0000-0000-0000000000c2');
do $$ begin
  begin perform start_essay_evaluation('00000000-0000-0000-0000-0000000000c2'); raise exception 'duplicata aceita';
  exception when sqlstate 'P0005' then raise notice 'ok   requisição duplicada recusada (já em correção)'; end;
  begin perform start_essay_evaluation('00000000-0000-0000-0000-0000000000d3'); raise exception 'concorrente aceita';
  exception when unique_violation then raise notice 'ok   requisição simultânea recusada (uma em voo por usuário)'; end;
end $$;
select complete_essay_evaluation('00000000-0000-0000-0000-0000000000c2',
  '{"c1":{"score":80},"c2":{"score":80},"c3":{"score":80},"c4":{"score":80},"c5":{"score":80},"competencies":[],"general_feedback":"ok"}'::jsonb,
  'groq', 'openai/gpt-oss-120b', 'essay-enem-v3');
select count(*) from start_essay_evaluation('00000000-0000-0000-0000-0000000000d3');
select complete_essay_evaluation('00000000-0000-0000-0000-0000000000d3',
  '{"c1":{"score":80},"c2":{"score":80},"c3":{"score":80},"c4":{"score":80},"c5":{"score":80},"competencies":[],"general_feedback":"ok"}'::jsonb,
  'cloudflare', '@cf/meta/llama-3.3-70b-instruct-fp8-fast', 'essay-enem-v3');
select _t('três correções (A, B e A de novo) = limite diário atingido', (select used = 3 and total = 3 from get_essay_quota()));
do $$ begin
  begin perform start_essay_evaluation('00000000-0000-0000-0000-0000000000d4'); raise exception 'quarta aceita';
  exception when sqlstate 'P0006' then raise notice 'ok   4ª correção do dia recusada, sem chamar provedor'; end;
end $$;
select _t('recusa por limite não deixa débito', (select used = 3 from get_essay_quota()));

-- 9. Administração: só admin; ajustes auditados
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-0000000000a1', true);
do $$ begin
  begin perform admin_essay_ai_overview(); raise exception 'aluno leu o painel';
  exception when sqlstate '42501' then raise notice 'ok   aluno comum não acessa o painel'; end;
  begin perform admin_essay_ai_set('groq', '{"enabled":false}'); raise exception 'aluno alterou';
  exception when sqlstate '42501' then raise notice 'ok   aluno comum não altera provedores'; end;
end $$;
select owner_attest_email('00000000-0000-0000-0000-0000000000ad', 'teste');
select bootstrap_first_admin('00000000-0000-0000-0000-0000000000ad');
select _t('admin reconhecido', is_admin('00000000-0000-0000-0000-0000000000ad'));
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-0000000000ad', true);
select admin_essay_ai_set_order(array['cloudflare', 'groq', 'google'], 'teste de inversão');
select _t('admin inverte a ordem', (select priority = 1 from essay_ai_providers where provider = 'cloudflare'));
select admin_essay_ai_set('groq', '{"enabled":false,"reset_breaker":true}', 'desligar');
select _t('admin desliga provedor', (select not enabled from essay_ai_providers where provider = 'groq'));
select _t('alterações auditadas', (select count(*) = 2 from admin_audit_log where target_type = 'essay_ai_provider'));
select _t('overview traz estado, modelo, consumo e último erro',
  (select jsonb_array_length(o -> 'providers') = 3
     and o -> 'providers' -> 0 ? 'breaker' and o -> 'providers' -> 0 ? 'today' and o -> 'providers' -> 0 ? 'last_error'
     and o -> 'providers' -> 0 ? 'model' and o -> 'providers' -> 0 ? 'last_success_at'
   from (select admin_essay_ai_overview() o) x));
do $$ begin
  begin perform admin_essay_ai_set('groq', '{"api_key":"x"}'); raise exception 'campo desconhecido aceito';
  exception when sqlstate 'P0030' then raise notice 'ok   campo desconhecido recusado'; end;
end $$;

-- 10. Funções de serviço não são chamáveis por aluno/anônimo
select _t('essay_ai_plan/report fechadas ao app',
  not has_function_privilege('authenticated', 'essay_ai_plan()', 'execute')
  and not has_function_privilege('anon', 'essay_ai_plan()', 'execute')
  and has_function_privilege('service_role', 'essay_ai_plan()', 'execute')
  and not has_function_privilege('authenticated', 'essay_ai_report(text,boolean,text,integer,bigint,boolean,integer)', 'execute'));

rollback;
