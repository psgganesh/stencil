# Spec: Foundation

**Status:** ready-for-agent
**Source:** the wayfinder map `.scratch/stencil-v1/map.md`. Every decision below links back to a resolved ticket under `.scratch/stencil-v1/issues/`. When this spec and a ticket disagree, this spec wins; record the disagreement as a comment.
**Order:** spec 1 of 5 (Foundation → CI/CD → Onboarding → marketing → app screens).

## Assumes

Nothing. The repo is the empty Flutter template: `MainApp` shows "Hello World!", the only dependency is `flutter_lints`, and there's no `test/` directory. The architecture rules in `AGENTS.md` → "Architecture" apply to everything below. Terms are in `GLOSSARY.md`; colours, type and components are in `DESIGN.md`.

## Problem Statement

stencil is meant to be a cross-platform Flutter boilerplate. It ships a marketing site on web and a signed-in app on web, macOS, Windows, iOS and Android. Today it's an empty template.

Four more specs (CI/CD, Onboarding, marketing, app screens) will each add screens. Without a shared base, each would reinvent the same things: theme, translations, routing, the layout shells, the data layer and the state views. They would drift apart, and none could run or be tested without a Firebase project.

The person building a product from stencil needs:
- an app that starts, routes correctly and looks right on every platform and width from day one;
- one place to rename the product;
- a fake data layer good enough to demo every screen without any accounts or keys.

## Solution

Foundation delivers everything the later specs share, so each of them only adds screens:

- **App identity:** one `app_identity.yaml` with a script that applies it to every platform.
- **Build settings:** the Android, macOS and web settings the later specs depend on.
- **The design system** from `DESIGN.md` as a Material 3 theme, in light and dark.
- **Fonts and languages:** bundled fonts and translations for all 10 languages.
- **Routing:** every route and redirect rule, with placeholder screens where later specs will put the real ones.
- **The three layout shells:** bottom bar, rail and web top bar, chosen by platform and width.
- **The shared widget kit:** cards, chips, rows, fields, buttons, the language button, the avatar, and the Empty, Error, Offline and Loading states.
- **App-wide state:** session, theme, language and onboarding progress.
- **A complete fake data layer:** auth, user, items with activity, alerts, contact messages and notification permission. It seeds realistic demo data, can simulate latency and failures, and supports deleting an account.
- **Firebase-config detection** that falls back to the fakes.

When it's done, a developer can run the app on any platform:
- signed out, they land where the launch rule says (marketing Home placeholder on web, Welcome placeholder on native);
- they can sign in through a minimal placeholder;
- they see the right shell for the window size;
- they can switch theme and language;
- and they can force each data state with a run flag.

## User Stories

