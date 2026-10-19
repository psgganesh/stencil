# Fonts for ten languages

Type: research
Status: resolved
Blocked by:

## Question

The app needs Roboto plus Noto Sans for Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam and Gurmukhi (`DESIGN.md` → Typography), on web, iOS, Android, macOS and Windows. Compare the two options:
1. **Bundling the font files as assets.** What would it add to the size, especially for the web build? Can subsets or variable fonts reduce that?
2. **The `google_fonts` package.** How does it fetch at runtime, can it run offline with fonts bundled as a fallback, and what are the privacy and GDPR implications of web requests to Google?

Also find out how Flutter falls back to another font for a script the main font doesn't cover (`fontFamilyFallback`), and which platforms already ship a usable system font for each of these scripts. Recommend one option.

## Answer

Bundle the fonts in pubspec `fonts:` and skip `google_fonts`. Ship static TTFs for Roboto and the 8 Noto Sans Indic families at weights 400 and 500 only: 18 files, about 2.4 MB raw or about 1.1 MB gzipped. Variable fonts are twice the size for two weights, and WOFF2 isn't supported on desktop.
Set `fontFamilyFallback` to the Noto families once on the `TextTheme`. `google_fonts` overwrites that list and registers a separate family name for each weight.
Native platforms have system Indic fonts, but each looks different (Noto, Kohinoor/Sangam, Nirmala UI). Flutter web fetches Roboto and Noto from fonts.gstatic.com by default, which is the GDPR risk (LG München 3 O 17493/20). Bundling fixes that, together with a self-hosted `fontFallbackBaseUrl`.
Known cost: on web, all bundled fonts load before the first frame. If that turns out too slow, move the Noto families to `assets:` and load them with `FontLoader`.
[findings](../research/04-fonts-for-ten-languages.md)
