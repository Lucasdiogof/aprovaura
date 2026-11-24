# AprovaAura Premium + Partners — documento central

> **Fonte de continuidade entre sessões e agentes.** Atualize-o em TODA etapa.
> Estado em 2026-11-30: **Etapas 01 a 08 concluídas em código (08 = paywall e integração final, §19). O modelo comercial e a confirmação obrigatória de e-mail estão DESLIGADOS em produção.**

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
| Administrador | `app_admins` (`revoked_at is null`, e-mail PROVADO em `email_verifications`) | derivado em tempo real |

- **Nada em `user_metadata`/`app_metadata`.** Papéis independem de Premium e mudam na MESMA conta, sem perder histórico.
- Sem autopromoção: tabelas novas têm RLS ligada e `REVOKE ALL` para `anon/authenticated`; tudo por RPC `security definer` com `search_path` fixo; `admin_*` chamam `require_admin()` (`42501` se não for admin).
- **Primeiro admin:** `bootstrap_first_admin(user_id)`, só `service_role`, só se não houver admin ativo, só com e-mail provado (`email_is_verified`). Nunca inferido por nome/e-mail. **Existe 1 admin ativo** (conta do dono, user `ace375c8…`, e-mail `lu***@gmail.com`, confirmado pelo dono; reconhecida com `owner_attest_email`). Depois, `admin_set_admin` (não remove o último admin).
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
- Validade: `min(fim do acesso, agora + TTL)`; TTL usuário 168h, staff 24h; **sem modelo ligado, 24h** (era 30 dias; migration 0600 — uma permissão permissiva antiga não sobrevive à ativação por mais que isso). Conta com e-mail não provado e confirmação obrigatória ligada não recebe autorização. Trial ⇒ vale até o fim das 72h.
- `AccessGrantVerifier`: assinatura, `sub == conta atual` (trocar de conta não reaproveita), expiração e **relógio**: um "último instante visto" por conta que só avança; relógio recuado ⇒ exige conexão.
- Sem autorização válida: se o app já viu o modelo ligado, exige conexão (`AccessStatus.connectionRequired`); senão segue como hoje. **Limites assumidos:** dica local não é assinada; aparelho adulterado pode burlar offline; o servidor continua barrando tudo que for online.
- `PendingSyncQueue` preservada: resposta 402 deixa a ação **na fila, intacta** (não conta tentativa, não descarta). Offline continua só onde já existia; nada online-only virou offline.
- Assinatura RSA em SQL leva ~0,4s por chamada; o `AccessCubit` limita a 1 refresh/60s (exceto login/reconexão/402).

## 8. Flutter (camada de acesso; UI de cadastro/perfil na Etapa 02)
`lib/features/access/` (entidade `AccessStatus`, `AccessRepository`, `AccessGrantVerifier`, `AccessCubit`), `lib/features/partners/` (listar ativos, vínculo, solicitar troca), `PremiumRequiredFailure` (HTTP 402) em `failureFromError`, `wireAccessSupport()` em `injection_container.dart` (login/abertura, saída, retorno do segundo plano, reconexão, 402). Paywall, telas de bloqueio e portal vieram nas Etapas 04-08 (§15-§19). A seleção de professor no cadastro, a tela do código de e-mail e a seção "professor indicador" do perfil existem (§13).

## 9. Migrations e operação
| Arquivo (`supabase/migrations/`) | Conteúdo | Aplicada em produção? |
|---|---|---|
| `20261124000100_access_roles_config.sql` | auditoria, admins, config | sim (2026-11-24) |
| `20261124000200_partners.sql` | parceiros e vínculos | sim |
| `20261124000300_entitlements_trial_offline.sql` | entitlements, trial, acesso, assinatura | sim |
| `20261124000400_finance.sql` | financeiro | sim |
| `20261124000500_enforcement_gate_essay.sql` | gate de API + limite de redações configurável | sim |
| `20261125000100_email_proof_legal_referral.sql` | prova de e-mail, trial na confirmação, termos/consentimentos, busca de professores, gate PT403 | sim (2026-11-25) |
| `20261125000200_discard_unconfirmed_signup.sql` | corrigir e-mail no cadastro + rota no gate | sim (2026-11-25) |
| `20261126000100_admin_portal.sql` | RPCs do portal admin, atividade, vínculo/solicitações, config | sim (2026-11-26) |

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
- **Aplicar a configuração de e-mail do Auth** (exige um *Personal Access Token* do dono; o token disponível não alcança este projeto): `supabase/apply_auth_email_config.ps1 -Templates`, depois `-Smtp`, e só no lançamento `-Activate` (ver §13.6).
- Confirmar no painel do Resend o domínio/remetente (`no-reply@lucksrei.com`) — a chave do cofre é só de envio e não lista domínios.
- Contas/contratos nas lojas: produtos de assinatura (mensal/anual) na Apple e na Google, Small Business Program, dados bancários/fiscais — **NÃO CONFIRMADO** (consoles).
- Mercado Pago: credenciais estão no cofre como `unassigned`; confirmar posse/ambiente antes de usar.
- Cloudflare Workers Builds (integração Git) pode publicar sozinho a cada push, independente do GitHub Actions — **NÃO CONFIRMADO** (sem acesso ao painel).
- `AUTO_DEPLOY` (variável do GitHub) foi posta em `false` na Etapa 01 para o push em `main` não publicar a web durante o desenvolvimento; **reativar (`true`) só no lançamento**. Deploy manual: `workflow_dispatch`.

**Roadmap oficial (exatamente dez etapas, 01–10; não renumerar):** 1 Fundação, segurança e monetização ✔; 2 Cadastro, Resend e confirmação de e-mail ✔; 3 Onboarding animado com Aurudo ✔; 4 Portal administrativo ✔ (§15); 5 Portal dos professores ✔; 6 Financeiro, comissões e repasses ✔; 7 Apple, Google e Mercado Pago ✔; 8 Paywall e integração final ✔ (§19); 9 Termos, privacidade e preparação comercial ✔ (§20); 10 QA consolidado, correções e publicação.

**Checklist de QA/publicação (a executar na etapa final):** `flutter analyze` + testes; revisar código novo da Etapa 01 (escrito sem analyze); teste de ponta a ponta de `get_my_access`, trial, cortesia, gate 402 (com enforcement ligado em ambiente de teste), offline (relógio recuado, troca de conta, expiração), fila offline sob 402; testes das RPCs financeiras; builds Android/iOS/Web; revisão de strings PT/EN/ES e temas; atualizar política de privacidade e termos (assinatura, parceiros); ativar modelo; monitorar; manter `emergency_disable` à mão.


## 13. Etapa 02 — cadastro, autenticação, Resend e indicação (2026-11-25)

### 13.1 Prova de e-mail (regra central)
`auth.users.email_confirmed_at` **não prova nada** hoje (`mailer_autoconfirm = true` confirma na criação). Prova real = linha em `email_verifications`: gravada por gatilho (`on_auth_email_confirmed_trg`) quando o GoTrue **atualiza** `email_confirmed_at` de nulo para preenchido (validação do código de 6 dígitos), ou `owner_attest_email(user)` (só `service_role`). O cliente nunca declara e-mail confirmado. `is_admin`, `bootstrap_first_admin`, `admin_set_admin`, trial e `must_verify_email` usam essa tabela. O admin existente foi atestado pelo dono; os outros 6 usuários **não** têm prova (preservados, sem nenhuma alteração).

### 13.2 Fluxo de cadastro (Flutter)
Cadastro → (com confirmação ligada, `signUp` volta sem sessão) → tela **/confirmar-email**: campo de 6 dígitos (cola, autofill `oneTimeCode`, só dígitos), reenvio com intervalo de 60s, bloqueio local de 60s após 5 erros (o GoTrue também limita), mensagens de código errado/expirado/sem conexão, dica de spam, **"Digitei o e-mail errado"** (informa novo e-mail + a senha criada → `discard_unconfirmed_signup` apaga SÓ conta sem prova com senha conferida → refaz o cadastro com os dados guardados) e "Voltar para o login". Interrupção: o cadastro pendente (sem senha) fica em `SharedPreferences`; ao reabrir, o login leva de volta à tela do código. Login de conta não confirmada (`email_not_confirmed`) também leva ao código (e envia código novo). Sucesso → sessão aberta pelo GoTrue → `/onboarding` (cadastro) ou `/home`. Hoje (autoconfirm ligado) o cadastro continua entrando direto, como antes. Login por e-mail+senha e recuperação por código seguem iguais. Nenhum link externo no fluxo principal.

### 13.3 Indicação de professor
Campo "Qual professor indicou o AprovaAura para você?" no cadastro (some se não há professor ativo; padrão "Não fui indicado por um professor."): seletor com busca (`search_active_partners`, paginado, só `id` + nome de divulgação, ordem alfabética, ativos). A escolha vai em `user_metadata.referral_partner_id` (ou `referral_code`, para links/códigos futuros) e **só é aplicada no servidor** quando o e-mail é provado (gatilho) ou no `get_my_access` (`_apply_signup_referral` → `_link_once`, idempotente, vínculo único). Sobrevive a fechar/reabrir o app (fica no metadado). Indicação inválida/inativa nunca bloqueia a conta.

