# Email + password over magic link

The SignIn design has a single email field, which reads like a magic link or one-time code. We chose **email + password, email first** instead. "Continue with email" leads to a password state of the same SignIn step: "Enter your password" on `/login`, "Create a password" on `/signup`. This is the only option that works on all five platforms (web, Android, iOS, macOS and Windows) without extra infrastructure.

## Considered Options

- **Magic link (Firebase email link):** rejected. Since Firebase Dynamic Links shut down in 2025, it needs Android App Links and iOS Universal Links on a hosted domain. A link opened on another device, or anywhere on Windows, can't sign the app in.
- **One-time code by email:** rejected. Firebase Auth doesn't offer it, so it would need a custom backend (Cloud Functions issuing custom tokens).

## Consequences

- With email enumeration protection on (the Firebase default), the app can't ask Firebase whether an email already has an account. Whether the user is new or returning comes from the route (`/login` or `/signup`), not from a lookup.
- Password reset and email verification happen on Firebase's hosted pages, so the app has no reset screen and needs no deep links.
