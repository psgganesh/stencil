# Spec: CI/CD

**Status:** ready-for-agent
**Source:** the wayfinder map `.scratch/stencil-v1/map.md`. Decisions point to `.scratch/stencil-v1/issues/` by ticket number. The reference workflow is `.refs/.github/workflows/main.yml`.
**Order:** spec 2 of 5 (Foundation → **CI/CD** → Onboarding → marketing → app screens).

## Assumes

The **Foundation** spec is done:
- the app builds on every platform and its tests pass;
- `app_identity.yaml` and the identity command exist (apply mode and `--check`);
- Android has a release `signingConfig` that falls back to debug signing when no keystore is present;
- macOS has the `network.client` and Keychain Sharing entitlements;
- `web/_redirects` is in place.

There's no `.github/` directory yet.

## Problem Statement

The person building a product from stencil wants every push to `main` to be checked, built for every platform, and shipped to every store and to the website automatically, as the reference workflow does for another app. But they won't have any accounts, certificates, keys or a self-hosted Mac runner on day one. They'll fill those in over weeks, platform by platform.

The reference workflow breaks in exactly that state:
- jobs on the self-hosted Mac wait forever when no runner exists;
- its Google Play check crashes on an empty secret, and that crash skips the Android build;
- its Netlify step fails;
- iOS signing fails;
- it hard-codes another app's identifiers (`au.com.devhustlers.catalyst`, `Catalyst.ipa`).

They also need one clear checklist of the manual work, in the right order, saying which secret each step produces.

## Solution

A single GitHub Actions workflow that runs on every push to `main`, and on demand from any branch. It does three things:

1. **Checks every commit:** identity drift, formatting, analysis and tests.
2. **Builds every platform** (web, Android, iOS, macOS, Windows) even when nothing has been set up. The iOS and macOS builds run unsigned as a compile check until signing exists. The iOS and macOS jobs wait for a repository variable saying the self-hosted Mac runner is ready.
3. **Deploys each platform only when its secrets are present:** web to Netlify, Android to Google Play, iOS and macOS to App Store Connect, Windows to the Microsoft Store. A missing secret skips that deploy visibly instead of failing the run.

Every identifier comes from `app_identity.yaml`. Alongside the workflow, `docs/manual-tasks.md` (written by Claude with this spec) walks through every manual step in order and names the secret or file each one produces.

## User Stories

1. As a developer, I want every push to `main` to check formatting, analysis and tests, so that broken code is caught at once.
2. As a developer, I want CI to fail when a native file has drifted from `app_identity.yaml`, so that the app identity can't silently split.
3. As a developer, I want to run the whole workflow on demand from any branch, so that I can try a change to it before merging.
4. As a developer, I want deploys to happen only from `main`, so that a branch run never ships anything.
5. As a developer with no secrets set, I want every build job I can run to go green, so that the boilerplate works from its first push.
6. As a developer with no secrets set, I want every deploy job to show as skipped, not failed, so that a red run always means something is really broken.
7. As a developer without a self-hosted Mac runner, I want the iOS and macOS jobs skipped, rather than queued forever, so that runs finish.
8. As a developer who has registered the Mac runner, I want to turn on the iOS and macOS jobs with one repository variable, so that I control when they start.
9. As a developer, I want web, Android and Windows built on GitHub-hosted runners, so that they don't depend on my Mac being online.
10. As a developer, I want the web build deployed to Netlify when the Netlify secrets are set, so that the marketing site and web app go live on every push.
11. As a developer, I want the Netlify deploy to serve every path from `index.html`, so that deep links like `/app/items/42` work after a refresh.
12. As a developer, I want the Android build signed with my upload key when the keystore secrets are set, and debug-signed otherwise, so that the build always runs.
13. As a developer, I want the Android upload skipped when this version code is already on Google Play, so that re-runs don't fail on duplicate versions.
14. As a developer with no Google Play secret, I want the version check to let the Android build continue, so that only the upload is skipped.
15. As a developer, I want the Android bundle uploaded to the internal and alpha tracks when the Play secret is set, so that testers get it automatically.
16. As a developer, I want an unsigned iOS build to run as a compile check when the App Store secrets are missing, so that iOS breakage is caught before signing exists.
17. As a developer, I want a signed IPA uploaded to App Store Connect when the App Store secrets are set, so that TestFlight gets every build.
18. As a developer, I want an unsigned macOS build when the App Store secrets are missing, and a signed Mac App Store package uploaded when they're set, so that macOS works like iOS.
19. As a developer, I want a Store-ready MSIX built on every run, so that Windows breakage is caught early.
20. As a developer, I want the MSIX submitted to the Microsoft Store when the Partner Center secrets are set, so that Windows ships automatically after the first manual submission.
21. As a developer, I want every artifact named from `artifact_name` and every package ID from `app_id`, so that renaming the product needs no workflow edit.
22. As a developer, I want the version name and build number taken from the `version:` line in `pubspec.yaml`, so that one edit bumps every platform.
23. As a developer, I want overlapping runs on the same branch queued, not cancelled, so that a release never stops halfway.
24. As a developer, I want the build artifacts kept on each run, so that I can download and test a build by hand.
25. As a developer, I want web, Android and Windows built with a pinned Flutter version, so that builds are reproducible.
26. As a developer, I want the self-hosted runner's Flutter version written in the manual-tasks document, so that Mac builds match the rest.
27. As a developer setting up a product, I want one ordered checklist of every manual task, so that I don't miss a step or do them in the wrong order.
28. As a developer, I want each checklist step to say where to do it, what it produces and which job uses it, so that I know exactly which secret to fill in.
29. As a developer, I want the checklist to start by saying what already works with nothing set up, so that I know I can postpone it.
30. As a developer, I want the checklist to tell me to choose the real app ID before creating any store record, so that I never get stuck with `com.example.stencil` in a store.
31. As a developer, I want each deploy step to check its own secrets and log which one is missing, so that I can see at a glance what's left to set up.

