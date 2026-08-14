# Aura

<p>
  <a href="README.md">🇺🇸 English</a>
  &nbsp;|&nbsp;
  <strong>🇧🇷 Português</strong>
</p>

Um aplicativo de estudos gamificado para estudantes brasileiros se preparando para o ENEM, vestibulares e concursos, feito com Flutter e Supabase. Aprenda. Pratique. Evolua.

## Visão geral

O Aura pega a ideia do Duolingo — lições curtas, estruturadas e que criam hábito — e aplica a matérias escolares em vez de idiomas. O conteúdo de cada matéria é organizado como uma árvore navegável (região/área → tema → atividade) em vez de uma lista plana de quizzes, então ele consegue crescer em profundidade (Geografia e História do Brasil ganham bastante destaque) sem virar uma pilha de questões impossível de navegar.

O projeto está em estágio inicial: o catálogo de conteúdo, a navegação, a autenticação e o perfil já estão prontos; os exercícios em si (as perguntas/atividades que o usuário responde) ainda não foram implementados.

## Funcionalidades

**Início**
- Saudação personalizada e um card de ofensiva (visual por enquanto — ainda não existe rastreamento de atividade real pra alimentar esse número)
- Grade com as 8 matérias: Matemática, Geografia, História, Português, Biologia, Física, Química, Atualidades

**Catálogo de matérias**
- Navegador recursivo de região/tema/atividade por matéria, com dados no Supabase, sem profundidade fixa — algumas matérias têm só dois níveis, outras (como Geografia e História do Brasil) vão bem mais fundo
- Conteúdo populado para Geografia, Matemática, História, Português, Biologia, Física e Química (parcial — o suficiente pra provar a estrutura em cada profundidade, não exaustivo)
- Atualidades usa um modelo de "dossiê" separado (contexto, o que aconteceu, por quê, quem está envolvido, consequências, fontes), já que esse conteúdo envelhece e precisa de uma janela de validade — o mecanismo está pronto, mas nenhum dossiê foi populado ainda

**Praticar** *(aba)*
- Quatro opções: prática rápida, revisar erros, favoritos, escolher um tema
- Interface e navegação prontas; nenhuma ainda está ligada a exercícios reais

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
2. No SQL Editor do seu projeto Supabase, rode os arquivos em `supabase/` — os arquivos de schema antes dos seeds correspondentes (ex: `catalog_schema.sql` antes de `catalog_seed.sql`).
3. `flutter pub get`
4. `flutter run --dart-define-from-file=env.json`
