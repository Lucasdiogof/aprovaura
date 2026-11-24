# Avaliação da OpenAI API para a correção de redação (Etapa 10C, serviço 3)

Data: 2026-11-24. **Avaliação documental e financeira.** Nada foi contratado, nenhuma chamada paga ou gratuita foi feita à OpenAI, o Gemini não foi reativado e a correção segue suspensa (`ESSAY_AI_PROVIDER=disabled`). Recomendação técnica, **não** orientação jurídica.

## 1. Veredito

| Pergunta | Resposta |
|---|---|
| Tecnicamente viável? | **Sim**, com ajuste pequeno no schema de saída e troca da função `callGemini` por uma chamada à OpenAI. |
| Financeiramente viável? | **Sim com modelo econômico** (`gpt-6-luna`: 0,3% a 1,9% do líquido por assinante) ou intermediário (`gpt-6.1-terra`: 3% a 19%), **desde que haja teto global e orçamento**. `gpt-6.2-sol` só com franquia menor. |
| Qualidade em português e nas 5 competências do ENEM? | **Não comprovada.** Não há teste: exige chamadas pagas (≈ US$ 6,47 para a bateria proposta) e autorização. |
| Uso por adolescentes autorizado? | **Não está autorizado automaticamente.** A OpenAI tem regras adicionais para menores e exige medidas do operador; menores de 13 anos têm condição própria (retenção zero). A decisão depende do dono e de assessoria jurídica (LGPD). |
| Pode reativar a correção pública? | **Não.** Condições na seção 11. |

## 2. Fontes e limites da leitura

Lidas em 24/11/2026 por agentes de leitura (resumos conferidos por mim contra o que as páginas permitem afirmar; **recomenda-se conferência humana das páginas antes de contratar**):

- Orientação para menores de 18 na API: `developers.openai.com/api/docs/guides/safety-checks/under-18-api-guidance` (a página **não mostra data**).
- Políticas de uso: `openai.com/policies/usage-policies/` (vigência 20/11/2026).
- Preços: **`developers.openai.com/api/docs/pricing`**. A URL `openai.com/api/pricing/` pedida no roteiro renderiza só preços de assinatura ChatGPT Business/Enterprise, não de API. A página de preços **não mostra data nem versão**.
- Dados e retenção: `.../guides/your-data`, `openai.com/enterprise-privacy/` (atualizada 08/01/2026), residência de dados, termos de serviço (13/11/2026), adendo de tratamento de dados (vigente 01/01/2026), Structured Outputs e Moderação.
- **Não lidos:** Termos de Uso (idade mínima de usuários finais costuma estar aí), lista de suboperadores, guias de CSAM e de processamento privado de segurança. Itens marcados "não informado" abaixo significam que as páginas lidas não dizem, não que a OpenAI não tenha regra.
- Partes de Structured Outputs e de residência vieram só de resumo automático da página; foram tratadas como indicativas.

## 3. Menores e uso educacional

**Orientação específica para menores de 18 (API):**
- **Obrigatório:** cumprir as leis de proteção da criança, citando COPPA; tomar "medidas razoáveis" para que o conteúdo entregue a menores seja seguro e adequado à idade. Exemplos listados (não obrigatórios um a um): avisos adequados à idade sobre o uso de IA, filtros de conteúdo sensível, monitoramento e canais de escalonamento para interações de risco, verificação de idade quando apropriada.
- **Dados de menores de 13 anos (ou da idade de consentimento digital aplicável):** a página diz que não devem ser processados sem antes ter retenção zero (ZDR) ativa. É redação de "não deve", mas tratamos como regra.
- **Recomendações:** cuidado reforçado com dados de menores, uso das ferramentas de segurança oferecidas, modelos mais atuais. A OpenAI se reserva o direito de auditar e pode advertir, suspender ou encerrar.
- **Não informado na página:** idade mínima do usuário final, consentimento parental, exigência de moderação, retenção de logs, identificador de usuário por requisição (`safety_identifier`).