### 13.4 Perfil: professor indicador
Linha "Professor indicador" no grupo Conta do perfil (só aparece se já há vínculo ou há professor ativo): sem vínculo prévio → escolher (vínculo único feito pelo aluno, `link_partner`); já vinculado → mostra o professor e permite **solicitar troca** com motivo opcional (`request_partner_change`, uma pendente por vez, status "troca em análise"). Aprovação é do admin (`admin_review_partner_change`, portal futuro); troca não retroage (Etapa 01).

### 13.5 Trial, e-mails antigos, gate
- **Trial de 72h** só começa na confirmação efetiva (`maybe_grant_trial` exige prova `otp`; `ends_at = verified_at + 72h`; só contas criadas depois de `launch_marker`; uma vez por e-mail normalizado; admin/professor não recebem). Substitui o início baseado em `get_my_access` da Etapa 01.
- **Gate (`app_pre_request`)**: novo erro `PT403 email_unverified` (HTTP 403) quando `commercial_config.email_verification_required` está ligada e o e-mail não foi provado; continua `PT402` para falta de Premium. Rotas liberadas sem Premium/e-mail: perfil, `get_my_access`, `get_public_app_config`, professores, vínculo/troca, termos, consentimento, `discard_unconfirmed_signup`, `admin_*` (validam admin por dentro). Confirmação/recuperação são do GoTrue (não passam pelo gate). O app trata PT403 saindo da conta e levando ao login, que retoma o código.
- **Usuários antigos (7)**: nada foi alterado. Estratégia pronta (não executada): `admin_update_commercial_config({"email_verification_required": true, "legacy_verification_deadline": "<data>"})` + `require_email_reverification(user)` por usuário (zera `email_confirmed_at`; no próximo login o app pede o código e o GoTrue confirma de verdade; dados, sessões e perfil preservados; admin/atestados ficam de fora). Contas criadas depois de `email_verification_since` já exigem prova imediatamente.
- **Autorização offline**: sem modelo, 24h (antes 30 dias). Limite assumido: aparelho que nunca mais conecta após a ativação segue com a última autorização até ela expirar (≤24h no modo sem modelo; 7 dias/24h staff no modo ligado).

### 13.6 Resend/SMTP e e-mails
- **Estado verificado**: cofre tem a chave do Resend `resend.unassigned` (somente envio; não lista domínios — 401). Domínio de envio já usado pela Lucksrei: `lucksrei.com` (verificado/parcial segundo notas; **confirmar no painel**). Nenhum domínio novo; remetente planejado `AprovaAura <no-reply@lucksrei.com>`. Cota do plano grátis (100/dia) é **compartilhada** com a Lucksrei — se o volume crescer, subir de plano ou separar chave/domínio (custo: decisão do dono).
- **Nada foi aplicado no Auth** (falta PAT do dono). Pronto para aplicar: `supabase/apply_auth_email_config.ps1` — `-Templates` (assuntos + templates signup/recovery + OTP 6 dígitos/1h; seguro agora), `-Smtp` (SMTP Resend; chave lida do cofre em runtime, nunca impressa; `rate_limit_email_sent = 30/h`), `-Activate` (`mailer_autoconfirm=false`; só no lançamento).
- **Templates** `supabase/templates/{signup,recovery}_code.html` (gerados por `build_templates.py`): HTML responsivo, e-mail compatível (tabela-less com estilos inline, sem imagens externas), código destacado em monoespaçada, validade 1h, aviso de ignorar, rodapé Lucksrei Systems. **PT/EN/ES num arquivo** com `{{ if eq .Data.lang "en" }}…` — o app grava `user_metadata.lang` no cadastro; sem `lang` cai em português (o Supabase não traduz sozinho). Assunto único trilíngue. Só e-mails de autenticação. O logotipo no e-mail é um selo "A" em CSS (sem dependência de imagem hospedada); trocar por imagem oficial quando houver URL pública.
- **Limites propostos** (aplicar no painel Auth › Rate Limits no lançamento): e-mails 30/h (SMTP), verificação de OTP 30/5min por IP, reenvio mínimo 60s (cliente + `max_frequency` do GoTrue), 5 erros → trava local de 60s. CAPTCHA/Turnstile para cadastro não foi ativado (custo/UX; avaliar se houver abuso).

### 13.7 Termos e privacidade
Tabelas `legal_documents` (versão vigente por tipo), `legal_acceptances` (aceite por usuário/versão, origem, data) e `study_sharing_consents` (consentimento de compartilhar **estatísticas de estudo** com professor vinculado; histórico imutável; padrão = não compartilha; menores exigem consentimento do responsável). RPCs: `get_legal_status`, `record_legal_acceptance`, `get_study_sharing`, `set_study_sharing`. Hoje só a **Política de Privacidade** (2026-09-28) está publicada; **os Termos de Uso NÃO existem e não foram inventados** — quando o dono publicar, inserir em `legal_documents` com `is_current` e o cadastro passa a mostrar os dois links (caixa única "Li e concordo", textos curtos + links). O aceite do cadastro vai em `user_metadata.legal_accept` e é gravado quando o e-mail é provado. **Aceitar termos ≠ consentir compartilhamento.** Nenhuma função de leitura para professores existe: redações, credenciais e dados pessoais nunca entram no escopo; o portal do professor (Etapa 06) só poderá ler estatísticas agregadas com consentimento ativo e vínculo ativo.

### 13.8 Pendências externas da Etapa 02
1. Dono: PAT do Supabase → rodar `apply_auth_email_config.ps1 -Templates` e `-Smtp`; confirmar domínio/remetente no Resend.
2. Publicar nas lojas uma versão com a tela do código **antes** de `-Activate`.
3. Publicar Termos de Uso (e atualizar a Política com assinatura/parceiros/compartilhamento).
4. Decidir `legacy_verification_deadline` e rodar `require_email_reverification` nos usuários antigos.
5. Revisar QA do Flutter (escrito sem `flutter analyze`/testes, por diretriz).

### 13.9 Checklist de ativação coordenada
(a) versão pública com `/confirmar-email` nas lojas e web; (b) `-Templates` e `-Smtp` aplicados e um e-mail real de signup/recovery recebido (Gmail e Apple Mail, PT/EN/ES); (c) limites de taxa configurados; (d) `admin_update_commercial_config({"email_verification_required": true})`; (e) `-Activate` (autoconfirm off); (f) testar cadastro novo, reenvio, código errado/expirado, corrigir e-mail, login de conta pendente, recuperação de senha; (g) legados (§13.5); (h) só então a ativação comercial (§9). Rollback: `-Activate` reverso (`mailer_autoconfirm=true` via painel) e `email_verification_required=false`.


## 14. Etapa 03 — onboarding animado e experiência inicial (2026-11-25)

### 14.1 Três fluxos distintos
1. **Apresentação do produto** (`lib/features/intro/`, rota `/apresentacao`): cinco telas animadas, uma única vez por instalação/perfil de navegador, pulável.
2. **Cadastro e confirmação de e-mail** (`/cadastro`, `/confirmar-email`, Etapa 02).
3. **Configuração pessoal** (`lib/features/onboarding/`, rota `/onboarding`: objetivo, ano da prova, matérias) — intacta.

Fluxo de um novo usuário: apresentação → (Criar minha conta | Já tenho conta) → cadastro → código de e-mail (quando a confirmação obrigatória estiver ativa) → configuração pessoal → `/home`. Hoje (autoconfirm ligado) o cadastro vai direto à configuração. O login fica a um toque em todas as telas da apresentação ("Já tenho conta").

### 14.2 Telas
1 Bem-vindo (logo + Aurudo acenando, partículas ambiente); 2 Pratique e evolua (Aurudo estudando, questão que se responde sozinha, chips de disciplinas/trilhas/dificuldade/simulados); 3 Aprenda com seus erros (anel de acertos, barras de evolução, meta diária, sequência de 7 dias, chips); 4 Aprimore suas redações (Aurudo pensando, folha que "se escreve", 5 barras de competências C1–C5, aviso "não é nota oficial nem garantia"); 5 Farme Aura (**`AurudoFarmAuraAnimation`**, barra de nível que sobe e vira Nível 4, "+10" Aura, chips de ganho/conquistas/sequência; CTA "Criar minha conta"). A linha do período experimental só aparece na tela 5 **se o servidor reportar o modelo comercial ativo** (`get_public_app_config`) e diz que o teste começa **após a confirmação do e-mail** — nunca que já começou. Sem o modelo ativo, mostra só "Sua jornada começa agora."

### 14.3 Componentes reaproveitados / novos
- **Reaproveitados (sem alteração):** `AurudoFarmAuraAnimation` (replay por `ValueKey` a cada chegada à tela 5), `AurudoIllustration` (acenando/estudando/pensando com suas animações próprias, só `animate: active`), `AuraParticles` (ambient), `AuraGlyph`, `AppLogo`, `AppButton`, `AppColors`/`AppSpacing`, `LocaleCubit`.
- **Novos:** `IntroPage` (PageView, parallax/fade entre páginas, indicadores, gestos + botões + setas do teclado, seletor de idioma, "Pular"), `IntroScene` (relógio de animação por tela: roda **só enquanto a tela está visível**, volta a zero ao sair; sob redução de movimento mostra o estado final), `intro_visuals.dart` (5 visuais desenhados numa caixa 320×360 e escalados), `intro_common.dart`, `IntroStrings` (PT/EN/ES), `IntroStore`.
- Animações nativas Flutter; nenhuma dependência nova. Layout largo (≥860 px): visual e texto lado a lado, conteúdo limitado a 1100 px.

