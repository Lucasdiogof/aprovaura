# AprovaAura Premium + Partners — documento central

> **Fonte de continuidade entre sessões e agentes.** Atualize-o em TODA etapa.
> Estado em 2026-11-24: **Etapa 01 (fundação) concluída. O modelo comercial está DESLIGADO em produção.**

## 1. Decisões comerciais definitivas
- Premium **mensal R$ 19,90** e **anual R$ 190,00**. Mercado inicial: Brasil (BRL). **Sem plano gratuito permanente.**
- Novos usuários: **72h de Premium** após confirmar o e-mail (uma vez por pessoa). Usuários existentes na transição: **sem teste**.
- Admin: Premium permanente enquanto tiver o papel. Professor parceiro ativo: Premium grátis enquanto durar a parceria. Cortesia: concedida manualmente por admin.
- Pagamento: Android = Google Play Billing; iOS = Apple StoreKit; Web = Mercado Pago (Pix quando suportado). **Conta única** nas 3 plataformas e no futuro portal.
- Parceiros (professores): comissão padrão **50% do valor líquido** (após taxas/impostos acordados), percentual individual configurável. Repasse **manual via Pix todo dia 01**, sem mínimo; histórico financeiro preservado.
- Idiomas PT-BR/EN/ES; temas claro/escuro. O app **já está publicado** na Google Play e na App Store (a documentação antiga que dizia o contrário estava desatualizada).

## 2. Arquitetura (resumo)
```
Flutter  ──get_my_access()──▶  Supabase (Postgres)  ◀── futuros webhooks (service_role)
  AccessCubit                    compute_access()  (fonte única da decisão)
  AccessRepository               app_pre_request() (gate de API, HTTP 402/PT402)
  AccessGrantVerifier (RS256)    sign_access_token() (RSA-2048 em SQL; chave privada só no banco)
```
- **Decisão sempre no servidor.** O Flutter só lê (`AccessCubit.state.status`); nunca decide sozinho.
- **Gate central (`app_pre_request`)**: PostgREST o chama antes de CADA requisição (tabelas, RPCs, chamadas diretas à API). Com o modelo ligado, quem não tem acesso recebe `402 premium_required`, exceto na lista permitida (perfil, `get_my_access`, config pública, indicação, `is_username_available`, `admin_*`, `partner_*`). Edge Functions chamam RPCs com o JWT do usuário, então também passam pelo gate. `service_role` e `/auth/v1` não passam por ele. Ligado em produção via `alter role authenticator set pgrst.db_pre_request`.
- **Ordem de ativação, sem quebrar versões publicadas:** o gate é inerte (`commercial_enforced() = false`) e só passa a valer quando o admin chama `admin_set_commercial_enforcement(true)` (ver §9). Apps antigos não conhecem 402; quando ele ligar, recebem erro/lista vazia nas telas de estudo — por isso a ativação só ocorre depois de as versões novas estarem aprovadas nas lojas (e de `min_version_*` orientar o "atualize").

## 3. Papéis e permissões
| Papel | Onde vive | Premium |
|---|---|---|
| Aluno | implícito (qualquer conta) | via entitlements |
| Professor parceiro | `partners` (status `active`) | derivado em tempo real |
| Administrador | `app_admins` (`revoked_at is null`, e-mail confirmado) | derivado em tempo real |

- **Nada em `user_metadata`/`app_metadata`.** Papéis independem de Premium e mudam na MESMA conta, sem perder histórico.
- Sem autopromoção: tabelas novas têm RLS ligada e `REVOKE ALL` para `anon/authenticated`; tudo por RPC `security definer` com `search_path` fixo; `admin_*` chamam `require_admin()` (`42501` se não for admin).
- **Primeiro admin:** `bootstrap_first_admin(user_id)`, só `service_role`, só se não houver admin ativo, só com e-mail confirmado. Nunca inferido por nome/e-mail. Não há admin hoje (`app_admins` vazia). Depois, `admin_set_admin` (não remove o último admin).
- **Auditoria:** `admin_audit_log` (append-only, trigger `forbid_mutation`) recebe toda mudança administrativa e `partners` (trigger).

