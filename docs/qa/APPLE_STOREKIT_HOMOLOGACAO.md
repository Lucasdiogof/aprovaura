# Apple StoreKit: homologação (Serviço 7)

Estado em 25/11/2026. Nenhum valor secreto neste documento. **Regra:** só está "homologado no Sandbox oficial" o que foi exercido contra a Apple de verdade (App Store Server API, notificações V2 entregues pela Apple, compra no iPhone). Testes com transações fabricadas ou mudança manual no banco estão rotulados **SIMULADO**.

## 1. Ambiente Mac
- macOS 27.2.1 (arm64), Xcode 27.2 (27B52), CocoaPods 1.16.2, Deno 2.9.8 (instalado via Homebrew só para os testes das Edge Functions).
- Flutter **3.47.4** via FVM (`/Volumes/DevSSD/Flutter/fvm_cache/versions/3.47.4`). O 3.44.1 (Dart 3.12.1) NÃO resolve: `web ^1.1.2` exige Dart 3.13.
- Plugins: `in_app_purchase` 3.3.x + `in_app_purchase_storekit` 0.4.17, que usa **StoreKit 2** por padrão (`transaction.jwsRepresentation` em `serverVerificationData`; `appAccountToken` vindo de `applicationUserName`, que o app preenche com o UUID opaco do servidor). Nenhuma segunda integração foi criada.
- Projeto sincronizado: `main` em `9b76035` no início; iPhone 15 Pro (iOS 26.6.2) e simulador iPhone 17 Pro (iOS 26.5).
- Testes: `flutter analyze` limpo; `flutter test` **1211 passaram**; `deno test` **46 passaram**.

## 2. App Store Connect (app 6817047910, bundle `com.lucasdiogof.aprovaura`)
- Versões: 1.0.4 pronta para distribuição; 1.1.0 aguardando revisão (já estava assim; **nada foi enviado por este serviço**).
- Contratos: Paid Apps e Free Apps ativos; conta bancária e formulários fiscais ativos. Nada aceito nem alterado por mim.
- Grupo de assinatura **AprovaAura Premium** (22619471). Sem oferta introdutória, cupom, plano familiar ou vitalício; trial de 72 h continua no backend.

| Produto | ID do produto | ID Apple | Duração | Preço (BRL) |
|---|---|---|---|---|
| Mensal | `aprovaura_premium_monthly` | 6839259084 | 1 mês | R$ 19,90 |
| Anual | `aprovaura_premium_annual` | 6839259012 | 1 ano | **R$ 189,90** |

- Disponibilidade: só Brasil. Localizações: pt-BR, en-US, es-ES. Não submetidas para revisão (a primeira assinatura precisa acompanhar uma nova versão do app).
- **Pontos de preço:** a Apple não tem R$ 190,00. "Ver preços adicionais" lista R$ 189,00, 189,90 e 190,90; o dono escolheu **R$ 189,90** (só Apple). Google Play e Mercado Pago seguem em R$ 190,00 (catálogo conferido depois: só a linha Apple anual mudou, migration `20261206000100_apple_annual_price.sql`).
- O app mostra o preço localizado do StoreKit (`ProductDetails.price`), nunca valor fixo: no iPhone com Sandbox brasileiro apareceu R$ 189,90/ano e R$ 19,90/mês com "economize 20%"; no simulador (loja dos EUA) apareceu $29,99/$2,99.

## 3. App Store Server API, chave e Secrets (projeto `cesuqfgrtcitatxvokez`)
- Chave In-App Purchase criada (nome "AprovaAura Supabase IAP", Key ID `9P65LP4X23`, Issuer `58e52e59-9add-4149-b558-03be3253dbf3`). `.p8` em `~/.aprovaaura-secrets/` (pasta 700, arquivo 600, fora de repositórios; download único: **fazer backup**).
- Secrets (nomes): `APPLE_BUNDLE_ID`, `APPLE_ROOT_CA_PEM` (Apple Root CA G3, SHA-256 `63:34:3A:BF:…:91:79`), `APPLE_IAP_PRIVATE_KEY`, `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`.
- PAT do Supabase restrito ao projeto `aura`; **não** foi gravado em disco nem Keychain (usado só em variável de ambiente).

## 4. Notificações V2
- URL **Sandbox** cadastrada: `…/functions/v1/payments-apple`. URL de **produção NÃO configurada**.
- **Teste oficial** (Request a Test Notification + Get Test Notification Status): `firstSendAttemptResult: SUCCESS` (a URL levou ~5 min para propagar).
- **Eventos automáticos oficiais** (gerados pela compra Sandbox e entregues pela Apple, processados no banco): `subscribed`, `did_renew` (várias), `did_change_renewal_pref`, `did_change_renewal_status`.
- Distinção: teste oficial ≠ evento automático oficial ≠ evento simulado. O TEST é ignorado de propósito (sem dado financeiro).

## 5. Matriz de homologação

