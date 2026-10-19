# AGENTS.md

Shared instructions for every coding agent in this repo (Codex, Claude Code). Role split: Claude Code does all ideation and planning; Codex does all implementation. See "Implementation workflow" below.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

# Project: stencil

## Project state

`stencil` is a freshly scaffolded Flutter app (stable channel, Dart SDK `^3.13.4`). It is currently the minimal "empty" template: `lib/main.dart` contains a single `MainApp` (`MaterialApp` → `Scaffold` → "Hello World!") and there are no third-party dependencies beyond `flutter_lints`. There is no `test/` directory yet. Platform folders exist for android, ios, web, macos, linux and windows.

The architecture below is decided but not built yet. Follow it as tickets land, and keep this file up to date when a ticket changes a convention. Domain terms are in `GLOSSARY.md`; colors, type and components are in `DESIGN.md`.

## Architecture

- **MVVM with Riverpod only.** No other state-management library, and no code generation: write providers by hand, and write state classes as plain immutable classes with `copyWith` (no `riverpod_generator`, no `freezed`).
- **Layers:** a View (a widget that watches its view model) → a ViewModel (a Riverpod notifier; async data is held as `AsyncValue`) → a Repository (an abstract interface) → a data source. Each layer only talks to the one beneath it.
- **Repositories have two implementations:** an in-memory fake, used by default, and a Firestore version that is used only when the Firebase config is present. The choice is made once, at startup, with provider overrides, and tests override providers the same way. The app and its tests have to run without a Firebase project. **v1 builds only the fakes**, kept alive by Riverpod providers. The Firestore repositories and `firestore.rules` come in a later effort. The data shapes they share are in `.scratch/stencil-v1/issues/08-firestore-data-model.md`.
- **Where state lives:**
  - **App-wide:** shared notifiers for the session, theme mode, language and whether onboarding is finished. Theme mode, language and onboarding progress are saved with `shared_preferences`.
  - **Per screen:** one view model per screen. Each device layout (mobile, tablet, desktop, web) is chosen from the screen width and reads that same view model.
  - **Per flow:** onboarding has one view model covering every step. Answers stay in memory until Done; the current step is saved so the flow can resume.
  - **Widget UI state** (selected tab, expanded section, a toggle not yet saved) goes in small `autoDispose` Riverpod providers. Only Flutter controller objects (`TextEditingController`, `FocusNode`, `AnimationController`, scroll controllers) live in a `StatefulWidget`, because Riverpod can't own their lifecycle without hooks. Don't add `flutter_hooks`.
- **Riverpod 3 details:**
  - Turn automatic retry off on the root `ProviderScope` and in every test container (`retry: (_, _) => null`). Each repository decides for itself whether to retry.
  - Per-screen view models and widget-state providers are `isAutoDispose: true`. The session, theme, language, repositories and the onboarding view model stay alive.
  - Every state class implements `==` and `hashCode` (with `Object.hash`).
  - Don't use `legacy.dart` providers (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`).
  - Use `SharedPreferencesWithCache`, created in `main()` and injected with a provider override. Tests use `InMemorySharedPreferencesAsync`.
- **Package versions and minimum platforms:** `flutter_riverpod ^3.4.3`, `firebase_core ^5.0.0`, `firebase_auth ^7.0.0`, `cloud_firestore ^7.0.0`, `shared_preferences ^2.5.6`. Android minSdk is 24 and macOS is 11. If the new Firebase versions cause problems, fall back to 4.15 / 6.7 / 6.10 and record that here.
- **Widgets inside a screen** get their values and callbacks from the screen; they don't read providers. The exceptions are a few small app-wide widgets, such as the language button and the avatar.
- **Routing:** `MaterialApp` named routes, with no routing package. Onboarding is one flow in one view model, and its steps are view model state, not routes. `/onboarding` shows the flow from the saved step. `/signup` opens the same flow at Language, with SignIn in signup mode. `/login` is SignIn on its own, in login mode, with no step progress. `/onboarding` has no route guard: its view model sends a signed-out user on any step after SignIn back to SignIn. `onGenerateRoute` checks the session and onboarding status, and redirects:
  - signed out and asking for `/app` → `/login`;
  - signed in, not onboarded, and asking for `/app`, `/login` or `/signup` → `/onboarding`;
  - onboarded and asking for `/login`, `/signup` or `/onboarding` → `/app`;
  - on web, signed out with no saved step and asking for `/onboarding` → `/signup`. Welcome is native-only.

  The full tables are in `.scratch/stencil-v1/issues/02-login-signup-onboarding-routes.md`.
- **Folder layout:** `lib/features/<feature>/{data,view_model,view}/` for each feature, and `lib/core/` for shared pieces (theme, routing, app-wide providers, shared widgets). Tests mirror this layout under `test/`.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run -d <device>         # run (e.g. -d macos, -d chrome); `flutter devices` lists targets
flutter analyze                 # lint/static analysis (flutter_lints)
dart format .                   # format
dart fix --apply                # apply automated lint fixes
flutter test                    # run all tests (once test/ exists)
flutter test test/foo_test.dart             # single test file
flutter test --plain-name "test name"       # single test by name
flutter build <apk|ios|web|macos|linux|windows>
```

## Lint configuration

`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` and excludes `build/` and all platform directories (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`) from analysis — Dart code is expected to live under `lib/` (and `test/`).

## Agent skills

### Issue tracker

Issues and specs live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Implementation workflow (Codex)

Implementation tickets are produced by Claude Code (`/to-spec` → `/to-tickets`) as files at `.scratch/<feature>/spec.md` and `.scratch/<feature>/issues/NN-<slug>.md`. Codex implements them; it does not re-plan them.

Only tickets with `**Status:** ready-for-agent` are implementation work. Files under a wayfinder effort (those with a `Type:` line, or alongside a `map.md`) are planning tickets — leave them alone.

1. **Pick a ticket.** Use the one you were given; otherwise take the lowest-numbered `ready-for-agent` ticket whose `Blocked by:` tickets are all `done`. Read the feature's `handoff.md` (if present) and `spec.md` for context.
2. **Implement** only what the ticket's "What to build" and acceptance criteria require. If the ticket is ambiguous or contradicts the spec, stop: append the question under a `## Comments` heading in the ticket file instead of guessing.
3. **Verify:** `dart format .`, `flutter analyze` (no new issues), `flutter test` (all pass). Add or update tests for the behaviour the ticket delivers.
4. **Close it out:** tick each acceptance criterion (`- [x]`), change the status line to `**Status:** done`, then make one commit for the ticket — code and ticket file together — with the message `<NN>: <ticket title>`. Do not push.
