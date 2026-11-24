-- Reverte 0400 (APAGA histórico financeiro: só antes de qualquer pagamento real).
drop function if exists partner_my_summary();
drop function if exists admin_reverse_payout(uuid, text);
drop function if exists admin_register_payout(uuid, bigint, date, timestamptz, text);
drop function if exists record_payment_refund(text, text, timestamptz, boolean);
drop function if exists record_confirmed_payment(text, text, uuid, text, bigint, bigint, bigint, timestamptz, jsonb);
drop function if exists _competence(timestamptz);
drop function if exists partner_balance_cents(uuid);
drop table if exists payouts;
drop table if exists commission_ledger;
drop table if exists payments;
drop function if exists payments_guard();
