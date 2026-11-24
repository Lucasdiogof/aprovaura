# Matriz de dados e privacidade (AprovaAura)

> Data-base: 24/11/2026. Base: migrations de `supabase/migrations/` (0100 a 20261201000200), `supabase/functions/`, `FATOS_ETAPA09.md` e `PREMIUM_PARTNERS.md`. Rascunho técnico para o RIPD e para advogado: NÃO é parecer jurídico.
> Legenda: **V** = verificado no código/migration; **NV** = não verificado (precisa conferir antes de afirmar publicamente); **[PENDENTE-DONO]** = decisão do dono/jurídico. Bases legais abaixo são PROPOSTAS (LGPD art. 7º/14) a validar com advogado, não afirmações finais.
> Controlador: Lucas Diogo Franca (marca Lucksrei), CNPJ 54.868.173/0001-55, endereço [PENDENTE-DONO: endereço]; encarregado: o próprio controlador, via marketing@lucksrei.com (dispensa a confirmar com advogado).

## Operadores e destinos
| Operador | Papel | Dados | País/região |
|---|---|---|---|
| Supabase | Banco, Auth, Edge Functions, Storage | Todos os dados da conta e de uso (abaixo) | NV (região do projeto) |
| Cloudflare | Hospedagem web/Worker, entrega | Registros de acesso (IP, requisição) | NV |
| Google Gemini | Avaliação de redações | Tema, textos de apoio, texto da redação, critérios — SEM identificadores (V). Camada gratuita; **envio suspenso** (`ESSAY_AI_PROVIDER=disabled`): hoje nenhum dado de redação sai para o Google | Qualquer país onde o Google opere (camada paga) |
| Resend | E-mail transacional (configurado em 24/11, remetente no-reply@lucksrei.com, chave só de envio) | E-mail do usuário, código de confirmação | NV |
| Apple / Google Play | Cobrança in-app | O app não vê cartão; recebe ids de transação (V) | — |
| Mercado Pago | Cobrança web | Sem PAN/CVV no app (V); `external_reference` opaco | — |

## Matriz
Colunas: Dado | Finalidade | Base legal (proposta) | Operador | Retenção | Exclusão | Menores. Verificação entre parênteses.

