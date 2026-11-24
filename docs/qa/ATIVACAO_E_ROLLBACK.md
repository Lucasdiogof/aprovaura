# Ativação e rollback

## Sequência de ativação
Os 20 passos definitivos (pré-requisitos, responsável, "pronto quando" e rollback de cada um) estão em `docs/release/PLANO_ATIVACAO_COMERCIAL.md`. Resumo da ordem: QA e correções (1-2) → credenciais e funções (3-4) → produtos e sandbox (5-7) → web e conciliação (8-9) → legal e conta de revisão (10-11) → lojas (12-14) → web coordenada (15) → e-mail obrigatório (16) → monetização (17) → versões mínimas (18) → monitoramento (19) → rollback (20).

Estado desta etapa: passos 1 e 2 **executados** (ver `RESULTADOS.md`). Os demais dependem do dono (ver `PENDENCIAS_DO_DONO.md`). Antes do passo 12: versão do app **1.1.0+8** já definida (acima do 1.0.4+7 publicado; IDs inalterados). iOS exige Mac/Xcode e assinatura do dono; não foi declarado pronto.

## Procedimento de rollback comercial: três coisas diferentes
| Quero... | Ação | Efeito | Reversível |
|---|---|---|---|
| **Suspender cobranças** (parar de vender) | `payment_providers_config.enabled=false` por provedor | ninguém consegue iniciar compra; quem já assina continua com acesso | sim |
| **Suspender o bloqueio** (todos voltam a estudar) | `commercial_config.emergency_disable=true` (vence `enforcement_enabled`) | `commercial_enforced()` vira falso; paywall some; entitlements e pagamentos intactos | sim |
| **Revogar direitos** (cortar acesso de alguém) | revogação de entitlement de **cortesia** por RPC admin | só cortesias; compra de provedor não é revogável pelo admin | revogação é auditada |

Regras: nunca apagar `payments`, `entitlements` ou `commission_ledger` para "voltar atrás"; para corrigir valores usar estorno/ajuste. Para desfazer a Etapa 09 no banco: `supabase/rollbacks/20261201000100_*.down.sql` (preserva proteções de menores) e `…0200…down.sql`. Nenhum rollback altera versões mínimas (`min_version_*` só sobe com autorização do dono).

## Interruptores existentes
`emergency_disable`, `enforcement_enabled`, `email_verification_required`, `payment_providers_config.enabled` (por provedor), `min_version_*`, `ESSAY_AI_PROVIDER` (correção por IA), `AUTO_DEPLOY` (GitHub; desligado). Nenhum foi alterado na Etapa 10.
