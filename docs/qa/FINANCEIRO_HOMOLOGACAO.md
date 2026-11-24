# Financeiro: homologação (Etapa 10D)

Valores em centavos. Executado em `tool/db/sql_tests.py` (produção, transação revertida; sem cobrança real, sem Pix).

| Caso | Entrada | Resultado verificado |
|---|---|---|
| A | bruto 19,90, taxa 2,99, líquido 16,91 | comissão de 50% = 8,45 (piso do líquido x bps) |
| B | 190,00, taxa 28,50 | comissão 80,75; Lucksrei 80,75 |
| C | saldo 500,00, repasse 500,00 | saldo 0; repasse acima do saldo recusado (P0041); mesma chave de idempotência não duplica; nova comissão 8,46 → saldo 8,46 |
| D | estorno após repasse | ajuste negativo registrado; compensação em comissões futuras |
| Estorno parcial | reversão por piso | conferido |
| Taxa estimada | comissão fora do livro até conciliar | comissão liberada só após conciliação |
| bps | histórico por data do pagamento | taxa vigente na data |
| Importação de relatório | arquivo repetido, tipo incompatível, bruto divergente, sem par | recusados/divergentes, nunca aplicados; apply idempotente |

## Conciliação: limites declarados
- Só linhas com **valor bruto idêntico** são aplicáveis; diferença vira divergência.
- **Google:** o preço estimado (câmbio/imposto) pode diferir do relatório de ganhos; a taxa oficial vem do relatório individual. Até lá a comissão é estimada e **não vira repasse**.
- **Apple:** relatório agregado por SKU/país; só confere totais (nenhum pagamento individual é atualizado).
- Formatos de relatório **não validados com amostras reais** (sem conta disponível).

## Fechamento mensal (dia 1)
Simulado por: saldo disponível por professor, `admin_register_payout` com chave idempotente, saldo 0, estorno/ajuste posterior. **Nenhum Pix enviado**; o pagamento ao professor é manual e fora do app.

## Concorrência
Executado na Etapa 10B com **sessões reais simultâneas** em Postgres descartável (`tool/db/concurrency_tests.py`, 22/22, repetido 3 vezes):
- dois repasses do saldo inteiro: exatamente um passa, o outro recebe P0041, saldo final 0;
- mesma chave de idempotência em 6 sessões: um único repasse gravado e débito aplicado uma vez (a chave é **única globalmente**; reutilizá-la com outro parceiro falha com 23505, de forma segura);
- repasse x nova comissão e repasse x reembolso simultâneos: nenhum repasse acima do saldo existente; contabilidade fecha (comissões - estornos - repasses = saldo); estorno depois do repasse gera saldo negativo (compensação futura);
- webhook duplicado (8 sessões): um pagamento, uma comissão, uma única resposta `created`;
- conciliação duplicada (6 sessões): comissão creditada uma vez;
- alteração de bps durante o registro (15 corridas): comissão sempre coerente com o bps usado;
- eventos fora de ordem (reembolso/conciliação/ajuste antes do pagamento, reembolso repetido, conciliação tardia): sem saldo indevido.

## Provedores
Apple, Google Play e Mercado Pago: **NÃO HOMOLOGADOS** (sem credenciais/consoles do AprovaAura; as de Mercado Pago `unassigned` não foram usadas). Conta única entre plataformas: regra no banco (entitlement por conta) coberta pelas migrações; compra cruzada real depende da homologação.
