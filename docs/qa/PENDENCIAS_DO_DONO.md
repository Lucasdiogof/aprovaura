# Pendências do dono: lista única e consolidada

Cada item: **Estado atual / Falta / Onde / Quem / Bloqueia lançamento? / Como validar.** Detalhe completo por serviço: `docs/release/PENDENCIAS_EXTERNAS.md`. Nenhum valor de credencial aqui.

Auditoria do cofre (Etapa 10C): para o AprovaAura existem apenas `supabase.aprovaura.*` (secret e publishable) e `postgres.aprovaura.production.db-url`. **Não há** no cofre: PAT do Supabase para este projeto, Apple, Google, Cloudflare/GitHub para o AprovaAura. Resend e Mercado Pago estão `unassigned` (não usados até confirmação de titularidade).

| # | Item | Estado atual | Falta | Onde | Quem | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|---|
| 1 | PAT do Supabase | ausente para o projeto `cesuqfgrtcitatxvokez` | gerar e guardar no cofre (projeto aprovaura) | supabase.com › Account › Access Tokens; cofre | Dono | Sim | `supabase projects list` mostra o projeto |
| 2 | Publicar Edge Functions (6 de pagamento/provisão + `evaluate-essay` com interruptor) | código pronto, nada publicado | rodar scripts com o PAT | CLI | Agente | Sim | `list_edge_functions`; chamada sem assinatura dá 401/400 |
| 3 | Resend: confirmar domínio e titularidade da chave `unassigned` | não confirmado | verificar SPF/DKIM; autorizar chave para o AprovaAura | resend.com; cofre | Dono | Sim | status `verified`; envio de teste |
| 4 | Templates e SMTP no Auth | prontos, não aplicados | `apply_auth_email_config.ps1` com PAT | Auth | Agente | Sim | e-mail PT/EN/ES recebido |
| 5 | Mercado Pago: titularidade das credenciais `unassigned`, app e webhook | não confirmado | confirmar conta/aplicativo; webhook `…/mp-webhook` | mercadopago.com.br; cofre | Dono | Sim | checkout de teste gera entitlement |
| 6 | Apple: contratos, bancário/fiscal, produtos, chave IAP | não confirmado | concluir no App Store Connect | App Store Connect | Dono | Sim | produtos aprovados; `payments-apple` valida JWS |
| 7 | Google Play: conta de pagamentos, assinatura `aprovaura_premium`, service account, Pub/Sub | não confirmado | concluir no Play Console | Play Console / GCP | Dono | Sim | compra de teste licenciado gera entitlement |
| 8 | Documentos legais finais | minutas com `[PENDENTE-DONO]` | CNPJ, razão social, endereço, contato, DPO; **revisão de advogado** | `docs/legal/` | Dono + advogado | Sim | publicar via `publish_legal_version` |
| 9 | Idade mínima, menores, DPO/RIPD | análise pronta | decidir política | `IA_REDACAO_E_MENORES.md` | Dono + advogado | Sim | política publicada e refletida no app |
| 10 | Provedor de IA (sair da camada gratuita) | Gemini gratuito | escolher provedor/custo; ou manter suspenso | `IA_REDACAO_E_MENORES.md` | Dono | Sim (para menores/lançamento) | teste cego com redações sintéticas |
| 11 | Conta de revisão das lojas | não criada | agente cria; dono guarda a senha | lojas | Dono | Sim | revisor entra e vê o app completo |
| 12 | Envio às lojas (Android/iOS) | AAB 1.1.0+8 compilado (não enviado); iOS sem Mac | certificados/assinatura, classificação etária, Data Safety/App Privacy, screenshots com dados demo | Play Console / Xcode | Dono | Sim | versões aprovadas |
| 13 | `site_url` e redirects do Auth, publicação da web e do site comercial | não confirmados | conferir/publicar com autorização final | Auth › URL Configuration; Cloudflare | Dono | Sim | URLs respondem; links de e-mail abrem |
| 14 | Amostras reais de relatórios (Apple, Google, MP) | formatos não validados | baixar um relatório de cada | consoles | Dono | Sim (conciliação) | importar sem divergência inexplicada |
| 15 | Cron de conciliação e `CRON_SECRET` | agendador não criado | definir segredo e agendar | Supabase/GitHub | Agente (após item 2) | Sim | execuções registradas |
| 16 | Storage/Realtime e backups do banco | não conferidos no painel | verificar buckets, Realtime e PITR | Dashboard | Dono | Não (recomendado) | sem bucket público; backup recente |
| 17 | Decisão final de ativação (passos 14 a 18) | NO-GO | autorizar ativação comercial, e-mail obrigatório e `min_version_*` | `PLANO_ATIVACAO_COMERCIAL.md` | Dono | Sim | passo a passo do plano |

Mantidos desligados nesta etapa: monetização (`enforcement_enabled`), confirmação obrigatória de e-mail, provedores de pagamento, `AUTO_DEPLOY`.
