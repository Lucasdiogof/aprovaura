// Homologação do fallback com chamadas REAIS (redação sintética curta; nada de aluno).
// Provoca falhas reais do Plano A (modelo inexistente -> 404, chave inválida -> 401) e confirma que o
// Plano B conclui; depois derruba os dois. Os relatórios de uso vão para $OUT (JSON) para alimentar o
// teste do breaker no Postgres descartável. As chaves vêm do ambiente e nunca são impressas.
//   deno run --allow-env --allow-net --allow-write tool/qa/essay_ai_fallback_real.ts
import { buildMessages } from '../../supabase/functions/_shared/essay_ai/contract.ts';
import { runCorrection, type Outcome, type PlanItem } from '../../supabase/functions/_shared/essay_ai/orchestrator.ts';
import { ADAPTERS, type ProviderName } from '../../supabase/functions/_shared/essay_ai/providers.ts';

const GROQ_KEY = Deno.env.get('GROQ_API_KEY')!;
const OUT = Deno.env.get('OUT') ?? 'fallback_real.json';
const GOOD_A = 'openai/gpt-oss-120b';
const GOOD_B = '@cf/meta/llama-3.3-70b-instruct-fp8-fast';
const m = buildMessages({
  theme_title: 'Desafios para valorizar o trabalho de cuidado doméstico no Brasil',
  theme_prompt: 'Redija texto dissertativo-argumentativo sobre o tema, com proposta de intervenção.',
  supporting_texts: [],
  body: 'O trabalho de cuidado em casa é importante, mas pouco valorizado. As mulheres realizam a maior parte das tarefas, o que limita o tempo para estudo e trabalho. O governo deveria ampliar creches e as escolas deveriam ensinar a divisão igualitária das tarefas, para que o cuidado seja uma responsabilidade de todos.',
}, 'pt-BR');
const reports: Array<{ scenario: string; provider: ProviderName; o: Outcome }> = [];
const results: Record<string, unknown> = {};

async function scenario(name: string, plan: PlanItem[]) {
  const t0 = Date.now();
  const r = await runCorrection(plan, { ...m, locale: 'pt-BR' }, {
    adapters: ADAPTERS,
    report: (provider, o) => { reports.push({ scenario: name, provider, o }); return Promise.resolve(); },
  });
  const row = r.ok
    ? { ok: true, provider: r.provider, model: r.model, attempts: r.attempts, total: r.evaluation.total, ms: Date.now() - t0 }
    : { ok: false, reason: r.reason, attempts: r.attempts, ms: Date.now() - t0 };
  results[name] = row;
  console.log(name, JSON.stringify(row));
}
const A = (model: string, t = 40_000): PlanItem => ({ provider: 'groq', model, timeout_ms: t });
const B = (model: string, t = 40_000): PlanItem => ({ provider: 'cloudflare', model, timeout_ms: t });

await scenario('1_A_ok_sem_fallback', [A(GOOD_A), B(GOOD_B)]);
await scenario('2_A_modelo_inexistente_B_conclui', [A('openai/modelo-inexistente'), B(GOOD_B)]);
Deno.env.set('GROQ_API_KEY', 'gsk_invalida_homologacao');
await scenario('3_A_chave_invalida_B_conclui', [A(GOOD_A), B(GOOD_B)]);
Deno.env.set('GROQ_API_KEY', GROQ_KEY);
await scenario('4_A_timeout_B_conclui', [A(GOOD_A, 50), B(GOOD_B)]);
await scenario('5_ordem_invertida_B_primeiro', [B(GOOD_B), A(GOOD_A)]);
await scenario('6_ambos_falham_sem_loop', [A('openai/modelo-inexistente'), B('@cf/modelo/inexistente')]);

Deno.writeTextFileSync(OUT, JSON.stringify({ results, reports }, null, 1));
console.log('relatórios:', reports.length, '->', OUT);