### 14.4 Persistência (`IntroStore`, SharedPreferences) — nunca concede Premium
- `intro_seen_v1`: apresentação vista/pulada. Independente de trial/assinatura; **nenhuma flag local concede acesso** (o servidor decide).
- `setup_pending_uid_v1`: a conta que entrou na configuração pessoal e não terminou; o router leva `/home` → `/onboarding` só para essa conta, e a flag é limpa ao concluir. Contas existentes nunca recebem a flag (não refazem a configuração). Nada de XP/progresso/trial é tocado.
- Redirect (`authRedirect`): sem sessão e sem intro vista → `/apresentacao` (a menos que haja confirmação de e-mail pendente); com sessão, `/login` e `/apresentacao` → `/home` (ou `/onboarding` se pendente).

### 14.5 Integração futura (paywall)
O destino final do fluxo é a única linha `context.go('/home')` da configuração pessoal; a Etapa 04 pode trocar por uma decisão por estado de acesso (`AccessCubit`) sem mexer na apresentação, no cadastro ou na configuração. O CTA e a linha de teste já leem `get_public_app_config`.

### 14.6 Correções de etapas anteriores
- Etapa 02: a falha ao buscar documentos legais **não ignora mais o aceite** — o cadastro fica bloqueado com mensagem e "Tentar de novo" (`AuthRepository.publicConfig()` devolve `null` na falha; substitui `legalDocuments()`).
- Etapa 02: logo oficial nos e-mails — `web/email/aprovaura-mark.png` (publicado junto com a web) referenciado como `{{ .SiteURL }}/email/aprovaura-mark.png`; **só funciona após o deploy da web** e se `site_url` do Auth for o domínio da web (o script avisa se o arquivo ainda não responde). Sem a imagem, o e-mail mostra o texto alternativo. Nenhuma URL foi inventada.
- Etapa 02: a navegação inicial respeita a confirmação pendente (a apresentação não a atropela); recuperação de falhas de conexão na tela do código (erro de rede não conta tentativa; reenvio disponível).

### 14.7 Pendências externas
Publicar a web (o logo do e-mail depende disso) e conferir `site_url`; demais pendências da §13.8 continuam.

### 14.8 Checklist de QA futuro (Etapa 03)
Primeira abertura (Android/iOS/web) → apresentação; pular; reabrir (não repete); trocar idioma na apresentação; redução de movimento; fonte grande (sem corte); celular pequeno, tablet, desktop; claro/escuro; voltar/avançar por gesto, botão e teclado; replay da tela 5 ao voltar; cadastro novo → configuração → app; fechar o app no meio da configuração e reabrir (retoma); usuário existente (não vê configuração; vê apresentação uma vez); confirmação de e-mail pendente ao abrir; verificar consumo (nenhum controller rodando fora da tela visível).


## 15. Etapa 04 — Portal administrativo (2026-11-26)

### 15.1 Arquitetura e URL
- **https://aprovaura.lucksrei.com/partners** é o próprio Flutter Web (mesmo bundle, Auth, tema e idiomas). O app passou a `usePathUrlStrategy()` (URLs sem `#`); o Cloudflare já devolve `index.html` para qualquer caminho (SPA). **Links antigos `/#/rota` continuam abrindo** (`_initialLocation` lê o fragmento). Acesso direto, F5 e voltar funcionam; sem sessão → `/login?next=/partners/...` e, após entrar, volta ao destino (só aceita `next` que comece com `/partners`; nunca redireciona para fora).
- `lib/features/portal/`: `data/portal_api.dart` (único cliente de RPCs `admin_*` + Edge Function), `l10n/portal_strings.dart` (PT/EN/ES, datas/moeda por idioma), `presentation/widgets/portal_widgets.dart` (cards, tabela responsiva, paginação, filtros, skeleton, gráficos de barras sem dependência), `pages/` (gate/shell, dashboard, usuários, detalhe, professores, solicitações, assinaturas, configurações, auditoria).
- **Gate**: `PortalSession` lê `get_my_access` **direto do servidor** (nunca da autorização offline) e decide a interface: administrador → portal completo; professor ativo → casca compartilhada com placeholder (Etapa 05); demais → "Acesso restrito" + link para o app. Reconsulta a cada 5 min e quando qualquer operação volta `42501` (perda de papel na sessão fecha o portal). Sessão expirada (JWT) → logout e login com retorno. Cada RPC valida `require_admin()` no servidor: esconder menu não é segurança.

### 15.2 Telas
Visão geral (indicadores + gráficos diários, presets hoje/7d/30d/mês atual/anterior/personalizado), Usuários (busca nome/username/e-mail; filtros acesso, professor, indicação, e-mail verificado, data; ordenação; paginação no servidor), Detalhe do usuário (Conta, Premium com concessão/revogação, Professor indicador com histórico e solicitações, Estatísticas, Financeiro), Professores (lista, cadastro, detalhe com alunos/estatísticas/histórico, editar, encerrar/reativar), Solicitações (badge de pendentes no menu), Assinaturas, Auditoria (detalhe + registros anteriores/posteriores), Configurações.

### 15.3 Migration `20261126000100_admin_portal.sql` (aplicada; rollback em `supabase/rollbacks`)
- `commercial_config.default_commission_bps` (50%). `user_activity` + `touch_activity(platform)`.
- Leitura: `admin_dashboard(from,to)`, `admin_list_users(...)`, `admin_get_user`, `admin_list_partners`, `admin_get_partner`, `admin_list_change_requests`, `admin_pending_change_count`, `admin_list_subscriptions`, `admin_get_config`, `admin_list_audit`, `admin_audit_actions`, `admin_audit_neighbors`, `admin_assert`.
- Escrita: `admin_grant_premium` (dias/data/sem fim; cortesia, sem comissão), `admin_revoke_entitlement` (**agora só cortesia**, P0032 para o resto), `admin_promote_partner` (reativa a mesma parceria se já existiu), `admin_update_partner` (validações + código único P0052), `admin_set_student_partner` (vincula/troca/remove, auditoria, bloqueio por aluno, encerra pendência obsoleta), `admin_review_partner_change` (agora devolve jsonb; idempotente se já processada; "obsoleta" se o vínculo mudou; bloqueia professor inativo), `admin_update_commercial_config` (+ validação de versões, + comissão padrão).
- Auxiliares internos sem acesso de cliente: `_scrub` (remove `pix_key`, `raw`, tokens do que o portal mostra da auditoria), `_page`, `_like_escape`, `_user_last_study`, `service_find_user_by_email` (só service_role).
- Correção: `_link_once`/`get_my_partner` — depois que o admin **remove** o vínculo, o aluno pode escolher de novo (antes ficava sem caminho).
- Todas as `admin_*` já passam no gate (`/rpc/admin_%`).

### 15.4 Provisionamento de professor (Edge Function `admin-provision-partner`)
Valida o chamador com `admin_assert()` usando o JWT dele; só então usa `service_role` (existe apenas no ambiente da função, nunca no bundle). E-mail já existente → reutiliza a conta (senha intocada). Conta nova → senha aleatória descartada + e-mail de recuperação para o professor definir a própria senha; nada de senha em tabela. A parceria é criada por `admin_promote_partner` **com o JWT do admin** (auditoria correta); falha → remove a conta recém-criada. **Pendente: deploy** (ver 15.8). Promover usuário existente também funciona pela RPC direta.

### 15.5 Semântica da atividade
- **Último login** = `auth.users.last_sign_in_at` (GoTrue). **Atividade no app** = `user_activity.last_seen_at` (abertura/retorno do app autenticado; ≤1 escrita/10 min no cliente e no servidor; só plataforma, sem geolocalização). **Último estudo** = maior entre resposta, simulado, redação e Aura. Usuários antigos só têm "atividade no app" após abrirem a versão nova.
- Encerrar parceria: sai da lista, perde Premium de professor, sem novas comissões; mantém conta, histórico, ledger e repasses; vínculos dos alunos permanecem como história.

### 15.6 Segurança
Sem chave privilegiada no Flutter; todas as operações por RPC `security definer` + `require_admin()`; paginação limitada no servidor; filtros validados (P0060); auditoria imutável sem segredos; revogação restrita a cortesia (admin não "vira" a Apple/Google/Mercado Pago); ativação do modelo comercial **não existe na UI** (somente leitura + bloqueio emergencial com confirmação).

### 15.7 Limitações assumidas
- `compute_access` é chamado por usuário (dashboard e filtro de acesso): ótimo para milhares, a reavaliar com dezenas de milhares (materializar).
- (Resolvido na Etapa 05: o cadastro consome `?ref=`; professor tem painel.)
- Financeiro detalhado, fechamento e repasses pela UI: Etapa 06.
- Código Flutter novo escrito **sem `flutter analyze` e sem testes** (diretriz); revisar no QA final. Teste de `authRedirect` existente segue válido (parâmetros novos são opcionais).

### 15.8 Pendências externas
1. Deploy da Edge Function (`supabase functions deploy admin-provision-partner`, requer PAT do dono para o projeto `cesuqfgrtcitatxvokez`).
2. Aplicar templates/SMTP de e-mail (§13.6) para o e-mail de definição de senha do professor chegar com o layout trilíngue.
3. Publicar a web (sem deploy nesta etapa) — `/partners` só existe após o próximo deploy.

## 16. Etapa 05 — Portal dos professores (2026-11-27)

