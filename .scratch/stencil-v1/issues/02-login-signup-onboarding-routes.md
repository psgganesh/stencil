# Login, signup and onboarding routes

Type: prototype
Status: resolved
Blocked by: 01

## Question

Sketch (ASCII) exactly which screens are behind `/login`, `/signup` and `/onboarding`, and where users go between them.

- **Charting decision:** `/signup` starts onboarding, and `/login` is the SignIn screen without the step progress.
- **What GOAL.md says:** `/onboarding` is an *authenticated* guard.
- **What the designs show:** Welcome and Language come *before* SignIn.

The proposed split, to confirm or change:
- `/signup`: Welcome → Language → SignIn (signup mode).
- `/onboarding` (guarded): Profile → Preferences → Permissions → Done.
- `/login`: SignIn alone.

The sketch should also cover:
- the step-count text ("Step 1 of 5" starts at SignIn);
- what the back button does on each screen;
- where a signed-in user who opens `/login` or `/signup` ends up;
- where a signed-in user who hasn't finished onboarding and opens `/app` ends up;
- what happens on web compared with native;
- the SignIn password state from [Real email sign-in flow](01-real-email-sign-in-flow.md). It is a sub-state of SignIn, not a route, and its "New here? Create an account" and "Sign in instead" links move the user between `/login` and `/signup`.

Fix the "Routing" line in `AGENTS.md` → "Architecture" to match the result.

## Answer

Resolved on 2026-10-19 with a markdown sketch ([prototype sketch](../prototypes/02-routes-sketch.md)) and the user's answers to it. Model A was chosen.

**Routes.** There is one onboarding flow, and it can be entered from three routes. Steps are state in the single onboarding view model, not routes, so the URL doesn't change from step to step.

| Route         | Shows                                                                 | Guard |
|---------------|-----------------------------------------------------------------------|-------|
| `/onboarding` | The whole flow, resuming at the saved step: Welcome → Language → SignIn → Profile → Preferences → Permissions → Done | None at the route. The view model sends a signed-out user on any step after SignIn back to SignIn. |
| `/signup`     | The same flow and view model, opened at **Language**, with SignIn in signup mode | None |
| `/login`      | SignIn on its own, in login mode, with no step progress               | None |
| `/app`        | The signed-in app                                                     | Needs a session and finished onboarding |

GOAL.md's "authenticated onboarding guard" is enforced by the view model on the steps after SignIn, not on the `/onboarding` route. A route-level guard would have sent a fresh native install to `/login` instead of Welcome.

**Web compared with native**
- **Web:** marketing never shows onboarding. Signed-out visitors see two top-bar buttons, "Sign in" → `/login` and "Get started" → `/signup`. Signed-in visitors see a single "Open app" → `/app`. **Welcome isn't used on web**, because the marketing pages already do its job: a signed-out visitor who opens `/onboarding` with no saved step is sent to `/signup`. Steps aren't in the URL, so browser back leaves the flow, and the flow resumes at the saved step on the next visit.
- **Native:** there's no marketing. The charting launch rule stands: `/app` if signed in and onboarded, otherwise `/onboarding` (which starts at Welcome) if onboarding isn't finished, otherwise `/login`.

**Step count: Language is step 1.** This replaces the design labels, which skip step 2.

| Screen      | Progress     |
|-------------|--------------|
| Welcome     | none         |
| Language    | Step 1 of 5 (gains the step-progress bar that the design doesn't show) |
| SignIn      | Step 2 of 5 (the design says 1); the password state is still the same step |
| Profile     | Step 3 of 5  |
| Preferences | Step 4 of 5  |
| Permissions | Step 5 of 5  |
| Done        | none         |

`/login` shows no progress.

**Moving between login and signup.** "New here? Create an account" on `/login` goes to `/signup`, and "Sign in instead" goes to `/login`. Both carry the typed email over and land on the SignIn email state in the new mode, so the user doesn't go through Language again. After a `/login` sign-in, an onboarded user goes to `/app`, and anyone else goes to `/onboarding`, which resumes at the saved step (Profile at the earliest). After a signup, the flow continues to Profile.

**Redirects** (`onGenerateRoute`, plus the view model for steps)

| User state                          | `/login` or `/signup` | `/onboarding` | `/app` |
|-------------------------------------|-----------------------|---------------|--------|
| Signed out                          | Shown | Saved step; a step after SignIn falls back to SignIn. On web with no saved step → `/signup` | → `/login` |
| Signed in, onboarding not finished  | → `/onboarding` | Saved step (Profile at the earliest) | → `/onboarding` |
| Signed in, onboarding finished      | → `/app` | → `/app` | Shown |

**Back arrow and system back**

| Screen                     | Arrow | Arrow or system back does |
|----------------------------|-------|---------------------------|
| Welcome                    | None  | Native: leaves the app |
| Language, reached from Welcome | Shown | → Welcome |
| Language, opened by `/signup`  | Shown only if there's a route to pop | Pops (back to marketing on web) |
| SignIn email state, in the flow | Shown | → Language |
| SignIn email state, `/login`    | Shown only if there's a route to pop | Pops; hidden when `/login` is the launch route on native |
| SignIn password state       | Shown | → the email state (decided in ticket 01) |
| Profile                     | **None** (the design shows one, and the design is overridden) | The user is signed in and can't step back over sign-in. Native system back leaves the app |
| Preferences                 | Shown | → Profile |
| Permissions                 | Shown | → Preferences |
| Done                        | None  | Native: leaves the app |

**Differences from the designs, for the Onboarding spec:** Language gains the step-progress bar and a back arrow; the step labels are renumbered; Profile loses its back arrow; Welcome is native-only.

`AGENTS.md` → Architecture → Routing has been updated to match.
