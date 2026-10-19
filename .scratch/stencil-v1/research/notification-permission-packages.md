# Notification permission packages: check, request, open settings (no Firebase)

Research for ticket [10](../issues/10-permissions-and-notifications.md). Sources checked on 2026-10-19. Versions come from the pub.dev JSON API (`https://pub.dev/api/packages/<name>`). Behaviour comes from each package's source on its default branch, and for `flutter_local_notifications` it was also checked against the published 22.3.2 archive. Nothing here was run on a device. Statements marked *(from source)* were read from the code, not tested.

## TL;DR

- **No single package covers all five platforms.** Windows has no runtime notification permission at all, and no Flutter package exposes its notification setting.
- **`firebase_messaging` cannot be used without Firebase.** `FirebaseMessaging.instance` calls `Firebase.app()`, which throws `noAppExists` when `Firebase.initializeApp()` hasn't run. That happens on every platform, before `requestPermission` is ever reached.
- **`flutter_local_notifications` 22.3.2** is the widest single option. It can check, request and open the app's notification settings on Android, iOS and macOS, and it can check and request on web. On Windows it has no permission API.
- **`permission_handler` 13.0.2** has **no macOS implementation**. On Windows it always reports `granted`, and its Windows `openAppSettings` falls through to `NotImplemented` because of a bug *(from source)*. On web, `openAppSettings` returns `false`.
- **`app_settings` 9.0.1** only opens settings pages. It supports Android, iOS and macOS, and its `notification` type deep-links to the notification settings on each.
- **Recommendation (§6):** use `flutter_local_notifications` behind a `NotificationPermissionRepository` interface. Report Windows (and Linux) as "not applicable" in Dart without calling a plugin. On web, show instructions instead of a settings button. Drop `permission_handler`, `app_settings` and `firebase_messaging` for this capability.

## 1. Capability matrix

✅ = supported · ⚠️ = works with caveats · ❌ = not available

| Capability | `permission_handler` 13.0.2 | `flutter_local_notifications` 22.3.2 | `firebase_messaging` 17.0.0 | `app_settings` 9.0.1 |
|---|---|---|---|---|
| **Check: Android** | ✅ `Permission.notification.status` | ✅ `areNotificationsEnabled()` | ❌ needs Firebase app | — |
| **Check: iOS** | ✅ (`provisional` too) | ⚠️ `checkPermissions()`: booleans only, so it can't tell "not asked" from "denied" | ❌ | — |
| **Check: macOS** | ❌ no macOS plugin | ⚠️ `checkPermissions()`, same booleans | ❌ | — |
| **Check: web** | ⚠️ through the Permissions API | ✅ `permissionStatus` (`Notification.permission`) | ❌ | — |
| **Check: Windows** | ⚠️ always `granted` | ❌ no API | ❌ (no Windows plugin) | — |
| **Request: Android** | ✅ | ✅ `requestNotificationsPermission()` | ❌ | — |
| **Request: iOS / macOS** | iOS ✅ / macOS ❌ | ✅ `requestPermissions(alert:, badge:, sound:)` | ❌ | — |
| **Request: web** | ⚠️ any non-grant is reported as `permanentlyDenied` | ✅ `requestNotificationsPermission()` | ❌ | — |
| **Request: Windows** | ⚠️ always `granted` | ❌ | ❌ | — |
| **Open settings: Android** | ✅ app details page | ✅ app **notification** page, falls back to app details | — | ✅ `AppSettingsType.notification` |
| **Open settings: iOS** | ✅ app settings | ✅ notification settings on iOS 15.4+, otherwise app settings | — | ✅ notification settings on 15.4+/16+ |
| **Open settings: macOS** | ❌ | ✅ falls back to the system Notifications pane | — | ✅ System Settings › Notifications |
| **Open settings: web** | returns `false` | throws `UnimplementedError` | — | ❌ (no web plugin) |
| **Open settings: Windows** | ⚠️ falls through to `NotImplemented` *(from source)* | throws `UnimplementedError` *(from source: no override)* | — | ❌ |

## 2. Package details

### 2.1 `permission_handler` 13.0.2 (published 2026-09-04)

