# 03: Translations and language

**What to build:** The app speaks 10 languages. It starts in the device language when it's one of them, otherwise in English. A language button anywhere lets the user switch instantly, and the choice is remembered on the device. See `../spec.md` → "Fonts and languages" (translations, language notifier, language button).

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] **Translation files:** gen-l10n is set up with `generate: true` and has ARB files for English, Hindi, Bengali, Tamil, Telugu, Marathi, Gujarati, Kannada, Malayalam and Punjabi. English is complete; the other 9 are machine-drafted and marked for review.
- [ ] Only Foundation's own strings are added (anything this ticket and later Foundation tickets display).
- [ ] **Language notifier:** a keep-alive, app-wide notifier.
  - [ ] With nothing saved, it uses the device language if supported, otherwise English.
  - [ ] It's saved to preferences, and switching changes the language with no restart.
- [ ] **Language button:** an app-wide widget in two sizes, icon-only and labelled with the current native name.
  - [ ] It opens a picker listing the 10 languages by native name with the English name beneath, in the order from `DESIGN.md`.
  - [ ] Its screen-reader label is "Language: <name>".
- [ ] Root-widget tests:
  - [ ] the device-language default, and the English fallback for an unsupported language;
  - [ ] switching through the picker changes visible text immediately;
  - [ ] the choice survives a re-pump;
  - [ ] `labeledTapTargetGuideline` passes.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
