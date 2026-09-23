# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- Password recovery: "Esqueci minha senha" opens a bottom sheet that takes
  an email, sends a Supabase recovery link, and confirms it with the option
  to send again.
- New brand identity: the horizontal logo (symbol + wordmark) on the login
  and sign-up screens, and the monogram-on-navy app icon on Android, iOS and
  the web/PWA.
- Dark-surface version of the horizontal logo, so the wordmark stays legible
  on the dark theme.

### Changed
- Home shows the full subject grid again. Filtering it by the subjects
  picked during onboarding hid most of the catalog behind a setting, and
  the grid visibly collapsed once the profile loaded.
- Launcher icons regenerated from a full-bleed navy master; the Android
  adaptive icon now uses the monogram alone as its foreground.
- Native launch screen now shows the monogram on the brand navy instead of
  the old logo on white.
- Login screen opens directly instead of showing a timed splash screen first.
- Login screen is now a single centred column: the top illustration is gone.
- Login and sign-up refined: a soft brand-gradient background, the form on
  its own card with inset fields, a supporting line under the header, and
  reworked spacing. Sign-up leads with the monogram and a page title instead
  of the full wordmark.

### Removed
- Previous logo assets (`lib/assets/logo.png`, `lib/assets/login_logo.png`).
- Login screen illustration (`lib/assets/login_illustration.png`) and its
  widget.
- Marketing tagline ("Learn. Practice. Evolve.") from the login screen.
