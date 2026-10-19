# Item create and edit form

Type: prototype
Status: open
Blocked by: 08

## Question

Charting decided that items get a working create/edit flow, but there's no design for it. Sketch (ASCII) the form from `DESIGN.md` components:
- which fields it has, from the item model;
- validation and error messages;
- how it opens on each device: a full screen on mobile, a dialog or side sheet on larger screens;
- where the entry points are: the FAB on Items, and Edit on Item detail;
- what happens after save and after cancel.

Also cover deleting an item.

> Context from [Device layouts](03-device-layouts.md): on desktop and web, Items is always a list + detail split (`/app/items/<id>`). Decide whether create and edit open in the detail pane, a dialog or a side sheet there. Entry points: the tonal FAB on mobile, the inline "New item" button on tablet and wider, and Edit on Item detail (or in the detail pane).
