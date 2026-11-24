# Segurança e banco (Etapa 10)

## Migrações
- **Do zero:** `tool/db/empty_db_check.sh` sobe Postgres 16 descartável (Docker), cria stubs de `auth`/papéis, aplica a base legada mínima (`profiles`, `catalog`, `questions`, `difficulty`, `progress`, `essays`, `xp`, `quiz_xp_ledger`, `streaks`, `favorites`, `error_review`, `mock_exams`) e as 14 migrações comerciais em ordem: **14/14 OK**.
- **Limite:** a base legada não tem histórico ordenado de migrações (arquivos soltos em `supabase/`); por isso não existe "reconstrução idêntica da produção a partir do repositório", só das migrações comerciais sobre uma base mínima. Nunca reaplicar seeds/correções antigas (`supabase/LEIA_ANTES_DE_REAPLICAR.md`).
- **Comparação com produção:** `tool/db/sql_tests.py` roda contra a produção em transação sempre revertida (nada persiste). Não foi feito diff completo de schema; o cruzamento é: as funções e tabelas usadas pelos testes existem e se comportam como esperado.
- **Rollback:** `supabase/rollbacks/20261201000100_*.down.sql` completo (restaura `record_legal_acceptance` de 2 argumentos, `get_legal_status`, config pública e gate). Mantém de propósito a tabela de faixa etária e a regra "só adulto compartilha".

## Testes negativos
- **API anônima (PostgREST), `tool/db/rest_negative_tests.py`, 34/34 negados:** leitura de 17 tabelas sensíveis (financeiro, admins, aceites, redações, perfis, config), escrita em 5 e chamada de 13 RPCs administrativas/financeiras/de serviço.
- **Banco (`sql_tests.py`):** anônimo e usuário comum não chamam `admin_*`, `record_confirmed_payment`, `publish_legal_version`; não leem `payments`, `commission_ledger`, `payouts`, `financial_report_imports`, `user_age_declarations`; professor não lê aluno de outro professor.
- **Não coberto (sem PAT/painel):** Storage, Realtime, Edge Functions publicadas. Conferir no painel que não há bucket público nem tabela de conteúdo no Realtime.
- `app_pre_request` é concedida a `anon` por desenho (gancho do gate; retorna `void`; sem efeito).

## Exclusão de conta (contas de teste, transação revertida)
Aluno excluído: `payments.raw` zerado, pagamento e comissão preservados (contábil), vínculo removido. Professor excluído: perfil anonimizado ("Professor removido"), encerrado, sem Pix; comissões e repasses preservados. Último administrador: trigger `app_admins_protect_last` (P0014) revisado no código; teste destrutivo só em banco descartável com um único admin.

## Banco de questões e gabarito
| Classe | Ação |
|---|---|
| **Compatível agora** | Nenhuma mudança: `correct_index` continua legível a quem tem acesso (necessário ao uso offline); simulados já são online-only sem gabarito antecipado. |
| **Exige versões novas** | RPC `check_answer` no servidor e retirada de `correct_index` do `select`; limites por requisição e `max-rows` no PostgREST. Só depois de `min_version_*` desligar versões antigas. |
| **No lançamento** | Definir `min_version_*` (passo 18 do plano) e então aplicar a retirada do gabarito. Não há proteção absoluta contra extração por quem tem acesso legítimo. |

## Reaceite legal
O servidor é a fonte: `publish_legal_version(..., requires_reaccept=true)` + `get_legal_status` mostram o pendente; o app bloqueia apenas após resposta confirmada do servidor. Falha de rede ou autorização offline **nunca** bloqueiam. A tela de aceite mantém: ler documentos, sair/trocar de conta e excluir conta; recuperação de senha e login ficam fora do gate (sem sessão). O requisito segue **desligado** publicamente: nenhum documento tem `requires_reaccept` ativo até a publicação dos Termos.

## Etapa 10B: segurança autenticada (stack Supabase local, JWTs reais)
`tool/qa/rest_auth_tests.py`: **103/103**. Cobre usuário comum, aluno, dois professores e admin:
- nenhum papel não-admin lê financeiro, admins, auditoria, config, aceites, consentimentos, entitlements ou vínculos de terceiros;
- RPCs `admin_*` e de serviço recusadas a usuário comum, aluno e professor; ninguém se promove a admin nem se concede cortesia;
- RPCs de professor recusadas a quem não é professor;
- **isolamento entre professores**: um professor não vê aluno, lista nem financeiro do outro;
- **consentimento**: sem faixa adulta o compartilhamento é recusado; adulto compartilha; o consentimento de um aluno não abre acesso a outro professor; revogação encerra a visibilidade na hora; declarar-se menor encerra mesmo com consentimento antigo gravado;
- perfil e progresso alheios ilegíveis e inalteráveis; aluno não escreve em `app_admins`, `entitlements`, `partners` nem `commercial_config`.

Produção (somente leitura, chave anônima): Storage sem buckets visíveis; Realtime exige credencial; `delete-account` exige JWT de usuário (401); as funções de pagamento ainda não estão publicadas (404). `AUTO_DEPLOY=false` confirmado no GitHub. Publicação automática independente do GitHub Actions (Cloudflare Workers Builds ligado ao Git) **não verificável sem acesso ao painel**: pendência do dono.

### Achados
1. **Corrigido:** padrão de `requires_reaccept = true` com zero aceites em produção forçaria reaceite a todos (migração `20261202000100`, aplicada).
2. **Corrigido:** a obrigação de reaceite confirmada pelo servidor podia ser ignorada desconectando o aparelho; agora é guardada por conta (offline, 5xx e reinício não a apagam).
3. **Aberto (conhecido, decisão de lançamento):** com o modelo comercial desligado, `questions.correct_index` é legível a qualquer um (política "publicly readable"); com o modelo ligado o gate responde 402 ao anônimo e o usuário autenticado continua lendo o gabarito (necessário ao offline). Mitigação definitiva = `check_answer` + `min_version_*`.
4. **Recomendação:** o `web/_headers` não define Content-Security-Policy; adicionar exige teste com CanvasKit (`wasm-unsafe-eval`) e provedores de pagamento, então não foi aplicado às cegas.
