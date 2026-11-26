# Correção de redação com múltiplos provedores gratuitos e fallback

> Estado em 26/11/2026: **implementado e testado com simulação; NÃO ativado**. Todos os provedores nascem desligados e o interruptor global segue em `ESSAY_AI_PROVIDER=disabled`. Nada foi contratado, nenhuma chave foi criada, nenhuma redação foi enviada a terceiros. Custo: R$ 0,00.

## Provedores selecionados

| Papel | Provedor | Modelo | Por que |
|---|---|---|---|
| **Plano A** | Groq | `openai/gpt-oss-120b` | JSON Schema **estrito** (decodificação restrita), sem retenção de entradas/saídas por padrão, latência baixa |
| **Plano B** | Cloudflare Workers AI | `@cf/meta/llama-3.3-70b-instruct-fp8-fast` | franquia independente, conteúdo **não** usado para treino e sem retenção, JSON Schema suportado, no plano Free estourar a franquia dá **erro, nunca cobrança** |
| Preservado, **desligado** | Google Gemini | `gemini-3.8-flash` | termos do plano gratuito exigem 18+ e usam o conteúdo para melhorar produtos (incompatível com o público adolescente); código mantido |

Qualquer ordem, modelo e liga/desliga é configuração no banco (abaixo), sem publicar app nem redeployar.

## Limites gratuitos (páginas oficiais lidas em 26/11/2026)

| Provedor | Limite | Fonte / ressalva |
|---|---|---|
| Groq `gpt-oss-120b` | 30 req/min, 1.000 req/dia, 8.000 tokens/min, 200.000 tokens/dia | tabela de limites da Groq; a página não rotula o plano na extração — **conferir no console da conta** |
| Cloudflare Workers AI (Free) | 10.000 neurons/dia, zera 00:00 UTC; estouro = erro | página de preços (atualizada 18/11/2026); Llama 3.3 70B: 26.668 neurons/M tokens de entrada e 204.805/M de saída |
| Gemini (free) | números só no painel do AI Studio (não lidos) | termos: 18+, conteúdo usado para melhorar produtos, "não envie dados pessoais" |

Tetos internos (editáveis, ~10% de margem): Groq 180.000 tokens e 900 req/dia; Cloudflare 9.000 neurons/dia.

## Estimativa de correções por dia

Premissa (a medir na homologação real): ~3.000 tokens de entrada (rubrica + tema + redação) e ~2.000 de saída.
- Groq: ≈ 5.000 tokens/correção → **~36 correções/dia**.
- Cloudflare: (3.000×26,668 + 2.500×204,805)/1.000 ≈ 590 neurons → **~15 correções/dia**.
- Juntos ≈ **50 correções/dia**, ou seja, cerca de **17 alunos/dia** no teto de 3 correções por aluno. Esgotadas as franquias, a correção pausa até a renovação (sem custo, sem perda de texto). É capacidade de piloto, não de escala.

## Arquitetura

```
app ──> evaluate-essay (Edge Function)
         1. autentica (JWT) e respeita o interruptor global ESSAY_AI_PROVIDER
         2. essay_ai_plan()  [service_role]  -> provedores elegíveis, em ordem
            (ligado, breaker fechado/meia-abertura, sem cooldown, franquia interna sobrando)
            sem plano -> 503 ANTES de debitar cota ou tocar na submission
         3. start_essay_evaluation()  [como o aluno] -> posse, cota, 1 em voo por usuário
         4. runCorrection(): cada provedor no máximo 1x, prazo global 100 s, timeout por provedor
            ok válido (schema + notas 0-200 + soma) -> encerra (sem chamada duplicada)
            falha -> próximo provedor; essay_ai_report() registra uso/latência/erro/Retry-After
         5. complete_essay_evaluation(provider, model, prompt essay-enem-v3)  ou
            fail_essay_evaluation() -> trigger devolve a cota -> 502 genérico
```

- Código: `supabase/functions/_shared/essay_ai/{contract,providers,orchestrator}.ts`, `evaluate-essay/index.ts`.
- Banco: `supabase/migrations/20261207000100_essay_ai_providers.sql` (rollback em `supabase/rollbacks/`).
- **Contrato único**: mesmo prompt (v3, com defesa contra injeção: a redação vai entre marcas e é tratada como dado), mesmo JSON Schema (c1..c5, `total_score`, justificativas, pontos fortes/melhorar, evidências, desvio de tema, texto insuficiente). Validação antes de gravar: estrutura completa, nota inteira 0–200 (arredondada ao múltiplo de 40), `total_score` = soma, textos não vazios.
- **Circuit breaker**: 3 falhas consecutivas abrem por 300 s (configurável); 401/403/modelo descontinuado abrem por 1 h; 429 usa `Retry-After` (limitado a 1 h); depois do prazo o provedor volta sozinho (meia-abertura). `invalid_output` nunca abre o breaker (um texto malicioso não derruba o provedor para todos). Provedor com breaker aberto nem entra no plano: a redação seguinte vai direto ao B sem esperar falha conhecida.
- **Fallback silencioso**: 429, 500/502/503/504, timeout, indisponibilidade, franquia, modelo descontinuado, resposta vazia/truncada, JSON inválido, nota fora do limite, soma incoerente e falha de autenticação acionam o próximo provedor. O app recebe sempre o mesmo `502 provider_unavailable`; a mensagem única é "Não foi possível corrigir sua redação agora. Seu texto está salvo. Tente novamente em alguns instantes." (3 idiomas). Nomes de modelo e códigos ficam só no banco/admin.
- **Cota**: 3/dia por usuário, compartilhada. Falha total devolve o débito (trigger `essay_release_quota_on_failure`); fallback concluído = 1 correção. Retentativa ainda passa por `start_essay_evaluation` (uma em voo por usuário, duplicata recusada).
- **Custo zero**: só modelos/planos gratuitos; teto interno por provedor; sem upgrade, sem faturamento, sem segunda conta. Sem provedor ou chave, a função recusa antes de qualquer envio.

