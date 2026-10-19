# Prototype: device layouts (ASCII)

Throwaway sketch for [Device layouts: mobile, tablet, desktop, web](../issues/03-device-layouts.md). Measured from `.refs/design/{mobile,tablet,desktop,web}/` (PNG frames are @2x: mobile 390, tablet 834, desktop and web 1440 logical px wide). Sizes are logical px and rounded.

## 1. App shell per layout

### Mobile (native < 600, and web at phone width)

```
┌──────────────────────────────┐
│ Title              (🌐) (🔍) │  top bar: page title, icon-only language button, search
│                              │
│  content, single column      │  16 px side padding, full width
│  cards stacked               │
│                     [+ New]  │  extended FAB (tonal), Items only
├──────────────────────────────┤
│  ⌂     ≡     🔔     ⚙        │  bottom navigation bar, 80 tall
│ Home Items Alerts Settings   │
└──────────────────────────────┘
Sub-page (Item detail): top bar = [←] "Details" (🌐)(🔍); bottom bar stays.
```

### Tablet (native 600–1199)

```
┌────┬──────────────────────────────────────┐
│ ●  │ Page title             [🌐 English]  │  header: title + subtitle, language button
│    │ subtitle                             │  (+ search icon: added, see §6)
│ ⌂  │                                      │
│ ≡  │  content, fills width                │  ~24 px padding each side
│ 🔔 │  2-column card grid where shown      │
│ ⚙  │  [+ New item] inline filled button   │
│    │                                      │
│ 👤 │                                      │  avatar at rail bottom → opens Settings
└────┴──────────────────────────────────────┘
rail 80 wide: logo mark (no name) on top, 4 destinations, avatar at bottom
Sub-page: "← Items" back button above the page title.
```

### Desktop (native ≥ 1200)

```
┌────┬──────────────────────────────────────────────────────────┐
│ ●  │ Page title                          (🔍) [🌐 English]    │
│ ⌂  │ subtitle                                                 │
│ ≡  │  content max 1120, centred beside the rail, ≥40 padding  │
│ 🔔 │  2- or 3-column card grid                                │
│ ⚙  │                                         [+ New item]     │
│ 👤 │                                                          │
└────┴──────────────────────────────────────────────────────────┘
same rail as tablet. Header has the search icon (tablet gets it too: decided)
```

### Web (web ≥ 600)

```
┌────────────────────────────────────────────────────────────────────┐
│   ● App name  (Home) Items Alerts Settings     (🔍)[🌐 English](👤) │  top bar, Surface container, ~72 tall
├────────────────────────────────────────────────────────────────────┤
│        ┌────────────── max 1120, centred ──────────────┐          │
│        │ Page title                                     │          │
│        │ subtitle                                       │          │
│        │  same 2-/3-column grid as desktop              │          │
│        └────────────────────────────────────────────────┘          │
└────────────────────────────────────────────────────────────────────┘
top bar contents also sit inside the 1120 column; language + avatar move to the bar
```

## 2. Column structure per screen

| Screen | Mobile | Tablet | Desktop / Web |
|---|---|---|---|
| Home | 1 col: Featured, 3 metrics in a row, Overview, Recent, Tip, Quick actions | Featured (with chart), 3 metrics, [Overview \| Tip + Quick actions], Recent full width | [Featured 2/3 \| Overview 1/3], 3 metrics, [Recent 2/3 \| Tip + Quick actions 1/3] |
| Items | list rows (avatar, title, "desc · date", chip), FAB | table: Name, Status, Updated, › | split: list pane + detail pane (section 3) |
| Item detail | 1 col: header, image, Description, Details, Activity | header, image full width, [Description \| Details], Activity full width | detail pane of the split, tablet arrangement (section 3) |
| Alerts | 1 col feed | 1 col feed, no settings card | [feed 2/3 \| Notification settings card 1/3] |
| Settings | 1 col: Profile, Preferences, Notifications, About, Sign out | 1 col, same order | [Profile + Preferences + Sign out \| Notifications + About] |

Featured card: mobile has no chart; tablet and wider add the chart on the right.

## 3. Panes (decided: split on desktop and web)

The designs show no split; this was decided in the ticket. **Desktop (native ≥ 1200) and web (≥ 600, non-phone) always show Items as list + detail.** Tablet and mobile keep the design: Items list/table, then a separate Item detail page.