1. As a developer building a product from stencil, I want the app name, app ID, build file name and Microsoft Store identity in one YAML file, so that renaming the product is a single edit.
2. As a developer, I want one command that applies the identity file to Android, iOS, macOS, Windows, Linux, web and the msix config, so that no native file keeps the old name.
3. As a developer, I want a check mode of that command that fails when any native file has drifted from the YAML, so that CI catches a hand-edited bundle ID.
4. As a developer, I want the identity constants available to Dart, so that the UI shows the app name from the same place.
5. As a developer, I want the app to run with no Firebase project, so that I can build and demo everything before any manual setup.
6. As a developer, I want the app to use Firebase automatically once the real config file is committed, and a run flag to force the fakes anyway, so that switching needs no code change.
7. As a developer, I want a run flag that adds latency to every fake load, so that I can see the loading skeleton.
8. As a developer, I want a run flag that makes every fake load fail with a chosen failure code, so that I can see the Error and Offline states.
9. As a developer, I want those run flags ignored in release builds, so that a shipped app never fakes failures.
10. As a user on any platform, I want the app to follow the light and dark designs exactly, so that it looks finished.
11. As a user, I want the theme to follow my system by default and let me choose Light, Dark or System, so that it matches my preference.
12. As a user, I want my theme choice remembered on this device, so that it persists across restarts.
13. As a user, I want the app in one of 10 languages (English, Hindi, Bengali, Tamil, Telugu, Marathi, Gujarati, Kannada, Malayalam, Punjabi), so that I can use it in my own language.
14. As a user, I want the app to start in my device language when it's one of the 10, and in English otherwise, so that the first screen already makes sense.
15. As a user, I want my language choice remembered on this device, so that it persists across restarts.
16. As a user reading an Indic script, I want text to render in a consistent bundled font on every platform, so that it looks the same everywhere.
17. As a web visitor in the EU, I want fonts served from the app's own host, not Google's, so that my IP address isn't sent to a third party.
18. As a user on a phone, I want a bottom navigation bar with Home, Items, Alerts and Settings, so that I can move around with my thumb.
19. As a user on a native tablet or desktop, I want a navigation rail with the logo, the four destinations and my avatar, so that wide screens use their space well.
20. As a web user on a wide window, I want a top bar with the logo, app name, destinations, search, language button and avatar, so that the app feels like a website.
21. As a web user at phone width, I want the mobile layout, so that the site works on my phone's browser.
22. As a user on desktop or web, I want content capped at 1120 wide and centred, so that lines don't stretch across a huge monitor.
23. As a user, I want tapping the avatar to open Settings, so that my account is one tap away.
24. As a user, I want a language button in the app bar that lets me switch language from anywhere, so that I never have to hunt for it.
25. As a signed-out web visitor, I want `/` to show the marketing Home, so that I learn about the product first.
26. As a signed-out native user who hasn't finished onboarding, I want the app to open onboarding, so that I can get started.
27. As a signed-out native user who has finished onboarding before, I want the app to open login, so that I can sign back in.
28. As a signed-in, onboarded user, I want the app to open `/app`, so that I'm straight back in.
29. As a signed-out user who opens `/app`, I want to be sent to `/login`, so that private screens stay private.
30. As a signed-in user who hasn't finished onboarding, I want `/app`, `/login` and `/signup` to send me to `/onboarding`, so that I finish setting up first.
31. As an onboarded user, I want `/login`, `/signup` and `/onboarding` to send me to `/app`, so that I don't repeat setup.
32. As a signed-out web visitor with no saved onboarding step, I want `/onboarding` to send me to `/signup`, so that web never shows the native-only Welcome.
33. As a user, I want an unknown route to land somewhere sensible, so that a bad link never shows a blank screen.
34. As a user, I want my session remembered across restarts, so that I don't sign in every time.
35. As a user, I want to sign in with any valid email and password, or with a tap on Google or Apple where they're offered, so that I can try the app before real auth exists.
36. As a user, I want signup with an email the app has already seen to say "An account with this email already exists.", so that the fake behaves like the real thing.
37. As a user who signed in with email, I want the app to remember that, so that only email users are offered "Change password" later.
38. As a Windows or Linux user, I want the Google and Apple buttons hidden, so that I'm never offered a sign-in that can't work here.
39. As a new user who has just signed in, I want 7 sample items and 3 welcome alerts ready, so that the app feels alive straight away.
40. As a user, I want sample activity spread over the last 14 days, so that the Home activity chart isn't flat.
41. As a user, I want every item change recorded as activity (created, edited, status changed), with my name, so that Item detail can show a history.
42. As a user, I want an alert raised whenever one of my items changes status, so that I notice changes.
43. As a user, I want to mark alerts read, one at a time or all at once, so that the Unread count is accurate.
44. As a user, I want a screen that's loading for more than 300 ms to show a skeleton in the shape of its content, with a thin progress bar, so that I know something is happening without a flash on fast loads.
45. As a user, I want a screen that failed to load to show "Something went wrong", the error code, "Try again" and "Contact support", so that I can recover or get help.
46. As a user, I want "Contact support" to open the Contact page with the topic set to Support and the error code filled in (in the browser on native), so that I don't have to describe the error.
47. As a user, I want a screen that failed because I'm offline to show "You're offline" with "Try again", so that I know it isn't the app's fault.
48. As a user, I want an empty space to explain what goes there and how to add the first one, so that I know what to do next.
49. As a user, I want a failed reload to keep what I'm already looking at and tell me in a snackbar, so that I don't lose context.
50. As a user, I want to delete my account and everything in it, so that I control my data.
51. As a user who deletes their account, I want to land on login (native) or the marketing Home (web) with nothing left behind on the device, so that it's really gone.
52. As a user on Android 13+, iOS or macOS, I want the app to ask for notification permission only when I tap Allow, so that I'm not surprised by a system prompt.
53. As a user who denied notifications, I want a way to open the OS settings, so that I can change my mind.
54. As a web user whose browser has no notifications, I want to be told it isn't available, rather than see a false "Allowed".
55. As a screen-reader user, I want every icon button labelled, rows and tiles read as one item, headings marked, and the chart summarised in words, so that I can use the app without sight.
56. As a keyboard user on desktop or web, I want a visible focus ring, a logical tab order, Esc to close dialogs, and focus moved to the page heading after navigation, so that I can use the app without a mouse.
57. As a user with large text, I want the app to work at up to 200% text size without clipping or overflow, so that I can read it.
58. As a user who prefers reduced motion, I want shimmer, chart animation and page transitions turned off, so that the app doesn't make me uncomfortable.
59. As a developer, I want the Android, macOS and web build settings already correct (minSdk, desugaring, compileSdk, release signing, entitlements, SPA rewrite), so that later specs and CI build without surprises.
60. As a developer working on a later spec, I want placeholder screens on every route, so that I only replace a placeholder, never touch routing.

