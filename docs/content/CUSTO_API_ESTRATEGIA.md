# Custo de API Anthropic para produzir/validar questões — estratégia

Consulta às fontes em **2026-11-27**. Nenhuma chamada à API foi feita; nenhuma chave/conta/cofre foi tocado.

## 1. Achados CONFIRMADOS em fonte oficial

Fonte: https://support.claude.com/en/articles/17154008-api-credits-for-max-and-team-plans (artigo "Monthly API Credits for Max, Ultra, and Team Plans"); preços e limites: https://platform.claude.com/docs/en/about-claude/pricing e https://platform.claude.com/docs/en/api/rate-limits.

- Existe crédito mensal de API no plano **Max: US$ 100/mês** (Ultra US$ 200; Team Standard US$ 20/assento, Premium US$ 100/assento, pool máx. US$ 500). Free, Pro e Enterprise não têm.
- Elegibilidade: assinatura ativa e em dia, **7 dias no plano antes de resgatar**; só o assinante (Max) vincula; papel Owner/Admin/Billing na organização do Console. **Não exige forma de pagamento** na Claude Platform para resgatar ou usar.
- Concessão: em Settings > Billing, seção "API credits" > "Link organization". **Uma única organização do Console** por plano; trocar só via suporte. O crédito vai para essa organização todo ciclo de cobrança (planos anuais: mensalmente).
- Validade: **não acumula**; expira ao fim de cada ciclo. Créditos mensais são consumidos antes de créditos comprados. O saldo é compartilhado por todas as chaves da organização vinculada.
- Escopo: vale para Messages API, Message Batches API, Playground do Console, Managed Agents e Claude Agent SDK (com chave de API da organização vinculada), qualquer modelo. **Não vale** para Claude Code interativo, extra usage, Bedrock/Vertex/Foundry, GitHub Action/IDE/desktop. Agent SDK / `claude -p` logado com o plano consome o limite do plano, não o crédito.
- Saldo: página Billing do Console (platform.claude.com/settings/billing), com valor e data de expiração.
- Esgotamento: se a organização não tem outro crédito nem auto-reload, **as requisições param até o próximo crédito**; nunca é cobrado do plano Claude. Se houver crédito comprado ou auto-reload, o uso continua nele (risco de cobrança). Organização faturada por vendas: cobra o excedente.
- Spend limits (rate-limits doc): limite mensal da organização configurável em platform.claude.com/settings/spend-limits (nunca acima do teto do tier: Start US$ 500). Ao atingir o limite definido por você: HTTP 400 `invalid_request_error` ("You have reached your specified API usage limits"). Ao atingir o teto do tier: HTTP 429 `enforced_spend_limit_reached`, sem `retry-after`. Workspaces aceitam limite próprio; limite no workspace default pode não contar Playground nem Managed Agents (vale o limite da organização).
- Preços (US$/1M tokens, entrada/saída): Haiku 5.5 0,10/0,50 (prompt até 100k); Sonnet 5.5 2/10; Opus 5.5 4/20; Fable 5.2 8/40. Batch: -50% em entrada e saída. Cache: escrita 5 min = 1,25x, 1 h = 2x; leitura 0,1x (Sonnet 5.5 e Opus 5.5: 0,05x; Haiku 5.5: US$ 0,01). Descontos batch e cache se combinam. Tokenizer dos modelos 4.7+ gera ~30% mais tokens.
- Rate limits tier Start: Sonnet 5.5 4.000 RPM / 2M ITPM / 400k OTPM; Batches 1.000 RPM, 200k requisições na fila, 100k por batch. Organizações novas podem começar no tier "Evaluation" com limites menores (o tier real só aparece no Console).

## 2. NÃO verificado / inferência

- Se a organização do dono **já resgatou/vinculou** o crédito, o saldo atual, a data de expiração e se há crédito comprado ou auto-reload ligado: só o Console mostra.
- Se há cartão salvo na organização vinculada e qual o limite de gasto atual: desconhecido.
- Texto exato das "Supplemental Credit Terms" (restrições de uso do crédito) não foi lido.
- Mecânica de auto-reload: o artigo não a detalha; presume-se desligada por padrão, **sem confirmação**.
- Há fontes secundárias (imprensa) divergindo em detalhes (ex.: "por ciclo" vs "por mês"); prevalece o artigo oficial.
- Contagem de tokens por questão abaixo é premissa, não medição; medir com a primeira dezena de itens (ou `count_tokens`, que não consome crédito de geração) antes de escalar.
- O crédito pode estar em fase de liberação gradual ("rolling out over several days" no artigo).

