# Pendências do dono: lista única e consolidada

> Classificação completa por área (concluída/implementada/parcial/não implementada/dependente do dono/bloqueadora) e o que falta para ir ao ar: `docs/release/AUDITORIA_LANCAMENTO_COMERCIAL.md` (26/11/2026).

Cada item: **Estado atual / Falta / Onde / Quem / Bloqueia lançamento? / Como validar.** Detalhe completo por serviço: `docs/release/PENDENCIAS_EXTERNAS.md`. Nenhum valor de credencial aqui.

Auditoria do cofre (Etapa 10C): para o AprovaAura existem apenas `supabase.aprovaura.*` (secret e publishable) e `postgres.aprovaura.production.db-url`. **Não há** no cofre: PAT do Supabase para este projeto, Apple, Google, Cloudflare/GitHub para o AprovaAura. Resend e Mercado Pago estão `unassigned` (não usados até confirmação de titularidade).

## Ações que realmente dependem do dono (27/11/2026)
| # | Ação | Onde | Por quê | Custo | Bloqueia? |
|---|---|---|---|---|---|
| A | Informar o **endereço** do responsável e decidir **idade mínima**; opcionalmente 1 consulta jurídica sobre menores/IA/Termos | repasse ao agente; advogado | Termos/Política exigem endereço (Decreto 7.962); menores/ECA Digital é análise jurídica | consulta pontual (opcional) | Sim (Termos) |
| B | **Mercado Pago:** decidir a aplicação de produção (reutilizar "Lucksrei - Payhip" isolando por `external_reference`, ou criar outra), copiar o segredo do webhook de produção para o cofre e **autorizar 1 Pix real de valor mínimo** | https://www.mercadopago.com.br/developers/panel/app | só o dono vê o segredo; Pix real não é testável no sandbox | taxa do MP sobre o valor mínimo | Sim, se a Web for o canal |
| C | **Apple:** preencher localização/imagem/captura do grupo, nível dos produtos, backup do `.p8`, e enviar uma **nova versão com as assinaturas** à revisão | https://appstoreconnect.apple.com/apps/6817047910 | primeira assinatura só vai com nova versão | R$ 0 | Sim (iOS) |
| D | **Google Play:** ativar os base plans, decidir **não usar RTDN** (a conciliação periódica cobre) e fazer 1 compra de teste com 2ª conta | https://play.google.com/console | produto está em rascunho | R$ 0 | Sim (Android) |
| E | **Lojas:** criar senha da conta de revisão, Data Safety, App Privacy, classificação etária, screenshots, e **autorizar o envio** das versões | App Store Connect e Play Console | exigência de publicação | R$ 0 | Sim |
| F | **Resend:** conferir o e-mail de cadastro na caixa de entrada; decidir plano pago se passar de ~60 cadastros/dia | https://resend.com/domains | cota grátis de 100/dia é da Lucksrei também | grátis; pago se crescer | Só para ligar a confirmação |
| G | **Cloudflare:** confirmar plano Free e se o `studio-worker` do Beard divide o Workers AI; abrir o painel (Portal → Correção por IA) logado | https://dash.cloudflare.com/?to=/:account/workers/ai | o token do agente não lê o plano | R$ 0 | Só a correção por IA |
| H | **Autorizar** (na ativação) criar `pg_cron`/`pg_net` e o agendamento da conciliação, e desligar `apple/sandbox` | resposta ao agente | extensões em produção exigem autorização | R$ 0 | Sim (conciliação) |
| I | Baixar 1 relatório de liberações do Mercado Pago (qualquer período com venda) e entregar ao agente | https://www.mercadopago.com.br/balance/reports | validar o importador sem inventar formato | R$ 0 | Só o 1º repasse |
| J | **Decisão final de ativação** (`enforcement_enabled`, e-mail obrigatório, `min_version_*`) | resposta ao agente | passos 14–18 do plano | R$ 0 | Sim |

