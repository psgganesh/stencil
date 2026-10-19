# 05: Layout shells

**What to build:** Signed-in screens sit inside the right shell for the device. Phones get a bottom navigation bar, native tablets and desktops a rail, and web at 600 and wider a top bar. Web at phone width gets the mobile layout. Desktop and web content is capped at 1120 and centred. The avatar opens Settings. See `../spec.md` → "Layouts and shells".

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] **Layout choice:** platform first, then width.
  - [ ] Web: the web layout at ≥ 600, the mobile layout below that.
  - [ ] Native: mobile below 600, tablet from 600 to 1199, desktop at 1200 or more.
  - [ ] The chosen layout is exposed to screens.
- [ ] **The three shells** wrap Home, Items, Alerts and Settings, with the active destination indicated as in `DESIGN.md`:
  - [ ] **mobile:** bottom bar plus a top bar with title, icon-only language button and search;
  - [ ] **rail:** logo mark, four destinations, avatar at the bottom, and a header with title, subtitle, search and labelled language button;
  - [ ] **web top bar:** logo, app name, pill links, search, labelled language button, avatar.
- [ ] **Content width:** capped at 1120 and centred on desktop and web; 24 / 16 px side padding on tablet and mobile.
- [ ] **Avatar:** shows the initial (display name, else email prefix) or a person icon, has the screen-reader label "Settings", and opens `/app/settings`.
- [ ] **Search icon:** shown and labelled "Search", and does nothing.
- [ ] **Hidden-shell option:** a shell option hides the bottom bar for sub-pages (used later by the item form and Edit profile).
- [ ] Root-widget tests:
  - [ ] the shell chosen for each platform and width combination;
  - [ ] navigation between the four destinations;
  - [ ] the avatar opening Settings;
  - [ ] guidelines in light and dark;
  - [ ] text scale 2.0 at mobile width with no overflow (only nav labels may truncate).
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