### 16.1 Arquitetura
Mesmo endereço (`/partners`), mesma shell, auth, tema e i18n da Etapa 04. `/partners` é role-aware (`PortalHome`): admin vê o painel admin; professor ativo, a visão geral. Menu: Visão geral · Meus alunos · Estatísticas · Financeiro · Minhas indicações · Minha parceria (`partner_pages.dart`). Componentes compartilhados novos: `PeriodState` (seletor de período único, agora usado também pelo painel admin) e `ReferralCard`. Tudo somente leitura.

### 16.2 RPCs (migration `20261127000100_partner_portal.sql`, aplicada; rollback em `supabase/rollbacks`)
`partner_portal_me`, `partner_dashboard`, `partner_usage`, `partner_list_students`, `partner_student_detail`, `partner_finance`, `resolve_referral_code` (anon). O professor vem **sempre de `auth.uid()`** (`_my_partner_id`/`_active_partner_id`); nenhum RPC aceita `partner_id`. `app_pre_request` libera `/rpc/partner_%` e `/rpc/resolve_referral_code` (funciona sem Premium e com e-mail pendente).

### 16.3 Isolamento e privacidade
- Lista/detalhe só de alunos vinculados **a este professor** (outro aluno → 42501). Sem e-mail, senha, Pix ou pagamentos de alunos; texto de redação e respostas individuais nunca saem.
- **Dois consentimentos independentes**: vínculo comercial (indicação) mostra situação comercial; estudo individual exige o **último** registro de `study_sharing_consents` = concedido (revogar bloqueia na hora; vínculo e comissões ficam). Menor sem autorização do responsável já vale como não concedido.
- Agregados de estudo (`partner_usage`, cards de estudo da Visão geral) só com **≥ 5 alunos que compartilham**; abaixo disso, mensagem de coorte mínima (sem números).
- Professor encerrado/suspenso: só `partner_finance` e `partner_portal_me`; sem dados de ex-alunos.

### 16.4 Definições de métrica
- **Alunos indicados** = vínculos atuais. **Novos no período** = `linked_at` no período. **Assinante ativo** = entitlement apple/google/web vigente (mensal/anual pelo plano). **Experiência gratuita** = trial vigente; **encerrada** = trial expirado/revogado. **Assinatura expirada** = teve assinatura e não tem vigente. **Cortesia** = Premium cortesia vigente.
- **Conversão** = alunos que já assinaram ÷ alunos indicados (denominador explícito no card).
- **Ativo no período** = respondeu questão, fez simulado, enviou redação ou ganhou Aura. **Atividade recente** = estudo/uso do app nos últimos 14 dias (só para quem compartilha).
- `user_question_progress` guarda a última resposta por questão (não o histórico): totais são consolidados; "no período" usa a data da última resposta. Sem rankings nem estimativas apresentadas como exatas.
- Premium de professor/cortesia **nunca** gera comissão; comissão só vem de pagamento confirmado (`commission_ledger`).

### 16.5 Link de indicação
`https://aprovaura.lucksrei.com/?ref=CODE`. Na web, sem sessão, `main.dart` guarda o código (SharedPreferences `pending_referral_code`, só `[A-Za-z0-9]{4,12}`); `RegisterPage` valida via `resolve_referral_code` (professor ativo) e **pré-seleciona** no dropdown — o aluno pode trocar/remover. Inválido/inativo é descartado em silêncio. O código é limpo ao enviar o cadastro; a indicação segue no próprio cadastro (persiste pela confirmação de e-mail). Usuário já logado nunca é alterado por link; vínculo existente nunca é substituído (regras de `link_partner`). Copiar código, copiar link e compartilhar (`share_plus`, com cópia como alternativa). Sem serviço de deep link nem atribuição pós-instalação.

### 16.6 Financeiro do professor
Saldo, comissões confirmadas, estornos/ajustes, total recebido, último/próximo repasse (1º do mês, manual), histórico por competência, repasses (pago/pendente) e movimentações paginadas. Extensível: a Etapa 06 só adiciona fechamento/repasse pela UI do admin.

### 16.7 Pendências externas e limitações
PAT do dono para deploy de `admin-provision-partner`; templates/SMTP Resend (§13.6); deploy da web. Mobile (Android/iOS) não expõe o portal. `pubspec.lock` foi regenerado pelo SDK local (pacotes de dev recuados) + `share_plus` novo. Código Flutter sem `flutter analyze`/testes (diretriz): revisar no QA final.

### 16.8 Checklist de QA futuro
Link `?ref=` válido/inválido/inativo; login prévio + link; troca no dropdown; professor com <5 e ≥5 consentimentos; revogar consentimento; aluno de outro professor (42501); professor encerrado (só Financeiro/Parceria); PT/EN/ES, claro/escuro, mobile; F5 em `/partners/...`.

## 17. Etapa 06 — Financeiro, comissões e repasses (2026-11-28)

### 17.1 Arquitetura (sem segundo sistema)
Mesma base de `20261124000400_finance.sql`: `payments` (snapshot imutável), `commission_ledger` (append-only), `payouts`. Nova migration `20261128000100_finance_admin.sql` (aplicada; rollback em `supabase/rollbacks`). Dinheiro **sempre em centavos `bigint`** (comissão = `floor(líquido × bps / 10000)`; nenhum float). Todos os números das telas vêm de RPCs; o Flutter só formata. Tabelas novas (travadas para o cliente): `payment_refunds`, `payment_adjustments`, `partner_commission_history`, `expense_categories`, `expenses`, `expense_history`; view interna `payments_eff` (valores efetivos = base + ajustes − reembolsos).

### 17.2 Estados do pagamento
`status`: confirmed → partially_refunded → refunded | charged_back. `reconciliation_status`: **pending** (taxa/imposto ESTIMADOS) → **reconciled** (oficiais do provedor, uma única vez). `settlement_status`: pending → settled (`settled_cents`/`settled_at` informados pelo provedor). Receita gerada ≠ pagamento confirmado ≠ liquidado ≠ comissão conquistada ≠ disponível ≠ repassado ≠ lucro: cada um tem campo/indicador próprio.

### 17.3 Regras de comissão (corrigidas)
- Professor, vínculo e **percentual são reconstruídos pelo histórico no instante do pagamento** (`partner_link_history`, `partner_commission_history` por trigger em `partners`; funções `_student_partner_at`, `_partner_bps_at`). Eventos atrasados/fora de ordem, renovações e mudança de percentual (50%→40% só vale para pagamentos novos) usam o estado da data do pagamento, nunca o estado atual. *Bug anterior corrigido:* o percentual e o professor atuais eram usados em pagamentos antigos.
- Pagamento com taxa/imposto **estimado** grava a comissão provisória no pagamento mas **não lança no razão** (não é liberável); a conciliação lança a comissão definitiva e os reembolsos que chegaram antes. Comissão = 0 para trial/cortesia/professor/admin (só pagamentos reais entram em `payments`). Anual = comissão sobre o pagamento anual.
- Ajuste posterior de taxa/imposto (`record_payment_adjustment`) gera lançamento `fee_adjustment` (± diferença da comissão), idempotente por `external_ref`.

### 17.4 Reembolsos
`record_payment_refund` aceita total, parcial, vários e chargeback, com taxa/imposto devolvidos opcionais. Comissão revertida = alvo cumulativo (`floor(comissão × reembolsado / bruto)`, integral no último) − já revertido: sem deriva de arredondamento e sem desconto duplo (idempotente por `external_ref`; sem ref só o saldo restante integral). Antes ou depois do repasse: lançamento negativo no razão (saldo pode ficar negativo e compensa as próximas comissões). Evento antes do pagamento ⇒ `P0040` (a integração reenfileira). Cancelamento de renovação ≠ reembolso: não gera ajuste; o Premium de outras fontes nunca é tocado aqui.

### 17.5 Fechamento e repasse
Competência = mês em America/Sao_Paulo. `admin_partner_closing(competência)` por professor: acumulado anterior, comissão do mês, ajustes, já repassado, **disponível = soma do razão até a competência**, situação (pago/parcial/pendente/negativo), Pix mascarado, pendente de conciliação. Nada é apagado ao virar o mês. **Registrar repasse** (`admin_register_payout`): valor padrão = disponível, parcial permitido, data do Pix, referência, observação, **chave de idempotência** (clique duplo não duplica), lock por professor, validação contra o disponível (P0041), auditoria e admin responsável. Efeito: lançamento negativo `payout` (nunca "update para zero"); comissões novas continuam somando. **Reverter** (`admin_reverse_payout`): motivo obrigatório (≥5), lançamento compensatório `payout_reversal`, original preservado, admin registrado — **não desfaz o Pix externo**. Chave Pix completa só por ação explícita e auditada (`admin_get_partner_pix`).

### 17.6 Resultado (fórmulas)
`líquida = bruto − reembolsos − taxas − impostos` · `receita Lucksrei = líquida − (comissões geradas − estornadas)` · `resultado = receita Lucksrei − despesas`. Por competência (data do pagamento/evento); a data do repasse não deduz de novo. **Fluxo de caixa informado** = recebido dos provedores − repasses pagos − despesas (separado do resultado). Impostos/taxas só aparecem se registrados; nada é estimado por padrão e há aviso quando o período tem taxas estimadas. Despesas não alteram comissões.

### 17.7 Despesas
Categorias iniciais (Supabase, Cloudflare, IA, Apple Developer, Google Play, e-mail, Marketing, Outros) + novas pelo admin. Criar/editar/excluir (anular) com `expense_history` imutável e auditoria. Sem ERP, notas fiscais ou conciliação bancária.

