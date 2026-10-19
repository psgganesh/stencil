# 10: Delete account

**What to build:** A single app-wide action deletes everything belonging to the signed-in user and leaves nothing behind on the device. If auth needs a recent sign-in first, it reports that so the screen can ask the user to sign in again. Afterwards the user lands on `/login` (native) or `/` (web). Settings and `/delete-data` use this action later. See `../spec.md` → "Delete account".

**Blocked by:** 06, 09

**Status:** ready-for-agent

- [ ] **Steps, in order:**
  1. delete the user's items and their activity, then alerts, then the user record;
  2. delete the auth user;
  3. clear local preferences (fake session, theme, language, onboarding progress, the notification "asked once" flag);
  4. navigate to `/login` on native, or `/` on web.
- [ ] Contact messages are kept.
- [ ] **Recent sign-in:** when auth reports that a recent sign-in is required, the action stops before deleting the auth user and returns that outcome without navigating. The fake can be told to report it.
- [ ] A developer button on the Settings placeholder runs the action, so it can be demoed.
- [ ] Tests:
  - [ ] **contract:** after the action, no items, activity, alerts or user record exist for the user, and contact messages remain;
  - [ ] **root widget:** the landing route per platform, with preferences cleared (the theme and language are back to their defaults after a re-pump);
  - [ ] **root widget:** the recent-sign-in outcome leaves the user signed in and on the same route.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