**Políticas de uso (vigentes desde 20/11/2026):** proíbem expor menores a conteúdo impróprio, mas **não proíbem uso educacional**. Proíbem facilitar fraude acadêmica. Há uma regra sobre **ações automatizadas de alto impacto em áreas sensíveis (inclui educação) sem revisão humana** e uma proibição de **inferir emoções em contexto educacional**. Nada trata de correção de redação diretamente, nem exige aviso de "conteúdo gerado por IA" ao usuário final (só recomendado para menores).

**Leitura para o AprovaAura:**
- A correção é **formativa**: a nota é "estimativa de treino, não a nota oficial do ENEM" (o prompt já diz isso). Isso a afasta de "decisão de alto impacto", mas o texto precisa ficar **visível na tela do aluno**, e o portal do professor **não** pode usar a nota da IA como avaliação formal.
- O prompt não infere emoções e não deve passar a fazê-lo.
- Proposta de regra por faixa etária (já existem as faixas no banco: `get_my_age_band`):

| Faixa | Proposta | Condição |
|---|---|---|
| Menos de 13 e **desconhecida** | **Sem IA externa** | só com ZDR aprovado, base legal e consentimento do responsável (decisão do dono + advogado) |
| 13 a 17 | IA **somente após decisão jurídica** | aviso na Política de Privacidade, aviso de uso de IA adequado à idade, filtro de moderação, canal de reporte; LGPD art. 14 |
| Adulto | permitido | aviso na Política |

A checagem tem de ser **no servidor** (dentro de `evaluate-essay`, antes de debitar cota e de enviar texto), não só na interface. Não implementada nesta rodada.

## 4. Privacidade, retenção e treino

| Tema | Achado |
|---|---|
| Treino | **Dados da API não treinam modelos por padrão.** Só com opt-in explícito. |
| Retenção padrão | Logs de abuso por até 30 dias (salvo exigência legal). Chat Completions: sem estado de aplicação (cache de prompt até 24 h). Responses: estado por 30 dias conforme `store`. Batch e Files: até apagar. **Moderação: sem retenção.** |
| ZDR e Monitoramento de Abuso Modificado | Exigem **aprovação prévia e requisitos adicionais, via comercial** (critérios não detalhados). Cobrem Chat Completions, Responses e Moderação; **não cobrem Batch nem Files**. Mesmo com ZDR, conteúdo sinalizado por classificadores pode ser retido e revisto para riscos graves. |
| Acesso humano | Pessoal autorizado e contratados podem revisar dados armazenados para abuso. |
| Residência de dados | Regiões com processamento regional: EUA e Europa (+ algumas com modelos limitados). **Brasil e América do Sul não constam.** Residência cobre só conteúdo do cliente, não "dados de sistema" (o schema de saída é listado como dado de sistema). |
| Transferência internacional / LGPD | O adendo de tratamento de dados traz salvaguardas só para UE/Suíça e Reino Unido. **Nada específico para o Brasil/LGPD.** O cliente declara ter feito os avisos e obtido os consentimentos necessários. Exige análise jurídica (LGPD art. 33) e atualização da Política de Privacidade. |
| Segurança | Criptografia em repouso e em trânsito; SOC 2 Tipo 2. |
| Dados pessoais na redação | O adendo prevê que texto livre do usuário final pode conter dados pessoais. O app não envia identificadores, mas a redação pode citar nomes: tratar como dado pessoal. |

Consequência prática: **ZDR provavelmente não está ao alcance de um app pequeno** (depende de aprovação comercial), então o caminho para menores de 13 é simplesmente **não enviar**.

## 5. Moderação

`omni-moderation-latest`: **gratuita**, aceita texto, sem retenção, categorias incluem autoagressão e `sexual/minors`. A página recomenda usar os resultados como **sinal** para a política do app, não como bloqueio automático. Não é obrigatória. Proposta: moderar a redação **antes** de enviar ao modelo de correção (e a saída antes de mostrar), registrando só categorias e escores, nunca o texto. Autoagressão detectada deve levar a resposta acolhedora sem nota, a decidir no produto.

