# Research 06: Review of the reference CI workflow

Ticket: [06-reference-ci-workflow-review](../issues/06-reference-ci-workflow-review.md)
Subject: `.refs/.github/workflows/main.yml` ("Flutter Local Build"), checked against the repo as of 2026-10-19.

## TL;DR

- **Flutter 3.47.5 exists.** It is a **stable** release (2026-09-18) and ships **Dart 3.13.4**, which matches `pubspec.yaml` `sdk: ^3.13.4` exactly. The local SDK is also 3.47.5 / Dart 3.13.4. Newer stable patches exist: 3.47.6 and 3.47.7 (current), both on Dart 3.13.5. [1][2]
- **Actions:** `actions/checkout@v5` is **two majors behind** (v7 is current). `upload-artifact@v7`, `download-artifact@v8`, `subosito/flutter-action@v2` and `r0adkll/upload-google-play@v1` are all on their current majors. `netlify-cli@27.12.1` is one minor behind 27.13.0. [3]
- **Fastlane is not used anywhere** in the workflow, and neither is an `ExportOptions.plist`. iOS goes through `flutter build ipa` (its default export method is App Store, and it passes `-allowProvisioningUpdates`) plus `xcrun altool`. Android goes through Gradle plus `r0adkll/upload-google-play`. [4][5]
- **Empty secret:** the `gh` client does not reject an empty value (`gh secret set NAME < /dev/null` sends an encrypted empty string). Whether GitHub's API accepts it was **not tested**, because the ticket rules forbid creating secrets. The closest workaround that is guaranteed to work is to **not create the secret at all**: an unset secret evaluates to `''` in expressions, which is the same thing a workflow sees for an empty one. [6][7]
- **Netlify SPA rewrite:** the reference workflow has **none**. Add `web/_redirects` containing `/*  /index.html  200`. `flutter build web` copies it into `build/web/`, and Netlify reads it from the deployed directory. A `netlify.toml` would **not** work here, because the `deploy_web` job never checks out the repo. [8][9][10]

## 1. Versions

### Flutter / Dart (source: Flutter releases JSON [1])

| Flutter | Channel | Dart | Released |
|---|---|---|---|
| 3.47.4 | stable | 3.13.3 | 2026-09-11 |
| **3.47.5** | **stable** | **3.13.4** | 2026-09-18 |
| 3.47.6 | stable | 3.13.5 | 2026-10-01 |
| 3.47.7 (current stable) | stable | 3.13.5 | 2026-10-08 |
| 3.49.0-0.2.pre | beta | 3.14.0 | 2026-10-01 |

- Local `flutter --version`: `Flutter 3.47.5 • channel stable … Tools • Dart 3.13.4` [2].
- `pubspec.yaml` has `sdk: ^3.13.4`, which equals the Dart that ships with 3.47.5. That lower bound means Flutter 3.47.4 or older (Dart 3.13.3) **cannot** resolve this package. 3.47.5 is the minimum Flutter that satisfies the constraint.
- **Pinning caveat:** only `build_web` pins Flutter (`subosito/flutter-action` with `flutter-version: '3.47.5'`). The other jobs (`validate`, `build_android`, `build_ios`) run on `[self-hosted, macOS]` and use whatever `flutter` is on that machine's PATH. Nothing in the workflow keeps the two in sync. flutter-action also supports `flutter-version-file: pubspec.yaml` (reads an `environment.flutter` pin) as an alternative to hard-coding [3d].

### Actions (source: each repo's latest GitHub release [3])

| Used | Latest release | Status |
|---|---|---|
| `actions/checkout@v5` | v7.0.1 (2026-07-20). v6.0.0 on 2025-11-20, v7.0.0 on 2026-06-18 | **2 majors behind** → `@v7` |
| `actions/upload-artifact@v7` | v7.0.2 (2026-10-07) | current |
| `actions/download-artifact@v8` | v8.0.2 (2026-10-07) | current |
| `subosito/flutter-action@v2` | v2.23.0 (2026-03-25) | current |
| `r0adkll/upload-google-play@v1` | v1.1.5 (2026-04-21) | current |
| `npx netlify-cli@27.12.1` | 27.13.0 (npm) | minor behind. Pinning is fine. |

- checkout v5 already required runner ≥ v2.327.1 (Node 24) [3a]. The self-hosted runner must be at least that version, and v6/v7 have the same requirement.
- r0adkll: `tracks` (plural) is the non-deprecated input, and the workflow uses it correctly. The package must **already exist in Play Console with one manually uploaded AAB** before the action can upload [3b].

## 2. Per-job summary and what each assumes

