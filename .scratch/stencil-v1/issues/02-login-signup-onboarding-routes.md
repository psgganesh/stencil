# Login, signup and onboarding routes

Type: prototype
Status: open
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
- what happens on web compared with native.

Fix the "Routing" line in `AGENTS.md` → "Architecture" to match the result.