## 6. Structured Outputs e compatibilidade com o schema atual

Suportado com `json_schema` e `strict: true` (exemplos oficiais usam o modelo topo de linha; a lista de modelos compatíveis **não** é dada por modelo na página: confirmar no teste). Tratar recusa e resposta incompleta (`incomplete`).

Ajustes necessários no `RESPONSE_SCHEMA` de `evaluate-essay` (hoje no formato do Gemini):
1. Tipos em minúsculas (`object`, `integer`...).
2. `additionalProperties: false` em **todo** objeto.
3. **Todos** os campos em `required`: `evidence` hoje é opcional; passa a obrigatório (lista pode ser vazia).
4. `score` como `enum` `[0, 40, 80, 120, 160, 200]` (o código já valida múltiplos de 40; `minLength/maxLength` não são suportados, `minItems/maxItems` são).
5. Manter a conferência da soma e das evidências literais já existente.

Esforço: pequeno. O restante (cota, idempotência, estados, 502 recuperável) não muda.

## 7. Modelos e preços oficiais (US$ por 1M tokens, Standard, contexto curto)

| Modelo | Entrada | Entrada em cache | Saída | Observação |
|---|---|---|---|---|
| `gpt-6-luna` | 0,10 | 0,01 | 0,50 | indicado pela OpenAI para volume e custo; contexto 1,05M |
| `gpt-5.6-luna` | 0,20 | 0,02 | 1,20 | |
| `gpt-6.1-terra` | 1,00 | 0,05 | 5,00 | eficiente; contexto 1,05M |
| `gpt-5.4-mini` | 0,75 | 0,075 | 4,50 | |
| `gpt-6.2-sol` / `gpt-6.1-sol` | 2,00 | 0,10 | 10,00 | equilibrado |
| `gpt-6-astra` / `gpt-6.2-astra` | 10,00 / 8,00 | 1,00 / 0,40 | 50,00 / 40,00 | topo de linha: **fora de questão** |

- **Batch:** exatamente 50% do preço Standard (cálculo meu sobre a tabela; a página não imprime o percentual). **Inviável para a experiência síncrona** do aluno e **não coberto por ZDR**.
- Moderação: gratuita. Regiões/FedRAMP: +10%.
- Cobrança de tokens de raciocínio como saída: **não confirmada** na página; assumida (pior caso).
- **Descontinuações já anunciadas (não usar):** `gpt-5`, `gpt-5-mini`, `gpt-5-nano` (11/12/2026), `gpt-4o`, `gpt-4o-mini`, `gpt-4.1`, `gpt-4.1-mini` (14/01/2027), `gpt-5.4-nano` e `gpt-5.1` (01/04/2027).
- **Candidatos à bateria de testes:** `gpt-6-luna` (econômico), `gpt-6.1-terra` (equilíbrio), `gpt-6.2-sol` (qualidade). Preços dependem de tabela sem data: reconferir na página ao vivo.

## 8. Qualidade em português e nas cinco competências: NÃO COMPROVADA

Não há medição. O que se sabe: o prompt atual já pede as 5 competências em múltiplos de 40, evidências literais e tom pedagógico, e foi validado só contra o Gemini (3 respostas válidas, ver `IA_CORRECAO_AVALIACAO.md`). Nenhuma afirmação de qualidade da OpenAI em português foi verificada.

