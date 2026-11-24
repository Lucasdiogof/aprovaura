# AprovaAura Premium + Partners — documento central

> **Fonte de continuidade entre sessões e agentes.** Atualize-o em TODA etapa.
> Estado em 2026-11-26: **Etapas 01 (fundação), 02 (cadastro/autenticação/indicação), 03 (onboarding animado) e 04 (portal administrativo) concluídas. O modelo comercial e a confirmação obrigatória de e-mail estão DESLIGADOS em produção.**

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
`lib/features/access/` (entidade `AccessStatus`, `AccessRepository`, `AccessGrantVerifier`, `AccessCubit`), `lib/features/partners/` (listar ativos, vínculo, solicitar troca), `PremiumRequiredFailure` (HTTP 402) em `failureFromError`, `wireAccessSupport()` em `injection_container.dart` (login/abertura, saída, retorno do segundo plano, reconexão, 402). **Ainda não existe** paywall, tela de bloqueio nem portal. A seleção de professor no cadastro, a tela do código de e-mail e a seção "professor indicador" do perfil existem (§13).

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

**Roadmap oficial (exatamente dez etapas, 01–10; não renumerar):** 1 Fundação, segurança e monetização ✔; 2 Cadastro, Resend e confirmação de e-mail ✔; 3 Onboarding animado com Aurudo ✔; 4 Portal administrativo ✔ (§15); 5 Portal dos professores; 6 Financeiro, comissões e repasses; 7 Apple, Google e Mercado Pago; 8 Paywall e integração final; 9 Termos, privacidade e preparação comercial; 10 QA consolidado, correções e publicação.

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
- Link de indicação exibido, mas o cadastro por `?ref=` ainda não é consumido pelo app (hoje o aluno escolhe na lista).
- Professor sem painel (Etapa 05). Financeiro detalhado, fechamento e repasses pela UI: Etapa 06.
- Código Flutter novo escrito **sem `flutter analyze` e sem testes** (diretriz); revisar no QA final. Teste de `authRedirect` existente segue válido (parâmetros novos são opcionais).

### 15.8 Pendências externas
1. Deploy da Edge Function (`supabase functions deploy admin-provision-partner`, requer PAT do dono para o projeto `cesuqfgrtcitatxvokez`).
2. Aplicar templates/SMTP de e-mail (§13.6) para o e-mail de definição de senha do professor chegar com o layout trilíngue.
3. Publicar a web (sem deploy nesta etapa) — `/partners` só existe após o próximo deploy.
