# evaluate-essay

Corrige uma redação enviada: lê a submission, corrige com o primeiro provedor de IA **gratuito** disponível
(com fallback automático para o seguinte) e grava o resultado pelas RPCs de `essays.sql`.

A função não decide nada sozinha. Posse, cota diária, idempotência, nota e crédito de Aura vivem no banco;
aqui só há orquestração. Documento completo (provedores, limites, estimativa, testes, pendências):
[`docs/qa/IA_CORRECAO_MULTIPROVEDOR.md`](../../../docs/qa/IA_CORRECAO_MULTIPROVEDOR.md).

## Estado

**Desativada.** Todos os provedores nascem desligados no banco e o interruptor global está em
`ESSAY_AI_PROVIDER=disabled`. Sem provedor ligado e com chave, a função responde `503` **antes** de debitar
cota ou tocar na submission.

## Configuração

Secrets (nunca no repositório, no app, no banco ou em log; cópia no cofre global):

```bash
npx.cmd supabase secrets set GROQ_API_KEY=...
npx.cmd supabase secrets set CLOUDFLARE_AI_TOKEN=... CLOUDFLARE_ACCOUNT_ID=...
npx.cmd supabase secrets set GEMINI_API_KEY=...        # opcional; provedor desligado por padrão
npx.cmd supabase secrets set ESSAY_AI_PROVIDER=multi   # ou =disabled para suspender TUDO
npx.cmd supabase functions deploy evaluate-essay
```

Quem roda, em que ordem, modelo, timeouts, tetos gratuitos e breaker ficam na tabela `essay_ai_providers`
(sem deploy), pelas RPCs administrativas `admin_essay_ai_overview`, `admin_essay_ai_set` e
`admin_essay_ai_set_order`. Só planos gratuitos: nunca habilitar faturamento nos provedores.

## Contrato

`POST` com `Authorization: Bearer <jwt do usuário>` e corpo
`{ "submission_id": "<uuid>", "locale": "pt-BR" | "en" | "es" }`. Prompt `essay-enem-v3`; o idioma do
`locale` é o da correção, a redação pode estar em qualquer idioma.

| Resposta | Situação |
|---|---|
| `200 {status: "evaluated", total_score}` | corrigida e gravada (provider/model/prompt_version na avaliação) |
| `409 {reason}` | `already_evaluated`, `already_evaluating`, `daily_limit_reached` |
| `404 {reason: "not_found"}` | a submission não é sua ou não existe |
| `502 {status: "failed", reason: "provider_unavailable"}` | todos os provedores falharam; texto salvo, **cota devolvida** |
| `503 {reason: "provider_unavailable"}` | sem provedor elegível agora (franquia/breaker); nada foi debitado |
| `503 {reason: "not_configured"}` | suspensa ou sem chaves |

O app recebe sempre o mesmo motivo para qualquer falha; o detalhe (código, modelo, latência) fica no banco.

## Privacidade e custo

O prompt leva só tema, proposta, textos motivadores e redação, sem nome, e-mail, `user_id` ou
`submission_id`. Redação e resposta do provedor não são logadas (só o código do motivo e contagens de uso).
O Gemini no plano gratuito exige 18+ e usa o conteúdo para melhorar produtos: por isso fica desligado.
A política de privacidade (`docs/legal`) descreve o processamento por IA.

## Testes

```bash
deno task test:functions     # adaptadores, validação, fallback, breaker lógico
docker exec -i aura-empty-check psql -U postgres -v ON_ERROR_STOP=1 -q < tool/db/essay_ai_sql_tests.sql
```

O segundo roda num Postgres descartável criado por `tool/db/empty_db_check.sh` (`KEEP=1`).