## Implementation Decisions

### Packages and platform settings

- **Dependencies:**
  - `flutter_riverpod ^3.4.3`, `shared_preferences ^2.5.6`, `flutter_localizations` (SDK) with `intl`;
  - `flutter_local_notifications ^22.3.0`, used only for its permission calls;
  - `url_launcher`;
  - `firebase_core ^5.0.0`, `firebase_auth ^7.0.0` and `cloud_firestore ^7.0.0`. These are added now so the config check compiles, but **v1 uses no Firebase repository**.
  - No codegen packages, no `flutter_hooks`, no `google_fonts`, no connectivity package. Source: Package versions (07), Permissions step and notification toggles (10), Empty, error, loading and offline states (13).
- **Android:** minSdk 24, core library desugaring on, `compileSdk` 37 or higher, a notification icon, and a release `signingConfig` that reads the keystore from the CI environment and falls back to debug signing when it's absent.
- **macOS:** deployment target 12.0. Release and debug entitlements gain `com.apple.security.network.client` and Keychain Sharing (macOS and Windows distribution, 18).
- **Web:** a `_redirects` file with `/*  /index.html  200` for Netlify (Review of the reference CI workflow, 06). Also `fontFallbackBaseUrl` pointed at the app's own host (Fonts for ten languages, 04).

### App identity

- **The file:** `app_identity.yaml` at the repo root holds `app_name`, `app_id` (reverse DNS), `artifact_name`, and the Microsoft Store identity (identity name, publisher, publisher display name). Placeholder values: `Stencil`, `com.example.stencil`, `stencil`, plus clearly fake Store values.
- **The command:** a Dart command-line tool rewrites:
  - Android `applicationId` and `namespace`;
  - the iOS and macOS `PRODUCT_BUNDLE_IDENTIFIER` and display name;
  - the Windows and Linux binary and window names;
  - the web manifest and page title;
  - the msix config.

  It also writes a Dart constants file the UI reads.
- **Check mode:** with `--check`, the command changes nothing and exits non-zero, listing every drifted file. It's idempotent: running it twice changes nothing the second time. Source: Manual-tasks document (19).

### Theme

- **Schemes:** one Material 3 `ColorScheme` per brightness, **set explicitly** from the `DESIGN.md` tables, not from a seed colour. Primary stays `#00639B` in dark.
- **Custom roles** (Selected and link, Track, Gain container and friends, Accent fill, muted On primary container) live in a `ThemeExtension`.
- **The accessibility exception:** in dark mode, a filled button on a Primary container surface uses a `#96CCFF` fill with `#001D32` text (`DESIGN.md`; Accessibility rules, 16).
- **Type and components:** the type scale is the Material 3 default on Roboto. Component themes (buttons, text fields, chips, cards, segmented control, switch, navigation bar and rail, dialog, snackbar) follow `DESIGN.md` → Components.
- **Theme mode:** a keep-alive app-wide notifier holds Light, Dark or System, defaulting to System. It's saved to `shared_preferences`.