### 17.8 RPCs
Admin: `admin_finance_dashboard`, `admin_list_payments`, `admin_get_payment`, `admin_partner_closing`, `admin_partner_commissions`, `admin_list_payouts`, `admin_register_payout`, `admin_reverse_payout`, `admin_get_partner_pix`, `admin_create_expense`, `admin_update_expense`, `admin_void_expense`, `admin_add_expense_category`, `admin_list_expenses`, `admin_finance_export`. Professor: `partner_finance` (mesma fonte), `partner_finance_export`. Exportações CSV (pagamentos, comissões, repasses, despesas, resumo): texto livre com proteção contra injeção de fórmula (`_csv`), valores decimais exatos, sem Pix/segredos, limite de 20 000 linhas, respeitam os filtros.

### 17.9 Contratos para a Etapa 07 (somente service_role)
`record_confirmed_payment(provider, external_id, user, plan, gross, fee, tax, paid_at, raw, fee_source, tax_source)` · `record_payment_reconciliation(provider, external_id, fee, tax, settled_cents, settled_at)` · `record_payment_settlement(...)` · `record_payment_adjustment(provider, external_id, kind, delta, external_ref, note)` · `record_payment_refund(provider, external_id, at, charged_back, refund_cents, fee_refund, tax_refund, external_ref)`. Todos idempotentes (lock por pagamento). Se o provedor só entrega relatório posterior: registrar com `fee_source='estimated'` e conciliar quando o oficial chegar (o oficial prevalece). Admin não cria/edita pagamento de provedor pela UI.

### 17.10 Segurança
RLS ligada e `revoke` em todas as tabelas novas; RPCs `security definer` com `search_path` fixo, `require_admin()` ou identificação do professor por `auth.uid()`; paginação no servidor; professor só vê o próprio razão (nunca despesas/lucro/outros); parceria encerrada mantém o Financeiro. Triggers: pagamentos só mudam taxas na 1ª conciliação; razão e histórico imutáveis.

### 17.11 Limitações e pendências
- **Comprovantes (anexo) não implementados** (exigiria seletor de arquivos + bucket privado + políticas); o campo `reference` do Pix cobre o rastreio.
- Ajuste de taxa não recalcula reembolsos já lançados (a diferença cai no próximo lançamento).
- Estorno usa a competência da data do estorno.
- Pendências externas: integrações reais (Etapa 07), PAT para a Edge Function de provisionamento, templates Resend, deploy da web. Código Flutter novo sem `flutter analyze`/testes (diretriz).

### 17.12 Checklist de QA futuro
Pagamento com professor → comissão; mudar % → pagamento antigo reprocessado mantém %; taxa estimada → conciliar; reembolso parcial/total/duplicado; repasse total/parcial/clique duplo/acima do saldo/reverter; novo saldo após repasse; exportações CSV com `=cmd()`; professor encerrado só Financeiro; isolamento entre professores; PT/EN/ES, claro/escuro, mobile.

## 18. Etapa 07 — Assinaturas Apple, Google Play e Mercado Pago (2026-11-29)

> **Estado:** código e backend prontos; **nenhuma integração está operacional** e **nada é cobrado**. Todo provedor/ambiente nasce com `enabled = false` em `payment_providers_config`; `enforcement_enabled`, confirmação obrigatória de e-mail e AUTO_DEPLOY seguem desligados. Código escrito ≠ integração validada.

### 18.1 Arquitetura
`lib/features/payments/` (domain → data → cubit): `PaymentsRepository` (catálogo/preços reais via `in_app_purchase`, compra, restauração, Mercado Pago), `PaymentsCubit` (loading/purchasing/pending/validating/success/cancelled/conflict/failed) ligado ao `AccessCubit` (relê o acesso sem logout). **O "sucesso" do cliente nunca é prova**: o app só entrega o comprovante à Edge Function, que valida e grava; a transação só é encerrada na loja (`completePurchase`) depois da validação. UI definitiva (paywall, gestão) = Etapa 08; já existe o componente `PixPaymentPanel` (QR, copia-e-cola, contagem regressiva, atualização proporcional 5→30 s, "Verificar pagamento", expirado → novo Pix). StoreKit 2 é o padrão do pacote `in_app_purchase_storekit`.

### 18.2 Catálogo e ids
`payment_catalog` (plano × provedor × ambiente): `aprovaura_premium_monthly`/`_annual` (Apple, um grupo de assinatura), `aprovaura_premium` com base plans `monthly`/`annual` (Google), planos internos no Mercado Pago. Preço R$ 19,90 / R$ 190,00 é **referência**; o app mostra o preço **da loja**. `verified=false` até conferir no console. Bundle/package: `com.lucasdiogof.aprovaura`.

### 18.3 Associação conta ↔ compra
`get_purchase_account_token()` devolve um UUID opaco por usuário (exige e-mail confirmado quando a regra estiver ativa): Apple `appAccountToken`, Google `obfuscatedAccountId`, Mercado Pago `external_reference`. `provider_subscriptions` fixa `(provider, env, original_ref) → user`; outro token tentando a mesma assinatura vira `payment_conflicts` + evento `conflict` (sem transferência automática; transferência exige ação de admin auditada). `service_upsert_entitlement` já recusava mover `(source, external_ref)` entre usuários.

### 18.4 Entrada única de eventos
`payments_ingest_event` (service_role): lock por assinatura, idempotência por `(provider, env, event_id)`, tentativas/erro em `payment_events` (sem payload bruto), **barra evento antigo** (`last_event_at`), converte em entitlement (só a fonte do próprio provedor; revogar uma não revoga as outras) e, **só em produção**, chama `record_confirmed_payment`/`record_payment_refund`/`record_payment_settlement` (Etapa 06). **Sandbox nunca gera receita nem comissão** (o entitlement leva ref `sandbox:` e permite revisão da loja/testers). Taxa/imposto não informados → `estimated` (comissão fica pendente até conciliar). Cada pagamento tem id próprio (Apple `transactionId`, Google `latestSuccessfulOrderId`, MP `payment.id`): renovações não duplicam comissão. Cancelar renovação ≠ reembolso: acesso até o fim do período.

### 18.5 Apple (`payments-apple`)
Notificações V2 (`signedPayload`) e verificação do app (`signedTransaction`, JWT do usuário). **JWS verificado de verdade**: `alg=ES256`, `x5c` de 3 certificados, raiz **fixada** em `APPLE_ROOT_CA_PEM`, assinatura de cada elo, validade, OIDs Apple e assinatura do JWS. Confere `bundleId`, produto do catálogo, ambiente (Sandbox ≠ Production) e `appAccountToken`. Mapeia SUBSCRIBED/DID_RENEW (ativo + pagamento; `price` em milésimos → centavos), cancelamento de renovação (vale até o fim), DID_FAIL_TO_RENEW (carência/retentativa), EXPIRED, REFUND/REVOKE e mudança de plano. Consulta oficial na reconciliação: App Store Server API (JWT ES256 com chave `.p8`).

### 18.6 Google Play (`payments-google`)
RTDN por Pub/Sub push autenticado por **OIDC** (audience + service account verificados); a mensagem só avisa — o estado é relido em `subscriptionsv2`. Valida `packageName`, produto + base plan e conta ofuscada. **Acknowledge só após validar e gravar** e só se pendente. `linkedPurchaseToken` encerra o token antigo. `voidedPurchaseNotification` → reembolso/chargeback. Estados: ACTIVE, CANCELED, IN_GRACE_PERIOD, ON_HOLD/PAUSED (sem acesso), EXPIRED, PENDING; `testPurchase` → sandbox. **Limite:** a API v2 não devolve o preço pago → bruto = preço de referência, marcado estimado até conciliar com o relatório financeiro da Play.

### 18.7 Mercado Pago (`mp-checkout`, `mp-webhook`) — somente Web/Portal
Nunca dentro dos apps móveis (regra das lojas). Cartão: assinatura recorrente (`preapproval`, checkout hospedado — sem PAN/CVV). **Pix: não há Pix recorrente automático** nesta integração → Pix **avulso** por 30/365 dias, renovação manual, rotulado assim; períodos empilham após o vigente. O servidor cria a cobrança com valor do catálogo (o cliente não envia valor), reaproveita a tentativa pendente, substitui a antiga ao trocar plano/método e recusa se já houver assinatura vigente em outro provedor (409; nunca cancela sozinho). Webhook: **HMAC oficial** (`x-signature`), relê o recurso na API e valida conta recebedora (`MP_COLLECTOR_ID`; sem ele, falha fechada), valor × plano, moeda BRL, `external_reference` e `live_mode` (→ ambiente). Taxa vem de `fee_details`; imposto estimado. Assinatura autorizada sem cobrança aprovada **não** concede acesso.

### 18.8 Reconciliação periódica (`payments-reconcile`)
Protegida por `CRON_SECRET`. Lote ≤ 50 de `service_subscriptions_to_check` (vencendo em 2 dias/pendentes, mín. 12 h entre checagens): relê o provedor e reaplica pelo mesmo caminho (idempotente). Não roda a cada abertura do app. **O agendamento externo não foi criado** (ver 18.12). Reprocesso admin (`admin_requeue_event`) só recoloca evento **falho** na fila; não cria pagamentos.