| # | Item | Estado atual | Falta | Onde | Quem | Bloqueia? | Como validar |
|---|---|---|---|---|---|---|---|
| 1 | PAT do Supabase | **FEITO (24/11)**: no cofre (`supabase.aprovaura.production.pat`), restrito ao projeto `cesuqfgrtcitatxvokez` | nada | cofre | — | Não | lista só o projeto aura; org retorna 403 |
| 2 | Publicar Edge Functions | **FEITO (24/11)**: 7 publicadas (`evaluate-essay` v18 com interruptor + 6 de pagamento/provisão); falha fechada 19/19 | só os Secrets de cada provedor na ativação (`SUPABASE_AUDITORIA.md` §4) | CLI | Dono (valores) | Não | `tool/qa/edge_smoke.py` |
| 3 | Resend: confirmar domínio e titularidade da chave `unassigned` | **SMTP e templates aplicados (24/11)**; `lucksrei.com` verificado por envio; chave só de envio. Resta: conferir no painel a titularidade e ver um e-mail renderizado | verificar SPF/DKIM; autorizar chave para o AprovaAura | resend.com; cofre | Dono | Sim | status `verified`; envio de teste |
| 4 | Templates e SMTP no Auth | prontos, não aplicados | `apply_auth_email_config.ps1` com PAT | Auth | Agente | Sim | e-mail PT/EN/ES recebido |
| 5 | Mercado Pago: homologação sandbox | **cartão recorrente mensal/anual, webhook com HMAC, entitlement e isolamento homologados em sandbox real** (app AprovaAura Sandbox, vendedor/comprador de teste). **Pix e reembolso: 401 do MP no sandbox, só validados em mocks.** Estado seguro restaurado | decidir a conta/app de PRODUÇÃO do AprovaAura (hoje só a app Lucksrei - Payhip); abrir chamado no MP sobre o 401 de Pix/reembolso no sandbox; autorizar Pix real de valor mínimo quando for ativar | mercadopago.com.br/developers | Dono | Sim | `docs/qa/MERCADOPAGO_HOMOLOGACAO.md` §11 |
| 6 | Apple: contratos, bancário/fiscal, produtos, chave IAP | **parcial (25/11)**: contratos/banco/fiscal ativos; grupo + mensal R$ 19,90 e anual **R$ 189,90** (ponto de preço; R$ 190,00 não existe) criados, BR, PT/EN/ES, sem submeter; chave IAP e Secrets feitos; notificação V2 só Sandbox (teste oficial OK); compra/renovação/cancelamento/troca homologadas no Sandbox | backup do `.p8`; nível dos produtos e carência; Small Business Program; localização do grupo, imagem e captura de revisão; primeira assinatura **com nova versão**; relatórios financeiros reais | App Store Connect | Dono | Sim | `docs/qa/APPLE_STOREKIT_HOMOLOGACAO.md` |
| 7 | Google Play: conta de pagamentos, assinatura `aprovaura_premium`, service account, Pub/Sub | não confirmado | concluir no Play Console | Play Console / GCP | Dono | Sim | compra de teste licenciado gera entitlement |
| 8 | Documentos legais finais | minutas com `[PENDENTE-DONO]` | CNPJ, razão social, endereço, contato, DPO; **revisão de advogado** | `docs/legal/` | Dono + advogado | Sim | publicar via `publish_legal_version` |
| 9 | Idade mínima, menores, DPO/RIPD | análise pronta | decidir política | `IA_REDACAO_E_MENORES.md` | Dono + advogado | Sim | política publicada e refletida no app |
| 10 | Provedor de IA da correção de redação | **Homologado tecnicamente em 26/11 (Groq A + Cloudflare B, fallback e breaker com chamadas reais, R$ 0,00), NÃO ativado**: migration aplicada, função implantada, Secrets definidos, provedores desligados, `ESSAY_AI_PROVIDER=disabled`; app NÃO restrito a 18+; 3 correções/dia | parecer jurídico sobre menores e termos (Groq DPA/Cloudflare); confirmar plano Free da conta Cloudflare **e se o `studio-worker` do Beard divide a mesma cota de 10 mil neurons/dia** (token atual não lê o plano); abrir o painel logado (Portal → Correção por IA) e validar; ligar os provedores e `ESSAY_AI_PROVIDER=multi`; PDF dos professores só com disponibilidade pública | `IA_CORRECAO_MULTIPROVEDOR.md` | Dono | Não (o app funciona sem a correção por IA) | — |
| 11 | Conta de revisão das lojas | não criada | agente cria; dono guarda a senha | lojas | Dono | Sim | revisor entra e vê o app completo |
| 12 | Envio às lojas (Android/iOS) | AAB 1.1.0+8 compilado (não enviado); iOS compila no Mac (Flutter 3.47.4/Xcode 27.2); 1.1.0 já aguarda revisão na App Store (anterior a este serviço) | certificados/assinatura, classificação etária, Data Safety/App Privacy, screenshots com dados demo | Play Console / Xcode | Dono | Sim | versões aprovadas |
| 13 | `site_url` e redirects do Auth | **conferido (24/11)**: `site_url` e allow-list coerentes com a Web (app usa código, sem deep link); publicação da web e do site comercial seguem fora | senha mínima 8 e SSL enforcement **aplicados (24/11)**; HIBP exige plano pago | Auth; Cloudflare | Dono | Não | `SUPABASE_AUDITORIA.md` §2 |
| 14 | Amostras reais de relatórios (Apple, Google, MP) | formatos não validados | baixar um relatório de cada | consoles | Dono | Sim (conciliação) | importar sem divergência inexplicada |
| 15 | Cron de conciliação e `CRON_SECRET` | **viável sem custo** (`pg_cron`+`pg_net`); não criado de propósito (0 assinaturas, provedores desligados) | agendar só na ativação, com o procedimento de `SUPABASE_AUDITORIA.md` §6 | Supabase | Agente | Só na ativação | execuções registradas |
| 16 | Storage/Realtime e backups do banco | **conferido (24/11)**: 0 buckets, 0 tabelas no Realtime, RLS em todas as tabelas; PITR desligado (pago); SSL enforcement **ligado (24/11)** | decidir PITR | Dashboard | Dono | Não | `SUPABASE_AUDITORIA.md` §3 |
| 17 | Decisão final de ativação (passos 14 a 18) | NO-GO | autorizar ativação comercial, e-mail obrigatório e `min_version_*` | `PLANO_ATIVACAO_COMERCIAL.md` | Dono | Sim | passo a passo do plano |

