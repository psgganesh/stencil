# Firebase support on each platform (FlutterFire)

Research for ticket [05](../issues/05-firebase-platform-support.md). Sources checked on 2026-10-19.

## TL;DR

- **Android, iOS and web are fully supported** for core, auth, Firestore and FCM. **macOS is beta.** **Windows works for core, auth and Firestore, but only for development.** Firebase says it is "not intended for production". FCM has no Windows support at all.
- **Google sign-in works on Android, iOS, macOS and web.** **Apple sign-in works on iOS, macOS, Android and web.** **Neither works on Windows**: `signInWithProvider` is unimplemented there, and neither `google_sign_in` nor `sign_in_with_apple` supports Windows.
- **Offline persistence is on by default on Android, iOS and macOS.** On web it is off by default: you opt in, and it only works in Chrome, Safari and Firefox.
- **Config detection:** commit a stub `lib/firebase_options.dart`. It has the same shape the FlutterFire CLI generates, and every platform throws `UnsupportedError`. At startup, `main()` reads `DefaultFirebaseOptions.currentPlatform` and calls `Firebase.initializeApp(options: …)` inside a try/catch. If either step fails, it falls back to the fakes. Don't rely on the native `google-services.json` / `GoogleService-Info.plist` files, and don't call `initializeApp()` without options.

## 1. Platform × feature table

| Feature | Android | iOS | Web | macOS | Windows |
|---|---|---|---|---|---|
| `firebase_core` | ✔ | ✔ | ✔ | β | dev only (*) [1][2] |
| `firebase_auth` | ✔ | ✔ | ✔ | β | dev only (*) [1][2] |
| `cloud_firestore` | ✔ | ✔ | ✔ | β | dev only (*) [1][2] |
| Google sign-in | ✔ `google_sign_in` + `signInWithCredential` [3][4] | ✔ same [3][4] | ✔ `signInWithPopup` / `signInWithRedirect` [3] | ✔ `google_sign_in` (via `google_sign_in_ios`) [4] | ✘ no plugin, and `signInWithProvider` is unimplemented [4][7][8] |
| Apple sign-in | ✔ `signInWithProvider(AppleAuthProvider())` (web flow) [3] | ✔ `signInWithProvider`; needs the "Sign in with Apple" capability [3] | ✔ `signInWithPopup` [3] | ✔ ("iOS+" in the docs; `sign_in_with_apple` lists macOS) [3][5] | ✘ [5][7][8] |
| FCM (`firebase_messaging`) | ✔ Android 7+ with Play services [9] | ✔ needs an APNs key [9] | ✔ needs a VAPID key and a service worker [9][10] | β [1] | ✘ N/A [1][6] |
| Firestore offline persistence | on by default [11] | on by default [11] | **off** by default; opt in; Chrome, Safari and Firefox only [11] | on by default (Apple) [11] | the plugin passes `persistenceEnabled` and `cacheSizeBytes` through to the C++ SDK [12] |

(*) The FlutterFire README says: "for development only. Production on Windows is not supported." [1] The Firebase setup page says: "Firebase on Windows is not intended for production use cases, only local development workflows." [2] Its plugin table marks auth, Firestore and storage as **beta** on Windows [2].

### Notes per area

- **Windows auth limits.** The Windows plugin wraps the Firebase C++ SDK. The C++ SDK documents that `SignInWithProvider` "is supported only on iOS, tvOS and Android platforms. On other platforms this method will return … `kAuthErrorUnimplemented`" [8]. The Flutter Windows plugin also returns `unimplemented` for 11 auth methods, including `applyActionCode`, `checkActionCode` and `confirmPasswordReset` [7]. Email/password and `signInWithCredential` (for example with a Google `idToken`) do work there [7]. So on Windows, social sign-in would need its own desktop OAuth flow that produces a credential. That flow isn't worth building for a dev-only platform.
- **Google sign-in on web.** With `google_sign_in` 7.x, a user-started sign-in on web has to use the button the Google SDK renders (`renderButton`). The app can't use its own button for it [4]. The Firebase-only path (`signInWithPopup(GoogleAuthProvider())`) avoids this [3].
- **Apple sign-in setup.** All platforms need Sign in with Apple configured in the Apple Developer portal and the Apple provider turned on in the Firebase console [3]. Android and web also need a Services ID and a return URL [5]. That is manual console work, like APNs.
- **Offline persistence API (Dart).** On Apple and Android: `db.settings = const Settings(persistenceEnabled: true)`, which is the default. On web: `await db.enablePersistence(const PersistenceSettings(synchronizeTabs: true))` [11]. The web cache isn't cleared between sessions, so Firebase advises asking whether the device is trusted before enabling it for sensitive data [11].