### 18.9 Portal admin
`/partners/integrations`: provedores × ambientes (liberado/desligado), produtos e "conferido na loja", último evento/falhas, pagamentos a conciliar, conflitos e histórico com reprocesso seguro. Sem segredos e sem botão de cobrança real. RPCs: `admin_payments_status`, `admin_list_payment_events`, `admin_requeue_event`, `admin_reconcile_payment_tax`.

### 18.10 Segurança
RLS + `revoke` nas tabelas novas; RPCs `security definer` com `search_path` fixo; service-only: `payments_ingest_event`, `service_*`; o cliente só chama `get_purchase_*`/`get_my_subscription`. Nenhuma chave Apple/Google/MP nem `service_role` no Flutter. Logs só com tipo/código (sem token, e-mail ou payload). Rotas de compra liberadas no gate sem exigir Premium; o token exige e-mail confirmado. Migration: `20261129000100_payment_integrations.sql` (rollback em `supabase/rollbacks/`).

### 18.11 Variáveis de ambiente (Supabase Secrets — nunca no repositório)
Apple: `APPLE_BUNDLE_ID`, `APPLE_ROOT_CA_PEM` (Apple Root CA G3), `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`. Google: `GOOGLE_PACKAGE_NAME`, `GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL`. Mercado Pago: `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, `MP_COLLECTOR_ID`, `MP_ENV`, `MP_NOTIFICATION_URL`, `PORTAL_BACK_URL`. Reconciliação: `CRON_SECRET`.

### 18.12 Ações do dono (procedimento e motivo)
1. **PAT do projeto `cesuqfgrtcitatxvokez`** e rodar `supabase/deploy_payments_functions.ps1` (publica as 5 funções; sem PAT não há como publicar).
2. **Apple**: contrato Paid Apps + dados bancários/fiscais; criar o **grupo de assinatura** com `aprovaura_premium_monthly`/`_annual` (BRL, Brasil), localizações e análise; Small Business Program; chave **In-App Purchase** (.p8, Key ID, Issuer ID); URL de Notificações V2 (produção e sandbox) → `…/functions/v1/payments-apple`; a primeira assinatura deve ir **junto com a versão do app**; conta e instruções de revisão.
3. **Google**: perfil de pagamentos; assinatura `aprovaura_premium` com base plans `monthly`/`annual`; service account com permissão de pedidos/assinaturas + API Android Publisher; tópico Pub/Sub + assinatura push com OIDC → `…/payments-google` e RTDN no Play Console; testers de licença; versão atual da Play Billing Library.
4. **Mercado Pago**: **confirmar a titularidade** das credenciais hoje `unassigned` (não foram usadas); criar aplicação, credenciais teste/produção, segredo e URL do webhook → `…/mp-webhook`; confirmar assinatura recorrente e Pix na conta.
5. **Cron** (pg_cron/GitHub Actions/Cloudflare) chamando `payments-reconcile` com `x-cron-secret` a cada 6–12 h.
6. Conferir os produtos no console → `update payment_catalog set verified=true …`; só então liberar `update payment_providers_config set enabled=true where provider=… and environment=…`.

### 18.13 Pendências e limites conhecidos
Sem validação sandbox/produção (sem credenciais). Imposto sobre venda não vem dos provedores (estimado; `admin_reconcile_payment_tax`). **Importação de relatórios oficiais (Apple/Google/MP) não implementada**: conciliar por pagamento; relatório agregado não deve ser casado "por palpite". Preço Apple/Google (regional/imposto) = estimativa até o relatório. Confirmar os ids no console (Google usa `aprovaura_premium` + base plan). Mercado Pago: tolerância de timestamp da assinatura não aplicada (replay barrado por idempotência). Gestão/paywall: Etapa 08. Sem `flutter analyze`/testes/builds por diretriz.

### 18.14 QA e publicação (futuro)
Sandbox Apple/Google: compra, renovação, cancelamento, expiração, carência, reembolso, restauração, reinstalação, troca de aparelho, conflito de conta. MP teste: Pix aprovado/expirado/estornado, cartão aprovado/recusado/cancelado, webhook duplicado/fora de ordem. Verificar: entitlement por fonte, uma comissão por pagamento, sandbox sem comissão, `enabled` por ambiente. Publicação: produtos aprovados, conta de revisão, termos/privacidade/exclusão de conta, preço localizado e renovação automática claros, Mercado Pago ausente do app móvel.

## 19. Etapa 08 — Paywall obrigatório e integração final (2026-11-30)

> **Estado:** tudo em código e **inerte**: `enforcement_enabled`, confirmação obrigatória de e-mail, provedores de pagamento e `AUTO_DEPLOY` seguem desligados; nenhuma cobrança; nada publicado. Sem `flutter analyze`, testes, builds ou deploy (diretriz) — o código novo precisa de QA na Etapa 10.

### 19.1 Decisão única de acesso (`AccessCubit.gate`)
`AccessGate`: `resolving` (sessão aberta, servidor ainda não respondeu) → `/verificando`; `open`; `paywall` → `/assinatura`; `connectionRequired` → `/conectar`; `updateRequired` → `/atualizar`. Ordem: versão → conexão → paywall. O roteador (`gateRedirect`, função pura em `app_router.dart`, coberta por `test/core/router/gate_redirect_test.dart` — **escrito, não executado**) é o único lugar que redireciona; telas não conferem assinatura. `refreshListenable` reavalia quando o portão muda (acesso vence, 402, pagamento confirmado, reconexão, retorno do segundo plano) e, ao entrar em bloqueio, **fecha tudo empilhado por cima** (`popUntil` de rotas não-Page): botão voltar, gestos, navegador, deep link e rota direta não reabrem estudo. `PaywallFrame` usa `PopScope(canPop: false)`. Estado de navegação não é persistido. `/verificando?to=` guarda o destino original (só caminhos internos; `//host` é descartado) → sem loop nem piscada na resolução inicial. O portal (`/partners*`) tem gate próprio por papel e **nunca** é barrado pelo paywall (professor encerrado continua no financeiro; usuário comum cai em "Acesso restrito").
- Erro que não é de conexão (ex.: 5xx) mantém o último estado: o app não inventa bloqueio por falha técnica (a decisão real é do servidor/gate). Erro de rede nunca vira "sem assinatura": offline sem autorização válida → `/conectar` ("conecte-se para verificar"; **não** diz que a assinatura venceu).
- `PT402` → `onPremiumRequired` → refresh forçado → paywall. `PT403 email_unverified` → sai e retoma pelo código (fluxo da Etapa 02), distinto de falta de assinatura.
- O acesso (ou a autorização offline) que vence **durante a sessão** é detectado por `Timer` (≤12 h, mínimo 5 s) e reavaliado sozinho.

### 19.2 Paywall (`lib/features/paywall/`)
`/assinatura` (tela própria, sem bottom sheet): logo, Aurudo (pose por estado), `AuraParticles` ambiente (única animação contínua; some com redução de movimento), `AuraGlyph` nos benefícios, `AppButton`, cartões do design system, PT/EN/ES (via `PortalStrings`), claro/escuro, coluna ≤520 px. Plano anual destacado ("Melhor valor · economize X%", calculado dos preços **reais**, nunca fixo); mensal sempre visível. Preço: Apple/Google = preço da loja (`ProductDetails`); Mercado Pago = valor do catálogo do servidor (o mesmo que o servidor cobra). **Sem preço fixo de reserva:** loja indisponível ⇒ estado "indisponível" com "Tentar de novo", sem simular compra. Sem contagem regressiva, oferta falsa ou promessa de aprovação.

**Estados** (mesma tela, textos por motivo): teste expirado ("seus 3 dias gratuitos terminaram"), assinatura expirada, usuário existente (novo modelo, histórico preservado, **sem trial**), sem assinatura, pagamento pendente (sem novo botão de compra; "Atualizar status"), compra em validação (barra de progresso; **não** conclui antes do servidor), pagamento recusado (tentar de novo/outro método), provedor indisponível, conflito de titularidade, compra cancelada, sem conexão, restauração sem compras. O motivo vem de `get_my_access_context()` (só texto). Rodapé sempre disponível, mesmo bloqueado: Minha assinatura, restaurar compras (nativo), privacidade, termos (só se publicados), sair/trocar de conta, **excluir conta**.

**Desbloqueio:** só quando o servidor confirmou e o `AccessCubit` reabriu o acesso (ou `PayPhase.success` após validação): tela "Premium ativado!" com Aurudo comemorando, sem logout/reinstalação, conta e dados intactos; eventos atrasados chegam pelo mesmo caminho (retorno do segundo plano, reconexão, polling do Pix, "verificar"). **Visita voluntária** (acesso liberado, ex.: trial): botão fechar; `/assinatura` fica permitido com o portão aberto.

### 19.3 Pagamentos por plataforma (camada da Etapa 07)
Android = Google Play Billing; iOS = StoreKit; **Mercado Pago só na Web** (nunca no app móvel). Web: escolha **Cartão recorrente** (checkout oficial hospedado, renova até cancelar na conta) ou **Pix avulso** (30/365 dias, sem renovação, períodos se somam), com a diferença explicada; reaproveita `PixPaymentPanel` (QR, copia-e-cola, valor, validade, status, verificação, retomada de cobrança pendente, expirado → novo Pix). Retorno do checkout/navegador **nunca** libera Premium: "Já concluí — verificar" só consulta o servidor. Assinatura vigente em outro provedor: card "Premium ativo" + provedor + instruções de gerenciamento compatíveis com a plataforma (links só para a **própria** loja; assinatura da Web vista no app móvel é só texto, sem link a checkout externo); nada é cancelado automaticamente e não se oferece segunda assinatura.
Correções na camada: "Restaurar compras" sem nada a restaurar deixava o cubit em "validando" para sempre (agora encerra em 10 s com aviso); recusa do Mercado Pago agora vira estado "recusado"; `emit` após `close` no `PaymentsCubit`.

