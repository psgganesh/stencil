# Manual tasks

These are the steps a person has to do by hand, outside the code, to take stencil from "runs locally" to "ships to every store". Do them in this order. Each step says **where** to do it, what it **produces**, and **what uses it**. Tick the box when you're done.

## What already works with nothing set up

- The app runs on every platform using the in-memory fakes. Sign-in accepts any valid email, and demo data is seeded. No Firebase project is needed.
- Every push to `main` runs `validate`, `build_web`, `check_play`, `build_android` and `build_windows`. Each deploy job is skipped and logs which secrets it's waiting for.
- `build_ios`, `build_macos` and their deploys are skipped until the self-hosted Mac runner is ready (section 8).

You can do the sections below whenever you like. Each one turns on a specific piece and nothing else.

---

## 1. App identity

Do this **first**. Store records can't be renamed later.

- [ ] **Choose the real app name and app ID** (reverse DNS, for example `com.yourcompany.yourapp`).
  - Where: `app_identity.yaml` at the repo root. Set `app_name`, `app_id` and `artifact_name` (the file name used for builds, no spaces).
  - Produces: the identity every platform uses.
  - Used by: every build and deploy job, and the app's UI.
- [ ] **Apply it** with the identity command (see the Foundation spec), then commit.
  - Produces: rewritten Android, iOS, macOS, Windows, Linux, web and msix files.
  - Used by: `validate`, which fails on any drift (`--check`).
- [ ] **Fill in the Microsoft Store identity later**, in section 5.

## 2. Firebase

Needed only when the Firestore effort lands. v1 runs on the fakes either way.

- [ ] **Create a Firebase project.**
  - Where: https://console.firebase.google.com
  - Produces: the project ID.
- [ ] **Turn on Email/Password sign-in, and leave email enumeration protection on** (the default).
  - Where: Firebase console → Authentication → Sign-in method.
  - Used by: the real `AuthRepository` (later effort).
- [ ] **Run `flutterfire configure`** for Android, iOS, macOS, web and Windows, using the app ID from section 1.
  - Produces: `firebase_options.dart` (replacing the committed stub), `google-services.json` and `GoogleService-Info.plist`.
  - Used by: Firebase detection at startup. **Commit these files.** They're public client identifiers, not secrets; security rules protect the data.

## 3. Apple (iOS and macOS)

Needs the paid Apple Developer Program ($99/yr).

- [ ] **Register the app ID** from section 1, with Keychain Sharing turned on (needed by Firebase Auth on macOS).
  - Where: https://developer.apple.com/account → Certificates, IDs & Profiles → Identifiers.
- [ ] **Create the certificates** and install them in the runner Mac's login keychain:
  - Apple Distribution (iOS);
  - Mac App Distribution and Mac Installer Distribution (macOS).

  An Admin can create these; you don't need the Account Holder.
  - Used by: `build_ios`, `build_macos`.
- [ ] **Create App Store provisioning profiles** for iOS and macOS. The macOS profile must include Keychain Sharing.
  - Where: Certificates, IDs & Profiles → Profiles.
  - Used by: `build_ios`, `build_macos`.
- [ ] **Create the iOS and macOS app records.**
  - Where: https://appstoreconnect.apple.com → Apps.
  - Used by: `deploy_ios`, `deploy_macos`.
- [ ] **Create an App Store Connect API key** (role: App Manager).
  - Where: App Store Connect → Users and Access → Integrations → App Store Connect API.
  - Produces: `APPSTORE_API_KEY_ID`, `APPSTORE_ISSUER_ID`, and the `.p8` file contents for `APPSTORE_API_PRIVATE_KEY`.
  - Used by: `build_ios`, `deploy_ios`, `build_macos`, `deploy_macos`.

## 4. Google Play (Android)

