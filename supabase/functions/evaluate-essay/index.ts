// Correção de redação: lê a submission, pede ao Gemini uma avaliação em
// JSON estruturado e grava o resultado. Tudo que decide (posse, cota,
// idempotência, nota, Aura) mora nas RPCs do essays.sql -- esta função só
// orquestra e fala com o provider.
//
// SEGURANÇA
// - O usuário NUNCA vem do body: sai do próprio JWT via auth.getUser(),
//   que revalida no GoTrue em vez de só decodificar o token. O mesmo
//   padrão da função delete-account.
// - Todas as chamadas ao banco usam o client "como o chamador"
//   (publishable key + Authorization do usuário), nunca a service key.
//   start_essay_evaluation() recusa submission de outra pessoa, e é ela
//   quem debita a cota -- não há caminho aqui para corrigir a redação
//   alheia nem para furar o teto diário.
// - A GEMINI_API_KEY só existe no ambiente desta função (Supabase
//   Secrets). Nunca chega ao Flutter, ao banco ou a um log.
//
// PRIVACIDADE (free tier)
// A documentação do Gemini avisa que, no free tier, o conteúdo enviado
// pode ser usado pelo Google para melhorar os produtos deles. Por isso o
// prompt leva SÓ o necessário para corrigir: proposta, textos motivadores
// e o texto da redação. Nada de nome, e-mail, user_id, submission_id ou
// qualquer identificador interno -- nem no prompt, nem nos logs. O corpo
// da redação e a resposta completa do provider também não são logados.
// Ver README.md desta pasta: isso precisa estar na Política de
// Privacidade antes de publicar.
//
// CUSTO
// Só a modalidade Standard do free tier. Sem batch pago, sem grounding,
// sem fallback para provider pago. Estourou a cota do free tier, vira
// erro recuperável e a pessoa tenta de novo depois -- a redação e a
// submission nunca se perdem.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';

const MODEL = Deno.env.get('GEMINI_MODEL') ?? 'gemini-3.8-flash';
const PROMPT_VERSION = 'essay-enem-v1';
const PROVIDER = 'google';

/** Uma tentativa + uma repetição: JSON torto costuma sair certo na
 * segunda. Mais que isso seria queimar cota do free tier à toa. */
const MAX_ATTEMPTS = 2;
const REQUEST_TIMEOUT_MS = 60_000;

/** Competências do ENEM, 0-200 cada. O total é a soma e é conferido por
 * constraint no banco -- JSON incoerente não vira nota salva. */
const COMPETENCIES = ['c1', 'c2', 'c3', 'c4', 'c5'] as const;

const COMPETENCY_TITLES: Record<string, string> = {
  c1: 'Domínio da norma padrão da língua escrita',
  c2: 'Compreender a proposta e aplicar conceitos das várias áreas',
  c3: 'Selecionar, relacionar, organizar e interpretar informações',
  c4: 'Conhecimento dos mecanismos linguísticos de argumentação',
  c5: 'Proposta de intervenção que respeite os direitos humanos',
};

/** O schema que o Gemini é obrigado a devolver (structured output). Ter o
 * formato garantido é o que permite validar a nota antes de gravar em vez
 * de tentar adivinhar de texto livre. */
const RESPONSE_SCHEMA = {
  type: 'OBJECT',
  properties: {
    ...Object.fromEntries(
      COMPETENCIES.map((key) => [
        key,
        {
          type: 'OBJECT',
          properties: {
            score: { type: 'INTEGER' },
            summary: { type: 'STRING' },
            strengths: { type: 'ARRAY', items: { type: 'STRING' } },
            improvements: { type: 'ARRAY', items: { type: 'STRING' } },
            evidence: { type: 'ARRAY', items: { type: 'STRING' } },
          },
          required: ['score', 'summary', 'strengths', 'improvements'],
        },
      ]),
    ),
    general_feedback: { type: 'STRING' },
    strengths: { type: 'ARRAY', items: { type: 'STRING' } },
    priority_improvements: { type: 'ARRAY', items: { type: 'STRING' } },
    possible_theme_deviation: { type: 'BOOLEAN' },
    insufficient_text: { type: 'BOOLEAN' },
  },
  required: [
    ...COMPETENCIES,
    'general_feedback',
    'strengths',
    'priority_improvements',
    'possible_theme_deviation',
    'insufficient_text',
  ],
};

