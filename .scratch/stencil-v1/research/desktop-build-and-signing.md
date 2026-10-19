# Desktop build, signing and distribution (macOS, Windows)

Research for ticket [17](../issues/17-desktop-build-and-signing-research.md), which feeds the grilling ticket [18](../issues/18-desktop-distribution.md). Sources checked on 2026-10-19. Apple pages were read through their JSON doc endpoints. Microsoft prices come from the Azure Retail Prices API, because the pricing page fills its numbers in with JavaScript. `xcodebuild -help` and `xcrun notarytool submit --help` were run on this Mac (Xcode 27.1). Nothing was built, signed or uploaded. Statements marked *(inference)* are my reasoning, not something a source says.

## TL;DR

- **macOS has two routes, and each needs its own certificates.** The Mac App Store route needs *Mac App Distribution* and *Mac Installer Distribution* certificates, and it uploads a signed `.pkg` [M3]. Direct download needs a *Developer ID Application* certificate, the Hardened Runtime, a secure timestamp, and notarisation with `notarytool` [M1][M2]. Both routes need the $99/year Apple Developer Program [M8], which the iOS pipeline already pays for. Only the **Account Holder** can create Developer ID certificates [M4].
- **Firebase on macOS adds two things.** It needs `com.apple.security.network.client` in the release entitlements, because without it every request fails with `SocketException … Operation not permitted` [M5]. It also needs **Keychain Sharing** [F1][F2]. Keychain Sharing adds `keychain-access-groups`, which is a *restricted* entitlement, so a **distribution provisioning profile** has to be embedded in the app. That is a Mac App Store profile or a **Developer ID provisioning profile**, depending on the route [M6]. So the "zip and notarise" path is not profile-free once Firebase is in.
- **Windows: the Microsoft Store is now the cheapest signed route.** Developer accounts are free for individuals and companies [W1]. The Store re-signs MSIX packages, so the publisher needs no certificate and users see no SmartScreen prompt [W2]. The `msix` package (3.18.0) builds the MSIX with `store: true` [W3]. Flutter documents publishing from GitHub Actions with `microsoft/setup-msstore-cli` [W4].
- **Windows direct download needs a paid certificate, or SmartScreen will warn.** Azure **Artifact Signing** (formerly Trusted Signing) costs **$9.99/month Basic** (5,000 signatures) or **$99.99/month Premium** [W5][W6]. *Individuals* must be in the **US or Canada** [W7]. An OV certificate costs about $150–300/year and an EV certificate $400+/year. Microsoft says EV is no longer a SmartScreen bypass: with every signing option, reputation builds over time [W2].
- **Sideloaded MSIX from the web is awkward.** The `ms-appinstaller:` one-click protocol has been off by default on consumer devices since December 2023 [W8], and the `msix` package's web App Installer is disabled too [W3]. A direct download is therefore better served as a signed `.exe` installer (Inno Setup [W9]) or a zip.
- **Runners.** Every macOS step can run on the existing `[self-hosted, macOS]` runner, or on GitHub-hosted `macos-latest`/`macos-26`. Windows builds need a Windows machine. The self-hosted runner is macOS-only, so Windows jobs would run on GitHub-hosted `windows-latest` (Windows Server 2025) [G1], which is the same pattern `build_web` uses on `ubuntu-latest`.
- **Note for the repo:** the `macos/` template currently has `MACOSX_DEPLOYMENT_TARGET = 12.0` in `project.pbxproj`, while `AGENTS.md` says macOS 11. Both meet Firebase's minimum of macOS 11 [F1]. The release entitlements (`Release.entitlements`) contain only `app-sandbox`: there is no `network.client` and no keychain group yet.

## 1. macOS

### 1.1 Shared groundwork (both routes)