Mantidos desligados nesta etapa: monetização (`enforcement_enabled`), confirmação obrigatória de e-mail, provedores de pagamento, `AUTO_DEPLOY`.
| 6 | Google Play Billing | **parcial**: produto `aprovaura_premium` (monthly/annual, rascunho), SA ativa, secrets no Supabase, testador licenciado. Sem RTDN (Cloud `billingEnabled=false` mesmo após pré-pagamento de R$ 30; Pub/Sub pendente, **sem pagamento adicional**). Compras de teste reais homologadas no emulador (mensal, anual, recusa, renovação, cancelamento, expiração, restauração, estorno) — ver seção 9; fechamento em seção 10 (carência, retenção, recuperação, reinstalação, restaurar corrigido); faltam RTDN, 2ª conta de teste e reinstalação com dados limpos | entrar com a conta de teste no emulador (Play Store) ou aparelho; aguardar crédito do Cloud (até 24h); decidir sobre R$ 30 se não liberar | Emulador/Play Console/Google Cloud | Dono | Sim | `docs/qa/GOOGLE_PLAY_HOMOLOGACAO.md` |

## Melhorias planejadas (depois da homologação manual; NÃO implementar antes)
Registrado em 27/11/2026. Não altera o fluxo de testes atual nem abre sprint. Fica **depois da homologação manual** e **antes de fechar a experiência comercial de cadastro**. Não renumera o roadmap oficial de dez etapas.

### F1. Login social (Google e Apple) e identificação do professor indicador
1. **Cadastro e login com Google e Apple**
   - Criar conta e entrar com Google e com Apple, integrados ao Auth existente.
   - Conta e progresso preservados qualquer que seja o método de login.
   - Sem duplicidade quando o mesmo e-mail já existir (vincular a identidade à conta existente).
2. **Pergunta no primeiro acesso à Home** (só se ainda não houver indicação registrada): BottomSheet "Você foi indicado por algum professor?"
   - **Sim, fui indicado:** lista pesquisável de professores parceiros ativos; o aluno escolhe quem indicou.
   - **Não fui indicado:** registra que o cadastro não tem indicação e segue normalmente.
   - Visual simples, bonito e na identidade do AprovaAura.
3. **Regras**
   - Perguntar **uma única vez**; nunca se a indicação já veio por link.
   - Escolha do professor grava o vínculo no backend, preservando as regras de indicação, comissões e proteção contra alteração indevida.
   - Sem autovinculação nem indicação inválida.
   - E-mail não confirmado: o vínculo só vale após a confirmação (regra atual).
   - Escolher professor **nunca é obrigatório** para usar o app.
4. **Execução:** somente após o dono concluir a homologação manual e autorizar.
