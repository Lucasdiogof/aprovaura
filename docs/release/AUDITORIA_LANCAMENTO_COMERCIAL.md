# Auditoria consolidada do roadmap para o lançamento comercial: AprovaAura

> Data-base: 26/11/2026. Escopo: só o app AprovaAura (Android, iOS, Web, portais). Fora de escopo: PDF comercial, anúncios, prospecção de professores.
> Fontes: `docs/qa/PENDENCIAS_DO_DONO.md`, `docs/release/*`, `docs/PREMIUM_PARTNERS.md`, `docs/qa/*_HOMOLOGACAO.md`, `docs/finance/RECONCILIATION.md` e **leitura direta de produção em 26/11** (somente leitura).
> Nenhum valor de credencial neste arquivo.

## Estado de produção verificado hoje (somente leitura)
| Fato | Valor |
|---|---|
| `commercial_config.enforcement_enabled` | **false** (monetização desligada) |
| `email_verification_required` / `mailer_autoconfirm` | **false / true** (confirmação de e-mail NÃO obrigatória) |
| `payment_providers_config` | apple/sandbox **ligado**; apple/produção, google (ambos) e mercadopago (ambos) **desligados** |
| SMTP do Auth | Resend (`smtp.resend.com`, remetente AprovaAura); senha mínima 8; `site_url` = web do app; limite 15 e-mails/h |
| Edge Functions | 8 ativas: evaluate-essay v36, delete-account, mp-checkout, mp-webhook, payments-reconcile, payments-apple, payments-google, admin-provision-partner |
| Dados | 12 usuários, 5 assinaturas de provedor (todas de teste), **0 pagamentos**, 1 admin, **0 professores parceiros** |
| Correção de redação por IA | provedores `enabled=false`, `ESSAY_AI_PROVIDER=disabled` (suspensa) |

Legenda: **C** Concluída e homologada · **I** Implementada, não homologada · **P** Parcialmente implementada · **N** Não implementada · **D** Depende de ação do dono · **B** Bloqueia o lançamento. Um item pode ter mais de um rótulo (ex.: P + D + B).

## 1. Correção de redação por IA (etapa encerrada tecnicamente)
| Item | Rótulo | Evidência / o que falta |
|---|---|---|
| Groq (A) + Cloudflare (B), fallback silencioso, breaker, 3/dia por usuário, 5 competências | **C** | chamadas reais, 66 testes Deno, e2e com redações sintéticas (`IA_CORRECAO_MULTIPROVEDOR.md`) |
| Matriz ENEM 2026 (fuga zera, tangência limita C2/C3/C5 a 40, múltiplos de 40) e prompt anti-manipulação independente | **C** | testes + comparação real |
| Textos PT/EN/ES (84 chaves exaustivas) e estados carregando/sucesso/falha/limite diário | **C** | testes de widget e cubit (166) |
| Aviso "estimativa de treino, não é a nota oficial; ENEM oficial exige português" nos 3 idiomas | **I** | no código desta entrega; só chega ao aluno em nova versão do app |
| Painel admin "Correção por IA" | **I** | 4 testes de widget + renders visuais + RPCs com 401/403 em produção; **nunca aberto logado** (a criação de admin de teste em produção foi negada e não foi contornada) |
| Plano Free da conta Cloudflare e consumo compartilhado (10 mil neurons/dia na conta toda) | **D** | token limitado não lê plano (403). O `studio-worker` do Beard usa Workers AI e pode dividir a mesma cota; teto interno do AprovaAura = 6 mil neurons. Estouro = erro, não cobrança, mas pode derrubar o Plano B |
| Parecer sobre menores + termos Groq (DPA) e Cloudflare | **D + B** (para ligar a IA a alunos reais) | `IA_REDACAO_E_MENORES.md`; app não restrito a 18+ |
| Ligar provedores no painel e `ESSAY_AI_PROVIDER=multi` | **D** | não bloqueia o lançamento: sem IA o app funciona e a redação fica salva |
| Redação em outro idioma | **C** (decisão pedagógica) | pontua como prática; a nota diz que o ENEM oficial exige português |