- **Build:** `flutter build macos --release` produces `build/macos/Build/Products/Release/<App>.app` [M3]. Flutter's own guide then archives in Xcode (Product › Archive), or uses Codemagic CLI tools with `productbuild` and `productsign` [M3]. For headless CI, the equivalent is `xcodebuild archive` on `macos/Runner.xcworkspace`, then `xcodebuild -exportArchive` with an `ExportOptions.plist` whose `method` is **`app-store-connect`** or **`developer-id`**. Both are export methods listed by `xcodebuild -help` on Xcode 27.1 [M9].
- **Entitlements** live in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`. Flutter tells you to edit both files directly, because the Xcode capabilities UI may change only one of them or create a new file [M5]. Builds are sandboxed by default. The App Sandbox is **required for the Mac App Store** and optional for Developer ID [M5].
- **What Firebase and the network need:**

  | Entitlement / capability | Why | Source |
  |---|---|---|
  | `com.apple.security.app-sandbox` = true | Already present. Required for the Mac App Store | [M5] |
  | `com.apple.security.network.client` = true | Outbound HTTPS (Firebase Auth, Firestore). Without it requests fail with errno 1 | [M5] |
  | Keychain Sharing → `keychain-access-groups` = [`$(AppIdentifierPrefix)<bundle id>`] | Firebase SDKs query the keychain with `kSecUseDataProtectionKeychain`, which needs an access group. Without it the user is asked for their keychain password | [F1][F2] |
  | `com.apple.security.network.server` | **Not** needed in release unless the app accepts incoming connections. It is only on by default in Debug/Profile, for the Flutter tooling | [M5] |
  | Hardened Runtime (`ENABLE_HARDENED_RUNTIME = YES`) | Required for notarisation (Developer ID). Harmless for the App Store | [M1][M5] |

- **The provisioning profile:** `keychain-access-groups` has to be authorised by a provisioning profile. When a program claims a restricted entitlement, Apple says to embed a *distribution* profile "that matches your distribution channel (Mac App Store or Developer ID)" as `Contents/embedded.provisionprofile` [M6]. Developer ID profiles made after 22 Feb 2017 are valid for 18 years, and Gatekeeper checks them at install and **at every launch** [M4].
- **Bundle ID:** the template still uses `com.example.stencil`. Both routes need a registered App ID *(inference: profiles are tied to an App ID)*.

### 1.2 Route A: Mac App Store

| | |
|---|---|
| **Certificates** | Mac App Distribution (signs the app) and Mac Installer Distribution (signs the `.pkg`) [M3] |
| **Profile** | Mac App Store distribution profile (needed because of the keychain group) [M6] |
| **Steps** | Register the bundle ID and create the App Store Connect record (macOS platform) [M3] → `flutter build macos --release` → archive and export (`app-store-connect`), or `productbuild --component <App>.app /Applications unsigned.pkg` then `productsign` [M3][M7] → upload → TestFlight / review |
| **Upload** | Flutter documents Xcode Organizer, Transporter, or Codemagic's `app-store-connect publish` [M3]. The repo's iOS job uses `xcrun altool --upload-app --apiKey … --apiIssuer …`. The macOS equivalent is `-t macos` with the `.pkg` *(inference: same tool, macOS type; not run)* |
| **Secrets** | The App Store Connect API key (`APPSTORE_API_PRIVATE_KEY`, `APPSTORE_API_KEY_ID`, `APPSTORE_ISSUER_ID`, which the iOS job already has) and `MAC_KEYCHAIN_PASSWORD`. Either install the two certificates in the runner's login keychain once (as for iOS today), or add base64 `.p12` + password + profile secrets for an ephemeral runner [G2] |
| **Review** | Yes, App Review, including sandbox compliance |
| **Users see** | A normal Store install, with no Gatekeeper prompts |

### 1.3 Route B: direct download (Developer ID + notarisation)

| | |
|---|---|
| **Certificates** | **Developer ID Application** (signs the `.app`; also the `.dmg`). Add Developer ID Installer only if a `.pkg` is shipped. Up to 5 of each. **Account Holder only** [M4][M10] |
| **Profile** | **Developer ID provisioning profile** (because of `keychain-access-groups`) [M4][M6] |
| **Requirements** | Every executable signed with Developer ID (not "Mac Distribution"), the Hardened Runtime on, a secure timestamp, and no `get-task-allow` [M1] |
| **Steps** | `flutter build macos --release` → archive and export with `method: developer-id` (Xcode adds the timestamp) [M1][M9] → package as a `.dmg` (`hdiutil`) or a zip (`ditto -c -k --keepParent`) [M7] → `xcrun notarytool submit <file> --wait` [M2] → `xcrun stapler staple` the `.dmg`/`.app`. You can't staple a zip: staple the `.app`, then zip it again [M2] |
| **notarytool auth** | Either `--key <p8> --key-id <id> --issuer <uuid>` (App Store Connect API key, the same key as the iOS upload) [M11], or `--apple-id/--team-id/--password` with an app-specific password, or `--keychain-profile` saved with `notarytool store-credentials` [M2]. `altool` notarisation has been refused since 1 Nov 2023 [M1] |
| **Network** | The runner must reach `notary-submissions-prod.s3-accelerate.amazonaws.com` (or use `--no-s3-acceleration`), and CloudKit ranges on 443 for `stapler` [M2] |
| **Secrets** | The same API key as iOS, plus the Developer ID Application cert in the keychain (or `.p12` + password secrets) and the Developer ID profile (a file or base64 secret) |
| **Hosting** | Wherever we like (GitHub Releases, Netlify, a bucket). Updates are manual unless an updater is added later (out of scope) |
| **Users see** | On first launch, a Gatekeeper dialog saying Apple checked the app for malware [M1]. No "unidentified developer" block |

### 1.4 macOS and runners

- **Self-hosted Mac (the current setup):** it already holds an Apple Distribution identity and an unlocked login keychain for iOS. Adding a Mac Installer Distribution certificate or a Developer ID Application certificate to that keychain is a one-time manual step. Then `build_macos`/`deploy_macos` jobs can mirror `build_ios`/`deploy_ios`.
- **GitHub-hosted:** `macos-latest`/`macos-15`/`macos-26` (M1, 3 vCPU / 7 GB) are available, and an `xcode-27` image is listed [G1]. Signing there needs the documented ephemeral-keychain pattern: base64 `.p12` + `P12_PASSWORD` + base64 profile + `KEYCHAIN_PASSWORD`, then `security import` [G2]. The current workflow deliberately keeps signing material on the self-hosted Mac, so staying self-hosted fits better *(inference)*.

## 2. Windows

### 2.1 Building

- `flutter build windows --release` produces `build/windows/x64/runner/Release/` (an exe plus DLLs and data). `--build-name`/`--build-number` from the existing `validate` outputs map to the exe's file and product version [W4].
- Store versions must have a **revision of 0** (the 4th number). Flutter's default exe version is `1.0.0.1`, so the MSIX version has to be set separately during packaging (`msix_version: x.y.z.0`) [W4][W3].
- Building needs a Windows host *(inference: Flutter documents Windows builds with Visual Studio; the existing runner is macOS)*. So this means `windows-latest` (Windows Server 2025, with VS images listed) or a new self-hosted Windows box [G1].

### 2.2 Route A: Microsoft Store (MSIX)

| | |
|---|---|
| **Account** | Free Individual or Company account via storedeveloper.microsoft.com. You can't convert Individual to Company later [W1] |
| **Signing** | None by us. The Store re-signs the MSIX after certification [W2][W3]. Build with `store: true`. `publisher_display_name`, `identity_name`, `publisher` and `msix_version` must match Partner Center [W3] |
| **Package** | `msix` 3.18.0 (pub.dev, published 2026-06-27, SDK `>=2.19.0 <4.0.0`) as a dev dependency with an `msix_config:` block in `pubspec.yaml` → `dart run msix:create --store` [W3] |
| **Manual steps** | Create the account → reserve the app name → copy the identity values into `msix_config` → make the **first submission by hand** (Flutter: "the application must already be present … with at least one complete submission") → run `msstore init` once in the repo [W4] |
| **CI** | `microsoft/setup-msstore-cli@v1` → `msstore reconfigure --tenantId --clientId --clientSecret --sellerId` → `msstore package .` → `msstore publish -v` [W4]. Needs an Entra ID (Azure AD) app linked to Partner Center |
| **Secrets** | `AZURE_AD_TENANT_ID`, `AZURE_AD_CLIENT_ID`, `AZURE_AD_CLIENT_SECRET`, `SELLER_ID` (Partner Center › Account settings › Legal info) [W4] |
| **Runners** | GitHub-hosted `windows-latest` works. There is no secret material beyond the API credentials |
| **Users see** | A Store install, with no SmartScreen prompt (UAC may appear) [W2] |

A Win32 `.exe`/`.msi` can also be listed in the Store, but then **we** must sign it with a CA-chained certificate (self-signed is rejected). It also needs a versioned HTTPS URL that never changes, a silent install and a standalone installer [W10]. That costs more than MSIX for no gain here.

### 2.3 Route B: direct download

Options, cheapest first:

| Format | Signing | SmartScreen / UX | Notes |
|---|---|---|---|
| Unsigned zip / exe | none | "Strong SmartScreen block; enterprises may block entirely" [W2] | Fine for internal testers only |
| MSIX sideload (`msix` without `--store`) | Must be signed by a trusted certificate. The `msix` default is a **self-signed test certificate**, which it installs on the *build* machine only [W3] | The web one-click `ms-appinstaller:` has been disabled since Dec 2023 [W8], and `msix:publish` web install is disabled [W3] | A poor fit for public downloads |
| Inno Setup `.exe` installer | Supports signed installs and uninstalls [W9]. Sign with SignTool | SmartScreen reputation builds per file/certificate over time [W2][W6] | The conventional choice for a downloadable installer |

**Certificate options** (Microsoft's comparison [W2]):

| Option | Cost | Who can get it | SmartScreen |
|---|---|---|---|
| **Azure Artifact Signing** (formerly Trusted Signing) | **$9.99/mo Basic** (5,000 signatures/mo, 1 profile of each type) or **$99.99/mo Premium** (100,000 signatures/mo); $0.005 per signature over quota. Billing starts when the account is created [W5][W6] | Organizations: US, Canada, EU, UK, Australia, NZ, Japan, South Korea, Singapore, Switzerland, Norway, Israel. **Individuals: US and Canada only** [W7]. Identity validation uses a government ID and Microsoft Authenticator (Verified ID) [W7] | Reputation builds automatically. Submit to Microsoft Security Intelligence if prompts persist [W6] |
| OV certificate (DigiCert, Sectigo…) | ~$150–300/yr | Worldwide | The same as Artifact Signing: reputation builds over time [W2] |
| EV certificate | $400+/yr | Worldwide | "No longer recommended specifically for SmartScreen bypass" [W2]. Artifact Signing doesn't issue EV and won't [W6] |
| Self-signed | free | — | Dev/test only [W2] |

- **Artifact Signing in CI:** use `azure/login@v3` (OIDC: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`), then `azure/artifact-signing-action@v2` with `endpoint`, `signing-account-name`, `certificate-profile-name` and `files-folder` [W11]. Locally it uses SignTool ≥ 10.0.2261.755 + .NET 8 + the Artifact Signing dlib [W12]. It runs on GitHub-hosted Windows runners, and there's no private key to store as a secret.
- **OV/EV in CI:** since 2023 these keys normally come on hardware tokens or a CA's cloud HSM, which complicates hosted runners *(inference; not checked against a CA's docs in this pass)*.
- **Manual steps (Artifact Signing):** an Azure subscription and Entra tenant → register the resource provider → create the account → identity validation (days, not minutes) → create a Public Trust certificate profile → assign the "Artifact Signing Certificate Profile Signer" role to the CI identity [W7].