```
┌────┬───────────────────────────┬──────────────────────────────────────┐
│rail│ Items                     │ Item name ● Active                    │
│    │ [🔍 Search items       ]  │ [One-sentence summary]                │
│    │ (All)(Active)(Draft)(Arc) │ [Edit] [Share] [⋮]                    │
│    │ [+ New item]              │ ┌──────────── image ──────────────┐  │
│    │ ● Item one     Active   ◀ │ └─────────────────────────────────┘  │
│    │ ● Item two     Active     │ [Description      ] [Details      ]  │
│    │ ● Item three   Draft      │ [Activity                          ]  │
│    │  list pane ~360           │  detail pane: tablet arrangement      │
└────┴───────────────────────────┴──────────────────────────────────────┘
```

- **List pane:** about 360 wide. It uses the shared item rows (avatar, title, "desc · date", status chip), with search, filter chips and an inline filled "New item" button above them. The selected row gets the Primary container fill plus a leading indicator, not colour alone. The design's table (and its Owner column) isn't used; Owner shows in the Details card.
- **Detail pane:** fills the rest, using the tablet Item detail arrangement (image full width, then [Description | Details], then Activity). It has no back button.
- **Nothing selected** (`/app/items`): the detail pane shows the shared State layout (icon circle, "Select an item", a line of body text) with no buttons.
- **Route:** `/app/items/<id>` selects that item. On desktop/web it renders the split; on mobile/tablet it renders the Item detail page. Resizing across the 1200 / phone-width boundary keeps the same route and item. An unknown id falls back to `/app/items` and shows the placeholder.
- On web the split sits inside the 1120 cap.

## 4. Onboarding framing

### Mobile and tablet: hero on top, sheet below

```
┌──────────────────────────┐
│ ● App name        ☀      │  illustration band, full bleed
│   /\    /\               │
│ ╭────────────────────────╮  rounded sheet overlaps the band
│ │      Step n of 5 [🌐]  │
│ │ Title                  │
│ │ body / tiles / form    │  tablet: same, wider (2-col tiles), ~80 px side padding
│ │                        │
│ │ [ Continue        → ]  │  full-width CTA pinned at bottom
│ ╰────────────────────────╯
└──────────────────────────┘
```

### Desktop and web: split screen

```
┌───────────────────┬──────────────────────────────────────────┐
│ ● App name        │ ← Back            Step n of 5  [🌐 English] │
│ ┌───────────────┐ │                                            │
│ │ illustration  │ │       ┌──── form column ~560 ────┐         │
│ │               │ │       │ Title                     │         │
│ └───────────────┘ │       │ body / tiles / fields     │         │
│ Hero headline     │       └───────────────────────────┘         │
│ hero subline      │                          [ Continue → ]     │  CTA bottom-right, not full width
└───────────────────┴──────────────────────────────────────────┘
left panel ~480 wide, Primary container fill, per-step headline
```

## 5. Shared vs layout-specific

**Shared (every layout uses the same widget, given values by the screen):** every card (Featured, Metric tile, Overview, Recent items, Tip, Quick actions, Details, Activity, Description, Profile, Preferences, Notifications toggles, About), item row, status chip, filter chips, search field, language button (two sizes: icon-only and labelled), avatar, logo mark, image placeholder, onboarding step bodies (title, tiles, forms), step progress, State views (Empty/Error/Loading/Offline).

**Layout-specific:** the shell (bottom bar / rail / web top bar), the page header (mobile top bar vs large title header), the Items table vs list rows, the mobile FAB vs inline "New item" button, back affordance (app-bar arrow vs "← Items" button), the column grid per screen (section 2), onboarding frame (hero + sheet vs split screen) and CTA placement.

## 6. Differences between the designs and DESIGN.md / decided behaviour

1. Wide Item detail shows "Item name" twice (page title, then heading with chip). Mobile shows "Details" + one "Item name". Treat the duplicate as a design slip.
2. Tablet header has no search icon; mobile, desktop and web do.
3. Web SignIn shows "Step 1 of 5"; the routes decision makes SignIn step 2.
4. The rail logo is the mark only (no "App name"); the web top bar shows the full lockup. DESIGN.md doesn't say.
5. Avatar (rail bottom, web top bar right) isn't in DESIGN.md, and nothing says where it goes.
6. "New item" is a tonal extended FAB on mobile but a filled button on wider layouts. DESIGN.md only describes the FAB.
7. The Alerts screen is titled "Notifications" in every design, while the nav says "Alerts" and the glossary calls the feed **alerts**.
8. Language button is icon-only on mobile app screens but labelled in mobile onboarding.
9. Items show an **Archived** status chip and filter on every layout, but `GLOSSARY.md` says an item's status is Active or Draft.
