# 02: Theme, fonts and appearance

**What to build:** The app looks like `DESIGN.md` in light and dark. It renders text in bundled fonts (Indic scripts included) on every platform. It follows the system theme by default, lets the user choose Light, Dark or System, and remembers the choice on the device. See `../spec.md` → "Theme" and "Fonts and languages" (fonts part).

**Blocked by:** 01

**Status:** done

- [x] **Colour schemes:**
  - [x] one Material 3 colour scheme per brightness, set explicitly from the `DESIGN.md` tables (no seed colour); primary stays `#00639B` in dark;
  - [x] the custom roles (Selected and link, Track, Gain family, Accent fill, muted On primary container) live in a theme extension;
  - [x] the dark-mode exception: a filled button on a Primary container surface uses a `#96CCFF` fill with `#001D32` text.
- [x] Component themes for buttons, text fields, chips, cards, segmented control, switch, navigation bar and rail, dialog and snackbar follow `DESIGN.md` → Components.
- [x] **Fonts:** Roboto plus the eight Noto Sans Indic families at weights 400 and 500 are bundled as static fonts and set once as the text theme's family fallback. Nothing fetches fonts from Google at runtime.
- [x] **Theme-mode notifier:** a keep-alive, app-wide notifier holding Light, Dark or System. It defaults to System, is saved to `SharedPreferencesWithCache`, and changes the theme immediately.
- [x] `main()` creates `SharedPreferencesWithCache` and injects it with a provider override. Retry is off on the root `ProviderScope`.
- [x] Root-widget tests with `InMemorySharedPreferencesAsync`:
  - [x] the default follows the platform brightness;
  - [x] switching changes the theme;
  - [x] the choice survives a re-pump over the same preferences;
  - [x] `textContrastGuideline` passes in light and dark.
- [x] `dart format .`, `flutter analyze` and `flutter test` pass.
