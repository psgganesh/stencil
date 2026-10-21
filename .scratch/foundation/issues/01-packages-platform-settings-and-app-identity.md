# 01: Packages, platform settings and app identity

**What to build:** The project gets the dependencies and platform settings that every later ticket and spec relies on. It also gets one place for the product's identity, plus a command that applies that identity to every platform and checks for drift. After this ticket the app still shows a single screen, but it builds on every platform and shows the app name from the identity constants. See `../spec.md` → "Packages and platform settings" and "App identity".

**Blocked by:** None (can start immediately)

**Status:** done

- [x] Dependencies are added at the versions in the spec: Riverpod 3, shared_preferences, flutter_localizations + intl, flutter_local_notifications ^22.3.0, url_launcher, firebase_core / firebase_auth / cloud_firestore.
- [x] None of these are added: codegen packages, flutter_hooks, google_fonts, a connectivity package.
- [x] Android has minSdk 24, core library desugaring on, compileSdk ≥ 37, and a notification icon.
- [x] macOS deployment target stays 12.0; release and debug entitlements include `com.apple.security.network.client`.
- [x] The Netlify SPA rewrite file (`/*  /index.html  200`) ships in the web build.
- [x] `app_identity.yaml` at the repo root holds `app_name`, `app_id`, `artifact_name` and the Microsoft Store identity values, with the placeholder values from the spec.
- [x] **The identity command** rewrites the Android, iOS, macOS, Windows, Linux, web and msix identifiers and display names, and writes a Dart constants file.
  - [x] Running it twice changes nothing the second time.
  - [x] `--check` changes nothing; it exits non-zero and names every drifted file.
- [x] The app's single screen shows `app_name` from the generated constants.
- [x] Tests (seam 3) run the command against a temporary copy of the native files. They cover rewrite, idempotency, and `--check` failing after a hand edit.
- [x] `dart format .`, `flutter analyze`, `flutter test`, and `flutter run -d chrome` pass; the Chrome widget tree contains `Text("Stencil")` with no runtime errors.

## Deferred

- Android release signing, macOS Keychain Sharing and signed release-build verification are deferred by human decision until distribution work.
- `fontFallbackBaseUrl` is deferred to ticket 02 so the self-hosted fallback URL and its font files ship together; configuring the URL without those files prevented CanvasKit from rendering text.

## Comments

- Human decision: defer signing and release builds, and limit runtime verification to Chrome for now.
