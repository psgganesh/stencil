# Map: stencil v1, from GOAL.md to five specs

Label: wayfinder:map
Source: `GOAL.md`

## Destination

Five specs ready for implementation, each to be turned into Codex tickets with `/to-spec` and then `/to-tickets`: **Foundation**, **Onboarding** (7 screens), **app screens** (Home, Items, Item detail, Alerts, Settings), **marketing** (13 pages plus the legal and support routes) and **CI/CD** (web, Android, iOS). The map is done when nothing is left to decide before those specs are written.

## Notes

- **Roles:** Claude Code only plans: it grills, researches, and writes maps, specs and tickets as markdown. **All implementation and code is written by Codex**, following `AGENTS.md` → "Implementation workflow". Prototype tickets are resolved with ASCII or markdown sketches, never code.
- **Git:** the user commits and pushes by hand. Sessions don't commit, push or create branches. Research findings are saved in `.scratch/stencil-v1/research/`, not on a research branch.
- **Read first:** `GLOSSARY.md` (domain terms), `DESIGN.md` (design system, screen references and States), `AGENTS.md` → "Architecture", the screen PNGs in `.refs/design/`, and the reference workflow `.refs/.github/workflows/main.yml`.
- **Skills:** call grilling and domain-modeling for grilling tickets, prototype for prototype tickets, and research for research tickets. Update `GLOSSARY.md` as terms are settled.

### Settled while charting (2026-10-19)

- **Architecture:** MVVM with Riverpod only, no code generation (no riverpod_generator, no freezed), and immutable state classes with `copyWith`. The folder layout is by feature, with a shared `core/`. Theme mode, language and onboarding progress are saved with `shared_preferences`. Onboarding answers stay in memory until Done, and the step it was on is saved so it can resume. Widget UI state also uses Riverpod (autoDispose providers). Only Flutter controller objects stay in a `StatefulWidget`, and `flutter_hooks` isn't used. Riverpod 3 details: automatic retry is off; screen view models clear themselves while app-wide state, repositories and onboarding stay alive; state classes implement `==` and `hashCode`; new Firebase releases with Android minSdk 24 and macOS 11 (Q28–Q31, in `AGENTS.md`). Full rules are in `AGENTS.md` → "Architecture".
- **Data:** each repository has a fake in-memory version, used by default, and a Firestore version used once the Firebase config is present. The app and its tests run without a Firebase project. Revised by the Firestore data model ticket: v1 builds only the fakes, and Firestore is a later effort.
- **item** is a placeholder entity with a working list, detail view and create/edit. The feed is called **alerts**; delivery settings are called **notifications** (see `GLOSSARY.md`).
- **Auth for now:** any valid email, or a tap on Google or Apple, signs in a fake user immediately.
- **Launch:** on web, `/` is the marketing Home. On native platforms there's no marketing, and the app opens to `/app` if signed in, otherwise `/onboarding` if onboarding isn't finished, otherwise `/login`.
- **Layouts:** chosen by platform first, then width. On web, the web layout is used except at phone width, which gets the mobile layout. On native, below 600 is mobile, 600–1199 tablet, and 1200 or more desktop.
- **Languages:** Flutter's built-in localization (gen-l10n). English is complete; the other 9 languages are machine-translated drafts marked for review.
- **marketing routes:** `/`, `/features`, `/whats-new`, `/about`, `/articles`, `/premium`, `/reviews`, `/press`, `/changelog`, `/contact`, plus `/privacy`, `/terms`, `/support`, `/delete-data`. Path URLs, with a Netlify rewrite to `index.html`.
- **marketing content:** placeholder content bundled with the app. Articles and Changelog are loaded from local data files. No CMS.
- **Contact Us** saves through a repository and sends no email. **Premium** buttons go to `/signup`. Downloads and social links come from one config file. **`/delete-data`** is a public page with instructions, plus a delete button when the user is signed in.
- **CI** builds and deploys web, Android and iOS, matching the reference workflow. Empty GitHub secrets may be created.
- **Testing:** every ticket adds view model and repository unit tests against the fakes, plus at least one widget test for each new screen (light, dark, and mobile width). No golden tests.

## Decisions so far

<!-- one line per resolved ticket: [title](issues/NN-slug.md): gist -->

