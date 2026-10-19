# Spec: Onboarding

**Status:** ready-for-agent
**Source:** the wayfinder map `.scratch/stencil-v1/map.md`; decisions point to `.scratch/stencil-v1/issues/` by ticket number. Designs: `.refs/design/{mobile,tablet,desktop,web}/onboarding/{light,dark}/`.
**Order:** spec 3 of 5 (Foundation → CI/CD → **Onboarding** → marketing → app screens).

## Assumes

**Foundation** and **CI/CD** are done:
- **Routing:** every route and redirect rule, with placeholder screens at `/onboarding`, `/signup` and `/login` (including a minimal developer sign-in, which this spec removes).
- **App-wide state:** the session (with sign-in method), the theme, language and onboarding-progress notifiers (saved step, finished flag).
- **Platform:** `PlatformCapabilities`, layout selection, the language button and the step-progress widget.
- **Shared widgets:** text field, selectable tile and option card, segmented control, toggle row, buttons, image placeholder.
- **Data layer:** the fake `AuthRepository`, `UserRepository`, `AlertsRepository` (including seeding the 3 welcome alerts) and `NotificationPermissionRepository`.
- **The ARB setup** for 10 languages.
- **CI** builds every platform on each push.

## Problem Statement

A new user opening stencil needs to:
- understand what the app is;
- pick a language they can read;
- create an account or sign in;
- say who they are;
- choose how the app looks and how it reaches them;
- decide about notifications,

all before landing in the app.

Today, `/onboarding`, `/signup` and `/login` are placeholders with a developer sign-in. Without a real flow there's no way to set the display name, role or notification preferences, and onboarding is never marked finished properly.

The flow also has to:
- resume where the user left off;
- never let a signed-out user past sign-in;
- behave differently on web (no Welcome, marketing does that job) and native;
- look right as a sheet on phones and tablets and as a split screen on desktop and web.

## Solution

One onboarding flow, driven by one keep-alive view model. Its steps are state in the view model, not routes:

**Welcome** (native only) → **Language** (Step 1 of 5) → **SignIn** (Step 2, with an email state and a password state) → **Profile** (Step 3) → **Preferences** (Step 4) → **Permissions** (Step 5) → **Done**.

- **How it's reached:**
  - `/onboarding` resumes the flow at the saved step;
  - `/signup` opens it at Language, with SignIn in signup mode;
  - `/login` shows SignIn on its own, in login mode, with no step progress.
- **When answers are saved:**
  - language and appearance are applied and saved the moment they're chosen;
  - everything else is held until **Done**, which writes it to the user record, marks onboarding finished, makes sure the welcome alerts exist, and opens the app.

## User Stories

