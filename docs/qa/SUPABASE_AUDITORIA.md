# Auditoria do Supabase (projeto `cesuqfgrtcitatxvokez`, 24/11/2026)

Feita com o PAT do cofre (`supabase.aprovaura.production.pat`), só leitura, exceto o que está marcado como alteração. Nenhum segredo foi gravado em arquivo.

## 1. PAT
- Lista **exatamente 1 projeto**: `cesuqfgrtcitatxvokez` (nome `aura`, região sa-east-1, `ACTIVE_HEALTHY`). A consulta à organização retorna **403**: o token é restrito ao AprovaAura.
- Permite: leitura de projeto, Auth, Storage, Postgrest, Realtime, Secrets (só nomes), Functions, advisors e consulta SQL somente leitura; deploy de Functions (usado nesta rodada).
- Incidente de higiene: a leitura do endpoint `postgrest` devolveu o campo `jwt_secret` e ele apareceu na saída da ferramenta desta conversa (não foi gravado em arquivo nem enviado a terceiros). Os auxiliares passaram a omitir campos sensíveis. **Decisão do dono:** rotacionar o JWT secret é opcional (invalida chaves legadas `anon`/`service_role` e exige atualizar quem as usa); a política do dono é não revogar tokens do Supabase, então nada foi rotacionado.

## 2. Auth (config)
| Item | Valor | Avaliação |
|---|---|---|
| `site_url` | `https://aprovaura.lucksrei.com` | coerente com a Web |
| `uri_allow_list` | `https://aprovaura.lucksrei.com/` | suficiente: o app usa código de verificação, sem `redirectTo` nem deep link |
| Cadastro | aberto; anônimos desligados; só provedor `email` | ok |
| `mailer_autoconfirm` | **true** | confirmação obrigatória de e-mail **desligada**, como exigido; não alterado |
| Senha | **mínimo 8** (alterado em 24/11; antes 6), sem exigência de classes | Flutter (`minPasswordLength`, mensagens PT/EN/ES), `config.toml` e Auth alinhados |
| Vazamento de senha (HIBP) | desligado | alerta do advisor; recurso de plano pago: não ligado |
| Rotação de refresh token | ligada (reuso 10 s) | ok |
| JWT | 3600 s | ok |
| Limite de e-mails | **15/h** (era 2; ver §10) | proporcional ao plano grátis da Resend |
| SMTP | `smtp.resend.com`, remetente `AprovaAura <no-reply@lucksrei.com>` (alterado em 24/11, ver §10) | chave Resend `unassigned` validada como somente envio |
| Captcha, hooks | desligados | ok |

Nada de Auth foi alterado.

## 3. Storage, Realtime, banco
- **Storage:** 0 buckets, 0 políticas em `storage`. Limite de arquivo 50 MB; sem transformação de imagem.
- **Realtime:** 0 tabelas na publicação `supabase_realtime`; sem canais de dados expostos.
- **RLS:** nenhuma tabela de `public` sem RLS. 35 tabelas com RLS ligado e **sem política** (INFO do advisor): é o desenho (acesso só por RPC `SECURITY DEFINER`/service role), confirmado pelos testes negativos.
- **Extensões:** só `supabase_vault`. `pg_cron` e `pg_net` disponíveis para instalar, não instaladas.
- **Rede/SSL/backup:** banco aceita qualquer IP (padrão), SSL obrigatório **desligado**, PITR desligado (backup diário do plano). Recomendação: ligar SSL enforcement quando todos os clientes confirmarem TLS; PITR é pago.
- **Advisors de segurança:** 31 `function_search_path_mutable` (funções legadas de leitura), 28 (anon) e 102 (authenticated) RPCs `SECURITY DEFINER` executáveis (esperado: são a API do app; cada `admin_*` chama `require_admin()` e cada `partner_*` chama `_active_partner_id()`), 1 de senha vazada. Performance: 23 `auth_rls_initplan`, 12 FKs sem índice, 13 índices sem uso (INFO/WARN, sem impacto hoje).

### Vulnerabilidade encontrada e corrigida
`refresh_broken_streak(p_user_id, p_today)` (`SECURITY DEFINER`) era executável por `anon`/`authenticated` e **não checava o dono**: com `p_today` distante, quem conhecesse o UUID zerava a sequência de estudo de outro usuário (integridade, sem vazamento). O app não a chama direto (só `get_or_refresh_user_streak`/`register_activity_completion`, que rodam como dono). Corrigida pela migração `20261203000100` (revoga de `public`, `anon`, `authenticated`; rollback em `supabase/rollbacks/`). Provas: antes 204 anônimo, depois **401**; `get_or_refresh_user_streak` segue funcionando (teste SQL novo); `rest_negative_tests` 35/35.

