# DESIGN

Design system for the app and marketing (see `GLOSSARY.md`). Generated from `.refs/design/DESIGN.html` ("App name starter kit", UI skeleton v1.0); screen designs live as PNGs under `.refs/design/<device>/<flow>/<light|dark>/`.

Material 3 structure, a blue and orange palette, Roboto type, light and dark themes, and onboarding in ten languages. Use Material components throughout; this file only says how to configure them.

## Principles

- **Every color is a named role, never a raw hex** in screen code. Screens reference roles; the theme maps roles to values.
- **Blue carries actions and structure.** Buttons, links, selection, progress.
- **Orange marks emphasis** and is always a *fill* with dark text on it — never small orange text on a light surface.
- **Status colors always come with a label** (chips say "Active", "Draft", "Error"); color is never the only signal.
- **Selected states never rely on color alone** — add a check icon, filled radio, thicker border, or pill indicator.
- **Touch targets are 44–56 px tall.**

## Color roles

| Role | Light | Dark | Used for | Material 3 `ColorScheme` slot |
|---|---|---|---|---|
| Primary | `#00639B` | `#00639B` | Filled buttons, toggles (on) | `primary` |
| On primary | `#FFFFFF` | `#FFFFFF` | Text/icons on primary | `onPrimary` |
| Selected and link | `#00639B` | `#96CCFF` | Links, text/outlined button labels, focus ring, progress fill, selected borders, radio dot | *custom* (see note) |
| Primary container | `#CDE5FF` | `#004B76` | Tonal buttons, selected tiles/options/chips, featured cards, FAB | `primaryContainer` |
| On primary container | `#001D32` | `#CDE5FF` | Text on primary container | `onPrimaryContainer` |
| On primary container (muted) | `#124A73` | `#B9D9F7` | Secondary text on primary container | *custom* |
| Nav indicator (pill) | `#CDE5FF` | `#004B76` | Active nav-bar / rail / tab pill | `secondaryContainer` |
| On nav indicator | `#001D32` | `#CDE5FF` | Icon/label in the active pill | `onSecondaryContainer` |
| Accent fill | `#F28A1E` | `#F28A1E` | Logo mark, illustration sun, emphasis fills, review stars | *custom* |
| Tertiary container | `#FFDCBE` | `#693C00` | "Highlight" chips, tip cards | `tertiaryContainer` |
| On tertiary container | `#2C1600` | `#FFDCBE` | Text on tertiary container | `onTertiaryContainer` |
| Surface | `#F8F9FF` | `#111418` | Page background | `surface` |
| Surface container | `#ECEEF4` | `#1D2024` | Search field, bottom nav, image placeholders, alternating page bands | `surfaceContainer` |
| On surface | `#191C20` | `#E1E2E8` | Primary text | `onSurface` |
| On surface variant | `#42474E` | `#C2C7CF` | Secondary text, labels, inactive icons | `onSurfaceVariant` |
| Outline | `#72777F` | `#8C9199` | Field and outlined-button borders | `outline` |
| Outline variant | `#C2C7CF` | `#42474E` | Card/tile borders, list dividers | `outlineVariant` |
| Track | `#D9DEE6` | `#33363B` | Progress-bar track, skeleton blocks | *custom* |
| Gain container | `#D8F3DC` | `#0E5128` | "Active"/success chips | *custom* |
| On gain container | `#00210C` | `#B7F1C4` | Text on gain container | *custom* |
| Gain | `#1B6D3A` | `#7DDA9A` | Status dot | *custom* |
| Error | `#BA1A1A` | `#FFB4AB` | Field error border and message | `error` |
| Error container | `#FFDAD6` | `#93000A` | Error chips | `errorContainer` |
| On error container | `#410002` | `#FFDAD6` | Text on error container | `onErrorContainer` |
| Scrim | `rgba(25,28,32,.48)` | `rgba(0,0,0,.6)` | Behind dialogs and sheets | `scrim` (with opacity) |

**Note — primary stays `#00639B` in dark mode.** Filled buttons keep the same blue with white text in both themes. The lighter dark-mode blue (`#96CCFF`) is used only for "Selected and link". This deviates from a generated Material 3 dark scheme, so set the scheme explicitly rather than from a seed color, and carry the *custom* roles in a theme extension.