1. As a new native user, I want a Welcome screen with the app name, a one-line pitch and three feature highlights, so that I know what I'm signing up for.
2. As a new native user, I want "Get started" to take me to language selection, so that the rest of the flow is in my language.
3. As a web visitor, I want to skip Welcome, because the marketing pages already introduced the app, so that I get to sign-up faster.
4. As a new user, I want to pick from 10 languages, each shown by its native name with the English name beneath, so that I can find mine even if the current language is foreign to me.
5. As a new user, I want the app to switch language the moment I tap one, so that I can check it's right before continuing.
6. As a new user, I want my language remembered on this device right away, so that it survives a restart mid-flow.
7. As a new user, I want "Step N of 5" with a progress bar on every step from Language to Permissions, so that I know how far I am.
8. As a user, I want a language button on every step, so that I can change language at any point.
9. As a new user, I want to enter my email first and then a password, so that each screen asks one thing.
10. As a new user, I want "Continue with email" to show the password state with my email read-only and a "Change" link, so that I can fix a typo without starting over.
11. As a new user creating an account, I want the password state titled "Create a password", with "Use at least 8 characters." shown when it's too short, so that I know the rule.
12. As a returning user on `/login`, I want the password state titled "Enter your password", with a "Forgot password?" link, so that I can get back in.
13. As a returning user who forgot their password, I want "Forgot password?" to say "If an account exists for <email>, we've sent a reset link.", so that I know what to do next without being told whether the account exists.
14. As a user, I want a show/hide toggle on the password field, so that I can check what I typed.
15. As a user who mistyped their password, I want "Email or password is incorrect." with a "New here? Create an account" link, so that I can recover either way.
16. As a new user whose email is already taken, I want "An account with this email already exists." with a "Sign in instead" link, so that I don't create a duplicate.
17. As a user whose email already uses another sign-in method, I want "This email already uses another sign-in method.", so that I know to use Google or Apple instead.
18. As a user, I want to move between `/login` and `/signup` without retyping my email, so that switching is painless.
19. As a user on a platform that supports them, I want "Google" and "Apple" buttons under "or continue with", so that I can sign in with an account I already have.
20. As a Windows or Linux user, I want those buttons and the "or continue with" divider hidden, so that I'm only offered what works.
21. As a user, I want a short privacy note and "By continuing you agree to the Terms of Service and Privacy Policy." on SignIn, so that I know what I'm agreeing to.
22. As a user, I want the terms and privacy links to open the Terms and Privacy pages (in the browser on native), so that I can read them.
23. As a new user, I want the email state's back arrow to return to Language, and the password state's to return to the email state, so that back always means one step back.
24. As a new user who has just signed in, I want to tell the app my name and pick what best describes me from three options, so that it can personalise my experience.
25. As a user, I want my name to be optional, so that I can continue without it; the app then uses the part of my email before the @.
26. As a signed-in user on Profile, I want no back arrow, so that I can't step back over sign-in.
27. As a user, I want Preferences to let me choose Light, Dark or System, with the theme changing live, so that I see my choice immediately.
28. As a user, I want Preferences to let me turn on Email updates and Weekly summary, both off by default, so that the app only emails me if I ask.
29. As a user, I want Push decided only on the Permissions step, so that I'm never asked about push twice in a row.
30. As a user on Android 13+, iOS or macOS, I want "Allow" on the Notifications card to show the system prompt, so that I grant permission only when I choose to.
31. As a user who granted notifications, I want the card to show "✓ Allowed", so that I can see it worked.
32. As a user who denied notifications, I want an "Open settings" button (or, on web, a line saying it's blocked in the browser settings), so that I can change my mind later.
33. As a user on Windows, Linux or older Android, I want the card already showing "✓ Allowed", so that I'm not asked for something my device doesn't need.
34. As a web user whose browser can't show notifications, I want the card to say "Not available in this browser", so that I'm not misled.
35. As a user, I want "Continue" and "Skip for now" on Permissions, neither of which blocks me, so that I can decide later.
36. As a user, I want my push preference set from what I chose on Permissions (on if granted, off if denied or skipped), so that Settings shows the truth.
37. As a user, I want a Done screen confirming my language, my account and my saved preferences, so that I know setup worked.
38. As a user, I want "Go to Home" to open the app, so that I can start using it.
39. As a new user, I want three welcome alerts waiting in Alerts when I arrive, so that the app greets me.
40. As a user who closes the app mid-flow, I want `/onboarding` to resume at the step I was on, so that I don't redo anything.
41. As a user whose session ended mid-flow, I want any step after SignIn to send me back to SignIn, so that my answers always belong to a signed-in user.
42. As a web visitor who opens `/onboarding` with no saved step, I want to land on `/signup`, so that web never shows Welcome.
43. As a user who has finished onboarding, I want `/onboarding`, `/login` and `/signup` to take me to the app, so that I never repeat setup.
44. As a returning user who signs in at `/login` but never finished onboarding, I want to be taken to my saved step (Profile at the earliest), so that I finish setting up.
45. As a returning, onboarded user who signs in at `/login`, I want to go straight to the app.
46. As a phone or tablet user, I want each step shown as an illustration band with a rounded sheet and a full-width button at the bottom, so that it fits one hand.
47. As a desktop or web user, I want a split screen with a hero panel and the form column, the button bottom-right, so that wide screens look intentional.
48. As a user, I want the hero headline to change with each step, so that the wide layout always matches what I'm doing.
49. As a user on native, I want system back on Welcome, Profile and Done to leave the app rather than break the flow.
50. As a screen-reader user, I want each step's heading announced, step progress read as "Step N of 5", tiles and option cards read as selectable with their state, and errors announced, so that I can complete onboarding without sight.
51. As a keyboard user, I want Enter to submit the email and password fields, Tab to move through every control in order, and a visible focus ring, so that I can complete onboarding without a mouse.
52. As a user with large text, I want every step to work at 200% without clipping, so that I can read it.
53. As a user, I want a clear snackbar with "Try again" if finishing onboarding fails, so that I'm not stuck on Done.

## Implementation Decisions

### Flow model

- **One view model:** `OnboardingViewModel`, a keep-alive notifier. Its immutable state (with `copyWith`, `==` and `hashCode`) holds:
  - the current step and the SignIn sub-state (email or password);
  - the mode (`flow` or `login`);
  - the typed email;
  - the profile answers (name, role);
  - the preference answers (email updates, weekly summary);
  - the permission outcome;
  - a busy flag and an error per field.

  Language and appearance aren't in the state; they're read and written through the Foundation notifiers.
- **Steps are state, not routes:** the URL stays `/onboarding` or `/signup` throughout (Login, signup and onboarding routes, 02).
- **Saving progress:** the current step is saved through the onboarding-progress notifier every time it changes, so the flow can resume. Answers aren't saved until Done; a restart before Done loses them, and the user re-enters them at the resumed step.
- **Signed-out gate:** when the session is signed out and the step is after SignIn, the view model moves to SignIn. It's checked on load and whenever the session changes. A route guard was ruled out (02).
- **Entry points:**
  - **`/onboarding`:** the saved step.
    - With no saved step: Welcome on native, or a redirect to `/signup` on web (the redirect is Foundation's).
    - When signed in and the saved step is before Profile: Profile.
  - **`/signup`:** Language, with mode `flow`.
  - **`/login`:** SignIn in mode `login`. It's a separate screen state with no step progress, sharing the same view model and widgets.
- **After a successful sign-in:**
  - **In `flow` mode,** the flow continues to Profile.
  - **In `login` mode:**
    - an onboarded user goes to `/app`;
    - anyone else goes to `/onboarding`, which resumes at the saved step (Profile at the earliest).
  - **Typed email:** moving between `/login` and `/signup` carries the typed email over and lands on the SignIn email state in the new mode.

### Steps

**Step labels:**

| Step | Progress | Back arrow → | Notes |
|---|---|---|---|
| Welcome | none | none; native system back leaves the app | native only |
| Language | Step 1 of 5 | Welcome when reached from it; otherwise shown only when there's a route to pop | gains the progress bar and back arrow the design lacks |
| SignIn: email | Step 2 of 5 | Language (in the flow); on `/login`, only when there's a route to pop | the design says "Step 1"; renumbered |
| SignIn: password | Step 2 of 5 | the email state | |
| Profile | Step 3 of 5 | **none**; native system back leaves the app | the design's arrow is removed |
| Preferences | Step 4 of 5 | Profile | |
| Permissions | Step 5 of 5 | Preferences | |
| Done | none | none; native system back leaves the app | |

**Welcome:**
- the logo with `app_name` from the identity constants;
- the illustration band;
- the language button;
- "Welcome to <app name>" and a one-sentence placeholder pitch;
- three feature rows (icon circle, title, one line) with placeholder copy;
- a filled "Get started →" button, which goes to Language.

**Language:**
- a 2-column grid of the 10 selectable tiles: native name, with the English name beneath; selected shows a check and border.
- The order follows `DESIGN.md` → Languages.
- Tapping a tile switches the app language through the Foundation notifier, at once, and saves it.
- **Headline and button:** both are shown in the selected language. When that isn't English, the English text is added after a "·" (the design's "जारी रखें · Continue"), so anyone can find their way back.
- **"Continue"** goes to SignIn.

**SignIn: email state:**
- **Title:** "Sign in to <app name>" in `login` mode; "Create your account" in `flow` mode.
- **Subtitle:** "Use your email or an account you already have."
- **Fields:** an "Email address" field; the filled button "Continue with email".
- **Validation:** the email is checked for basic validity when the button is pressed: "Enter a valid email."
- **Other sign-in options:** "or continue with" and the Google and Apple outlined buttons, shown only when the `PlatformCapabilities` flags allow (Sign-in and data on Windows, 12).
- **Footer:** a privacy note card (placeholder copy) and the line "By continuing you agree to the Terms of Service and Privacy Policy." Its links open `/terms` and `/privacy`: in-app on web, the site URL in the browser on native.
- **Mode switch link:** "Already have an account? Sign in" (`flow` mode) or "New here? Create an account" (`login` mode).

**SignIn: password state:** from Real email sign-in flow (01).
- **Email:** shown read-only, with a "Change" link back to the email state.
- **Title:** "Create a password" (`flow` mode) or "Enter your password" (`login` mode).
- **Password field:** has a show/hide toggle.
- **Signup rule:** at least 8 characters, else "Use at least 8 characters." Login only checks the field isn't empty.
- **"Forgot password?"** (login mode only) calls the reset method and shows inline: "If an account exists for <email>, we've sent a reset link."
- **Errors:**
  - wrong credentials: "Email or password is incorrect." with "New here? Create an account" → `/signup`;
  - taken email on signup: "An account with this email already exists." with "Sign in instead" → `/login`;
  - another sign-in method: "This email already uses another sign-in method."
- **No Google or Apple** buttons in this state.

**Google and Apple:**
- A tap calls the fake auth's Google or Apple sign-in, which records the sign-in method.
- In `flow` mode it continues to Profile; in `login` mode it follows the same after-sign-in rule as email.

**Profile:**
- **Title and subtitle:** "Tell us about you" / "This helps us personalise your experience. You can edit it later."
- **Fields:** the `ProfileFields` widget, built here and reused by Edit profile in the app screens spec (Edit profile, 14):
  - "Your name": optional, ≤ 50 characters after trimming, else "Keep it under 50 characters.";
  - "WHAT BEST DESCRIBES YOU?": three selectable option cards with placeholder titles and descriptions; the first is preselected, and one is always selected.
- **"Continue"** goes to Preferences.

**Preferences:** from What onboarding Preferences control (15).
- **Title and subtitle:** "Set your preferences" / "Pick how <app name> looks and how we reach you."
- **APPEARANCE:** a Light / Dark / System segmented control, default System. It applies and saves through the Foundation theme notifier immediately.
- **NOTIFICATIONS:** **Email updates** and **Weekly summary** toggles, both default off, held in view-model state. **The design's Push toggle is removed.**
- **"Continue"** goes to Permissions.

**Permissions:** from Permissions step and notification toggles (10).
- **Title and subtitle:** "Allow a few permissions" / "We only ask for what the app needs. You can change these later in your device settings."
- **One card, Notifications** (icon circle, title, placeholder reason, action). The design's Location and Camera cards are dropped.
- **Card action by permission status:**

  | Status | Card shows |
  |---|---|
  | not asked | tonal "Allow"; tapping it requests the permission |
  | granted | disabled "✓ Allowed" |
  | denied | "Open settings" (Android, iOS, macOS), or the line "Blocked in your browser settings." with no button (web) |
  | on by default | "✓ Allowed" |
  | unavailable | "Not available in this browser" with no button |

- **Re-checking:** the status is re-checked when the app returns to the foreground.
- **Leaving the step:**
  - **"Continue →"** goes to Done. The push preference becomes **true only if the status is granted or on by default** when leaving the step.
  - **"Skip for now"** goes to Done without requesting, and the push preference becomes false.

**Done:**
- **Layout:** "You're all set" / "Your account is ready. Let's take a look around.", the large Gain-container check circle, then three checked rows:
  - "Language set to <native name>";
  - "Account created" (`flow` mode signup) or "Signed in as <email>" (otherwise);
  - "Preferences saved".
- **On entering Done**, the view model writes, in one step:
  1. the user record's `displayName` (trimmed; empty stays empty, and the UI falls back to the email prefix) and `role`;
  2. `notifications {push, emailUpdates, weeklySummary}`;
  3. `onboardingFinishedAt`;
  4. the welcome alerts, **only if this user has none yet**. The Foundation demo seed may already have added them; this keeps them from being duplicated.

  Then it sets the onboarding-progress "finished" flag and clears the saved step.
- **"Go to Home →"** opens `/app`. It stays disabled while the writes are in progress.
- **If any write fails:** a snackbar says "Couldn't finish setting up. Try again." with a "Try again" action that repeats the writes. The finished flag isn't set until they succeed (Empty, error, loading and offline states, 13).

### Layouts

From Device layouts (03); `.scratch/stencil-v1/prototypes/device-layouts.md` §4.
- **Mobile and tablet:** an illustration band on top, with a rounded sheet over it holding the top row (back arrow, step progress, language button), the title, the body and the controls. A full-width CTA is pinned at the bottom of the sheet; "Skip for now" sits under it on Permissions.
- **Desktop and web:** a split screen.
  - **Left:** a hero panel, about 480 wide, on Primary container: the logo and app name, the illustration, and a **headline and line for each step** (placeholder copy, translated).
  - **Right:** a form column of about 560, with the back arrow and step progress at the top, the language button at the top-right, and the CTA bottom-right.
  - **Language** uses a 2-column tile grid on wide layouts and 1 column on mobile.
- **Welcome** follows the same frame. **Done** is centred in the form column (wide) or the sheet (narrow).
- **No app shell:** onboarding never shows the bottom bar, rail or web top bar.

### Accessibility

From Accessibility rules (16).
- **Headings:** each step's title is a heading, and focus moves to it when the step changes.
- **Step progress** reads "Step N of 5".
- **Selection:** tiles, option cards and the segmented control expose their selected state.
- **Errors** are announced when they appear.
- **Illustrations** are hidden from screen readers.
- **Keyboard:** Enter submits the email and password fields; Esc does nothing in the flow, because there are no dialogs.
- **Text scale:** every step works at text scale 2.0. The Language grid drops to 1 column above 1.5×.

### Strings

All new copy goes into all 10 ARB files: English, plus machine-drafted translations marked for review. Placeholder copy (pitch, feature rows, privacy note, role options, hero headlines, permission reason) stays clearly bracketed or generic, so a product can replace it.

### Replacing placeholders

This spec replaces Foundation's `/onboarding`, `/signup` and `/login` placeholder screens, **including the developer sign-in**. Routing and the redirect rules aren't touched.

## Testing Decisions

- **What a good test is:** it drives the flow through the app's root widget, the way a user would, and checks what's visible, which route is shown, and the resulting repository and preference state. It never reads the view model's fields directly.
- **The seam:** Foundation's seam 1, the root widget pumped with provider overrides (fake repositories, `InMemorySharedPreferencesAsync`, `PlatformCapabilities`, `NotificationPermissionRepository` set to a chosen status), at mobile and desktop/web sizes. Tests to cover:
  - the native fresh launch → Welcome → … → Done → `/app`, with the user record, notifications, `onboardingFinishedAt`, three welcome alerts (no duplicates when already seeded) and the finished flag all written;
  - the web `/onboarding` with no saved step → `/signup`, and `/signup` opening at Language;
  - `/login` for an onboarded user → `/app`; for a not-onboarded user → the saved step (Profile at the earliest);
  - email state validation, password rules for signup and login, the forgot-password message, wrong-credentials, taken-email and other-method errors, and their links carrying the email over;
  - Google and Apple shown or hidden per capabilities, and recording the sign-in method;
  - back arrows per the table, including none on Profile;
  - language switching the UI immediately and persisting; appearance switching the theme immediately and persisting;
  - Preferences having no Push toggle;
  - each permission status rendering correctly; Continue/Skip setting `push` correctly;
  - resuming at the saved step after a re-pump over the same preferences; a signed-out session on a later step returning to SignIn;
  - a Done write failure (repository override that fails) showing the snackbar and not setting the finished flag; Try again succeeding;
  - on each step: light and dark, mobile width, `meetsGuideline` (tap targets, labels, contrast), and text scale 2.0 with no overflow.
- **No new seam.** No new repository methods are added; Foundation's repository contract suites already cover the data operations used here.
- **Prior art:** Foundation's root-widget tests and its test helpers for overrides and screen sizes.

## Out of Scope

- **Real auth and email:** real Firebase Auth, real Google and Apple sign-in, real password-reset and verification emails (the fake only pretends).
- **Cross-device sync** of onboarding answers and the finished flag (assume a single device until Firestore, per 01).
- **The Location and Camera permissions,** and the design's Push toggle on Preferences.
- **Edit profile and Settings:** the app screens spec, which reuses `ProfileFields`.
- **Marketing's "Sign in" and "Get started" buttons:** the marketing spec.

## Further Notes

- **Differences from the designs, on purpose:**
  - Language gains the progress bar and a back arrow;
  - the step labels are renumbered;
  - Profile loses its back arrow;
  - Welcome is native-only;
  - Preferences drops Push;
  - Permissions keeps only Notifications;
  - the SignIn title depends on the mode.
- **Details filled in while writing this spec** (not explicitly grilled; reverse them in review if wrong):
  - the `flow`-mode SignIn title "Create your account", and the mode-switch links under the form;
  - the Language headline and button shown in the selected language, with English added after "·";
  - Done's second row: "Account created" vs "Signed in as <email>";
  - Done's welcome alerts are seeded only when none exist, so they don't duplicate Foundation's demo seed;
  - Push is true when leaving Permissions as granted or on by default.
- **Suggested `/to-tickets` slices:**
  1. the view model, entry points, resume and the signed-out gate;
  2. the frames (sheet and split) plus Welcome and Language;
  3. SignIn, both states and both modes;
  4. Profile with `ProfileFields`;
  5. Preferences;
  6. Permissions;
  7. Done and its writes.
