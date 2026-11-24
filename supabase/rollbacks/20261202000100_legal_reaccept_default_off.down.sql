-- Reverte só o padrão da coluna. NÃO restaura requires_reaccept=true nas linhas (isso reabriria o bloqueio
-- geral de reaceite); se for realmente necessário, usar publish_legal_version com decisão explícita.
alter table legal_documents alter column requires_reaccept set default true;
notify pgrst, 'reload schema';
