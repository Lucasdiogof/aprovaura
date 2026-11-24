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
| 11 | **Crítico:** `requires_reaccept` com padrão `true` e 0 aceites em produção forçaria todos à tela de reaceite | padrão da coluna | migração `20261202000100` (padrão false), aplicada; teste SQL |
| 12 | Reaceite exigido pelo servidor era burlado desconectando o aparelho | obrigação não era guardada | pendência confirmada guardada por conta (`loadPendingLegal`); offline/5xx/reinício não a apagam; testes |
| 13 | Home exibia cartão/banner Premium | pedido do dono (Premium só no Perfil) | removido da Home; permanece em Perfil > Minha assinatura |
| 14 | Admin > Financeiro: exceção de layout com valor negativo | altura de barra negativa | `BarChart` com barra mínima |
| 15 | `Select` do portal estourava em 320 px | largura do item mais largo | expande e trunca em telas estreitas |
| 16 | Interruptor "Bloqueio emergencial" estourava 4,5 px em 320 px | texto sem `Flexible` | `Flexible` + reticências |