### Fonts and languages

- **Fonts:** bundled static TTFs, Roboto plus the eight Noto Sans Indic families (Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam, Gurmukhi) at weights 400 and 500. They're declared as pubspec fonts and set once as `fontFamilyFallback` on the text theme. (04)
- **Translations:** gen-l10n with `generate: true`, with ARB files for the 10 languages in `DESIGN.md` → Languages. English is complete; the other 9 are machine-drafted, each marked for review. **Foundation adds only its own strings** (shells, shared widgets, state views, placeholder screens, notification and error copy). Each later spec adds its own strings to all 10 files.
- **Language:** a keep-alive app-wide notifier holds the chosen language. With nothing saved, it uses the device language if that's one of the 10, otherwise English. It's saved to `shared_preferences`. It changes the language straight away, with no restart (What onboarding Preferences control, 15).
- **Language button:** one app-wide widget in two sizes: icon-only (mobile top bar) and labelled with the current native name (wider layouts). It opens a picker listing the 10 languages by native name with the English name beneath. Its screen-reader label is "Language: <name>".

### Platform capabilities

A keep-alive `PlatformCapabilities` value holds four flags:
- `googleSignIn` and `appleSignIn`: false on Windows and Linux;
- `pushDelivery`: false on Windows and Linux;
- the notification-permission kind: runtime prompt (Android 13+, iOS, macOS), on by default (Android 12 and lower, Windows, Linux), browser (web with the Notification API), or unavailable (web without it).

Screens and view models read these flags and never check the platform themselves. Tests override the value. Source: Sign-in and data on Windows (12).

### Routing

- **No routing package:** `MaterialApp` named routes with `onGenerateRoute`.
- **Routes registered by Foundation**, each showing a **placeholder screen** that names the route and the spec that will replace it:
  - onboarding and auth: `/onboarding`, `/signup`, `/login`;
  - app: `/app` (Home), `/app/items`, `/app/items/new`, `/app/items/<id>`, `/app/items/<id>/edit`, `/app/alerts`, `/app/settings`, `/app/settings/profile`;
  - marketing, web only: `/`, `/features`, `/whats-new`, `/about`, `/articles`, `/premium`, `/reviews`, `/press`, `/changelog`, `/contact`, `/privacy`, `/terms`, `/support`, `/delete-data`.

  The `/login` and `/signup` placeholders include a **minimal developer sign-in** (email + password, plus Google and Apple buttons where the capabilities allow). Through the fake auth repository, it creates a session, so routing can be exercised before the Onboarding spec lands. The Onboarding spec replaces it.
- **Redirects** (Login, signup and onboarding routes, 02; `AGENTS.md` → Routing):

  | Who | Asking for | Goes to |
  |---|---|---|
  | signed out | `/app…` | `/login` |
  | signed in, not onboarded | `/app…`, `/login` or `/signup` | `/onboarding` |
  | onboarded | `/login`, `/signup` or `/onboarding` | `/app` |
  | on web, signed out, no saved onboarding step | `/onboarding` | `/signup` |
  | on native | any marketing route | the launch rule below |

- **Launch rule:**
  - **web:** `/`;
  - **native:** `/app` if signed in and onboarded, otherwise `/onboarding` if onboarding isn't finished, otherwise `/login`.
- **Unknown routes:**
  - an unknown `/app/items/<id>` goes to `/app/items`;
  - any other unknown route goes to `/` on web and to the launch rule on native.
- **Focus:** after every route change, focus moves to the page heading.

### Layouts and shells

- **Layout choice:** by platform first, then width.
  - **Web:** the web layout at 600 and wider, the mobile layout below that.
  - **Native:** below 600 is mobile, 600–1199 tablet, 1200 or more desktop.

  The chosen layout is exposed to screens, and every layout of a screen reads the same view model. Source: Device layouts (03); `.scratch/stencil-v1/prototypes/device-layouts.md`.