## 2. FCM push: what each platform needs

| Platform | Needs | Manual work outside the repo? |
|---|---|---|
| iOS (and macOS, β) | Push Notifications and Background Modes (Background fetch, Remote notifications) capabilities in Xcode. **Upload an APNs `.p8` auth key** (key ID and Team ID) to the Firebase console. At least one of dev/prod is required. Method swizzling must stay on. Call `requestPermission()`. Call `getAPNSToken()` before any other FCM call. [9][10] | **Yes**: an Apple Developer account, creating the APNs key, uploading it to Firebase |
| Android | A device or emulator on Android 7.0+ with Google Play services or Google APIs [9]. A runtime permission prompt on Android 13+ (`requestPermission`) [10] | No |
| Web | A VAPID key pair, generated or imported in the Firebase console, passed as `getToken(vapidKey: …)` [9]. A `web/firebase-messaging-sw.js` service worker for background messages [10]. A permission prompt [10] | Yes: generating the VAPID key in the console |
| Windows | Not supported [1][6] | — |

Background message handlers run in a separate isolate on Android only. iOS and macOS don't spawn one [10]. The iOS simulator doesn't show images in push notifications [10].

## 3. How the app tells that "Firebase is configured"

### What happens with each option

| Option | Behaviour without config | Verdict |
|---|---|---|
| `Firebase.initializeApp()` with **no options**, relying on native files | On web it fails an assert: "FirebaseOptions cannot be null when creating the default app." [13] On Android, `optionsFromResource` throws "Failed to load FirebaseOptions from resource…" [14] It never works on Windows or macOS without options. | ✘ It only fails at runtime, the behaviour differs per platform, and web can't use it at all |
| Check for `google-services.json` / `GoogleService-Info.plist` | These files are native build inputs. Dart can't see them at runtime. If the Android `google-services` Gradle plugin is applied and the JSON file is missing, the Android build fails (unverified here, see Open questions). | ✘ Not detectable from Dart; it can break the build |
| Import a **gitignored** `firebase_options.dart` | Any clone without it fails to compile | ✘ Breaks the build |
| **Commit a stub `lib/firebase_options.dart`** in the CLI's shape, where each platform `throw`s `UnsupportedError('DefaultFirebaseOptions have not been configured for <platform> - …')` | It compiles everywhere. Reading `currentPlatform` throws `UnsupportedError`. When you run `flutterfire configure`, the CLI rewrites the file in place. It removes the `throw UnsupportedError(` line for each platform it configures and writes the `static const FirebaseOptions <platform>` [15][16]. | ✔ **Recommended** |
| `--dart-define=…` (`bool.fromEnvironment`) | A compile-time constant, default `false`. It doesn't touch the build. But the options still have to come from somewhere, and someone has to remember the flag. | Optional extra: use it as a **force fakes** override, not as the main signal |

### Recommended approach

1. **Commit `lib/firebase_options.dart` as a stub.** It has the `DefaultFirebaseOptions.currentPlatform` switch, and every platform throws `UnsupportedError`. That is exactly the shape the FlutterFire CLI emits for platforms that aren't configured [16]. The IDs it later holds are "unique, but non-secret" [2], so it's safe to commit after `flutterfire configure` too.
2. **In `main()`, before `runApp`, run one check:**
   - Wrap `DefaultFirebaseOptions.currentPlatform` in a try/catch for `UnsupportedError`. If it throws, use the fakes.
   - Otherwise call `await Firebase.initializeApp(options: …)` inside a try/catch. If it throws, use the fakes and log the error.
   - Optionally, `const bool.fromEnvironment('USE_FAKES')` short-circuits to fakes, for demos or screenshots against a configured build.
   - Pass the result to the root `ProviderScope` as repository overrides, as `AGENTS.md` says.
