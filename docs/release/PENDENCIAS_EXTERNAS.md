# Pendências externas — inventário definitivo (AprovaAura)

> Data-base: 24/11/2026. Fontes: `docs/release/FATOS_ETAPA09.md`, `docs/PREMIUM_PARTNERS.md` (§12–§19), `supabase/functions/`, `.github/workflows/deploy.yml`, `wrangler.toml`, `supabase/migrations/`.
> Marcadores: **[PENDENTE-DONO]** = decisão/dado só do dono; **[INCERTO]** = não confirmado em fonte oficial ou no console; **NÃO CONFIRMADO** = sem acesso ao painel.
> Este documento NÃO contém valores de credenciais. **Antes de pedir qualquer chave ao dono, rodar `vault.ps1 find` (cofre global) por serviço + projeto `aura`/`aprovaura` + ambiente.** Credenciais já no cofre não são re-solicitadas; as marcadas `unassigned` exigem confirmação de titularidade, não nova entrega.

Colunas de cada tabela: **Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia lançamento? | Como validar**. "Lançamento" = ativação comercial (`enforcement_enabled`).

## Resumo executivo
Tudo no código está pronto e **inerte**. Estão DESLIGADOS em produção: `enforcement_enabled`, confirmação obrigatória de e-mail (`mailer_autoconfirm` ainda `true`), todos os provedores de pagamento (`payment_providers_config.enabled=false`) e `AUTO_DEPLOY`. Nenhuma Edge Function de pagamento foi publicada; nenhuma integração foi validada com credenciais reais. Termos de Uso ainda NÃO existem em `legal_documents` (só Privacidade 2026-09-28).

## 0. Nomes de segredos exigidos pelas Edge Functions (só nomes)
| Função | Variáveis (Deno.env) |
|---|---|
| `_shared/common` (todas) | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (injetadas pelo próprio Supabase) |
| `payments-apple` / `_shared/apple` | `APPLE_BUNDLE_ID`, `APPLE_ROOT_CA_PEM`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID` |
| `payments-google` / `_shared/google` | `GOOGLE_PACKAGE_NAME`, `GOOGLE_SA_JSON`, `GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL` |
| `mp-checkout`, `mp-webhook` / `_shared/mp` | `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, `MP_COLLECTOR_ID`, `MP_ENV`, `MP_NOTIFICATION_URL`, `PORTAL_BACK_URL` |
| `payments-reconcile` | `CRON_SECRET` |
| `evaluate-essay` | `GEMINI_API_KEY`, `GEMINI_MODEL` |
| `admin-provision-partner`, `delete-account` | só as três do Supabase acima |
Todos devem ser definidos como **Supabase Secrets** (nunca no repositório, nunca no bundle Flutter). Ver `supabase/deploy_payments_functions.ps1`.

