# Inventário real do acervo — AprovaAura

Gerado por `tool/content/inventory.py` em **2026-11-27**. Fonte: produção (`cesuqfgrtcitatxvokez`), consulta **somente leitura** (`read_only`), token do cofre local, nada alterado.

**Confirmado:** 2609 questões, 572 nós de catálogo (468 folhas), 14 matérias com banco de questões. Os números antigos (~2.609 / 572) estão corretos.

## Por matéria

| Matéria | Nós | Folhas | Folhas sem questão | Questões | Fácil | Médio | Difícil |
|---|---:|---:|---:|---:|---:|---:|---:|
| geografia | 127 | 115 | 45 | 388 | 142 | 180 | 66 |
| biologia | 75 | 62 | 0 | 329 | 70 | 201 | 58 |
| quimica | 43 | 37 | 0 | 234 | 92 | 83 | 59 |
| fisica | 37 | 31 | 0 | 226 | 59 | 98 | 69 |
| matematica | 39 | 34 | 0 | 200 | 82 | 69 | 49 |
| historia | 28 | 25 | 0 | 177 | 79 | 48 | 50 |
| portugues | 27 | 24 | 0 | 169 | 59 | 63 | 47 |
| filosofia | 28 | 20 | 0 | 127 | 40 | 43 | 44 |
| ingles | 28 | 20 | 0 | 127 | 40 | 44 | 43 |
| espanhol | 28 | 20 | 0 | 127 | 40 | 44 | 43 |
| educacao_fisica | 28 | 20 | 0 | 127 | 42 | 42 | 43 |
| sociologia | 28 | 20 | 0 | 126 | 40 | 42 | 44 |
| literatura | 28 | 20 | 0 | 126 | 41 | 43 | 42 |
| artes | 28 | 20 | 0 | 126 | 40 | 44 | 42 |
| **Total** | 572 | 468 | 45 | 2609 | 866 (33%) | 1044 (40%) | 699 (26%) |

As folhas de Geografia sem questão (45) são, em geral, nós de **mapa interativo** (`region_count`, 1.499 regiões em 48 arquivos GeoJSON), não lacuna de questões — a confirmar nó a nó antes de tratá-las como lacuna.

## Idiomas

- Questões traduzidas: en = 2.609, es = 2.609 (cobertura total). Nós: en = 572, es = 572. Dossiês: en = 7, es = 7.
- pt-BR é o texto original em `questions`/`catalog_nodes`; en/es em `*_translations`.

## Outras superfícies

- **Dossiês de Atualidades:** 7 (um por área: Brasil, Ciência/Tecnologia, Economia, Meio ambiente, Mundo/Geopolítica, Saúde, Sociedade), todos `current`, com 35 questões (5 por dossiê), 0 sem explicação.
- **Redação:** 5 temas (`practice`, ativos). Nenhum tema oficial/de exame cadastrado.
- **Simulados:** 24 simulados gerados por usuários (`mock_exams`), 280 itens; são montados a partir de `questions` por matéria/dificuldade (sem noção de categoria).
- **Mapas:** 48 GeoJSON no repositório; progresso em `user_region_progress`.

## Dados de usuário que precisam ser preservados

`user_question_progress`: 375 linhas · favoritos: 2 · reportes: 0 · itens de simulado: 280. Todos apontam para `questions.id`; nenhuma questão existente pode ser apagada ou ter o id trocado.

## Qualidade das 2.609 questões existentes (checagem automática)

| Verificação | Ocorrências |
|---|---:|
| explicacao_curta(<60) | 227 |
| sem_explicacao | 7 |
| alternativas_duplicadas | 35 |
| duplicatas exatas (enunciado normalizado) | 2 grupos / 4 questões |
| sem 4 alternativas / gabarito fora do intervalo / HTML suspeito / órfãs | 0 |

**Distribuição do gabarito:** A 640 (24%), B 648 (24%), C 684 (26%), D 637 (24%) — equilibrada.

**Alerta de viés:** em **1621 de 2609 questões (62%) a alternativa correta é a mais longa** (o acaso daria ~25%). Quem aprende o padrão acerta sem saber. Os novos lotes têm controle automático para isso e as questões antigas devem entrar em uma fila de revisão de distratores (não alterar sem revisão humana; muda a prova de quem já respondeu).

As 35 questões com alternativas iguais após normalização (maiúsc./pontuação) e as 7 sem explicação estão listadas por id em `tool/content/state/inventory_issue_ids.json` (versionado). A dificuldade das questões existentes foi preservada; nenhuma foi reclassificada.

## Limitações desta análise

- Não há classificação por categoria (ENEM/Vestibulares/Concursos) nem proveniência no banco hoje: **todas as 2.609 são 'não classificadas'**. A origem presumida é autoral, mas isso **não está registrado** — precisa de confirmação do dono.
- Similaridade entre questões distintas (quase-duplicatas) ainda não medida no acervo antigo; o pipeline novo faz isso (MinHash local).
- Correção de conteúdo (acerto do gabarito) das questões antigas não foi reauditada neste inventário.
- O app só reconhece as 16 matérias do enum `Subject` (14 com banco + `atualidades` + `redacao`); matérias novas exigem código no app (fora de escopo desta etapa).
