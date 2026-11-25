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

## 3b. Google Cloud preparado (25/11, sem custo)
- `gcloud` autenticado como a conta do dono. Criar projeto novo falhou (cota de projetos excedida); reaproveitado o projeto **Aura** (`gen-lang-client-0711282501`, sem faturamento) que já era do AprovaAura.
- API habilitada: **Google Play Android Developer API** (`androidpublisher`, gratuita). Nenhum outro serviço habilitado; **faturamento não vinculado**.
- Conta de serviço exclusiva `aprovaura-play-billing@gen-lang-client-0711282501.iam.gserviceaccount.com`, **sem nenhum papel IAM no projeto** (as permissões virão do convite no Play Console, restritas ao app). Chave JSON guardada só no cofre: `googleplay.aprovaura.production.service-account-json` / `…service-account-email` (nada em arquivo; o arquivo temporário foi apagado).
- **Pub/Sub/RTDN: não habilitado** (projeto sem faturamento; depende de autorização do dono).
- **Perfil de pagamentos:** o formulário fica em iframe do Google fora do alcance das ferramentas e exige CNPJ/conta bancária/endereço (não digitados pelo agente). Continua pendente do dono.

## 4. O que o dono precisa fazer (indispensável)
1. Play Console → Configurar → Perfil de pagamentos → **Criar perfil de pagamentos** (dados fiscais/bancários do titular; o agente não insere dados pessoais/financeiros). Declarar o estatuto de comerciante.
2. Autorizar (ou recusar) vincular faturamento no Google Cloud: o Pub/Sub para RTDN normalmente exige conta de faturamento no projeto; há cota gratuita, mas **nenhum faturamento será vinculado sem autorização**. Alternativa sem Pub/Sub: depender só da verificação pelo app + conciliação periódica (RTDN fica de fora).
3. Informar a conta Google de QA (license tester) para homologação.

## 5. Próximos passos do agente após 4.1–4.3
Criar produto/base plans (sem ofertas), projeto/SA com papéis mínimos no app, convidar a SA no Play Console, tópico/assinatura Pub/Sub push com OIDC, instalar secrets, build AAB para faixa interna (versionCode > o publicado), compras de teste (aprovada/recusada/pendente/cancelamento/renovação acelerada/grace/hold/reembolso), conciliação com relatórios oficiais, restaurar estado seguro.

## 6. Atualização 25/11 (tarde) — configuração no Play Console concluída até onde não há bloqueio externo
**Feito (verificado):**
- Perfil de pagamentos criado pelo dono (organização, perfil público do comerciante). Subscrições liberadas no Aprovaura.
- Conta de serviço `aprovaura-play-billing@…` convidada **só no app Aprovaura**, com 4 autorizações: ver informações do app, qualidade, **Ver dados financeiros** e **Gerir encomendas e subscrições** (nada de admin, nada de editar catálogo). Estado: *Ativa*. Teste real: token OAuth obtido e `androidpublisher` respondeu (listar subscrições = 204; criar edição = 200). Escrever no catálogo pela API deu 403, como esperado pelo mínimo privilégio — catálogo foi feito pela interface.
- Produto **`aprovaura_premium`** criado, com base plans (ambos **RASCUNHO**, sem ofertas, só Brasil): `monthly` P1M R$ 19,90, tolerância 7 dias, suspensão de conta 53 dias, resubscrever permitido; `annual` P1Y R$ 190,00, tolerância 14 dias. Nomes/vantagens em pt-BR, en-US e es-419. Confirmado por leitura via API (`subscriptions.get`).
- Observação: no Play o preço digitado "19,90" foi arredondado para 19,99 no diálogo em lote; corrigido na célula (19,90).
- **Testador licenciado:** lista de e-mail "Aprovaura testadores" (1 e-mail do dono) marcada em *Teste da licença*; lista é da conta (vale para todos os apps), a lista "Equipe interna Tech" não foi alterada.
- Release 1.1.0+8 enviada pelo dono direto à produção; está **em revisão** ("Alterações em revisão"). Não toquei.

**Ainda bloqueado:**
1. **Faturamento Google Cloud**: a conta de teste gratuito existe (`010256-B4B60C-BBCEE4`), mas `gcloud` a mostra `OPEN=False` e o projeto `billingEnabled=false`; o teste gratuito provavelmente não foi concluído (verificação do cartão/dados pelo dono). Sem isso não habilito Pub/Sub, tópico, assinatura push nem alertas de orçamento (R$1/5/10). Nada com custo foi habilitado.
2. Ativar os base plans e comprar só faz sentido com o app publicado/aprovado (ou na faixa interna) e a conta de teste no aparelho. Ativação do produto adiada para a fase de teste.
3. Adesão ao programa de 15% e conta bancária: pendência do dono (não confirmada).
4. Secrets no Supabase (`GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_*`) ainda **não** instalados; instalar junto com o RTDN.
5. Nenhuma compra de teste feita: **nada homologado** neste serviço.

## 7. Atualização 25/11 (noite)
- Dono fez pré-pagamento de R$ 30,00 no Google Cloud (vira crédito; nenhum pagamento adicional será feito). Em seguida o aviso de pré-pagamento sumiu do console, mas `gcloud` ainda mostra a conta `OPEN=False` e o projeto `billingEnabled=false` (o crédito pode levar até 24h). **Pub/Sub segue não habilitado.**
- Release 1.1.0+8 (versionCode 8) **está ao vivo na produção** (`tracks.get production`: status completed); faixa interna vazia. Assinaturas continuam em rascunho, então não há compra possível.
- Criada a SA de push `aprovaura-pubsub-push@gen-lang-client-0711282501.iam.gserviceaccount.com` (sem papéis; será a identidade OIDC da assinatura push).
- Secrets instalados no Supabase `cesuqfgrtcitatxvokez` (valores não impressos): `GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_AUDIENCE` (URL da função), `GOOGLE_PUBSUB_SA_EMAIL`, `GOOGLE_PACKAGE_NAME`. `payments-google` rejeita chamada sem OIDC válido (401).
- Pendente: faturamento ativo → habilitar só `pubsub`, tópico, permissão de publicação para `google-play-developer-notifications@system.gserviceaccount.com`, assinatura push com OIDC, alertas R$1/5/10, tópico no Play Console, notificação de teste.
