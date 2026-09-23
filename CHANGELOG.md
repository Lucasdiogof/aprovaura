# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- New brand identity: the horizontal logo (symbol + wordmark) on the login
  and sign-up screens, and the monogram-on-navy app icon on Android, iOS and
  the web/PWA.
- Dark-surface version of the horizontal logo, so the wordmark stays legible
  on the dark theme.

### Changed
- Launcher icons regenerated from a full-bleed navy master; the Android
  adaptive icon now uses the monogram alone as its foreground.
- Native launch screen now shows the monogram on the brand navy instead of
  the old logo on white.
- Login screen opens directly instead of showing a timed splash screen first.
- Login screen is now a single centred column: the top illustration is gone.

### Removed
- Previous logo assets (`lib/assets/logo.png`, `lib/assets/login_logo.png`).
- Login screen illustration (`lib/assets/login_illustration.png`) and its
  widget.
- Marketing tagline ("Learn. Practice. Evolve.") from the login screen.