- **The three shells** wrap the four app destinations (Home, Items, Alerts, Settings):

  | Shell | Used by | Contents |
  |---|---|---|
  | **Mobile** | mobile layout | bottom navigation bar (80 tall, pill indicator), plus a top bar with title, icon-only language button and search icon |
  | **Rail** | tablet and desktop | 80-wide rail: logo mark, four destinations, avatar at the bottom; plus a page header with title, subtitle, search icon and labelled language button |
  | **Web top bar** | web layout | about 72 tall: logo, app name, four pill links, search, labelled language button, avatar |

- **Content width:** desktop and web cap content at 1120, centred. Tablet and mobile fill the width with 24 and 16 px side padding.
- **Search icon:** it appears as designed but does nothing in v1 (search results are out of scope). Its label says "Search".
- **Avatar:** opens `/app/settings`. It shows the user's initial (from the display name, or else the email before the @), or a person icon. Its screen-reader label is "Settings".
- **Hidden shell:** sub-pages that hide the bottom bar (the item form and Edit profile, built later) use a shell option that Foundation provides.

### Shared widget kit

All built from `DESIGN.md` → Components. Screen widgets get their values and callbacks from the screen and don't read providers; the language button and the avatar are the only exceptions.
- **Building blocks:**
  - outlined card;
  - filled card variants (Featured on Primary container, Tip on Tertiary container);
  - status chip (Active, Draft, Archived; always labelled; read as "Status: X");
  - filter chip;
  - item row (letter avatar, title, "summary · date", status chip, merged into one screen-reader node);
  - metric tile (merged into one screen-reader node);
  - buttons (filled, tonal, outlined, text, extended FAB);
  - outlined text field with the label above and an error message below;
  - segmented control; toggle row; selectable option card;
  - image placeholder (hidden from screen readers);
  - step progress ("Step N of 5").
- **The skeleton** comes in four shapes:

  | Shape | Used by |
  |---|---|
  | Home | title, 3 tiles, a list card |
  | List | title, 6 rows; used by Items and Alerts |
  | Detail | header, image block, two cards |
  | Settings | three cards |

  It runs with the 4 px progress bar. The shimmer is turned off under reduced motion.
- **State views:**

  | State | Content |
  |---|---|
  | **Empty** | Configurable: icon, title, body, optional filled button, optional outlined button |
  | **Error** | Fixed copy plus the failure code; "Try again" and "Contact support" |
  | **Offline** | Fixed copy; "Try again" only |
  | **Placeholder** | Icon, title and body, with no buttons. Used for the wide split's "Select an item" |

  A state replaces only the content area; the shell and title stay.
- **Async content wrapper:** one wrapper turns an `AsyncValue` into the right view (source: Empty, error, loading and offline states, 13):
  - **first load:** nothing for 300 ms, then the skeleton;
  - **error with no data:** the Error state (or Offline for the `offline` code);
  - **data:** the content;
  - **reloading with data:** the content plus the progress bar only;
  - **failed reload with data:** keeps the data and shows a snackbar.
- **"Contact support":** opens `/contact?topic=support&code=<code>`. On web this is in-app; on native it opens the site URL from the config file in the browser through `url_launcher`.
- **Downloads and social config:** one config file holds the site URL, the four store URLs (empty by default) and the social links. Foundation reads only the site URL; the marketing spec uses the rest.

### Session, auth and app-wide state

- **`AuthRepository`** (fake, behind an interface), from Real email sign-in flow (01):
  - **Sign in with email and password:** any valid email with a non-empty password succeeds.
  - **Sign up:** the password needs at least 8 characters. An email the fake has already seen fails with "taken".
  - **Google and Apple:** a tap signs in a fake user.
  - **Password reset:** pretends to send a reset email.
  - **Sign-in method:** the fake records it (email, Google or Apple) on the session.
  - **Persistence:** the fake saves the signed-in email and sign-in method in `shared_preferences`, so a restart keeps the session.
  - **Sign out** clears the session.
- **The session** is a keep-alive app-wide notifier: signed out, or signed in with uid, email and sign-in method. Routing watches it.
- **Onboarding progress** is a keep-alive app-wide notifier: the saved step and whether onboarding is finished, saved in `shared_preferences`. Foundation provides the storage and the "finished" flag that routing reads; the Onboarding spec drives the steps.

