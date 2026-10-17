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
