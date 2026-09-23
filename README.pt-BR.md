# Aura

<p>
  <a href="README.md">🇺🇸 English</a>
  &nbsp;|&nbsp;
  <strong>🇧🇷 Português</strong>
</p>

Um aplicativo de estudos gamificado para estudantes brasileiros se preparando para o ENEM, vestibulares e concursos, feito com Flutter e Supabase. Aprenda. Pratique. Evolua.

## Visão geral

O Aura pega a ideia do Duolingo — lições curtas, estruturadas e que criam hábito — e aplica a matérias escolares em vez de idiomas. O conteúdo de cada matéria é organizado como uma árvore navegável (região/área → tema → atividade) em vez de uma lista plana de quizzes, então ele consegue crescer em profundidade (Geografia e História do Brasil ganham bastante destaque) sem virar uma pilha de questões impossível de navegar.

O catálogo de conteúdo, a navegação, a autenticação, o perfil e o motor de prática já estão prontos e populados: Matemática, Geografia, História, Português, Biologia, Física e Química têm bancos de questões completos (~1.400 questões), cada uma marcada como fácil/médio/difícil, para o aluno conseguir filtrar uma matéria só pelo nível que quiser. A Geografia ainda tem dezenas de quizzes interativos de mapa e bandeiras, e Atualidades tem seu próprio modelo de dossiê vivo, com quiz de prática. A progressão também é real: questões respondidas e regiões encontradas no mapa são registradas por usuário, terminar uma atividade dá XP e alimenta a ofensiva diária, os erros viram uma lista de revisão e qualquer questão pode ser favoritada. Todos os atalhos de prática estão ligados: a Início abre com a ofensiva mais prática rápida, revisar erros e favoritos, e a aba Praticar guarda o catálogo de matérias.

## Funcionalidades

**Início**
- Saudação personalizada e um card de ofensiva alimentado pela atividade diária real do usuário
- Um bottom sheet avisa que a ofensiva caiu uma única vez, na primeira vez que o usuário abre o app depois de perder um dia
- Os três atalhos que escolhem as questões por você: prática rápida, revisar erros e favoritos

**Catálogo de matérias**
- Navegador recursivo de região/tema/atividade por matéria, com dados no Supabase, sem profundidade fixa — algumas matérias têm só dois níveis, outras (como Geografia e História do Brasil) vão bem mais fundo
- Um seletor de dificuldade Fácil/Médio/Difícil/Todos fica na raiz de cada matéria e filtra a árvore inteira (via uma RPC recursiva no Supabase), deixando só os tópicos que têm questões naquele nível, e carrega esse filtro até a prática
- Todo nó mostra uma barra de progresso, sempre derivada da soma das questões respondidas (ou regiões encontradas no mapa) das folhas descendentes — nunca armazenada direto
- Todo tópico-folha termina em um quiz de múltipla escolha ou, nos tópicos de mapa da Geografia, em um quiz interativo de mapa/bandeiras

**Motor de prática (quiz)**
- Interface de múltipla escolha estilo Duolingo: cabeçalho "Questão X de Y", cards de alternativa com letra e estados de certo/errado, card de feedback e botão fixo "Continuar" na parte de baixo
- Um único motor compartilhado (view + cubit + interface de repositório) alimenta o quiz de toda matéria, os quizzes de dossiê da Atualidades e o filtro de dificuldade — só o repositório usado e o parâmetro de dificuldade mudam
- Qualquer questão pode ser favoritada dentro do próprio quiz, e terminar uma atividade dá XP e registra a atividade do dia para a ofensiva

**Quizzes interativos de mapa e bandeiras** (Geografia)
- Construído com `flutter_map` e dados GeoJSON: responde tocando no país/estado certo (polígono), no rio certo (linha) ou na cidade/capital certa (ponto)
- Um modo de identificação de bandeiras reaproveita as mesmas formas dos países, usando emoji de bandeira como pergunta — sem precisar de imagens
- Cobertura: estados do Brasil, além de países/capitais/cidades/rios da Europa, América do Sul, África, Ásia, América do Norte, Oceania e do mundo todo

**Atualidades**
- Um modelo de conteúdo separado, o "dossiê" (contexto, o que aconteceu, por quê, quem está envolvido, consequências, fontes), em vez da árvore de região/tema, já que esse conteúdo envelhece e precisa ser atualizado periodicamente, e não de um catálogo fixo
- Populado com dossiês cobrindo Brasil, geopolítica, economia, meio ambiente, ciência e tecnologia, sociedade e saúde
- Cada dossiê tem seu próprio quiz de prática, reaproveitando o mesmo motor de múltipla escolha de qualquer outra matéria

