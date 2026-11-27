# Correção de redação com múltiplos provedores gratuitos e fallback

> Estado em 26/11/2026: **homologado tecnicamente com chamadas reais e usuários/redações sintéticas; NÃO ativado para alunos reais**. Migration aplicada em produção, `evaluate-essay` implantada, Secrets dos provedores configurados, provedores desligados no banco e interruptor global em `ESSAY_AI_PROVIDER=disabled` (a função responde `503 not_configured` antes de qualquer envio). Custo: R$ 0,00.

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

Tetos internos (editáveis): Groq 180.000 tokens e 900 req/dia (~10% de margem); **Cloudflare 6.000 de 10.000 neurons/dia**: a franquia é da CONTA e vale para qualquer outro uso de Workers AI nela, por isso o teto interno fica abaixo. No plano Free, estourar dá erro, não cobrança; o plano da conta não é verificável pelo token (escopo limitado), então o teto interno é a proteção.

## Consumo medido e capacidade diária (chamadas reais, 26/11)

| Provedor | Consumo por correção | Latência | Capacidade/dia (teto interno) |
|---|---|---|---|
| Groq `gpt-oss-120b` | 2.000–3.600 tokens (média ≈ 3.100) | 2–3 s | 180.000 / 3.100 ≈ **58** (limite da conta: 200 mil tokens/dia e 8.000 tokens/min, ≈ 2 correções/min) |
| Cloudflare `llama-3.3-70b` | 150–290 neurons (média ≈ 215; usa o campo `usage.neurons` da própria resposta) | 19–45 s | 6.000 / 215 ≈ **28** (franquia inteira de 10.000: ≈ 46) |

Efetivo ≈ **86 correções/dia**, ou ≈ **28 alunos/dia** no teto de 3 correções por aluno. O gargalo do Groq é por minuto (3 correções simultâneas passam de 8.000 tokens/min, dão 429 e o Plano B assume, sem custo). Esgotadas as franquias, a correção pausa até a renovação (sem custo, texto salvo). É capacidade de piloto, não de escala.

**Prazo global**: 100 s por solicitação, abaixo do limite da Edge Function (150 s). Pior caso medido: Groq falha em até 40 s e Cloudflare leva até 45 s, ou seja ≈ 85 s; o app mostra o estado "corrigindo" e recebe resposta definitiva (corrigida ou o aviso único), sem travar.

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
         5. complete_essay_evaluation(provider, model, prompt essay-enem-v4)  ou
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

Painel em **Portal → Correção por IA** (`/partners/essay-ai`, `lib/features/portal/presentation/pages/essay_ai_page.dart`): provedores com papel (Plano A/B/desligado), modelo, estado do breaker (com botão de reiniciar), correções/falhas/fallbacks do dia, consumo da franquia e capacidade restante, latência média, último erro e última correção; subir/descer prioridade (com confirmação, vale já, sem publicar app); ligar/desligar por provedor (com confirmação e aviso sobre termos/privacidade). Tudo via RPCs `admin_essay_ai_overview`, `admin_essay_ai_set`, `admin_essay_ai_set_order` (somente administrador, auditadas). Não-admin recebe 403 e anônimo 401 (verificado em produção); a tabela é invisível ao aluno.

## Regras pedagógicas (Cartilha do Participante do ENEM 2026, Inep)

Lidas no PDF oficial. Prompt `essay-enem-v4` e `validateEvaluation` (servidor, independente do modelo):
- Notas por competência só em 0, 40, 80, 120, 160, 200 (schema + normalização).
- **Fuga total ao tema** ("nem o assunto mais amplo nem o tema específico são desenvolvidos") → nota 0 em tudo.
- **Tangenciamento** → C2, C3 e C5 limitadas a 40 pontos cada (a Cartilha 2026 confirma a regra da edição 2025).
- **Texto insuficiente**: a regra oficial é de até 7 linhas manuscritas. Não há equivalente digital preciso e não convertemos em palavras: o app já impede o envio de menos de 50 palavras (`essay_min_word_count`); um texto que chegue ao modelo muito pouco desenvolvido é sinalizado (`insufficient_text`), avaliado pelo que existe e orientado a escrever um texto completo, sem zerar de forma arbitrária.
- **Texto em língua estrangeira**: a Cartilha zera o texto escrito predominantemente em outro idioma. Mantivemos a decisão anterior do dono (avaliar em qualquer idioma, sem zerar); é treino e a nota nunca é apresentada como oficial. Reavaliar se o dono preferir seguir a Cartilha à risca.
- **Tentativa de manipular o prompt**: detecção independente da classificação pedagógica (`looksLikeInjection`). Não altera nota nem zera redação; só recusa uma resposta do modelo que "obedeceu" (todas as competências em 200 numa redação com o sinal), o que aciona o fallback e, se ninguém resistir, o aviso único com texto salvo e cota devolvida. Texto legítimo com frase parecida é avaliado normalmente.
- O `total_score` do modelo é informativo: o total é recalculado (o Llama errou a soma em um caso real).

## Homologação real (26/11/2026)

**Comparação com 7 redações sintéticas** (`tool/qa/essay_ai_compare.ts`, adaptadores e validação reais):

