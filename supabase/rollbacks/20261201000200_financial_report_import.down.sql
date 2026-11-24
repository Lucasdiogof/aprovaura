-- Reverte a conciliação por relatórios (Etapa 09, parte 2). Conciliações já aplicadas em payments permanecem (são registros financeiros).
drop function if exists admin_import_report(text, text, date, text, text, jsonb);
drop function if exists admin_apply_report(uuid);
drop function if exists admin_list_report_imports();
drop function if exists admin_get_report_import(uuid, boolean);
drop table if exists financial_report_lines;
drop table if exists financial_report_imports;