### 2.4 Firebase caveat for Windows

Our earlier research found that Firebase on Windows is "not intended for production", that auth and Firestore are beta there, and that there's no social sign-in ([05-firebase-platform-support.md](05-firebase-platform-support.md)). A *production* Store listing for Windows would therefore ship an app whose real backend is officially dev-only, or one that runs on the in-memory fakes. That is a product decision for ticket 18, not a build problem.

## 3. Fit with `.refs/.github/workflows/main.yml`

| Job (proposed) | Runner | Mirrors | New secrets |
|---|---|---|---|
| `build_macos` + `deploy_macos` (App Store) | `[self-hosted, macOS]` | `build_ios`/`deploy_ios` (keychain unlock, then upload with the API key) | none if the certificates live in the runner keychain. The profile is handled by Xcode automatic signing, as for iOS |
| `build_macos_direct` (Developer ID) | `[self-hosted, macOS]` | `build_ios`, plus `notarytool submit --wait` and `stapler` | none beyond the existing API key, if the certificate and profile sit on the runner |
| `build_windows` (+ Store publish) | `windows-latest` | `build_web` (hosted, no signing material) | `AZURE_AD_TENANT_ID`, `AZURE_AD_CLIENT_ID`, `AZURE_AD_CLIENT_SECRET`, `SELLER_ID` |
| `build_windows_direct` (Artifact Signing) | `windows-latest` | — | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (+ account and profile names as vars) |
| v1 "unsigned artifacts only" | macOS: self-hosted. Windows: `windows-latest` | `build_web` → `upload-artifact` | none |

