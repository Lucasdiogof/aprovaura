# Plano futuro do app (SOMENTE documentação — nada implementado)

## 1. Tabs ENEM | Vestibulares | Concursos
- Três abas fixas, **sem "Todas" e sem chips**. Referência (somente leitura): `Lucasdiogof/fan-hub` → `lib/shared/widgets/fan_hub_tab_bar.dart` (`FanHubTabBar`: container compacto com borda sutil, aba ativa com fundo suave, só texto, uma linha, fonte única com redução 13→10 e fallback rolável, largura mínima 56, alvo de toque). Adaptar ao tema do AprovaAura (tokens/cores do app), sem copiar identidade do Goiás App.
- Estado `selectedCategory` persistido por usuário; trocar de aba recarrega matérias/tópicos/trilhas daquela categoria.
- **Sem fallback silencioso entre categorias:** matéria sem questões publicadas na categoria **não aparece** (ou aparece desabilitada com "em breve"), nunca mostra questões de outra categoria.
- Questão compartilhada (em 2–3 categorias): o progresso é gravado uma vez em `user_question_progress` (chave user+question); em cada aba o contador conta essa questão uma vez; o total geral do usuário conta uma vez. Cuidado em estatísticas por categoria: somar categorias **não** é total.
- Simulados por categoria: `mock_exam_subject_configs` + filtro de categoria; composição só com questões da categoria; Redação por modalidade (ENEM dissertativo, vestibular por gênero, concurso discursiva/parecer/ofício) — critérios próprios, as 5 competências do ENEM só na modalidade ENEM.
- Mudanças de app necessárias (futuras): enum `Subject` hoje fixo (16 valores) → matérias dirigidas por dados; RPCs de catálogo/questões com parâmetro `p_category`; ícones/estilos das matérias novas; i18n pt/en/es das novas matérias.

## 2. Portal de professores (requisitos futuros)
Filtros e relatórios por **categoria / matéria / tópico / dificuldade**; desempenho do aluno por categoria sem dupla contagem de questões compartilhadas; sinalizar conteúdo `expires_at` vencido; professor **não** edita o catálogo (curadoria é do pipeline); manter regras de compartilhamento de estatísticas existentes (`study_sharing_consents`) e os vínculos atuais.

## 3. Performance com dezenas de milhares de questões
- Hoje: 2.609 questões, leitura pública sem paginação explícita nos repositórios; offline por sincronização (ver `docs/OFFLINE.md`).
- Índices a criar quando o volume entrar: `question_categories (category, question_id)` (já na migration), `questions (catalog_node_id, difficulty)` (existe), `catalog_node_categories (category, catalog_node_id)` (na migration), parcial por `question_provenance.expires_at`.
- Paginação por tópico/trilha (keyset por `order_index, id`), sessão de estudo carrega só o lote da sessão (10–30 questões), nunca "todas as questões de uma matéria".
- Contagens por categoria/matéria via view materializada ou tabela de contadores atualizada na promoção do lote (evitar `count(distinct)` em cada abertura de tela).
- Offline: baixar sob demanda por tópico/trilha escolhido, com teto de armazenamento e expurgo LRU; **não** embutir o acervo no bundle do app (20 mil questões ≈ dezenas de MB de texto); manter bundle apenas com UI e metadados mínimos.
- Medição a fazer antes de lançar: tempo de `catalog_children_with_difficulty` (recursivo) com 10×; tamanho do JSON por sessão; consumo de leitura no Supabase (plano atual).