| Job | Runner | Does | Assumes (outside the repo) |
|---|---|---|---|
| `validate` | self-hosted macOS | checkout. Parse `version: X+N` from pubspec (fails if there is no `+N`). `flutter pub get`, `flutter analyze` | Flutter on PATH (unpinned). The `[[ … ]]` guard works because GitHub's default bash shell is `-e` |
| `check_play` | self-hosted macOS | `pip3 install google-api-python-client google-auth`, then queries Play `internal` track version codes. Sets `skip_play_upload` | `python3`/`pip3` on the runner. A Homebrew/system Python may refuse `pip install` (PEP 668 "externally managed"), so a venv or `--user` may be needed. **Hard-coded `PACKAGE_NAME = "au.com.devhustlers.catalyst"`.** App must already exist on Play |
| `build_web` | ubuntu-latest | flutter-action 3.47.5 stable (cached). `flutter build web --release --build-name/--build-number`. Upload `build/web/` | nothing repo-specific |
| `deploy_web` | ubuntu-latest | download artifact, assert secrets non-empty, `netlify deploy --dir=build/web --prod` | Netlify site already created. **No checkout**, so only files inside `build/web` reach Netlify |
| `build_android` | self-hosted macOS | `chmod +x android/gradlew; ./gradlew --stop`. Decode keystore to `android/app/upload-keystore.jks`, write `android/key.properties`. `flutter build appbundle`. Delete signing files | JDK 17 + Android SDK on runner. **`android/app/build.gradle.kts` must read `key.properties`.** Right now the release build signs with the debug key [4a] |
| `deploy_android` | self-hosted macOS | `r0adkll/upload-google-play` → tracks `internal,alpha`, status `completed` | Hard-coded `packageName: au.com.devhustlers.catalyst`. First AAB uploaded manually [3b] |
| `build_ios` | self-hosted macOS | `security unlock-keychain` on **login** keychain (1 h timeout). `flutter build ipa --release` | Xcode installed (runner has Xcode 27.1, not pinned by the workflow). An Apple Distribution cert + key **already in the runner's login keychain**. Automatic signing (`CODE_SIGN_STYLE = Automatic`, team `H9G82PWCEV` in `project.pbxproj`) with `-allowProvisioningUpdates` (which flutter passes [5]), so Xcode on the runner must be signed in to an Apple account that can create profiles. No ExportOptions.plist: flutter generates one, default `--export-method app-store` [5] |
| `deploy_ios` | self-hosted macOS | write `~/.appstoreconnect/private_keys/AuthKey_<id>.p8`, `xcrun altool --upload-app -f ios-release/Catalyst.ipa` | **Hard-coded `Catalyst.ipa`.** Flutter names the IPA after the app (here `CFBundleName` = `stencil`), and Flutter's own docs use `build/ios/ipa/*.ipa` [4b][5]. altool upload with `--apiKey/--apiIssuer` is the documented CLI path [4b] |

### Secrets referenced (none exist yet; listed for the setup ticket)