## Typography

Roboto, with Noto Sans fallbacks for Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam and Gurmukhi (the onboarding languages). Values are size / line height in px, tracking in px, weight. The scale matches the Material 3 default type scale.

| Style | Size / line | Tracking | Weight | Typical use |
|---|---|---|---|---|
| Display large | 57 / 64 | -0.25 | 400 | — |
| Display medium | 45 / 52 | 0 | 400 | Marketing hero headline |
| Display small | 36 / 44 | 0 | 400 | Marketing section headline |
| Headline large | 32 / 40 | 0 | 400 | Page headline |
| Headline medium | 28 / 36 | 0 | 400 | Onboarding screen title |
| Headline small | 24 / 32 | 0 | 400 | — |
| Title large | 22 / 28 | 0 | 400 | App name in logo lockup (weight 500) |
| Title medium | 16 / 24 | 0.15 | 500 | Card titles, option titles |
| Title small | 14 / 20 | 0.1 | 500 | — |
| Label large | 14 / 20 | 0.1 | 500 | Buttons, tabs, language button |
| Label medium | 12 / 16 | 0.5 | 500 | Overlines (uppercase), nav labels, progress label |
| Label small | 11 / 16 | 0.5 | 500 | — |
| Body large | 16 / 24 | 0.5 | 400 | Lead paragraphs, field input text |
| Body medium | 14 / 20 | 0.25 | 400 | Body text, descriptions |
| Body small | 12 / 16 | 0.4 | 400 | Captions, metadata ("[Short description] · [Date]") |

## Components

All sizes in logical px. Radii: **full** = height / 2.

### Buttons
| Variant | Height | Padding | Radius | Colors |
|---|---|---|---|---|
| Filled | 48 | 0 24 | full (24) | Primary / On primary |
| Tonal | 48 | 0 24 | full | Primary container / On primary container |
| Outlined | 48 | 0 24 | full | 1px Outline border, label in Selected-and-link |
| Text | 48 | 0 12 | full | Label in Selected-and-link, no border |
| Small | 40 | 0 16 | full | any variant |
| Large full-width (primary CTA) | 56 | — | full (28) | Filled, 16 px label, full width; trailing arrow icon |
| Disabled | — | — | — | Same variant at 38% opacity |
| Icon button | 48 × 48 | — | full | On surface variant icon |
| Back button | 48 | 0 16 0 8 | full | Leading arrow + label in Selected-and-link |

Button label: Label large (14 / 500 / 0.1), icon gap 8.

### Text fields
- Outlined, **56** tall, radius **12**, 16 px horizontal padding, Body large input text.
- Label sits **above** the field (Label medium style, On surface variant), 6 px gap.
- Default: 1px Outline. Focused: 2px Selected-and-link. Error: 2px Error border plus an error message below ("Enter a valid email.").
- Search field: 48 tall, full radius, Surface container fill, leading search icon, no border.

### Chips and status
- 32 tall, radius **8**, 0 12 padding, 13 px / 500 label, icon gap 8.
- Filter (unselected): 1px Outline border, On surface variant text. Selected: Primary container fill + check icon.
- Status chips (always labelled): Active → Gain container; Draft → Surface container with Outline-variant border; Highlight → Tertiary container; Error → Error container. Optional 8 px Gain status dot.

### Selection controls
- **Toggle:** 52 × 32 track, full radius. Off: Surface container track, 2px Outline border, 16 px Outline thumb. On: Primary track, 24 px white thumb.
- **Segmented control** (e.g. theme Light / Dark / System): 40 tall, radius 20, 1px Outline border and dividers, Label large text.
- **Radio:** 22 px, 2px border (On surface variant; Selected-and-link when on) with 11 px filled dot.
- **Selectable tile** (e.g. language grid): 64 tall, radius **16**, 1px Outline-variant border, native-script name (20 / 500) over English name (Body small). Selected: Primary container fill, 2px Selected-and-link border, trailing check.
- **Selectable option card** (e.g. preferences): radius **20**, 16 18 padding, radio + title (Title medium) + description (Body medium). Selected: same treatment as the tile.
- **Language button:** 44 tall, radius 8, 1px Outline border, globe icon + current language name. Top-right of onboarding screens.

