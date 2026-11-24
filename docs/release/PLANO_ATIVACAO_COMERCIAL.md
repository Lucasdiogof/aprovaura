# Plano de ativação comercial — 20 passos

> Data-base: 24/11/2026. Base: `FATOS_ETAPA09.md`, `PREMIUM_PARTNERS.md` §9, §12, §13.9, §18.12, §19.12, `PENDENCIAS_EXTERNAS.md`.
> Regra geral: nada é ligado antes de a versão compatível estar aprovada e publicada. Credenciais: consultar `vault.ps1 find` antes de pedir ao dono. Sem segredos neste documento.
> Estado inicial: `enforcement_enabled`, confirmação obrigatória de e-mail, provedores de pagamento e `AUTO_DEPLOY` DESLIGADOS.

## Princípios da transição
1. **Como revisores avaliam sem cobrança pública antes da ativação:** o paywall é inerte enquanto `commercial_enforced() = false`, então a build enviada às lojas abre normalmente. Para a revisão, a conta de revisão (passo 11) tem Premium por cortesia (`admin_grant_premium`, sem comissão) ou usa a compra em ambiente sandbox/teste; produtos Apple/Google ficam em sandbox até a aprovação. Os provedores só recebem `enabled=true` em produção depois da aprovação. Notas de revisão descrevem o modelo: teste de 72 h após confirmar o e-mail, depois assinatura mensal/anual.
2. **Sem teste para usuários existentes:** usuário existente = `auth.users.created_at < commercial_config.launch_marker`. O marco é fixado na ativação; `maybe_grant_trial` só concede teste a contas criadas depois dele, com e-mail provado, uma vez por e-mail normalizado. Existentes veem o paywall com texto "novo modelo, histórico preservado, sem teste". Carência opcional via `legacy_grace_until` (decisão do dono).
3. **Contas e históricos preservados:** nada é apagado na ativação; quem não assina perde apenas o acesso até assinar. Exclusão de conta continua disponível sem assinatura.
4. **Primeira assinatura Apple:** a primeira assinatura (grupo + ≥1 assinatura) deve ser enviada JUNTO com uma NOVA versão do app. Depois de aprovada a primeira, as demais podem ir sem nova versão.
5. **Primeira assinatura Google:** assinatura `aprovaura_premium` com base plans `monthly`/`annual` criada no Play Console, com versão do app usando Play Billing Library 8 ou 9 enviada a uma faixa; testers de licença validam. Se o console exigir versão enviada antes de criar/ativar o produto [INCERTO — confirmar no Play Console], seguir essa ordem. A ativação comercial só ocorre após a versão nova estar disponível na produção.

## Os 20 passos
Formato: **Pré-requisitos | Responsável | Pronto quando | Rollback**.

**1. QA completo (Etapa 10).** Pré: código das Etapas 01–09 (escrito sem `flutter analyze`/testes). Resp.: agente. Pronto: `flutter analyze` limpo, suíte verde (inclui `gate_redirect_test`), checklists §12/§14.8/§16.8/§17.12/§19.11 executados com `enforcement` ligado apenas em ambiente de teste. Rollback: n/a (nada em produção).

**2. Correções.** Pré: achados do QA. Resp.: agente. Pronto: zero bloqueadores abertos; migrations novas só via `tool/db/apply_migration.py` (ensaio `dry`, depois `apply`). Rollback: `supabase/rollbacks/*.down.sql` (os de 0200/0300/0400 apagam dados: só antes de uso real).

**3. Credenciais.** Pré: `vault.ps1 find` por serviço/projeto/ambiente; PAT do Supabase; titularidade do Mercado Pago confirmada; decisões do dono (`PENDENCIAS_EXTERNAS.md` §0–§8). Resp.: dono (fornece/confirma) + agente (cadastra como Secrets). Pronto: todos os NOMES da seção 0 definidos; valores nunca impressos. Rollback: remover/rotacionar o secret afetado; provedor volta a `enabled=false`.

