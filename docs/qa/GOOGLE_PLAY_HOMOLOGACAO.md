# Google Play Billing — homologação (Serviço 6) — 25/11/2026

**Estado: BLOQUEADO por pendência do dono.** Nada foi criado, alterado, publicado ou cobrado no Play Console nem no Google Cloud.

## 1. Estado do Play Console (somente leitura)
- Conta de programador: "Lucas Diogo França" (organização, id `7231040649358841478`). A mesma conta Google também enxerga outras contas (Bip Táxi, Rodrigo Moreira Leite): **não tocadas**.
- App existente: **Aprovaura**, `com.lucasdiogof.aprovaura` (id interno `4972959530782676385`), produção publicada, último lançamento de produção em 29/10/2026, sem alterações pendentes de publicação.
- **Subscrições: bloqueadas.** A página exige conta de comerciante do Google Payments; a conta não tem **Perfil de pagamentos** ("Crie um perfil de pagamentos para começar"). Sem isso não é possível criar produto de assinatura nem base plans.
- Aviso do console: declarar estatuto de comerciante até 01/02/2027.
- Google Cloud: projetos existentes (`lucksrei-growth-os`, `goias-app-…`, etc.); **nenhum projeto exclusivo do AprovaAura**. Cofre global: **sem credenciais Google Play/Cloud**.

## 2. Catálogo já definido no backend (a ser reaproveitado)
Produto `aprovaura_premium` com base plans `monthly` (R$ 19,90, 30 dias) e `annual` (R$ 190,00, 365 dias), BRL, `payment_catalog` provider `google`. `external_product_id` e `base_plan_id` precisam ser criados idênticos no console.

## 3. Implementação existente (revisão de código, sem execução)
- `payments-google`: RTDN autenticado por OIDC (`GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL`), estado sempre relido em `purchases.subscriptionsv2`, confere pacote/produto/base plan e `obfuscatedExternalAccountId`, trata `linkedPurchaseToken`, `voidedPurchaseNotification`, acknowledge só após persistir, `testPurchase` → ambiente `sandbox`.
- App: `in_app_purchase` 3.3.1 / `_android` 0.5.5, `applicationUserName` = token opaco, `offerToken`, `restorePurchases`.
- Secrets exigidos no Supabase (ainda ausentes): `GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL` (e opcional `GOOGLE_PACKAGE_NAME`).
- **Nada disso foi homologado.** Sem compra real de teste, tudo segue "validado só em mocks/SQL".

## 4. O que o dono precisa fazer (indispensável)
1. Play Console → Configurar → Perfil de pagamentos → **Criar perfil de pagamentos** (dados fiscais/bancários do titular; o agente não insere dados pessoais/financeiros). Declarar o estatuto de comerciante.
2. Autorizar (ou recusar) vincular faturamento no Google Cloud: o Pub/Sub para RTDN normalmente exige conta de faturamento no projeto; há cota gratuita, mas **nenhum faturamento será vinculado sem autorização**. Alternativa sem Pub/Sub: depender só da verificação pelo app + conciliação periódica (RTDN fica de fora).
3. Informar a conta Google de QA (license tester) para homologação.

## 5. Próximos passos do agente após 4.1–4.3
Criar produto/base plans (sem ofertas), projeto/SA com papéis mínimos no app, convidar a SA no Play Console, tópico/assinatura Pub/Sub push com OIDC, instalar secrets, build AAB para faixa interna (versionCode > o publicado), compras de teste (aprovada/recusada/pendente/cancelamento/renovação acelerada/grace/hold/reembolso), conciliação com relatórios oficiais, restaurar estado seguro.
