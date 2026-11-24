# Correção de redação por IA e menores de idade

> Recomendação técnica, **não** orientação jurídica. Preços e termos de provedores mudam: **conferir nas páginas oficiais antes de contratar** (não verificados nesta sessão; a coluna de outros provedores é conhecimento geral, não pesquisa de hoje). Nenhum serviço foi contratado e o provedor não foi trocado.

## Decisões definitivas do dono (24/11/2026)
- Não contratar OpenAI nem qualquer serviço de IA pago; não procurar novos provedores pagos.
- **Gemini mantido como integração existente**, com a chave compartilhada com o ia-audio; **envio de redações SUSPENSO** (`ESSAY_AI_PROVIDER=disabled`) até existir solução compatível com os termos do provedor e com o público adolescente.
- O AprovaAura **não** vira app exclusivo para 18+: preserva estudantes do ENEM e vestibulandos.
- IA **somente** para correção de redações; limite configurável de **3 correções/dia** preservado; **sem chatbot ou conversa livre**.
- Monetização e AUTO_DEPLOY seguem desativados; nenhum custo gerado.

## Estado atual
`evaluate-essay` usa Gemini (`GEMINI_MODEL`, camada gratuita). No prompt vão só proposta, textos motivadores e redação (sem identificadores). O limite de 3 correções/dia continua configurável no admin. Documentação do Google (registrada em `docs/release/FATOS_ETAPA09.md`): na camada gratuita o conteúdo pode ser usado para melhorar produtos e revisado por humanos, e o serviço é para 18+.

## Preparado nesta etapa
- **Interruptor:** `ESSAY_AI_PROVIDER=disabled` (Supabase Secret) faz a função responder `not_configured` (o app já trata) **antes** de debitar cota ou enviar texto. Valor desconhecido também suspende (falha fechada). Para voltar: `google`. Código em `supabase/functions/_shared/essay_provider.ts` (testado). **Pendente:** publicar a função (precisa de PAT).
- Redação e submissão nunca se perdem em caso de falha (já era assim).

## Comparação de alternativas
| Critério | Gemini API paga | Claude API | OpenAI API | Modelo aberto próprio |
|---|---|---|---|---|
| Menores | termos exigem 18+ para usuário final: análise jurídica | idem (salvaguardas do operador) | idem | você define e assume tudo |
| Treino com seus dados | pago: em geral não (conferir) | API: em geral não (conferir) | API: em geral não (conferir) | total controle |
| Revisão humana / retenção | retenção para abuso (conferir) | retenção curta; opção de retenção zero sob contrato (conferir) | idem (conferir) | você decide |
| Qualidade em redação ENEM | boa | muito boa | muito boa | variável; exige avaliação |
| Custo por redação | centavos; 3/dia cabe no preço do plano | centavos a dezenas de centavos conforme o modelo | centavos | infraestrutura fixa |
| Integração | pronta | trocar `callGemini` e o schema | idem | hospedagem e manutenção |
| Brasil | sim | sim | sim | n/a |

**Recomendação objetiva:**
1. Para menores e para qualquer lançamento comercial, **não usar a camada gratuita**.
2. Manter a correção por IA suspensa (interruptor) para faixa etária menor/desconhecida até haver decisão jurídica.
3. Escolher entre Gemini pago e outro provedor por teste cego com redações **sintéticas** (qualidade) e leitura dos termos de dados vigentes.
4. Migrar só com custo aprovado pelo dono. Trocar de provedor é editar `callGemini`, `PROVIDER` e `MODEL`.

## Menores: análise preparada (decisão do dono + advogado)
| Faixa | Situação hoje | Decisão necessária |
|---|---|---|
| Menos de 13 | declarável; sem compartilhamento; sem data de nascimento | permitir ou barrar; consentimento parental verificável |
| 13 a 15 e 16 a 17 | declarável; sem compartilhamento com professor | base legal e consentimento do responsável (LGPD art. 14, melhor interesse) |
| Adulto | compartilhamento revogável de estatísticas com professor | nenhuma |
| Desconhecida | tratada como menor (nunca compartilha) | nenhuma |

Pontos abertos: idade mínima; avaliação etária proporcional (autodeclaração x verificação); assinatura por menores; vínculo com professor; IA com menores. **DPO e RIPD:** o app trata dados de adolescentes em escala e pode enviar texto a terceiros; recomenda-se nomear encarregado e elaborar RIPD antes do lançamento, com assessoria jurídica. O app **não** foi tornado 18+ unilateralmente.
