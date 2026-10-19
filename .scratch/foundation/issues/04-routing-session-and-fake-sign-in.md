# 04: Routing, session and fake sign-in

**What to build:** Every route in the app exists and shows a placeholder naming the spec that will replace it. The launch rule and every redirect behave as decided. A developer can sign in through a minimal sign-in on the `/login` and `/signup` placeholders using the fake auth, and the session survives a restart. Platform differences come from `PlatformCapabilities`. See `../spec.md` → "Platform capabilities", "Routing", and "Session, auth and app-wide state".

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] **`PlatformCapabilities`:** a keep-alive value, overridable in tests.
  - [ ] Its flags are `googleSignIn`, `appleSignIn`, `pushDelivery` and the notification-permission kind, set per platform as in the spec.
  - [ ] No screen checks the platform directly.
- [ ] **Fake `AuthRepository`** behind an interface:
  - [ ] email sign-in accepts any valid email with a non-empty password;
  - [ ] signup needs ≥ 8 characters, and an email the fake has already seen counts as taken;
  - [ ] Google and Apple sign in a fake user;
  - [ ] password reset pretends to send;
  - [ ] the sign-in method is recorded;
  - [ ] the session is saved in preferences.
- [ ] **App-wide notifiers:** keep-alive notifiers for the session (signed out, or uid, email and sign-in method) and for onboarding progress (saved step, finished flag), both saved in preferences.
- [ ] **Placeholder screens** for every route listed in the spec. Each placeholder can be replaced without touching routing.
- [ ] **Redirects:** `onGenerateRoute` applies the redirect table, the launch rule (web `/`; native `/app` / `/onboarding` / `/login`), the marketing-on-native rule and the unknown-route fallbacks (including unknown `/app/items/<id>` → `/app/items`).
- [ ] After every route change, focus moves to the page heading.
- [ ] **Developer sign-in** on the `/login` and `/signup` placeholders: email + password, plus Google and Apple buttons shown only when the capabilities allow. It signs in through the fake. A way to mark onboarding finished lets `/app` be reached.
- [ ] Root-widget tests on web and native:
  - [ ] every row of the redirect table and the launch rule;
  - [ ] the unknown routes;
  - [ ] the session surviving a re-pump;
  - [ ] Google and Apple hidden on Windows and Linux.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
