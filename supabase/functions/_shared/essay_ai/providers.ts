// Adaptadores dos provedores. Todos recebem o MESMO contrato (system/user + RESPONSE_SCHEMA) e devolvem
// o JSON já parseado + custo estimado na unidade da franquia do provedor. Só plano gratuito: nenhum
// parâmetro de cobrança, batch pago ou modelo exclusivamente pago. Chaves vêm do ambiente (Secrets).
import { geminiSchema, ProviderError, RESPONSE_SCHEMA } from './contract.ts';

export type ProviderName = 'groq' | 'cloudflare' | 'google';
export type CallArgs = { model: string; system: string; user: string; timeoutMs: number };
export type CallResult = { raw: unknown; cost: number };
export type Adapter = (a: CallArgs, f?: typeof fetch) => Promise<CallResult>;

const MAX_OUT = 4000;

/** Retry-After em segundos (número ou data HTTP). */
export function retryAfter(h: Headers): number | undefined {
  const v = h.get('retry-after');
  if (!v) return undefined;
  const n = Number(v);
  if (Number.isFinite(n)) return Math.ceil(n);
  const t = Date.parse(v);
  return Number.isNaN(t) ? undefined : Math.max(1, Math.ceil((t - Date.now()) / 1000));
}

/** HTTP -> motivo. 429 vira quota_exhausted quando o corpo indica franquia diária esgotada. */
export function classify(status: number, body: string, headers: Headers): ProviderError {
  const b = body.toLowerCase();
  if (status === 429) {
    const daily = /per day|daily|allocation|neurons|free tier|quota/.test(b);
    return new ProviderError(daily ? 'quota_exhausted' : 'rate_limited', retryAfter(headers));
  }
  if (status === 401 || status === 403) return new ProviderError('auth');
  if (status === 404 || /decommission|model.*(not found|does not exist|deprecated|no longer)/.test(b)) {
    return new ProviderError('model_gone');
  }
  if (status === 408 || status >= 500) return new ProviderError('provider_unavailable', retryAfter(headers));
  return new ProviderError('bad_request');
}

async function post(url: string, init: RequestInit, timeoutMs: number, f: typeof fetch): Promise<unknown> {
  const ctl = new AbortController();
  const timer = setTimeout(() => ctl.abort(), timeoutMs);
  try {
    const r = await f(url, { ...init, signal: ctl.signal });
    if (!r.ok) throw classify(r.status, (await r.text().catch(() => '')).slice(0, 500), r.headers);
    return await r.json();
  } catch (e) {
    if (e instanceof ProviderError) throw e;
    if (e instanceof SyntaxError) throw new ProviderError('invalid_output');
    throw new ProviderError(ctl.signal.aborted ? 'timeout' : 'provider_unavailable'); // DNS, TLS, abort
  } finally {
    clearTimeout(timer);
  }
}

/** Conteúdo textual/objeto -> JSON. Vazio, truncado ou torto => invalid_output. */
export function parseJsonContent(content: unknown): unknown {
  if (content && typeof content === 'object') return content;
  if (typeof content !== 'string' || !content.trim()) throw new ProviderError('invalid_output');
  const s = content.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  try {
    return JSON.parse(s);
  } catch {
    throw new ProviderError('invalid_output');
  }
}

// deno-lint-ignore no-explicit-any
type Json = any;

export const groq: Adapter = async (a, f = fetch) => {
  const key = Deno.env.get('GROQ_API_KEY');
  if (!key) throw new ProviderError('auth');
  const p: Json = await post('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
    body: JSON.stringify({
      model: a.model,
      messages: [{ role: 'system', content: a.system }, { role: 'user', content: a.user }],
      temperature: 0.2,
      max_completion_tokens: MAX_OUT,
      ...(a.model.startsWith('openai/gpt-oss') ? { reasoning_effort: 'low' } : {}),
      response_format: { type: 'json_schema', json_schema: { name: 'essay_evaluation', strict: true, schema: RESPONSE_SCHEMA } },
    }),
  }, a.timeoutMs, f);
  const choice = p?.choices?.[0];
  if (choice?.finish_reason === 'length') throw new ProviderError('invalid_output'); // resposta incompleta
  return { raw: parseJsonContent(choice?.message?.content), cost: Number(p?.usage?.total_tokens) || 6000 };
};

/** Custo em neurons por mil tokens (página de preços da Cloudflare). Modelo desconhecido usa o mais caro. */
const NEURONS_PER_K: Record<string, [number, number]> = {
  '@cf/meta/llama-3.3-70b-instruct-fp8-fast': [26.668, 204.805],
  '@cf/openai/gpt-oss-120b': [31.818, 68.182],
};

export const cloudflare: Adapter = async (a, f = fetch) => {
  const token = Deno.env.get('CLOUDFLARE_AI_TOKEN');
  const account = Deno.env.get('CLOUDFLARE_ACCOUNT_ID');
  if (!token || !account) throw new ProviderError('auth');
  const p: Json = await post(`https://api.cloudflare.com/client/v4/accounts/${account}/ai/run/${a.model}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({
      messages: [{ role: 'system', content: a.system }, { role: 'user', content: a.user }],
      temperature: 0.2,
      max_tokens: MAX_OUT,
      response_format: { type: 'json_schema', json_schema: RESPONSE_SCHEMA },
    }),
  }, a.timeoutMs, f);
  if (p?.success === false) throw new ProviderError('provider_unavailable');
  const r = p?.result ?? p;
  const [rin, rout] = NEURONS_PER_K[a.model] ?? [31.818, 204.805];
  const u = r?.usage ?? {};
  const cost = Math.ceil(((Number(u.prompt_tokens) || 3000) * rin + (Number(u.completion_tokens) || 2500) * rout) / 1000);
  const content = r?.response ?? r?.choices?.[0]?.message?.content;
  if (r?.choices?.[0]?.finish_reason === 'length') throw new ProviderError('invalid_output');
  return { raw: parseJsonContent(content), cost };
};

export const google: Adapter = async (a, f = fetch) => {
  const key = Deno.env.get('GEMINI_API_KEY');
  if (!key) throw new ProviderError('auth');
  const p: Json = await post(
    `https://generativelanguage.googleapis.com/v1beta/models/${a.model}:generateContent`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: a.system }] },
        contents: [{ role: 'user', parts: [{ text: a.user }] }],
        generationConfig: {
          temperature: 0.2, maxOutputTokens: MAX_OUT,
          responseMimeType: 'application/json', responseSchema: geminiSchema(),
        },
      }),
    },
    a.timeoutMs, f,
  );
  const cand = p?.candidates?.[0];
  if (cand?.finishReason === 'MAX_TOKENS') throw new ProviderError('invalid_output');
  return { raw: parseJsonContent(cand?.content?.parts?.[0]?.text), cost: 1 };
};

export const ADAPTERS: Record<ProviderName, Adapter> = { groq, cloudflare, google };

/** Credenciais presentes no ambiente (sem expor valores). Provedor sem credencial é ignorado, não falha. */
export function hasCredentials(p: string): boolean {
  if (p === 'groq') return !!Deno.env.get('GROQ_API_KEY');
  if (p === 'cloudflare') return !!Deno.env.get('CLOUDFLARE_AI_TOKEN') && !!Deno.env.get('CLOUDFLARE_ACCOUNT_ID');
  if (p === 'google') return !!Deno.env.get('GEMINI_API_KEY');
  return false;
}