The version flows through as today: `--build-name`/`--build-number` from `validate`. Windows Store packaging also needs `msix_version: <name>.0`.

## 4. Open questions (for ticket 18)

1. Is the Apple **Account Holder** available to create Developer ID certificates and profiles? Nobody else can [M4].
2. Who would hold the Azure Artifact Signing identity? An individual (US/Canada only) or an organization [W7]? Where is the publisher located?
3. Should Windows ship publicly at all, given that Firebase on Windows is dev-only (§2.4)?
4. Should the bundle ID move from `com.example.stencil` to a real reverse-DNS ID before any profile or Store identity is created? Profiles and Store identities are hard to rename later *(inference)*.

## Sources

**Apple**
- [M1] Notarizing macOS software before distribution: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
- [M2] Customizing the notarization workflow (`notarytool submit/store-credentials`, `stapler`, network): https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- [M3] Flutter, Build and release a macOS app (certificates, `productbuild`/`productsign`, upload): https://docs.flutter.dev/deployment/macos
- [M4] Apple Developer Help, Developer ID certificates (up to 5, Account Holder, profile validity): https://developer.apple.com/help/account/certificates/create-developer-id-certificates/ and https://developer.apple.com/developer-id/
- [M5] Flutter, Building macOS apps (entitlements, sandbox, `network.client`, Hardened Runtime): https://docs.flutter.dev/platform-integration/macos/building
- [M6] Creating distribution-signed code for macOS (restricted entitlements need a profile; `keychain-access-groups`): https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac
- [M7] Packaging Mac software for distribution (`ditto`, `productbuild`, dmg): https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- [M8] Apple Developer Program enrollment (99 USD per membership year): https://developer.apple.com/programs/enroll/
- [M9] `xcodebuild -help` on Xcode 27.1, export `method` values (`app-store-connect`, `developer-id`, …)
- [M10] Certificates overview: https://developer.apple.com/help/account/certificates/certificates-overview/
- [M11] `xcrun notarytool submit --help` on Xcode 27.1 (`--key`, `--key-id`, `--issuer`, `--keychain-profile`)

