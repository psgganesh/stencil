# PROTOTYPE (throwaway): login, signup and onboarding routes

**Verdict (2026-10-19): Model A, with Language as step 1, `/signup` opening at Language, Welcome native-only, and no back arrow on Profile. The ticket's Answer is the source of truth.**

Sketch for [Login, signup and onboarding routes](../issues/02-login-signup-onboarding-routes.md). No code, by repo rule. Items marked **[?]** are open until the ticket's answer records the human's call.

## The conflict the sketch has to resolve

- The charting decision on launch says a native, signed-out, not-onboarded user opens on `/onboarding`, and that screen must be **Welcome**.
- GOAL.md calls `/onboarding` an *authenticated* guard. If the route itself checked sign-in, that user would be sent to `/login` and would never see Welcome.
- `AGENTS.md` → Routing already says "Onboarding's own view model makes sure the steps after SignIn are only reachable once the user is signed in". That puts the guard on the **steps**, not on the route.

## Model A (recommended): one flow, three entry routes

```
 route          what it shows                                  guard
 ─────────────  ─────────────────────────────────────────────  ──────────────────────────────
 /onboarding    the whole flow, resuming at the saved step     route: none
                Welcome → Language → SignIn → Profile →        view model: steps after SignIn
                Preferences → Permissions → Done               need a session, otherwise SignIn
 /signup        the same flow and view model, opened at        none
                SignIn in signup mode
 /login         SignIn alone, in login mode, with no step      none
                progress (a separate screen and view model?
                see below)
 /app           the signed-in app                              session + onboarding finished
```

Steps are **state in the onboarding view model**, not routes. The URL stays `/onboarding` (or `/signup`) while the user moves between steps.

### Flow

```
                      ┌────────────── web only ──────────────┐
                      │  /  marketing Home                   │
                      │   "Get started"/Premium ──► /signup  │
                      │   "Sign in"             ──► /login   │
                      └──────────────────────────────────────┘

 native first launch ──► /onboarding
 ┌──────────────────────────────── onboarding view model ─────────────────────────────────┐
 │                                                                                         │
 │  Welcome ──► Language ──► SignIn[signup] ──► Profile ──► Preferences ──► Permissions ──► Done ──► /app
 │  (no bar)    (no bar)     email ⇄ password   Step ?      Step ?          Step ?          (no bar)
 │                           Step 1 of N        of N        of N            of N
 │                             ▲                                                            │
 └─────────────────────────────┼────────────────────────────────────────────────────────────┘
                               │ /signup enters here
                               │
            "New here? Create an account"  ▲      │ "Sign in instead"
                                           │      ▼
                               /login: SignIn[login], email ⇄ password, no progress bar
                                   │ success
                                   ├── onboarding finished ──► /app
                                   └── not finished ─────────► /onboarding (resumes at Profile
                                                               or the saved step after it)
```

### Redirects (in `onGenerateRoute` plus the view model)

| User state                                | Opens `/login` or `/signup` | Opens `/onboarding`            | Opens `/app` |
|-------------------------------------------|-----------------------------|--------------------------------|--------------|
| signed out                                | shown                       | saved step; a step after SignIn falls back to SignIn | `/login` |
| signed in, onboarding not finished        | `/onboarding` (saved step)  | saved step (Profile at the earliest) | `/onboarding` |
| signed in, onboarding finished            | `/app`                      | `/app`                         | shown        |

### Back arrow and system back

| Screen                   | Arrow shown? | Arrow / system back does                                       |
|--------------------------|--------------|----------------------------------------------------------------|
| Welcome                  | no           | native: leaves the app. Web: browser history                    |
| Language                 | no (design)  | system back → Welcome                                          |
| SignIn email, in flow    | yes          | → Language                                                     |
| SignIn email, `/signup`  | yes          | pops the route (back to marketing on web); with nothing to pop: **[?]** |
| SignIn email, `/login`   | yes          | pops the route; with nothing to pop (native launch), the arrow is hidden |
| SignIn password state    | yes          | → the email state (decided in ticket 01)                       |
| Profile                  | design: yes  | **[?]** the user is already signed in                          |
| Preferences              | yes          | → Profile                                                      |
| Permissions              | yes          | → Preferences                                                  |
| Done                     | no           | native: leaves the app. The user stays on Done                 |

### Web compared with native

- On web, steps aren't in the URL, so browser back leaves the flow entirely (for example, back to marketing). The flow resumes from the saved step on the next visit. Putting the step in the URL (`/onboarding?step=profile`) is possible but isn't proposed.
- On native, `/` doesn't exist. The launch rule from charting stands: `/app`, then `/onboarding`, then `/login`.

## Model B (the ticket's proposal), for comparison

```
 /signup     Welcome → Language → SignIn[signup]
 /onboarding (guarded) Profile → Preferences → Permissions → Done
 /login      SignIn[login]
```

This needs the native launch rule changed to "otherwise `/signup`" so that a fresh install sees Welcome. It also splits one onboarding view model across two routes, and `AGENTS.md` decided on a single view model for the whole flow.

## Step numbering: the designs have a gap **[?]**

| Screen      | Design label |
|-------------|--------------|
| SignIn      | Step 1 of 5  |
| (none)      | Step 2 of 5  |
| Profile     | Step 3 of 5  |
| Preferences | Step 4 of 5  |
| Permissions | Step 5 of 5  |
