# Revisores e checklists de submissão — AprovaAura (Etapa 09)

> Fonte única: `docs/release/FATOS_ETAPA09.md` (24/11/2026) + leitura do repositório. Marcadores: **VERIFICADO** (código/FATOS), **PENDENTE** (falta ação/decisão), **[PENDENTE-DONO]**, **[INCERTO — confirmar no console]**. Nada aqui é promessa de aprovação. Nunca escrever senhas neste arquivo.

## 0. Divergências e bloqueadores encontrados

| # | Item | Situação |
|---|---|---|
| B1 | Gemini free tier + termos exigem 18+ e vedam clientes "direcionados a ou provavelmente acessados por" menores de 18 (FATOS §3) | BLOQUEADOR [PENDENTE-DONO]: migrar para camada paga e decidir política para menores antes de usuários reais em escala. Afeta classificação etária, público-alvo (Play) e Data Safety. |
| B2 | Decisões sobre menores (idade mínima, <12, consentimento parental, assinatura por menores, RIPD/DPO, advogado) — FATOS §4 | BLOQUEADOR [PENDENTE-DONO]. |
| B3 | Termos de Uso NÃO publicados em `legal_documents` (FATOS §8) | A URL de Termos/EULA só vale após `publish_legal_version` na ativação coordenada. Até lá, EULA padrão Apple. |
| B4 | `ios/Runner/PrivacyInfo.xcprivacy` declara `NSPrivacyCollectedDataTypes` vazio e `NSPrivacyTracking` false; o app coleta e-mail, progresso, redações etc. no Supabase | DIVERGÊNCIA a revisar: manifest × nutrition labels (§5). Tracking=false é coerente (sem publicidade/SDK de tracking no `pubspec.yaml`); a lista vazia de dados coletados precisa de decisão do dono/revisão. |
| B5 | Listagens descrevem teste de 3 dias + assinatura, mas `enforcement_enabled`, confirmação de e-mail obrigatória e provedores comerciais estão DESLIGADOS em produção (FATOS §8) | A ficha só deve ir ao ar na ativação coordenada; ver §1.4 e §9. |
| B6 | Product IDs vêm do catálogo semeado em `supabase/migrations/20261129000100_payment_integrations.sql` (não há constantes no Dart; o app lê do servidor) | Conferir que os IDs criados nos consoles sejam IDÊNTICOS: Apple `aprovaura_premium_monthly` / `aprovaura_premium_annual`; Google produto `aprovaura_premium` com base plans `monthly` / `annual`. |
| B7 | Dados do responsável (razão social, CNPJ, endereço, canal de suporte oficial, DPO) | [PENDENTE-DONO] — exigidos nas fichas/declarações das lojas. |
| OK | SDK/Billing/target (§6) | Sem divergência no repo; confirmar no binário final. |

## 1. Instruções para o revisor Apple (App Review Information)

### 1.1 Conta de revisão
- Usuário (e-mail): **[PENDENTE-DONO: dono cria e cola]**
- Senha: **[PENDENTE-DONO: dono cria e cola — nunca escrever aqui]**
- A conta deve ser **SEM permissão de admin** (sem papel em `app_admins`), com e-mail confirmado e sem vínculo de parceiro. Deve estar ativa durante toda a revisão (guideline 5.1.1 — FATOS §6).
- Estado de acesso da conta: com `enforcement_enabled` off, ela tem acesso total ao conteúdo (ver §1.4).

### 1.2 Onde encontrar
- **Restaurar compras** (guideline 3.1.1): na tela do paywall (botão "Restaurar compras") e na tela **Minha assinatura** (mesmo botão). VERIFICADO em `lib/features/paywall/presentation/pages/paywall_page.dart` e `my_subscription_page.dart`.
- **Exclusão de conta dentro do app** (guideline 5.1.1): aba **Perfil**, final da página, texto vermelho **"Excluir minha conta"** (com confirmação). VERIFICADO em `lib/features/profile/presentation/widgets/delete_account_tile.dart`; também acessível pelo rodapé de conta do paywall (`AccountFooter`).
- **Política de Privacidade** no app: Perfil → **Privacidade e termos** (rota `/privacidade`). VERIFICADO.
- **Minha assinatura**: status, cancelamento e restauração.

