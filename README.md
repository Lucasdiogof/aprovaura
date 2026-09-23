# Aura

<p>
  <strong>🇺🇸 English</strong>
  &nbsp;|&nbsp;
  <a href="README.pt-BR.md">🇧🇷 Português</a>
</p>

A gamified study app for Brazilian students preparing for the ENEM, university entrance exams (vestibulares) and civil service exams (concursos), built with Flutter and Supabase. Learn. Practice. Evolve.

## Overview

Aura turns school subjects into short, structured, habit-forming lessons. Content for each subject is organized as a browsable tree (region/area → theme → activity) rather than a flat quiz list, so it can grow deep (Brazil's geography and history get particular depth) without turning into an unnavigable pile of questions.

The content catalog, navigation, auth, profile and the practice engine are all built and populated: Matemática, Geografia, História, Português, Biologia, Física and Química have full question banks (~1,400 questions), each one tagged fácil/médio/difícil so a learner can filter a subject down to just the level they want. Geografia additionally has dozens of interactive map and flag quizzes, and Atualidades (current affairs) has its own living dossier model with practice quizzes. Progression is real as well: answered questions and found map regions are tracked per user, completing an activity awards XP and feeds a daily streak, wrong answers pile up into a review list, and any question can be favorited. The one entry point still without a destination is "quick practice" on the Practice tab.

## Features

**Home**
- Personalized greeting and a streak card driven by the user's real daily activity
- A bottom sheet announces a broken streak once, the first time the user opens the app after missing a day
- Grid of all 8 subjects: Math, Geography, History, Portuguese, Biology, Physics, Chemistry, Current Affairs — narrowed down to the subjects picked during onboarding

**Subject catalog**
- Recursive region/theme/activity browser per subject, backed by Supabase, with no fixed depth — some subjects go two levels deep, others (like Brazil's geography and história) go much further
- A Fácil/Médio/Difícil/Todos difficulty selector sits at each subject's root and filters the whole tree (via a recursive Supabase RPC) down to only the topics that have questions at that level, then carries the filter into practice
- Every node shows a progress bar, always derived by summing the answered questions (or found map regions) of its descendant leaves — never stored directly
- Every leaf topic ends in either a multiple-choice quiz or, for Geography's map-based topics, an interactive map/flag quiz

**Practice engine (quiz)**
- Duolingo-style multiple-choice UI: "Questão X de Y" progress header, lettered option cards with correct/incorrect states, a feedback card, and a fixed bottom "Continuar" button
- One shared engine (view + cubit + repository interface) powers every subject's quiz, Atualidades dossier quizzes and the difficulty filter — only the backing repository and the difficulty parameter change
- Any question can be favorited from the quiz itself, and finishing an activity awards XP and registers the day's activity for the streak

**Interactive map & flag quizzes** (Geography)
- Built on `flutter_map` and GeoJSON data: tap the right country/state (polygon), river (line) or city/capital (point) to answer
- A flag-identification mode reuses the same country shapes with emoji flags as prompts — no image assets needed
- Coverage: Brazil's states, plus countries/capitals/cities/rivers for Europe, South America, Africa, Asia, North America, Oceania and the whole world

**Atualidades** *(current affairs)*
- A separate "dossier" content model (context, what happened, why, who's involved, consequences, sources) instead of the region/theme tree, since this content ages and needs periodic refreshing rather than a fixed catalog
- Seeded with dossiers spanning Brazil, geopolitics, economy, environment, science & technology, society and health
- Each dossier has its own practice quiz, reusing the same multiple-choice engine as every other subject

**Progress, XP and streak**
- Every answered question counts once per user, right or wrong; map-quiz leaves track found regions the same way, since they have no rows in `questions`
- Completing an activity awards 10 XP; level is always derived from total XP (100 XP per level) and shown on the Profile
- The daily streak counts consecutive calendar days (America/São_Paulo) with at least one completed activity, and a break is detected lazily, the first time an RPC runs after a gap of 2+ days
- XP and streak writes only ever happen through `security definer` RPCs — the client can say "an activity was completed", never set the numbers itself

**Practice** *(tab)*
- Three entry points: quick practice, review mistakes, favorites
- **Review mistakes** lists the leaf topics where the user still has wrong answers, with a wrong-answer count per topic, and replays just those questions; answering one correctly resolves it, since it is all derived from the same progress table
- **Favorites** lists the topics holding favorited questions and practices only those
- Quick practice is the one option whose UI exists but does not open a destination yet

**Onboarding**
- Runs once, right after sign-up: goal (ENEM / vestibular / concurso / school / self-study) → target exam year → subjects of interest
- Skips the exam-year step when the goal is self-study, since it doesn't apply

**Profile**
- Account details (name, username, email), goal, subjects of interest
- XP and level card
- Light/dark theme and language (Portuguese/English) settings
- Sign out

**Account & auth**
- Email/password authentication via Supabase Auth
- Sign-up collects only name (required), email, password, and an optional username — no phone, no other personal data

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Android, iOS, Web) |
| State management | `flutter_bloc` (Cubit) |
| Backend | Supabase (Postgres, Auth, Row Level Security) |
| Dependency injection | `get_it` |
| Routing | `go_router` |
| Maps | `flutter_map` + GeoJSON (bundled as assets) |
| Testing | `flutter_test` |

## Architecture

Clean Architecture, organized by feature rather than by layer at the top level:

```
lib/
├── core/            # Cross-cutting concerns: DI, routing, theming, error handling, env config
├── shared/          # Reusable widgets and utilities with no feature-specific knowledge
└── features/
    ├── auth/
    ├── onboarding/
    ├── home/
    ├── subjects/        # Subject list (Math, Geography, ...) shown on Home
    ├── catalog/         # Generic region/theme/activity browser used by every subject
    ├── questions/       # Shared multiple-choice quiz engine (view, cubit, repository)
    ├── map_quiz/        # Interactive map/flag quiz engine for Geography
    ├── atualidades/     # Current-affairs dossiers (separate content model)
    ├── practice/
    ├── progress/        # Per-question progress, aggregated into catalog-node progress
    ├── xp/              # Total XP and the level derived from it
    ├── streak/          # Daily streak and its break notice
    ├── error_review/    # "Review mistakes" — pending wrong answers, grouped by topic
    ├── favorites/       # Favorited questions, grouped by topic
    └── profile/
        ├── data/            # Repository implementations (Supabase)
        ├── domain/          # Entities and repository interfaces
        └── presentation/    # Cubits, pages, widgets
```

Each feature only has the layers it actually needs. Errors are modeled explicitly with a `Result<T>` (`Success` / `Error`) type rather than thrown exceptions crossing layer boundaries, so the UI always handles failure states deliberately. No `setState` — all UI state, including simple things like a password-visibility toggle, goes through a Cubit.

## Getting started

1. Copy `env.example.json` to `env.json` and fill in your Supabase project URL and publishable key.
2. In your Supabase project's SQL Editor, run the files under `supabase/`: schema files first (`*_schema.sql`, plus `map_quiz_progress.sql`), then each subject's question seeds, then the `difficulty_classify_*.sql` files, then the Atualidades dossier files. `supabase/health_check.sql` and `supabase/audit_questions_duplicates.sql` are read-only scripts you can run anytime to audit the catalog and the question bank.
3. `flutter pub get`
4. `flutter run --dart-define-from-file=env.json`
