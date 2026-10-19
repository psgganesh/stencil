# Sign-in and data on Windows

Type: grilling
Status: resolved
Blocked by:

## Question

According to [Firebase support on each platform](05-firebase-platform-support.md), FlutterFire on Windows is "not intended for production". It has no Google or Apple sign-in, and no FCM. GOAL.md still ships a Windows app. Decide the following for Windows:

- **Data:** does the Windows app keep using the fake repositories in its releases? Or does it use Firestore anyway, accepting the development-only status?
- **Sign-in buttons:** are Google and Apple hidden, disabled, or replaced (for example with a sign-in that happens in the browser)?
- **Permissions and notifications:** what do the Permissions step and the notification toggles do on Windows?

Then decide how much of that also applies to macOS, which has beta status.

> Context from [Firestore data model and security rules](08-firestore-data-model.md): v1 builds only the fake repositories, and Firestore is a later effort. So the **Data** question is about which repositories Windows uses once Firestore arrives, not in v1.

## Answer

Resolved by grilling on 2026-10-19.

### Data

- **Once Firestore arrives, Windows uses it like every other platform.** We accept FlutterFire's "not intended for production" label for Windows. The README and the manual-tasks document say so.
- The existing fallback still applies: with the stub `firebase_options.dart`, or no config, the app uses the fakes.
- Rejected: fakes in Windows releases (data split by device) and a REST repository just for Windows (a second data layer to maintain).

### Sign-in buttons

- **Google and Apple are hidden on Windows and Linux, from v1 on.** SignIn shows only email and password, with no "or" divider.
- Browser-based sign-in on desktop is out of scope.

### Permissions and notifications

- The Permissions step stays as decided in [Permissions step and notification toggles](10-permissions-and-notifications.md): the card shows "✓ Allowed" with no prompt, and the step count stays at 5 on every platform.
- **The Push row is hidden in Settings on Windows and Linux.** Email updates and Weekly summary stay.

### macOS

- **No special treatment: it behaves like iOS.** Firestore, the Google and Apple buttons, a real notification permission, and the Push row are all shown.
- The README mentions FlutterFire's beta status for macOS.

### Where the rules live

- **One app-wide `PlatformCapabilities` value** in `lib/core/`, provided through Riverpod (keep-alive) so tests can override it.
- Flags: `googleSignIn`, `appleSignIn`, `pushDelivery`, and the notification-permission kind (runtime prompt / on by default / browser / unavailable).
- Screens and view models read these flags and never check `Platform.isWindows` or `kIsWeb` for these features.

| | Android | iOS | macOS | web | Windows | Linux |
|---|---|---|---|---|---|---|
| Google / Apple buttons | ✓ | ✓ | ✓ | ✓ | hidden | hidden |
| Push row in Settings | ✓ | ✓ | ✓ | ✓ | hidden | hidden |
| Notification permission | prompt (13+) / on by default (≤12) | prompt | prompt | browser | on by default | on by default |
| Firestore (later effort) | ✓ | ✓ | ✓ (beta) | ✓ | ✓ (dev-only label accepted) | not tested |