### Fake data layer

Every repository is an abstract interface with an in-memory fake, provided by a keep-alive provider and overridable in tests. The shapes are from Firestore data model and security rules (08).
- **`UserRepository`:** the user record: `displayName`, `role`, `notifications {push, emailUpdates, weeklySummary}` (all false by default), `onboardingFinishedAt`, `createdAt`. It's watchable, and it can update fields.
- **`ItemsRepository`:**
  - **Reads:** watch the list; watch one item with its latest 3 activity entries.
  - **Create** sets the owner to the display name and writes a `created` activity entry.
  - **Update** writes an `edited` entry, plus `statusChanged` when the status changes.
  - **Delete** removes the item and its activity.
  - **Categories:** a fixed list of 4 placeholder categories in app code.
  - **Status:** Active, Draft or Archived.
- **`AlertsRepository`:**
  - watch the list, newest first;
  - mark one alert read; mark all read;
  - raise an alert (kind info, success or warning; title; body);
  - seed the 3 welcome alerts (one of each kind).

  **A status change on an item raises an alert** through this repository, in the same step as the item change.
- **`ContactRepository`:** create a message (name, email, topic from General / Support / Billing / Press / Other, message, optional uid). Messages are kept in memory only.
- **`NotificationPermissionRepository`:** `flutter_local_notifications` behind the interface, from Permissions step and notification toggles (10).
  - **Status** is one of: not asked, granted, denied, on by default, unavailable. It's derived from the capabilities kind, the plugin's check, and an "asked once" flag in `shared_preferences`. The flag exists because on iOS and macOS the plugin can't tell "never asked" from "denied".
  - **Request** shows the OS prompt.
  - **Open settings** opens the app's OS settings (Android, iOS, macOS only).
  - **Status is re-checked** when the app comes back to the foreground.
- **Demo seed:** on sign-in or startup, if the fake has no data for this user, it seeds:
  - **7 items:** a mix of Active, Draft and Archived, with placeholder names and summaries, each with a few activity entries whose dates are spread over the last 14 days (Home dashboard content, 09);
  - **the 3 welcome alerts:** in v1 these are seeded at startup when the data is empty. The Onboarding spec also seeds them at Done for brand-new users.

  Display name and role don't survive a restart, so the email-prefix fallback applies.
- **Failures:**
  - **Codes:** repositories throw one `AppFailure` type with a stable code: `offline`, `permission`, `not-found`, `unknown`.
  - **`FAKE_LATENCY_MS`** (an integer, default 0) delays every fake load.
  - **`FAKE_FAILURE`** (`offline`, `unknown` or `permission`) makes every fake load fail with that code.
  - **Release builds** ignore both flags.
- **Firebase detection:** a stub Firebase options file (the shape the FlutterFire CLI generates, every platform throwing) is committed. At startup the app tries to read the options and initialise Firebase; any failure, or `--dart-define=USE_FAKES=true`, means the fakes are used (Firebase support on each platform, 05). In v1 the fakes are used in both cases, because no Firebase repository exists yet. Foundation records which way it went, so the later Firestore effort only swaps overrides.

### Delete account

One app-wide action, used later by the Settings button and the `/delete-data` page (08):
1. Delete everything for the user: items and their activity, alerts, then the user record.
2. Delete the auth user. If auth reports that a recent sign-in is required, the action returns that outcome, so the screen can ask the user to sign in again and retry.
3. Clear local preferences, including the fake session, theme, language and onboarding progress.
4. Go to `/login` on native, or `/` on web.

Contact messages are kept.

### Accessibility (applies to everything above)

The rules are from Accessibility rules (16):
- **Standard:** WCAG 2.1 AA, with 44–56 px touch targets.
- **Icon-only buttons** get a `Tooltip` with a translated label.
- **Page and card titles** are headings.
- **Reading order:** the mobile order on every layout.
- **Text scale:** clamped at 2.0. Only the nav labels may truncate.
- **Keyboard (desktop and web):** visible 2 px focus ring, Esc closes dialogs, and dialogs trap focus. Foundation provides the focus and keyboard plumbing; the specific shortcuts (Ctrl or ⌘ + S, list arrows) belong to the screens that use them.
- **Reduced motion:** `MediaQuery.disableAnimations` turns off shimmer and page transitions.