3. **Leave Windows unconfigured on purpose.** When `flutterfire configure` is run, don't select Windows. Windows then keeps throwing `UnsupportedError` and falls back to the fakes, which fits "dev only" [1][2]. You can also gate it explicitly on `defaultTargetPlatform == TargetPlatform.windows`.
4. **Tests never touch Firebase.** `flutter test` runs on the host VM, with no Firebase plugin implementation. Tests override the repository providers directly, as they already do. The detection lives only in `main()`, so tests never run it.
5. **Native files are optional for this app.** Core, auth and Firestore initialise from the Dart options, so the app runs from `firebase_options.dart` alone. FCM on iOS still needs APNs set up in Xcode and the console (section 2), not a plist check.

(Firebase also documents `Firebase.initializeApp(demoProjectId: 'demo-…')` for use with the Emulator Suite [2]. That could become a third mode later: "configured, but local".)

## Open questions / not verified

- I did not check whether the current `flutterfire configure` always adds the `com.google.gms.google-services` Gradle plugin and writes `google-services.json`. If it does, and that JSON is gitignored, Android builds from a clean clone would fail. Codex should check this right after running the CLI, and either commit the generated native files or remove the plugin.
- Firestore offline persistence on **Windows**: the plugin forwards the setting to the C++ SDK [12], but I found no Flutter doc that states the default or whether it is reliable there. It doesn't matter much for a dev-only platform.
- macOS is "β" across the board [1][2]. Treat it like Windows (fakes) unless the spec says macOS needs a real backend.

## Sources

1. FlutterFire README, "Stable Plugins" table and footnote: https://github.com/firebase/flutterfire/blob/main/README.md
2. Firebase docs, "Get started with Firebase in your Flutter project" (the `flutterfire configure` steps, `demoProjectId`, the Available plugins table, the Windows caution): https://firebase.google.com/docs/flutter/setup
3. Firebase docs, "Federated identity and social sign-in" (Flutter): https://firebase.google.com/docs/auth/flutter/federated-auth
4. pub.dev, `google_sign_in` 7.2.0 (platforms: Android, iOS, macOS, web): https://pub.dev/packages/google_sign_in
5. pub.dev, `sign_in_with_apple` (platforms: iOS, macOS, Android, web; Services ID setup): https://pub.dev/packages/sign_in_with_apple
6. pub.dev, `firebase_messaging` (platforms: Android, iOS, macOS, web; no Windows); `firebase_auth` and `cloud_firestore` list Windows: https://pub.dev/packages/firebase_messaging, https://pub.dev/packages/firebase_auth, https://pub.dev/packages/cloud_firestore
7. FlutterFire source, `firebase_auth` Windows plugin (the `unimplemented` errors, `SignInWithCredential`, `SignInWithProvider`): https://github.com/firebase/flutterfire/blob/main/packages/firebase_auth/firebase_auth/windows/firebase_auth_plugin.cpp
8. Firebase C++ SDK, `auth.h` (`SignInWithProvider` is supported only on iOS, tvOS and Android): https://github.com/firebase/firebase-cpp-sdk/blob/main/auth/src/include/firebase/auth.h
9. Firebase docs, "Get started with Firebase Cloud Messaging in Flutter apps": https://firebase.google.com/docs/cloud-messaging/flutter/client
10. Firebase docs, "Receive messages in a Flutter app": https://firebase.google.com/docs/cloud-messaging/flutter/receive
11. Firebase docs, "Access data offline" (Firestore, Dart snippets): https://firebase.google.com/docs/firestore/manage-data/enable-offline
12. FlutterFire source, `cloud_firestore` Windows plugin (`persistence_enabled`, `cache_size_bytes`): https://github.com/firebase/flutterfire/blob/main/packages/cloud_firestore/cloud_firestore/windows/cloud_firestore_plugin.cpp
13. FlutterFire source, `firebase_core_web` (the assert when options are null): https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_web/lib/src/firebase_core_web.dart
14. FlutterFire source, `firebase_core` Android `optionsFromResource`: https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core/android/src/main/kotlin/io/flutter/plugins/firebase/core/FlutterFirebaseCorePlugin.kt
15. FlutterFire source, `Firebase.initializeApp` (`demoProjectId`, `apps`): https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core/lib/src/firebase.dart
16. FlutterFire CLI source, `firebase_dart_configuration_write.dart` (the `UnsupportedError` template and in-place rewrite): https://github.com/invertase/flutterfire_cli/blob/main/packages/flutterfire_cli/lib/src/firebase/firebase_dart_configuration_write.dart
