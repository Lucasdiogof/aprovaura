# Aura

<p>
  <strong>🇺🇸 English</strong>
  &nbsp;|&nbsp;
  <a href="README.pt-BR.md">🇧🇷 Português</a>
</p>

A gamified study app for Brazilian students preparing for the ENEM, university entrance exams (vestibulares) and civil service exams (concursos), built with Flutter and Supabase. Learn. Practice. Evolve.

## Overview

Aura turns school subjects into short, structured, habit-forming lessons. Content for each subject is organized as a browsable tree (region/area → theme → activity) rather than a flat quiz list, so it can grow deep (Brazil's geography and history get particular depth) without turning into an unnavigable pile of questions.

The project is early-stage: the content catalog, navigation, auth and profile are built; the exercises themselves (the actual questions/activities a user answers) are not implemented yet.

## Features

**Home**
- Personalized greeting and a streak card (visual placeholder — no activity tracking exists yet to drive it)
- Grid of all 8 subjects: Math, Geography, History, Portuguese, Biology, Physics, Chemistry, Current Affairs

**Subject catalog**
- Recursive region/theme/activity browser per subject, backed by Supabase, with no fixed depth — some subjects go two levels deep, others (like Brazil's geography and história) go much further
- Content seeded for Geography, Math, History, Portuguese, Biology, Physics and Chemistry (partial — enough to prove the structure at every depth, not exhaustive)
- Current Affairs uses a separate "dossier" model instead (context, what happened, why, who's involved, consequences, sources) since that content ages and needs a validity window — the mechanism is built, no dossiers are seeded yet

**Practice** *(tab)*
- Four entry points: quick practice, review mistakes, favorites, choose a topic
- UI and navigation are ready; none are wired to real exercises yet

**Onboarding**
- Runs once, right after sign-up: goal (ENEM / vestibular / concurso / school / self-study) → target exam year → subjects of interest
- Skips the exam-year step when the goal is self-study, since it doesn't apply

**Profile**
- Account details (name, username, email), goal, subjects of interest
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
    ├── atualidades/     # Current-affairs dossiers (separate content model)
    ├── practice/
    └── profile/
        ├── data/            # Repository implementations (Supabase)
        ├── domain/          # Entities and repository interfaces
        └── presentation/    # Cubits, pages, widgets
```

Each feature only has the layers it actually needs. Errors are modeled explicitly with a `Result<T>` (`Success` / `Error`) type rather than thrown exceptions crossing layer boundaries, so the UI always handles failure states deliberately. No `setState` — all UI state, including simple things like a password-visibility toggle, goes through a Cubit.

## Getting started

1. Copy `env.example.json` to `env.json` and fill in your Supabase project URL and publishable key.
2. In your Supabase project's SQL Editor, run the files under `supabase/` — schema files before their matching seed files (e.g. `catalog_schema.sql` before `catalog_seed.sql`).
3. `flutter pub get`
4. `flutter run --dart-define-from-file=env.json`
