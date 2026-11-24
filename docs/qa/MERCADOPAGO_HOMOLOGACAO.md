# Mercado Pago — configuração e homologação (Etapa 10C, serviço 5)

Data: 2026-11-24. Sem cobranças, sem Pix, sem pagamento real. Nenhum valor de credencial neste arquivo.

## 1. Conta e aplicação identificadas (leitura somente, `GET /users/me` e `GET /applications/{id}`)

| Item | Resultado |
|---|---|
| Conta recebedora | `LUCKSREI`, id **207507198**, Brasil (MLB), conta pessoal com identificação CPF, cadastro completo, e-mail confirmado, cobrança e venda permitidas |
| Titularidade | **Lucksrei**: mesmo apelido e mesma conta do app já usado no Payhip; CPF do titular do CNPJ 54.868.173/0001-55 (Lucas Diogo Franca). Confirmação final do vínculo CPF↔CNPJ: dono |
| Aplicação | `Lucksrei - Payhip`, id **6559240255677467**, criada em 23/10/2026, ativa, `sandbox_mode=false`, `notification_url` vazia, escopos de pagamentos, assinaturas, reembolsos e chargebacks |
| Decisão | **Reaproveitar** esta aplicação (não criar outra). O nome "Payhip" é só rótulo. Efeito colateral aceito: o segredo de webhook da aplicação é único; o `mp-webhook` rejeita qualquer pagamento que não tenha o token de compra (`external_reference`) de um usuário do AprovaAura |

## 2. Credenciais no cofre (sem valores)

| Id no cofre | Finalidade | Ambiente | Situação |
|---|---|---|---|
| `mercadopago.unassigned.production.access-token` | chamadas à API (`MP_ACCESS_TOKEN`) | **produção** (`APP_USR-`) | válida (200 na API); compartilhada com `aprovaura` (`shared_with`) |
| `…public-key` | chave pública (checkout transparente; **não usada hoje**, o checkout é hospedado/Pix via API) | produção | compartilhada com `aprovaura` |
| `…client-id` | id da aplicação | produção | idem |
| `…client-secret` | OAuth (**não usado**) | produção | idem |
| `supabase.aprovaura.production.cron-secret` | `CRON_SECRET` (agendamento futuro) | produção | **criado agora**, no cofre e no Supabase |

**Ausentes (só o dono obtém no painel):** (a) credenciais de TESTE da aplicação (Access Token de teste e chave pública de teste); (b) segredo de assinatura do webhook (`MP_WEBHOOK_SECRET`), de teste e de produção. Nenhuma credencial de produção foi usada para criar cobrança.

## 3. Secrets no Supabase (`cesuqfgrtcitatxvokez`) — nomes apenas

| Secret | Estado |
|---|---|
| `PORTAL_BACK_URL` | **corrigido**: `https://aprovaura.lucksrei.com/minha-assinatura` (antes `/partners`, rota que exige papel de professor/admin) |
| `MP_COLLECTOR_ID` | **definido** (id da conta de produção, não é segredo): valida pagamentos reais (`live_mode=true`) |
| `MP_NOTIFICATION_URL` | **definido**: `…/functions/v1/mp-webhook` |
| `CRON_SECRET` | **definido** (mesmo valor no cofre) |
| `MP_ACCESS_TOKEN` | **NÃO definido de propósito**: só entra o token de TESTE na homologação e o de produção na ativação |
| `MP_WEBHOOK_SECRET` | ausente (dono) |
| `MP_SANDBOX_COLLECTOR_ID` | ausente: id da conta vendedora de TESTE (descobre-se com o token de teste) |
| `MP_ENV` | ausente (= produção); usar `sandbox` só durante a homologação |

Sem `MP_ACCESS_TOKEN`/`MP_WEBHOOK_SECRET`, o webhook responde 401 e o checkout responde `provider_disabled`: **fail-closed comprovado** (smoke 19/19; webhook sem assinatura 401; reconcile sem segredo 401).

## 4. Edge Functions republicadas (arquitetura de autenticação preservada)

