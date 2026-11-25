# Apple StoreKit: homologação (Serviço 7)

Estado em 25/11/2026. Nenhum valor secreto neste documento. **Honestidade:** só está marcado como "homologado" o que foi exercido contra a Apple de verdade; o resto está como pendente.

## 1. Ambiente Mac
- macOS 27.2.1 (arm64), Xcode 27.2 (27B52), CocoaPods 1.16.2.
- Flutter **3.47.4** via FVM (`/Volumes/DevSSD/Flutter/fvm_cache/versions/3.47.4`). O 3.44.1 (Dart 3.12.1) NÃO resolve: `web ^1.1.2` exige Dart 3.13.
- Simulador: iOS 26.5 (iPhone 17 Pro). iPhone físico "de Lucas" visível por Wi-Fi.
- Projeto sincronizado: `main` em `9b76035` (fast-forward desde `bd77a16`). `flutter analyze` limpo; `flutter test`: 1207 aprovados.
- Build iOS simulador (debug, `--dart-define-from-file=env.json`): OK. Smoke test: primeira e última tela do onboarding (Aurudo acenando; farmar Aura com as duas mãos) corretas. Demais telas NÃO testadas ainda.

## 2. App Store Connect (app 6817047910, bundle `com.lucasdiogof.aprovaura`)
- Versões: 1.0.4 pronta para distribuição; 1.1.0 aguardando revisão (já estava assim; nada foi enviado por este serviço).
- Contratos: Paid Apps Agreement e Free Apps Agreement ativos; conta bancária e formulários fiscais ativos. Nada aceito nem alterado.
- Grupo de assinatura **AprovaAura Premium** (22619471).

| Produto | ID do produto | ID Apple | Duração | Preço (BRL) |
|---|---|---|---|---|
| Mensal | `aprovaura_premium_monthly` | 6839259084 | 1 mês | R$ 19,90 |
| Anual | `aprovaura_premium_annual` | 6839259012 | 1 ano | **R$ 189,90** |

- Disponibilidade: só Brasil (as duas). Localizações: pt-BR, en-US, es-ES.
- **Preço anual:** a Apple não tem o ponto R$ 190,00. "Ver preços adicionais" mostra R$ 189,00, 189,90 e 190,90; o dono escolheu R$ 189,90. O catálogo do backend (`payment_integrations.sql`, anual Apple = 19000) e `docs/release/INFO_ASSINATURAS.md` ainda dizem R$ 190,00: **atualizar por migration revisada** (pendente).
- Sem oferta introdutória, cupom, plano familiar ou vitalício. Trial de 72 h continua no backend.
- Não submetidas para revisão (a primeira assinatura precisa acompanhar uma nova versão do app).

## 3. App Store Server API e Secrets (projeto Supabase `cesuqfgrtcitatxvokez`)
- Chave In-App Purchase criada no ASC (nome "AprovaAura Supabase IAP", Key ID `9P65LP4X23`, Issuer ID `58e52e59-9add-4149-b558-03be3253dbf3`). Arquivo `.p8` em `~/.aprovaaura-secrets/` (pasta 700, arquivo 600, fora de qualquer repositório). Download único já feito: **fazer backup**.
- Secrets definidos (somente nomes): `APPLE_BUNDLE_ID`, `APPLE_ROOT_CA_PEM` (Apple Root CA G3, SHA-256 `63:34:3A:BF:…:91:79`, exportada do macOS), `APPLE_IAP_PRIVATE_KEY`, `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`.
- O JWT ES256 assinado com essa chave foi aceito pela App Store Server API Sandbox (HTTP 200 em Request a Test Notification).

## 4. Notificações V2
- URL **Sandbox** cadastrada: `…/functions/v1/payments-apple`. URL de **produção NÃO configurada** (de propósito).
- **Teste oficial da Apple (Request a Test Notification + Get Test Notification Status): `firstSendAttemptResult: SUCCESS`.** A URL levou ~5 min para propagar (404 `4040007` antes disso).
- Como `payments-apple` valida o JWS (cadeia até a raiz fixada + OIDs Apple) antes de responder 200, o SUCCESS também confirma validação real de assinatura oficial. O evento TEST é ignorado de propósito (`no_tx`), então **não** gera dado financeiro.
- Distinção: teste oficial = feito; evento automático de transação Sandbox = **pendente** (precisa de compra Sandbox); eventos simulados localmente = ainda não rodados nesta sessão.

## 5. Pendente (nada disso foi feito/homologado)
- Conta Sandbox Apple (storefront Brasil): falta um e-mail próprio para o testador.
- Compra/renovação/cancelamento/reembolso/restauração em Sandbox e StoreKit Testing; `appAccountToken`; entrada de homologação (`BILLING_TEST_ENTRY` + `payment_test_users`) para iOS; revisão do cliente `in_app_purchase_storekit`.
- Revisão do `payments-reconcile` para Apple; conciliação financeira e comissões.
- Texto do onboarding cita "correção assistida por IA" (IA suspensa): revisar antes de qualquer envio.
- Dados de revisão da App Store (conta de demonstração, screenshots das assinaturas, localização do grupo).

## 6. Estado seguro
Monetização global, provedores comerciais, cron comercial, `AUTO_DEPLOY` e confirmação obrigatória de e-mail: **não tocados / desligados**. Nenhuma cobrança real; nenhuma versão publicada ou enviada.
