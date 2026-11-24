# Conciliação financeira — metodologia

> Data-base: 24/11/2026. Base: `FATOS_ETAPA09.md` §7, migration `20261201000200_financial_report_import.sql` (tabelas `financial_report_imports`, `financial_report_lines`; RPCs `admin_import_report`, `admin_apply_report`, `admin_list_report_imports`, `admin_get_report_import`), `PREMIUM_PARTNERS.md` §17–§19. Sem segredos.
> **Estado: importação "não validada".** Os cabeçalhos literais dos relatórios oficiais NÃO foram confirmados em amostra real; isso fica para a Etapa 10.

## 1. Princípios
1. **Importar só confere; aplicar é ato explícito do admin, auditado.**
2. **Regra de ouro: comissão estimada NUNCA vira pagamento.** Só pagamentos `reconciled` entram no razão liberável; o repasse é limitado ao saldo disponível (`P0041`).
3. Só linhas com **valor bruto idêntico** podem ser aplicadas. Divergência nunca é aplicada automaticamente.
4. Relatório agregado nunca é casado "por palpite".
5. Sandbox nunca gera receita nem comissão.
6. A taxa/imposto oficial prevalece sobre a estimativa e só é gravada uma vez (primeira conciliação); ajustes posteriores geram `fee_adjustment`.

## 2. Nível de identificação por provedor
| Provedor | Relatório | Chave de casamento | Método |
|---|---|---|---|
| Apple | Relatórios financeiros AGREGADOS, sem id de transação | Nenhuma individual | **Só conferência de totais** (por competência/moeda); nenhuma linha é aplicada individualmente |
| Google Play | Relatório com id de pedido individual | Id do pedido (`latestSuccessfulOrderId`) | Conciliação individual por pagamento |
| Mercado Pago | Relatório com SOURCE_ID individual | `payment.id` (SOURCE_ID) | Conciliação individual por pagamento |

Particularidades: no Google a API v2 não devolve o preço pago, então o bruto é o preço de referência marcado `estimated` até o relatório; no Mercado Pago a taxa vem de `fee_details` e o imposto é estimado; Apple informa `price` em milésimos.

## 3. Procedimento auditável no portal admin (`/partners`)
Pré-requisitos: ser admin; ter baixado o relatório oficial do período diretamente do console do provedor (Apple: Payments and Financial Reports; Google: relatórios de download; MP: relatório de liberações/atividade). Não guardar o arquivo fora de local seguro; ele contém dados financeiros.

1. **Escolher provedor e competência.** Anotar o período e a moeda (BRL).
2. **Verificar pagamentos pendentes.** Em Financeiro › Pagamentos, filtrar `reconciliation_status = pending` do período; anotar a contagem e o total bruto.
3. **Importar o relatório** (`admin_import_report`): informar provedor, período e linhas. O sistema cria um lote em `financial_report_imports` e linhas em `financial_report_lines`; nada é alterado nos pagamentos.
4. **Revisar o lote** (`admin_get_report_import`): para cada linha o sistema indica casada/idêntica, divergente, sem correspondente ou duplicada. Conferir os totais do lote contra o total do arquivo original (soma de linhas e valor bruto).
5. **Tratar exceções ANTES de aplicar**: linha divergente (investigar no console do provedor), sem correspondente (pagamento não registrado? sandbox?), duplicada. Nada disso é aplicado.
6. **Aplicar** (`admin_apply_report`) só o lote com linhas idênticas: grava taxa/imposto oficiais, `reconciliation_status = reconciled`, lança a comissão definitiva no razão e eventuais reembolsos que chegaram antes. A ação registra o admin, data e lote na auditoria (`admin_audit_log`).
7. **Conferir resultado**: pagamentos do período `reconciled`; pendências restantes listadas com motivo; comissão disponível por professor (`admin_partner_closing`) reflete só pagamentos conciliados.
8. **Apple (agregado):** comparar o total bruto/líquido do relatório com a soma dos pagamentos Apple de produção do período no sistema; registrar a diferença em observação. Diferenças não explicadas mantêm os pagamentos Apple como pendentes de conciliação (sem comissão liberável) e são tratadas com os valores efetivos conferidos no console. Imposto: registrar via `admin_reconcile_payment_tax` quando houver valor oficial.
9. **Só então** fechar a competência e registrar repasses (`admin_register_payout`, com chave de idempotência); o repasse é Pix manual no dia 1º.
10. **Arquivar evidência** (identificação do lote, totais, responsável, data). Reversão de repasse: `admin_reverse_payout` com motivo; NÃO desfaz o Pix externo.

## 4. Limites conhecidos
- Importação **não validada** com cabeçalhos reais; qualquer divergência de formato deve parar o processo, nunca ser "adaptada" às cegas.
- Apple sem id individual: não há comissão por transação conciliada individualmente.
- Impostos sobre venda não vêm dos provedores (estimados) e retenção fiscal depende de contador [INCERTO].
- Ajuste de taxa não recalcula reembolsos já lançados (a diferença cai no próximo lançamento).
- Sem comprovantes anexados aos repasses (só o campo `reference`).
- Taxas efetivas por provedor e Small Business Program Apple [INCERTO] até confirmação no console/relatório.

## 5. O que ainda precisa de amostras reais (Etapa 10)
1. Relatório financeiro real da Apple (agregado) com cabeçalhos literais.
2. Relatório real do Google Play (id de pedido, valores, taxas, impostos).
3. Relatório real do Mercado Pago (SOURCE_ID, taxas, liberações).
4. Pagamentos reais de baixo valor ponta a ponta em cada provedor (após a ativação) para confrontar bruto, taxa e líquido.
5. Confirmação de taxas efetivas e impostos registrados com o contador.
Até concluir 1–3 e a confirmação das taxas: **nenhum repasse deve ser feito** e nenhuma comissão estimada pode ser considerada disponível.

## 6. Checklist de saída (antes do primeiro repasse)
- [ ] Relatórios oficiais Apple, Google e MP conciliados no período.
- [ ] Taxas efetivas confirmadas por provedor.
- [ ] Impostos conferidos (não apenas estimados).
- [ ] Transações sem identificação individual tratadas (pendentes, sem comissão liberável).
- [ ] Nenhuma comissão `estimated` no saldo disponível.
- [ ] Valor do repasse ≤ saldo disponível; chave de idempotência definida.
