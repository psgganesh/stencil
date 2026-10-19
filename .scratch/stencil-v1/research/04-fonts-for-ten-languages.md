# Fonts for ten languages — research findings

Ticket: [04-fonts-for-ten-languages](../issues/04-fonts-for-ten-languages.md). Researched 2026-10-19 against Flutter 3.47 docs, `google_fonts` 9.0.0 and the Flutter engine `main` branch.

**Scope.** We need Roboto plus Noto Sans Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam and Gurmukhi (`DESIGN.md` → Typography). The type scale only uses weights **400 and 500**. The language grid shows every native-script name at 20 / 500 on one screen (`DESIGN.md` → Selectable tile, Languages), so the language step needs all eight Indic families at the same time.

---

## 1. How Flutter falls back across fonts

- `TextStyle.fontFamilyFallback` is an ordered list. Flutter looks for each glyph in `fontFamily` first, then in each fallback family in order, and then in the platform's default font. If nothing matches, it draws a box. Families from a package are prefixed `packages/<name>/`. ([api: fontFamilyFallback](https://api.flutter.dev/flutter/painting/TextStyle/fontFamilyFallback.html))
- The `TextStyle` class docs give the full order as `fontFamily`, then `fontFamilyFallback` first to last, then "System fallback fonts which will vary depending on platform". They also say this list is the usual way to style multilingual text. ([api: TextStyle → Custom Font Fallback](https://api.flutter.dev/flutter/painting/TextStyle-class.html))
- The default font differs by platform: **Roboto** on Android, Fuchsia and Linux, **SF Pro** on iOS, **.AppleSystemUIFont** on macOS and **Segoe UI** on Windows. The docs say to specify a custom font "if absolute font consistency is required". ([api: TextStyle → Inconsistent platform fonts](https://api.flutter.dev/flutter/painting/TextStyle-class.html)) → **Roboto has to be bundled to look the same on iOS, macOS, Windows and web.** Only Android has it by default.
- A family declared in `pubspec.yaml` takes a `weight` (100–900) for each file. Flutter picks the file by `TextStyle.fontWeight`. If a weight is missing, Flutter synthesizes a fake bold. ([docs: Use a custom font](https://docs.flutter.dev/cookbook/design/fonts))
- Supported formats are `.ttf`, `.otf` and `.ttc`. **`.woff` and `.woff2` are not supported on desktop**, so they can't be the single shared format. ([docs: Use a custom font → supported format](https://docs.flutter.dev/cookbook/design/fonts))

### Web is different: the engine fetches fonts from Google by default

- Flutter web (CanvasKit and skwasm) draws text with its own font collection, not the browser's. At startup, `_downloadAssetFonts()` downloads **every font listed in `FontManifest.json` (the pubspec `fonts:` section) before the engine finishes initializing**. ([engine `initialization.dart`](https://github.com/flutter/flutter/blob/main/engine/src/flutter/lib/web_ui/lib/src/engine/initialization.dart), [`canvaskit/fonts.dart` `loadAssetFonts`](https://github.com/flutter/flutter/blob/main/engine/src/flutter/lib/web_ui/lib/src/engine/canvaskit/fonts.dart))
- If no bundled family is named `Roboto`, CanvasKit **downloads Roboto from `fontFallbackBaseUrl`** (`…roboto/v32/….woff2`) to use as its default font. ([`canvaskit/fonts.dart`](https://github.com/flutter/flutter/blob/main/engine/src/flutter/lib/web_ui/lib/src/engine/canvaskit/fonts.dart))
- When a glyph is missing from every loaded font, the engine downloads a matching Noto font. Its generated list includes Noto Sans Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam and Gurmukhi as `.woff2` files. ([`font_fallback_data.dart`](https://github.com/flutter/flutter/blob/main/engine/src/flutter/lib/web_ui/lib/src/engine/font_fallback_data.dart))
- `fontFallbackBaseUrl` **defaults to `https://fonts.gstatic.com/s/`** and can be changed in the web loader config. ([docs: Web app initialization](https://docs.flutter.dev/platform-integration/web/initialization), [engine `configuration.dart`](https://github.com/flutter/flutter/blob/main/engine/src/flutter/lib/web_ui/lib/src/engine/configuration.dart))

So an unconfigured Flutter web app **already makes requests to Google** for Roboto and for any Indic glyphs, whichever font option we pick. These requests stop only when the fonts are bundled, or when `fontFallbackBaseUrl` points at our own host.

## 2. System fonts already on each platform

| Script | Android | iOS (system, not downloadable) | macOS | Windows | Web |
|---|---|---|---|---|---|
| Devanagari | Noto Sans Devanagari | Kohinoor Devanagari, Devanagari Sangam MN | Kohinoor Devanagari, ITF Devanagari, … | Nirmala UI | none (see §1) |
| Bengali | Noto Sans Bengali | Kohinoor Bangla | Kohinoor Bangla, Bangla Sangam MN | Nirmala UI | none |
| Tamil | Noto Sans Tamil | Tamil Sangam MN | Tamil Sangam MN, Tamil MN | Nirmala UI | none |
| Telugu | Noto Sans Telugu | Kohinoor Telugu | Kohinoor Telugu, Telugu Sangam MN | Nirmala UI | none |
| Gujarati | Noto Sans Gujarati | Kohinoor Gujarati | Gujarati Sangam MN, Gujarati MT | Nirmala UI | none |
| Kannada | Noto Sans Kannada | Noto Sans Kannada | Noto Sans Kannada, Kannada Sangam MN | Nirmala UI | none |
| Malayalam | Noto Sans Malayalam | Malayalam Sangam MN | Malayalam Sangam MN, Malayalam MN | Nirmala UI | none |
| Gurmukhi | Noto Sans Gurmukhi | Mukta Mahee | Gurmukhi Sangam MN, Gurmukhi MN | Nirmala UI | none |

Sources: Android [`fonts.xml`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/data/fonts/fonts.xml) (lists `NotoSans<Script>-VF.ttf` and `…UI-VF.ttf` for every script; Gujarati uses static Regular/Bold). Apple [system fonts list](https://developer.apple.com/fonts/system-fonts/) ("system font iOS" vs "downloadable iOS" status for each face). Microsoft [Nirmala UI](https://learn.microsoft.com/en-us/typography/font-list/nirmala-ui) (script tags Beng, Deva, Gujr, Guru, Knda, Mlym, Taml, Telu; ships with Windows 7 to 11).

**Takeaway.** Every native platform could display all eight scripts with no bundled font, through Flutter's system fallback. The designs would differ by platform, though: Noto on Android, Kohinoor, Sangam and Mukta on Apple, Nirmala UI on Windows. Weight 500 isn't guaranteed either. Some Apple faces only ship Regular and Bold as system fonts, and Nirmala UI has only Semilight, Regular and Bold. DESIGN.md calls for Noto Sans, so we have to bundle. Web has no system fallback in Flutter, so it either bundles or fetches from Google.

## 3. Option 1 — bundle the font files as assets

**Sizes.** These are the static TTFs that Google Fonts serves. The sizes come from the expected-length values in `google_fonts` 9.0.0's generated tables ([`part_n.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/google_fonts_parts/part_n.dart), [`part_r.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/google_fonts_parts/part_r.dart)), and I downloaded the files to confirm them.

| Family | w400 | w500 | 400+500 | Variable font `[wdth,wght]` |
|---|---|---|---|---|
| Roboto | 100.8 KB | 101.0 KB | 201.7 KB | 488.6 KB |
| Noto Sans Devanagari | 219.4 KB | 220.0 KB | 439.5 KB | 641.9 KB |
| Noto Sans Bengali | 138.8 KB | 139.2 KB | 277.9 KB | 463.7 KB |
| Noto Sans Tamil | 77.7 KB | 77.8 KB | 155.5 KB | 340.7 KB |
| Noto Sans Telugu | 178.5 KB | 179.1 KB | 357.6 KB | 888.8 KB |
| Noto Sans Gujarati | 173.5 KB | 173.8 KB | 347.3 KB | 672.9 KB |
| Noto Sans Kannada | 143.6 KB | 143.7 KB | 287.2 KB | 641.4 KB |
| Noto Sans Malayalam | 105.6 KB | 105.6 KB | 211.2 KB | 504.2 KB |
| Noto Sans Gurmukhi | 57.5 KB | 57.6 KB | 115.1 KB | 268.6 KB |
| **Total** | | | **≈ 2.39 MB** | **≈ 4.91 MB** |

The variable-font sizes come from the [google/fonts repo](https://github.com/google/fonts/tree/main/ofl) (`ofl/roboto`, `ofl/notosans<script>`).

- **Variable fonts don't help.** With only two weights, two static files per family (2.39 MB) are about half the size of one variable file (4.91 MB). Variable fonts only pay off with three or more weights.
- **Web transfer size.** I gzip-compressed the 18 TTFs at level 9 and got **≈ 1.09 MB** (measured). A web host that gzips or brotli-compresses `.ttf` gets roughly that. WOFF2 would be smaller, but it isn't supported on desktop (§1), so it would mean keeping a second, web-only set of files. Not worth it for v1.
- **Web startup cost.** Fonts in pubspec `fonts:` are all downloaded before the engine finishes initializing (§1). That puts about 1.1 MB (compressed) on the first load of every web page, including the marketing Home at `/`. Native apps pay it once, in install size (≈ 2.4 MB uncompressed; the stores compress further).
- **Subsetting.** Google Fonts' per-script Noto files are already split by script, so there's little left to cut. The only obvious cut is the Latin glyphs inside each Indic file, which Roboto covers anyway. Subsetting Indic fonts needs the GSUB/GPOS shaping tables kept intact, and it adds a build step to maintain. Not recommended for v1, and I didn't measure it.
- **Lazy-loading alternative.** You can list the files under plain `assets:` instead of `fonts:` and load a family on demand with [`FontLoader`](https://api.flutter.dev/flutter/services/FontLoader-class.html) ("enables the dynamic loading of fonts at runtime"). That keeps them off web startup. But the language step needs all eight families at once anyway, so the saving only matters for pages that come before it (web marketing Home).
- **Licence.** The Noto and Roboto files on Google Fonts are OFL. Include `OFL.txt` and register it with `LicenseRegistry` (the same advice as the `google_fonts` README, below).

## 4. Option 2 — the `google_fonts` package

Package: [`google_fonts` 9.0.0](https://pub.dev/packages/google_fonts), verified publisher flutter.dev, BSD-3. It requires `sdk ^3.13.0` and Flutter ≥ 3.47.0 ([pubspec](https://github.com/flutter/packages/blob/main/packages/google_fonts/pubspec.yaml)). All nine families are in its generated API (`GoogleFonts.roboto`, `GoogleFonts.notoSansDevanagari`, …).

**How it fetches** ([`google_fonts_base.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/google_fonts_base.dart), [`google_fonts_descriptor.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/google_fonts_descriptor.dart)):
1. Calling a font method (for example `GoogleFonts.notoSansDevanagari(fontWeight: …)`) starts `loadFontIfNecessary` for the **closest matching weight/style variant**, as a side effect.
2. It first looks in the `AssetManifest` for an asset whose filename matches `<Family>-<Weight>.ttf`, for example `NotoSansDevanagari-Medium.ttf`.
3. Next it checks the on-device cache, which is `getApplicationSupportDirectory()` via `path_provider` ([`file_io_desktop_and_mobile.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/file_io_desktop_and_mobile.dart)). **On web this cache is a no-op** ([`file_io.dart`](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/file_io.dart)), so web relies on the browser's HTTP cache.
4. Last, if `GoogleFonts.config.allowRuntimeFetching` is true (the default), it fetches `https://fonts.gstatic.com/s/a/<sha256>.ttf` and checks the file's length and SHA-256 before using it. If the setting is false and no asset exists, it throws.
5. The package downloads TTF on every platform, including web.

**Offline with bundled fallback.** Yes. The README says "matching font files found in assets are prioritized over HTTP fetching", and you set `GoogleFonts.config.allowRuntimeFetching = false` to make the bundle the only source ([README → Bundling fonts when releasing](https://pub.dev/packages/google_fonts)). The files go under `assets:` (not `fonts:`) and must keep the Google Fonts filenames. Bundled this way, the fonts are lazy-loaded per variant rather than at web startup.

**Problems for this project:**
- **It replaces your fallback list.** `googleFontsTextStyle` returns `textStyle.copyWith(fontFamily: 'Roboto_regular', fontFamilyFallback: ['Roboto'])` ([source](https://github.com/flutter/packages/blob/main/packages/google_fonts/lib/src/google_fonts_base.dart)). Any `fontFamilyFallback` we set is overwritten, so the Noto chain has to be added again afterwards.
- **One family name per variant.** Fonts are registered under names such as `NotoSansDevanagari_regular` and `NotoSansDevanagari_500`. A 500-weight style needs `…_500` names in its fallback list, and a 400 style needs `…_regular`. Every Noto variant also has to be loaded on purpose (by calling its method), because nothing references the fallback families directly. That's clumsier than one pubspec family with two weights.
- **More dependencies.** It pulls in `http`, `path_provider` and `crypto`. On macOS, runtime fetching also needs the `com.apple.security.network.client` entitlement (README → HTTP fetching).
- If runtime fetching is left on, there can be a visible font swap while loading. The README suggests `FutureBuilder` with `GoogleFonts.pendingFonts()` to avoid it.

## 5. Privacy and GDPR of requests to Google

- **Case law.** In *LG München I, judgment of 20 Jan 2022, 3 O 17493/20*, the court held that passing a visitor's dynamic IP address to Google through dynamically embedded Google Fonts, without consent, violated their right to informational self-determination. It found no legitimate interest, because Google Fonts "can also be used without a connection to a Google server" (self-hosting). The site operator was ordered to stop and to pay **€100** damages under Art. 82 GDPR. ([full text, gesetze-bayern.de](https://www.gesetze-bayern.de/Content/Document/Y-300-Z-BECKRS-B-2022-N-612))
- That reasoning covers any runtime fetch from `fonts.gstatic.com`: `google_fonts` with runtime fetching, **and Flutter web's own default Roboto and Noto fallback downloads** (§1). Bundling removes the reason for those requests. Pointing `fontFallbackBaseUrl` at our own origin covers glyphs outside our fonts (for example emoji).
- Google's own Fonts privacy FAQ (`developers.google.com/fonts/faq/privacy`, now redirected to [fonts.google.com/faq](https://fonts.google.com/faq#privacy)) is a client-rendered page that I couldn't fetch as text. I didn't verify what it says about logging, so it isn't relied on here.
- Related but out of scope: Flutter web also downloads `canvaskit.wasm` from `canvasKitBaseUrl` ([docs: Web app initialization](https://docs.flutter.dev/platform-integration/web/initialization)). Check its default host and self-host it when the web privacy story is settled. I didn't verify the default host.

## 6. Comparison

| | Bundle via pubspec `fonts:` | `google_fonts`, runtime fetch | `google_fonts` + bundled assets, fetch off |
|---|---|---|---|
| Offline / first run | ✅ | ❌ needs network the first time (and every time on web) | ✅ |
| Requests to Google | none (if `fontFallbackBaseUrl` is self-hosted) | yes, on every platform | none |
| Native app size | +≈2.4 MB | ~0 | +≈2.4 MB |
| Web first load | +≈1.1 MB gzip, before the first frame | lazy, per variant | lazy, per variant |
| `fontFamilyFallback` | works as documented, weight-aware | overwritten; per-variant names | overwritten; per-variant names |
| Dependencies | none | `google_fonts`, `http`, `path_provider`, `crypto` | same |
| Consistent look across platforms | ✅ | ✅ (once loaded) | ✅ |

## Recommendation

**Bundle the fonts as assets in pubspec `fonts:`. Don't use `google_fonts`.**

- Ship static TTFs from Google Fonts at **weights 400 and 500 only**: Roboto plus Noto Sans Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam and Gurmukhi. That's 18 files, ≈ 2.39 MB raw and ≈ 1.09 MB gzip. Don't use variable fonts (2× larger for two weights), WOFF2 (not supported on desktop) or subsetting (a risky build step for little gain).
- Declare one pubspec family per typeface with `weight: 400` and `weight: 500`. Set `fontFamily: 'Roboto'` and `fontFamilyFallback: ['Noto Sans Devanagari', 'Noto Sans Bengali', …]` once on the app `TextTheme`, so every style inherits it. The order doesn't matter much because the scripts don't overlap.
- On web, set `fontFallbackBaseUrl` to our own origin in `flutter_bootstrap.js` so that no font request goes to `fonts.gstatic.com`. Bundling Roboto already stops the engine's default Roboto download.
- Register the OFL licence texts with `LicenseRegistry`.
- Known cost: about 1.1 MB of fonts on web first load, before the first frame, including the marketing Home. If web performance measurements later show this is too slow, move the eight Noto families from `fonts:` to `assets:` and load them with `FontLoader` before the language step. That's a local change and needs no new package.