## 1. Supabase (projeto `cesuqfgrtcitatxvokez`)
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| PAT (Personal Access Token) | O token disponível não alcança este projeto (CLI só vê outras orgs) | Dono gerar PAT com acesso ao projeto e fornecer por canal seguro/cofre (consultar `vault.ps1 find` antes) | supabase.com › Account › Access Tokens | Dono | Sim (bloqueia deploy das funções e Auth) | `supabase projects list` lista o projeto |
| Projeto / migrations | 14 migrations (0100 de 24/11 até 20261201000200) aplicadas; rollbacks em `supabase/rollbacks/` | Nada (aplicar novas só via `tool/db/apply_migration.py`, nunca `db push`) | SQL via script | Agente | Não | `list_migrations` coincide com `supabase/migrations/` |
| Publicação das Edge Functions | Código pronto: `payments-apple`, `payments-google`, `mp-checkout`, `mp-webhook`, `payments-reconcile`, `admin-provision-partner`; `evaluate-essay` e `delete-account` já existentes. As 5 de pagamento + provisionamento NÃO publicadas | Rodar `supabase/deploy_payments_functions.ps1` e `supabase functions deploy admin-provision-partner` com PAT | CLI | Agente (com PAT) | Sim | `list_edge_functions`; POST sem assinatura retorna 401/400 (não 404) |
| Secrets das funções | Nenhum dos de pagamento definido (ver §0) | Cadastrar cada um conforme os consoles da Apple/Google/MP forem concluídos | Dashboard › Edge Functions › Secrets ou `supabase secrets set` | Agente (valores vindos do cofre/dono) | Sim | `supabase secrets list` mostra os NOMES; função não responde "missing env" |
| Config de Auth: templates | Prontos (`supabase/templates/{signup,recovery}_code.html`, PT/EN/ES) mas NÃO aplicados | `apply_auth_email_config.ps1 -Templates` | Auth › Email Templates (via script) | Agente (com PAT) | Sim (para ativar confirmação) | E-mail real recebido PT/EN/ES em Gmail e Apple Mail |
| SMTP (Resend) | Não aplicado | `apply_auth_email_config.ps1 -Smtp` (chave lida do cofre em runtime) | Auth › SMTP | Agente (com PAT) | Sim | E-mail chega do remetente `no-reply@lucksrei.com`; cabeçalhos SPF/DKIM ok |
| Confirmação de e-mail obrigatória | `mailer_autoconfirm=true`; `commercial_config.email_verification_required=false` | Só na ativação coordenada: `admin_update_commercial_config({"email_verification_required": true})` e `-Activate` | Auth + RPC admin | Agente + dono (autoriza) | Sim (trial de 72h depende da prova) | Cadastro novo exige código; trial só começa após `email_verifications` |
| Rate limits de Auth | Propostos (30 e-mails/h; OTP 30/5min/IP; reenvio 60 s) — não aplicados | Aplicar no lançamento | Auth › Rate Limits | Agente/dono | Não (recomendado) | Reenvio antes de 60 s é recusado |
| Storage/Realtime | NÃO CONFIRMADO no painel (código não os usa para conteúdo) | Conferir que nenhum bucket público/realtime expõe conteúdo de estudo | Dashboard › Storage / Realtime | Dono ou agente com PAT | Não (verificar no QA) | Lista de buckets vazia/privada; Realtime sem tabelas de conteúdo |
| Agendamento da conciliação | `payments-reconcile` pronta (lote ≤ 50, `x-cron-secret`); agendador NÃO criado | Criar cron (pg_cron, GitHub Actions ou Cloudflare) a cada 6–12 h com `CRON_SECRET` | Supabase (pg_cron) ou GitHub | Agente (após deploy) | Sim (renovações/expirações dependem dele) | Execução registra eventos; `service_subscriptions_to_check` esvazia |
| `CRON_SECRET` | Não definido | Gerar valor aleatório e guardar no cofre + Secrets | Cofre + Supabase Secrets | Agente | Sim | Chamada sem header retorna 401 |
| Plano/limites do banco (PostgREST `max-rows`, backups) | NÃO CONFIRMADO | Conferir plano, PITR/backup antes da ativação | Dashboard › Database | Dono | Não (recomendado) | Backup recente visível |

## 2. Resend
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| Domínio de envio | `lucksrei.com` já usado pela Lucksrei; "verificado/parcial" segundo notas — NÃO CONFIRMADO | Confirmar no painel que o domínio está `verified` (SPF/DKIM) | resend.com › Domains | Dono | Sim (para ativar confirmação) | Status `verified` no painel; teste de envio |
| Remetente | Planejado `AprovaAura <no-reply@lucksrei.com>` | Confirmar uso aprovado | Painel Resend + script `-Smtp` | Dono | Sim | E-mail mostra o remetente correto |
| Credenciais | Chave `resend.unassigned` no cofre, só envio (não lista domínios; 401 em listagem) | Dono confirmar que pode ser usada pelo AprovaAura (ou criar chave dedicada) | Cofre (`vault.ps1 find`/`update`) | Dono | Sim | Envio SMTP autenticado funciona |
| SMTP | Não aplicado no Auth | Ver §1 (SMTP) | Auth | Agente com PAT | Sim | Idem |
| Templates | Prontos, trilíngues; só autenticação | Aplicar (§1) | Auth | Agente com PAT | Sim | Revisar PT/EN/ES, claro/escuro, clientes de e-mail |
| Logo hospedada | `web/email/aprovaura-mark.png` referenciado via `{{ .SiteURL }}/email/aprovaura-mark.png`; só existe após deploy da web e se `site_url` do Auth for o domínio da web | Publicar a web e conferir `site_url` | Cloudflare + Auth › URL Configuration | Agente/dono | Não (cai em texto alternativo) | URL da imagem responde 200 |
| Limites | Plano grátis (100/dia) COMPARTILHADO com a Lucksrei | Decidir: subir de plano ou separar chave/domínio (custo = decisão do dono) | Resend › Billing | Dono | Sim se o volume de cadastros passar da cota | Painel de uso; sem rejeições por cota |

