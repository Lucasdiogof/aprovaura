// Orquestração: percorre os provedores elegíveis na ordem do plano (vem do banco), cada um no máximo
// uma vez (sem loop de fallback), respeitando um prazo global. O primeiro resultado VÁLIDO encerra: nada
// de chamada duplicada. Nenhum texto de redação ou resposta passa por log/relatório daqui.
import { Evaluation, FailReason, Locale, looksLikeInjection, ProviderError, validateEvaluation } from './contract.ts';
import type { Adapter, ProviderName } from './providers.ts';

export type PlanItem = { provider: ProviderName; model: string; timeout_ms: number };
export type Outcome = {
  ok: boolean; reason?: FailReason; latencyMs: number; cost: number; fallback: boolean; retryAfter?: number;
};
export type Deps = {
  adapters: Record<ProviderName, Adapter>;
  report: (provider: ProviderName, o: Outcome) => Promise<void>;
  now?: () => number;
  fetchFn?: typeof fetch;
};
export type RunResult =
  | { ok: true; evaluation: Evaluation; provider: ProviderName; model: string; attempts: number }
  | { ok: false; reason: FailReason; attempts: number };

/** Prazo global da solicitação e sobra mínima para valer a pena iniciar outra chamada. */
export const TOTAL_DEADLINE_MS = 100_000;
const MIN_REMAINING_MS = 8_000;
const RETRYABLE: FailReason[] = ['invalid_output', 'provider_unavailable', 'timeout'];

export async function runCorrection(
  plan: PlanItem[], input: { system: string; user: string; locale: Locale }, deps: Deps,
  deadlineMs = TOTAL_DEADLINE_MS,
): Promise<RunResult> {
  const now = deps.now ?? Date.now;
  const start = now();
  let attempts = 0;
  let last: FailReason = 'unexpected';
  let failedBefore = false;

  async function attempt(item: PlanItem): Promise<RunResult | null> {
    const remaining = deadlineMs - (now() - start);
    if (remaining < MIN_REMAINING_MS) return null;
    attempts++;
    const t0 = now();
    try {
      const { raw, cost } = await deps.adapters[item.provider](
        { model: item.model, system: input.system, user: input.user, timeoutMs: Math.min(item.timeout_ms, remaining) },
        deps.fetchFn,
      );
      const evaluation = validateEvaluation(raw, input.locale, { injection: looksLikeInjection(input.user) });
      await deps.report(item.provider, { ok: true, latencyMs: now() - t0, cost, fallback: failedBefore }).catch(() => {});
      return { ok: true, evaluation, provider: item.provider, model: item.model, attempts };
    } catch (e) {
      const err = e instanceof ProviderError ? e : new ProviderError('unexpected');
      last = err.reason;
      failedBefore = true;
      await deps.report(item.provider, {
        ok: false, reason: err.reason, latencyMs: now() - t0, cost: 0, fallback: false, retryAfter: err.retryAfterSec,
      }).catch(() => {});
      return null;
    }
  }

  for (const item of plan) {
    const r = await attempt(item);
    if (r) return r;
  }
  // Retry controlado: só quando há UM provedor no plano e a falha foi transitória/de forma.
  if (plan.length === 1 && attempts === 1 && RETRYABLE.includes(last)) {
    const r = await attempt(plan[0]);
    if (r) return r;
  }
  return { ok: false, reason: last, attempts };
}