### 19.4 Teste de 72 h e "Minha assinatura"
`TrialBanner` na **Home** (somente com o modelo ligado **e** acesso vindo só do teste): "Experiência Premium · restam X", data/hora de término (a do servidor; nada reinicia ou prorroga localmente), "Ver planos" (assinar antes do fim). Não cita cartão. Ao acabar, o paywall aparece sozinho. **Perfil › Minha assinatura** (`/minha-assinatura`, também acessível bloqueado; a linha só aparece com o modelo ligado): status geral, origem(ns) (admin = benefício administrativo; professor = vinculado à parceria ativa; cortesia = validade; trial = tempo restante; transição), assinaturas comerciais (plano, provedor, início, próxima renovação/acesso até, automática × manual, sandbox), gerenciar/cancelar renovação (**só** cartão Mercado Pago na Web), restaurar compras e **histórico de pagamentos** (`get_my_payment_history`, valores brutos pagos; sandbox nunca entra). Cortesia/papel administrativo **nunca** aparecem como assinatura cancelável. Múltiplas fontes: todas listadas, com aviso de que não se cancelam entre si.

### 19.5 Offline
Mantido o desenho da Etapa 01 (RS256, vínculo `sub`, relógio só avança, armazenamento local por conta). Novo: `authorizationExpiresAt` (exp do JWS) arma o `Timer` de expiração; autorização vencida offline → `/conectar` (diferencia "preciso verificar" de "venceu"); reconectar → refresh forçado → `open` → autorização renovada. **Fila de sincronização:** ação feita enquanto autorizado e adiada por `PT402` fica **intacta** (não conta tentativa, não é descartada) e agora é enviada no instante em que o acesso reabre (`wireAccessSupport` observa a transição para `open`). Sem acesso o app está bloqueado (`/conectar` ou paywall), logo não há como registrar atividade nova depois do vencimento: não existe "atividade ilimitada pós-expiração". Limite assumido: aparelho adulterado/relógio — mitigado pelo "último instante visto", não eliminado; o servidor continua barrando tudo online.

### 19.6 Atualização obrigatória
`/atualizar` quando `enforced` e `AppInfo.version < min_version_{plataforma}`: botão para a loja (iOS `apps.apple.com/br/app/aprovaura/id6817047910`; Android `play.google.com/store/apps/details?id=com.lucasdiogof.aprovaura`) ou, na Web, recarregar com `?v=<timestamp>` (ignora assets antigos). **Não é segurança:** versões já publicadas não têm esta tela; a proteção real é o gate do servidor (nada confia na versão enviada). A versão mínima de produção **não** foi alterada.

### 19.7 Exclusão de conta × monetização (migration `20261130000100_paywall_account_deletion.sql`, aplicada; rollback em `supabase/rollbacks`)
Auditoria de FKs a partir de `auth.users`: `partners.user_id` e `app_admins.user_id` eram `ON DELETE RESTRICT`, então **excluir conta de professor ou admin falhava** (corrigido). Agora: professor → FK `SET NULL` + gatilho que **encerra e anonimiza** a parceria ("Professor removido", Pix apagado), preservando pagamentos/razão/repasses (que referenciam `partners`); admin → `CASCADE` + gatilho que **impede remover o último administrador ativo** (a exclusão inteira falha, nada é apagado, `P0014`); gatilho minimiza `payments.raw` (payload do provedor) ao excluir a conta — valores, datas e comissões ficam (obrigação contábil; `payments.user_id` não tem FK e vira referência opaca). Sem Premium continua possível excluir; assinatura ativa **não** impede. O diálogo agora avisa (PT/EN/ES) que **excluir a conta não cancela** assinaturas Apple/Google/Mercado Pago e manda cancelar na loja antes. A Edge Function `delete-account` não mudou (sem redeploy: a lógica está no banco).

### 19.8 Segurança do conteúdo (revisão)
- **Gate** (`app_pre_request`, refeito na migration): com o modelo ligado, **anon e usuário sem Premium recebem 402 em tudo que não está na lista**, inclusive leitura direta de `questions`, `catalog_nodes`, `*_translations`, `dossiers*`, `essay_themes*`, RPCs e Edge Functions que chamam RPCs com o JWT do usuário. Lista liberada (conta bloqueada precisa): perfil, `get_my_access`, `get_my_access_context`, `get_my_payment_history`, `get_my_subscription`, `get_purchase_config`, indicação/termos, `admin_*`, `partner_*`. Hoje inerte (`commercial_enforced() = false`).
- **Fora do PostgREST:** `/auth/v1` (não serve conteúdo); Edge Functions (`evaluate-essay` valida o JWT e usa RPCs, logo passa pelo gate; as de pagamento são públicas por desenho e validam JWS/HMAC/OIDC); mapas e GeoJSON embarcados (sem gabarito). **Storage/Realtime: não usados para conteúdo — NÃO CONFIRMADO no painel** (verificar no QA).
- **Extração:** quem tem acesso legítimo baixa o banco de questões por desenho (necessário ao offline); não há proteção absoluta. Melhoria preparada, **não aplicável antes de desligar versões antigas:** corrigir no servidor (`check_answer`) e retirar `correct_index` do `select`; limites por requisição e `max-rows` no PostgREST. Simulados já são online-only sem gabarito antecipado.
- Nenhuma mudança incompatível com apps publicados (tudo aditivo e inerte).

### 19.9 Correções desta etapa
Exclusão de professor/admin por FK; último admin (via exclusão de conta); `restore` preso em "validando"; recusa do Mercado Pago sem estado; `emit` após `close`; expiração durante a sessão só notada no próximo refresh; fila adiada pelo 402 sem disparo ao reabrir o acesso; diálogo de exclusão sem aviso sobre assinaturas; falta de resolução inicial estável (agora `/verificando`).
**Revisão estrutural por leitura (sem analyze):** DI (`AccessCubit` singleton, `PaymentsCubit` factory ligado a ele), rotas novas exigem sessão, ciclo de vida (timers/subscriptions cancelados em `close`/`dispose`), contratos Flutter↔RPC (`get_my_access_context`, `get_my_payment_history`, `reference_price_cents`). Só o QA confirma: compilação/imports, `popUntil` com diálogos abertos, StoreKit/Billing reais.

### 19.10 Pendências externas e financeiras (obrigatórias antes dos primeiros repasses)
Contratos, consoles e credenciais da Etapa 07 (§18.12) continuam do dono. **Antes de qualquer repasse:** (1) conciliar com os **relatórios financeiros oficiais da Apple**; (2) idem **Google**; (3) conciliar **Mercado Pago**; (4) **confirmar as taxas efetivas** por provedor; (5) **confirmar os impostos registrados** (hoje estimados); (6) tratar **transações sem identificação individual suficiente** (relatório agregado nunca é casado "por palpite"; ficam pendentes de conciliação, sem comissão liberável). Comissões estimadas **não** estão disponíveis para repasse (só entram no razão após `reconciled`; §17.3). Importação automática de relatórios segue **não implementada**.

### 19.11 Checklist de QA (Etapa 10)
Gate (com `enforcement` ligado só em ambiente de teste): sem acesso → paywall em `/home`, voltar, F5, deep link, `/onboarding`; trial expirando durante a sessão; 402 numa tela de estudo; offline com autorização vencida (`/conectar`) e reconexão; relógio recuado; troca de conta; fila offline sob 402 e envio ao reabrir. Paywall em PT/EN/ES × claro/escuro × celular/tablet/desktop × fonte grande/redução de movimento; todos os estados (§19.2). Compras sandbox Apple/Google e Mercado Pago teste (§18.14), restauração, conflito, "Premium em outro provedor". Minha assinatura (trial, cortesia, professor, admin, múltiplas fontes). Exclusão: aluno, professor, admin, **último admin** (deve falhar), com assinatura ativa. Portal: professor encerrado só financeiro. Atualização obrigatória (versão abaixo do mínimo; web). Rodar `flutter analyze` e a suíte (inclui `gate_redirect_test`).

### 19.12 Checklist de ativação comercial
Tudo da §12/§13.9 e §18.12 concluído; versão nova (com paywall e `/confirmar-email`) **aprovada e publicada** nas lojas e na web; produtos Apple/Google/MP conferidos (`verified=true`) e provedores `enabled=true` por ambiente; `min_version_*` definido; Termos de Uso e Política atualizados; cron de reconciliação; `emergency_disable` à mão; só então `admin_set_commercial_enforcement(true)` e, por último, `AUTO_DEPLOY=true`.

## 20. Etapa 09 — Termos, privacidade e preparação comercial (2026-11-24)
Nada foi ativado: `enforcement_enabled`, confirmação de e-mail obrigatória, provedores comerciais e `AUTO_DEPLOY` seguem **desligados**; nenhuma publicação nas lojas ou na web.