## 4. Modelo de dados (migrations 0100–0500)
| Tabela | Função |
|---|---|
| `admin_audit_log` | auditoria imutável (ator, ação, antes/depois) |
| `app_admins` | administradores (FK restrict em `auth.users`) |
| `commercial_config` | linha única: `enforcement_enabled`, `emergency_disable`, `launch_marker`, `legacy_grace_until`, `trial_hours`, `min_version_{android,ios,web}`, `essay_daily_limit`, `offline_ttl_hours_{user,staff}` |
| `entitlements` / `entitlement_events` | fontes armazenadas (`trial`,`apple`,`google`,`web`,`courtesy`); estados `pending,active,grace,canceled,expired,refunded,revoked`; histórico imutável; único por `(source, external_ref)` |
| `trial_grants` | 1 teste por **hash do e-mail normalizado** (ignora `+tag` e pontos do gmail); sem FK, sobrevive à exclusão da conta |
| `server_secrets` | chave privada RSA de assinatura (ninguém do cliente lê) |
| `partners`, `partner_links`, `partner_link_history`, `partner_change_requests` | programa de professores |
| `payments`, `commission_ledger`, `payouts` | financeiro (centavos `bigint`) |

## 5. Regras de autorização (acesso)
- `compute_access(uid)` une as fontes: `admin`, `partner` ativo, `entitlements` com estado `active|grace|canceled` e `starts_at <= now < ends_at`, e `transition` (carência opcional p/ usuários existentes). **Cancelada vale até o fim do período pago.** Expirar uma fonte nunca revoga outra.
- `access_allowed(uid) = not commercial_enforced() or has_access`.
- Provedores futuros gravam via `service_upsert_entitlement` (idempotente, só `service_role`).
- **Teste de 72h:** `maybe_grant_trial` roda dentro de `get_my_access`: exige `launch_marker`, conta criada **depois** do marco, e-mail confirmado, não ser admin/professor, e-mail nunca usado; relógio do servidor; trava advisory por usuário + índices únicos contra corrida/duplicidade.
- **Usuário existente** = `auth.users.created_at < commercial_config.launch_marker`. O marco é fixado (uma vez) ao ativar o modelo.
- Versão mínima (`min_version_*`) **só orienta a UI**; a autorização é o entitlement + gate. Nada confia na versão enviada pelo cliente.

## 6. Regras financeiras
- Tudo em **centavos `bigint`**; `net = gross − fee − tax` e `comissão + Lucksrei = net` por constraint.
- `record_confirmed_payment` (service_role) é **idempotente** por `(provider, external_id)`; grava o professor e o `commission_bps` **do momento** (só se a parceria estava ativa em `paid_at` e o vínculo já existia); comissão = `floor(net × bps / 10000)`.
- `record_payment_refund` gera ajuste **negativo** no razão (idempotente), mesmo após repasse (saldo pode ficar negativo e compensa nos meses seguintes). O Premium é revogado pela integração do provedor.
- `commission_ledger` é append-only; **saldo pendente = soma dos lançamentos**. `admin_register_payout` lança um valor negativo (não pode exceder o saldo); `admin_reverse_payout` lança o estorno. Cada competência (`America/Sao_Paulo`) fica preservada.
- Alterar percentual/indicação só afeta pagamentos futuros; cancelar assinatura não remove comissão já conquistada; encerrar a parceria (`admin_update_partner` status `ended`) interrompe novas comissões e o Premium de professor.
- `partner_my_summary` devolve só agregados (isolamento entre professores).

