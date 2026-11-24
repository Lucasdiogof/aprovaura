# Pendências do dono: lista única e consolidada

Cada item: **Estado atual / Falta / Onde / Quem / Bloqueia lançamento? / Como validar.** Detalhe completo por serviço: `docs/release/PENDENCIAS_EXTERNAS.md`. Nenhum valor de credencial aqui.

Auditoria do cofre (Etapa 10C): para o AprovaAura existem apenas `supabase.aprovaura.*` (secret e publishable) e `postgres.aprovaura.production.db-url`. **Não há** no cofre: PAT do Supabase para este projeto, Apple, Google, Cloudflare/GitHub para o AprovaAura. Resend e Mercado Pago estão `unassigned` (não usados até confirmação de titularidade).

| # | Item | Estado atual | Falta | Onde | Quem | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|---|
| 1 | PAT do Supabase | **FEITO (24/11)**: no cofre (`supabase.aprovaura.production.pat`), restrito ao projeto `cesuqfgrtcitatxvokez` | nada | cofre | — | Não | lista só o projeto aura; org retorna 403 |
| 2 | Publicar Edge Functions | **FEITO (24/11)**: 7 publicadas (`evaluate-essay` v18 com interruptor + 6 de pagamento/provisão); falha fechada 19/19 | só os Secrets de cada provedor na ativação (`SUPABASE_AUDITORIA.md` §4) | CLI | Dono (valores) | Não | `tool/qa/edge_smoke.py` |
| 3 | Resend: confirmar domínio e titularidade da chave `unassigned` | **SMTP e templates aplicados (24/11)**; `lucksrei.com` verificado por envio; chave só de envio. Resta: conferir no painel a titularidade e ver um e-mail renderizado | verificar SPF/DKIM; autorizar chave para o AprovaAura | resend.com; cofre | Dono | Sim | status `verified`; envio de teste |
| 4 | Templates e SMTP no Auth | prontos, não aplicados | `apply_auth_email_config.ps1` com PAT | Auth | Agente | Sim | e-mail PT/EN/ES recebido |
| 5 | Mercado Pago: titularidade das credenciais `unassigned`, app e webhook | não confirmado | confirmar conta/aplicativo; webhook `…/mp-webhook` | mercadopago.com.br; cofre | Dono | Sim | checkout de teste gera entitlement |
| 6 | Apple: contratos, bancário/fiscal, produtos, chave IAP | não confirmado | concluir no App Store Connect | App Store Connect | Dono | Sim | produtos aprovados; `payments-apple` valida JWS |
| 7 | Google Play: conta de pagamentos, assinatura `aprovaura_premium`, service account, Pub/Sub | não confirmado | concluir no Play Console | Play Console / GCP | Dono | Sim | compra de teste licenciado gera entitlement |
| 8 | Documentos legais finais | minutas com `[PENDENTE-DONO]` | CNPJ, razão social, endereço, contato, DPO; **revisão de advogado** | `docs/legal/` | Dono + advogado | Sim | publicar via `publish_legal_version` |
| 9 | Idade mínima, menores, DPO/RIPD | análise pronta | decidir política | `IA_REDACAO_E_MENORES.md` | Dono + advogado | Sim | política publicada e refletida no app |
| 10 | Provedor de IA da correção de redação | **suspensa** (`ESSAY_AI_PROVIDER=disabled`); Gemini descartado (vedado a menores). **OpenAI avaliada (24/11), nada contratado**: viável tecnicamente e, com modelo econômico, financeiramente; qualidade não testada; menores dependem de parecer jurídico | decidir: (a) autorizar conta própria da OpenAI com limite de gasto e a bateria de ≈ US$ 6,47; (b) regra por faixa etária (sem IA para <13 e desconhecida); (c) parecer jurídico sobre adolescentes e transferência internacional | `IA_OPENAI_AVALIACAO.md` §11 | Dono + advogado | Sim (para reativar) | bateria aprovada pelos critérios da §8 |
| 11 | Conta de revisão das lojas | não criada | agente cria; dono guarda a senha | lojas | Dono | Sim | revisor entra e vê o app completo |
| 12 | Envio às lojas (Android/iOS) | AAB 1.1.0+8 compilado (não enviado); iOS sem Mac | certificados/assinatura, classificação etária, Data Safety/App Privacy, screenshots com dados demo | Play Console / Xcode | Dono | Sim | versões aprovadas |
| 13 | `site_url` e redirects do Auth | **conferido (24/11)**: `site_url` e allow-list coerentes com a Web (app usa código, sem deep link); publicação da web e do site comercial seguem fora | senha mínima 8 e SSL enforcement **aplicados (24/11)**; HIBP exige plano pago | Auth; Cloudflare | Dono | Não | `SUPABASE_AUDITORIA.md` §2 |
| 14 | Amostras reais de relatórios (Apple, Google, MP) | formatos não validados | baixar um relatório de cada | consoles | Dono | Sim (conciliação) | importar sem divergência inexplicada |
| 15 | Cron de conciliação e `CRON_SECRET` | **viável sem custo** (`pg_cron`+`pg_net`); não criado de propósito (0 assinaturas, provedores desligados) | agendar só na ativação, com o procedimento de `SUPABASE_AUDITORIA.md` §6 | Supabase | Agente | Só na ativação | execuções registradas |
| 16 | Storage/Realtime e backups do banco | **conferido (24/11)**: 0 buckets, 0 tabelas no Realtime, RLS em todas as tabelas; PITR desligado (pago); SSL enforcement **ligado (24/11)** | decidir PITR | Dashboard | Dono | Não | `SUPABASE_AUDITORIA.md` §3 |
| 17 | Decisão final de ativação (passos 14 a 18) | NO-GO | autorizar ativação comercial, e-mail obrigatório e `min_version_*` | `PLANO_ATIVACAO_COMERCIAL.md` | Dono | Sim | passo a passo do plano |

Mantidos desligados nesta etapa: monetização (`enforcement_enabled`), confirmação obrigatória de e-mail, provedores de pagamento, `AUTO_DEPLOY`.
