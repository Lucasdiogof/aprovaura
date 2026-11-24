# Fatos verificados — Etapa 09 (fonte única para todos os documentos)

> Data-base: 24/11/2026. Documentos derivados DEVEM citar estes fatos e NÃO inventar nada além deles.
> Itens marcados **[PENDENTE-DONO]** ou **[INCERTO]** nunca viram afirmação nos textos finais.

## 1. Produto e preços
- App: AprovaAura (Flutter + Supabase). Bundle/app id `com.lucasdiogof.aprovaura` (não alterar).
- Planos: R$ 19,90/mês; R$ 190,00/ano (~20% de economia vs. 12 × 19,90 = 238,80; 190/238,80 = 20,4%).
- Teste: 72 h após a confirmação efetiva do e-mail, sem cartão, sem cobrança automática. Usuários já existentes NÃO ganham teste novo.
- Android = Google Play Billing; iOS = StoreKit (App Store); Web = Mercado Pago (cartão recorrente ou Pix avulso com renovação manual).
- Conta única entre plataformas. Idiomas PT-BR/EN/ES. Mercado inicial: Brasil. Temas claro/escuro.
- Nunca dizer "grátis para sempre" nem prometer aprovação.
- Professor parceiro: 50% de comissão sobre o líquido (configurável por parceiro), pagamento manual por Pix todo dia 1º, sem mínimo. Parceria por convite; sem cadastro público de professor; sem contrato digital.
- Endereços: App https://aprovaura.lucksrei.com · Portal https://aprovaura.lucksrei.com/partners · Site https://lucksrei.com/projects/aura/ · Privacidade (NÃO quebrar) https://lucksrei.com/projects/aura/privacy/
- Termos: https://lucksrei.com/projects/aura/terms/ · Exclusão de conta: https://lucksrei.com/projects/aura/data-deletion/ · Suporte: https://lucksrei.com/projects/aura/support/
- Dados do responsável **[PENDENTE-DONO]**: razão social, CNPJ, endereço, e-mail/canal de suporte oficial, encarregado (DPO). NUNCA inventar; usar o marcador `[PENDENTE-DONO: …]`.

## 2. Dados tratados e operadores (verificado no código)
- Supabase (banco, autenticação, Edge Functions, Storage): conta, perfil, progresso de estudo, respostas, redações, vínculo com professor, consentimentos, pagamentos (valores/ids de transação; sem número de cartão), aceites de documentos.
- Cloudflare: hospedagem web/Worker, entrega de conteúdo.
- Google Gemini (API, avaliação de redações): o texto enviado contém apenas tema, textos de apoio, texto da redação e critérios — SEM identificadores do usuário. Hoje usa a camada GRATUITA.
- Resend: e-mails transacionais (código de confirmação etc.) — a configurar.
- Apple (StoreKit/App Store), Google Play (Billing), Mercado Pago: cobrança. O app não vê dados de cartão.
- Faixa etária: só a faixa declarada (under_13 | 13_15 | 16_17 | adult), nunca data de nascimento.
- Compartilhamento com professor: só estatísticas de desempenho; nunca redação completa, senhas, credenciais, dados financeiros privados ou respostas individuais desnecessárias. Revogável no Perfil → Privacidade e termos; revogar NÃO apaga comissões nem desfaz o vínculo comercial.

## 3. Gemini API — termos oficiais (https://aistudio.google.com/docs/terms, "Effective March 23, 2026")
- Camada gratuita: Google pode usar conteúdo/respostas para melhorar produtos; revisores humanos podem ler; diz para NÃO enviar dados pessoais/sensíveis/confidenciais; sem prazo geral de retenção informado.
- Camada paga: Google afirma que não usa prompts/respostas para melhorar produtos; registra por período limitado para abuso/obrigações legais; dados podem ser armazenados em qualquer país onde o Google opere. Prazo exato dos logs: [INCERTO].
- Termos exigem 18+ e vedam clientes da API "direcionados a ou provavelmente acessados por" menores de 18.
- **BLOQUEADOR DE LANÇAMENTO [PENDENTE-DONO]**: (a) migrar para a camada paga antes de enviar redações de usuários reais em escala comercial; (b) decidir a posição quanto a menores de 18 anos × termos do Gemini (restringir correção por IA a 18+, ou parecer jurídico). Nos textos públicos NÃO afirmar "sem treinamento" para a camada atual.

