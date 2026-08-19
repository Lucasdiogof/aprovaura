# Aura

<p>
  <a href="README.md">🇺🇸 English</a>
  &nbsp;|&nbsp;
  <strong>🇧🇷 Português</strong>
</p>

Um aplicativo de estudos gamificado para estudantes brasileiros se preparando para o ENEM, vestibulares e concursos, feito com Flutter e Supabase. Aprenda. Pratique. Evolua.

## Visão geral

O Aura pega a ideia do Duolingo — lições curtas, estruturadas e que criam hábito — e aplica a matérias escolares em vez de idiomas. O conteúdo de cada matéria é organizado como uma árvore navegável (região/área → tema → atividade) em vez de uma lista plana de quizzes, então ele consegue crescer em profundidade (Geografia e História do Brasil ganham bastante destaque) sem virar uma pilha de questões impossível de navegar.

O catálogo de conteúdo, a navegação, a autenticação, o perfil e o motor de prática já estão prontos e populados: Matemática, Geografia, História, Português, Biologia, Física e Química têm bancos de questões completos (~1.400 questões), cada uma marcada como fácil/médio/difícil, para o aluno conseguir filtrar uma matéria só pelo nível que quiser. A Geografia ainda tem dezenas de quizzes interativos de mapa e bandeiras, e Atualidades tem seu próprio modelo de dossiê vivo, com quiz de prática. O que ainda é só um placeholder: o card de ofensiva na Início, e os quatro atalhos da aba Praticar (prática rápida, revisar erros, favoritos, escolher um tema) — a interface e a navegação existem, mas nenhum ainda abre um destino real.

## Funcionalidades

**Início**
- Saudação personalizada e um card de ofensiva (visual por enquanto — ainda não existe rastreamento de atividade real pra alimentar esse número)
- Grade com as 8 matérias: Matemática, Geografia, História, Português, Biologia, Física, Química, Atualidades

**Catálogo de matérias**
- Navegador recursivo de região/tema/atividade por matéria, com dados no Supabase, sem profundidade fixa — algumas matérias têm só dois níveis, outras (como Geografia e História do Brasil) vão bem mais fundo
- Um seletor de dificuldade Fácil/Médio/Difícil/Todos fica na raiz de cada matéria e filtra a árvore inteira (via uma RPC recursiva no Supabase), deixando só os tópicos que têm questões naquele nível, e carrega esse filtro até a prática
- Todo tópico-folha termina em um quiz de múltipla escolha ou, nos tópicos de mapa da Geografia, em um quiz interativo de mapa/bandeiras

**Motor de prática (quiz)**
- Interface de múltipla escolha estilo Duolingo: cabeçalho "Questão X de Y", cards de alternativa com letra e estados de certo/errado, card de feedback e botão fixo "Continuar" na parte de baixo
- Um único motor compartilhado (view + cubit + interface de repositório) alimenta o quiz de toda matéria, os quizzes de dossiê da Atualidades e o filtro de dificuldade — só o repositório usado e o parâmetro de dificuldade mudam

**Quizzes interativos de mapa e bandeiras** (Geografia)
- Construído com `flutter_map` e dados GeoJSON: responde tocando no país/estado certo (polígono), no rio certo (linha) ou na cidade/capital certa (ponto)
- Um modo de identificação de bandeiras reaproveita as mesmas formas dos países, usando emoji de bandeira como pergunta — sem precisar de imagens
- Cobertura: estados do Brasil, além de países/capitais/cidades/rios da Europa, América do Sul, África, Ásia, América do Norte, Oceania e do mundo todo

**Atualidades**
- Um modelo de conteúdo separado, o "dossiê" (contexto, o que aconteceu, por quê, quem está envolvido, consequências, fontes), em vez da árvore de região/tema, já que esse conteúdo envelhece e precisa ser atualizado periodicamente, e não de um catálogo fixo
- Populado com dossiês cobrindo Brasil, geopolítica, economia, meio ambiente, ciência e tecnologia, sociedade e saúde
- Cada dossiê tem seu próprio quiz de prática, reaproveitando o mesmo motor de múltipla escolha de qualquer outra matéria

**Praticar** *(aba)*
- Quatro opções: prática rápida, revisar erros, favoritos, escolher um tema
- Interface e navegação prontas; nenhuma ainda está ligada a um destino real

**Onboarding**
- Roda uma vez, logo após o cadastro: objetivo (ENEM / vestibular / concurso / escola / conta própria) → ano da prova → matérias de interesse
- Pula a etapa de ano da prova quando o objetivo é estudar por conta própria, já que não se aplica

**Perfil**
- Dados da conta (nome, usuário, e-mail), objetivo, matérias de interesse
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
    └── profile/
        ├── data/            # Implementações de repositório (Supabase)
        ├── domain/          # Entidades e interfaces de repositório
        └── presentation/    # Cubits, páginas, widgets
```

Cada feature só tem as camadas que realmente precisa. Erros são modelados explicitamente com um tipo `Result<T>` (`Success` / `Error`) em vez de exceções lançadas atravessando os limites das camadas, então a UI sempre trata os estados de falha de forma deliberada. Sem `setState` — todo estado de UI, até coisas simples como mostrar/esconder senha, passa por um Cubit.

## Como rodar

1. Copie `env.example.json` para `env.json` e preencha a URL e a publishable key do seu projeto Supabase.
2. No SQL Editor do seu projeto Supabase, rode os arquivos em `supabase/`: primeiro os arquivos de schema (`*_schema.sql`), depois os seeds de questões de cada matéria, depois os arquivos `difficulty_classify_*.sql`, e por fim os arquivos de dossiê da Atualidades. `supabase/audit_questions_duplicates.sql` é um script só de leitura que você pode rodar a qualquer momento pra checar duplicatas no banco de questões.
3. `flutter pub get`
4. `flutter run --dart-define-from-file=env.json`