- **Platforms** (from the pubspec `flutter.plugin.platforms`): android (`permission_handler_android` 14.1.0), ios (`permission_handler_apple` 9.6.2, whose pubspec declares **ios only**), web (`permission_handler_html` 0.1.4+1) and windows (`permission_handler_windows` 0.2.2). **No macOS.** On macOS, a call goes to a method channel with no native handler, so expect a `MissingPluginException` *(from source, inference)*.
- **Android** *(from source, `PermissionManager.java`)*:
  - Below API 33, `status` uses `NotificationManagerCompat.areNotificationsEnabled()` and returns `granted` or `denied`. There is no runtime prompt there. On API 33+, it uses `checkSelfPermission(POST_NOTIFICATIONS)`.
  - The request only adds `POST_NOTIFICATIONS` when the device is on API 33+ **and the permission is in the app manifest**. **You must add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` yourself.**
  - `status` never returns `permanentlyDenied` (an intentional change in `permission_handler_android` 14.1.0). Only the result of `request()` can be `permanentlyDenied`, and that request then returns without showing a dialog (README FAQ).
  - `openAppSettings()` opens `ACTION_APPLICATION_DETAILS_SETTINGS` (`AppSettingsManager.java`).
- **iOS** *(from source, `NotificationPermissionStrategy.m`)*: `UNAuthorizationStatusNotDetermined` → `denied`, `Denied` → `permanentlyDenied`, `Provisional` → `provisional`, and anything else → `granted`. The request asks for sound, alert and badge. `openAppSettings` opens `UIApplicationOpenSettingsURLString`.
  - **Config:** no Info.plist key is needed. Under SwiftPM the `PERMISSION_NOTIFICATIONS` macro is **on by default** (`Package.swift`: "enabled for permissions with no required plist key"). It can be switched off with `PERMISSION_NOTIFICATIONS=0`. Under CocoaPods, every permission is excluded by default, so add `'PERMISSION_NOTIFICATIONS=1'` to the Podfile `GCC_PREPROCESSOR_DEFINITIONS` (README, "iOS - CocoaPods").
- **Web** *(from source, `web_delegate.dart`)*:
  - `status` calls `navigator.permissions.query({name: 'notifications'})` and maps `granted` → `granted`, `denied` → `permanentlyDenied`, and `prompt` (or anything else) → `denied`.
  - `request` calls `Notification.requestPermission()`. **Any result other than `granted` becomes `permanentlyDenied`**, even when the user just dismissed the prompt and the state is still `default`.
  - `openAppSettings` returns `false`.
- **Windows** *(from source, `permission_handler_windows_plugin.cpp`)*: `checkPermissionStatus` and `requestPermissions` always return `GRANTED`. The branch meant to answer `openAppSettings` with `false` is written `methodName.compare("openAppSettings")` with no `== 0`. That expression is truthy for every *other* name and false for `"openAppSettings"` itself, so the call reaches `result->NotImplemented()`, which Dart sees as `MissingPluginException`.

### 2.2 `flutter_local_notifications` 22.3.2 (published 2026-10-12)

- **Platforms:** android, ios, macos, linux, windows (`flutter_local_notifications_windows` 3.1.1) and web (`flutter_local_notifications_web`). It requires `sdk ^3.10.0` and `flutter >=3.38.1`, both fine for Dart 3.13.4 / Flutter 3.47.5.
- **Check / request / open settings APIs** (`lib/src/platform_flutter_local_notifications.dart`, which is identical in the 22.3.2 archive):
  - **Android:** `AndroidFlutterLocalNotificationsPlugin.areNotificationsEnabled()` and `requestNotificationsPermission()`. On API 33+ the request calls `ActivityCompat.requestPermissions(POST_NOTIFICATIONS)`; below 33 it returns `areNotificationsEnabled()` with no prompt *(from source, `FlutterLocalNotificationsPlugin.java`)*. `openAppNotificationSettings()` opens `ACTION_APP_NOTIFICATION_SETTINGS` (API 26+) and falls back to app details.
  - **iOS:** `IOSFlutterLocalNotificationsPlugin.requestPermissions(...)` returns `bool?`, and `checkPermissions()` returns `NotificationsEnabledOptions` (`isEnabled`, `isProvisionalEnabled`, `isAlertEnabled`, …). **There is no "not determined" state**, so the app can't tell "never asked" from "denied" before it requests. `openAppNotificationSettings()` opens the app's notification settings on 15.4+.
  - **macOS:** `MacOSFlutterLocalNotificationsPlugin` has the same three methods. Settings falls back to the system Notifications pane.
  - **Web:** `WebFlutterLocalNotificationsPlugin.permissionStatus` (a getter for `Notification.permission`: `granted` / `denied` / `default`) and `requestNotificationsPermission()`. If the state is already `denied`, the request returns `false` without calling the browser *(from source, `flutter_local_notifications_web/lib/src/plugin.dart`)*. The facade's `openAppNotificationSettings()` throws `UnimplementedError` on web.
  - **Windows:** the plugin has no permission method (`flutter_local_notifications_windows/lib/src/plugin/base.dart` only has `initialize`, `show`, `zonedSchedule` and similar). `openAppNotificationSettings()` is not overridden, so it throws the platform interface's `UnimplementedError`.
  - `openAppNotificationSettings()` arrived in **22.3.0** (CHANGELOG), so require `^22.3.0`.
- **Native config:**
  - **Android:** the plugin's own manifest already declares `POST_NOTIFICATIONS` and `VIBRATE`, so they merge in without any work. The app must turn on **core library desugaring** (`isCoreLibraryDesugaringEnabled = true` plus `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`) and set **`compileSdk` to at least 37**. To see the runtime prompt the app must target 33+ (README, "Gradle setup" and "Requesting permissions on Android 13 or higher"). `initialize()` takes an `AndroidInitializationSettings('<icon>')`, which needs a drawable icon resource.
  - **iOS / macOS:** no Info.plist key and no entitlement for local notifications. Pass `requestAlertPermission/Badge/Sound: false` in `DarwinInitializationSettings`, otherwise `initialize()` itself shows the prompt (README, "Requesting notification permissions"). The README's iOS "General setup" adds the `UNUserNotificationCenter` delegate line to `AppDelegate`. That line is for foreground presentation and isn't needed for the permission check.
  - **Web:** no HTML or JS changes. Request only after a user gesture (README, "Web limitations").
  - **Windows:** `WindowsInitializationSettings` (app name, AUMID, GUID) is needed only to *show* toasts.

### 2.3 `firebase_messaging` 17.0.0 (published 2026-10-15)

- **Platforms:** android, ios, macos and web (`firebase_messaging_web` 4.3.0). **No Windows.**
- **Without Firebase it can't be used on any platform.** `FirebaseMessaging.instance` runs `Firebase.app()` (`lib/src/messaging.dart`). `MethodChannelFirebase.app()` throws `noAppExists(name)` when no app has been initialised (`firebase_core_platform_interface/.../method_channel_firebase.dart`). `requestPermission()` is an instance method, so it can't be reached first.
- What it would do once Firebase is set up (its own doc comment): it shows the dialog on iOS, a notification prompt on macOS and the browser prompt on web. On Android it **returns a `NotificationSettings` that reflects whether notifications are enabled**. The doc comment doesn't say it prompts there, so don't rely on it for the API 33 prompt.
- Its `NotificationSettings.authorizationStatus` (`notDetermined` / `denied` / `authorized` / `provisional`) is a richer model than flutter_local_notifications' booleans, and is worth mirroring in our own state enum.
- **Native config:** push needs the `aps-environment` entitlement and APNs keys on Apple platforms. That is out of scope for v1 (ticket 10 says push is manual work).

### 2.4 `app_settings` 9.0.1 (published 2026-10-15)

- **Platforms:** android, ios and macos (pubspec). **No web, no Windows.**
- `AppSettings.openAppSettings(type: AppSettingsType.notification)`:
  - **Android:** `openNotificationSettings` (`AppSettingsPlugin.kt`).
  - **iOS:** `UIApplication.openNotificationSettingsURLString` on 16+, `UIApplicationOpenNotificationSettingsURLString` on 15.4+, otherwise `openSettingsURLString` (`AppSettingsPlugin.swift`).
  - **macOS:** `x-apple.systempreferences:com.apple.Notifications-Settings.extension`, which is the system-wide pane rather than the app's page.
  - If a type isn't supported on the platform, the general app settings open instead (README).
- **Config:** none. The README's only note is `use_frameworks!` for Objective-C iOS projects. The plugin is Swift and supports SwiftPM.
- It **can't check or request** anything. Only pair it with `permission_handler`, and `flutter_local_notifications` already covers what it does.

## 3. What each platform reports when there is no runtime permission

| Platform | OS behaviour (primary source) | `permission_handler` reports | `flutter_local_notifications` reports |
|---|---|---|---|
| **Android ≤ 12L (API ≤ 32)** | No `POST_NOTIFICATIONS` runtime permission. Notifications are on unless the user turned them off in Settings, and `areNotificationsEnabled()` is the check (Android docs, "Notification runtime permission"). | `granted` / `denied` from `areNotificationsEnabled()`; `request()` shows no prompt | `areNotificationsEnabled()` bool; `requestNotificationsPermission()` returns that same bool, no prompt |
| **Android 13+ targeting 33+** | Notifications are **off by default** on fresh installs. The app controls when the dialog appears. Swiping the dialog away leaves the state unchanged (Android docs). | `denied` until granted; only `request()` can return `permanentlyDenied` | bool; a request after permanent denial returns `false` with no dialog |
| **Android 13+ targeting ≤ 32** | The system shows the prompt itself when the app creates its first channel. One "Don't allow" means no more prompts until reinstall or until the app targets 33+ (Android docs). | — | — |
| **Windows** | No runtime prompt. The user or admin can disable toasts, which surfaces as `ToastNotifier.Setting` / `NotificationSetting` (`Enabled`, `DisabledForApplication`, `DisabledForUser`, `DisabledByGroupPolicy`, `DisabledByManifest`) (Microsoft Learn, `NotificationSetting`). The settings URI is `ms-settings:notifications` (Microsoft Learn, "Launch the Windows Settings app"). | always `granted`, even when toasts are disabled | no API |

Neither plugin reads `NotificationSetting`. If a "disabled in Windows settings" state is ever needed, it takes a native call or FFI to WinRT. For v1, treat Windows as "not applicable" and, if anything, offer `ms-settings:notifications` through `url_launcher` (a package we don't use yet).

## 4. Web: what browsers return

- `Notification.permission` is `"granted"`, `"denied"` or `"default"`, and "default" means the user decision is unknown, so act as if denied (MDN). `Notification.requestPermission()` resolves to the same three strings (MDN).
- Browser support (MDN browser-compat-data, current `@mdn/browser-compat-data`):

| | Chrome | Firefox | Safari (macOS) | Safari (iOS/iPadOS) |
|---|---|---|---|---|
| `Notification.permission` | 32 | 22 | 7 | 16.4, **only for a web app saved to the Home Screen with a non-default manifest `display`**. Otherwise `Notification` is undefined. |
| `requestPermission()` returns a Promise | 47 | 46 | 15 | 16.4 (same Home Screen limit) |
| `permissions.query({name:'notifications'})` | 43 | 46 (alias of `push`) | 16.4 | 16.4 |
| User-gesture requirement | — | **72+: only in response to a user gesture**; 70+: not from cross-origin iframes | — (BCD has no note) | — |

- Permissions API states are `"granted"` / `"denied"` / `"prompt"`. `permission_handler` turns `prompt` into `denied` and `denied` into `permanentlyDenied`. `flutter_local_notifications` exposes the raw `Notification.permission` (`default` instead of `prompt`).
- In Safari on iOS in a normal tab, `Notification` doesn't exist. `flutter_local_notifications_web`'s getter reads `Notification.permission` directly, so check for that (or `kIsWeb` plus a JS feature check) before calling it *(not tested)*.
- No browser API opens site settings. Show text instead ("Allow notifications in your browser's site settings").

## 5. Platform-level notes

- **iOS/macOS** (Apple, "Asking permission to use notifications"): the first `requestAuthorization` shows the prompt and records the answer. **Later requests don't prompt**, so a repeat request is a cheap way to read the current answer. Apple advises asking in context, not at launch. Provisional authorization delivers quietly with no prompt.
- **macOS:** local notifications need no entitlement or Info.plist key. `aps-environment` is only for remote push (not in v1).

## 6. Recommendation

Use **`flutter_local_notifications: ^22.3.0`** as the only notification-permission dependency, wrapped in a `NotificationPermissionRepository`. Under the AGENTS.md architecture, an in-memory fake is the default and is used in tests, and the plugin-backed implementation is selected at startup. Give it one state enum modelled on FCM's `authorizationStatus`: `notDetermined | granted | denied | notApplicable`. Map it per platform:

- **Android / iOS / macOS:** check via `areNotificationsEnabled()` / `checkPermissions().isEnabled`, request via the platform-specific `request*`, and when the request returns `false` offer "Open settings" through `openAppNotificationSettings()`. "Not determined" can't be detected on these platforms, so keep a `shared_preferences` flag "asked once" to choose between showing the request button and the settings button.
- **Web:** use `permissionStatus` (`default` → `notDetermined`) and `requestNotificationsPermission()`, called only from a button tap. Never show a settings button; show instructions instead. Guard against `Notification` being undefined (iOS Safari outside a Home Screen web app).
- **Windows / Linux:** `notApplicable`. Skip the Permissions step entry, or show it as "Managed by your system", without calling a plugin.

Why not the others: `permission_handler` has no macOS and fakes `granted` on Windows, and its Windows `openAppSettings` is broken. That would still need `app_settings` for macOS, so it means two packages for fewer platforms. `firebase_messaging` throws without `Firebase.initializeApp()`. The cost of this choice is the Android build config (desugaring, `compileSdk` 37) and an icon for `AndroidInitializationSettings`. Codex should handle that in the ticket that adds the dependency. The same plugin can later show the local notifications behind the Settings toggles if ticket 10 decides they should deliver anything.

## Sources

1. pub.dev API: `https://pub.dev/api/packages/{permission_handler, permission_handler_android, permission_handler_apple, permission_handler_html, permission_handler_windows, flutter_local_notifications, flutter_local_notifications_windows, firebase_messaging, firebase_messaging_web, app_settings}`, and the `flutter_local_notifications-22.3.2.tar.gz` archive.
2. Baseflow/flutter-permission-handler (`main`): `permission_handler/README.md`; `permission_handler_android/.../PermissionManager.java`, `PermissionUtils.java`, `AppSettingsManager.java`; `permission_handler_apple/pubspec.yaml`, `ios/permission_handler_apple/Package.swift`, `.../strategies/NotificationPermissionStrategy.m`, `.../PermissionManager.m`; `permission_handler_html/lib/web_delegate.dart`, `permission_handler_html.dart`; `permission_handler_windows/windows/permission_handler_windows_plugin.cpp`.
3. MaikuB/flutter_local_notifications (`master`): `flutter_local_notifications/README.md`, `CHANGELOG.md`, `android/src/main/AndroidManifest.xml`, `lib/src/platform_flutter_local_notifications.dart`, `lib/src/flutter_local_notifications_plugin.dart`, `lib/src/platform_specifics/darwin/notification_enabled_options.dart`, `.../FlutterLocalNotificationsPlugin.java`; `flutter_local_notifications_web/lib/src/plugin.dart`; `flutter_local_notifications_windows/lib/src/plugin/base.dart`; `flutter_local_notifications_platform_interface/lib/flutter_local_notifications_platform_interface.dart`.
4. firebase/flutterfire (`main`): `packages/firebase_messaging/firebase_messaging/lib/src/messaging.dart`; `packages/firebase_core/firebase_core_platform_interface/lib/src/method_channel/method_channel_firebase.dart`.
5. spencerccf/app_settings (`master`): `README.md`, `pubspec.yaml`, `android/.../AppSettingsPlugin.kt`, `ios/.../AppSettingsPlugin.swift`, `macos/.../AppSettingsPlugin.swift`, `AppSettingsEnums.swift`.
6. Android Developers, "Notification runtime permission": https://developer.android.com/develop/ui/views/notifications/notification-permission (last updated 2026-10-16).
7. Apple, "Asking permission to use notifications": https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications; `UNAuthorizationStatus`.
8. MDN: `Notification.permission`, `Notification.requestPermission()` (mdn/content), and `@mdn/browser-compat-data` (`api.Notification.permission_static`, `api.Notification.requestPermission_static`, `api.Permissions.permission_notifications`, `api.Permissions.query`).
9. Microsoft Learn: `Windows.UI.Notifications.NotificationSetting`; "Launch the Windows Settings app" (`ms-settings:notifications`).