### Progress
- Step progress (onboarding): "Step 2 of 5" label (Label medium) above a **4** px bar, radius 2, Track background, Selected-and-link fill; min width 140.
- Linear progress: 8 px bar, radius 4.

### Cards and lists
- Card: radius **24**, padding 24 (20 for compact cards). Outlined cards use a 1px Outline-variant border on Surface.
- Featured card: Primary container fill. Tip/callout card: Tertiary container fill.
- List rows: 14 px vertical padding, 14 px gap; leading circular avatar (initial on a tinted container), title + Body small metadata, trailing status chip. Rows separated by 1px Outline-variant dividers.

### Navigation
- **Bottom navigation bar** (mobile): 80 tall, Surface container background; items show a 56 × 32 pill indicator (radius 16) around the icon with a Label medium label below. Active: Nav-indicator pill, On surface label.
- **Navigation rail** (tablet/desktop): 80 px wide items, same pill and label treatment.
- **Top tabs / web top-bar links:** 44 tall, radius 22, 0 18 padding; active link gets the Nav-indicator pill.
- **FAB (extended):** 56 tall, radius **16**, 0 20 padding, Primary container fill, icon + label, shadow `0 2 8 rgba(0,0,0,.2)`.

### Brand and imagery
- **Logo mark:** 36 px Accent-fill circle with a 14 px Primary dot centred; "App name" beside it at 22 / 500, 12 px gap.
- **Image placeholder:** Surface container block with a mountain-and-sun illustration (two blues, Accent-fill sun), radius 20–24, with a small "Image placeholder" caption tag in the bottom-left corner.
- **Skeleton loader:** Track-colored blocks, radius 8.

## Languages

Ten onboarding languages, each shown by its native name with the English name beneath:

| Native | English |
|---|---|
| हिन्दी | Hindi |
| English | English |
| বাংলা | Bengali |
| தமிழ் | Tamil |
| తెలుగు | Telugu |
| मराठी | Marathi |
| ગુજરાતી | Gujarati |
| ಕನ್ನಡ | Kannada |
| മലയാളം | Malayalam |
| ਪੰਜਾਬੀ | Punjabi |

## Screen references

| Flow | Devices | Screens |
|---|---|---|
| Onboarding (`onboarding/`) | mobile, tablet, desktop, web | Welcome, Language, SignIn, Profile, Preferences, Permissions, Done |
| app (`app/`) | mobile, tablet, desktop, web | Home, Items, Item detail, Notifications, Settings |
| marketing (`marketing/`) | web | Home, Features, What's new, About Us, Articles, Premium, Reviews, Press, Support & FAQ, Terms & Conditions, Privacy Policy, Changelog, Contact Us |
| States (`states/`) | mobile, tablet, desktop, web | Empty, Error, Loading, Offline |

Every screen exists in `light/` and `dark/`.

## States

A state replaces only a screen's **content area**. The app bar (or the web top bar) and the navigation stay in place, and the screen title stays visible. Empty, Error and Offline share one centred layout:

1. an icon in a large tinted circle (about 128 px);
2. a title;
3. a Body large explanation (On surface variant), centred;
4. buttons: a filled one, plus an outlined one for Empty and Error.

| State | Circle fill / icon | Title | Body | Buttons (filled · outlined) |
|---|---|---|---|---|
| Empty | Primary container / inbox, On primary container | "Nothing here yet" | Explains what the space is for and how to add the first one | "+ Add your first item" · "Learn more" |
| Error | Error container / warning triangle, On error container | "Something went wrong" | "We couldn't load this page. Try again, or contact support if it keeps happening." Then a Body small line: "Error code: [CODE]" | "↻ Try again" · "Contact support" |
| Offline | Surface container / wifi-off, On surface | "You're offline" | "Check your connection and try again. Changes you make will sync when you're back online." | "↻ Try again" only. The design's "View saved items" button is deliberately dropped. |

**Loading** uses no circle. It shows skeleton blocks in the shape of the screen's real content, as described under Skeleton loader above: a title bar, a row of three metric tiles, and an outlined card with six list-row skeletons (circle, two text lines, chip). A 4 px linear progress bar (Selected-and-link fill on Track) runs across the top of the content.
