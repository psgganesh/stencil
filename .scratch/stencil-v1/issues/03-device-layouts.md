# Device layouts: mobile, tablet, desktop, web

Type: prototype
Status: open
Blocked by:

## Question

Charting settled how the layout is chosen: by platform first, then by width. This ticket asks what each layout actually **is**: navigation, content width and column structure. Compare the four device variants in `.refs/design/{mobile,tablet,desktop,web}/{onboarding,app}/` and sketch (ASCII), for the app screens and for onboarding:
- **Navigation:** bottom bar, rail or top bar.
- **Content width:** the maximum, and any centring.
- **Panes:** where a single pane becomes two (for example Items list + Item detail).
- **Onboarding:** how it's framed on wide screens.

Also identify which parts can be shared widgets used by every layout and which parts are specific to one layout. Record any differences between the designs and `DESIGN.md`.