`mp-checkout`, `mp-webhook`, `payments-reconcile` (e código compartilhado `_shared/mp.ts`). Alterações:
1. **Ambientes separados:** pagamento real só vale para `MP_COLLECTOR_ID`; pagamento de teste só para `MP_SANDBOX_COLLECTOR_ID` (antes um único id servia aos dois).
2. **HMAC:** o manifesto agora **omite partes ausentes** (ex.: sem `x-request-id`), como na documentação oficial; antes enviava a parte vazia e recusaria evento legítimo.
3. **Taxa informada:** `fee_details` do pagamento agora entra como `fee_source=reported` (antes caía como "estimada" mesmo vindo do MP). O imposto continua "estimado" até a conciliação, então o pagamento segue **pendente e sem comissão liberável**.
4. **Liquidação:** quando o MP informa `money_release_status=released`, grava `settled_cents` (líquido recebido) e a data.
5. **Reembolso/chargeback de CARTÃO** era ignorado (só Pix tratava): agora reverte comissão e encerra o acesso, **só para pagamento que o sistema registrou**, e cancela a assinatura no MP (o MP não faz isso sozinho). Também trata o tópico próprio de chargebacks (`topic_chargebacks_wh`).
6. **Cobrança de cartão nunca saía de "pendente"** (nem `status` nem webhook a fechavam): o botão "Já concluí — verificar" nunca liberava o acesso e o app seguia mostrando "pagamento pendente". Agora o webhook, a consulta de status (relê o MP) e a reconciliação fecham a cobrança; cobrança de cartão expira em 24 h.
7. **Retorno do checkout:** `back_url` padrão = `/minha-assinatura` (página de qualquer assinante). O retorno **não libera nada**: o acesso só vem do webhook/consulta ao backend.
8. **Fail-closed antes de cobrar:** `mp-checkout` recusa criar cobrança sem a conta recebedora do ambiente e sem o segredo do webhook (antes o cliente poderia pagar e nunca ser creditado).
9. **Reconciliação:** `payments-reconcile` agora reaplica as cobranças aprovadas perdidas de cada assinatura de cartão e confirma as cobranças abertas (Pix/cartão) dos últimos 3 dias; renovações, cancelamentos e reembolsos passam pelo mesmo caminho idempotente.

## 5. Webhook — o que configurar no painel (ver passo a passo na resposta final)

URL: `https://cesuqfgrtcitatxvokez.supabase.co/functions/v1/mp-webhook`. Eventos necessários e como o código trata cada um:

| Evento (painel) | `type` recebido | Tratamento |
|---|---|---|
| Pagamentos | `payment` | relê `/v1/payments/{id}`; Pix: concede/estorna; cartão: só reversão (reembolso/chargeback) |
| Planos e assinaturas | `subscription_preapproval` | relê `/preapproval/{id}`; cancelamento mantém acesso até o fim do período |
| Pagamentos recorrentes de assinaturas | `subscription_authorized_payment` | relê cobrança, pagamento e assinatura; ativa/renova |
| Contestações | `topic_chargebacks_wh` | relê o chargeback e reaplica cada pagamento |

Reembolsos chegam como atualização de `payment`. Segurança: HMAC SHA-256 do manifesto oficial (comparação em tempo constante), **o corpo nunca é confiado**: cada recurso é relido na API com o Access Token e validado (conta recebedora por ambiente, valor contra o catálogo, moeda BRL, plano, `external_reference` = token opaco do usuário, `live_mode`). Não há janela de tolerância do `ts` de propósito: o processamento é por estado e idempotente (evento atrasado/duplicado é inofensivo) e o MP reenvia por dias.

## 6. Testes realizados (todos locais; nenhuma chamada a pagamento)

| Camada | Resultado |
|---|---|
| Deno, processadores com API do MP e banco simulados (`_shared/mp_processors_test.ts`) | **15 testes OK**: Pix mensal/anual aprovado (bruto integral, taxa informada, sem imposto inventado); sandbox por `live_mode`; ambientes separados (mistura recusada); conta recebedora errada ou ausente (fail-closed); valor fora do catálogo, moeda errada e sem referência (`invalid`); pendente/em processamento/recusado/cancelado (nada concedido); duplicado/atrasado (mesmo `eventId`); reembolso total, parcial e chargeback; cartão ativa/renova anual; cartão recusado; cancelamento mantém acesso; reembolso de cartão só em pagamento registrado; chargeback por tópico próprio; conciliação recupera cobrança perdida; `paymentInfo` |
| Deno, HMAC (`mp_signature_test.ts`) | 5 testes OK (incl. manifesto sem `x-request-id`) |
| SQL contra produção em transação revertida (`tool/db/sql_tests.py`) | **83/83** (12 novos de Mercado Pago via `payments_ingest_event`): sandbox sem pagamento/receita/comissão; anual = pagamento integral R$ 190,00 e 365 dias; taxa informada + imposto estimado = pendente sem comissão; webhook duplicado inerte; conciliação libera `floor((19000-120)*50%)=9440`; mudar percentual depois não altera comissão lançada; evento atrasado não derruba acesso; reembolso total reverte comissão |
| Flutter, `PixPaymentPanel` (5 testes) | QR, copia e cola (área de transferência), 30/365 dias, "verificar" só confirma com `approved`, expirado oferece novo Pix e esconde QR |
| Smoke das Edge Functions publicadas | 19/19; webhook sem assinatura 401; reconcile sem segredo 401 |

## 7. O que NÃO foi homologado (limitações declaradas, sem simular sucesso)

