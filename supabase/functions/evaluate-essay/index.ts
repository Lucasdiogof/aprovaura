// Correção de redação: lê a submission, corrige com o primeiro provedor de IA gratuito disponível (com
// fallback automático para o seguinte) e grava o resultado. Tudo que decide (posse, cota, idempotência,
// nota, Aura) mora nas RPCs do essays.sql -- esta função só orquestra.
//
// SEGURANÇA
// - O usuário NUNCA vem do body: sai do JWT via auth.getUser(). Chamadas de redação usam o client "como o
//   chamador" (nunca a service key); a service key só lê/grava a configuração e o consumo dos provedores
//   (essay_ai_plan / essay_ai_report), que não contêm dados de aluno.
// - Chaves dos provedores só existem nos Secrets desta função. Nunca chegam ao app, ao banco ou a logs.
//
// PRIVACIDADE
// O prompt leva SÓ tema, proposta, textos motivadores e a redação: sem nome, e-mail, user_id ou
// submission_id. Redação e resposta do provedor não são logadas; o log guarda só o código do motivo.
//
// CUSTO ZERO
// Só franquias gratuitas, com tetos internos por provedor (banco). Sem fallback pago, sem upgrade.
// Esgotadas as franquias, a função recusa ANTES de debitar cota; a redação nunca se perde.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';
import { publishableKey, secretKey } from '../_shared/keys.ts';
import { resolveEssayProvider } from '../_shared/essay_provider.ts';
import { buildMessages, type EssayInput, parseLocale, PROMPT_VERSION } from '../_shared/essay_ai/contract.ts';
import { ADAPTERS, hasCredentials, type ProviderName } from '../_shared/essay_ai/providers.ts';
import { type PlanItem, runCorrection } from '../_shared/essay_ai/orchestrator.ts';

type StartRow = EssayInput & { word_count: number };

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
}

/** Códigos de erro do start_essay_evaluation (essays.sql, 4.1) traduzidos para o app. */
function startFailureReason(code: string | undefined): string {
  switch (code) {
    case 'P0002': return 'not_found';
    case 'P0004': return 'already_evaluated';
    case 'P0005': return 'already_evaluating';
    case 'P0006': return 'daily_limit_reached';
    case '23505': return 'already_evaluating'; // uma correção em voo por usuário
    default: return 'unexpected';
  }
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method not allowed' }, 405);
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'missing authorization header' }, 401);

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  // Autenticação PRIMEIRO (verify_jwt do gateway está desligado por causa do ES256).
  const caller = createClient(supabaseUrl, publishableKey(), { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userError } = await caller.auth.getUser();
  if (userError || !userData?.user) return json({ error: 'invalid session' }, 401);

  // Interruptor global: suspende toda correção externa antes de qualquer cota ou envio.
  if (resolveEssayProvider(Deno.env.get('ESSAY_AI_PROVIDER')) === 'suspended') {
    return json({ error: 'provider suspended', reason: 'not_configured' }, 503);
  }

  let submissionId: string | undefined;
  let locale = parseLocale(undefined);
  try {
    const body = await req.json();
    submissionId = body?.submission_id;
    locale = parseLocale(body?.locale); // app antigo não manda: português
  } catch (_) {
    return json({ error: 'invalid body' }, 400);
  }
  if (typeof submissionId !== 'string' || !submissionId) return json({ error: 'missing submission_id' }, 400);

  // Plano de provedores (config + breaker + franquia, tudo no banco). Antes de debitar qualquer cota:
  // sem provedor disponível a submission nem é tocada.
  const admin = createClient(supabaseUrl, secretKey(), { auth: { persistSession: false } });
  const { data: planData, error: planError } = await admin.rpc('essay_ai_plan');
  if (planError) {
    console.error('evaluate-essay plan failed');
    return json({ error: 'temporarily unavailable', reason: 'provider_unavailable' }, 503);
  }
  const plan = ((planData ?? []) as PlanItem[]).filter((p) => hasCredentials(p.provider));
  if (plan.length === 0) {
    const configured = (['groq', 'cloudflare', 'google'] as const).some(hasCredentials);
    return json({ error: 'no provider available', reason: configured ? 'provider_unavailable' : 'not_configured' }, 503);
  }

  // Reivindica a submission: posse, estado e cota são conferidos aqui, ANTES de qualquer chamada externa.
  const { data: startData, error: startError } = await caller.rpc('start_essay_evaluation', {
    p_submission_id: submissionId,
  });
  if (startError) {
    const reason = startFailureReason(startError.code);
    return json({ error: 'cannot start evaluation', reason }, reason === 'not_found' ? 404 : 409);
  }
  const row = (Array.isArray(startData) ? startData[0] : startData) as StartRow | undefined;
  if (!row) {
    await caller.rpc('fail_essay_evaluation', { p_submission_id: submissionId, p_reason: 'unexpected' });
    return json({ error: 'submission unavailable', reason: 'unexpected' }, 500);
  }

  const result = await runCorrection(plan, { ...buildMessages(row, locale), locale }, {
    adapters: ADAPTERS,
    report: async (provider: ProviderName, o) => {
      await admin.rpc('essay_ai_report', {
        p_provider: provider, p_ok: o.ok, p_reason: o.reason ?? null, p_latency_ms: o.latencyMs,
        p_cost: o.cost, p_fallback: o.fallback, p_retry_after: o.retryAfter ?? null,
      });
    },
  });

  let lastReason = 'unexpected';
  if (result.ok) {
    const { data: completed, error: completeError } = await caller.rpc('complete_essay_evaluation', {
      p_submission_id: submissionId,
      p_result: result.evaluation.payload,
      p_provider: result.provider,
      p_model: result.model,
      p_prompt_version: PROMPT_VERSION,
    });
    if (!completeError) {
      const r = Array.isArray(completed) ? completed[0] : completed;
      return json({ status: 'evaluated', total_score: r?.total_score ?? null });
    }
  } else {
    lastReason = result.reason;
  }

  // Falha total: submission volta a 'failed' (o banco devolve o débito da cota), texto intacto.
  await caller.rpc('fail_essay_evaluation', { p_submission_id: submissionId, p_reason: lastReason });
  console.error(`evaluate-essay failed: ${lastReason}`);
  // Para o app o motivo é sempre o mesmo (mensagem única e amigável); o detalhe fica no banco/admin.
  return json({ status: 'failed', reason: 'provider_unavailable' }, 502);
});
