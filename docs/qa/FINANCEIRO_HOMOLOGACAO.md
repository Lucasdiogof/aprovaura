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
Repasse protegido por bloqueio de linha do parceiro e chave de idempotência (testado: repetição não duplica; excesso de saldo recusado). Teste com duas sessões simultâneas reais **não foi executado**.

## Provedores
Apple, Google Play e Mercado Pago: **NÃO HOMOLOGADOS** (sem credenciais/consoles do AprovaAura; as de Mercado Pago `unassigned` não foram usadas). Conta única entre plataformas: regra no banco (entitlement por conta) coberta pelas migrações; compra cruzada real depende da homologação.
