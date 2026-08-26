# Aura — histórico desta sessão de trabalho

Este arquivo existe pra qualquer pessoa ou máquina que abrir este
repositório depois conseguir retomar o contexto sem precisar reconstruir
tudo do zero. Não é documentação de produto — é um recap do que foi feito,
por quê, e o que ainda falta.

## Stack e convenções do projeto

- Clean Architecture: `lib/features/<nome>/{domain,data,presentation}`.
- Estado com `flutter_bloc` (Cubits, nunca `setState`), DI com `get_it` (`sl`).
- Supabase como backend. RLS: dado sensível/gamificável (streak, XP,
  progresso) passa por RPC `security definer` que valida `auth.uid()`
  internamente; dado simples do próprio usuário (favoritos) permite
  insert/delete direto via policy `auth.uid() = user_id`.
- Árvore de catálogo recursiva (`catalog_nodes`: id, subject, parent_id,
  title, description, icon, order_index, manual_difficulty, region_count).
  `questions` sempre anexa direto na folha (catalog_node_id já é a folha,
  nunca precisa subir a árvore procurando).
- l10n manual via classes `*_strings.dart` chaveadas por `AppLanguage`.
- **Sem comentários explicativos no código** — só quando explica um "porquê"
  não óbvio (invariante escondida, gotcha, decisão que surpreenderia quem lê).
- **Nunca commitar/subir sem pedido explícito**, sempre nesta sessão.
- Estilo de commit: sem prefixo `feat:`/`fix:`, mensagem natural em inglês,
  descrevendo o "porquê", não o "o quê".
- SQL sempre é entregue ao usuário rodar manualmente no Supabase (nunca
  aplicado diretamente) — sinalizar isso sempre que houver um `.sql` novo.
- Rotina de verificação: `dart format` + `flutter analyze` + `flutter test`
  depois de qualquer lote de mudanças, antes de reportar como pronto.

## O que foi construído nesta sessão (em ordem)

### 1. Progresso para quizzes de mapa
Quizzes de mapa nunca gravavam progresso (só perguntas de múltipla escolha
gravavam) — por isso tópicos só-de-mapa (ex.: América do Norte, Oceania)
não mostravam barra de progresso nenhuma.

- Tabela `user_region_progress(user_id, catalog_node_id, region_id)` +
  RPC `register_region_found` (mesmo padrão de `register_question_answered`).
- Coluna `catalog_nodes.region_count` (total de regiões clicáveis de cada
  quiz de mapa — não dá pra derivar via SQL porque os dados moram nos
  `.geojson` embutidos no app, não no banco).
- `catalog_node_progress` (RPC) somando os dois: `question_totals` +
  `region_totals`, `full outer join`. Lado de leitura (`ProgressRepository`,
  `CatalogNodeTile`) não precisou mudar nada.
- Progresso é rastreado por `catalog_node_id`, não por `mapId` — o mesmo
  `.geojson` pode alimentar mais de um quiz (ex.: `europe_countries.geojson`
  vira tanto "Países da Europa" quanto "Bandeiras da Europa").
- SQL: `supabase/map_quiz_progress.sql`.

### 2. Pipeline de conteúdo a partir de PDFs de atlas
O usuário tem PDFs de um curso (prof. Thais Formagio, cpf/email dela
embutido como marca d'água — material comprado, uso pessoal, nunca
reproduzir o desenho dela, só extrair o fato geográfico e desenhar a
geometria do zero).

- Sem `pdftoppm`/poppler instalado — usar `pymupdf` (`fitz`) via
  `C:\Users\Computador\AppData\Local\Programs\Python\Python312\python.exe`
  (esse Python específico, não o alias da Microsoft Store) pra renderizar
  páginas em PNG e ler como imagem.
- PDFs processados: relevo mundial, solos mundiais, hidrografia mundial,
  relevo brasileiro, EUA, agricultura mundial, clima mundial, indústria
  brasileira, agricultura brasileira. "Portos brasileiros" veio em branco
  (só o contorno, sem anotação) — esse tópico foi construído do zero a
  partir do meu conhecimento geral, não do PDF.
- O que virou **quiz de mapa** (ponto/linha/polígono, sempre com
  `backgroundMapId` pra dar contexto visual): Relevo do mundo, Solos do
  mundo, Correntes marítimas, Estreitos do mundo, Relevo do Brasil,
  Indústria do Brasil, Portos do Brasil, Relevo da América do Norte,
  Relevo da Oceania, Biomas do Brasil, Biomas do mundo, Biomas da América
  do Sul.
- O que virou **múltipla escolha** (não tem geometria discreta — cinturão,
  ranking, faixa de latitude): Agricultura mundial, Climas do mundo,
  Agricultura do Brasil, Estados Unidos (dentro de América do Norte).
- Fronteiras de bioma são **aproximadas à mão** (sem shapefile oficial
  disponível) — servem pra "clique na região certa", não são precisão de
  agrimensura. Sempre avisar isso ao usuário quando tocar nesse conteúdo.
- Arquivo de referência completo (todos os 37+ pares catalog_node_id ↔
  mapId): `lib/features/catalog/presentation/mapped_activities.dart`.