**Condições para a correção chegar a alunos reais:** (1) dono confirma plano Free e consumo compartilhado no painel Cloudflare; (2) dono abre Portal → Correção por IA logado e valida; (3) parecer jurídico sobre menores e termos dos dois provedores; (4) nova versão do app com o aviso e o texto único de erro (hoje o texto antigo ainda funciona); (5) dono liga os provedores e a chave global. Capacidade medida: cerca de 86 correções/dia (28 alunos com 3/dia) a R$ 0,00.

## 2. Plataformas e publicação
| Item | Rótulo | Estado |
|---|---|---|
| Android 1.1.0+8 | **C** (publicado) | em produção desde 25/11; **sem assinatura ativa** (base plans em rascunho) |
| Android versão posterior à 1.1.0+8 (pubspec em 1.2.0+11: paywall, portais, aviso de IA) | **N** (envio) **+ D + B** | não consta envio nos docs; exige autorização expressa |
| iOS 1.1.0 | **D** | aguardando revisão da App Store; primeira assinatura precisa ir **com nova versão** |
| iOS nova versão com assinaturas | **D + B** | submissão de produtos + versão junto |
| Web (app e portais) | **C** (no ar) | `aprovaura.lucksrei.com`; deploy automático (`AUTO_DEPLOY`) desligado de propósito |
| Conta de revisão das lojas | **N + D + B** | agente cria, dono guarda a senha |
| Classificação etária, Data Safety, App Privacy, screenshots com dados demo | **D + B** | `docs/store-listings`, `docs/screenshots` |
| `min_version_*` | **N** (de propósito) | definir só na ativação |

## 3. Assinaturas e pagamentos
| Item | Rótulo | Estado |
|---|---|---|
| Premium / entitlement único entre plataformas, trial 72 h, gate/paywall, versão mínima | **I** | testes Flutter (1215), SQL e QA visual; **nunca ativado** (`enforcement_enabled=false`) |
| **Apple StoreKit** | **P + D + B** | Sandbox **oficial** homologado: compra, renovação, troca de plano, cancelamento, restauração, notificações V2, isolamento; preço anual R$ 189,90 (R$ 190,00 não existe na Apple). Falta: URL de notificação de **produção**, envio da assinatura com nova versão, nível dos produtos, localização/imagem de revisão do grupo, backup do `.p8`, Small Business Program |
| **Google Play Billing** | **P + D + B** | compras reais de teste no emulador (mensal, anual, recusa, renovação, cancelamento, expiração, restauração, estorno). Falta: **RTDN/Pub/Sub** (Cloud sem faturamento ativo, sem pagamento adicional autorizado), ativar base plans, 2ª conta de teste, reinstalação limpa. Pode lançar sem RTDN apoiado só em verificação do app + conciliação (decisão do dono) |
| **Mercado Pago** | **P + D + B** | cartão recorrente mensal/anual, HMAC real, entitlement, idempotência, cancelamento e recusa homologados no sandbox real. **Pix e reembolso: 401 do sandbox, só em mocks/SQL.** Falta: credencial de produção própria do AprovaAura (hoje só a app "Lucksrei - Payhip"), segredo de webhook de produção, teste de Pix real de valor mínimo (autorização do dono), chamado ao MP sobre o 401 |
| Checkout hospedado do MP (retorno) | **I** | não exercitado fim a fim |

## 4. Financeiro e professores
| Item | Rótulo | Estado |
|---|---|---|
| Regras de comissão (50% do líquido, piso, bps histórico, anual integral, estorno, repasse idempotente, concorrência) | **C** | 83/83 SQL e 22/22 concorrência (`FINANCEIRO_HOMOLOGACAO.md`) |
| Conciliação e importação de relatórios (Apple/Google/MP) | **P + D + B** | lógica testada; **formatos nunca validados com relatório real**; Apple só confere totais; comissão estimada nunca vira repasse (regra preservada) |
| Cron de conciliação (`pg_cron`) | **N** (de propósito) + **B** | viável sem custo; criar só na ativação, com `CRON_SECRET` já existente |
| Repasse aos professores | **C** (processo) | manual por Pix dia 1º, registro no sistema; nenhum Pix enviado |
| Portal do professor | **I** | implementado e testado; **0 professores cadastrados**, nunca usado com dado real |
| Portal admin (Etapas 2.0–2.2) | **I** | no ar; MFA opcional; owners/admin criados; sem validação autenticada documentada nesta etapa |
| Cadastro com indicação de professor (código/link) | **I** | testado em unidade/SQL; sem professor real para ponta a ponta |