## Administração

RPCs para o painel (somente administrador, auditadas em `admin_audit_log`):
- `admin_essay_ai_overview()` — por provedor: papel (principal/secundário/desligado), modelo, estado do breaker, último erro (só código), última correção bem-sucedida, uso de hoje (requisições, sucessos, falhas, fallbacks, consumo estimado e %), últimos 7 dias (sucessos, falhas, fallbacks, latência média).
- `admin_essay_ai_set(provider, patch, note)` — `enabled`, `priority`, `model`, `timeout_ms`, `daily_budget`, `daily_request_limit`, `breaker_threshold`, `recovery_seconds`, `reset_breaker`.
- `admin_essay_ai_set_order(array['cloudflare','groq'], note)` — inverte o Plano A/B de uma vez.

A tela no portal administrativo **não foi construída** (o portal web não está neste repositório); as RPCs já devolvem tudo o que ela precisa.

## Testes executados

- Deno (`deno task test:functions`): 20 testes passam — validação, normalização de notas, classificação HTTP, Retry-After, adaptadores com `fetch` simulado (Groq, Cloudflare, Gemini), Plano A ok, A fora do ar (503/timeout/auth/429/franquia/modelo) com B concluindo, A com JSON inválido/vazio/nota inválida/total incoerente, ambos fora do ar (sem loop), B fora do ar sem ser chamado, retry controlado de plano único, prazo global, falha ao reportar uso, equivalência de payload entre provedores, redação delimitada contra manipulação do prompt.
- SQL em Postgres descartável (`tool/db/essay_ai_sql_tests.sql`, 45 asserts): plano, inversão de ordem, desligar individual, breaker abre/recupera, cooldown com Retry-After, auth, franquia de tokens e de requisições, contabilização de fallback, falha total devolve cota, correção presa, fallback = 1 correção, duplicata e concorrência, 4ª correção recusada, painel só para admin, auditoria, funções de serviço fechadas ao app.

## O que NÃO foi possível fazer (e por quê)

1. **Comparação de qualidade com chamadas reais** (excelente/mediana/ruim/fuga/curta/manipulação/outro idioma): não há chave Groq nem Cloudflare (criar conta/chave exige o dono) e a chave do Gemini do cofre pertence ao projeto `ia-audio`, então não foi usada. O script `tool/qa/essay_ai_compare.ts` já roda as 7 redações sintéticas pelos adaptadores reais assim que as chaves existirem.
2. **Evidência de fallback ponta a ponta com provedores reais** e de **recuperação automática** em produção: só simulados (testes acima).
3. **Equivalência pedagógica** entre Groq e Llama 3.3: depende da comparação real (item 1). Risco conhecido: o Llama não tem decodificação estrita em todos os casos; a validação + fallback cobrem JSON torto, mas a **calibração de notas** só se mede com o teste real.
4. **Screenshots reais da correção** e página nova no PDF dos professores: dependem da funcionalidade homologada e autorizada. O PDF **não** anuncia o recurso (continua "temporariamente indisponível").

## Pendências para ativar (ordem)

1. Dono cria **uma** chave na Groq (console, plano gratuito, sem cartão) e **um** token Cloudflare "Workers AI" + Account ID (plano Workers Free). Guardar no cofre global e nos Secrets: `GROQ_API_KEY`, `CLOUDFLARE_AI_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`.
2. Confirmar nos consoles os limites reais da conta e ajustar `daily_budget`/`daily_request_limit`.
3. Rodar `deno run --allow-env --allow-net tool/qa/essay_ai_compare.ts` e avaliar equivalência (comparar totais e C1–C5; manter o fallback só se a diferença for aceitável).
4. Parecer jurídico sobre menores (Groq Services Agreement/DPA e termos da Cloudflare) e publicar a política atualizada (`docs/legal/*`; o texto do site `docs/site-lucksrei` só muda na ativação).
5. Aplicar a migration `20261207000100` em produção, fazer deploy de `evaluate-essay`, habilitar os dois provedores (`admin_essay_ai_set`) e trocar `ESSAY_AI_PROVIDER` de `disabled` para `multi`.
6. Gerar screenshots reais e atualizar o PDF dos professores (página exclusiva da correção).
7. Publicar novo app apenas quando o dono decidir: o texto único de erro só chega ao aluno com a nova versão; apps antigos mostram a mensagem anterior.
