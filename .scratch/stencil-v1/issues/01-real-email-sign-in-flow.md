# Real email sign-in flow

Type: grilling
Status: open
Blocked by:

## Question

The SignIn design (`.refs/design/*/onboarding/*/… SignIn.png`) has just one email field and a "Continue with email" button: no password, and no code-entry screen. For now, sign-in is fake: any valid email signs in immediately. Which **real** email flow should the app plan for, so that the screens and routes built now don't need rework when real Firebase Auth arrives? The candidates are a magic link, a one-time code, and email plus password. Also cover what returning users see, how a link opened on a different device is handled (web vs. app), and whether we need any screen that isn't in the designs (for example "Check your inbox" or "Enter code").
