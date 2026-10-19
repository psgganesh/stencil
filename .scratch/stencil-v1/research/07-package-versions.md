# Package versions and the current Riverpod API (no codegen)

Research for ticket [07](../issues/07-package-versions.md). Sources checked on 2026-10-19 against the toolchain confirmed in ticket 06: **Flutter 3.47.5 stable, Dart 3.13.4** (`flutter --version` run locally), pubspec `environment: sdk: ^3.13.4`.

## TL;DR

- Every package below resolves on Dart 3.13.4 / Flutter 3.47.5. Latest stable: `flutter_riverpod ^3.4.3`, `firebase_core ^5.0.0`, `firebase_auth ^7.0.0`, `cloud_firestore ^7.0.0`, `shared_preferences ^2.5.6`, `intl: any` (resolves to 0.20.3 and is pinned by `flutter_localizations`), plus `flutter_localizations: sdk: flutter`.
- The FlutterFire majors came out on **2026-10-15**, four days ago. They bump the native SDKs (Firebase iOS SDK 13, Android BoM 35), require **Android `minSdk 24`** and **macOS 11** for Swift packages, and make no Dart API changes that matter to us. Use them, but the Android/macOS platform floors have to be set when Firebase lands.
- Riverpod 3 without codegen: `Notifier` / `AsyncNotifier` with `NotifierProvider` / `AsyncNotifierProvider` (`Class.new`). There are no more `AutoDispose*` or `Family*` classes. Auto-dispose is opt-in with `isAutoDispose: true` (or `.autoDispose`). A family notifier takes its argument through its constructor. Overrides work the same on `ProviderScope(overrides:)` and `ProviderContainer(overrides:)`. Tests use `ProviderContainer.test()`.
- Main conflicts with AGENTS.md: (1) Riverpod 3 **retries failing providers automatically**, which changes how error states behave in tests and in the error UI. Turn it off explicitly. (2) `shared_preferences`' legacy `SharedPreferences` API is slated for deprecation, so use `SharedPreferencesWithCache` / `SharedPreferencesAsync`. Neither is a contradiction, but both need a line in AGENTS.md (see §5).

## 1. Version table

Latest versions come from the pub.dev JSON API (`https://pub.dev/api/packages/<name>`) [1].

