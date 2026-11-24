-- Reverte a Etapa 06 (aditiva). ATENÇÃO: remove reembolsos parciais, ajustes,
-- despesas e histórico de percentual. Reaplique 20261124000400 para restaurar
-- as assinaturas antigas de record_*/admin_*payout se necessário.
drop function if exists admin_finance_dashboard(date, date), admin_list_payments(text, text, text, text, text, text, date, date, text, text, integer, integer),
  admin_get_payment(uuid), admin_partner_closing(date, text, integer, integer), admin_partner_commissions(uuid, integer, integer),
  admin_list_payouts(uuid, text, integer, integer), admin_finance_export(text, date, date, uuid, text), partner_finance_export(text, date, date),
  admin_get_partner_pix(uuid), admin_create_expense(text, uuid, bigint, date, text, date), admin_update_expense(uuid, text, uuid, bigint, date, text, date),
  admin_void_expense(uuid, text), admin_add_expense_category(text), admin_list_expenses(date, date, uuid, integer, integer),
  record_payment_reconciliation(text, text, bigint, bigint, bigint, timestamptz), record_payment_settlement(text, text, bigint, timestamptz),
  record_payment_adjustment(text, text, text, bigint, text, text);
drop view if exists payments_eff;
drop table if exists expense_history, expenses, expense_categories, payment_adjustments, payment_refunds, partner_commission_history cascade;
