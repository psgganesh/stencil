# Sign-in and data on Windows

Type: grilling
Status: open
Blocked by:

## Question

According to [Firebase support on each platform](05-firebase-platform-support.md), FlutterFire on Windows is "not intended for production". It has no Google or Apple sign-in, and no FCM. GOAL.md still ships a Windows app. Decide the following for Windows:

- **Data:** does the Windows app keep using the fake repositories in its releases? Or does it use Firestore anyway, accepting the development-only status?
- **Sign-in buttons:** are Google and Apple hidden, disabled, or replaced (for example with a sign-in that happens in the browser)?
- **Permissions and notifications:** what do the Permissions step and the notification toggles do on Windows?

Then decide how much of that also applies to macOS, which has beta status.
