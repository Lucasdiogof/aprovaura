# Avaliação técnica da IA de correção de redação (Etapa 10C, serviço 3)

Data: 2026-11-24. Redações **sintéticas** apenas; nenhum dado de aluno. Scripts: `tool/qa/essay_ai_eval.py`
(prompt/schema reais da função, chamada direta ao Gemini) e `tool/qa/essay_quota_check.py` (RPCs, usuário temporário apagado).

## 1. Estado atual: correção externa SUSPENSA

- Secret `ESSAY_AI_PROVIDER=disabled`. O código (`_shared/essay_provider.ts`) só reconhece `google`; qualquer outro valor
  (inclusive `disabled`, vazio ou desconhecido) vira `suspended` e a função responde 503 `not_configured` **antes** de
  debitar cota ou enviar texto. Redação e submission não se perdem.
- `GEMINI_API_KEY` continua nos secrets (inerte enquanto suspenso). Vem da chave do `ia-audio`, compartilhada por
  autorização do dono (`shared_with: aprovaura` no cofre). `ia-audio` não foi alterado.

## 2. Modelos Gemini (chave atual, sondagem em 2026-11-24)

| Modelo | Resultado |
|---|---|
| `gemini-2.5-flash`, `2.5-flash-lite`, `2.5-pro` | **404** (descontinuados; ainda aparecem na lista) |
| `gemini-3.8-flash` (padrão do código) | existe, mas **503** em todas as chamadas |
| `3.5-flash`, `3.6-flash`, `3.7-flash`, `flash-latest`, `3-flash-preview`, `3.1-flash-lite-preview`, `3.5-flash-lite`, `flash-lite-latest` | 503 no pedido real de correção (alguns 200 só em "diga ok") |
| `gemini-3.1-flash-lite` (versão fixa, sem preview) | **único que respondeu** ao pedido real, de forma intermitente |

Conclusão: no nível gratuito, a disponibilidade é inaceitável: ~3 de 7 correções sintéticas concluídas após até
6 tentativas com espera de 20 s (4 falharam com 503 persistente). `gemini-3.1-flash-lite` é o único candidato
estável testado; o padrão `gemini-3.8-flash` deve ser trocado se o Gemini for mantido.

## 3. Qualidade (poucas amostras; 3 respostas válidas)

| Caso | Notas C1–C5 | Total | Observações |
|---|---|---|---|
| fraca | 40/40/40/40/40 | 200 | coerente com texto com muitos erros e sem proposta |
| média (1ª) | 160/120/120/160/120 | 680 | plausível |
| curta (1 frase) | 40/40/40/40/0 | 160 | `insufficient_text=true` marcado corretamente |

Em todas: notas inteiras e múltiplas de 40, resumos preenchidos, 3 prioridades, trechos de `evidence` literais
(conferidos contra o texto). **Não verificado:** consistência entre repetições (só 1 amostra válida do caso médio),
casos "forte" e "fuga ao tema" (503). Nada disso permite concluir qualidade nem estabilidade das notas.

## 4. Tokens por correção (medidos)

~800–850 tokens de entrada + ~700–920 de saída (sem "thinking") ≈ **1.450–1.800 tokens por correção**.
Redações reais maiores (900+ palavras) aumentam a entrada; esperar ~2.500–3.500 no total.

## 5. Cota, concorrência e abuso (produção, usuário temporário; 9/9 OK)

- Teto: `essay_daily_evaluation_limit() = 3` por usuário/dia. A 4ª correção falha com `P0006`.
- Retentativa da mesma redação que falhou **não** debita de novo.
- Uma correção em voo por usuário: índice único parcial `essay_submissions_one_in_flight_per_user`; sob duas
  chamadas simultâneas, uma passa e a outra recebe `23505` (a função traduz para `already_evaluating`).
- Envio duplicado: `submit_essay_draft` é idempotente por `client_request_id`.
- Correção presa é liberada após 15 min (`essay_evaluation_stale_after`).
- Observação: `P0005` volta como HTTP 500 pelo PostgREST; a função lê o código e responde corretamente.
- Limite do próprio app: 3/dia/usuário; **não há teto global**. Muitos usuários simultâneos esgotam a cota do provedor.
- Banco após o teste: mesmas contagens (6 redações, 6 débitos), nada deixado.

## 6. Esgotamento de cota e isolamento

A IA vive só em `evaluate-essay`. Erro do provedor (429/503/timeout) vira `failed` recuperável (502) naquela
função; login, estudo, questões e demais Edge Functions não dependem dela. A chave compartilhada com `ia-audio`
significa **cota única**: consumo de um app esgota o outro. Recomenda-se chave/projeto próprio do Aprovaura.

## 7. Comparação de provedores

| Critério | Gemini Developer API (grátis) | Gemini Developer API (pago) | Vertex AI | OpenAI API |
|---|---|---|---|---|
| Uso por adolescentes | **Vedado**: termos de 23/03/2026 exigem 18+ e proíbem apps "directed towards or likely to be accessed by" menores de 18 | idem (mesmos termos) | termos do Google Cloud; **não verificados nesta sessão** | Service Terms lidos não tratam menores; remetem à Usage Policy (**não lida**) |
| Dados para treino | **Sim**: conteúdo usado para melhorar produtos; revisores humanos podem ler | Não usado; logs limitados para abuso | Em geral não (a confirmar na documentação do Cloud) | Não por padrão (dados da API) |
| Retenção | n/d | limitada | configurável (a confirmar) | log de abuso até 30 dias; ZDR só com aprovação |
| Custo | R$ 0, cota baixa e 503 frequentes | por token, exige faturamento | por token, exige faturamento no Google Cloud | por token |
| Custo por correção (~1,8k tokens) | 0 | ~US$ 0,0005–0,002 (preços não verificados) | ~US$ 0,0005–0,002 (não verificado) | ~US$ 0,002 com GPT-5 mini (US$ 0,25/2,00 por 1M, fonte de agregador) |
| Disponibilidade medida | ruim (503) | não testado | não testado | não testado |
| Exige contratar | não | **sim** | **sim** | **sim** |

Preços citados vêm de agregadores, não das páginas oficiais; conferir antes de decidir.

## 8. Recomendação

1. **Manter suspenso.** O Gemini Developer API (gratuito ou pago) não pode atender um app cujo público inclui
   estudantes menores de 18 anos, e o nível gratuito ainda treina com o conteúdo. Isso é uma restrição contratual,
   não de qualidade. O Aprovaura segue aberto a todas as idades.
2. Candidatos a avaliar com autorização de custo: **Vertex AI** (termos do Google Cloud; menor troca de modelo e
   prompt) ou **OpenAI API** (sem treino por padrão; conferir a Usage Policy para menores e o consentimento
   parental/aviso na Política de Privacidade). Nenhum foi contratado ou testado.
3. Qualquer escolha exige: aviso na Política de Privacidade (serviço 4), chave própria do Aprovaura, teto global
   diário e orçamento, e nova bateria sintética em tempo real (disponibilidade, 5 competências, consistência).
4. Se mantiver o Gemini temporariamente para testes internos: trocar `GEMINI_MODEL` para `gemini-3.1-flash-lite`.