## Implementation Decisions

### Triggers and shape

- **Triggers:** a push to `main`, and `workflow_dispatch` from any branch. **Deploy jobs run only when the ref is `main`** as well as when their secrets are present.
- **Concurrency:** one group per workflow and ref, with no cancelling, as in the reference.
- **Actions:**
  - `actions/checkout@v7` (the reference's `@v5` is two majors behind);
  - `actions/upload-artifact@v7` and `actions/download-artifact@v8`;
  - `subosito/flutter-action@v2` pinned to Flutter **3.47.5 stable** on GitHub-hosted runners;
  - `r0adkll/upload-google-play@v1`.

  Source: Review of the reference CI workflow (06).

### Jobs

| Job | Runner | Needs | Runs when | Does |
|---|---|---|---|---|
| `validate` | `ubuntu-latest` | none | always | reads the version name and build number from `pubspec.yaml` and outputs them; reads `app_id` and `artifact_name` from the identity command and outputs them; `flutter pub get`; identity `--check`; `dart format --set-exit-if-changed`; `flutter analyze`; `flutter test` |
| `build_web` | `ubuntu-latest` | validate | always | `flutter build web --release` with the version; uploads `build/web` |
| `deploy_web` | `ubuntu-latest` | build_web | `main` **and** `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` set | deploys `build/web` to Netlify production. `_redirects` comes from Foundation's `web/` folder, so it's already in the build. |
| `check_play` | `ubuntu-latest` | validate | always | if `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is empty: outputs `skip_play_upload=false` and logs "Play secret not set". Otherwise it checks the internal track for this version code, using `app_id` as the package name. |
| `build_android` | `ubuntu-latest` | validate, check_play | `skip_play_upload != 'true'` | writes the keystore and `key.properties` when the four `ANDROID_*` secrets are set (otherwise Foundation's debug-signing fallback applies); `flutter build appbundle --release`; uploads the AAB |
| `deploy_android` | `ubuntu-latest` | build_android | `main` **and** the Play secret and all four keystore secrets set | uploads to Google Play tracks `internal` and `alpha`, status `completed`, package `app_id` |
| `build_ios` | `[self-hosted, macOS]` | validate | `vars.MAC_RUNNER_READY == 'true'` | unlocks the keychain if `MAC_KEYCHAIN_PASSWORD` is set. With all three `APPSTORE_*` secrets set: `flutter build ipa --release`, renames the IPA to `<artifact_name>.ipa`, uploads it. Otherwise: `flutter build ios --release --no-codesign` as a compile check, with no artifact. |
| `deploy_ios` | `[self-hosted, macOS]` | build_ios | `main` **and** the runner variable **and** the `APPSTORE_*` secrets set | uploads `<artifact_name>.ipa` to App Store Connect with the API key, as in the reference |
| `build_macos` | `[self-hosted, macOS]` | validate | `vars.MAC_RUNNER_READY == 'true'` | the same keychain handling. With the `APPSTORE_*` secrets: archives and exports a **Mac App Store** `.pkg` (App Store export method, Mac Installer Distribution signing, the embedded App Store provisioning profile carrying Keychain Sharing) as `<artifact_name>.pkg`, and uploads it. Otherwise: `flutter build macos --release` unsigned, with no artifact. |
| `deploy_macos` | `[self-hosted, macOS]` | build_macos | `main` **and** the runner variable **and** the `APPSTORE_*` secrets set | uploads the `.pkg` to App Store Connect with the same API key (`altool` with type `macos`; **verify this command on the first real run**, because the research only inferred it) |
| `build_windows` | `windows-latest` | validate | always | `flutter build windows --release`, then builds the MSIX with the `msix` package in **Store mode**, using the Store identity values that the identity command wrote into the msix config; uploads `<artifact_name>.msix` |
| `deploy_windows` | `windows-latest` | build_windows | `main` **and** the four `MSSTORE_*` secrets set | `setup-msstore-cli`, configure it with tenant, client, secret and seller ID, then publish the MSIX to the Store product |

Sources: macOS and Windows distribution (18); Desktop build and signing options (17); `.scratch/stencil-v1/research/desktop-build-and-signing.md`.

### Secrets and variables

- **Secrets in the reference:** `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `APPSTORE_API_KEY_ID`, `APPSTORE_API_PRIVATE_KEY`, `APPSTORE_ISSUER_ID`, `MAC_KEYCHAIN_PASSWORD`.
- **New secrets:** `MSSTORE_TENANT_ID`, `MSSTORE_CLIENT_ID`, `MSSTORE_CLIENT_SECRET`, `MSSTORE_SELLER_ID`.
- **New repository variable:** `MAC_RUNNER_READY` (unset, or `true`).
- **Codex creates no secrets.** A secret that isn't set evaluates to an empty string, which is exactly the "not set up" case (06). The manual-tasks document lists them.
- **Checking whether a secret is set:** GitHub doesn't allow `secrets.*` in a job-level `if:`. Each deploy job exposes the secrets it needs as job environment variables, and a first step checks them.
  - **If any are missing:** the step logs which ones and ends the job successfully, marking itself skipped with a clear notice. The remaining steps are guarded on that step's output.
  - **`deploy_web`** replaces the reference's failing "Verify Netlify Credentials" step with this pattern.

### Identity in CI

- **New `app_identity.yaml` field:** `msstore_product_id`, the Partner Center Store ID, which isn't secret. The identity command ignores it when rewriting files.
- **`--get <key>`:** the identity command gains this mode, which prints one value. `validate` uses it to output `app_id`, `artifact_name` and `msstore_product_id` to later jobs.
- **No hard-coded identifiers:** no workflow line contains the product's identifiers. `au.com.devhustlers.catalyst` and `Catalyst.ipa` disappear.
- Source: Manual-tasks document (19).

### Manual-tasks document

`docs/manual-tasks.md` is written by Claude as part of this spec (Manual-tasks document, 19). The workflow's skip notices link to it by section name. Codex doesn't edit it, except to fix a secret or job name if the implementation had to differ; such a fix is noted in the ticket.

## Testing Decisions

- **What a good test is:** it checks what the workflow does on GitHub for a given set of secrets and variables, not how the YAML is written.
- **Seam 1, a real workflow run:**
  - **Pass bar:** a `workflow_dispatch` run on a branch, with **no secrets and no `MAC_RUNNER_READY`**. `validate`, `build_web`, `check_play`, `build_android` and `build_windows` are green. Every `deploy_*` is skipped (branch ref) or reports its missing secrets. `build_ios` and `build_macos` are skipped.
  - **Recording it:** the run's URL and a summary of the job results go in the ticket's `## Comments` before it's closed.
  - **Optional second run:** if the human has a Mac runner, a run with `MAC_RUNNER_READY=true` shows the unsigned iOS and macOS compile checks passing.
- **Seam 2, `actionlint`:** run locally on the workflow before every push. It must report no issues.
- **The identity command's new `--get` mode** is tested at Foundation's seam 3 (the command run against a temporary copy).
- **Prior art:** the reference workflow for job structure, and the Foundation identity command tests.

## Out of Scope

- **Developer ID / notarised macOS direct downloads,** and **signed Windows direct installers.**
- **Self-hosted Windows or Linux runners.** Linux has no build job.
- **Store listings, screenshots and release notes.** First submissions are manual (in the manual-tasks document).
- **Push-delivery keys** (APNs `.p8`, VAPID, FCM). They're listed as "Later" in the manual-tasks document; nothing in CI uses them.
- **RevenueCat,** and creating GitHub secrets automatically.
- **PR-triggered runs.** Only `main` pushes and manual dispatch trigger the workflow.

## Further Notes

- **Differences from the reference workflow, on purpose:**
  - `validate`, the Android jobs and `check_play` move to GitHub-hosted runners, so nothing waits for a Mac that doesn't exist yet.
  - Mac jobs are gated on `MAC_RUNNER_READY`.
  - Unsigned iOS and macOS compile checks run when there are no Apple secrets.
  - `check_play` tolerates an empty secret.
  - Deploys skip instead of failing.
  - Identifiers come from `app_identity.yaml`.
  - Windows and macOS jobs are new.
- **Suggested `/to-tickets` slices:**
  1. the identity `--get` mode, `msstore_product_id`, and `validate`;
  2. web build and deploy;
  3. Android: `check_play`, build and deploy;
  4. iOS build and deploy, with the runner gate;
  5. macOS build and deploy;
  6. Windows build and deploy.

  Each ticket is closed with a dispatch run link.
