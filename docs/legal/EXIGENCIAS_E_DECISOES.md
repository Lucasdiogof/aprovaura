# Exigências, recomendações e decisões jurídicas do AprovaAura (27/11/2026)

> Organização do que já se sabe. **Não é parecer jurídico.** Dados cadastrais só os já públicos nos documentos; nada foi inventado. Fontes: `docs/release/FATOS_ETAPA09.md`, `docs/legal/README.md`, leitura da Resolução CD/ANPD 2/2022 em portal de terceiros (conferir no DOU/ANPD antes de decidir).

## 1. Dados institucionais que JÁ temos
| Dado | Valor | Fonte |
|---|---|---|
| Responsável | Lucas Diogo Franca (marca Lucksrei) | site oficial, minutas |
| CNPJ | 54.868.173/0001-55 | site oficial, minutas |
| Canal de suporte e privacidade | marketing@lucksrei.com | `…/support/` publicado |
| URLs públicas | Termos, Privacidade, Exclusão de conta, Suporte em `lucksrei.com/projects/aura/` | FATOS §1 |
| Operadores | Supabase, Cloudflare, Groq (IA, suspensa), Resend, Apple, Google Play, Mercado Pago | FATOS §2 |
| Exclusão de conta | dentro do app (`delete-account`) e página web | implementado |

## 2. Dados que SÓ VOCÊ pode fornecer
1. **Endereço do responsável** (único dado cadastral faltante; aparece nos Termos e na Política). Pode ser o endereço comercial do CNPJ.
2. **Prazo de guarda fiscal** dos dados financeiros: pergunta ao contador (as minutas deixam marcador).
3. **Decisão de idade mínima** (ver §6).
Os demais marcadores `[PENDENTE-DONO]` dependem de decisão ou de advogado, não de dado cadastral.

## 3. Exigências legais (verificadas nas fontes)
- **Identificação do fornecedor** na contratação eletrônica (Decreto 7.962/2013): nome, CNPJ e **endereço físico e eletrônico**, atendimento para cancelar, resposta em até 5 dias. Por isso o endereço é necessário para publicar os Termos.
- **CDC art. 49:** arrependimento de 7 dias. Aplicação a assinatura in-app é prática, jurisprudência incerta; compra via Apple/Google segue a política da loja.
- **LGPD:** informar controlador, finalidades, bases legais, direitos do titular, compartilhamentos e transferência internacional; eliminação ao fim do tratamento; consentimento para crianças (<12) por um responsável.
- **Encarregado (DPO): você NÃO é obrigado a contratar um externo.** A Resolução CD/ANPD 2/2022 (art. 11) dispensa agentes de pequeno porte de indicar encarregado, desde que ofereçam **um canal de comunicação com o titular** (o e-mail de privacidade já cumpre). Pequeno porte inclui microempresa, empresa de pequeno porte e **MEI**, dentro dos limites de receita da LC 123/2006. A dispensa se perde se o tratamento for de **alto risco** (art. 3º e 4º: exige um critério geral, como larga escala ou afetação significativa, mais um específico, como dados de crianças/adolescentes, dados sensíveis, tecnologia emergente ou decisão só automatizada). Hoje o volume é pequeno e a IA está suspensa; reavaliar se crescer. A ANPD pode exigir o que foi dispensado (art. 16). Indicar você mesmo como encarregado é só boa prática.
- **Marco Civil art. 15:** guardar registros de acesso por 6 meses (provedor PJ com fins econômicos).
- **Menores:** LGPD art. 14 (melhor interesse), ECA Digital (Lei 15.211/2025, em vigor desde 17/03/2026; Decreto 12.880/2026). Autodeclaração de idade é insuficiente para certas atividades; o nível exigido para app educacional não está confirmado por escrito pela ANPD.

## 4. Exigências das lojas
- **Apple:** política de privacidade com URL, **exclusão de conta dentro do app** (feito), conta demo para revisão, **Restaurar compras** (feito), descrever o que a assinatura entrega antes de cobrar, primeira assinatura junto com nova versão, classificação etária (web irrestrita tende a 16+), App Privacy (sem Kids Category).
- **Google Play:** declaração de segurança dos dados (Data Safety), URL de exclusão de conta, divulgação clara de preço, renovação e cancelamento, nome de SKU não enganoso, declarar o estatuto de comerciante até 01/02/2027 (aviso do console).
- Ambas: dados bancários/fiscais da conta de desenvolvedor (Apple já ativo; Google com perfil de pagamentos criado).

## 5. Recomendações (não obrigatórias)
Indicar encarregado por boa prática; elaborar RIPD simples (especialmente por causa de menores e IA); registrar o canal de privacidade também na Política; revisão por advogado de Termos e Política antes da ativação; manter a IA de redação desligada até o parecer.

## 6. Decisões comerciais suas
Idade mínima do serviço (hoje o app **não** é restrito a 18+; faixa "menor de 13" aceita); manter ou não assinatura por menores de 18 (responsável paga via Family Sharing/Ask to Buy/Family Link); Apple anual em R$ 189,90 (feito) e demais lojas em R$ 190,00; plano pago do Resend; Small Business Program da Apple; PITR do banco.

## 7. O que realmente exige análise jurídica (única parte que pode custar)
1. **Menores e ECA Digital:** idade mínima, necessidade de verificação de idade além da autodeclaração, consentimento parental para <12, vínculo com professor e assinatura para 16–17 anos.
2. **Envio de redações de menores a provedores de IA** (Groq, Cloudflare) e transferência internacional (LGPD art. 33), além dos contratos/DPA dos provedores.
3. **Revisão final dos Termos e da Política** (incluindo CDC art. 49 em assinatura digital e retenção fiscal).
Dá para lançar **sem a IA** e com público a partir da idade que o advogado validar; o item 2 só trava a IA. Orçamento: uma consulta pontual costuma bastar; não há obrigação de contratar DPO externo.