## 5. Conta, segurança, privacidade
| Item | Rótulo | Estado |
|---|---|---|
| Cadastro, login, recuperação de senha | **C** (fluxo atual) | testes + QA visual |
| **Confirmação de e-mail obrigatória** | **I + B** | código, templates PT/EN/ES e SMTP Resend aplicados; produção ainda `autoconfirm=true`. Falta: e-mail real recebido em Gmail/Apple Mail, titularidade da chave Resend, domínio `verified`, cota (plano grátis 100/dia compartilhado com a Lucksrei) |
| Rate limits de Auth recomendados | **P** | `rate_limit_email_sent=15`; restante proposto, não aplicado |
| Senha mínima 8, SSL enforcement, RLS em todas as tabelas, 0 buckets, Realtime vazio | **C** | `SUPABASE_AUDITORIA.md` |
| HIBP e PITR | **D** (pagos) | decisão de custo do dono; não bloqueia |
| Exclusão de conta no app | **C** | `delete-account` ativa |
| Termos, privacidade, política de menores/DPO/RIPD | **P + D + B** | minutas com `[PENDENTE-DONO]` (CNPJ, razão social, endereço, contato, DPO) e **revisão de advogado**; idade mínima e modelo para menores indefinidos |
| Compartilhamento com professor só para `adult` | **C** | regra no servidor |

## 6. Experiência
| Item | Rótulo | Estado |
|---|---|---|
| Offline e sincronização de leitura | **C** (leitura) | cache + timeout; conteúdo nunca aberto não existe offline (limite declarado); TTL offline configurável (168 h usuário, 24 h equipe) |
| Onboarding animado e apresentação | **I** | testes; checklist de QA em aparelho (PREMIUM_PARTNERS §14.8) não executado completo |
| Paywall (PT/EN/ES, claro) | **C** (visual) / **I** (comercial) | homologado no emulador com Play; aciona só com `enforcement_enabled` |
| Acessibilidade | **P** | semântica e fonte grande cobertas por testes pontuais; **sem auditoria completa com leitor de tela real** |
| Idiomas PT/EN/ES e temas claro/escuro | **C** | cobertura exaustiva nas telas novas; QA visual 10B em combinações selecionadas; telas Aura/metas/atualidades/mapas não cobertas por QA visual |

## 7. Operação
| Item | Rótulo | Estado |
|---|---|---|
| Plano de ativação em 20 passos e rollback | **C** (documento) | `PLANO_ATIVACAO_COMERCIAL.md`, `ATIVACAO_E_ROLLBACK.md`; **NO-GO** |
| Painel de métricas, auditoria, `emergency_disable` | **I** | no ar, sem uso real |
| CI | **P** | sem GitHub Actions; `verify-local` e testes locais (1215 Flutter) |

## O que falta, objetivamente, para o AprovaAura entrar no ar comercialmente
**Bloqueadores (todos dependem do dono, nenhum é de código):**
1. **Jurídico:** dados do responsável (CNPJ, razão social, endereço, contato, DPO), revisão de advogado, idade mínima/menores. Sem isso Termos e Privacidade não podem ser publicados.
2. **Pelo menos um canal de pagamento completo.** Menor caminho: **Mercado Pago na Web** (credencial de produção do AprovaAura + segredo de webhook + Pix real de valor mínimo) ou **Apple** (URL de produção, nova versão com assinaturas enviada à revisão). Google Play exige ativar base plans e decidir sobre RTDN/faturamento Cloud.
3. **E-mail:** confirmar domínio/chave Resend e ver um e-mail real; só então ligar confirmação obrigatória.
4. **Lojas:** conta de revisão, classificação etária, Data Safety/App Privacy, screenshots, envio das versões (autorização expressa).
5. **Relatórios financeiros reais** (um de cada provedor) para validar a conciliação e **criar o cron na ativação**.
6. **Decisão de ativação** (`enforcement_enabled`, `email_verification_required`, `min_version_*`) seguindo `PLANO_ATIVACAO_COMERCIAL.md`.

**Não bloqueiam:** correção de redação por IA, PITR, HIBP, Small Business Program (recomendado), auditoria completa de acessibilidade (recomendada).

**Nada nesta auditoria foi alterado em produção.**