**Progresso, XP e ofensiva**
- Cada questão respondida conta uma única vez por usuário, tendo acertado ou errado; as folhas de quiz de mapa registram as regiões encontradas do mesmo jeito, já que não têm linhas em `questions`
- Concluir uma atividade dá 10 XP; o nível é sempre derivado do XP total (100 XP por nível) e aparece no Perfil
- A ofensiva conta dias corridos de calendário (America/São_Paulo) com pelo menos uma atividade concluída, e a quebra é detectada de forma preguiçosa, na primeira vez que uma RPC roda depois de um intervalo de 2+ dias
- Toda escrita de XP e de ofensiva passa por RPCs `security definer` — o cliente só consegue dizer "uma atividade foi concluída", nunca definir os números

**Praticar** *(aba)*
- A grade com as 8 matérias: Matemática, Geografia, História, Português, Biologia, Física, Química, Atualidades — praticar uma matéria específica começa aqui

**Atalhos de prática** *(na Início)*
- **Prática rápida** monta um baralho de 10 questões que o usuário nunca respondeu, em rodadas: uma questão de cada matéria por rodada, sorteada dentro da matéria. No fim, um bottom sheet oferece outra rodada. Como são questões comuns, acertar já conta no progresso do tópico de origem e errar já cai no "revisar erros" — sem nenhuma escrita extra
- **Revisar erros** lista os tópicos-folha em que o usuário ainda tem questões erradas, com a contagem de erros por tópico, e refaz só essas questões; acertar uma resolve o erro, já que tudo é derivado da mesma tabela de progresso
- **Favoritos** lista os tópicos que têm questões favoritadas e pratica só elas

**Onboarding**
- Roda uma vez, logo após o cadastro: objetivo (ENEM / vestibular / concurso / escola / conta própria) → ano da prova → matérias de interesse
- Pula a etapa de ano da prova quando o objetivo é estudar por conta própria, já que não se aplica

**Perfil**
- Dados da conta (nome, usuário, e-mail), objetivo, matérias de interesse
- Card de XP e nível
- Configurações de tema (claro/escuro) e idioma (português/inglês)
- Sair da conta

**Conta e autenticação**
- Autenticação por e-mail/senha via Supabase Auth
- Cadastro pede só nome (obrigatório), e-mail, senha e um nome de usuário opcional — sem telefone, sem outros dados pessoais

## Stack técnica

| Camada | Escolha |
|---|---|
| Framework | Flutter (Android, iOS, Web) |
| Gerenciamento de estado | `flutter_bloc` (Cubit) |
| Backend | Supabase (Postgres, Auth, Row Level Security) |
| Injeção de dependência | `get_it` |
| Roteamento | `go_router` |
| Mapas | `flutter_map` + GeoJSON (empacotado como assets) |
| Testes | `flutter_test` |

## Arquitetura

Clean Architecture, organizada por feature em vez de por camada no nível raiz:

```
lib/
├── core/            # Preocupações transversais: DI, roteamento, tema, tratamento de erros, config de ambiente
├── shared/          # Widgets e utilitários reutilizáveis, sem conhecimento de nenhuma feature específica
└── features/
    ├── auth/
    ├── onboarding/
    ├── home/
    ├── subjects/        # Lista de matérias (Matemática, Geografia, ...) exibida na Home
    ├── catalog/         # Navegador genérico de região/tema/atividade usado por todas as matérias
    ├── questions/       # Motor de quiz de múltipla escolha compartilhado (view, cubit, repositório)
    ├── map_quiz/        # Motor de quiz interativo de mapa/bandeiras da Geografia
    ├── atualidades/     # Dossiês de atualidades (modelo de conteúdo separado)
    ├── practice/
    ├── progress/        # Progresso por questão, agregado no progresso de cada nó do catálogo
    ├── xp/              # XP total e o nível derivado dele
    ├── streak/          # Ofensiva diária e o aviso de quebra
    ├── error_review/    # "Revisar erros" — erros pendentes, agrupados por tópico
    ├── favorites/       # Questões favoritadas, agrupadas por tópico
    └── profile/
        ├── data/            # Implementações de repositório (Supabase)
        ├── domain/          # Entidades e interfaces de repositório
        └── presentation/    # Cubits, páginas, widgets
```

Cada feature só tem as camadas que realmente precisa. Erros são modelados explicitamente com um tipo `Result<T>` (`Success` / `Error`) em vez de exceções lançadas atravessando os limites das camadas, então a UI sempre trata os estados de falha de forma deliberada. Sem `setState` — todo estado de UI, até coisas simples como mostrar/esconder senha, passa por um Cubit.

## Como rodar

1. Copie `env.example.json` para `env.json` e preencha a URL e a publishable key do seu projeto Supabase.
2. No SQL Editor do seu projeto Supabase, rode os arquivos em `supabase/`: primeiro os arquivos de schema (`*_schema.sql`, mais o `map_quiz_progress.sql` e o `quick_practice.sql`), depois os seeds de questões de cada matéria, depois os arquivos `difficulty_classify_*.sql`, e por fim os arquivos de dossiê da Atualidades. `supabase/health_check.sql` e `supabase/audit_questions_duplicates.sql` são scripts só de leitura que você pode rodar a qualquer momento pra auditar o catálogo e o banco de questões.
3. `flutter pub get`
4. `flutter run --dart-define-from-file=env.json`