const RUBRIC = `Você é um corretor de redação do ENEM, experiente e pedagógico.

Avalie a redação abaixo nas cinco competências do ENEM, cada uma de 0 a 200
pontos, em múltiplos de 40 (0, 40, 80, 120, 160, 200), como faz a banca:

C1 — ${COMPETENCY_TITLES.c1}
C2 — ${COMPETENCY_TITLES.c2}
C3 — ${COMPETENCY_TITLES.c3}
C4 — ${COMPETENCY_TITLES.c4}
C5 — ${COMPETENCY_TITLES.c5}

Regras da correção:
- Escreva em português do Brasil, dirigindo-se a quem escreveu, por "você".
- Tom pedagógico e respeitoso. Aponte o que precisa melhorar sem humilhar:
  nunca use termos como "péssimo", "horrível" ou equivalentes.
- Em "evidence", cite trechos curtos do próprio texto (entre aspas) que
  justifiquem a nota daquela competência. Não invente trechos: só use o que
  está escrito.
- "summary" explica a nota da competência em uma ou duas frases.
- "priority_improvements" traz no máximo três ações concretas, na ordem em
  que mais mudariam a nota.
- Marque "possible_theme_deviation" quando o texto não tratar do tema
  proposto, e "insufficient_text" quando for curto demais para avaliar.
- A nota é uma ESTIMATIVA de treino, não a nota oficial do ENEM.`;

type StartRow = {
  body: string;
  theme_title: string;
  theme_prompt: string;
  supporting_texts: unknown;
  word_count: number;
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/** Códigos de erro do start_essay_evaluation (essays.sql, seção 4.1)
 * traduzidos em algo que o app entende sem ler mensagem do Postgres. */
function startFailureReason(code: string | undefined): string {
  switch (code) {
    case 'P0002':
      return 'not_found';
    case 'P0004':
      return 'already_evaluated';
    case 'P0005':
      return 'already_evaluating';
    case 'P0006':
      return 'daily_limit_reached';
    default:
      return 'unexpected';
  }
}

function buildPrompt(row: StartRow): string {
  // Só o que é preciso para corrigir. Nenhum identificador interno entra
  // aqui -- ver a nota de privacidade no topo.
  const supporting = Array.isArray(row.supporting_texts)
    ? (row.supporting_texts as Array<Record<string, unknown>>)
        .map((text, index) => {
          const title = typeof text.title === 'string' ? text.title : `Texto ${index + 1}`;
          const body = typeof text.body === 'string' ? text.body : '';
          return body.trim() ? `${title}\n${body.trim()}` : '';
        })
        .filter(Boolean)
        .join('\n\n')
    : '';

  return [
    RUBRIC,
    `TEMA\n${row.theme_title}`,
    `PROPOSTA\n${row.theme_prompt}`,
    supporting ? `TEXTOS MOTIVADORES\n${supporting}` : '',
    `REDAÇÃO DO ESTUDANTE\n${row.body}`,
  ]
    .filter(Boolean)
    .join('\n\n---\n\n');
}

async function callGemini(apiKey: string, prompt: string): Promise<unknown> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
      {
        method: 'POST',
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: 'application/json',
            responseSchema: RESPONSE_SCHEMA,
          },
        }),
      },
    );

    if (response.status === 429) throw new ProviderError('rate_limited');
    if (!response.ok) throw new ProviderError('provider_unavailable');

    const payload = await response.json();
    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== 'string') throw new ProviderError('invalid_output');
    return JSON.parse(text);
  } catch (error) {
    if (error instanceof ProviderError) throw error;
    if (error instanceof SyntaxError) throw new ProviderError('invalid_output');
    // Timeout, DNS, TLS: tudo recuperável -- a submission continua lá.
    throw new ProviderError('provider_unavailable');
  } finally {
    clearTimeout(timeout);
  }
}

class ProviderError extends Error {
  constructor(public readonly reason: string) {
    super(reason);
  }
}

/** Recusa o que não dá para gravar: competência faltando, nota fora de
 * 0-200 ou não inteira. O banco ainda confere a soma por constraint, mas
 * errar aqui é mais barato do que errar lá. */
function validate(result: unknown): Record<string, unknown> {
  if (typeof result !== 'object' || result === null) {
    throw new ProviderError('invalid_output');
  }
  const data = result as Record<string, unknown>;
  for (const key of COMPETENCIES) {
    const competency = data[key];
    if (typeof competency !== 'object' || competency === null) {
      throw new ProviderError('invalid_output');
    }
    const score = (competency as Record<string, unknown>).score;
    if (typeof score !== 'number' || !Number.isInteger(score) || score < 0 || score > 200) {
      throw new ProviderError('invalid_output');
    }
  }
  return data;
}

