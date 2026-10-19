# 02: Theme, fonts and appearance

**What to build:** The app looks like `DESIGN.md` in light and dark. It renders text in bundled fonts (Indic scripts included) on every platform. It follows the system theme by default, lets the user choose Light, Dark or System, and remembers the choice on the device. See `../spec.md` → "Theme" and "Fonts and languages" (fonts part).

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] **Colour schemes:**
  - [ ] one Material 3 colour scheme per brightness, set explicitly from the `DESIGN.md` tables (no seed colour); primary stays `#00639B` in dark;
  - [ ] the custom roles (Selected and link, Track, Gain family, Accent fill, muted On primary container) live in a theme extension;
  - [ ] the dark-mode exception: a filled button on a Primary container surface uses a `#96CCFF` fill with `#001D32` text.
- [ ] Component themes for buttons, text fields, chips, cards, segmented control, switch, navigation bar and rail, dialog and snackbar follow `DESIGN.md` → Components.
- [ ] **Fonts:** Roboto plus the eight Noto Sans Indic families at weights 400 and 500 are bundled as static fonts and set once as the text theme's family fallback. Nothing fetches fonts from Google at runtime.
- [ ] **Theme-mode notifier:** a keep-alive, app-wide notifier holding Light, Dark or System. It defaults to System, is saved to `SharedPreferencesWithCache`, and changes the theme immediately.
- [ ] `main()` creates `SharedPreferencesWithCache` and injects it with a provider override. Retry is off on the root `ProviderScope`.
- [ ] Root-widget tests with `InMemorySharedPreferencesAsync`:
  - [ ] the default follows the platform brightness;
  - [ ] switching changes the theme;
  - [ ] the choice survives a re-pump over the same preferences;
  - [ ] `textContrastGuideline` passes in light and dark.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