**Bateria proposta (exige autorização de custo):** 40 redações sintéticas (fraca, média, forte, curta, fuga ao tema, em outros idiomas, com tentativa de injeção de instrução dentro do texto) × 3 repetições × 3 modelos = 360 chamadas ≈ **US$ 6,47 (≈ R$ 39)**. Critérios de aceite sugeridos:
- ≥ 99% das chamadas concluídas (com no máximo 2 tentativas);
- 100% de JSON válido, notas múltiplas de 40 e evidências literais;
- consistência: em 3 repetições, diferença de até 1 nível (40 pontos) por competência em ≥ 90% dos casos;
- coerência de ordem: fraca < média < forte;
- `insufficient_text` e `possible_theme_deviation` corretos nos casos de controle;
- nenhuma obediência a instruções embutidas na redação; tom sem humilhação; nenhuma inferência de emoção;
- latência p95 aceitável para o app (meta ≤ 30 s).

## 9. Custos

Premissas (todas **hipóteses**; o uso real em produção é de 6 redações de 2 usuários de teste): US$ 1 = R$ 5,50 e folga de 10% para IOF/tributos de importação de serviço e câmbio; mensalidade R$ 19,90; líquido R$ 16,91 após taxa do provedor (R$ 2,99, caso A homologado); comissão do professor 50% do líquido (R$ 8,46 quando o aluno é vinculado). Tokens por correção: leve 2.400 + 1.000, moderado 2.400 + 3.000 (com raciocínio), máximo 4.000 + 6.000. Redações reais de ~900 palavras e a medição em Gemini (≈ 850 + 900) sustentam a faixa; **não** há medição com a OpenAI. Reprodutível por `python tool/qa/essay_ai_cost_model.py` (sem rede).

**Custo por correção (R$):**

| Modelo | leve | moderado | máximo |
|---|---|---|---|
| `gpt-6-luna` | 0,0045 | 0,0105 | 0,0206 |
| `gpt-6.1-terra` | 0,0448 | 0,1053 | 0,2057 |
| `gpt-6.2-sol` | 0,0895 | 0,2105 | 0,4114 |

**Por assinante/mês (moderado):**

| Perfil | Correções | `gpt-6-luna` | `gpt-6.1-terra` | `gpt-6.2-sol` |
|---|---|---|---|---|
| Ocasional | 2 | R$ 0,02 (0,1%) | R$ 0,21 (1,2%) | R$ 0,42 (2,5%) |
| Médio | 8 | R$ 0,08 (0,5%) | R$ 0,84 (5,0%) | R$ 1,68 (10,0%) |
| Intenso | 30 | R$ 0,32 (1,9%) | R$ 3,16 (18,7%) | R$ 6,32 (37,4%) |
| **Máximo da franquia (3/dia × 30)** | 90 | R$ 0,95 (5,6%) | **R$ 9,47 (56,0%)** | **R$ 18,95 (112%)** |

Percentuais sobre o líquido de R$ 16,91. **Pior caso extremo** (90/mês com tokens máximos): luna R$ 1,85; terra **R$ 18,51 (109% do líquido)**; sol R$ 37,03 (219%).

**Total mensal e margem (mistura esperada = 50% ocasional, 35% médio, 12% intenso, 3% no máximo: 10,1 correções/assinante/mês; moderado):**

| Assinantes | `gpt-6-luna` | `gpt-6.1-terra` | `gpt-6.2-sol` |
|---|---|---|---|
| 100 | R$ 11 | R$ 106 | R$ 213 |
| 500 | R$ 53 | R$ 532 | R$ 1.063 |
| 1.000 | R$ 106 | R$ 1.063 | R$ 2.126 |
| 5.000 | R$ 532 | R$ 5.316 | R$ 10.632 |

Na mistura esperada o custo é 0,6% (luna), 6,3% (terra) e 12,6% (sol) do líquido; a margem por assinante fica em R$ 16,80 / R$ 15,85 / R$ 14,78 sem professor e R$ 8,35 / R$ 7,39 / R$ 6,33 com professor. Na mistura de **estresse** (20% no máximo), terra consome 18,6% do líquido (margem R$ 13,77 sem professor, R$ 5,32 com). Tabelas completas de 100/500/1.000/5.000 por mistura (conservadora, esperada, estresse) no apêndice.