`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`, `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `MAC_KEYCHAIN_PASSWORD`, `APPSTORE_API_PRIVATE_KEY`, `APPSTORE_API_KEY_ID`, `APPSTORE_ISSUER_ID`.

## 3. Files the workflow needs that the repo lacks

What exists now: `android/app/build.gradle.kts` (namespace/applicationId `com.example.stencil`, release uses `signingConfigs.getByName("debug")`), `android/gradlew`, and `android/.gitignore` already ignores `key.properties`, `*.jks`, `*.keystore`. `ios/` has the plain template (bundle id `com.example.stencil`, automatic signing). There is **no** `.github/`, no Fastlane, no `ExportOptions.plist`, no `_redirects`/`netlify.toml`, and no `key.properties`. (Repo listing and `grep` on `project.pbxproj`, 2026-10-19.)

| # | File | Why | Required? |
|---|---|---|---|
| 1 | `.github/workflows/main.yml` | The workflow itself. It exists only under `.refs/`, and GitHub only runs workflows from `.github/workflows/` | **yes** |
| 2 | `web/_redirects` (`/*  /index.html  200`) | SPA deep links on Netlify. See section 5 | **yes** (if the app uses path URLs; harmless otherwise) |
| 3 | `android/app/build.gradle.kts` (**edit**, not new) | Load `rootProject.file("key.properties")` and add a `release` signing config, per Flutter's guide [4a]. Without this the AAB is debug-signed and Play rejects it | **yes** |
| 4 | `android/key.properties`, `android/app/upload-keystore.jks` | Written by CI at build time from secrets and deleted afterwards. **Must not be committed** (already gitignored) | generated in CI, not committed |
| 5 | `pubspec.yaml` `version: X.Y.Z+N` | Already present (`0.1.0+1`). `validate` fails without the `+N` | present |
| 6 | App IDs in workflow vs. project | The workflow hard-codes `au.com.devhustlers.catalyst` and `Catalyst.ipa`, but the project is `com.example.stencil` / `stencil`. Either change `applicationId`/`namespace` and `PRODUCT_BUNDLE_IDENTIFIER`, or edit the workflow | **yes** (decision) |
| — | Fastlane (`Gemfile`, `fastlane/Fastfile`, `Appfile`) | **Not needed.** The workflow never calls Fastlane | no |
| — | `ios/ExportOptions.plist` | **Not needed.** `flutter build ipa` generates one (app-store method) unless `--export-options-plist` is passed [5] | no |
| — | `netlify.toml` | **Not usable** for the rewrite, because `deploy_web` has no checkout. It is optional and only matters if a checkout is added | no |

Runner-side prerequisites (not repo files, but nothing in the repo provides them): a registered self-hosted macOS runner (≥ v2.327.1) with Flutter (ideally 3.47.5), Xcode, JDK 17, Android SDK, python3/pip3, the distribution certificate in the login keychain, and an Apple account in Xcode. On the store side: a Play Console app with one manual AAB upload, an App Store Connect app record and API key, and a Netlify site.

## 4. Can `gh secret set` create an empty secret?

- **Client side: yes, it is not rejected.** In `pkg/cmd/secret/set/set.go` (`getBody`), `--body ""` is treated as "not given" (`if opts.Body != ""`), so it falls through to an interactive prompt or, when not a TTY, to `io.ReadAll(stdin)` with trailing `\r\n` trimmed. It never checks that the result is non-empty [6]. So `gh secret set NAME --body "" < /dev/null` (or `printf '' | gh secret set NAME`) encrypts and sends an empty value. The sealed-box ciphertext of an empty string is itself non-empty, so the API cannot tell the value is empty. The manual documents `-b/--body` as "reads from standard input if not specified" [6a].
- **Server side: unverified.** It was not run, because the ticket forbids creating secrets. The web UI requires a value.
- **Closest workaround that is guaranteed to work:** leave the secret **unset**. GitHub documents that "If a secret has not been set, the return value of an expression referencing the secret … will be an empty string" [7]. A workflow cannot tell an empty secret from a missing one, so `${{ secrets.X }}` gives `''` in both cases. If a placeholder must be visible in the repo's secret list, use a sentinel value (e.g. `unset`) and test for it in the step, like the `test -n` check in `deploy_web`.

## 5. Netlify SPA rewrite (every path → `index.html`)

- The reference workflow does **nothing** for this. It deploys `build/web` as-is.
- Netlify's documented SPA rule is `/*  /index.html  200` in `_redirects`, or the `[[redirects]] from="/*" to="/index.html" status=200` equivalent in `netlify.toml` [8].
- `_redirects` must sit in the **publish directory** [9]. `netlify.toml` must be at the **root of the project directory** the CLI runs from [10]. `deploy_web` runs only `download-artifact` with no `actions/checkout`, so a repo-root `netlify.toml` would never be on disk. **Use `_redirects`.**
- How it gets into `build/web`: `flutter build web` copies every file under `web/` (other than the templated `index.html`/`flutter_bootstrap.js`) into the output (`flutter_tools/lib/src/build_system/targets/web.dart`, the "Copy other resource files out of web/ directory" step) [11]. So **commit `web/_redirects`**. `upload-artifact` keeps it, because the file isn't a dotfile, and `include-hidden-files: true` is set anyway.
- Rule order: `_redirects` rules run before `netlify.toml` rules, and the first match wins. Keep the SPA catch-all last [9].

## Sources

1. Flutter releases JSON (macOS): https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json (fetched 2026-10-19). Archive UI: https://docs.flutter.dev/install/archive
2. Local `flutter --version` (2026-10-19): Flutter 3.47.5 stable, rev 6a19cca564, Dart 3.13.4.
3. GitHub Releases API, `gh api repos/<repo>/releases/latest`, for actions/checkout, actions/upload-artifact, actions/download-artifact, subosito/flutter-action, r0adkll/upload-google-play. `npm view netlify-cli version`.
   - 3a. https://github.com/actions/checkout/releases/tag/v5.0.0 (minimum runner v2.327.1, Node 24)
   - 3b. https://github.com/r0adkll/upload-google-play/blob/main/README.md ("packageName must already exist… upload a manual apk or aab first"; `track` deprecated in favour of `tracks`)
   - 3d. https://github.com/subosito/flutter-action (README: `flutter-version-file`)
4. Flutter docs
   - 4a. https://docs.flutter.dev/deployment/android, "Configure signing in Gradle" (`key.properties`, `keystoreProperties`, `signingConfigs`)
   - 4b. https://docs.flutter.dev/deployment/ios, "Upload the app bundle to App Store Connect" (`xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey … --apiIssuer …`; `--export-options-plist`)
5. flutter_tools source, `packages/flutter_tools/lib/src/commands/build_ios.dart` in the local 3.47.5 SDK: `--export-method` defaults to `app-store`, `-allowProvisioningUpdates` is passed, and the instructions print `build/ios/ipa/*.ipa`.
6. cli/cli source, https://github.com/cli/cli/blob/trunk/pkg/cmd/secret/set/set.go, `getBody()`.
   - 6a. https://cli.github.com/manual/gh_secret_set
7. https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets ("If a secret has not been set … will be an empty string")
8. https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/#history-pushstate-and-single-page-apps
9. https://docs.netlify.com/manage/routing/redirects/overview/ (`_redirects` in the publish directory; rule processing order)
10. https://docs.netlify.com/api-and-cli-guides/cli-guides/get-started-with-cli/ ("Manual deploys": `netlify.toml` stored at the root of your project directory)
11. flutter_tools source, `packages/flutter_tools/lib/src/build_system/targets/web.dart` (copies `web/` resources into the build output)