| Dado | Finalidade | Base legal (proposta) | Operador | Retenção | Exclusão | Menores |
|---|---|---|---|---|---|---|
| E-mail, senha (hash), id de conta (`auth.users`) (V) | Autenticação e conta | Execução de contrato / procedimentos preliminares | Supabase | Enquanto a conta existir | Exclusão de conta (`delete-account`) apaga a conta (V) | Faixa etária declarada; idade mínima [PENDENTE-DONO] |
| Perfil: nome, username, preferências, idioma (V) | Operação do app | Contrato | Supabase | Enquanto a conta existir | Apagado na exclusão (V, via cascata; escopo exato NV) | Idem |
| Faixa etária (`user_age_declarations`: under_13, 13_15, 16_17, adult; sem data de nascimento) (V) | Proteção de menores e trava do compartilhamento | Obrigação legal / melhor interesse (ECA Digital, LGPD art. 14) | Supabase | Enquanto a conta existir | Na exclusão (NV tabela/cascata) | Núcleo da regra: só `adult` pode compartilhar estatísticas; autodeclaração é limitada [INCERTO] |
| Prova de e-mail (`email_verifications`: origem, data) (V) | Segurança, trial, papéis | Legítimo interesse / contrato | Supabase | Enquanto a conta existir | Na exclusão (NV) | — |
| `trial_grants` (hash do e-mail normalizado) (V) | Impedir novo teste por pessoa | Legítimo interesse (antifraude) | Supabase | **Sobrevive à exclusão da conta** (sem FK) — decisão a validar [PENDENTE-DONO] | Não apagado com a conta | Idem; informar no texto de privacidade |
| Progresso de estudo, respostas, XP, streak, favoritos, simulados (V) | Funcionalidade principal | Contrato | Supabase | Enquanto a conta existir | Apagado na exclusão (NV por tabela) | Dados do menor sujeitos ao melhor interesse |
| Redações (texto) e correções (V) | Correção por IA e histórico | Contrato; consentimento ao enviar à IA [PENDENTE-DONO] | Supabase; Google Gemini | Enquanto a conta existir; no Gemini: camada gratuita sem prazo informado, paga: logs por período limitado [INCERTO] | Apagado no banco; cópia no Google não controlável | **Envio à IA suspenso** (decisão do dono 24/11): termos do Gemini exigem 18+ e o app atende adolescentes; sem IA paga |
| `user_activity` (última atividade, plataforma, sem geolocalização) (V) | Suporte e métricas do portal | Legítimo interesse | Supabase | Enquanto a conta existir | Na exclusão (NV) | — |
| Aceites de documentos (`legal_acceptances`: versão, origem, data) (V) | Prova de aceite | Obrigação legal / exercício de direitos | Supabase | NV (imutável por desenho; tratamento na exclusão a validar) | NV | — |
| Consentimento de compartilhamento (`study_sharing_consents`, histórico imutável) (V) | Dar a professor vinculado estatísticas de desempenho | Consentimento (revogável) | Supabase | Histórico preservado como registro | NV na exclusão | Só `adult` compartilha; menor/desconhecido nunca (V) |
| Vínculo com professor (`partner_links`, `partner_link_history`) (V) | Programa de parceria e comissão | Execução de contrato (comercial) | Supabase | Preservado como história contábil | Na exclusão do aluno: NV (histórico pode permanecer sem identificação) | Modelo para menores [PENDENTE-DONO] |
| Estatísticas mostradas ao professor (V) | Acompanhamento do aluno | Consentimento | Supabase | Não armazenadas à parte (derivadas) | Revogar bloqueia na hora; comissões ficam | Agregados só com ≥ 5 alunos que compartilham (V) |
| Entitlements e eventos (`entitlements`, `entitlement_events`, `payment_events`) (V) | Acesso Premium | Contrato | Supabase | Histórico imutável; payload bruto não guardado em eventos (V) | NV | Pagamento por menor: [PENDENTE-DONO] |
| Pagamentos (`payments`): valores, ids de transação, datas; sem cartão (V) | Cobrança, comissão, contabilidade | Obrigação legal/fiscal; contrato | Supabase; Apple/Google/MP | Retenção fiscal geralmente 5 anos [INCERTO — contador]; `payments.raw` minimizado ao excluir a conta, `user_id` vira referência opaca (V §19.7) | Valores/datas ficam (obrigação contábil) | — |
| Token de compra opaco (`purchase_account_tokens`) (V) | Associar compra à conta | Contrato | Supabase | Enquanto a conta existir | NV | — |
| Parceiros: nome de divulgação, código, chave Pix, percentual (V) | Pagar comissão | Contrato | Supabase | Chave Pix apagada na anonimização da parceria (V §19.7) | Parceria encerrada e anonimizada ("Professor removido"); razão preservado | — (professores adultos; confirmar) |
| Razão de comissão, repasses (V) | Contabilidade | Obrigação legal | Supabase | Preservado (5 anos [INCERTO]) | Não apagado | — |
| Auditoria admin (`admin_audit_log`) (V) | Segurança e prestação de contas | Legítimo interesse / obrigação | Supabase | Append-only; sem segredos (`_scrub`) | Não editável | — |
| Despesas e importações de relatório financeiro (V) | Gestão financeira | Legítimo interesse | Supabase | Preservado | — | — |
| Registros de acesso (IP, user-agent) (NV) | Segurança; Marco Civil art. 15 (6 meses) | Obrigação legal | Cloudflare; Supabase | NV (6 meses mínimo, a confirmar onde ficam) | NV | — |
| E-mails transacionais (destinatário, conteúdo do código) (NV) | Confirmação/recuperação | Contrato | Resend | NV (prazo de logs do Resend) | NV | — |
| Armazenamento local (SharedPreferences: `intro_seen_v1`, confirmação pendente, `pending_referral_code`, último instante visto, autorização offline) (V) | Funcionamento/offline | Contrato | Dispositivo | Até limpar dados/desinstalar | Usuário | Não concede Premium |
| Conteúdo/Storage/Realtime (NV) | — | — | Supabase | — | — | Conferir no painel que não há buckets/realtime com dado pessoal |

## Lacunas a fechar antes do lançamento
1. Tabela por tabela, confirmar o que a Edge Function `delete-account` e as cascatas removem (NV acima) e produzir lista final para a Política e para o Data safety/App Privacy.
2. Região e retenção reais em Supabase, Cloudflare e Resend (NV).
3. Decidir retenção do `trial_grants` após exclusão e declarar na Política [PENDENTE-DONO].
4. Gemini: integração mantida, envio suspenso; só reativar com solução compatível com termos do provedor e com adolescentes (decisão do dono 24/11; sem provedores pagos; IA só para redação, 3/dia, sem chatbot).
5. Idade mínima, base legal professor/menores, RIPD, revisão de advogado [PENDENTE-DONO].
6. Retenção fiscal: confirmar com contador [INCERTO].