**Ponto de equilíbrio** (correções/mês por assinante para a IA consumir 10% / 25% / 50% da margem do Lucksrei com professor, R$ 8,46): luna 80 / 201 / 402; **terra 8 / 20 / 40**; sol 4 / 10 / 20.

**Outras sensibilidades:** câmbio R$ 5,00 a R$ 6,50 move terra/esperada/1.000 de R$ 967 a R$ 1.257 por mês; o cache do prompt estático economiza só ≈ 5% (a saída domina o custo); Batch cortaria 50%, mas é incompatível com a UX síncrona e com ZDR.

**Leitura financeira:** com `gpt-6-luna` o custo é desprezível mesmo no máximo da franquia; com `gpt-6.1-terra` é saudável na média e **perigoso no uso máximo** (56% do líquido por assinante), então precisa de **teto mensal por assinante** (ex.: 30 correções/mês, o que limita terra a ≈ R$ 3,16 = 18,7% do líquido) além do teto de 3/dia; `gpt-6.2-sol` só com franquia muito menor. A decisão de modelo depende da bateria de qualidade: se luna atingir os critérios, é a escolha.

## 10. Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Custo sem teto (hoje só há 3/dia por usuário, **sem teto global**) | limite de gasto mensal na conta OpenAI + teto global diário no app (RPC com contador) + teto mensal por assinante |
| Menores | regra por faixa etária no servidor (seção 3); aviso na Política e na tela; sem IA para <13 e desconhecida |
| Dados pessoais na redação | aviso ao aluno ("não inclua nomes/dados pessoais"); sem identificadores no prompt; moderação sem retenção; retenção de 30 dias nos logs da OpenAI informada na Política |
| Transferência internacional (sem região Brasil) | parecer jurídico; Política de Privacidade; contrato/DPA |
| Injeção de instrução na redação | já há schema estrito; incluir casos na bateria; delimitar o texto do aluno no prompt |
| Falhas 429/5xx | já é erro recuperável (502) e não debita cota; reaproveitar |
| Nota tratada como oficial | rótulo "estimativa de treino" visível; portal do professor sem a nota da IA |
| Mudança de preço/modelo/descontinuação | modelo e provedor em Secrets; reconferir a página de preços e a de descontinuações a cada trimestre |
| Chave | chave própria do AprovaAura (a do `ia-audio` é só para o Gemini e não deve ser usada aqui); no cofre com `project=aprovaura` |

## 11. Condições para reativar a correção (nenhuma cumprida hoje)

1. Decisão do dono e parecer jurídico sobre adolescentes (LGPD art. 14) e transferência internacional (art. 33); documentos legais e Política de Privacidade atualizados (serviço 4).
2. Regra por faixa etária implementada no servidor (`evaluate-essay`).
3. Conta própria da OpenAI com limite de gasto, chave no cofre; autorização de custo para a bateria (≈ US$ 6,47).
4. Bateria aprovada pelos critérios da seção 8; modelo escolhido.
5. Adaptação do schema e da chamada (seção 6) com testes; teto global e mensal; moderação.
6. Só então trocar `ESSAY_AI_PROVIDER` (o código hoje só reconhece `google` e `suspended`; seria preciso adicionar `openai`).

## 12. O que esta rodada não fez

Não contratou nem criou conta; não fez nenhuma chamada à API; não alterou código de produção nem Secrets; não reativou nem trocou o provedor; não leu os Termos de Uso nem a lista de suboperadores; não mediu qualidade. Monetização, provedores comerciais, confirmação obrigatória de e-mail e `AUTO_DEPLOY` seguem desligados.

---

## Apêndice: saída do modelo de custo (`tool/qa/essay_ai_cost_model.py`)

Premissas: US$1 = R$5.50; folga 10%; mensalidade R$19.9; líquido R$16.91 (taxa R$2.99); comissão 50% do líquido.

### Custo por correção (R$, com câmbio e folga)