## 3. Apple
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| App publicado | Já na App Store (id citado em `/atualizar`) | — | — | — | Não | — |
| Contratos Paid Apps | NÃO CONFIRMADO | Aceitar contrato de Apps Pagos | App Store Connect › Business | Dono | Sim | Status "Active" |
| Bancário/fiscal | NÃO CONFIRMADO | Dados bancários e fiscais | App Store Connect › Business | Dono | Sim | Status sem pendências |
| Small Business Program | [INCERTO — não confirmado em página oficial] | Dono verificar elegibilidade e inscrever | App Store Connect | Dono | Não | Comissão reduzida refletida nos relatórios |
| Produtos | Ids planejados `aprovaura_premium_monthly` / `_annual` (BRL, Brasil) | Criar assinaturas, localizações PT/EN/ES, preços R$ 19,90 / R$ 190,00, revisão | App Store Connect › Subscriptions | Dono (agente prepara textos) | Sim | Estado "Ready to Submit"/aprovado; `payment_catalog.verified=true` |
| Grupo de assinatura | Planejado: um grupo único | Criar grupo; limites de nome/descrição [INCERTO — confirmar no App Store Connect] | App Store Connect | Dono | Sim | Grupo visível com as 2 assinaturas |
| Chaves | Nenhuma chave `.p8` gerada | Chave In-App Purchase (.p8, Key ID, Issuer ID) → secrets `APPLE_IAP_*`; `APPLE_ROOT_CA_PEM` (Apple Root CA G3) e `APPLE_BUNDLE_ID` | App Store Connect › Users and Access › Integrations; Supabase Secrets | Dono gera; agente cadastra | Sim | `payments-apple` valida JWS de teste; consulta App Store Server API responde |
| App Store Server API | Código pronto, sem chave | Chave acima | Secrets | Agente | Sim (reconciliação) | Reconciliação lê transação sandbox |
| Notifications V2 | URL a configurar: `…/functions/v1/payments-apple` (produção e sandbox); [INCERTO] cobertura oficial confirmada | Cadastrar URLs após deploy | App Store Connect › App Information | Dono | Sim | Notificação de teste chega e vira `payment_events` |
| Sandbox | Não executado | Criar testers sandbox; testar compra/renovação/cancelamento/reembolso/restauração | App Store Connect › Users › Sandbox | Dono + agente | Sim | Entitlement `sandbox:` sem receita/comissão |
| Primeira assinatura | Regra: deve ir junto de uma NOVA versão do app | Nova versão com paywall + `/confirmar-email` | App Store Connect | Dono | Sim | Submissão inclui grupo + ≥1 assinatura |
| Revisão | Conta demo ativa e notas (trial 72h próprio ≠ introductory offer; descrever claramente) | Criar conta de revisão; preencher notas; classificação etária (web irrestrita → 16+); exclusão de conta no app (já existe) | App Store Connect | Dono + agente | Sim | Aprovação |
| Relatórios financeiros | Aprovados só AGREGADOS (sem id de transação) | Baixar relatório real para amostra | App Store Connect › Payments and Financial Reports | Dono | Sim (antes de repasse) | Totais conferem; ver `docs/finance/RECONCILIATION.md` |

## 4. Google Play
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| App publicado | Já na Play (`com.lucasdiogof.aprovaura`) | — | — | — | Não | — |
| Perfil de pagamentos | NÃO CONFIRMADO | Perfil de pagamentos/fiscal | Play Console › Setup | Dono | Sim | Perfil ativo |
| Produto | Planejado `aprovaura_premium` com base plans `monthly` / `annual` | Criar assinatura e base plans; nome do SKU não pode conter "Free Trial" | Play Console › Monetize › Subscriptions | Dono | Sim | Base plans "Ativos"; `payment_catalog.verified=true` |
| Preços | Referência R$ 19,90 / R$ 190,00 | Definir BRL (mostrar anual também como total) | Play Console | Dono | Sim | Preço no app = preço da loja |
| Ofertas/trial | Trial é do app (72 h, sem cartão) | Não criar oferta gratuita de loja; [INCERTO] regras de ofertas — confirmar no console | Play Console | Dono | Não | Texto da assinatura não promete "grátis" |
| Service account | Não criada | Criar SA com permissão de pedidos/assinaturas + Android Publisher API → `GOOGLE_SA_JSON` | Google Cloud + Play Console › API access | Dono cria; agente cadastra | Sim | `subscriptionsv2.get` retorna 200 com compra de teste |
| Pub/Sub e RTDN | Não criados | Tópico + assinatura push OIDC → `…/functions/v1/payments-google`; `GOOGLE_PUBSUB_AUDIENCE`, `GOOGLE_PUBSUB_SA_EMAIL`; informar tópico no Play Console | Google Cloud Pub/Sub; Play Console › Monetization setup | Dono | Sim | Notificação de teste vira `payment_events` |
| Play Billing Library | Versão 7 vencida; usar 8 ou 9 (confirmar versão do `in_app_purchase_android` no QA) | Garantir ≥ 8 no build | `pubspec.lock`/Gradle | Agente (QA) | Sim | Upload aceito sem aviso de biblioteca |
| Contas de teste | Não definidas | License testers + faixa de teste | Play Console › Setup › License testing | Dono | Sim | Compra de teste (`testPurchase` → sandbox) |
| Data safety / IARC / Families / acesso | [INCERTO — confirmar no console] | Atualizar Data safety (Supabase = coleta; histórico de compras: considerar), exclusão de conta | Play Console › App content | Dono + agente (rascunho) | Sim | Formulários sem pendência |
| Relatórios | Há id de pedido individual; API v2 não devolve preço pago (bruto = referência, estimado) | Baixar relatório financeiro de amostra | Play Console › Download reports | Dono | Sim (antes de repasse) | Ver `RECONCILIATION.md` |