## 7. Offline
- `get_my_access` devolve `offline_grant`: JWS **RS256** (`kid`,`sub`,`iat`,`exp`,`enforced`,`allowed`,`roles`,`sources`), assinado em SQL com a chave privada de `server_secrets`. O app embute só a pública (`lib/features/access/data/access_keys.dart`).
- Validade: `min(fim do acesso, agora + TTL)`; TTL usuário 168h, staff 24h; sem modelo ligado, 30 dias. Trial ⇒ vale até o fim das 72h.
- `AccessGrantVerifier`: assinatura, `sub == conta atual` (trocar de conta não reaproveita), expiração e **relógio**: um "último instante visto" por conta que só avança; relógio recuado ⇒ exige conexão.
- Sem autorização válida: se o app já viu o modelo ligado, exige conexão (`AccessStatus.connectionRequired`); senão segue como hoje. **Limites assumidos:** dica local não é assinada; aparelho adulterado pode burlar offline; o servidor continua barrando tudo que for online.
- `PendingSyncQueue` preservada: resposta 402 deixa a ação **na fila, intacta** (não conta tentativa, não descarta). Offline continua só onde já existia; nada online-only virou offline.
- Assinatura RSA em SQL leva ~0,4s por chamada; o `AccessCubit` limita a 1 refresh/60s (exceto login/reconexão/402).

## 8. Flutter (camada pronta, sem UI nova)
`lib/features/access/` (entidade `AccessStatus`, `AccessRepository`, `AccessGrantVerifier`, `AccessCubit`), `lib/features/partners/` (listar ativos, vínculo, solicitar troca), `PremiumRequiredFailure` (HTTP 402) em `failureFromError`, `wireAccessSupport()` em `injection_container.dart` (login/abertura, saída, retorno do segundo plano, reconexão, 402). **Ainda não existe** paywall, tela de bloqueio, redirecionamento do router, seleção de professor no cadastro nem portal — etapas seguintes.

## 9. Migrations e operação
| Arquivo (`supabase/migrations/`) | Conteúdo | Aplicada em produção? |
|---|---|---|
| `20261124000100_access_roles_config.sql` | auditoria, admins, config | sim (2026-11-24) |
| `20261124000200_partners.sql` | parceiros e vínculos | sim |
| `20261124000300_entitlements_trial_offline.sql` | entitlements, trial, acesso, assinatura | sim |
| `20261124000400_finance.sql` | financeiro | sim |
| `20261124000500_enforcement_gate_essay.sql` | gate de API + limite de redações configurável | sim |

Rollbacks em `supabase/rollbacks/*.down.sql` (os de 0200/0300/0400 apagam dados: só antes de uso real). Aplicar com `tool/db/apply_migration.py` (ensaio `dry` com ROLLBACK, depois `apply`); **nunca `supabase db push`**. A chave de assinatura foi gerada com `tool/db/gen_access_key.py` (kid `k1`).

**Rollback imediato do gate** (se algo estranho): `alter role authenticator reset pgrst.db_pre_request; notify pgrst, 'reload config';`.
**Desativação emergencial** (modelo já ligado): admin chama `admin_update_commercial_config('{"emergency_disable": true}')` (ou, sem admin, `update commercial_config set emergency_disable = true` via banco).
**Ativação (NÃO fazer antes do checklist §12):** `admin_set_commercial_enforcement(true)`.

### Limite de redações
`essay_daily_evaluation_limit()` agora lê `commercial_config.essay_daily_limit` (padrão 3, fuso America/Sao_Paulo). `supabase/essays.sql` foi atualizado para a mesma definição. Gemini, idempotência, XP e novas tentativas intactos; sem billing.