| Modelo | leve (sem raciocínio) | moderado (com raciocínio) | máximo (texto longo + raciocínio alto) |
|---|---|---|---|
| gpt-6-luna | R$ 0.0045 | R$ 0.0105 | R$ 0.0206 |
| gpt-6.1-terra | R$ 0.0448 | R$ 0.1053 | R$ 0.2057 |
| gpt-6.2-sol | R$ 0.0895 | R$ 0.2105 | R$ 0.4114 |

### Custo mensal por assinante (cenário de tokens 'moderado')

| Modelo | ocasional | médio | intenso | máximo da franquia (3/dia x 30) |
|---|---|---|---|---|
| gpt-6-luna | R$ 0.02 (0.1% do líquido) | R$ 0.08 (0.5% do líquido) | R$ 0.32 (1.9% do líquido) | R$ 0.95 (5.6% do líquido) |
| gpt-6.1-terra | R$ 0.21 (1.2% do líquido) | R$ 0.84 (5.0% do líquido) | R$ 3.16 (18.7% do líquido) | R$ 9.47 (56.0% do líquido) |
| gpt-6.2-sol | R$ 0.42 (2.5% do líquido) | R$ 1.68 (10.0% do líquido) | R$ 6.32 (37.4% do líquido) | R$ 18.95 (112.1% do líquido) |

### Pior caso por assinante (90 correções/mês com tokens 'máximo')

- gpt-6-luna: R$ 1.85/mês = 11% do líquido de R$16.91
- gpt-6.1-terra: R$ 18.51/mês = 109% do líquido de R$16.91
- gpt-6.2-sol: R$ 37.03/mês = 219% do líquido de R$16.91

### Custo mensal total e margem (tokens 'moderado')


**gpt-6-luna**

| Mistura | Corr./assin./mês | Assinantes | Custo IA/mês | % do líquido | Margem/assin. sem professor | Margem/assin. 100% com professor |
|---|---|---|---|---|---|---|
| conservadora | 4.9 | 100 | R$ 5 | 0.3% | R$ 16.86 | R$ 8.40 |
| conservadora | 4.9 | 500 | R$ 26 | 0.3% | R$ 16.86 | R$ 8.40 |
| conservadora | 4.9 | 1000 | R$ 52 | 0.3% | R$ 16.86 | R$ 8.40 |
| conservadora | 4.9 | 5000 | R$ 258 | 0.3% | R$ 16.86 | R$ 8.40 |
| esperada | 10.1 | 100 | R$ 11 | 0.6% | R$ 16.80 | R$ 8.35 |
| esperada | 10.1 | 500 | R$ 53 | 0.6% | R$ 16.80 | R$ 8.35 |
| esperada | 10.1 | 1000 | R$ 106 | 0.6% | R$ 16.80 | R$ 8.35 |
| esperada | 10.1 | 5000 | R$ 532 | 0.6% | R$ 16.80 | R$ 8.35 |
| estresse | 29.8 | 100 | R$ 31 | 1.9% | R$ 16.60 | R$ 8.14 |
| estresse | 29.8 | 500 | R$ 157 | 1.9% | R$ 16.60 | R$ 8.14 |
| estresse | 29.8 | 1000 | R$ 314 | 1.9% | R$ 16.60 | R$ 8.14 |
| estresse | 29.8 | 5000 | R$ 1,569 | 1.9% | R$ 16.60 | R$ 8.14 |

**gpt-6.1-terra**

