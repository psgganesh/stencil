# Package versions

Type: research
Status: resolved
Blocked by: 06

## Question

Find the current stable versions, and their compatibility with the Flutter and Dart versions confirmed in the reference CI workflow review (Dart `^3.13.4` until then), for:
- `flutter_riverpod`
- `firebase_core`, `firebase_auth` and `cloud_firestore`
- `shared_preferences`
- `flutter_localizations` and `intl`, as used by gen-l10n

For Riverpod in particular, the current major version without code generation:
- the recommended `Notifier`/`AsyncNotifier` API;
- how provider overrides work in `ProviderScope` and `ProviderContainer` for tests;
- whether there are any changes to `autoDispose` or `family` that affect the AGENTS.md architecture.

Note anything deprecated that tickets should avoid.

## Answer

Everything fits Dart 3.13.4 / Flutter 3.47.5: `flutter_riverpod ^3.4.3`, `firebase_core ^5.0.0`, `firebase_auth ^7.0.0`, `cloud_firestore ^7.0.0` (released 2026-10-15; require Android `minSdk 24` and macOS 11), `shared_preferences ^2.5.6`, `flutter_localizations` (SDK) + `intl: any` (0.20.3). gen-l10n needs `generate: true` and writes to `lib/l10n/` (no `flutter_gen`).
Riverpod 3 without codegen: `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider(X.new)`. The `AutoDispose*`/`Family*` classes are gone: use `isAutoDispose: true` (off by default without codegen) and constructor arguments for families. Overrides go on `ProviderScope`/`ProviderContainer`, and tests use `ProviderContainer.test()`.
Avoid: `legacy.dart` providers, `valueOrNull`, `family.overrideWith` (use `overrideWith2`), experimental mutations/offline, and the legacy `SharedPreferences` (use `SharedPreferencesWithCache`; tests use `InMemorySharedPreferencesAsync`).
Gaps in AGENTS.md: turn off Riverpod 3's automatic retry (`retry: (_, _) => null`) so errors reach `AsyncValue`, decide auto-dispose per state tier (onboarding view model stays keep-alive), and decide `==` on state classes.
[findings](../research/07-package-versions.md)
