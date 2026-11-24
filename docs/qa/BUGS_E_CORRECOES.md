# Bugs encontrados e corrigidos (Etapa 10)

| # | Problema | Causa | Correção |
|---|---|---|---|
| 1 | Erro de compilação no financeiro do portal | colisão de nome (campo `_recon` x função `_recon`) | função renomeada para `_reconBadge` |
| 2 | Dezenas de avisos de analyze (tipos genéricos, imports, estilo) | acúmulo das Etapas 06–09 | corrigidos na origem; um único `ignore` justificado (assinatura de stream cancelada em dispose) |
| 3 | `/privacidade` inacessível com paywall/sessão sem acesso | rota fora das listas do gate | adicionada ao conjunto permitido |
| 4 | Rollback de `20261201000100` incompleto | não restaurava assinatura antiga nem gate | reescrito; mantém propositalmente as proteções de menores (bloco inseguro só comentado) |
| 5 | Testes de widget quebrados (login, cadastro, home, perfil, widget_test) | novos providers/DI e dependências de acesso | fakes em `test/helpers/fakes.dart`, registros de DI, `ensureVisible` |
| 6 | Reaceite legal só listado, sem bloqueio | requisito da Etapa 10 | `AccessGate.legalRequired`, tela `/aceite-legal`, RPCs existentes; só reage a `requires_reaccept` confirmado pelo servidor (falha de rede nunca bloqueia) |
| 7 | `PrivacyInfo.xcprivacy` declarava zero dados coletados | desatualizado | declarados e-mail, ID, histórico de compras, conteúdo do usuário, interação e diagnóstico (vinculados, sem rastreamento) |
| 8 | Sem forma de suspender a correção externa por IA | não havia chave | `ESSAY_AI_PROVIDER=disabled` recusa antes de debitar cota ou enviar texto |
| 9 | Versão igual à já publicada | 1.0.4+7 | 1.1.0+8 (IDs inalterados) |
| 10 | `tool/db/sql_tests.py` (erros do próprio teste) | papéis do banco e fixtures | corrigidos; nenhum bug real de backend encontrado nas regras financeiras |