## 3. Estimativa de custo por questão

Premissas (tokens: entrada total / parte cacheável / saída): autoral 1500/1200/900; validação de gabarito 1500/1000/400; revisão de explicação 1300/900/500; classificação 900/700/100; tradução en+es 1200/600/1300. Cache em batch assume só 50% de acertos. Gerado por `python tool/content/api/estimar.py --tabela`.

Custo por questão, pipeline completo (as 5 tarefas), e quantas cabem em US$ 100 com margem de 30% (teto US$ 76,9):

| Modelo | Padrão | Batch | Batch + cache | Questões (batch+cache) | Questões (padrão) |
|---|---|---|---|---|---|
| Haiku 5.5 | 0,0022 | 0,0011 | 0,0010 | ~73.000 | ~34.000 |
| Sonnet 5.5 | 0,0448 | 0,0224 | 0,0209 | ~3.680 | ~1.717 |
| Opus 5.5 | 0,0896 | 0,0448 | 0,0418 | ~1.840 | ~858 |
| Fable 5.2 | 0,1792 | 0,0896 | 0,0833 | ~920 | ~429 |

Por tarefa (Sonnet 5.5, batch+cache, US$/questão): autoral 0,0056; validação 0,0032; revisão 0,0035; classificação 0,0012; tradução 0,0075. Haiku 5.5 custa ~20x menos, mas não é adequado para autoria/gabarito de Direito ou cálculo sem checagem; serve para classificação e triagem. Orçamento prático: autoria + validação independente em Sonnet 5.5 batch ≈ US$ 0,009/questão → ~8.000 questões/mês em tese (ex.: 3.000 questões novas com validação ≈ US$ 27), bem abaixo do teto.

## 4. Riscos de cobrança

1. Crédito esgotado + **crédito comprado ou auto-reload ligado** → cobrança real no cartão. Principal risco.
2. Crédito expira ao fim do ciclo; saldo não acumula (planejar consumo dentro do ciclo).
3. Spend limit do **workspace default** pode não conter Playground/Managed Agents; o limite da organização é o que vale.
4. Chave de organização diferente da vinculada (sem crédito) → pode cair em cobrança paga se houver cartão.
5. Agent SDK logado com plano (não chave) consome o limite do plano Max, não o crédito (impacta o uso interativo do dono).
6. Batches só contabilizam ao terminar: o executor reserva o pior caso (`max_tokens`) antes de enviar; estimativas são aproximadas (chars/3) e o tokenizer novo infla ~30%.
7. Retry cego em 429 de spend limit não resolve (sem `retry-after`); o executor interrompe.

## 5. Recomendação: NO-GO até confirmação do dono; depois GO controlado

Regra: **só executar se o dono confirmar no Console**, e o executor exige o arquivo `AUTORIZADO`:
- [ ] Organização do Console vinculada ao plano Max (Billing > API credits) e saldo promocional visível com validade.
- [ ] Saldo de crédito **comprado** = US$ 0 e **auto-reload desligado**.
- [ ] Spend limit mensal da organização definido (sugestão: US$ 80) em Spend limits, e workspace dedicado "aura-conteudo" com limite igual ou menor; chave de API criada **nesse workspace** pelo dono (nunca no cofre sem pedido).
- [ ] Sem forma de pagamento salva, se possível (o artigo diz que não é necessária) — elimina o risco 1.
Se qualquer item não puder ser confirmado, apenas documentar/estimar. Se confirmado: começar com piloto de ~50 questões (Sonnet 5.5, batch), comparar uso real (`uso/uso.jsonl`) com `estimar.py`, ajustar premissas, depois escalar. Preferir Sonnet 5.5 batch para autoria e validação (modelo ou prompt diferente do autor; "autor nunca aprova o próprio conteúdo" — ver `pipeline/SCHEMA.md`), Haiku 5.5 para classificação. Não usar os provedores de correção de redação do app. Texto jurídico/mutável continua exigindo `referencias` e revisão humana.

Scripts: `tool/content/api/` (README lá).
