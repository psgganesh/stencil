# Permissions step and notification toggles

Type: grilling
Status: resolved
Blocked by: 05

## Question

The onboarding Permissions step and the Settings notification toggles (Push, Email, Weekly summary) suggest the app asks for OS permissions and sends notifications. Real push needs FCM plus APNs keys, which is manual work. Decide:
- **Permissions:** which ones the step asks for on each platform, and what happens when the user grants or denies them.
- **Toggles:** what each one actually does in this boilerplate: stores the preference only, or delivers something?
- **Push:** how the app behaves before push is configured.

Use the Permissions and Settings designs in `.refs/design/`.

## Answer

Resolved by grilling on 2026-10-19. The package facts are in `../research/notification-permission-packages.md`.

### Which permissions

- **v1 asks only for the notification permission.** The Location and Camera cards from the design are dropped: nothing in v1 uses them, and both app stores reject unused permission requests. The card is a reusable pattern, noted in `DESIGN.md`.

### Permission states

| State | When | Card | Push toggle in Settings |
|---|---|---|---|
| **not asked** | never asked yet | tonal "Allow" button; tapping it shows the OS prompt | turning it on shows the OS prompt |
| **granted** | the OS granted it | disabled "✓ Allowed" chip | works normally |
| **denied** | asked, and refused | Android, iOS and macOS: "Open settings" opens the app's OS settings. Web: a line saying it's blocked in the browser settings, with no button | goes back to off; the subtitle says "Turned off in device settings", with the same "Open settings" link or browser line |
| **not applicable, on by default** | Windows, Linux, Android 12 and lower | "✓ Allowed", no prompt | works normally |
| **not applicable, unavailable** | a browser with no Notification API (e.g. iOS Safari outside a Home Screen web app) | "Not available in this browser", no button | disabled, with the same subtitle |

- The state is checked again when the app comes back to the foreground, so it picks up changes made in the OS settings.
- On web, the request is made only from a button tap (Firefox requires this). The browser's `default` result counts as denied.

### Onboarding Permissions step

- **Continue** and **Skip for now** both go to Done and never block. Skip simply leaves the permission unasked.
- The result sets the user's `notifications.push` preference: granted sets `true`; denied or skipped sets `false`.
- **Email updates** and **Weekly summary** default to **off** (opt-in). The design's "on" Weekly summary is only the mockup.

### Settings toggles

- All three toggles **save the preference only**, on the user record (in the fake for v1). Nothing is delivered in v1: no FCM token registration, no local notifications for alerts, no email.
- **Turning Push on** needs the permission:
  - if it hasn't been asked, the OS prompt appears; the toggle stays on if it's granted and goes back to off if it's denied;
  - if it's denied, the toggle goes back to off and shows the denied subtitle.
- **Turning Push off** only saves the preference; the app can't revoke the OS permission.
- There's no "push isn't configured" UI. The toggles look the same whether or not delivery is set up.

### Package and wrapper

- **`flutter_local_notifications ^22.3.0`**, used only for its permission check, request and open-settings calls.
- It's wrapped in a `NotificationPermissionRepository` (an abstract interface plus an in-memory fake for tests) that exposes the five states above.
- **"Asked once" flag:** on iOS and macOS the plugin can't tell "never asked" from "denied", so a flag is saved in `shared_preferences`. Before asking, the state is not asked; after asking, a `false` result means denied.
- **Android setup** (part of Foundation): core library desugaring turned on, `compileSdk` 37 or higher, and a notification icon for initialization. `POST_NOTIFICATIONS` is added by the plugin.
- **Not used:** `permission_handler` (no macOS support, a broken Windows open-settings call), `app_settings`, and `firebase_messaging` (needs a Firebase app, no Windows support).

### Out of scope and manual tasks

- Real delivery is out of scope for v1: FCM push, email updates and the weekly summary email.
- The manual-tasks document gets one line: turning on push delivery needs FCM, an APNs `.p8` key, and a VAPID key with `firebase-messaging-sw.js` for web.