| Caso | Groq C1–C5 / total | Cloudflare C1–C5 / total |
|---|---|---|
| Excelente | 200·200·200·200·200 = 1000 | 200·200·200·200·200 = 1000 |
| Mediana | 80·120·120·80·80 = 480 | 120·160·120·120·160 = 680 |
| Ruim | 40·40·40·40·0 = 160 | 40·40·40·40·40 = 200 (tangente) |
| Fuga ao tema | 0 (fuga total) | 0 (fuga total) |
| Curta | 160 (sinalizada) | 0 |
| Manipulação | 0 (resistiu) | 0 (nesta rodada; em outra o Llama obedeceu e foi barrado) |
| Inglês | 160·160·160·120·160 = 760 | 200·200·200·200·200 = 1000 |

Leitura: o Groq é mais calibrado e consistente (justificativas específicas, citações literais da redação, sugestões acionáveis); o Llama é **mais generoso** (+200 na mediana, +240 no inglês) e mais lento (19–45 s), e foi vulnerável à injeção. Como Plano B só atua quando o A falha, é aceitável para treino; a diferença fica registrada e o painel mostra qual provedor corrigiu. Todas as respostas válidas trazem as cinco competências com resumo, pontos fortes, melhorias e evidências. As falhas iniciais do Cloudflare (mediana e manipulação) eram: soma do total incoerente e resposta que obedeceu à injeção sem sugestões; ambas tratadas.

**Fallback real** (`tool/qa/essay_ai_fallback_real.ts` e e2e pela função): modelo inexistente (404), chave inválida (401) e timeout do Plano A, com o Plano B concluindo (`fallback=true` contabilizado); ordem invertida funciona; os dois fora do ar dão falha limpa, sem loop. Pela função, com usuário de teste e a chave do A inválida: 200 em 46 s, corrigido pelo Cloudflare, uso registrado e breaker do A aberto por `auth`.

**Circuit breaker** (relatórios reais reaplicados no Postgres descartável): `auth`/`model_gone` abrem por 1 h; o plano passa a ser só o B; vencido o prazo o A volta em meia-abertura; um sucesso real fecha e zera as falhas. 45 asserts SQL e 66 testes Deno passam.

**Limite compartilhado de 3/dia**: quarta correção do mesmo usuário em produção devolveu `409 daily_limit_reached` sem debitar nada. Falha total devolve a cota (trigger) e a redação fica salva; manipulação obedecida pelo Llama deu 502 genérico, cota devolvida.

**Ponta a ponta com usuários e redações sintéticas** (`tool/qa/essay_ai_e2e.py`; função executada localmente contra o banco de produção para não expor alunos reais; contas de teste no cofre, serviço `supabase-auth-test`): correções de 640 (saúde mental), 880 e 1000 (água) e 0 (fuga) gravadas e lidas pela RPC do app. A função implantada responde `503 not_configured` (desligada).

**Painel**: homologado por teste de widget com a API simulada e o estado real reproduzido (ligar/desligar com confirmação, reordenar, reiniciar breaker; `test/features/portal/essay_ai_page_test.dart`) e por renderização visual em 1440 px e 390 px, claro e escuro. **Não** foi aberto logado em produção: isso exigiria conceder administrador a uma conta de teste em produção, o que o controle de permissões negou; fica para o dono.

## Termos de uso e privacidade dos provedores (leitura de 26/11; parecer jurídico ainda necessário)

- **Groq**: por padrão não retém dados de inferência de clientes (página "Your Data"), com Zero Data Retention opcional; Customer DPA publicado; Services Agreement vigente de 15/10/2025. Não encontrei idade mínima no contrato (só a proibição de coletar dados de menores de 13 anos nos termos antigos do site) nem declaração explícita sobre treino na página consultada. **Ler o Services Agreement e o DPA completos.**
- **Cloudflare Workers AI**: a página de privacidade afirma que o conteúdo do cliente não é usado para treinar modelos e é retido só o necessário. O Self-Serve Subscription Agreement (12/09/2025) não trouxe cláusula de idade nos trechos lidos. **Conferir o contrato completo.**
- Consequência: redações reais seguem **desativadas** até o parecer sobre menores (ver `docs/qa/IA_REDACAO_E_MENORES.md`); o prompt não leva nome, e-mail, id de usuário nem de submissão.

## Estado em produção e como ativar

Feito em 26/11: migration `20261207000100` aplicada; `evaluate-essay` implantada; Secrets `GROQ_API_KEY`, `CLOUDFLARE_AI_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` definidos; `ESSAY_AI_PROVIDER=disabled`; provedores com `enabled=false`; monetização desligada; nada publicado nas lojas.

Pendências reais:
1. Parecer jurídico (menores, Groq DPA/Services Agreement, Cloudflare) e política publicada.
2. Dono confirmar o plano Free da conta Cloudflare e que nenhum outro serviço consome Workers AI nela.
3. Dono abrir o painel logado e validar os controles com os dados reais.
4. Ativar: habilitar Groq e Cloudflare no painel e `supabase secrets set ESSAY_AI_PROVIDER=multi`.
5. Publicar novo app só quando o dono decidir: o texto único de erro só chega com a nova versão.
6. PDF dos professores: a correção está **homologada**, não **disponível ao público**; a página só entra quando houver disponibilidade. Capturas reais prontas em `aprovaura-brand/comercial-professores-parceiros/capturas_correcao_redacao/` (nota total, C1–C5, justificativa, evidências, melhorias e sugestões, claro e escuro).
