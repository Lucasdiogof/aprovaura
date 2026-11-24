-- Reaceite legal só quando uma publicação o exigir de forma explícita.
-- Achado do QA (Etapa 10B): o padrão da coluna era true e nenhum usuário existente tem aceite gravado;
-- com o bloqueio de reaceite no app (1.1.0) isso forçaria TODOS à tela de aceite sem nenhuma nova versão.
-- A versão-base já vigente (privacy 2026-09-28) é o texto sob o qual os usuários atuais já usam o app.
-- publish_legal_version(..., p_requires_reaccept => true) continua sendo o único jeito de exigir reaceite.
alter table legal_documents alter column requires_reaccept set default false;
update legal_documents set requires_reaccept = false where requires_reaccept is distinct from false;
notify pgrst, 'reload schema';
