# Manual-tasks document

Type: grilling
Status: resolved
Blocked by: 18

## Question

Decide the shape, location and contents of the checklist the human follows before CI and Firebase work end to end:
- **Firebase:** creating the project, turning on the Email/Password provider (and leaving email enumeration protection on), the service JSON files, and the FCM, APNs `.p8` and VAPID keys for push delivery;
- **Stores and signing:** certificates and keys, RevenueCat, choosing the app name and bundle ID, and the first AAB uploaded to Play by hand;
- **CI:** filling in the GitHub secrets, and setting up the self-hosted runner (keychain certificate, Xcode account, JDK 17, Android SDK);
- **Desktop:** the steps from [macOS and Windows distribution](18-desktop-distribution.md).

The reference workflow hard-codes `au.com.devhustlers.catalyst` and `Catalyst.ipa`. Decide the **single place** that holds the app name, app ID and artifact name, which both the CI spec and the app read from. Also decide where the document lives (for example `docs/manual-tasks.md`) and whether each step names the secret or file it produces.

## Answer

Resolved by grilling on 2026-10-19.

### App identity: one place

- **`app_identity.yaml` at the repo root** holds `app_name`, `app_id` (reverse DNS), `artifact_name`, and the Microsoft Store identity values (Identity Name, Publisher, Publisher display name). None of these are secret.
- **`dart run tool/apply_identity.dart`** rewrites these files from the YAML:
  - Android `applicationId` and `namespace`;
  - the iOS and macOS `PRODUCT_BUNDLE_IDENTIFIER`;
  - the Windows and Linux binary names;
  - the web manifest and `<title>`;
  - the msix config.

  It also writes `lib/core/app_identity.dart`, the constants the UI reads (such as the app name in the web top bar).
- **CI** runs the script with `--check` and fails if any file has drifted from the YAML. CI reads `artifact_name` and `app_id` from the YAML, replacing the reference workflow's hard-coded `au.com.devhustlers.catalyst` and `Catalyst.ipa`.
- **Foundation** ships it with placeholder values (`Stencil`, `com.example.stencil`).

### Firebase config files

`flutterfire configure` produces `firebase_options.dart`, `google-services.json` and `GoogleService-Info.plist`. These are **committed by the human**, replacing the stub `firebase_options.dart`. They're public client identifiers; security rules protect the data. CI doesn't inject them.

### Secrets

- **Existing (from the reference workflow):** `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `APPSTORE_API_KEY_ID`, `APPSTORE_API_PRIVATE_KEY`, `APPSTORE_ISSUER_ID`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`, `MAC_KEYCHAIN_PASSWORD`, `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`.
- **New:** `MSSTORE_TENANT_ID`, `MSSTORE_CLIENT_ID`, `MSSTORE_CLIENT_SECRET`, `MSSTORE_SELLER_ID` for `deploy_windows`. macOS reuses the `APPSTORE_*` secrets and `MAC_KEYCHAIN_PASSWORD`. There are no other new secrets.

### RevenueCat

**Left out**, because real purchases are out of scope. It's added to the map's Out of scope.

### The document

- **File:** `docs/manual-tasks.md`.
- **At the top:** what works with nothing set up. The app runs on the fakes, every build job runs, and every deploy is skipped.
- **Sections, in order:**
  1. **App identity:** edit the YAML and run the script. Pick the real app ID before creating any store record.
  2. **Firebase:** create the project; turn on the Email/Password provider (leave email enumeration protection on); run `flutterfire configure`; commit the configs.
  3. **Apple:** certificates, the App Store Connect API key, the iOS and macOS app records, and provisioning profiles (App Store, with Keychain Sharing for macOS).
  4. **Google Play:** the upload keystore, the service account, and the first AAB uploaded by hand.
  5. **Microsoft Partner Center:** the app name reservation, the Entra app, and the first MSIX submission by hand.
  6. **Netlify.**
  7. **GitHub secrets.**
  8. **Self-hosted runner:** keychain certificate, Xcode account, JDK 17, Android SDK.
  9. **Later, push delivery:** APNs `.p8`, VAPID key, FCM.
- **Each step** has a checkbox, *what to do*, *where* (the console link), *produces* (the file, secret or value), and *used by* (the CI job or file).
- **Who writes it, and when:** Claude writes it as markdown together with the CI/CD spec, so the secret and job names come straight from that spec. The spec links to it.

### Glossary

**app identity** has been added.
