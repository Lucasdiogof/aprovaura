# Resultados executados (24/11/2026)

| Verificação | Comando | Resultado |
|---|---|---|
| Análise estática | `flutter analyze` | Sem problemas |
| Testes Flutter | `flutter test` | **1206 passaram · 0 falharam** (inclui `gate_redirect_test` e os testes novos do repositório de acesso) |
| Edge Functions | `deno task check:functions` e `deno task test:functions` (`deno.json` na raiz) | tipos OK em 8 funções + 2 testes; **6/6 com checagem completa** (o erro anterior era `nodeModulesDir`, resolvido) |
| Edge Functions publicadas (smoke, produção) | `python tool/qa/edge_smoke.py` | **19/19** recusam sem credencial |
| SQL (produção, transação revertida) | `python tool/db/sql_tests.py` | **71 passaram · 0 falharam** |
| REST autenticado (Etapa 10B, stack Supabase local) | `python tool/qa/rest_auth_tests.py` | **103/103** |
| Concorrência financeira (10B, Postgres descartável) | `python tool/db/concurrency_tests.py` | **22/22** |
| REST anônimo | `python tool/db/rest_negative_tests.py` (precisa de `SUPA_URL` e `SUPA_ANON`) | **35/35 negados** (inclui `refresh_broken_streak`) |
| Migrações do zero | `bash tool/db/empty_db_check.sh` (Docker, `postgres:16-alpine`) | 15/15 aplicadas (inclui `20261202000100`) |
| Web | `flutter build web --release` | Compilou |
| Android | `flutter build apk --debug` · `flutter build appbundle --release` | APK 183 MB · AAB 66 MB (1.1.0+8) |
| iOS | — | Não executado (sem Mac/Xcode) |

## O que os testes cobrem (mapa pedido na Etapa 10)
- **Acesso** (`access_cubit_test`, `access_repository_impl_test` novo na 10B: reaceite persistido por conta, offline/5xx não apagam): resolving, aberto, paywall, motivo, conexão exigida, versão mínima, erro sem inventar bloqueio, reset de conta, intervalo, reaceite legal (4 casos).
- **Rotas protegidas** (`gate_redirect_test`, `auth_redirect_test`): paywall barra estudo e deep links; portal fora do paywall; conexão/versão; reaceite só permite aceite e documentos.
- **Cadastro/login/recuperação/onboarding** (`login_page_test`, `register_page_test`, `auth_screens_layout_test`, `widget_test`).
- **Perfil / exclusão de conta** (`profile_page_test`).
- **Conciliação** (`report_parser_test`), **assinatura MP** (Deno).
- **Banco**: trial, bloqueios e papéis (migrações anteriores), financeiro A–D, estorno parcial, bps por data, importação de relatório, permissões negativas, exclusão de conta.

## Etapa 10B: QA visual (Chrome via Playwright, build web de depuração contra Supabase LOCAL com dados fictícios)
Harness em `tool/qa/` (`run_matrix.py`, `batch.sh`, `local_fixtures.py`). **570 capturas em 50 execuções.**

Combinações realmente executadas (largura · idioma · tema), todas com usuário em teste gratuito (telas públicas, estudo e conta) e usuário expirado (paywall): 320 pt-BR escuro · 320 en claro · 320 es escuro · 390 en escuro · 360 es claro · 430 pt-BR claro · 768 pt-BR claro · 1024 en claro · 1440 pt-BR escuro · 1920 pt-BR claro.
Portal (admin e professor): 320 pt-BR claro · 390 en escuro · 768 es claro · 1440 pt-BR claro · 1920 en escuro.
Telas: login, cadastro, recuperar senha, apresentação, home, praticar, matéria, trilha, questão, prática rápida, simulado, revisar erros, favoritos, perfil, configurações, minha assinatura, privacidade e termos, minha conta, paywall (e deep links sob paywall), portal admin (visão geral, usuários, professores, solicitações, assinaturas, financeiro, integrações, auditoria, configurações) e portal professor (visão geral, alunos, estatísticas, financeiro, indicações, perfil).

| Tela | Largura · idioma · tema | Problema | Correção |
|---|---|---|---|
| Admin > Financeiro | 320/390/768/1440 (vários) | gráfico de barras com valor negativo (estorno) gerava altura negativa e exceção de layout | `BarChart` usa barra mínima para valor <= 0 |
| Professor > Alunos | 320 pt-BR claro | `Select` (filtro) estourava 5,6 px à direita | `Select` expande e trunca com reticências abaixo de 480 px |
| Admin > Configurações | 320 pt-BR claro | linha do interruptor "Bloqueio emergencial" estourava 4,5 px | texto do estado em `Flexible` com reticências |

Reexecutado depois da correção: admin 320 pt-BR claro (9 telas), admin 390 en escuro e professor 320 pt-BR claro: **zero ocorrências**. Demais combinações: sem overflow nem exceção no console de depuração.

### Limites declarados (não validado como "aprovado")
- Cliques de roteiro que não acharam o rótulo (itens abaixo da dobra no Perfil, "Simulado"/"Próxima" em alguns idiomas) foram **falhas do roteiro**, não de interface; essas telas não contam como verificadas naquela combinação. "Privacidade e termos" foi verificada por URL direta no grupo do paywall.
- Não executados: 360/430/768/1024/1440/1920 para todas as telas de estudo em todos os idiomas (só as combinações listadas), Aura/estatísticas/metas/redações/atualidades/mapas (o banco local só tem conteúdo de geografia e matemática), onboarding, confirmar e-mail, reaceite (`/aceite-legal`), bloqueio offline e atualização obrigatória em navegador (cobertos por testes de widget/roteador), F5/links antigos com `#`, troca de idioma/tema em execução, desconexão real/reinício offline, relógio adulterado, emulador Android, VoiceOver/TalkBack e contraste medido (só inspeção visual).
- A detecção automática cobre overflow e exceções do framework; corte de texto, desalinhamento e contraste foram vistos só por amostragem visual das capturas.

## Lacunas conhecidas
- Relógio adulterado e `popUntil` com diálogos abertos em dispositivo real: cobertos só por teste unitário/roteador.
- Último administrador não removível: regra existe em trigger (`app_admins_protect_last`) e foi revisada no código; teste destrutivo exigiria banco descartável com um único admin.
- Edge Functions com provedores reais (nenhuma credencial do AprovaAura disponível). Auditoria do projeto Supabase: `SUPABASE_AUDITORIA.md`.
- iOS não executado.

## Evidências (sem dados reais; usuários e valores fictícios do banco local)
`docs/qa/evidencias/10b-*`: paywall 320 es escuro; questão 390 en escuro; Financeiro (admin), Alunos (professor) e Configurações (admin) em 320 pt-BR claro após a correção.
