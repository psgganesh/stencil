# 07: Shared widget kit

**What to build:** The building blocks every later screen is made from exist, match `DESIGN.md` in light and dark, and are accessible. Placeholder screens use them so they can be seen in the running app. See `../spec.md` → "Shared widget kit" (building blocks; the state views come in 08).

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] **Widgets:**
  - [ ] outlined card; Featured card (Primary container); Tip card (Tertiary container);
  - [ ] status chip (Active, Draft, Archived; always labelled; read as "Status: X");
  - [ ] filter chip with selected state;
  - [ ] item row (letter avatar, title, "summary · date", status chip; one merged screen-reader node);
  - [ ] metric tile (one merged screen-reader node);
  - [ ] filled, tonal, outlined and text buttons, and the extended FAB;
  - [ ] outlined text field (label above, error message below);
  - [ ] segmented control; toggle row; selectable option card;
  - [ ] image placeholder (hidden from screen readers);
  - [ ] step progress ("Step N of 5").
- [ ] Widgets take values and callbacks from their screen and don't read providers.
- [ ] Icon-only buttons use a `Tooltip` with a translated label. Card titles are headings.
- [ ] Touch targets are 44–56 px. Selected states never rely on colour alone.
- [ ] Placeholder screens use a representative set of the widgets.
- [ ] Root-widget tests over a placeholder screen that uses the widgets:
  - [ ] light and dark;
  - [ ] `meetsGuideline` for `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline`;
  - [ ] text scale 2.0 at mobile width with no overflow;
  - [ ] the merged screen-reader labels of the item row and metric tile.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
