# Accessibility rules

Type: grilling
Status: resolved
Blocked by:

## Question

Decide the accessibility rules every spec and ticket inherits:
- semantics labels for icon-only buttons, status chips, the avatar, the language button and charts (the Home Featured chart);
- screen reader reading order on Home and in the desktop/web Items split;
- text scaling up to 200%: which layouts reflow, and what may truncate;
- keyboard and focus order on desktop and web, including the split, dialogs, the item form and onboarding;
- the minimum test: which accessibility checks each widget test adds (for example `meetsGuideline` for tap targets, labels and contrast).

## Answer

Resolved by grilling on 2026-10-19. Every spec and ticket inherits these rules.

### Standard and contrast

- **The bar is WCAG 2.1 AA on every platform:**
  - 4.5:1 for text;
  - 3:1 for control boundaries and focus rings;
  - 44–56 px touch targets, as in `DESIGN.md`.
- **The palette was checked on 2026-10-19:**
  - every text pair passes in both themes;
  - field outlines are 4.29:1 in light and 5.83:1 in dark;
  - card borders (1.6:1) and skeleton blocks (1.3:1) are decorative, so they're exempt.
- **One fix.** In dark mode, a filled button on a Primary container surface (the Featured card) uses a `#96CCFF` fill with `#001D32` text. The normal `#00639B` fill was only 1.44:1 against `#004B76`. This is recorded in `DESIGN.md` as an exception to "primary stays `#00639B`".

### Semantics

| Element | What the screen reader gets |
|---|---|
| Icon-only buttons (search, language icon, ✕, ⋮, back) | a `Tooltip` with a translated label, which also gives them their semantics |
| Status chip | "Status: Active" |
| Avatar | "Settings" |
| Language button | "Language: English" |
| List rows | each **merged into one node**, e.g. "Item one, Active, summary, updated 3 Oct" |
| Metric tiles | each **merged into one node**, e.g. "Active items, 4, of 6 total" |
| Page and card titles | **headings** |
| Step progress | "Step 3 of 5" |
| Image placeholder, illustrations | hidden from screen readers |
| Home chart | hidden as a graphic, replaced by one text summary: "Activity, last 14 days: N changes, busiest day <date>" |

### Reading order

- **The mobile order applies on every layout**; wide layouts only rearrange the same cards.
  - **Home:** greeting, Featured, metric tiles, Overview, Recent items, Tip, Quick actions.
  - **Split:** the list pane, then the detail pane.
- After a route change, focus moves to the page heading.

### Text scaling

The system text scale is supported up to **2.0**; anything larger is clamped to 2.0.
- The mobile metric-tile row stacks into one column above 1.5×.
- List-row titles wrap to 2 lines, then ellipsis.
- Buttons grow taller rather than clipping.
- Only the nav labels (bottom bar and rail) may truncate.

### Keyboard (desktop and web)

- **Tab order** follows the reading order.
- **Focus ring:** visible, 2px Selected-and-link.
- **Esc** closes dialogs and cancels forms (with the "Discard changes?" prompt).
- **Enter** submits single-line forms.
- **Ctrl or ⌘ + S** saves the item form and Edit profile.
- **↑ and ↓** move the selection in the Items list pane.
- **Dialogs** trap focus.
- There are no other shortcuts.

### Reduced motion

When `MediaQuery.disableAnimations` is set, the skeleton shimmer, the chart's draw-in animation and page transitions become static or instant.

### Tests

Every screen's widget test adds two checks:
- `meetsGuideline` for `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline`, in light and dark;
- one run at text scale 2.0 at mobile width, with no overflow errors.

These come on top of the existing light, dark and mobile-width tests.
