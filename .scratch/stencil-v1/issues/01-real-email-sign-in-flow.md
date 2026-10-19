# Real email sign-in flow

Type: grilling
Status: resolved
Blocked by:

## Question

The SignIn design (`.refs/design/*/onboarding/*/… SignIn.png`) has just one email field and a "Continue with email" button: no password, and no code-entry screen. For now, sign-in is fake: any valid email signs in immediately. Which **real** email flow should the app plan for, so that the screens and routes built now don't need rework when real Firebase Auth arrives? The candidates are a magic link, a one-time code, and email plus password. Also cover what returning users see, how a link opened on a different device is handled (web vs. app), and whether we need any screen that isn't in the designs (for example "Check your inbox" or "Enter code").

## Answer

Resolved by grilling on 2026-10-19. ADR: [Email + password over magic link](../../../docs/adr/0001-email-password-over-magic-link.md).

- **Method:** real sign-in uses email and password, with the email asked first. A magic link was ruled out because it needs App Links and Universal Links and doesn't work on Windows or across devices. A one-time code was ruled out because Firebase doesn't offer one, so it would need a custom backend.
- **Fake auth mirrors the real flow:** it uses the same screens, states and error messages. Any non-empty password is accepted, "Forgot password" pretends to send an email, and an email the fake has already seen counts as taken on signup. Moving to Firebase only swaps the `AuthRepository` implementation; no views or routes change.
- **Password state of SignIn:** a second state of the SignIn step, held in the same view model, with no new route and no change to the step count (it stays the same step as the email state; [Login, signup and onboarding routes](02-login-signup-onboarding-routes.md) later relabelled SignIn "Step 2 of 5"). The email shows read-only with a "Change" link, and the back arrow returns to the email state. Google and Apple aren't shown in this state.
  - `/login` mode: the title is "Enter your password", with a "Forgot password?" link.
  - `/signup` mode: the title is "Create a password".
- **Password rules:** signup needs at least 8 characters, with no rules about which kinds of characters. Anything shorter shows the inline error "Use at least 8 characters." under the field. Login only checks that the field isn't empty. The field has a show/hide toggle.
- **Forgot password:** sends a reset email to the email already entered and shows an inline confirmation on the same screen: "If an account exists for <email>, we've sent a reset link." The reset happens on Firebase's hosted page, so the app has no reset screen and needs no deep link.
- **Email verification:** a verification email is sent after a password signup. It never blocks the user, and v1 has no banner or gate. Google and Apple users are already verified.
- **Errors:**
  - Login: "Email or password is incorrect." with a link, "New here? Create an account", to `/signup`. Email enumeration protection makes a wrong password and an unknown email give the same error.
  - Signup with a taken email: "An account with this email already exists." with a link, "Sign in instead", to `/login`.
  - Sign-in method collision: "This email already uses another sign-in method."
- **One user per email:** Firebase's default "one account per email" setting links password, Google and Apple sign-in to the same **user** (added to `GLOSSARY.md`).
- **Returning users:** once Firestore is in, "onboarding finished" and the onboarding answers are saved on the user's record through a repository, and the local `shared_preferences` flag becomes a cache. A user who has already been onboarded and signs in on a new device goes straight to `/app`. **Until Firestore is in, assume a single device (desktop or web) and don't design for cross-device edge cases.**
- **Screens not in the designs:** only the password state of SignIn. The app needs no "Check your inbox" screen, no "Enter code" screen and no deep links.
- **For the manual-tasks document:** turn on the Email/Password provider in Firebase Auth and leave email enumeration protection on (the default).
