-- Reverte a Etapa 05. app_pre_request volta à versão de 20261125000200 (reaplique-a se necessário).
drop function if exists partner_portal_me(), partner_dashboard(date, date), partner_usage(date, date),
  partner_list_students(text, text, text, text, integer, integer), partner_student_detail(uuid),
  partner_finance(integer, integer), resolve_referral_code(text), _partner_finance_summary(uuid),
  _student_last_activity(uuid), _next_payout_date(), _student_commercial(uuid), _student_shares(uuid),
  _active_partner_id(), _my_partner_id();
