# macOS and Windows distribution

Type: grilling
Status: resolved
Blocked by: 17

## Question

Using [Desktop build and signing options](17-desktop-build-and-signing-research.md), decide for macOS and for Windows:
- the distribution route (store, direct download, or both);
- whether CI builds, signs and publishes them, and on which runners, or whether v1 only builds unsigned artifacts;
- where the marketing Downloads links (in the downloads and social config file) point on each platform before and after the stores are set up.

> Open points from the research:
> - Is the Apple Account Holder available to create a Developer ID certificate?
> - Who would hold an Azure signing identity, and where are they based?
> - Should Windows ship publicly, given that Firebase on Windows is dev-only?
> - Should the bundle ID (`com.example.stencil`) be renamed before any store identities are created?
> - The macOS project targets 12.0, but `AGENTS.md` says the minimum is 11. Which is right?

## Answer

Resolved by grilling on 2026-10-19. The facts come from [Desktop build and signing options](17-desktop-build-and-signing-research.md).

### Routes

| | macOS | Windows |
|---|---|---|
| **Route** | **Mac App Store only** | **Microsoft Store only** |
| **Why** | Reuses the App Store Connect API key and the iOS self-hosted pipeline. An Admin can create the certificates; a Developer ID certificate needs the Account Holder. | The account is free, the Store signs the package, there are no SmartScreen warnings, and it builds on GitHub-hosted runners. |
| **App needs** | the sandbox, plus `com.apple.security.network.client` and Keychain Sharing (for Firebase), with an embedded App Store provisioning profile | MSIX built with `msix` (`store: true`) |
| **Out of scope** | Developer ID direct download (notarised `.dmg`) | a signed direct installer (Inno Setup `.exe`, Azure Artifact Signing, OV/EV certificates) |

Windows ships publicly. Its Firestore "dev-only" label was already accepted in [Sign-in and data on Windows](12-windows-sign-in-and-data.md).

### CI

- **`build_macos`** and **`deploy_macos`** run on the self-hosted macOS runner, mirroring `build_ios`/`deploy_ios`. The deploy job uploads to App Store Connect.
- **`build_windows`** (MSIX, `store: true`) and **`deploy_windows`** (`msstore` CLI via `setup-msstore-cli`) run on GitHub-hosted `windows-latest`.
- **Build jobs always run.** A deploy job runs only when its secrets are set, so empty secrets skip deploys rather than failing them. The same applies to every platform.
- **The first Store submission** on each platform is done by hand and goes in [Manual-tasks document](19-manual-tasks-document.md).

### Downloads links

- The downloads and social config file holds one store URL per platform (iOS, Android, macOS, Windows).
- **An empty URL hides that platform's download button** on the marketing pages. There's no "Coming soon" button.

### App identity

- Store identities can't be renamed, so the manual-tasks document says to **pick the real app ID first, then create the store records**.
- Foundation replaces `com.example.stencil` with the value from the single app-identity place that [Manual-tasks document](19-manual-tasks-document.md) defines.

### macOS minimum version

The deployment target stays at **12.0**, the project's value and above Firebase's macOS 11 minimum. `AGENTS.md` has been corrected to match.