**4. Edge Functions.** Pré: passo 3. Resp.: agente com PAT. Pronto: `supabase/deploy_payments_functions.ps1` + `admin-provision-partner` publicadas; chamadas sem assinatura retornam 401/400; cron de `payments-reconcile` criado (a cada 6–12 h, `x-cron-secret`). Rollback: republicar versão anterior; desligar o cron.

**5. Produtos nos consoles.** Pré: contratos, bancário/fiscal, Paid Apps. Resp.: dono (agente prepara textos PT/EN/ES). Pronto: Apple `aprovaura_premium_monthly`/`_annual` em um grupo; Google `aprovaura_premium` + base plans; chaves/service account/Pub/Sub/Notifications V2 configurados; `payment_catalog.verified=true` somente após conferência. Rollback: `verified=false`; produto permanece sem uso.

**6. Compras sandbox.** Pré: passos 4–5; testers. Resp.: dono + agente. Pronto: compra Apple sandbox, Google (license tester) e Mercado Pago teste geram entitlement com ref `sandbox:`, SEM receita nem comissão; conflito de conta gera `payment_conflicts`. Rollback: revogar entitlements de teste (apenas cortesia é revogável pelo portal; sandbox expira).

**7. Validar renovação, cancelamento, restauração e reembolso.** Pré: passo 6. Resp.: dono + agente. Pronto: renovação acumula período; cancelar renovação mantém acesso até o fim; restaurar compras funciona (reinstalação/troca de aparelho); reembolso/chargeback revoga só a fonte do provedor; eventos duplicados/fora de ordem barrados; MP: Pix aprovado/expirado/estornado, cartão aprovado/recusado/cancelado. Rollback: provedor `enabled=false`; `admin_requeue_event` só para evento falho.

**8. Pagamentos web (Mercado Pago).** Pré: passos 3–4; credenciais de teste e produção; webhook `…/mp-webhook`. Resp.: dono + agente. Pronto: checkout teste (cartão recorrente e Pix avulso) libera acesso SÓ após webhook validado; retorno do checkout nunca libera Premium; MP ausente dos apps móveis. Rollback: `payment_providers_config.enabled=false` para o ambiente.

**9. Conciliação.** Pré: relatórios reais de amostra (Apple agregado, Google, MP) — ver `docs/finance/RECONCILIATION.md`. Resp.: dono (baixa relatórios) + admin no portal. Pronto: importação validada com cabeçalhos reais; taxas e impostos efetivos confirmados; comissão estimada nunca liberada. Rollback: não aplicar linhas; reabrir conciliação por ajuste auditado.

**10. Documentos legais.** Pré: dados do responsável (CNPJ, razão social, endereço, suporte, DPO); decisões de idade/menores; revisão de advogado; textos finais PT/EN/ES. Resp.: dono aprova; agente executa `publish_legal_version` (Termos e Política atualizada) NA ativação coordenada. Pronto: `get_legal_status` lista Termos e Privacidade vigentes; URLs do site respondem; Política não quebrada. Rollback: nova versão corretiva (`publish_legal_version`); o histórico de aceites é imutável.

**11. Conta de revisão.** Pré: passo 6. Resp.: agente cria; dono cola/guarda a senha (nunca em chat/arquivo). Pronto: conta com e-mail provado, Premium por cortesia (sem comissão), instruções para Apple (5.1.1) e Google; exclusão de conta no app funcional. Rollback: revogar a cortesia e excluir a conta.

**12. Envio às lojas.** Pré: passos 1–11; Xcode/SDK 26, target API 36, Billing ≥ 8; classificação etária (iOS web irrestrita → 16+); Data safety/App Privacy; notas de revisão (trial próprio de 72 h descrito). Resp.: dono envia (agente prepara build — builds só mediante pedido). Apple: nova versão com grupo + primeira assinatura. Google: versão na faixa de produção/teste conforme console. Pronto: submissões enviadas. Rollback: retirar da revisão.

**13. Aprovação.** Pré: passo 12. Resp.: Apple/Google. Pronto: versões aprovadas; produtos aprovados. Rollback: se rejeitado, corrigir e reenviar; modelo continua desligado.

