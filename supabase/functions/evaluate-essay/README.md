# evaluate-essay

Corrige uma redação enviada: lê a submission, pede ao Gemini uma avaliação
em JSON estruturado e grava o resultado através das RPCs de `essays.sql`.

A função não decide nada sozinha. Posse, cota diária, idempotência, nota e
crédito de Aura vivem no banco; aqui só há orquestração e a conversa com o
provider.

## O que precisa ser configurado à mão

1. **Chave do Gemini**, criada no Google AI Studio num projeto **free tier,
   sem billing habilitado** (com billing ativo, estourar o free tier vira
   cobrança em vez de erro):

   ```bash
   npx.cmd supabase secrets set GEMINI_API_KEY=...
   ```

   A chave só existe no ambiente desta função. Não está no repositório, no
   Flutter, no banco, em teste nem em log.

2. **Deploy**:

   ```bash
   npx.cmd supabase functions deploy evaluate-essay
   ```

3. Opcional — trocar de modelo sem mexer no código:

   ```bash
   npx.cmd supabase secrets set GEMINI_MODEL=outro-modelo
   ```

Sem `GEMINI_API_KEY` a função responde `503 not_configured` e **não toca na
submission**: nada é debitado, nada falha no histórico.

## Privacidade — importante antes de publicar

A documentação atual do Gemini diz que, **no free tier, o conteúdo enviado
pode ser usado pelo Google para melhorar os produtos deles**.

Por isso o prompt leva apenas o necessário para corrigir:

- o tema e a proposta;
- os textos motivadores;
- o texto da redação;
- a rubrica de correção.

Não vai nome, e-mail, `user_id`, `submission_id` nem qualquer identificador
interno — nem no prompt, nem nos logs. O corpo da redação e a resposta
completa do provider também não são logados; o log de erro guarda só o
código do motivo (`rate_limited`, `invalid_output`, ...).

**Isto precisa constar na Política de Privacidade antes da publicação**: o
texto da redação é enviado a um provedor externo (Google) que, no plano
gratuito, pode usá-lo para treinar/melhorar seus produtos.

## Custo

Somente a modalidade Standard do free tier. Sem batch pago, sem grounding,
sem fallback para provider pago. Se o free tier acabar ou o rate limit
bater, a tentativa vira `failed` (erro recuperável) e a pessoa tenta de
novo depois — a redação e a submission nunca se perdem.

O teto de 3 correções por usuário por dia é do banco
(`essay_daily_evaluation_limit()`), não desta função, e é contado por
submission distinta: retentar a mesma redação no mesmo dia não gasta cota
nova.

## Contrato

`POST` com `Authorization: Bearer <jwt do usuário>` e corpo
`{ "submission_id": "<uuid>" }`.

| Resposta | Situação |
|---|---|
| `200 {status: "evaluated", total_score}` | corrigida e gravada |
| `409 {reason}` | `already_evaluated`, `already_evaluating`, `daily_limit_reached` |
| `404 {reason: "not_found"}` | a submission não é sua ou não existe |
| `502 {status: "failed", reason}` | `rate_limited`, `provider_unavailable`, `invalid_output` |
| `503 {reason: "not_configured"}` | falta a `GEMINI_API_KEY` |

Uma correção que fica presa em `evaluating` (a function morre no meio, um
deploy acontece durante a chamada) é enterrada pelo próprio banco na
tentativa seguinte, passado `essay_evaluation_stale_after()` — sem isso o
índice de "uma correção em voo por usuário" travaria a feature inteira
para aquela pessoa.

`prompt_version` atual: **`essay-enem-v1`**, gravado em cada avaliação junto
com provider e modelo — quando o prompt ou o modelo mudarem, dá para saber
de onde veio cada nota antiga.
