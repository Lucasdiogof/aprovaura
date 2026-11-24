# Revisão técnica acumulada — Etapa 09 (por leitura de código; sem analyze/testes/builds)

## Corrigido nesta etapa
| Item | Correção |
|---|---|
| Autorização offline vs. erro 5xx | `access_repository_impl.dart`: falha de servidor/inesperada agora cai na MESMA verificação offline (assinatura JWS + validade). Um 5xx nunca prorroga acesso vencido. |
| Compartilhamento com professor | `_student_shares`/`set_study_sharing` passaram a exigir faixa etária `adult` registrada NO SERVIDOR; flags de menor/responsável vindas do cliente são ignoradas. Menor/desconhecido nunca compartilha; declarar-se menor encerra compartilhamento ativo. |
| Aceite legal | `record_legal_acceptance` ganhou plataforma; `get_legal_status` expõe vigência, idiomas e `requires_reaccept`; versão nova só vale após `effective_at`; aceites antigos são preservados. Rotas de documentos/aceite/idade ficam liberadas no gate para conta sem Premium. |
| Conciliação | Importação auditável, idempotente por hash do arquivo, nunca aplica divergência; aplicar é ato do admin. |
| Exclusão de conta × assinatura / financeiro / último admin (Etapa 08, migração 20261130000100) | Registros financeiros preservados e anonimizados; trigger impede remover o último admin. |

## Verificado e OK
- `pubspec.lock`: Dart `>=3.13.0`, Flutter `>=3.47.0`; CI fixa Flutter 3.50.1 (compatível). `in_app_purchase_android 0.5.5` traz **Play Billing Library 9.1.0** (versão 7 está vencida; 9 é aceita).
- Template de e-mail usa `{{ .SiteURL }}/email/aprovaura-mark.png` e o arquivo existe em `web/email/` (logo hospedada junto com o app web).

## Pendente / não verificável aqui (vai para PENDENCIAS_EXTERNAS.md)
- `supabase/config.toml` local usa `site_url = http://127.0.0.1:3000`: o **site_url de produção** (https://aprovaura.lucksrei.com) e as URLs de redirecionamento precisam ser conferidos no painel Supabase (links de e-mail, recuperação, indicação). Sem PAT/acesso ao painel nesta etapa.
- `targetSdk = flutter.targetSdkVersion`: confirmar que o Flutter 3.50.1 aponta para API 36 antes do envio ao Play (exigência desde 31/08/2026). Se não, fixar `targetSdk = 36` e testar.
- Deployment target iOS ≥ 13 e Xcode 26/SDK 26 para o envio à App Store: conferir em `ios/` e no Mac de build.
- Storage/Realtime: nenhuma política de Storage nem canal Realtime foi tocada; a verificação de que as superfícies fora de `app_pre_request` (Storage, Realtime) não vazam conteúdo premium exige acesso ao projeto (listar buckets/políticas) — pendente.
- Endurecimento de permissões para o lançamento (quando as versões compatíveis estiverem publicadas): revogar `anon`/`authenticated` de acesso direto às tabelas de banco de questões/gabarito, deixando só RPCs; fazer isso DEPOIS que `min_version` bloquear versões antigas, para não quebrar apps publicados. Não prometer segurança absoluta de conteúdo: a proteção é dificultar extração, não impedi-la.
- Navegação com diálogos abertos / proteção de rota: Etapa 08 já fecha o que está empilhado ao entrar em bloqueio (`_AccessGateRefresh`); `/privacidade` entrou em `_sessionOnlyRoutes` e é liberada com o acesso bloqueado.
- Links de indicação: o código de indicação é resolvido por `resolve_referral_code` (liberado no gate); o formato público do link depende do domínio do app web — conferir após publicar.

## Estratégia de versões para a grande atualização comercial
- Versão atual: `pubspec.yaml` 1.0.4+7. A atualização comercial é MINOR com quebra de compatibilidade de acesso: **1.1.0** (build seguindo o contador de lojas).
- Ordem: (1) publicar as lojas com 1.1.0 (assinatura nova exige nova versão no iOS); (2) quando ≥ X% dos usuários estiverem em 1.1.0 ou a aprovação sair, subir `min_version_*` em `commercial_config` só para plataformas cuja loja já liberou 1.1.0; (3) só então `enforcement_enabled = true`. Nada disso foi feito nesta etapa; `pubspec` NÃO foi alterado.
- Rollback: `enforcement_enabled=false` / `emergency_disable` no servidor; `min_version_*` volta ao valor anterior.

## Achados adicionais (agente de lojas)
- `targetSdk`/`compileSdk` = 36 e `minSdk` = 24 pelo Flutter local (3.47.4): atende ao requisito de API 36; reconferir com o Flutter 3.50.1 do CI. iOS deployment target 15.0 (≥ 13).
- **`ios/Runner/PrivacyInfo.xcprivacy` declara nenhum dado coletado**, mas o app coleta e-mail, redações, progresso e compras: inconsistente com os rótulos de privacidade. Atualizar o manifesto junto com as App Privacy labels antes do envio (decisão do dono sobre o enquadramento).
- `TARGETED_DEVICE_FAMILY = "1,2"`: screenshots de iPad 13" são obrigatórios.
- Faltam screenshots do paywall e o feature graphic do Google Play.
- Com os provedores desligados em produção, o revisor Apple não vê paywall bloqueante: ver opções em `docs/store-listings/REVISORES_E_CHECKLISTS.md`.

## Divergências site existente × fatos (agente do site)
- Rodapé do site Lucksrei já exibe CNPJ e e-mail de marketing; os rascunhos usam `[PENDENTE-DONO]` para razão social/CNPJ/endereço/suporte até o dono confirmar quais dados valem para o AprovaAura.
- Página atual do app é um case study com links reais das lojas; os rascunhos deixam os links como pendentes (publicar só na ativação coordenada).
- Exclusão: site diz "Perfil → Excluir minha conta"; o app tem o botão vermelho no Perfil (conferir o texto final). Prazo de retenção do site ("nenhum adicional") conflita com registros de acesso (6 meses) e retenção fiscal: usar o texto da minuta.
