# Spec boundaries and hand-off order

Type: grilling
Status: resolved
Blocked by: 14, 15, 16, 18, 19

## Question

Split everything decided on the map into the five specs (Foundation, Onboarding, app screens, marketing, CI/CD):
- what belongs in **Foundation**: the theme, `PlatformCapabilities`, routing, app-wide providers, the fake repositories and demo seed, the failure type and state views, l10n and fonts, `NotificationPermissionRepository`, and the Android build settings;
- which spec owns each cross-cutting piece (for example the item form, used by Home and Items, or delete account, used by Settings and `/delete-data`);
- the order the specs go to Codex, and what each one may assume already exists;
- whether any spec is too big for one `/to-tickets` pass and should be split.

## Answer

Resolved by grilling on 2026-10-19.

### Order

| # | Spec | Why at this point |
|---|---|---|
| 1 | **Foundation** | Everything else builds on it. |
| 2 | **CI/CD** | It only needs a buildable app and the identity script. From here on, every spec is built and deployed by CI as it lands. |
| 3 | **Onboarding** | GOAL.md: "onboarding … first". |
| 4 | **marketing** | GOAL.md: "web screens first". |
| 5 | **app screens** | Reuses `ProfileFields` from Onboarding, and the `/delete-data` pattern is already in place. |

Codex finishes one spec before starting the next.

### What Foundation holds

**Foundation holds everything shared**, so later specs only add screens.
- **App identity and build setup:**
  - `app_identity.yaml` and `tool/apply_identity.dart` ([Manual-tasks document](19-manual-tasks-document.md));
  - Android settings: minSdk 24, desugaring, `compileSdk` 37, and a release signing config;
  - macOS entitlements: `network.client` and Keychain Sharing;
  - `web/_redirects`.
- **Look and feel:**
  - the theme (both schemes, the custom roles in a theme extension, and the dark Featured-button exception);
  - fonts ([Fonts for ten languages](04-fonts-for-ten-languages.md));
  - gen-l10n set up for all 10 languages.
- **Platform and routing:**
  - `PlatformCapabilities`;
  - `onGenerateRoute` with every redirect rule, using placeholder screens;
  - the three shells (bottom bar, rail, web top bar) and layout selection.
- **Shared widgets:** cards, chips, item row, buttons, text field, segmented control, the state views and skeleton, the language button and the avatar.
- **App-wide state:** the session (including sign-in method), theme, language and onboarding-progress notifiers.
- **The whole fake data layer:**
  - repositories for the user, items with activity, alerts (raising an alert on a status change) and contact messages;
  - the demo seed (with activity spread over 14 days), the failure type, and the `FAKE_LATENCY_MS` / `FAKE_FAILURE` flags;
  - Firebase-stub detection and `NotificationPermissionRepository`.
- **Delete account** at the repository and session level.

### Who owns the cross-cutting pieces

| Piece | Owner | Reused by |
|---|---|---|
| Item form (`/app/items/new`, `/app/items/<id>/edit`) | app screens | Home links to its route |
| Delete account logic | Foundation | Settings button (app screens), `/delete-data` page (marketing) |
| `ProfileFields` widget | Onboarding | Edit profile (app screens) |
| Welcome-alert seeding on Done | Onboarding, calling the Foundation repository | |
| `docs/manual-tasks.md` | CI/CD (Claude writes it with the spec) | |
| Contact Us page | marketing | the "Contact support" link from the Error state (Foundation), which is just a URL |

### Rules for every spec

- **Strings:** each spec adds its own strings to **all 10 ARB files**: English, plus machine-drafted translations marked for review.
- **"Assumes" section:** each spec opens with one, listing what earlier specs delivered, so Codex never re-plans.
- **Size:** there are **five specs, with no splits**. `/to-tickets` slices the big ones (Foundation, app screens) into about one ticket per area or screen, each working on every layout.

### When specs and tickets are written

- **All five specs are written now**, while every decision is fresh.
- **Each spec's tickets are written just before it's handed off**, so they reflect the code as it then stands.