## 5. Mercado Pago
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| Titularidade das credenciais | No cofre como `unassigned`; NÃO usadas | Dono confirmar que a conta é do AprovaAura e a qual CNPJ/CPF pertence | Cofre (`find`/`update`) | Dono | Sim | Registro com projeto/ambiente definidos |
| Aplicação | Não criada | Criar aplicação (checkout/assinaturas) | mercadopago.com.br/developers | Dono | Sim | Aplicação listada |
| Ambientes teste/prod | `MP_ENV` e `live_mode` mapeiam ambiente; nenhum liberado | Credenciais de teste e de produção separadas | Developers › Credenciais | Dono | Sim | Webhook de teste → sandbox; produção só após liberar |
| Access Token / segredo / collector | Nenhum cadastrado | `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, `MP_COLLECTOR_ID` (sem ele a função falha fechada) | Supabase Secrets | Agente (valores do cofre) | Sim | `mp-checkout` cria cobrança de teste |
| Webhooks | URL a registrar: `…/functions/v1/mp-webhook` (+ `MP_NOTIFICATION_URL`) | Registrar eventos de pagamento e assinatura | Developers › Webhooks | Dono | Sim | HMAC `x-signature` validado; duplicado/fora de ordem barrado |
| Cartão recorrente | Código usa `preapproval` (checkout hospedado) | Confirmar que a conta tem Assinaturas habilitado | Conta MP | Dono | Sim (para plano recorrente web) | Assinatura de teste autorizada + cobrança aprovada concede acesso |
| Pix | Só Pix AVULSO (30/365 dias, renovação manual); sem Pix recorrente automático | Confirmar Pix habilitado | Conta MP | Dono | Sim (para Pix) | Pix de teste aprovado/expirado/estornado |
| Conciliação | `fee_details` dá taxa; imposto estimado; SOURCE_ID individual no relatório | Relatório de amostra | MP › Relatórios | Dono | Sim (antes de repasse) | Ver `RECONCILIATION.md` |
| `PORTAL_BACK_URL` | **Definido (24/11)**: `https://aprovaura.lucksrei.com/partners` | URL de retorno do checkout web | Secrets | Agente | Sim | Retorno nunca libera Premium (só consulta) |