### 1.3 Como funciona o teste de 72h (texto sugerido para as Review Notes)
> O AprovaAura dá a cada novo usuário 72 horas de acesso completo após a confirmação efetiva do e-mail, sem cartão e sem cobrança automática. Isso é um teste próprio do app, calculado no servidor; NÃO é uma oferta introdutória da Apple e não há cobrança ao fim dele. Usuários já existentes não recebem novo teste. Depois do teste, o acesso é por assinatura via In-App Purchase (mensal ou anual), com renovação automática gerenciada pela Apple. O paywall descreve o que o usuário recebe antes de pedir a assinatura. Restaurar compras: botão no paywall e em "Minha assinatura".

Observação: não há regra específica conhecida para trial próprio em app de assinatura [INCERTO]; por isso a descrição explícita acima e no paywall.

### 1.4 Como o revisor avalia o paywall enquanto `enforcement_enabled` está off
- Com o flag off, o gate de acesso é inerte (`commercial_enforced() = false`): o paywall obrigatório NÃO bloqueia ninguém e produtos comerciais ficam desligados em produção. O revisor não conseguirá ver o paywall bloqueante nem comprar por fluxo natural.
- Opções (decisão do dono, **[PENDENTE-DONO]**), sem mexer na produção sem coordenação: (a) abrir **Minha assinatura**/paywall voluntário, que o app mostra mesmo com acesso liberado (visita voluntária, `paywall_page.dart`) e testar com sandbox; (b) ativar a cobrança de forma coordenada antes de enviar à revisão (ordem em §9); (c) enviar capturas de tela/vídeo do paywall nas Review Notes. O teste de compra usa o ambiente sandbox da Apple, sem cobrança pública.
- Se o flag permanecer off no envio, dizer isso explicitamente nas Review Notes; não prometer o que o revisor não consegue ver.

### 1.5 Outras notas
- Pagamento: iOS = StoreKit (nenhum link para pagamento externo/Mercado Pago no iOS — **confirmar na UI antes do envio**; FATOS: Web = Mercado Pago).
- IA: redações são avaliadas por IA (Gemini); a nota é estimada e isso está dito na descrição.
- Kids Category: NÃO usar.

## 2. Google Play — acesso ao app (formulário App access)
- Selecionar "All or some functionality is restricted" e fornecer: instruções de login, e-mail de teste e senha **[PENDENTE-DONO: dono cria e cola; nunca escrever aqui]**. Conta sem permissão de admin e com e-mail confirmado.
- Texto sugerido: "Entre com o e-mail e a senha fornecidos na tela de login. O teste de 3 dias e o paywall são controlados pelo servidor; no momento o acesso comercial pode estar desligado e toda a funcionalidade abre normalmente. Exclusão de conta: Perfil → Excluir minha conta; link web: https://lucksrei.com/projects/aura/data-deletion/."
- Exclusão de conta: caminho dentro do app + link web funcional, citando nome do app/desenvolvedor como no Play (FATOS §6). Declarar no Data safety e avisar dados retidos por lei.
- Fluxo "free trial": não existe oferta no Play; não criar. Instruções de acesso do app, IARC e Families Policy: [INCERTO — confirmar no console].

## 3. Privacidade Apple (App Privacy / nutrition labels)

**VERIFICADO (FATOS §2 + código):**
- Rastreamento (tracking): NÃO. Sem SDK de anúncios/analytics no `pubspec.yaml`; `NSPrivacyTracking` = false.
- Dados tratados e vinculados à conta (Supabase): e-mail/conta (identificador de usuário), conteúdo do usuário (redações, respostas, progresso), histórico de compras (valores/ids de transação; sem cartão), aceites de documentos/consentimentos, faixa etária declarada (não a data de nascimento).
- Finalidade: funcionalidade do app; sem publicidade e sem perfilamento comportamental.
- Terceiros: Supabase, Cloudflare, Resend (e-mails; a configurar), Apple/Google/Mercado Pago (cobrança; app não vê cartão), Google Gemini (texto de redação sem identificadores do usuário).