## 4. Menores — pesquisa legal (não é parecer jurídico)
- ECA Digital (Lei 15.211/2025), em vigor desde 17/03/2026; Decreto 12.880/2026; ANPD regula/fiscaliza. Fiscalização prevista a partir de jan/2027 (confirmar). Aplica-se a serviços "direcionados a crianças e adolescentes ou de acesso provável por eles": app de ENEM/vestibular provavelmente se enquadra (inferência; a ANPD não confirmou por escrito [INCERTO]).
- Autodeclaração de idade é expressamente insuficiente para pornografia/redes sociais/compras proibidas; para app educacional sem conteúdo restrito o decreto não exige verificação de alto grau (nível exato "proporcional" depende de regras da ANPD [INCERTO]).
- Obrigações prováveis: padrões de maior proteção, informação clara a responsáveis, design sem uso compulsivo/dark patterns, transparência de IA generativa, sem perfilamento comportamental para publicidade a menores, canal de denúncia, supervisão parental.
- LGPD art. 14: melhor interesse; consentimento específico de ao menos um dos pais para CRIANÇAS (<12, ECA art. 2º); Enunciado CD/ANPD 1/2023: outras bases legais são possíveis se prevalecer o melhor interesse.
- Código Civil: <16 absolutamente incapaz; 16–17 relativamente incapaz (contrato anulável sem assistência); art. 180.
- Implementado (seguro por padrão): só quem declarou `adult` no servidor pode compartilhar estatísticas individuais; menor/desconhecido nunca compartilha; declarar-se menor encerra compartilhamento ativo. Não há data de nascimento, nem perfilamento, nem publicidade comportamental.
- **DECISÕES DO DONO [PENDENTE-DONO] (bloqueadores)**: idade mínima do serviço (13? 16? 18?); permitir <12 e como obter consentimento parental; modelo de vínculo com professor para menores e base legal; assinatura por menores (pagamento por responsável: Family Sharing/Ask to Buy, Family Link); RIPD/DPO; revisão por advogado.

## 5. Consumidor
- CDC art. 49: arrependimento em 7 dias para contratação à distância, devolução integral. Aplicação a assinatura digital in-app: prática consolidada, mas [INCERTO] quanto a jurisprudência/Senacon. Compra via Apple/Google: reembolso é processado pela loja conforme a política dela [INCERTO].
- Decreto 7.962/2013: identificação do fornecedor, características essenciais, resumo do contrato, confirmação imediata, atendimento eletrônico para cancelar, resposta em até 5 dias, arrependimento pelo mesmo meio.
- Marco Civil art. 15: registros de acesso por 6 meses (provedor PJ com fins econômicos). LGPD arts. 15–16: eliminação ao fim do tratamento, ressalvadas obrigações legais; retenção fiscal (geralmente 5 anos) [INCERTO — confirmar com contador].
- Não existe lei federal sancionada de "cancelamento pelo mesmo canal" (há projeto); boa prática: cancelar em poucos cliques.