### 20.1 Entregue
- **Migrations aplicadas** (aditivas, com rollback em `supabase/rollbacks/`): `20261201000100_legal_versions_age_sharing` (documentos legais com vigência/idiomas/re-aceite, `publish_legal_version`, histórico de aceites, faixa etária declarada, compartilhamento seguro por padrão, gate liberando consulta/aceite sem Premium) e `20261201000200_financial_report_import` (conciliação por relatórios oficiais).
- **Flutter**: tela `/privacidade` (Perfil → Privacidade e termos: documentos, histórico de aceites, faixa etária, compartilhamento revogável); aba **Conciliação** no financeiro do portal admin; endurecimento do acesso offline contra 5xx.
- **Documentos**: `docs/legal/` (minutas de Termos e Política, PT/EN/ES), `docs/site-lucksrei/` (rascunhos do site e da página de parceiros; nada publicado), `docs/store-listings/` (Apple/Google PT/EN/ES + revisores/checklists), `docs/release/` (fatos, pendências externas, plano de ativação, assinaturas, matriz de dados, revisão técnica), `docs/partners/`, `docs/finance/RECONCILIATION.md`.

### 20.2 Menores (decisão e bloqueadores)
Seguro por padrão: só quem declarou **adulto** no servidor compartilha estatísticas com professor; menor/desconhecido nunca; sem data de nascimento, perfilamento ou publicidade comportamental. **Bloqueadores de lançamento (decisão do dono + advogado):** idade mínima do serviço; permitir <12 e consentimento parental; vínculo com professor para menores e base legal; assinatura por menores; RIPD/encarregado; Gemini exige 18+ e a camada gratuita permite revisão humana/treino → migrar para camada paga e decidir correção por IA para menores. Detalhes e fontes em `docs/release/FATOS_ETAPA09.md`.

### 20.3 Conciliação — estado e limites
Importar só confere; aplicar é ato do admin, auditado, apenas em linhas com valor bruto idêntico; divergência/sem par nunca é aplicada; Apple (agregada) só confere totais; comissão estimada nunca vira repasse. Formatos **não validados** com amostras reais — validar na Etapa 10.

### 20.4 Pendências para a Etapa 10
QA consolidado (sem `analyze`/testes/builds até lá, por diretriz): rodar `flutter analyze` e a suíte (inclui `gate_redirect_test`); validar `/privacidade` e a aba Conciliação; re-aceite: a tela `/privacidade` já lista versões vigentes não aceitas (`get_legal_status`) com botão Aceitar; o bloqueio forçado de uso até aceitar **não foi implementado** (decidir na Etapa 10, depois de publicados os Termos); publicar Termos via `publish_legal_version` na ativação; todas as pendências externas de `docs/release/PENDENCIAS_EXTERNAS.md`; plano de 20 passos em `docs/release/PLANO_ATIVACAO_COMERCIAL.md`; confirmar `site_url` de produção, target API 36, deployment target iOS, Storage/Realtime e endurecimento de permissões (`REVISAO_TECNICA_ETAPA09.md`).

## 21. Etapa 10 — QA consolidado (2026-11-24) — EM ANDAMENTO (não concluída)
A etapa 10 do roteiro **não** está marcada como concluída: há bloqueadores de lançamento que dependem do dono (`docs/qa/PENDENCIAS_DO_DONO.md`). Veredito atual: **NO-GO** para ativação comercial.

- **Feito e verificado:** `flutter analyze` limpo; 1206 testes Flutter passando; Deno ok; SQL 68/68 (produção, transação revertida: financeiro A–D, conciliação, permissões, exclusão de conta); REST anônimo 34/34 negados; 14 migrações aplicadas do zero em Postgres descartável; builds Web, APK debug e AAB release (1.1.0+8) compilam (nada publicado).
- **Código novo:** bloqueio de reaceite legal (`AccessGate.legalRequired`, `/aceite-legal`, inerte até haver versão com `requires_reaccept`); interruptor `ESSAY_AI_PROVIDER` da correção por IA (função ainda não publicada); `PrivacyInfo.xcprivacy` com dados coletados; rollback de `20261201000100` completo.
- **Etapa 10B (24/11):** QA visual automatizado (570 capturas; Chrome/Playwright contra Supabase local com dados fictícios) achou e corrigiu 3 bugs de layout no portal (gráfico com valor negativo, `Select` e interruptor em 320 px); segurança autenticada 103/103 (isolamento entre professores e consentimento); concorrência financeira 22/22 em Postgres descartável; achado crítico corrigido (`requires_reaccept` padrão true forçaria reaceite a todos: migração `20261202000100`, aplicada) e reaceite que não pode ser burlado offline. Home sem cartão Premium (só Perfil). Combinações e limites reais em `docs/qa/RESULTADOS.md`.
- **Supabase com PAT (24/11):** PAT restrito ao projeto; Auth/Storage/Realtime/Secrets auditados (`docs/qa/SUPABASE_AUDITORIA.md`); vulnerabilidade `refresh_broken_streak` corrigida (migração `20261203000100`); checagem de tipos do Deno resolvida (`deno.json`); 7 Edge Functions publicadas, falha fechada 19/19 (`tool/qa/edge_smoke.py`); conciliação agendável sem custo (`pg_cron`), não ativada. Monetização, provedores, e-mail obrigatório e `AUTO_DEPLOY` seguem desligados.
- **Etapa 10C, serviço 4 (24/11):** decisões do dono sobre IA registradas (Gemini mantido porém com envio suspenso; sem IA paga; app não restrito a 18+; IA só para redação, 3/dia, sem chatbot). Minutas de Termos e Política (pt-BR/en/es) atualizadas como rascunho para advogado; dados do controlador preenchidos a partir do site oficial (falta só o endereço); fichas das lojas e paywall deixaram de anunciar correção por IA (suspensa); `PrivacyInfo.xcprivacy` ganhou Name/OtherDataTypes; indicação comercial × compartilhamento de estatísticas separados nos textos (professor vê nome/usuário/situação comercial do indicado; decisão sobre minimizar para menores com advogado); nada publicado em `legal_documents`, Web ou lojas.
- **Etapa 10C, serviço 5 (24/11) — Mercado Pago:** conta recebedora (LUCKSREI) e aplicação identificadas e do Lucksrei; `PORTAL_BACK_URL` corrigido para `/minha-assinatura`; `mp-checkout`, `mp-webhook` e `payments-reconcile` republicadas com 9 correções (ambientes de teste/produção separados, HMAC com manifesto oficial, taxa informada, liquidação, reembolso/chargeback de cartão, cobrança de cartão que nunca fechava, fail-closed antes de cobrar, reconciliação). Testes locais: Deno 23, SQL 83/83, widget Pix 5. **Não homologado em sandbox oficial** (faltam credenciais de teste e segredo do webhook, que só o dono obtém); nenhuma cobrança real; enforcement, monetização e agendamento seguem desligados. Detalhes e limitações: `docs/qa/MERCADOPAGO_HOMOLOGACAO.md`.
- **Não validado:** pagamentos reais (Apple/Google/Mercado Pago), e-mail, iOS, VoiceOver/TalkBack, contraste medido, emulador Android, offline real/relógio adulterado em navegador, Cloudflare Workers Builds (publicação automática fora do GitHub Actions: conferir no painel).
- Detalhes: `docs/qa/README.md` (classificação por componente), `RESULTADOS.md`, `BUGS_E_CORRECOES.md`, `SEGURANCA_E_BANCO.md`, `FINANCEIRO_HOMOLOGACAO.md`, `IA_REDACAO_E_MENORES.md`, `ATIVACAO_E_ROLLBACK.md`.


### 13.6-bis Resend/SMTP — APLICADO em produção (24/11, Etapa 10C)
- **Chave** `resend.unassigned.production.api-key`: válida, **somente envio** (`/domains` e `/api-keys` devolvem 401 `restricted_api_key`; não pede chave de acesso total). Domínio verificado para envio: **`lucksrei.com`** (teste real: 200 em `no-reply@` e `aprovaura@`; `aprovaura.lucksrei.com` → 403 não autorizado). A chave é compartilhada com a infraestrutura Lucksrei; o SMTP do Supabase a guarda no próprio Auth (nunca devolvida em texto claro).
- **SMTP** `smtp.resend.com:465`, usuário `resend`, remetente **`AprovaAura <no-reply@lucksrei.com>`**. Limite do Auth: **15 e-mails/h** (antes 2). Limites Resend (plano grátis, sem custo): 100/dia, 3000/mês, 10 req/s; cota compartilhada com a Lucksrei (uso mensal na checagem: ~20). 100/dia equivale a ~100 cadastros/dia com confirmação ligada — decisão do dono (plano pago) se passar disso.
- **Templates** (`supabase/templates/build_templates.py`, PT/EN/ES por `user_metadata.lang`, padrão PT): confirmação de cadastro por código, recuperação de senha por código e **definição de senha do professor** (variante da recuperação, ativada por `user_metadata.partner`, gravado por `admin-provision-partner`; traz botão para `/partners` e o passo "Esqueci minha senha"). Código `{{ .Token }}` (6 dígitos, validade 1 h); sem `ConfirmationURL`.
- **Bug corrigido:** os templates gerados tinham `{ .SiteURL }` (chaves simples, por causa do f-string) e a **logo nunca apareceria**. Corrigido; logo pública: `https://aprovaura.lucksrei.com/email/aprovaura-mark.png` (HTTP 200, `image/png`).
- **Confirmação obrigatória de e-mail continua desligada** (`mailer_autoconfirm=true`).
- A flag `partner` é removida automaticamente na primeira senha definida (gatilho `clear_partner_invite_flag_trg`, migration `20261204000100`); depois disso o professor recebe o e-mail de recuperação normal.