Nada disto foi executado contra o sandbox oficial do Mercado Pago, porque **não há credenciais de teste no cofre** e as de produção não podem criar cobrança nesta etapa:
cartão mensal/anual reais de teste, Pix de teste (QR, copia e cola, expiração, aprovação), renovação recorrente do cartão, cancelamento e reembolso reais, retorno do checkout hospedado, entrega real de webhook assinado pelo MP, formato real dos relatórios financeiros e `fee_details`/`money_release_*` reais de um pagamento. O contrato com a API (nomes de campos) foi montado a partir do código existente e da documentação; só um pagamento de teste real confirma. Além disso:
- Meios offline (Pix) no sandbox: a documentação do MP não detalha Pix de teste de forma verificada; pode exigir aprovação manual ou ser indisponível. Documentar o resultado quando testar.
- O MP **não tem Pix recorrente** neste fluxo: Pix é avulso (30/365 dias), renovação manual, como no modelo comercial.
- `GET /authorized_payments/search?preapproval_id=` (usado na reconciliação) não foi verificado em resposta real; se vier outro formato, só a recuperação de eventos perdidos é afetada (o webhook segue valendo).
- Imposto nunca vem da API: depende do contador e do relatório (`admin_reconcile_payment_tax`/importação).

## 8. Financeiro, comissões e conciliação

- Registro de pagamentos, taxa informada, imposto pendente, líquido, professor indicador, percentual histórico (50% padrão, individual configurável), anual sobre o pagamento integral, ajustes de reembolso e liquidação: **todos exercitados por SQL (83/83)** pelos contratos já existentes; **não foi criado outro sistema financeiro**.
- Regra de ouro preservada: **comissão estimada nunca vira pagamento**. Com taxa informada e imposto estimado o pagamento fica `pending`; só vira `reconciled` (e libera comissão) após a conciliação oficial. Nenhuma taxa percentual foi presumida: sem `fee_details` real, o pagamento permanece estimado/pendente.
- Sandbox: `payments_ingest_event` descarta toda a parte financeira em ambiente de teste (provado em SQL).
- Conciliação com a aba existente (`docs/finance/RECONCILIATION.md`): importação ainda "não validada" com cabeçalhos reais do relatório do MP (SOURCE_ID); depende de amostra real.

## 9. Reconciliação periódica (preparada, NÃO habilitada)

`CRON_SECRET` existe (cofre + Supabase). Agendamento (`pg_cron` + `pg_net`, ver `SUPABASE_AUDITORIA.md` §8): **não criado**. Para ativar na época certa: criar as extensões, guardar o mesmo segredo em `vault.create_secret(…, 'cron_secret')` e `cron.schedule('payments-reconcile', '17 */12 * * *', …)`; desfazer com `cron.unschedule`. A função só consulta o MP quando `MP_ACCESS_TOKEN` existe.

## 10. Como rodar a homologação no sandbox quando houver credenciais de teste

1. Guardar no cofre o Access Token de teste e o segredo de webhook (modo teste); descobrir o id da conta vendedora de teste com o token; definir `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, `MP_SANDBOX_COLLECTOR_ID`, `MP_ENV=sandbox`.
2. Habilitar **só** a linha `mercadopago/sandbox` em `payment_providers_config` durante a janela de teste e desabilitar ao final. Atenção: o acesso concedido por compra de teste é real dentro do app (entitlement `sandbox:`), então a janela deve ser curta e só com conta de teste.
3. Executar a matriz da seção 7 com cartões e usuários de teste oficiais; registrar resultado de cada linha aqui. Voltar `MP_ENV` e os secrets de teste ao estado anterior.

## 11. Rodada de homologação sandbox (24/11/2026) — resultado

**Isolamento Payhip (novo, no código):** a aplicação do Mercado Pago é compartilhada com o Payhip. `processPayment` e `processAuthorizedPayment` só processam cobrança cujo `external_reference` é um token de `purchase_account_tokens`; qualquer outra origem retorna `foreign` e não gera evento, pagamento, comissão nem acesso. Cobertos por 2 testes Deno (25/25).

**Pagamento sandbox NÃO homologado.** Resultado real das tentativas com a API:
- As credenciais "de teste" cadastradas (`TEST-…`) pertencem à conta real (id 207507198), não a uma conta vendedora de teste.
- Pix com e-mail aleatório: 400 `2034 Invalid users involved`. Pix e cartão com comprador de teste criado via API: 403 `4390 Payer email forbidden`. Token de cartão foi gerado normalmente (cartão de teste do MP).
- Conclusão: vendedor real + comprador de teste não combinam. É preciso um par **vendedor de teste + comprador de teste** (mesmo país), usando o Access Token APP_USR do **vendedor de teste**.
- Nada foi simulado; nenhuma cobrança real; segredos `MP_ACCESS_TOKEN`/`MP_WEBHOOK_SECRET`/`MP_ENV` seguem ausentes no Supabase (provedor desligado).

**Procedimento para o dono (painel Mercado Pago Developers):** Suas integrações → aplicação → Testes → Contas de teste → criar conta **Vendedor** (Brasil) e **Comprador** (Brasil); abrir os três pontos da conta vendedora → "Gerar nova senha"; logar nela (usuário/senha da tela; se pedir código, são 6 dígitos enviados ao e-mail de teste) em janela anônima, abrir Developers e copiar o Access Token APP_USR dessa conta e criar o webhook de teste com a assinatura secreta. Guardar tudo no cofre (`mercadopago.aprovaura.sandbox.*`). Depois a Claude instala os segredos por janela controlada e roda a matriz (Pix/cartão, mensal/anual, aprovado/pendente/recusado, cancelamento, reembolso).