## 6. Requisitos das lojas (fontes oficiais, 24/11/2026)
### Apple
- Limites: Nome 2–30; Subtítulo ≤30; Texto promocional ≤170; Descrição ≤4000 (texto simples); Palavras-chave ≤100 bytes; Novidades ≤4000. URL de privacidade obrigatória. (https://developer.apple.com/help/app-store-connect/reference/app-information/…)
- 3.1.1: IAP obrigatório para desbloquear conteúdo; precisa de "Restaurar compras". 3.1.2: assinatura com valor contínuo, mín. 7 dias, sem tarefas extras; descrever o que o usuário recebe antes de pedir assinatura.
- 5.1.1: política de privacidade no App Store Connect e no app; exclusão de conta DENTRO do app; conta demo ativa para revisão.
- Primeira assinatura deve ir junto de uma NOVA versão do app (grupo de assinatura + ao menos uma assinatura na mesma submissão). Depois, as demais podem ir sem nova versão.
- Trial próprio de 72h não é "introductory offer" da Apple; não há regra específica para trial próprio em app de assinatura [INCERTO] → descrever com clareza no paywall e nas notas de revisão.
- Classificação etária: novo questionário (4+/9+/13+/16+/18+); web irrestrita → 16+. SDK: Xcode 26/SDK 26 desde 28/04/2026; deployment target iOS 13+ desde 09/09/2026.
- Screenshots: 1–10 por tamanho (jpeg/png sem alfa); iPhone 6,9" (1320×2868 ou 1290×2796…) ver doc oficial; iPad 13" só se o app rodar em iPad. Limites de nome/descrição da assinatura e do grupo: [INCERTO — confirmar no App Store Connect]. Small Business Program, privacy labels, Notifications V2: [INCERTO — não confirmados em página oficial].
- App Privacy: Kids Category NÃO usar (app geral).
### Google Play
- Limites: Título 30; descrição curta 80; completa 4000; notas da versão 500 [INCERTO — confirmar no Play Console].
- Assinaturas: descrever duração/preço/conversão do trial, renovação automática, como cancelar; nome de SKU não pode enganar ("Free Trial" proibido se houver cobrança recorrente automática); mostrar plano anual também como preço total; cancelamento fácil (link para Play Subscription Center).
- Play Billing Library: versão 7 vencida; usar 8 ou 9. Target API 36 (Android 16) desde 31/08/2026 (extensão até 01/11/2026 já passou).
- Exclusão de conta: caminho dentro do app OU link web funcional citando o nome do app/desenvolvedor como no Play; declarar no Data safety; avisar dados retidos por lei.
- Data safety: dados enviados ao servidor (Supabase) contam como coleta; criptografia em trânsito só se vale para todos; provedores que processam em nome do app geralmente não contam como "compartilhamento"; histórico de compras: considerar declarar. IARC, Families Policy, instruções de acesso do app, base plans/ofertas: [INCERTO — confirmar no console].
- RTDN via Cloud Pub/Sub; depois de cada notificação chamar `purchases.subscriptionsv2`.

## 7. Conciliação financeira (relatórios oficiais)
- Apple: relatórios AGREGADOS (sem id de transação) → só conferência de totais. Google: id de pedido individual. Mercado Pago: SOURCE_ID individual. Cabeçalhos literais NÃO confirmados em amostra real → importação "não validada" até a Etapa 10.
- Implementado (migration 20261201000200): tabelas `financial_report_imports/lines`, RPCs `admin_import_report`, `admin_apply_report`, `admin_list_report_imports`, `admin_get_report_import`. Importar só confere; aplicar é ato do admin, auditado; só linhas com valor bruto idêntico; divergência nunca é aplicada; comissão estimada nunca vira pagamento.

## 8. Estado técnico
- Etapa 08 (commit bd6fa62): paywall obrigatório (desligado em produção), gate de acesso, "Minha assinatura".
- Flags de produção que permanecem DESLIGADAS: `enforcement_enabled`, confirmação de e-mail obrigatória, provedores comerciais, AUTO_DEPLOY.
- Etapa 09: migrations 20261201000100 (documentos legais versionados, faixa etária, compartilhamento seguro) e 20261201000200 (conciliação) aplicadas; tela Flutter /privacidade.
- Termos de Uso ainda NÃO publicados em `legal_documents` (só privacidade 2026-09-28). Publicar via `publish_legal_version` só na ativação coordenada.
