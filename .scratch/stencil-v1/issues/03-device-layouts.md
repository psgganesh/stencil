# Device layouts: mobile, tablet, desktop, web

Type: prototype
Status: resolved
Blocked by:

## Question

Charting settled how the layout is chosen: by platform first, then by width. This ticket asks what each layout actually **is**: navigation, content width and column structure. Compare the four device variants in `.refs/design/{mobile,tablet,desktop,web}/{onboarding,app}/` and sketch (ASCII), for the app screens and for onboarding:
- **Navigation:** bottom bar, rail or top bar.
- **Content width:** the maximum, and any centring.
- **Panes:** where a single pane becomes two (for example Items list + Item detail).
- **Onboarding:** how it's framed on wide screens.

Also identify which parts can be shared widgets used by every layout and which parts are specific to one layout. Record any differences between the designs and `DESIGN.md`.

## Answer

Resolved 2026-10-19 with an ASCII prototype (no code): [device-layouts.md](../prototypes/device-layouts.md). It has the shells, per-screen column grids, the split, onboarding frames, the list of shared and layout-specific widgets, and the differences between the designs and DESIGN.md.

- **Navigation:** mobile has a bottom navigation bar and a top bar (title, icon-only language button, search). Tablet and desktop have an 80-wide rail: logo mark at the top, Home / Items / Alerts / Settings, avatar at the bottom. Web (≥ 600) has a top bar with the logo and app name, the four destinations as pill links, then search, the labelled language button and the avatar.
- **Avatar:** tapping it opens Settings. No menu.
- **Content width:** desktop and web cap content at **1120**, centred (on desktop, centred in the space beside the rail). On web the top bar's contents sit in the same 1120 column. Tablet and mobile fill the width (about 24 px and 16 px side padding).
- **Columns:** these follow the designs per screen (prototype section 2). Desktop and web use 2/3 + 1/3 grids on Home, Alerts (feed plus Notification settings card) and Settings (two columns). Tablet is mostly one column, with a 2-column row on Home and on Item detail.
- **Panes (a decision, not from the designs):** Items on desktop and web is **always a split**. The list pane (~360) uses item rows with search, filters and "New item". The detail pane uses the tablet Item detail arrangement and has no back button. With nothing selected, the detail pane shows a "Select an item" placeholder in the shared State layout, with no buttons. The design's desktop/web table is dropped, and Owner shows in the Details card. Tablet and mobile keep the design: list or table, then a separate Item detail page.
- **Route:** `/app/items/<id>` is one route rendered per layout: the split with that item selected on desktop/web, the detail page on mobile/tablet. Resizing keeps the item. An unknown id falls back to `/app/items`.
- **Onboarding:** mobile and tablet show an illustration band on top with a rounded sheet over it and a full-width CTA pinned at the bottom. Desktop and web are a split screen: a left hero panel (~480, Primary container, logo, illustration, a headline for each step) and a right form column (~560), with Back and step progress at the top and the CTA bottom-right.
- **New item:** a tonal extended FAB on mobile, a filled inline button on wider layouts.
- **Design slips (fixed):** wide Item detail shows "Item name" only once, and tablet's header gets the search icon.
- **Kept as designed:** the Alerts screen title stays "Notifications" on every layout (the nav label is "Alerts").
- **Left for other tickets:** the designs show an **Archived** item status, but `GLOSSARY.md` lists only Active and Draft (Firestore data model). The create/edit form has to open from the split's detail pane (Item create and edit form). Web SignIn's "Step 1 of 5" is superseded by the routes decision (SignIn is step 2).
