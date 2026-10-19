# Desktop build and signing options (macOS, Windows)

Type: research
Status: resolved
Blocked by:

## Question

Find out, from primary sources, how a Flutter app is built, signed and distributed on **macOS** and **Windows** today, and how each fits the self-hosted GitHub Actions setup in `.refs/.github/workflows/main.yml`:
- **macOS:** Mac App Store vs direct download (a Developer ID-signed and notarised `.dmg`/`.zip`), `notarytool`, which certificates are needed, and the entitlements Firebase and the network need (sandbox, keychain sharing for `firebase_auth`).
- **Windows:** Microsoft Store (MSIX via the `msix` package) vs a direct installer (MSIX sideload, Inno Setup, a signed `.exe`), code-signing certificate options and costs (including Azure Trusted Signing), and SmartScreen behaviour.
- For each route: the manual steps, the secrets, and whether it can run on GitHub-hosted runners.

Save the findings in `.scratch/stencil-v1/research/desktop-build-and-signing.md`.

## Answer

- **macOS:** both routes need the $99/yr Apple Developer Program. The Mac App Store route needs Mac App Distribution and Mac Installer Distribution certificates and uploads a signed `.pkg`. Direct download needs a Developer ID Application certificate (only the Account Holder can create one), the Hardened Runtime, `notarytool submit --wait` (the same App Store Connect API key as iOS works) and `stapler`, shipped as a `.dmg` or a re-zipped `.app`. Firebase needs `com.apple.security.network.client` and Keychain Sharing. `keychain-access-groups` is a restricted entitlement, so either route also needs an embedded distribution provisioning profile (App Store or Developer ID). Both routes fit the existing `[self-hosted, macOS]` runner, mirroring `build_ios`/`deploy_ios`.
- **Windows:** the Microsoft Store is the cheapest signed route. The account is free, and the Store re-signs the MSIX, so we need no certificate and users get no SmartScreen prompt. Build it with `msix` 3.18.0 (`store: true`) and publish from GitHub-hosted `windows-latest` with `setup-msstore-cli` (secrets: Entra tenant/client/secret plus seller ID; the first submission is manual). Direct download needs signing: Azure Artifact Signing costs $9.99/mo (individuals must be in the US or Canada), OV about $150–300/yr, EV $400+/yr. EV no longer skips SmartScreen; with any certificate, reputation builds over time. Web-installed sideloaded MSIX is effectively dead (`ms-appinstaller` has been off since Dec 2023), so a signed Inno Setup `.exe` or a zip is the direct format.
- **Watch out for:** Firebase on Windows is dev-only, which affects whether Windows ships publicly. The bundle ID is still `com.example.stencil`. Release entitlements don't have `network.client` yet.

Full findings: [desktop-build-and-signing.md](../research/desktop-build-and-signing.md)