### Startup

`main()` does the following, in order:
1. creates `SharedPreferencesWithCache`;
2. runs the Firebase detection;
3. builds the `ProviderScope` with the shared-preferences and repository overrides, and with automatic retry turned off (`retry: (_, _) => null`);
4. runs the app.

## Testing Decisions

- **What a good test is:** it checks behaviour a user or a later spec relies on, through a public seam. It doesn't check widget internals, notifier fields or private helpers.
- **Seam 1, the app's root widget**, pumped with provider overrides (repositories, `SharedPreferencesWithCache` backed by `InMemorySharedPreferencesAsync`, `PlatformCapabilities`, session) at a given surface size and platform. It covers:
  - every redirect rule and the launch rule (signed out, signed in not onboarded, onboarded; web and native);
  - the unknown-route fallbacks;
  - the shell chosen at each width and platform;
  - the avatar opening Settings;
  - theme switching (and persistence across a re-pump);
  - language switching and the device-language default;
  - the async wrapper's states through `FAKE_*`-equivalent repository overrides (skeleton after 300 ms, Error with code, Offline, reload keeping data);
  - Google and Apple hidden on Windows and Linux;
  - delete account landing on the right route with preferences cleared.

  Each screen-level test runs in light and dark at mobile width and adds `meetsGuideline` for `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline`, plus one run at text scale 2.0 with no overflow errors.
- **Seam 2, the repository contracts**, through `ProviderContainer.test()`, with retry off. One contract suite per repository interface, run against the fake, so the later Firestore repositories can run the same suite. It covers:
  - the seed (7 items, statuses, activity dates within 14 days, 3 alerts);
  - activity entries on create, edit and status change;
  - an alert raised on a status change;
  - mark read and mark all read;
  - the taken-email signup;
  - the session surviving a restart (a new container over the same in-memory preferences);
  - the sign-in method;
  - the notification-permission status mapping for each capabilities kind, including the "asked once" flag;
  - the latency and failure flags (injected through the repository's constructor or config, not real `--dart-define`s);
  - delete account removing everything except contact messages.
- **Seam 3, the identity command:** run against a temporary copy of the native files. It covers that every listed file is rewritten, that a second run changes nothing, and that `--check` exits non-zero and names the file after one is edited by hand.
- **Prior art:** none in the repo (there's no `test/` yet). These tests set the patterns the later specs copy. Tests mirror the `lib/` layout under `test/`. No golden tests.

## Out of Scope

- **Real screens:** onboarding, marketing pages and the app screens (only placeholders here). They belong to the Onboarding, marketing and app screens specs.
- **CI/CD:** the GitHub Actions workflow and `docs/manual-tasks.md`. They belong to the CI/CD spec.
- **Firebase and Firestore:** the Firestore repositories, `firestore.rules`, Firebase-backed auth, offline detection and the offline banner. They come in a later effort.
- **Real Google and Apple sign-in,** real purchases and RevenueCat, push and email delivery, search results, golden tests, and Linux CI.
- **Direct desktop downloads** (a notarised `.dmg` or a signed `.exe`).

## Further Notes

- Every decision here is traced in `.scratch/stencil-v1/map.md` → Decisions so far. The ticket numbers in brackets point to `.scratch/stencil-v1/issues/`.
- **Sizing:** Foundation is large on purpose. `/to-tickets` should slice it into about one ticket per area, each runnable and tested on its own. Roughly in dependency order:
  1. packages and platform settings, plus identity;
  2. theme and fonts;
  3. l10n and the language notifier;
  4. capabilities and layout selection;
  5. the routing skeleton and placeholders, plus the session and the fake auth;
  6. the three shells;
  7. the shared widget kit;
  8. the state views and async wrapper;
  9. the user, items and alerts fakes, plus the seed and failure flags;
  10. contact and notification-permission repositories;
  11. delete account.
- **Placeholder screens** must be trivially replaceable: a later spec swaps the widget that a route builds and touches nothing in routing.