- [Review of the reference CI workflow](issues/06-reference-ci-workflow-review.md): Flutter 3.47.5 stable with Dart 3.13.4 matches `pubspec.yaml`. The macOS jobs don't pin Flutter. Fastlane and ExportOptions aren't needed. The repo still needs `.github/workflows/main.yml`, `web/_redirects` and release signing in `build.gradle.kts`. Secrets that are never set evaluate to `''`. The workflow hard-codes the identifiers `au.com.devhustlers.catalyst` and `Catalyst.ipa`.
- [Firebase support on each platform](issues/05-firebase-platform-support.md): Android, iOS and web are fully supported. macOS is in beta. Windows supports core, auth and Firestore for development only, with no FCM and no Google or Apple sign-in. Detection: commit a stub `firebase_options.dart`, and if it throws, fall back to the fakes.
- [Fonts for ten languages](issues/04-fonts-for-ten-languages.md): bundle Roboto plus the eight Noto Sans Indic fonts as static weights 400 and 500 in pubspec `fonts:` (about 2.4 MB, or about 1.1 MB gzipped on web), use them as `fontFamilyFallback`, point web's `fontFallbackBaseUrl` at our own server for GDPR, and don't use `google_fonts`.
- [Package versions](issues/07-package-versions.md): `flutter_riverpod ^3.4.3`, `firebase_core ^5.0.0`, `firebase_auth ^7.0.0`, `cloud_firestore ^7.0.0` (released 2026-10-15; they need Android minSdk 24 and macOS 11), `shared_preferences ^2.5.6` (use `SharedPreferencesWithCache`), gen-l10n with `generate: true`. Riverpod 3 without codegen: `Notifier`/`AsyncNotifier`, `isAutoDispose: true`. Avoid `legacy.dart` providers.
- [Login, signup and onboarding routes](issues/02-login-signup-onboarding-routes.md): one onboarding flow in one view model, with steps as state. `/onboarding` resumes the flow and has no route guard; the view model gates the steps after SignIn. `/signup` opens at Language, and `/login` is SignIn alone. Welcome is native-only, and marketing shows "Sign in" and "Get started" (or "Open app"). Language is "Step 1 of 5" and SignIn is step 2. Profile has no back arrow.
- [Real email sign-in flow](issues/01-real-email-sign-in-flow.md): email + password, with the email asked first (ADR 0001). The password step is a second state of SignIn, not a new route. The fake goes through the same screens. One user per email. Verification never blocks, and password reset happens on Firebase's hosted page, so the app needs no deep links. Onboarding status is saved on the user's record once Firestore is in; until then, assume a single device.
- [Device layouts: mobile, tablet, desktop, web](issues/03-device-layouts.md): mobile has a bottom bar; tablet and desktop have a rail; web has a top bar. Desktop and web content is capped at 1120, centred. Items on desktop and web is always a list + detail split, routed as `/app/items/<id>`, with a "Select an item" placeholder; tablet and mobile keep a separate detail page. The avatar opens Settings. Onboarding is hero + sheet on mobile and tablet, split screen on desktop and web. ASCII sketch in `prototypes/device-layouts.md`.
- [Firestore data model and security rules](issues/08-firestore-data-model.md): v1 builds only the in-memory fakes, and Firestore is a later effort. Data is private per user under `users/{uid}`. Items have name, summary, description, category (fixed list), status Active/Draft/Archived, ownerName and dates, and their activity is a subcollection written automatically. Alerts are seeded when onboarding is Done and raised on status changes, with filters All and Unread, on a screen titled "Alerts". The user record holds displayName, role, notifications and onboardingFinishedAt; theme and language stay on the device. Contact messages are create-only. The fake keeps the session in `shared_preferences` and reseeds demo data. Delete account runs on the client.
- [Home dashboard content](issues/09-home-dashboard-content.md): everything on Home is computed live from the items and alerts repositories, with fixed translated copy. Featured chart = activity per day over 14 days (desktop and web only; the seed spreads activity dates). Progress = Active of non-archived; Next up = latest Draft. Tiles = Active, Drafts and Unread alerts, each linking to a filtered list. Recent = 4 latest non-archived. Tip = 1 of 3 ARB tips by day, with in-app links. Invite = OS share sheet (clipboard fallback).

## Not yet specified

- **Edit profile:** Settings has an "Edit profile" button, but there's no design for that screen. What it edits depends on the Onboarding Profile step.
- **Onboarding Preferences:** what the preference options actually control in the app, and where they're saved.
- **Spec boundaries and order:** exactly what belongs in Foundation and what in each feature spec, and the order the specs are handed to Codex. This depends on most of the tickets below.
- **Accessibility:** semantics labels, screen reader order, text scaling up to 200%, and keyboard and focus order on desktop and web.
- **macOS and Windows distribution:** building, signing and notarisation, and where the Downloads links point. Revisit once the Firebase-on-desktop research is in.
- **Manual-tasks document:** a checklist for the human covering creating the Firebase project, certificates and keys, service JSON files, RevenueCat, choosing the app name and bundle ID, turning on the Email/Password provider in Firebase Auth (and leaving email enumeration protection on), and filling in the GitHub secrets. Its shape depends on the research and CI tickets. The reference workflow hard-codes `au.com.devhustlers.catalyst` and `Catalyst.ipa`, so the CI spec has to read the app ID and the artifact name from the same single place as the app name, along with the self-hosted runner setup (keychain certificate, Xcode account, JDK 17, Android SDK, and the first AAB uploaded to Play by hand).

## Out of scope

- The manual work itself: Apple and Google certificates and keys, service JSON files, RevenueCat entitlements and products, creating the Firebase project, and choosing the real app name and bundle ID. These go into the manual-tasks document, but they're done by hand.
- Real Google and Apple sign-in, and real purchases.
- Search results. Every app screen has a search icon, but there's no design for results.
- Linux: the folder stays, but there's no CI and no testing for it.
- Golden (screenshot) tests, a CMS for marketing content, and sending email from Contact Us.
- The Firestore repositories, the full `firestore.rules` (validation, size limits, App Check), and error handling and persistence edge cases: a separate effort after v1 ([Firestore data model and security rules](issues/08-firestore-data-model.md) records the shapes and the rules principle).
