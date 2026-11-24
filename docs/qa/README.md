# QA consolidado — Etapa 10 (AprovaAura)

> Data-base: 24/11/2026. Nada foi ativado, publicado ou cobrado. Credenciais nunca aparecem aqui.
> Documentos: [RESULTADOS](RESULTADOS.md) · [BUGS_E_CORRECOES](BUGS_E_CORRECOES.md) · [SEGURANCA_E_BANCO](SEGURANCA_E_BANCO.md) · [FINANCEIRO_HOMOLOGACAO](FINANCEIRO_HOMOLOGACAO.md) · [IA_REDACAO_E_MENORES](IA_REDACAO_E_MENORES.md) · [ATIVACAO_E_ROLLBACK](ATIVACAO_E_ROLLBACK.md) · [SUPABASE_AUDITORIA](SUPABASE_AUDITORIA.md) · [IA_OPENAI_AVALIACAO](IA_OPENAI_AVALIACAO.md) · [PENDENCIAS_DO_DONO](PENDENCIAS_DO_DONO.md)
> Inventário detalhado de dependências externas: `docs/release/PENDENCIAS_EXTERNAS.md`. Plano de 20 passos: `docs/release/PLANO_ATIVACAO_COMERCIAL.md`.

## Classificação por componente
| Componente | Estado | Evidência / limite |
|---|---|---|
| Código Flutter (analyze) | CORRIGIDO E APROVADO | `flutter analyze`: 0 problemas, sem ignores genéricos |
| Suíte de testes Flutter | CORRIGIDO E APROVADO | 1196 passaram, 0 falharam, 0 ignorados |
| Gate/rotas (`gate_redirect_test`) | APROVADO | inclui o novo estado `legalRequired` |
| Acesso offline / relógio / 5xx | APROVADO (unitário) | `access_cubit_test`, testes do repositório; sem dispositivo real |
| Reaceite legal forçado | CORRIGIDO E APROVADO | gate + tela + testes; inerte até uma versão exigir reaceite |
| Banco: migrações do zero | APROVADO | 14 migrações em Postgres 16 vazio (base legada + stubs de auth) |
| Banco: regras financeiras A–D, concorrência de saldo, importação de relatório, permissões, exclusão de conta | APROVADO | `tool/db/sql_tests.py`: 66/66, em transação sempre revertida |
| Segurança REST (chave anônima) | APROVADO | `tool/db/rest_negative_tests.py`: 34/34 |
| Rollback de `20261201000100` | CORRIGIDO E APROVADO | reescrito por completo; preserva proteções de menores |
| Edge Functions (código) | PARCIALMENTE VALIDADO | Deno check/test ok; assinatura MP testada; NENHUMA publicada nem homologada com credencial real |
| Interruptor da correção por IA | CORRIGIDO E APROVADO (código) | `ESSAY_AI_PROVIDER=disabled`; falta publicar a função (depende de PAT) |
| Web (build release) | APROVADO (compila) | não publicada |
| Android debug APK / AAB release | APROVADO (compila) | 1.1.0+8; AAB assinado localmente, NÃO enviado à loja |
| iOS | NÃO VALIDADO | sem Mac/Xcode; `PrivacyInfo.xcprivacy` corrigido por leitura |
| QA visual (tamanhos, PT/EN/ES, claro/escuro) | PARCIALMENTE VALIDADO | testes de layout/golden existentes passam; sem rodada manual com capturas nesta etapa |
| Portais admin/professor (backend) | APROVADO no backend | RPCs, permissões, comissão, repasse e importação testados no SQL; telas só por testes de widget |
| Apple / Google / Mercado Pago (pagamento real) | BLOQUEADO POR DEPENDÊNCIA EXTERNA | sem credenciais do AprovaAura; `unassigned` não usadas |
| E-mail (Resend/SMTP/templates) | BLOQUEADO POR DEPENDÊNCIA EXTERNA | domínio/chave/PAT |
| Cloudflare/GitHub (AUTO_DEPLOY) | APROVADO (desligado) | nenhuma mudança |
| Documentos legais / site / lojas | PARCIALMENTE VALIDADO | minutas com `[PENDENTE-DONO]`; nenhuma revisão jurídica ocorreu |

## Veredito
**NO-GO para ativação comercial** enquanto houver os bloqueadores de [PENDENCIAS_DO_DONO](PENDENCIAS_DO_DONO.md). Etapa 10 (do roteiro) **não** é marcada como concluída em `docs/PREMIUM_PARTNERS.md`.