- [ ] **Create an upload keystore** (`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`). Keep it safe; losing it means asking Google for a key reset.
  - Produces: `ANDROID_KEYSTORE_BASE64` (`base64 -i upload-keystore.jks`), `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.
  - Used by: `build_android`.
- [ ] **Create the app** with the package name `app_id`.
  - Where: https://play.google.com/console
- [ ] **Upload the first AAB by hand** to the internal track. Google Play won't accept API uploads before this. Download it from a `build_android` run's artifacts once the keystore secrets are set.
- [ ] **Create a service account** with access to the app, and download its JSON key.
  - Where: Google Cloud console → IAM → Service accounts, then Play Console → Users and permissions (invite the service account's email, with release permissions for this app).
  - Produces: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (the whole JSON).
  - Used by: `check_play`, `deploy_android`.

## 5. Microsoft Partner Center (Windows)

The account is free for individuals. The Store signs the package, so no certificate is needed.

- [ ] **Reserve the app name.**
  - Where: https://partner.microsoft.com/dashboard → Apps and games → New product → MSIX or PWA app.
  - Produces: the **Package/Identity/Name**, **Publisher** and **Publisher display name** (Product identity page), and the **Store ID**.
  - Used by: `app_identity.yaml` (the Store identity fields and `msstore_product_id`). Re-run the identity command and commit.
- [ ] **Submit the first MSIX by hand.** Download it from a `build_windows` run's artifacts. The Store API only updates an existing submission.
- [ ] **Create a Microsoft Entra app** and link it to Partner Center.
  - Where: Partner Center → Account settings → User management → Microsoft Entra applications. Create a client secret.
  - Produces: `MSSTORE_TENANT_ID`, `MSSTORE_CLIENT_ID`, `MSSTORE_CLIENT_SECRET`, and `MSSTORE_SELLER_ID` (Account settings → Legal info → Seller ID).
  - Used by: `deploy_windows`.

## 6. Netlify (web)

- [ ] **Create a site** (no Git connection needed; CI uploads the build).
  - Where: https://app.netlify.com
  - Produces: `NETLIFY_SITE_ID` (Site configuration → Site ID).
- [ ] **Create a personal access token.**
  - Where: User settings → Applications → Personal access tokens.
  - Produces: `NETLIFY_AUTH_TOKEN`.
  - Used by: `deploy_web`.

## 7. GitHub secrets and variables

- [ ] **Add each secret you've produced so far.**
  - Where: repo → Settings → Secrets and variables → Actions → Secrets.
  - Leave a secret unset until you have its real value. An unset secret simply skips its deploy.

| Secret | From section | Used by |
|---|---|---|
| `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID` | 6 | `deploy_web` |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` | 4 | `build_android`, `deploy_android` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | 4 | `check_play`, `deploy_android` |
| `APPSTORE_API_KEY_ID`, `APPSTORE_API_PRIVATE_KEY`, `APPSTORE_ISSUER_ID` | 3 | iOS and macOS build and deploy |
| `MAC_KEYCHAIN_PASSWORD` | 8 | `build_ios`, `build_macos` |
| `MSSTORE_TENANT_ID`, `MSSTORE_CLIENT_ID`, `MSSTORE_CLIENT_SECRET`, `MSSTORE_SELLER_ID` | 5 | `deploy_windows` |

- [ ] **Set the variable `MAC_RUNNER_READY` to `true`** once section 8 is done.
  - Where: Settings → Secrets and variables → Actions → Variables.

## 8. Self-hosted Mac runner (iOS and macOS)

- [ ] **Register the Mac as a runner** with the labels `self-hosted` and `macOS`.
  - Where: repo → Settings → Actions → Runners → New self-hosted runner. Run it as a service so it survives restarts.
- [ ] **Install Flutter 3.47.5 stable** (the same version CI pins elsewhere), Xcode, and CocoaPods.
- [ ] **Sign Xcode into the Apple developer account** (Xcode → Settings → Accounts), so that automatic signing can find the profiles.
- [ ] **Install the certificates from section 3** in the login keychain.
- [ ] **Note the login keychain password.**
  - Produces: `MAC_KEYCHAIN_PASSWORD`.
  - Used by: `build_ios`, `build_macos`.
- [ ] **Then set `MAC_RUNNER_READY=true`** (section 7).

## 9. Later: push delivery

Not used in v1. The toggles only save preferences. Do this when push delivery is built.

- [ ] Upload an **APNs `.p8` authentication key** to Firebase (Project settings → Cloud Messaging), and turn on the Push Notifications capability for iOS and macOS.
- [ ] Create a **web push (VAPID) key pair** in Firebase Cloud Messaging, and add `firebase-messaging-sw.js` to the web build.
- [ ] Turn on **Firebase Cloud Messaging** for Android, iOS, macOS and web. Windows has no FCM.
