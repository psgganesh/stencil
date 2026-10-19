# Review of the reference CI workflow

Type: research
Status: resolved
Blocked by:

## Question

Read `.refs/.github/workflows/main.yml` and check it against current primary sources:
- **Versions:** does Flutter 3.47.5 exist, which channel is it on, and which Dart SDK does it ship with? Compare that with `pubspec.yaml` (`^3.13.4`). Are the actions used on current major versions?
- **Assumptions:** what does each job assume (Fastlane? Xcode version? the keychain setup on the self-hosted macOS runner?) that this repo doesn't have yet (`android/` signing config, `ios/` export options, Fastlane files)?
- **Secrets:** can `gh secret set` create a secret with an empty value? If not, what's the closest workaround?
- **Netlify:** how does the deploy step handle the rewrite of every path to `index.html` (`_redirects` or `netlify.toml`)?

List every file the workflow needs that the repo doesn't have yet.

## Answer

- Flutter 3.47.5 is a **stable** release (2026-09-18) shipping **Dart 3.13.4**, which matches `pubspec.yaml` `^3.13.4` exactly. The current stable is 3.47.7 / Dart 3.13.5. Only `build_web` pins Flutter; the self-hosted jobs use whatever is installed on the runner.
- Actions: `checkout@v5` is two majors behind (bump to `@v7`). upload-artifact v7, download-artifact v8, flutter-action v2 and upload-google-play v1 are all current.
- No Fastlane and no ExportOptions.plist are needed: `flutter build ipa` generates one (app-store). Missing pieces: `.github/workflows/main.yml`, `web/_redirects`, a release `signingConfig` in `android/app/build.gradle.kts`, and a decision on the hard-coded `au.com.devhustlers.catalyst` / `Catalyst.ipa` vs `com.example.stencil`.
- Empty secret: the `gh` client sends an empty value from stdin, but the server side is untested. The safe equivalent is to leave the secret unset, because unset secrets evaluate to `''`.
- Netlify: the workflow has no SPA rewrite. Commit `web/_redirects` with `/*  /index.html  200`; `netlify.toml` won't work because `deploy_web` never checks out the repo.

[findings](../research/06-reference-ci-workflow-review.md)