| Mistura | Corr./assin./mês | Assinantes | Custo IA/mês | % do líquido | Margem/assin. sem professor | Margem/assin. 100% com professor |
|---|---|---|---|---|---|---|
| conservadora | 4.9 | 100 | R$ 52 | 3.1% | R$ 16.39 | R$ 7.94 |
| conservadora | 4.9 | 500 | R$ 258 | 3.1% | R$ 16.39 | R$ 7.94 |
| conservadora | 4.9 | 1000 | R$ 516 | 3.1% | R$ 16.39 | R$ 7.94 |
| conservadora | 4.9 | 5000 | R$ 2,579 | 3.1% | R$ 16.39 | R$ 7.94 |
| esperada | 10.1 | 100 | R$ 106 | 6.3% | R$ 15.85 | R$ 7.39 |
| esperada | 10.1 | 500 | R$ 532 | 6.3% | R$ 15.85 | R$ 7.39 |
| esperada | 10.1 | 1000 | R$ 1,063 | 6.3% | R$ 15.85 | R$ 7.39 |
| esperada | 10.1 | 5000 | R$ 5,316 | 6.3% | R$ 15.85 | R$ 7.39 |
| estresse | 29.8 | 100 | R$ 314 | 18.6% | R$ 13.77 | R$ 5.32 |
| estresse | 29.8 | 500 | R$ 1,569 | 18.6% | R$ 13.77 | R$ 5.32 |
| estresse | 29.8 | 1000 | R$ 3,137 | 18.6% | R$ 13.77 | R$ 5.32 |
| estresse | 29.8 | 5000 | R$ 15,685 | 18.6% | R$ 13.77 | R$ 5.32 |

**gpt-6.2-sol**

| Mistura | Corr./assin./mês | Assinantes | Custo IA/mês | % do líquido | Margem/assin. sem professor | Margem/assin. 100% com professor |
|---|---|---|---|---|---|---|
| conservadora | 4.9 | 100 | R$ 103 | 6.1% | R$ 15.88 | R$ 7.42 |
| conservadora | 4.9 | 500 | R$ 516 | 6.1% | R$ 15.88 | R$ 7.42 |
| conservadora | 4.9 | 1000 | R$ 1,032 | 6.1% | R$ 15.88 | R$ 7.42 |
| conservadora | 4.9 | 5000 | R$ 5,158 | 6.1% | R$ 15.88 | R$ 7.42 |
| esperada | 10.1 | 100 | R$ 213 | 12.6% | R$ 14.78 | R$ 6.33 |
| esperada | 10.1 | 500 | R$ 1,063 | 12.6% | R$ 14.78 | R$ 6.33 |
| esperada | 10.1 | 1000 | R$ 2,126 | 12.6% | R$ 14.78 | R$ 6.33 |
| esperada | 10.1 | 5000 | R$ 10,632 | 12.6% | R$ 14.78 | R$ 6.33 |
| estresse | 29.8 | 100 | R$ 627 | 37.1% | R$ 10.64 | R$ 2.18 |
| estresse | 29.8 | 500 | R$ 3,137 | 37.1% | R$ 10.64 | R$ 2.18 |
| estresse | 29.8 | 1000 | R$ 6,274 | 37.1% | R$ 10.64 | R$ 2.18 |
| estresse | 29.8 | 5000 | R$ 31,370 | 37.1% | R$ 10.64 | R$ 2.18 |

### Ponto de equilíbrio: correções/mês por assinante em que a IA consome 10% / 25% / 50% da margem do Lucksrei (com professor, R$ 8.46)

- gpt-6-luna: 80 / 201 / 402
- gpt-6.1-terra: 8 / 20 / 40
- gpt-6.2-sol: 4 / 10 / 20

### Sensibilidade ao câmbio (gpt-6.1-terra, moderado, mistura esperada, 1000 assinantes)

- US$1 = R$5.00: R$ 967/mês
- US$1 = R$5.50: R$ 1,063/mês
- US$1 = R$6.00: R$ 1,160/mês
- US$1 = R$6.50: R$ 1,257/mês

### Efeito do cache do prompt estático (900 de 2.400 tokens de entrada), gpt-6.1-terra, moderado

- sem cache US$ 0.01740; com cache US$ 0.01655 (4.9% menos). A saída domina o custo; cache importa pouco.

### Custo da bateria de avaliação futura (NÃO executada; exige autorização)

- 40 redações x 3 repetições x 3 modelos = 360 chamadas ≈ US$ 6.47 (≈ R$ 39.16).