| Package | Latest stable (published) | SDK constraint of that version | Fits Dart 3.13.4 / Flutter 3.47.5? | Suggested pubspec line |
|---|---|---|---|---|
| `flutter_riverpod` | 3.4.3 (2026-09-03) | `sdk: ^3.12.0`, `flutter: >=3.0.0`; pins `riverpod: 3.4.3` | yes | `flutter_riverpod: ^3.4.3` |
| `riverpod` (transitive) | 3.4.3 (2026-09-03) | `sdk: ^3.12.0` | yes | (don't list it) |
| `firebase_core` | 5.0.0 (2026-10-15) | `sdk: ^3.6.0`, `flutter: >=3.27.0` | yes | `firebase_core: ^5.0.0` |
| `firebase_auth` | 7.0.0 (2026-10-15) | `sdk: ^3.6.0`, `flutter: >=3.16.0`; needs `firebase_core ^5.0.0` | yes | `firebase_auth: ^7.0.0` |
| `cloud_firestore` | 7.0.0 (2026-10-15) | `sdk: ^3.6.0`, `flutter: >=3.27.0`; needs `firebase_core ^5.0.0` | yes | `cloud_firestore: ^7.0.0` |
| `shared_preferences` | 2.5.6 (2026-10-05) | `sdk: ^3.11.0`, `flutter: >=3.41.0` | yes | `shared_preferences: ^2.5.6` |
| `flutter_localizations` | ships with the SDK | `sdk: ^3.11.0-0`; depends on `intl: ^0.20.3` (local `$FLUTTER/packages/flutter_localizations/pubspec.yaml`) | yes | `flutter_localizations: { sdk: flutter }` |
| `intl` | 0.20.3 (2026-06-25) | `sdk: ^3.9.0` | yes | `intl: any` (as the Flutter docs say; `flutter_localizations` decides the version) [9] |
| `riverpod_lint` (optional, not codegen) | 3.1.9 (2026-09-03) | `sdk: >=3.13.0-0 <4.0.0` | yes, barely (needs Dart ≥ 3.13.0) | Not needed. Leave it out unless a ticket asks for it. |

Notes:
- **FlutterFire 5/7/7 breaking changes** [2][3][4]: "BREAKING FEAT: bump Firebase iOS SDK to 13.0.0", "bump Firebase Android SDK to 35.0.0", "build on Firebase BoM 35 and **require minSdk 24**", "build on Firebase Apple SDK 13 and **require macOS 11** for Swift packages". `cloud_firestore` 7.0.0 also deprecates `setIndexConfigurationFromJSON`, which we don't use. None of this changes the Dart APIs we plan to call (`Firebase.initializeApp`, `FirebaseAuth`, `FirebaseFirestore`). The previous minors are `firebase_core 4.15.0` / `firebase_auth 6.7.0` / `cloud_firestore 6.10.0`, a fallback if the new native SDKs cause trouble.
- **The Android floor is `minSdk 24` either way.** `shared_preferences` also lists Android "SDK 24+" (and iOS 13.0+, macOS 10.15+) [5]. The ticket that adds Firebase should set `minSdk = 24` in `android/app/build.gradle(.kts)`, and macOS 11 for the macOS target.
- **`shared_preferences` 2.5.6** "Updates minimum supported SDK version to Flutter 3.41/Dart 3.11" [6]. We're above that.
- **gen-l10n with Flutter 3.47:** the synthetic `package:flutter_gen` is gone. Generated files go into the source tree (default `lib/l10n/`), and `flutter: generate: true` is **required** in pubspec [10]. Import with `import 'l10n/app_localizations.dart';` (or the `package:stencil/l10n/...` path), never `package:flutter_gen/...` [9][10]. Don't set `synthetic-package` in `l10n.yaml`.

## 2. Riverpod 3 without code generation: the API shape

### 2.1 Notifier / AsyncNotifier (the view model)

- **`Notifier<T>`** for synchronous state, exposed with `NotifierProvider<MyNotifier, T>(MyNotifier.new)`. **`AsyncNotifier<T>`** for state loaded asynchronously, exposed with `AsyncNotifierProvider<MyNotifier, T>(MyNotifier.new)`. Its `state` is an `AsyncValue<T>`, and `build()` returns `Future<T>`. `StreamNotifier` works the same way for streams [7][11].
- In 3.0 `Ref` lost its type parameter and **all `Ref` subclasses were removed** (`FutureProviderRef` and the like). `ref.state`, `ref.listenSelf` and `ref.future` are now `Notifier.state`, `Notifier.listenSelf` and `AsyncNotifier.future` [7][8].
- `AsyncValue`: **`valueOrNull` was removed**. Use `.value`, which is now nullable and returns `null` during errors. Use `requireValue` where a value is guaranteed. Pattern matching (`switch (asyncValue) { AsyncData(:final value) => ..., AsyncError(...) => ..., AsyncLoading() => ... }`) is the documented style [8]. (The migration page's example still says `valueOrNull`, but the changelog is authoritative: "Breaking removed AsyncValue.valueOrNull (use .value instead)" [8].)
- Since 3.0, all providers filter updates with **`==`** [7]. Our hand-written immutable state classes with `copyWith` should therefore implement `==` / `hashCode`. If they don't, every `state = state.copyWith(...)` notifies, which is correct but rebuilds more. If they do, a `copyWith` that changes nothing won't notify. Either is fine; the tickets should just pick one consistently. Override `updateShouldNotify` to customise.
- `Ref.mounted` exists. After an `await` inside a notifier method, check `ref.mounted` before writing `state`. "All ref and notifier methods besides `mounted` now throw if used after getting disposed" [8].
- Mutations and offline persistence are **experimental** (`package:riverpod/experimental/...`) and can break without a major version [8]. Avoid them.

### 2.2 Overrides: fake vs Firestore, and tests

- **Every** provider can be overridden through the `overrides:` list of either `ProviderScope` (widget tree) or `ProviderContainer` (pure Dart) [12][13]. The available methods are `overrideWith(...)` (replace the create function, or for a `NotifierProvider` supply a different notifier, e.g. `fooProvider.overrideWith(FakeFoo.new)`), `overrideWithValue(...)` (for `Provider`, and re-added for `FutureProvider`/`StreamProvider`), and **`overrideWithBuild(...)`** (new in 3.0: replaces only `Notifier.build` and keeps the real methods) [8][12].
- The pattern that fits AGENTS.md: `final todoRepositoryProvider = Provider<TodoRepository>((ref) => InMemoryTodoRepository());` as the default. In `main()`, once the Firebase config is detected (see research 05), call `runApp(ProviderScope(overrides: [todoRepositoryProvider.overrideWithValue(FirestoreTodoRepository(...))], child: ...))`. Tests do the same with fakes.
- Overriding the same provider **twice in one container now throws** [8]. Build the startup override list once.
- **Tests:** `ProviderContainer.test(overrides: [...])` replaces the old hand-rolled `createContainer` helper. It disposes itself at the end of the test [8][13]. In widget tests, wrap with `ProviderScope(overrides: [...])`. `tester.container()` finds the container in the tree [8].

### 2.3 autoDispose and family: what changed

- **AutoDispose:** the `AutoDispose*` interfaces (`AutoDisposeNotifier`, `AutoDisposeAsyncNotifier`, `AutoDisposeProvider`, …) are **removed**. There is one `Notifier` / `Provider` type now ("case-sensitive replace of `AutoDispose` to empty string") [7]. Opt in per provider with `isAutoDispose: true` (e.g. `Provider<String>(isAutoDispose: true, (ref) => ...)`), or keep using the `.autoDispose` modifier [8][14]. **Without codegen the default is keep-alive.** Auto-dispose is on by default only with `@riverpod` [14].
- **Family:** `FamilyNotifier` / `FamilyAsyncNotifier` / `FamilyStreamNotifier` are **removed**. Use `NotifierProvider.family<MyNotifier, State, Arg>(MyNotifier.new)` with a plain `Notifier` that **takes the argument in its constructor** (`MyNotifier(this.arg)`). `build()` takes no parameters [7]. Riverpod recommends auto-dispose for families so they don't leak one state per argument [14].
- **Family overrides:** since 3.2.0, `family.overrideWith` is **deprecated** in favour of `family.overrideWith2`, whose callback receives the argument. `overrideWith2` will be renamed back to `overrideWith` in 4.0 [8].
- As of 3.0, when an async provider rebuilds it keeps its old subscriptions until the rebuild finishes. That changes the exact moment auto-dispose fires (riverpod#1253) [8]. No impact on our design.

### 2.4 Other 3.x runtime behaviour to know about

- **Automatic retry** (on by default): a provider that throws is retried with backoff, and while retrying it is reported as *loading* [7][8]. To disable it globally: `ProviderScope(retry: (retryCount, error) => null, ...)` / `ProviderContainer(retry: ...)`. Per provider: `NotifierProvider(..., retry: (_, _) => null)` [7].
- **Pausing:** listeners in widgets that are out of view (driven by `TickerMode`) are paused, and so is a provider whose only listeners are paused. A paused `StreamProvider` pauses its `StreamSubscription` [7][8]. Pausing doesn't dispose anything, so app-wide state is safe. A screen under a pushed route just stops receiving updates until it is visible again.
- Errors read through `ref.watch` / `ref.read` are **wrapped in `ProviderException`**. Checking the error through `AsyncValue.error` still sees the original error [7].
- `ProviderObserver` methods now take a `ProviderObserverContext` [7].
- Riverpod's own 3.0 changelog warns that "a 4.0.0 will be released relatively soon" [8]. Use `^3.4.3` (caret stays below 4.0).

## 3. Deprecations and APIs tickets should avoid

| Avoid | Use instead | Source |
|---|---|---|
| `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` (now under `package:flutter_riverpod/legacy.dart`) | `Notifier` + `NotifierProvider` | [7] |
| `AutoDisposeNotifier`, `AutoDisposeAsyncNotifier`, `AutoDisposeNotifierProvider`, … | `Notifier` / `AsyncNotifier` + `isAutoDispose: true` or `.autoDispose` | [7] |
| `FamilyNotifier`, `FamilyAsyncNotifier`, `build(arg)` | constructor argument on `Notifier` + `.family` | [7] |
| `family.overrideWith` (deprecated in 3.2.0) | `family.overrideWith2` | [8] |
| `AsyncValue.valueOrNull` (removed) | `.value` / `requireValue` / pattern matching | [8] |
| `FutureProviderRef`, `ProviderRef<T>`, `ref.state`, `ref.listenSelf` | `Ref` + notifier members | [7][8] |
| `SyncProviderTransformerMixin` (deprecated in 3.4.0) | (we don't need custom listenables) | [8] |
| anything from `package:riverpod/experimental/...` (mutations, offline) | plain notifier methods | [8] |
| `riverpod_generator`, `@riverpod`, `freezed`, `build_runner` | hand-written providers (AGENTS.md) | — |
| legacy `SharedPreferences.getInstance()` ("will be deprecated in the future") | `SharedPreferencesWithCache` (sync reads after `create`) or `SharedPreferencesAsync` | [5] |
| `SharedPreferences.setMockInitialValues` in tests (legacy API) | `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()` (or `.withData({...})`) from `shared_preferences_platform_interface` | [15] |
| `package:flutter_gen/gen_l10n/...` imports, `synthetic-package` in `l10n.yaml` | generated source under `lib/l10n/`, `generate: true` | [10] |
| `cloud_firestore` `setIndexConfigurationFromJSON` (deprecated in 7.0.0) | — | [4] |

## 4. Where AGENTS.md "Architecture" meets current Riverpod guidance

Nothing in AGENTS.md is impossible under Riverpod 3. These are the points where the current default behaviour, or a needed choice, isn't written down yet:

1. **Automatic retry vs. "async data is held as `AsyncValue`".** By default a failing repository call puts the view model into a *loading/retrying* state instead of `AsyncError`, so error UI and tests that expect `AsyncError` won't see it right away [7][8]. **Recommendation:** pass `retry: (_, _) => null` on the root `ProviderScope` in `main()` and on every `ProviderContainer.test()` / test `ProviderScope`, so errors surface at once and tests stay deterministic. Record this in AGENTS.md.
2. **Auto-dispose isn't mentioned.** Without codegen, providers stay alive by default [14]. The obvious split: app-wide notifiers (session, theme mode, language, onboarding finished) and repository providers stay keep-alive. Per-screen view models use `isAutoDispose: true`, so leaving a screen resets it. **The onboarding flow view model should stay keep-alive** (or be kept alive explicitly). AGENTS.md says answers "stay in memory until Done" across steps, and auto-dispose could drop them during a route replacement.
3. **"Choose once at startup with provider overrides"** fits, with one guard: a provider can be overridden only once per container, or it throws [8]. Build a single override list in `main()`. Tests override on their own fresh container.
4. **State classes and `==`.** Riverpod 3 filters with `==` [7]. AGENTS.md says "plain immutable classes with `copyWith`" but says nothing about equality. Decide whether the hand-written state classes implement `==`/`hashCode`. Recommended: yes, it matches the filtering and makes test assertions simpler.
5. **`shared_preferences` API choice.** AGENTS.md just says "`shared_preferences`". The plugin steers new code away from the legacy `SharedPreferences` class [5]. **Recommendation:** create a `SharedPreferencesWithCache` in `main()` (an allowList with the theme/language/onboarding keys) so theme and locale are read synchronously before the first frame. Expose it through a `Provider` that is overridden with `overrideWithValue`. Tests use `InMemorySharedPreferencesAsync` [15].
6. **Pausing and multi-layout screens.** Mobile, tablet, desktop and web layouts read the same view model, and only one is mounted at a time, so pausing has no effect. Nothing to change.

## 5. Suggested AGENTS.md additions (for whoever owns the conventions ticket)

- Riverpod 3.x, hand-written: `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider`. No `legacy.dart` imports.
- Root `ProviderScope` and every test container get `retry: (_, _) => null`.
- Per-screen view models use `isAutoDispose: true`. App-wide notifiers, repositories and the onboarding view model stay keep-alive.
- Preferences go through `SharedPreferencesWithCache`, created in `main()` and injected with an override. Tests use `InMemorySharedPreferencesAsync`.
- Android `minSdk 24` and macOS 11 once FlutterFire 5.x is added.

## Sources

1. pub.dev package API, latest versions and pubspec environments: https://pub.dev/api/packages/flutter_riverpod, …/riverpod, …/firebase_core, …/firebase_auth, …/cloud_firestore, …/shared_preferences, …/intl, …/riverpod_lint (queried 2026-10-19)
2. firebase_core changelog, 5.0.0: https://pub.dev/packages/firebase_core/changelog
3. firebase_auth changelog, 7.0.0: https://pub.dev/packages/firebase_auth/changelog
4. cloud_firestore changelog, 7.0.0: https://pub.dev/packages/cloud_firestore/changelog
5. shared_preferences README ("SharedPreferences vs SharedPreferencesAsync vs SharedPreferencesWithCache", platform support table): https://pub.dev/packages/shared_preferences
6. shared_preferences changelog, 2.5.6: https://pub.dev/packages/shared_preferences/changelog
7. Riverpod "Migrating from 2.0 to 3.0": https://riverpod.dev/docs/3.0_migration
8. riverpod changelog (3.0.0 full list, 3.1.0–3.4.3): https://pub.dev/packages/riverpod/changelog, plus https://pub.dev/packages/flutter_riverpod/changelog
9. Flutter "Internationalizing Flutter apps": https://docs.flutter.dev/ui/internationalization
10. Flutter breaking change "Localized messages are generated into source, not a synthetic package": https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source
11. Riverpod "Providers": https://riverpod.dev/docs/concepts2/providers
12. Riverpod "Provider overrides": https://riverpod.dev/docs/concepts2/overrides
13. Riverpod "Testing your providers": https://riverpod.dev/docs/how_to/testing
14. Riverpod "Automatic disposal": https://riverpod.dev/docs/concepts2/auto_dispose and "Family": https://riverpod.dev/docs/concepts2/family
15. `InMemorySharedPreferencesAsync` API docs: https://pub.dev/documentation/shared_preferences_platform_interface/latest/in_memory_shared_preferences_async/InMemorySharedPreferencesAsync-class.html
- Local: `flutter --version` → Flutter 3.47.5 / Dart 3.13.4; `$FLUTTER_ROOT/packages/flutter_localizations/pubspec.yaml` → `intl: ^0.20.3`, `sdk: ^3.11.0-0`.