### Sandbox OFICIAL (iPhone físico + App Store Server API + banco)
| Cenário | Resultado |
|---|---|
| Produtos mensal e anual disponíveis, preço e moeda corretos | OK (R$ 19,90 / R$ 189,90, BRL, loja BRA) |
| Compra mensal aprovada | OK: Apple `status 1`, `appAccountToken` do usuário de teste; entitlement `apple` ativo; notificação automática `subscribed` + verificação do app idempotente |
| Renovação automática | OK: `did_renew` automático da Apple (mensal acelerado = 5 min); Apple e banco com o mesmo `expiresDate` |
| Mudança entre planos (mensal → anual) | OK: Apple `autoRenewProductId=annual`; `did_change_renewal_pref`; na renovação seguinte o banco virou `annual` (R$ 189,90, 1 h no Sandbox). **Observação:** os dois planos estão no mesmo nível do grupo, então a troca vale na próxima renovação (não é upgrade imediato). Ordem de níveis pode ser revista no ASC se quiserem upgrade imediato. |
| Cancelamento da renovação | OK: Apple `autoRenewStatus=0`; `did_change_renewal_status`; banco `canceled` com acesso até o fim do período |
| Restaurar compras / estado oficial | OK via `refresh` (relê a App Store Server API) |
| Associação segura à conta | OK: `appAccountToken` = UUID opaco do servidor (sem dado pessoal) |
| Entitlements | OK: concedido, mantido na renovação, `canceled` até o fim |
| Financeiro | OK: **0** linhas em `payments`, `commission_ledger` e `payment_adjustments` (Sandbox nunca gera receita/comissão) |

### Testado contra a Apple, sem passar pelo celular (transação real assinada pela Apple, obtida da App Store Server API)
| Cenário | Resultado |
|---|---|
| Outra conta tenta usar a transação do usuário 1 | **403** (`account_mismatch`); nenhum entitlement criado para o usuário 2 |
| Mesma transação reenviada (idempotência) | 200 sem duplicar |
| JWS adulterado / sem login | 400 / 401 |
| Conciliação de notificação perdida | banco marcado manualmente como expirado (**simulação da perda**); `refresh` com a resposta oficial da Apple reativou assinatura e entitlement |

### SIMULADO (não é homologação oficial)
- Mapeamento de eventos Apple em `apple_events_test.ts` (8 testes): ativa, renovação com bruto de 19,90/189,90, cancelamento, expiração, carência, reembolso, revogação, outro app/produto/moeda, produção vs sandbox.
- A conciliação agendada `payments-reconcile` usa o mesmo helper (`appleOfficialEvent`), mas **não foi executada** (exige `CRON_SECRET`); o `refresh` do usuário exerce a mesma rotina.

### Ainda não exercido / limitações da Apple
- Expiração: **OK (verificado em 27/11)**: a Apple entregou o evento `expired` em 25/11 17:45 UTC e o banco ficou `expired`. Restauração depois de expirar: ainda não exercida.
- **Reembolso e revogação:** o Sandbox oficial não tem como gerar; ficam só SIMULADOS. Em produção dependem de `REFUND`/`REVOKE` reais.
- **Carência e falha de pagamento (billing retry):** o Sandbox não força falha de cobrança; além disso o período de tolerância não está configurado no ASC (decisão comercial). Só simulado.
- **Compra cancelada / interrompida / pendente (Ask to Buy):** não executadas no iPhone.
- Notificações antigas atrasadas ou fora de ordem: a barreira `last_event_at` existe e há o bug abaixo; ordem real da Apple não foi forçada.
- Reinstalação e novo dispositivo com Apple real, mesmo usuário em Android/Web: não executados.

## 6. Problemas encontrados e corrigidos
1. **Texto do onboarding** citava "correção assistida por IA" com a IA suspensa: agora fala em treinar com as competências do ENEM (PT/EN/ES).
2. **Restaurar compras no iOS** não relia o estado oficial (assinatura expirada/revogada não voltava): nova ação `refresh` em `payments-apple`; `payments-reconcile` e o app usam o mesmo caminho.
3. **Bug de ordem no caminho "verificação do app"**: reenviar uma transação antiga (o que o Restaurar faz) reabria uma assinatura **cancelada** e apagava `auto_renew`. Achado no teste com transação real; corrigido (o estado vem da consulta oficial; da transação só vem o pagamento) e reverificado.
4. **Paywall:** X não fechava (ficava sob o conteúdo rolável); loader único até carregar; sem Sair/Excluir conta na visita voluntária; botão de assinar fixo no rodapé; sem mascote; selo "Melhor valor" em uma linha; compra mostra só o botão em loading (a tela "Confirmando seu pagamento" aparecia antes de pagar); "Premium ativado" sem mascote, com brilhos e borda animada; assinante abre **Minha assinatura** (a tela "Premium ativo" foi removida); Minha assinatura com "Gerenciar assinatura" fixo no rodapé.

## 7. Homologação restrita a testadores
Entrada de teste: `--dart-define=BILLING_TEST_ENTRY=true` (só builds de teste; build de loja não define) **e** autorização do servidor: `payment_providers_config(apple, sandbox)` ligado **e** usuário em `payment_test_users`. Qualquer outro usuário não vê o checkout nem obtém token de compra. Monetização global (`enforcement_enabled`), e-mail obrigatório, cron comercial e `AUTO_DEPLOY` permaneceram desligados.

## 8. Pendências comerciais (dono)
- Backup do `.p8`; decidir R$ 189,90 definitivo (catálogo/textos de loja ainda citam R$ 190,00 para Google/Mercado Pago).
- Nível dos produtos no grupo (troca imediata vs na renovação), período de tolerância, Small Business Program (comissão efetiva depende das condições da conta; não assumir 15%).
- Primeira assinatura precisa ir **com uma nova versão** enviada para revisão; localização do grupo, imagem e captura de tela de revisão ainda não preenchidas.
- Relatórios financeiros da Apple (Sales and Trends / Payments and Financial Reports): conciliação comercial só com relatório real; **comissões continuam pendentes** até lá. Taxas/impostos não foram inventados.
- URL de produção das notificações V2 só na ativação; cron comercial só com autorização.

## 9. Estado seguro final
Ver seção ao fim da homologação (a atualizar quando os testes terminarem): provedor Apple de volta a desligado, usuários de teste removidos da allowlist e do app, assinatura de teste cancelada.