**PENDENTE:**
- Mapear cada categoria acima nas categorias exatas do App Store Connect (Contact Info > Email; User Content; Purchases; Identifiers; Other Data) e marcar "linked to user" / "not used for tracking" **[PENDENTE-DONO]**.
- Corrigir/confirmar `PrivacyInfo.xcprivacy` (B4).
- Declarar o envio de texto de redação ao Gemini conforme a camada paga/gratuita vigente (B1). Não afirmar "sem treinamento" para a camada atual.
- Privacy labels como requisito formal: [INCERTO — não confirmado em página oficial (FATOS §6)]; tratar como obrigatório por prudência.
- URL de privacidade: https://lucksrei.com/projects/aura/privacy/ (não quebrar).

### Classificação etária Apple
- Novo questionário (4+/9+/13+/16+/18+). Não há conteúdo adulto no app, mas FATOS §6 diz "web irrestrita → 16+". **Resposta final: [PENDENTE-DONO]**; sugestão de ponto de partida: responder o questionário com honestidade quanto a acesso web irrestrito e aceitar 16+ se o questionário indicar. Decisão de idade mínima (B2) pode elevar/alterar. Não usar Kids Category.

## 4. Data Safety Google

**VERIFICADO:**
- Coleta: e-mail/identificadores de conta, conteúdo do usuário (redações, respostas), progresso/atividade no app, histórico de compras (considerar declarar), faixa etária declarada. Dados enviados ao servidor Supabase contam como coleta (FATOS §6).
- Provedores que processam em nome do app (Supabase, Cloudflare, Resend) geralmente não contam como "compartilhamento"; Gemini recebe texto de redação sem identificadores — **decidir se conta como compartilhamento [PENDENTE-DONO]**.
- Sem anúncios, sem SDK de rastreamento no `pubspec.yaml`.
- Exclusão de conta: disponível no app e por link web.
- Criptografia em trânsito: declarar "sim" apenas se vale para todo o tráfego (HTTPS Supabase/Cloudflare; **confirmar que nenhum tráfego é em claro**). O app só pede a permissão INTERNET (AndroidManifest) — VERIFICADO.

**PENDENTE:**
- Preencher o formulário no console (categorias, finalidades, opcional × obrigatório) — [INCERTO — confirmar no console].
- Declarar retenção legal (fiscal geralmente 5 anos [INCERTO — confirmar com contador]; Marco Civil art. 15: 6 meses).
- **Conteúdo IARC (questionário de classificação): PENDENTE** — responder no console; resultado depende do questionário.
- **Público-alvo e menores: decisão do dono [PENDENTE-DONO]** (B1/B2). Não marcar como app para crianças sem decisão; Families Policy [INCERTO].

## 5. Requisitos de SDK/Billing/target — o que o repo usa hoje

| Requisito (FATOS §6) | Repo | Status |
|---|---|---|
| Xcode 26 / iOS SDK 26 (desde 28/04/2026) | Não verificável no repo (depende da máquina/CI de build). `ios/Runner.xcodeproj` e Flutter 3.47.4 local. | PENDENTE: confirmar Xcode usado no upload. |
| Deployment target iOS 13+ (desde 09/09/2026) | `IPHONEOS_DEPLOYMENT_TARGET = 15.0` em `project.pbxproj` | VERIFICADO — atende. |
| Play Billing Library 8 ou 9 | `in_app_purchase_android 0.5.5` → `com.android.billingclient:billing:9.1.0` (pub-cache) | VERIFICADO — atende. |
| Target API 36 | `targetSdk = flutter.targetSdkVersion` = 36 no Flutter local 3.47.4 (`FlutterExtension.kt`); `compileSdk` 36; `minSdk` 24 | VERIFICADO no SDK local — conferir no AAB final. |
| Bundle/application id | `com.lucasdiogof.aprovaura` (iOS e Android) | VERIFICADO. |
| Versão atual | `pubspec.yaml` 1.0.4+7; nova submissão da assinatura precisa de build maior | PENDENTE: incrementar. |
| iPad | `TARGETED_DEVICE_FAMILY = "1,2"` (roda em iPad) | Exige screenshots de iPad 13". |

## 6. Screenshots necessárias (apenas listar; não gerar)

Acervo existente (18 imagens `.webp`, por idioma): `docs/screenshots/{pt-BR,en,es}/` — home, practice, practice-more, trail, topics, trail-topics, trail-question, mock-build, mock-build-more, mock-question, essay-list, essay-proposal, essay-correcting, essay-score, map, map-done, level-up, profile. Lojas aceitam jpeg/png: converter `.webp` na hora do envio; o iOS não aceita alfa.