/** Monta o payload no formato que complete_essay_evaluation() espera. */
function toRpcPayload(data: Record<string, unknown>): Record<string, unknown> {
  const competencies = COMPETENCIES.map((key) => {
    const value = data[key] as Record<string, unknown>;
    return {
      competency: key,
      title: COMPETENCY_TITLES[key],
      score: value.score,
      summary: value.summary ?? '',
      strengths: value.strengths ?? [],
      improvements: value.improvements ?? [],
      evidence: value.evidence ?? [],
    };
  });

  return {
    ...Object.fromEntries(COMPETENCIES.map((key) => [key, { score: (data[key] as Record<string, unknown>).score }])),
    competencies,
    general_feedback: data.general_feedback ?? '',
    strengths: data.strengths ?? [],
    priority_improvements: data.priority_improvements ?? [],
    possible_theme_deviation: data.possible_theme_deviation === true,
    insufficient_text: data.insufficient_text === true,
  };
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json({ error: 'method not allowed' }, 405);
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'missing authorization header' }, 401);

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) {
    // Sem chave configurada não há como corrigir. Erro claro, sem
    // fallback pago e sem tocar na submission.
    return json({ error: 'provider not configured', reason: 'not_configured' }, 503);
  }

  let submissionId: string | undefined;
  try {
    submissionId = (await req.json())?.submission_id;
  } catch (_) {
    return json({ error: 'invalid body' }, 400);
  }
  if (typeof submissionId !== 'string' || !submissionId) {
    return json({ error: 'missing submission_id' }, 400);
  }

  // Client "como o chamador": nunca a service key. Toda regra de posse e
  // de cota continua valendo exatamente como valeria para o app.
  const caller = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await caller.auth.getUser();
  if (userError || !userData?.user) return json({ error: 'invalid session' }, 401);

  // Reivindica a submission: posse, estado e cota são conferidos aqui, e a
  // cota é debitada ANTES de qualquer chamada ao provider.
  const { data: startData, error: startError } = await caller.rpc('start_essay_evaluation', {
    p_submission_id: submissionId,
  });

  if (startError) {
    const reason = startFailureReason(startError.code);
    // Nada foi gasto: a recusa acontece antes do provider.
    return json({ error: 'cannot start evaluation', reason }, reason === 'not_found' ? 404 : 409);
  }

  const row = (Array.isArray(startData) ? startData[0] : startData) as StartRow | undefined;
  if (!row) {
    await caller.rpc('fail_essay_evaluation', {
      p_submission_id: submissionId,
      p_reason: 'unexpected',
    });
    return json({ error: 'submission unavailable', reason: 'unexpected' }, 500);
  }

  const prompt = buildPrompt(row);
  let lastReason = 'unexpected';

  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    try {
      const raw = await callGemini(apiKey, prompt);
      const validated = validate(raw);

      const { data: completed, error: completeError } = await caller.rpc(
        'complete_essay_evaluation',
        {
          p_submission_id: submissionId,
          p_result: toRpcPayload(validated),
          p_provider: PROVIDER,
          p_model: MODEL,
          p_prompt_version: PROMPT_VERSION,
        },
      );
      if (completeError) throw new ProviderError('unexpected');

      const result = Array.isArray(completed) ? completed[0] : completed;
      return json({ status: 'evaluated', total_score: result?.total_score ?? null });
    } catch (error) {
      lastReason = error instanceof ProviderError ? error.reason : 'unexpected';
      // Só faz sentido repetir quando o problema foi a FORMA da resposta.
      // Rate limit ou provider fora do ar não melhoram tentando de novo
      // no mesmo segundo -- e gastariam cota.
      if (lastReason !== 'invalid_output' || attempt === MAX_ATTEMPTS) break;
    }
  }

  // Erro recuperável: status 'failed', texto e submission intactos, e a
  // cota do dia já debitada continua valendo para a retentativa (ver a
  // regra de cota no cabeçalho do essays.sql).
  await caller.rpc('fail_essay_evaluation', {
    p_submission_id: submissionId,
    p_reason: lastReason,
  });
  // Log mínimo: código do motivo, nunca o texto da redação nem a resposta
  // do provider.
  console.error(`evaluate-essay failed: ${lastReason}`);
  return json({ status: 'failed', reason: lastReason }, 502);
});