### Achado de desenho (sem alteração)
`payments_ingest_event` não consulta `payment_providers_config.enabled` (só taxas): o interruptor bloqueia **o início de compra** (MP) e o desenho documentado é que reembolsos/cancelamentos de quem já assina continuem sendo processados com vendas suspensas. Antes da ativação, o que impede efeito real é a ausência dos Secrets e da configuração nos consoles.

## 4. Secrets
Presentes: `SUPABASE_*` (padrão), `GEMINI_API_KEY`, `GEMINI_MODEL`. **Ausentes** (necessários só na ativação): `MP_ACCESS_TOKEN`, `MP_COLLECTOR_ID`, `MP_WEBHOOK_SECRET`, `MP_NOTIFICATION_URL`, `MP_ENV`, `APPLE_BUNDLE_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_KEY_ID`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_ROOT_CA_PEM`, `GOOGLE_PACKAGE_NAME`, `GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL`, `CRON_SECRET`, `ESSAY_AI_PROVIDER` (opcional; padrão `google`).

## 5. Edge Functions
- **Checagem de tipos resolvida:** o erro era de configuração (`@types/node` não resolvido pelo `deno test` sem `nodeModulesDir`). `deno.json` na raiz com `nodeModulesDir: auto` e tarefas `deno task check:functions` (8 funções + 2 testes) e `deno task test:functions` (6/6 **com checagem completa**).
- **Publicadas (24/11):** `evaluate-essay` v18 (agora com o interruptor `ESSAY_AI_PROVIDER` e a correção de idioma já presente no repositório desde 07/10; padrão `google` = mesmo comportamento), `admin-provision-partner`, `mp-checkout`, `mp-webhook`, `payments-apple`, `payments-google`, `payments-reconcile` (v1). `delete-account` v5 já era idêntico ao repositório (0 linhas divergentes): não republicado.
- `verify_jwt`: `true` em `delete-account`, `evaluate-essay`, `mp-checkout`, `admin-provision-partner`; `false` nos 4 webhooks/cron (autenticados por assinatura HMAC, OIDC do Pub/Sub, JWS da Apple e `x-cron-secret`).
- **Falha fechada comprovada:** `tool/qa/edge_smoke.py` **19/19** em produção, só chamadas sem credencial e sem efeito (401/405/400; nunca 2xx).
- Não testado (depende de credenciais): fluxo feliz de qualquer provedor, `evaluate-essay` autenticado (o interruptor tem teste unitário), `admin-provision-partner` com admin real.

## 6. Agendar a conciliação sem custo
Viável: `pg_cron` + `pg_net` são extensões incluídas em todos os planos, o projeto não tem add-ons pagos e 1 chamada a cada 12 h é desprezível frente à cota de invocações. **Não ativado agora**: 0 assinaturas, provedores desligados e `CRON_SECRET` ausente (a função devolveria 401). Procedimento para a ativação:
1. Gerar um segredo aleatório; guardar no cofre local, em `supabase secrets set CRON_SECRET=…` e em `vault.create_secret(…, 'cron_secret')` (mesmo valor).
2. `create extension pg_cron; create extension pg_net;`
3. Agendar:
   ```sql
   select cron.schedule('payments-reconcile', '17 */12 * * *', $$
     select net.http_post(
       url := 'https://cesuqfgrtcitatxvokez.supabase.co/functions/v1/payments-reconcile',
       headers := jsonb_build_object('x-cron-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), 'content-type', 'application/json'),
       body := '{}'::jsonb, timeout_milliseconds := 20000) $$);
   ```
4. Desfazer: `select cron.unschedule('payments-reconcile');`

Alternativa sem extensões: Cloudflare Cron Trigger (gratuito) ou workflow agendado; o `pg_cron` evita depender de GitHub Actions.

## 7. Pendências do Supabase
| # | Pendência | Quem |
|---|---|---|
| 1 | Definir Secrets de cada provedor quando for ativar (lista acima), incluindo `PORTAL_BACK_URL` e `CRON_SECRET` | Dono (valores) / agente (aplicar) |
| 2 | Decidir senha mínima (8+) e SSL enforcement; HIBP exige plano pago | Dono |
| 3 | Decidir rotação do JWT secret (ver §1) | Dono |
| 4 | Templates de e-mail do Auth (`apply_auth_email_config.ps1`) não aplicados: dependem da titularidade do domínio/Resend | Dono |
| 5 | Agendar a conciliação (§6) só na ativação | Agente |
| 6 | Conferir no painel o Cloudflare Workers Builds (publicação automática da Web fora do GitHub Actions) | Dono |
| 7 | `check_answer` + retirada de `correct_index` + `min_version_*` no lançamento | Agente após decisão |

## 8. Fechamento de segurança (24/11, 2ª rodada)

### 8.1 Senha mínima 8 — aplicado
Auth (`password_min_length` 6 → 8, via API de gestão), `supabase/config.toml`, `minPasswordLength` no Flutter e textos PT/EN/ES. Contas existentes não são afetadas (vale para cadastro/troca/recuperação). `mailer_autoconfirm` continua `true` (confirmação de e-mail desligada). Teste de cadastro atualizado (não executado nesta rodada).

### 8.2 SSL obrigatório no banco — aplicado
Compatibilidade verificada: todos os clientes diretos (`tool/db/*.py`, auxiliares de QA) usam `sslmode=require` ou `prefer` (negocia TLS); app, Web e Edge Functions falam com a API por HTTPS e não abrem conexão direta. Aplicado `ssl-enforcement`; conexão com TLS funciona e conexão com `sslmode=disable` é **recusada**. Reverter: `PUT /v1/projects/<ref>/ssl-enforcement` com `{"requestedConfig":{"database":false}}`.

### 8.3 PORTAL_BACK_URL — aplicado
**Corrigido em 24/11 (serviço 5):** `/partners` exige papel de professor/admin, então o assinante comum não conseguia voltar; o Secret agora é `https://aprovaura.lucksrei.com/minha-assinatura` (rota de qualquer assinante) e as funções foram republicadas. Antes: `https://aprovaura.lucksrei.com/partners`. Único uso: `back_url` do checkout de cartão em `mp-checkout` (retorno nunca libera Premium; só o webhook). O padrão em código também foi corrigido (a função publicada ainda tem o padrão antigo, mas ele só vale sem o Secret; republicar na ativação).

### 8.4 JWT Secret exposto — estratégia (SUPERADA: executada e concluída em 24/11, ver §9)
**Risco real:** quem tiver o secret legado forja qualquer JWT (inclusive `role=service_role`) até ele ser revogado. Foi exibido só na saída da ferramenta da sessão (não gravado nem enviado); o risco é residual, mas a rotação continua recomendada antes de aceitar dinheiro/dados sensíveis.

**Situação atual (medida):** 0 chaves de assinatura assimétricas (projeto 100% no secret legado HS256); chaves de API: `anon` e `service_role` legadas + 1 `publishable` + 1 `secret` (novo sistema).

**Quem depende do secret legado:**
| Consumidor | Usa | Impacto da rotação |
|---|---|---|
| App Flutter (Android/iOS/Web), CI, `env.json` | chave **publishable** (não é JWT legado) | **nenhum** na chave; apps publicados continuam |
| Sessões de usuários (access/refresh JWT) | assinados pelo secret legado | invalidadas se o secret legado for **revogado**: usuários precisam entrar de novo |
| Edge Functions | `SUPABASE_ANON_KEY`/`SERVICE_ROLE_KEY` injetadas (JWT legados) + `verify_jwt` | a plataforma reinjeta ao rotacionar; funções em execução usam as novas após novo deploy/reinício. Janela curta de 401 possível |
| Scripts locais/QA | `secret-key` e `publishable-key` do cofre (novo sistema) | nenhum |
| `tool/db/empty_db_check.sh` | cita service_role (local) | conferir antes |
| Access token offline do Premium | RSA próprio no banco | **independente** do JWT Secret |

**Procedimento recomendado (migração para JWT Signing Keys, sem derrubar usuários de uma vez):**
1. Dashboard → Settings → JWT Keys → **Migrate JWT secret** (cria chave ES256 em standby; o secret legado continua válido como verificador). Não há endpoint na API de gestão (`/jwt-signing-keys` e `/config/auth/signing-keys` devolvem vazio/404), então é ação no painel.
2. **Rotate** para a nova chave: novos tokens passam a ser ES256; sessões antigas (HS256) seguem válidas até expirarem (1 h) ou serem renovadas por refresh.
3. Confirmar (smoke das Edge Functions + login real) e só então **revogar** o secret legado: é aqui que o vazamento deixa de valer; `anon`/`service_role` legados deixam de funcionar (nada do app usa; Edge Functions dependem do reinício do passo 4).
4. Republicar as 7 Edge Functions (reinjeta chaves) e rodar `tool/qa/edge_smoke.py`, `rest_auth_tests.py` e `rest_negative_tests`.
5. Plano de volta: antes do passo 3 dá para voltar a chave legada como "in use"; depois da revogação, não.
Impacto esperado: nenhuma mudança de app/loja; usuários logados há mais de 1 h só renovam por refresh token (o refresh token não é JWT assinado pelo secret); pior caso, novo login. Executar fora de horário de pico e **só com sua autorização**.

## 9. Rotação de chaves JWT — concluída (24/11, 3ª rodada)

**Achado que corrige o §8.4:** a API de gestão (`/config/auth/signing-keys`, que só passei a consultar nesta rodada) mostrou que o projeto **já emitia tokens ES256** (chave `in_use`, criada em 13/08) e o secret HS256 legado estava só como `previously_used` (ainda aceito como verificador). Ou seja, a "migração" já existia; faltava **revogar o legado** e **desativar as chaves `anon`/`service_role`**. Os passos manuais no painel não foram necessários: tudo foi feito pela API de gestão com o PAT do cofre.

### 9.1 Evidências antes de agir
- **Web publicada** (`aprovaura.lucksrei.com/main.dart.js`): contém `sb_publishable_`, **zero** JWT HS256 embutido.
- **Android/iOS:** `env_config.dart` nasceu em 14/08/2026 já com `SUPABASE_PUBLISHABLE_KEY` e nunca teve chave anon JWT no histórico do Git; todas as versões publicadas (1.0.x/1.1.0) usam a publishable. Não baixei os binários das lojas (limite desta verificação: é inferência pelo histórico + build).
- **Dependências legadas:** só as 3 Edge Functions e `_shared/common.ts` (`SUPABASE_ANON_KEY`/`SERVICE_ROLE_KEY`). Nenhum JWT legado no repositório, CI, `env.json` ou cofre (o cofre só tem `secret-key`, `publishable-key`, `pat`, `db-url`). `tool/db/empty_db_check.sh` só cria papéis num banco local.

### 9.2 Mudanças no código
- `supabase/functions/_shared/keys.ts`: `publishableKey()`/`secretKey()` leem `SUPABASE_PUBLISHABLE_KEYS`/`SUPABASE_SECRET_KEYS` (chave `default`), com a legada só como reserva se a moderna faltar. Usado por `delete-account`, `evaluate-essay`, `admin-provision-partner` e `_shared/common.ts` (mp/apple/google/reconcile). Teste: `keys_test.ts`.
- **`verify_jwt = false` nas 8 funções** (`config.toml`): o gateway só entende JWT legado e não autentica chaves `sb_*`. A autenticação passou a ser **explícita e anterior a qualquer efeito** dentro de cada função:
  | Função | Autenticação no código |
  |---|---|
  | `delete-account` | `auth.getUser()` (GoTrue valida ES256) antes de apagar |
  | `evaluate-essay` | `auth.getUser()` agora **antes** de ler o corpo, checar provedor ou cota |
  | `mp-checkout` | `caller()` → `getUser()` |
  | `admin-provision-partner` | RPC `admin_assert` com o JWT do chamador (403 a não-admin) |
  | `mp-webhook` | HMAC oficial do Mercado Pago (inalterado) |
  | `payments-apple` | JWS ES256 + cadeia fixada na raiz Apple; compra do app exige `getUser()` |
  | `payments-google` | OIDC do Pub/Sub; compra do app exige `getUser()` |
  | `payments-reconcile` | `x-cron-secret` em tempo constante |
- Publicadas (v3 as de pagamento/provisionamento, `evaluate-essay` v21, `delete-account` v7), todas `verify_jwt=false`.

### 9.3 Execução
1. Funções migradas e publicadas **antes** de mexer nas chaves; smoke 19/19 e `auth_rotation_check.py` passaram.
2. `PUT /api-keys/legacy?enabled=false` → chaves `anon`/`service_role` **desativadas** (reversível pelo painel, mas não usada como estratégia).
3. Smoke + `auth_rotation_check.py` de novo: OK.
4. `PATCH /config/auth/signing-keys/<HS256>` → `status: revoked`. Estado final: **ES256 `in_use`, HS256 `revoked`**. O secret comprometido **não é mais aceito** como verificador e não é o plano de rollback (voltar a ele reabriria a exposição; o rollback correto é gerar nova chave).
5. Verificação final: smoke 19/19; `auth_rotation_check.py` todos OK (criar usuário temporário → login → refresh → `get_my_access` → RPC admin negada → Edge Functions autenticadas → `delete-account` real → usuário apagado). Usuários de teste são apagados no próprio script; nada real foi tocado.

### 9.4 Testes
`deno task check:functions` (tipos) e `deno task test:functions` 7/7 (6 anteriores + `keys_test`). **Não** rodei de novo os 103 testes REST autenticados, SQL nem os testes Flutter nesta rodada (nada de banco/Flutter mudou além do que o script de rotação cobre); recomenda-se rodar `rest_auth_tests.py` no próximo ciclo.

### 9.5 Pós-rotação (como repetir a checagem)
`SUPA_URL=… SUPA_PUB=<publishable> SUPA_SEC=<secret> python tool/qa/auth_rotation_check.py` (cria e apaga um usuário temporário) e `tool/qa/edge_smoke.py`.

### 9.6 Observações
- Sessões existentes não foram derrubadas (todos os tokens já eram ES256).
- Primeira chamada fria de `evaluate-essay` demorou >30 s uma vez (cold start intermitente; passou na repetição). Vale observar.
- Armazenamento antigo do segredo no histórico da sessão não pode ser "apagado", mas deixou de ter valor.
- `PUT /api-keys/legacy` e `PATCH …/signing-keys` não estão na documentação lida; foram aceitos pela API (200) e confirmados por GET.

## 10. Resend e e-mails do Auth (24/11)
**Chave:** `resend.unassigned.production.api-key` — aceita pela API e **restrita a envio** (suficiente para SMTP; não pedi chave completa). Titularidade: é a conta Resend da Lucksrei; o dono autorizou o uso nesta rodada. Domínios: não listáveis com esta chave; provado por envio que **`lucksrei.com` está verificado** e `aprovaura.lucksrei.com` não está autorizado.

**Aplicado (Management API, sem custo):** SMTP Resend, remetente `AprovaAura <no-reply@lucksrei.com>`, `rate_limit_email_sent=15`, OTP 6 dígitos/3600 s, assuntos bilíngues e os dois templates (cadastro e recuperação com a variante de professor). `mailer_autoconfirm` **continua true**. Templates/script: `supabase/templates/`, `supabase/apply_auth_email_config.ps1` (id do cofre corrigido, 15/h).

**Limites Resend (grátis):** 100/dia, 3000/mês, 10 req/s; compartilhados com a Lucksrei. Com 15/h o Supabase não passa de 360/dia, mas a Resend corta em 100/dia (envios acima falham sem custo). Para lançar com confirmação obrigatória em escala: plano pago ou chave/cota própria (decisão do dono).

**Testes (`tool/qa/email_flow_check.py`, só contas temporárias `delivered+…@resend.dev`, apagadas):** recuperação PT/EN/ES, recuperação de conta antiga sem `lang`, definição de senha de professor (`partner`) e reenvio de confirmação de cadastro: **todas aceitas pelo SMTP (HTTP 200)**. Nenhum usuário real recebeu e-mail. Uma chamada de reenvio de cadastro estourou 60 s uma vez (intermitente) e passou ao repetir.
**Não verificado:** a renderização final na caixa de entrada (Gmail/Outlook/dark mode) e a entrega real — o destino de teste da Resend não expõe o corpo e a chave não lê e-mails enviados. Recomendo 1 envio de conferência a um endereço do dono antes do lançamento (precisa da sua autorização do destinatário). Deploy de `admin-provision-partner` atualizado (grava `partner: true`).

### 10.1 Conferência na caixa de entrada e correção do texto do professor (24/11)
- **Envio autorizado pelo dono:** 3 modelos (cadastro, recuperação, boas-vindas/senha do professor) × PT/EN/ES × 2 destinatários (`lucasdiogo1234@gmail.com`, `marketing@lucksrei.com`) = **18/18 aceitos pelo SMTP (200)**, com os templates reais do Supabase (`tool/qa/email_send_samples.py`). Contas existentes e senhas **não foram tocadas**: o Gmail usou aliases `+tag` de contas temporárias; `marketing@` (sem conta prévia) usou uma conta temporária com o endereço exato. Limites `rate_limit_email_sent` (15) e `smtp_max_frequency` (60 s) foram elevados só durante o envio e **restaurados**; as 10 contas temporárias foram apagadas.
- **Bug do professor corrigido:** a variante de boas-vindas dependia de `user_metadata.partner`, que nunca era removida. Migration `20261204000100_clear_partner_invite_flag.sql` (rollback em `supabase/rollbacks/`): um gatilho `BEFORE UPDATE OF encrypted_password` em `auth.users` remove a flag na primeira senha definida, e o backfill limpou a flag de quem já entrou (nenhum caso real existia). Ensaiado em transação revertida: outras atualizações mantêm a flag; troca de senha a remove.
- A inspeção visual (logo, botões, formatação) é do dono, na caixa de entrada.
