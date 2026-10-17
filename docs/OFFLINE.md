# Offline reading (APR-OFF-001)

## Cause
Combination of network and UI state: catalog/progress/question RPCs had no
timeout and no cache. With a connection that hangs instead of failing (airplane
mode on iPhone), the future never completed, so `CatalogLoading` was never
replaced by `CatalogError`. Only subject names had any local persistence.

## What exists now
- `core/cache/offline_cache.dart`: JSON cache over SharedPreferences.
  Public content (`pub.`: catalog nodes, question text, per language) and
  personal data (`usr.<uid>.`: progress bars) are separate. `clearUserData()`
  runs on sign-out and account deletion; public content is kept.
- `core/network/request_guard.dart`: 12 s timeout (8 s for questions) and
  `failureFromError` -> `NetworkFailure` / `RequestTimeoutFailure` /
  `ServerFailure` / `UnexpectedFailure`.
- Catalog: cache shown first, revalidated in the background. Failure with
  cache keeps the last good list plus a "saved content" banner with retry;
  failure without cache ends loading with an error (offline icon) and retry.
  A request id drops responses that arrive after a newer filter/refresh.
- Questions: network first (8 s), fallback to the last questions fetched for
  that topic/difficulty on connection failure only.
- Progress bars: cached per user, shown with the catalog.

## Invalidation and limits
- Every successful online fetch overwrites its entry; empty answers are never
  saved. `OfflineCache.version` is in every key: bump it to discard all.
- No size cap/eviction: only topics the user opened are stored (small JSON).
- Content never opened online is unavailable offline (message + retry).

## Online-only (not changed)
Answer registration, XP, streak, daily goal, favorites, mock exams, essays.
No offline write queue exists. An answer that fails to register is NOT queued
or retried; the practice screen says it was not recorded. Nothing is duplicated.

## Other subjects
The mechanism is shared (all subjects use `CatalogListPage`), so the fix applies
to all; only Matemática was observed failing.

## Manual QA still pending (nothing was run: no analyze/tests/builds this round)
- Offline first open without data: no infinite spinner, retry works.
- Open Matemática online, go offline, return: content + filters visible.
- Rapid Todos/Fácil/Médio/Difícil switching, including during reconnect.
- Reconnect: list refreshes, selection kept.
- Sign out / sign in with another account: no progress bars from the first.
- pt/en/es strings, light/dark, large font, small screens (iPhone + Android).
- Practice offline: answer-not-recorded notice; finishing a quiz offline
  (XP award path was not changed and was not verified offline).

---

# Round 2: sync queue, connection monitor, more modes

## Connection monitor (`core/network/connection_monitor.dart`)
No plugin. Every request reports success/failure through `request_guard`
hooks; a connection failure flips the app to offline, and a cheap probe
(select 1 row, 5 s) runs every 8 s until the server answers. Offline, repos
fail fast (no 12 s wait): answers are queued at once, streak/daily goal
return a network failure. Back online: the queue is flushed and open
catalog screens refresh by themselves.

## Offline answer queue (`core/sync/pending_sync_queue.dart`) - no migration
Stored per account (`offline.v1.queue.<uid>`), replayed in order. Safe
because the server calls are already idempotent:
- answers: `register_question_answered` upserts on (user, question);
- XP: `award_quiz_xp` ignores an attempt id already paid;
- favorites: duplicate insert (23505) / delete of nothing = done.
A newer action for the same target replaces the older one. Pending items
are flushed before any new online answer, so an old answer is never
replayed over a newer one. Failed (non-connection) items are dropped after
3 attempts. Sign-out tries a 5 s flush first; leftovers stay under that
uid only; account deletion clears them.

Dates (needs `supabase/offline_sync_dates.sql`, NOT applied yet):
- Answers are queued with their real time and streak completions with their
  Sao Paulo calendar day. The SQL adds optional `p_answered_at` to
  `register_question_answered` (clamped to the last 7 days, latest answer
  wins) and `p_activity_date` to `register_activity_completion` (never
  rewrites an older day, break measured to the activity day). Both
  parameters have defaults, so the old app keeps working after the SQL.
- Until the SQL is applied the app degrades safely: an answer is sent
  without its time (counts on the day it syncs, like before) and a streak
  completion stays queued untouched (`deferred`) instead of crediting a day
  that may not have been studied. Apply, and the queue drains by itself.
- Clock trust: the device clock can backdate an answer/activity at most 7
  days; the server clamps anything in the future or older.

## Other modes
Cached with network-first + saved fallback: favorites (topics, questions;
their answered/wrong marks show as "not answered" offline), review
questions, error-review topics (per user), Atualidades dossiers (public).
Quick practice offline: shuffled deck from topics already opened online,
minus answers waiting in the queue (cannot know what the account answered
before, so repeats are possible; progress still counts once per question).

## Simulado: online-only by design
The server owns the exam status and grading and the answer key never
reaches the device before hand-in; the runner deliberately refuses
unconfirmed state. Offline answers/finish would break that. Now it fails
fast with a message saying it needs internet (it used to hang forever).

## Tests
Added: catalog cubit offline cases (saved copy kept, connection error flag,
stale response ignored) and `PendingAction` round-trip. NOT run (no
analyze/tests/builds this round; only `dart format`).

## Manual QA still pending
- Answer questions in airplane mode, reconnect: progress/XP appear once.
- Kill the app offline with queued answers, reopen online: they sync.
- Two accounts on one device: queued data never crosses accounts.
- Favorite offline, reconnect; unfavorite offline, reconnect.
- Quick practice, favorites, review, Atualidades offline (opened before).
- Simulado offline: message, retry works after reconnect.
