# Resultados executados (24/11/2026)

| Verificação | Comando | Resultado |
|---|---|---|
| Análise estática | `flutter analyze` | Sem problemas |
| Testes Flutter | `flutter test` | **1196 passaram · 0 falharam · 0 ignorados** (inclui `test/core/router/gate_redirect_test.dart`) |
| Edge Functions | `deno check --node-modules-dir=auto` + `deno test` (`_shared/mp_signature_test.ts` 4, `essay_provider_test.ts` 2) | Passaram |
| SQL (produção, transação revertida) | `python tool/db/sql_tests.py` | **66 passaram · 0 falharam** |
| REST anônimo | `python tool/db/rest_negative_tests.py` (precisa de `SUPA_URL` e `SUPA_ANON`) | **34/34 negados** |
| Migrações do zero | `bash tool/db/empty_db_check.sh` (Docker, `postgres:16-alpine`) | 14/14 aplicadas |
| Web | `flutter build web --release` | Compilou |
| Android | `flutter build apk --debug` · `flutter build appbundle --release` | APK 183 MB · AAB 66 MB (1.1.0+8) |
| iOS | — | Não executado (sem Mac/Xcode) |

## O que os testes cobrem (mapa pedido na Etapa 10)
- **Acesso** (`access_cubit_test`): resolving, aberto, paywall, motivo, conexão exigida, versão mínima, erro sem inventar bloqueio, reset de conta, intervalo, reaceite legal (4 casos).
- **Rotas protegidas** (`gate_redirect_test`, `auth_redirect_test`): paywall barra estudo e deep links; portal fora do paywall; conexão/versão; reaceite só permite aceite e documentos.
- **Cadastro/login/recuperação/onboarding** (`login_page_test`, `register_page_test`, `auth_screens_layout_test`, `widget_test`).
- **Perfil / exclusão de conta** (`profile_page_test`).
- **Conciliação** (`report_parser_test`), **assinatura MP** (Deno).
- **Banco**: trial, bloqueios e papéis (migrações anteriores), financeiro A–D, estorno parcial, bps por data, importação de relatório, permissões negativas, exclusão de conta.

## Lacunas conhecidas (não executadas nesta etapa)
- Relógio adulterado e `popUntil` com diálogos abertos em dispositivo real: cobertos só por teste unitário/roteador.
- Rodada visual manual (Chrome/emulador, tablet/desktop, PT/EN/ES, claro/escuro) com capturas.
- Último administrador não removível: regra existe em trigger (`app_admins_protect_last`) e foi revisada no código; teste destrutivo exigiria banco descartável com um único admin.
- Edge Functions com provedores reais (nenhuma credencial do AprovaAura disponível).