## 6. Cloudflare / GitHub
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| `AUTO_DEPLOY` | Variável do GitHub `false` (push em `main` não publica); deploy manual por `workflow_dispatch` | Colocar `true` só como ÚLTIMO passo do lançamento | GitHub › Settings › Variables | Dono/agente (com autorização) | Sim | Push em `main` dispara o job |
| Secrets do workflow | Usa `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | Conferir que existem e que o token permite deploy do Worker | GitHub › Secrets | Dono | Sim | Run manual conclui; `check-bundle-secrets.sh` passa |
| Worker | `wrangler.toml`: Worker `aura`, assets `build/web`, SPA, rota custom `aprovaura.lucksrei.com` + `workers_dev` | Nada de código | Cloudflare | — | Não | Domínio responde; `/partners` abre (F5 funciona) |
| Auto-deploy independente | Workers Builds (Git) pode publicar sozinho a cada push, fora do Actions — NÃO CONFIRMADO | Conferir/desligar a integração Git se existir | Cloudflare › Workers › aura › Settings › Builds | Dono | Sim (risco de publicar antes da hora) | Push de teste em branch não gera build |
| Rotas | Domínio `aprovaura.lucksrei.com` aprovado; QA de auth pendente | Validar login/redirects/`site_url` | Cloudflare + Auth | Agente | Sim | Login web e e-mails apontam para o domínio certo |
| Publicação web | Web atual sem Etapas 02–09 (`/partners`, logo de e-mail só após deploy) | Deploy coordenado (passo 15 do plano) | GitHub Actions | Agente com autorização | Sim | `/partners`, `/privacidade`, `/email/aprovaura-mark.png` ok |
| Rollback | Versões anteriores do Worker disponíveis na Cloudflare; `emergency_disable` no banco | Documentar versão atual antes de publicar | Cloudflare › Deployments; RPC admin | Agente | Sim (precisa estar pronto) | Rollback de teste restaura versão anterior |

## 7. Gemini (avaliação de redações)
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| Camada | GRATUITA: Google pode usar conteúdo para melhorar produtos e revisores humanos podem ler; termos pedem não enviar dados pessoais | Migrar para camada PAGA (billing) ANTES de redações de usuários reais em escala comercial. Custo novo = decisão do dono | Google AI Studio / Cloud Billing | Dono | **Sim [PENDENTE-DONO]** | Projeto da chave com billing ativo; prazo exato dos logs da camada paga [INCERTO] |
| Chave | `GEMINI_API_KEY` (verificar no cofre antes) | Nova chave do projeto pago, se houver troca | Supabase Secrets | Agente | Sim | `evaluate-essay` responde |
| Política de menores | Termos exigem 18+ e vedam clientes "direcionados a ou provavelmente acessados por" menores de 18 | Decidir: restringir correção por IA a 18+ ou obter parecer jurídico | Produto + jurídico | Dono | **Sim [PENDENTE-DONO]** | Decisão registrada; UI/servidor aplica a regra |
| Texto público | Não afirmar "sem treinamento" para a camada atual | Atualizar só depois da migração | Política/ficha | Agente | Não | Revisão de textos |
| Conteúdo enviado | Tema, textos de apoio, texto da redação e critérios — sem identificadores | — | — | — | Não | Auditoria da função |

## 8. Jurídico / dono
| Item | Estado atual | O que falta | Onde configurar | Quem executa | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|
| CNPJ | [PENDENTE-DONO: CNPJ] | Informar | Termos/Política/lojas | Dono | Sim | Aparece nos documentos |
| Razão social | [PENDENTE-DONO: razão social] | Informar | idem | Dono | Sim | idem |
| Endereço | [PENDENTE-DONO: endereço] | Informar (Decreto 7.962: identificação do fornecedor) | idem | Dono | Sim | idem |
| E-mail/canal de suporte oficial | [PENDENTE-DONO: e-mail de suporte] | Definir canal e SLA de resposta (Decreto 7.962: até 5 dias) | Site `…/support/`, lojas | Dono | Sim | Mensagem de teste respondida |
| Encarregado (DPO) | [PENDENTE-DONO: encarregado] | Nomear e publicar contato | Política | Dono | Sim | Contato publicado |
| Idade mínima | [PENDENTE-DONO: 13/16/18?] | Decidir; reflete no `set_my_age_band` e nas lojas | Produto | Dono | Sim | Regra aplicada no cadastro |
| Base legal professor/menores | Implementado seguro por padrão (só `adult` compartilha) | Decidir modelo de vínculo para menores, consentimento parental (<12), pagamento por responsável | Jurídico | Dono + advogado | Sim | Parecer arquivado |
| RIPD | Não elaborado | Elaborar com base em `MATRIZ_DADOS_PRIVACIDADE.md` | Jurídico | Dono/advogado | Sim [PENDENTE-DONO] | Documento assinado |
| Termos de Uso | NÃO publicados em `legal_documents` | Dono aprovar texto → `publish_legal_version` na ativação coordenada | Banco (RPC) + site `…/terms/` | Agente (após aprovação) | Sim | `get_legal_status` lista os dois |
| Retenção fiscal | [INCERTO — confirmar com contador] (geralmente 5 anos) | Confirmar prazo | Contador | Dono | Não | Prazo registrado na matriz |
| Revisão de advogado | Não feita (a pesquisa legal NÃO é parecer) | Revisar Termos, Privacidade, ECA Digital, consumidor | Advogado | Dono | **Sim** | Parecer/ressalvas incorporadas |
| Arrependimento (CDC 49) | [INCERTO] aplicação a assinatura digital; reembolso Apple/Google conforme a loja | Posição formal | Jurídico | Dono | Não | Texto em `INFO_ASSINATURAS.md` revisado |
