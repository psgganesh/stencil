# Item create and edit form

Type: prototype
Status: resolved
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

## Answer

Resolved on 2026-10-19 with an ASCII prototype (no code): [item-form.md](../prototypes/item-form.md). It holds the sketches, the field table and the after-action table.

### Fields

| Field | Rule |
|---|---|
| Name | required, up to 80 characters |
| Summary | required, up to 140 characters, with a counter |
| Category | dropdown; the first category is preselected on create |
| Status | segmented control. Create offers Draft and Active, defaulting to Draft; Archived is only offered on edit |
| Description | optional, multi-line, up to 2000 characters |

Owner, dates and activity can't be edited.

### Validation

- Errors only appear after the first Save. After that, fields re-check as you type, and focus moves to the first invalid field.
- On edit, Save is disabled until something has changed.
- While saving, fields are disabled. If the save fails, the form keeps its content and a snackbar says "Couldn't save. Try again."

### Where the form opens

- **Routes:** `/app/items/new` and `/app/items/<id>/edit`, each rendered for the current layout. An unknown id falls back to `/app/items`.
- **Mobile and tablet:** a full-screen page; the bottom bar is hidden while the form is open.
- **Desktop and web:** inside the split's detail pane (option A), with the list still visible. "New item" is disabled while the form is open.

### Entry points

- **New item:** the FAB on mobile, the inline "New item" button on wider layouts, and Home's "Add an item" (both the Featured button and the Quick action).
- **Edit:** the Edit button on Item detail, or in the detail pane.

### After save, cancel and delete

- **Saving a new item** opens it at `/app/items/<newId>` and shows "Item created". On wide layouts the new row is selected.
- **Saving an edit** goes back to the item and shows "Changes saved". If the status changed, an activity entry and an alert are written, as decided in the Firestore data model ticket.
- **Cancel, back or browser back:**
  - if nothing changed, the app goes back to where the form was opened from;
  - if there are unsaved changes, a "Discard changes?" dialog appears (Keep editing / Discard). It also appears for list-row and nav clicks on wide layouts.
- **Item detail ⋮ menu:** Archive (or Unarchive, which sets the status back to Active) and Delete item.
- **Deleting:**
  - a confirmation dialog: *Delete "Name"?* "This can't be undone." (Cancel / Delete in the error colour);
  - the item and its activity are deleted, and alerts already raised stay;
  - then the app goes to `/app/items` and shows "Item deleted". There's no undo.