### 3. UX e performance dos quizzes de mapa
- **Errar 3x no mapa**: revela a região certa (destaque âmbar, label "Era
  essa aqui") e avança automático depois de ~1.8s, sem contar como acerto.
  Lógica em `MapQuizCubit.onRegionTapped`/`advancePastReveal`.
- **Fundo em todo mapa de ponto/linha**: antes só alguns quizzes tinham
  `backgroundMapId`; agora os 24 (rios/capitais/cidades de cada continente
  + os de escopo mundial) têm. Continente usa o fundo do próprio
  continente (mais leve e mais nítido no zoom daquela região); só quizzes
  de escopo mundial usam o mapa-múndi.
- **Performance**: `world_countries.geojson` (868 KB, 37 mil pontos) tinha
  fundo pesado demais — gerei versões `_bg` simplificadas (RDP,
  `epsilon=0.3` pro mundo, `0.1`/`0.03` pros continentes/Brasil) que ficam
  visualmente idênticas no zoom em que são usadas. `MapQuizRepositoryImpl`
  também ganhou cache em memória (`Map<String, List<MapRegion>>`) — antes
  reprocessava o mesmo arquivo do zero em cada abertura/retry.

### 4. Suíte de testes (quase do zero)
Só existiam 2 arquivos de teste antes desta sessão. Agora:

- **Testes unitários** para os 18 cubits do app (auth, catalog, map quiz,
  questions, streak, xp, onboarding, profile, favorites, error review,
  atualidades, home shell, locale, theme) — `bloc_test` + `mocktail`,
  adicionados ao `pubspec.yaml`.
- **Gotcha importante de bloc_test**: cubits cujo construtor chama
  `load()` de forma assíncrona (a maioria) têm sua PRIMEIRA emissão
  síncrona perdida pelo `blocTest` (ele só assina o stream depois que
  `build()` retorna). E o `Cubit.emit()` do pacote `bloc` já deduplica
  estados iguais consecutivos (`if (state == _state && _emitted) return`).
  Combinação das duas coisas quebra silenciosamente qualquer teste que
  tente re-chamar `load()`/`refresh()` via `act:` esperando ver o ciclo
  completo `[Loading, Loaded]`. Solução adotada: pra estado de construção,
  usar `test()` simples com `await pumpEventQueue()` e checar `cubit.state`
  direto (não depender da sequência do stream); pra testar um método que
  já foi chamado depois de settled, usar dados DIFERENTES entre a carga
  inicial e a segunda chamada (senão o segundo emit é deduplicado e
  "desaparece").
- **Validators extraídos**: `lib/shared/utils/validators.dart` ganhou
  `isNameProvided` e `doPasswordsMatch` (antes inline em
  `register_page.dart`), mesmo comportamento e mensagens. 38 testes
  cobrindo e-mail, senha, nome e confirmação de senha — só o que existe
  de verdade no app (CPF/CEP/telefone/data de nascimento **não existem**
  no Aura, não inventar).
- **Testes de widget** (parcial, a pedido do usuário — parou aí por
  enquanto): `LoginPage`, `RegisterPage`, `CatalogListPage`. Helper
  reaproveitável em `test/helpers/pump_app.dart`. Faltam:
  `MultipleChoiceView`, `MapQuizPage` (mais arriscado por causa do
  `flutter_map`), `HomeShellPage`.
- Estado final: **213 testes, `flutter analyze` limpo** (só 4 infos
  pré-existentes e não relacionados em `profile_repository_impl.dart`).

### 5. Lacunas de conteúdo fechadas
- Todos os continentes agora têm um tema "Relevo" (só América do Norte e
  Oceania não tinham, diferente dos outros).
- Home (`home_page.dart`) agora filtra o grid de matérias pelos assuntos
  de interesse marcados no onboarding — cai de volta pra mostrar tudo se o
  perfil ainda não carregou ou o usuário terminou o onboarding sem marcar
  nada (o botão "Continuar" não obriga escolha). **Praticar continua sem
  filtro, de propósito.**

### 6. Diagnóstico de duplicidade
Rodado no banco (`supabase/diagnostico_duplicidade.sql` e depois
`supabase/health_check.sql`, mais completo, feito por outra sessão/conta):
nenhum nó de catálogo duplicado, nenhuma ordem colidindo, nenhuma pergunta
repetida, nenhum tópico "beco sem saída" esquecido. `region_count`/
`manual_difficulty` de todo mundo conferido linha a linha contra o que
foi cadastrado — bateu 100%.

## Pendências conhecidas (não é pedido implícito, só registro)

- Verificação de performance num dispositivo real após o cache +
  simplificação dos mapas — usuário ia testar, ainda sem retorno.
- Testes de widget de `MultipleChoiceView`/`MapQuizPage`/`HomeShellPage`.
- Biomas da América do Norte / Oceania (só Brasil, Mundo e América do Sul
  têm hoje).
- `supabase/questions_seed_goias_rios.sql`: preenche as 6 folhas de
  "Goiás > Rios" que estavam vazias — não fui eu que escrevi (não estava
  no meu contexto desta sessão), mas está no repo e parece legítimo.
- `supabase/health_check.sql`: versão mais completa do meu diagnóstico
  (14 categorias de checagem, só leitura) — também não escrito por mim
  nesta sessão, mas vale reaproveitar como rotina de auditoria.

## Onde estão as coisas

- Mapas: `lib/assets/maps/*.geojson` (globado inteiro no `pubspec.yaml`,
  não precisa registrar arquivo por arquivo).
- Ligação catalog_node_id ↔ mapId: `lib/features/catalog/presentation/mapped_activities.dart`.
- SQL desta sessão: `supabase/catalog_seed_*.sql`, `supabase/map_quiz_progress.sql`,
  `supabase/difficulty_classify_geografia_novos_topicos.sql`.
- Testes: `test/` espelha `lib/` 1:1; helper de widget test em `test/helpers/pump_app.dart`.
