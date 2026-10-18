# CLAUDE.md

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

Since there is no established architecture yet, any structure introduced (routing, state management, folder layout under `lib/`) sets the convention — keep it consistent once chosen and update this file.

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