| Loja | Tamanho | Quantidade | Idiomas | Observação |
|---|---|---|---|---|
| Apple | iPhone 6,9" (ex.: 1320×2868 ou 1290×2796; ver doc oficial) | 1–10 | pt-BR, en, es | obrigatório |
| Apple | iPad 13" (ver doc oficial) | 1–10 | pt-BR, en, es | obrigatório porque o app roda em iPad |
| Apple | Capturas do paywall/Minha assinatura | recomendado | pt-BR | **PENDENTE**: não existe no acervo; precisa mostrar preços e termos |
| Google | Telefone (mín. 2, máx. 8; dimensões no console) | ≥2 | pt-BR, en, es (localizar por idioma) | [INCERTO — confirmar no Play Console] |
| Google | Ícone 512×512; Feature graphic 1024×500 | 1 cada | por idioma opcional | feature graphic **PENDENTE** (não existe no repo) |
| Google | Tablets 7"/10" | opcional | — | recomendado |

## 7. Ordem exata de submissão da primeira assinatura

### Apple (FATOS §6)
1. Dono cria a conta de revisão sem admin (§1.1) e confirma Contrato de Apps Pagos (Paid Apps Agreement), dados bancários e fiscais **[PENDENTE-DONO]**.
2. App Store Connect → Monetização → criar **grupo de assinatura** "AprovaAura Premium" e as duas assinaturas `aprovaura_premium_monthly` (1 mês) e `aprovaura_premium_annual` (1 ano), preço-base BRL 19,90 e 190,00, nomes/descrições localizados (`apple/*.md`). Sem oferta introdutória.
3. Anexar captura de tela de revisão do paywall em cada assinatura (guideline 3.1.2) e localizações.
4. Gerar **nova versão do app** (build > 1.0.4+7) que inclua IAP/restaurar compras.
5. Na versão, selecionar o grupo + ao menos uma assinatura na MESMA submissão (a primeira assinatura só vai com nova versão); as demais podem ir depois sem nova versão.
6. Preencher: URL de privacidade, App Privacy (§3), classificação etária (§3), EULA (padrão ou próprio), Review Notes (§1.3–1.5), conta de revisão.
7. Atualizar a ficha (`apple/*.md`) e enviar. Coordenar com a ativação do `enforcement_enabled` (§9).

### Google Play
1. Dono confirma perfil de pagamentos/merchant e dados do desenvolvedor **[PENDENTE-DONO]**.
2. Enviar a nova versão (AAB; Billing 9.1.0, target 36) a uma trilha. Se o console exige build com permissão de Billing antes de criar assinaturas: [INCERTO — confirmar no console].
3. Monetizar → Produtos → Assinaturas → criar `aprovaura_premium`; adicionar base plans `monthly` (1 mês, auto-renovável, BRL 19,90) e `annual` (1 ano, auto-renovável, BRL 190,00); ativar. **Não criar oferta/SKU "free trial".**
4. Preencher nome/benefícios/descrição (`google/*.md`); exibir preço anual total no paywall e link do Subscription Center.
5. Configurar RTDN (Cloud Pub/Sub); após cada notificação chamar `purchases.subscriptionsv2` (FATOS §6).
6. Preencher App access (§2), Data safety (§4), IARC, público-alvo, exclusão de conta, declaração de assinatura.
7. Publicar a ficha (`google/*.md`) e a versão; coordenar com a ativação (§9).

## 8. Itens que o dono precisa fornecer
Conta de revisão Apple e Play (sem senha neste arquivo), razão social/CNPJ/endereço/e-mail de suporte/DPO, decisão EULA, idade mínima e política para menores, migração do Gemini para camada paga (ou restrição a 18+), questionário IARC, classificação Apple, screenshots do paywall, feature graphic.

## 9. Ativação coordenada (resumo)
Antes de ligar `enforcement_enabled`: versões novas aprovadas nas duas lojas, Termos publicados via `publish_legal_version`, provedores comerciais configurados, `min_version_*` orientando atualização (docs/PREMIUM_PARTNERS.md §2). Nenhuma ação desse tipo foi executada nesta etapa.