**14. Disponibilidade das versões compatíveis.** Pré: passo 13. Resp.: dono libera. Pronto: versão nova (paywall + `/confirmar-email`) liberada e disponível na Play e na App Store (verificar nas lojas, não só "aprovada"). Rollback: pausar rollout (Play) / remover da venda não aplicável; modelo permanece desligado.

**15. Publicação web coordenada.** Pré: passos 1–10 concluídos; Cloudflare Workers Builds (Git) verificado/desligado; versão atual do Worker anotada. Resp.: agente com autorização do dono. Pronto: deploy manual por `workflow_dispatch`; `/partners`, `/privacidade`, `/email/aprovaura-mark.png` respondem; Auth `site_url` correto. `AUTO_DEPLOY=true` só no fim (passo 17). Rollback: promover a versão anterior do Worker.

**16. Ativação segura da confirmação de e-mail.** Pré: passos 14–15; `-Templates` e `-Smtp` aplicados; Resend verificado; e-mail real recebido PT/EN/ES (Gmail/Apple Mail); limites de taxa. Resp.: agente + dono autoriza. Pronto: `admin_update_commercial_config({"email_verification_required": true})`, depois `apply_auth_email_config.ps1 -Activate` (`mailer_autoconfirm=false`); testados cadastro novo, reenvio, código errado/expirado, "digitei o e-mail errado", login pendente, recuperação; usuários antigos: decidir `legacy_verification_deadline` e `require_email_reverification` por usuário (dados preservados). Rollback: `mailer_autoconfirm=true` no painel + `email_verification_required=false`.

**17. Ativação comercial.** Pré: passos 1–16, provedores liberados por ambiente (`payment_providers_config.enabled=true` só após `verified=true`), `emergency_disable` à mão. Resp.: dono autoriza; agente executa `admin_set_commercial_enforcement(true)` (fixa `launch_marker`). Em seguida `AUTO_DEPLOY=true`. Pronto: usuário novo recebe 72 h após confirmar e-mail; existente vê paywall sem teste; compra real de baixo valor validada fim a fim (entitlement + pagamento + comissão pendente de conciliação). Rollback: `admin_update_commercial_config({"emergency_disable": true})`; se necessário `alter role authenticator reset pgrst.db_pre_request; notify pgrst, 'reload config';`.

**18. Proteção das versões antigas (`min_version_*`).** Pré: passo 17 estável; versão compatível disponível nas 3 plataformas. Resp.: agente (`admin_update_commercial_config`) com autorização. Pronto: `min_version_android/ios/web` definidos; lembrar que `/atualizar` só existe em versões novas — a proteção real é o gate de servidor (402/403 em apps antigos). Só depois disso avaliar endurecer o gabarito (`check_answer`, retirar `correct_index`). Rollback: limpar os `min_version_*`.

**19. Monitoramento.** Pré: passo 17. Resp.: agente + dono. Pronto: acompanhar `payment_events` (falhas/tentativas), `payment_conflicts`, execuções do cron, logs das funções (só tipo/código), cadastros/e-mails (cota do Resend), cobranças a conciliar, tickets de suporte; janela inicial recomendada de 72 h de acompanhamento ativo. Rollback: ver passo 20.

**20. Rollback (plano geral).** Camadas, da mais leve à mais forte: (a) `emergency_disable=true` (reabre acesso a todos; vence `enforcement_enabled`); (b) `payment_providers_config.enabled=false` por provedor/ambiente; (c) `email_verification_required=false` + `mailer_autoconfirm=true`; (d) reset do gate (`alter role authenticator reset pgrst.db_pre_request`); (e) Worker anterior na Cloudflare; (f) `AUTO_DEPLOY=false`. Assinaturas já pagas permanecem válidas e comissões já registradas não são apagadas; reembolsos são tratados pela loja/MP. Pronto quando: acesso restabelecido e causa registrada.

## Ordem de dependências (resumo)
QA/correções (1–2) → credenciais e funções (3–4) → produtos e sandbox (5–7) → web e conciliação (8–9) → legal e conta de revisão (10–11) → lojas (12–14) → web + e-mail (15–16) → ativação (17) → proteção, monitoramento e rollback (18–20).