## 10. Segurança do conteúdo — superfícies auditadas (2026-11-24)
- **Tabelas de leitura pública** (`using (true)`): `questions`, `catalog_nodes`, `*_translations`, `dossiers*`, `essay_themes*`. Agora cobertas pelo gate central (inclusive acesso direto à API).
- Tabelas pessoais (progresso, xp, streak, redações, simulados, favoritos): RLS por `auth.uid()`; escrita por RPC `security definer` com `search_path=public`.
- Todas as funções `security definer` existentes têm `search_path` fixo. `anon` ainda tem EXECUTE nas RPCs antigas (todas checam `auth.uid()` ou só leem conteúdo público); **não foi revogado** para não quebrar versões publicadas (ex.: `is_username_available` precisa de anon).
- **Gabarito:** `questions.correct_index` continua legível por quem tem acesso (o app corrige no cliente). Endurecer de verdade exige corrigir no servidor (RPC `check_answer`) e tirar `correct_index` do `select` — **só viável depois que as versões antigas forem desligadas** (`min_version_*`). Simulados continuam online-only e sem gabarito antecipado pelos RPCs.
- Mapas (`lib/assets/maps`) e GeoJSON ficam embarcados (sem gabarito de questões).
- Realtime/Storage não são usados para conteúdo de estudo (NÃO CONFIRMADO no painel).

## 11. Estratégia de transição
1. Etapa 01 (feita): backend + camada Flutter, tudo inerte.
2. Publicar novas versões nas lojas com a camada de acesso, paywall e pagamentos; manter modelo desligado.
3. Opcional: `legacy_grace_until` para carência dos usuários existentes; `min_version_*` para o "atualize".
4. Ativar. Dados dos usuários existentes preservados (nada é apagado); sem assinatura/entitlement, só perdem o acesso até assinar.

## 12. Pendências externas e checklist futuro
**Externas (bloqueiam o lançamento):**
- **Ligar a confirmação de e-mail** no Supabase Auth (hoje `mailer_autoconfirm = true`: "e-mail confirmado" não significa nada) **e configurar SMTP próprio** (o embutido limita a ~2 e-mails/hora). Sem isso, o teste de 72h e a identificação de admin não têm lastro.
- Definir quem é o primeiro admin e rodar `bootstrap_first_admin` (candidato óbvio: a conta do dono; confirmar o `user_id`).
- Contas/contratos nas lojas: produtos de assinatura (mensal/anual) na Apple e na Google, Small Business Program, dados bancários/fiscais — **NÃO CONFIRMADO** (consoles).
- Mercado Pago: credenciais estão no cofre como `unassigned`; confirmar posse/ambiente antes de usar.
- Cloudflare Workers Builds (integração Git) pode publicar sozinho a cada push, independente do GitHub Actions — **NÃO CONFIRMADO** (sem acesso ao painel).
- `AUTO_DEPLOY` (variável do GitHub) foi posta em `false` na Etapa 01 para o push em `main` não publicar a web durante o desenvolvimento; **reativar (`true`) só no lançamento**. Deploy manual: `workflow_dispatch`.

**Roadmap:** E02 onboarding + seleção de professor no cadastro + paywall/tela de bloqueio + redirect do router; E03 Mercado Pago (web) + webhooks → `record_confirmed_payment`/`service_upsert_entitlement`; E04 StoreKit/Play Billing + validação de recibos; E05 portal `/partners` (professor/admin, mesma conta; rota separada no Cloudflare); E06 endurecer gabaritos (check_answer no servidor); E07 QA consolidado, análise estática, builds, homologação, lançamento.

**Checklist de QA/publicação (a executar na etapa final):** `flutter analyze` + testes; revisar código novo da Etapa 01 (escrito sem analyze); teste de ponta a ponta de `get_my_access`, trial, cortesia, gate 402 (com enforcement ligado em ambiente de teste), offline (relógio recuado, troca de conta, expiração), fila offline sob 402; testes das RPCs financeiras; builds Android/iOS/Web; revisão de strings PT/EN/ES e temas; atualizar política de privacidade e termos (assinatura, parceiros); ativar modelo; monitorar; manter `emergency_disable` à mão.