**Firebase**
- [F1] Get started with Firebase in your Flutter project (macOS 11 minimum; Keychain Sharing for macOS): https://firebase.google.com/docs/flutter/setup
- [F2] Firebase Apple troubleshooting FAQ, "Why does Firebase require the Keychain Sharing capability on macOS?": https://firebase.google.com/docs/ios/troubleshooting-faq

**Microsoft / Windows**
- [W1] Open a Microsoft Store developer account (no registration fee, Individual vs Company): https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/open-a-developer-account
- [W2] Code signing options for Windows apps (comparison table, Store re-signing, SmartScreen, EV note): https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/code-signing-options
- [W3] pub.dev `msix` 3.18.0 (config fields, `store: true`, test certificate, App Installer limits): https://pub.dev/packages/msix
- [W4] Flutter, Build and release a Windows desktop app (MSIX, msstore CLI GitHub Action, versioning): https://docs.flutter.dev/deployment/windows
- [W5] Azure Retail Prices API, `serviceName 'Trusted Signing'` (Basic $9.99/mo, Premium $99.99/mo, overage $0.005): https://prices.azure.com/api/retail/prices?$filter=contains(productName,'Signing'). Quotas from https://azure.microsoft.com/en-us/pricing/details/artifact-signing/
- [W6] Artifact Signing FAQ (SmartScreen reputation, no EV, SignTool file types): https://learn.microsoft.com/en-us/azure/artifact-signing/faq
- [W7] Artifact Signing quickstart (eligible regions, individual validation, setup steps): https://learn.microsoft.com/en-us/azure/artifact-signing/quickstart
- [W8] Installing Windows apps from a web page (`ms-appinstaller` disabled by default since Dec 2023): https://learn.microsoft.com/en-us/windows/msix/app-installer/installing-windows10-apps-web
- [W9] Inno Setup features (signed installs/uninstalls, silent install): https://jrsoftware.org/isinfo.php
- [W10] App package requirements for MSI/EXE apps: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msi/app-package-requirements
- [W11] `azure/artifact-signing-action` README: https://github.com/azure/artifact-signing-action
- [W12] Artifact Signing integrations (SignTool, dlib, GitHub Actions): https://learn.microsoft.com/en-us/azure/artifact-signing/how-to-signing-integrations
- Microsoft Defender SmartScreen overview (reputation for files, apps and certificates): https://learn.microsoft.com/en-us/windows/security/operating-system-security/virus-and-threat-protection/microsoft-defender-smartscreen/

**GitHub**
- [G1] GitHub-hosted runners reference (`windows-latest`/`windows-2025`, `macos-latest`/`macos-26`, `xcode-27`): https://docs.github.com/en/actions/reference/runners/github-hosted-runners
- [G2] Signing Xcode applications on GitHub Actions (base64 `.p12`, profile, ephemeral keychain): https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications
