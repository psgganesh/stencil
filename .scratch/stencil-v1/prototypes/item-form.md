# Prototype: item create and edit form (ASCII)

A throwaway sketch for [Item create and edit form](../issues/11-item-create-edit-form.md). It uses `DESIGN.md` components (outlined text fields 56 tall with the label above, a segmented control, filled and outlined buttons) and builds on the shells in [device-layouts.md](device-layouts.md). The item fields come from [Firestore data model](../issues/08-firestore-data-model.md). Confirmed on 2026-10-19: option A for wide layouts, and every rule below as written.

## 1. Fields

| Field | Control | Rule | Error message |
|---|---|---|---|
| Name | text field, one line | required, 1–80 chars after trimming | "Enter a name." / "Keep it under 80 characters." |
| Summary | text field, one line, counter `n/140` | required, 1–140 chars | "Add a one-sentence summary." / "Keep it under 140 characters." |
| Category | dropdown (outlined, 56) | one of the fixed list; preselects the first category on create | none: there's always a value |
| Status | segmented control: Active · Draft · Archived | create offers Active · Draft only, defaulting to **Draft**; edit offers all three | none |
| Description | text field, multi-line (min 4 lines, grows), counter `n/2000` | optional, ≤ 2000 chars | "Keep it under 2,000 characters." |

Not editable: owner (copied in at create), created and updated dates, activity.

**When validation runs:** nothing shows until the first Save. After that, each field re-validates as you type. When Save fails validation, focus moves to the first invalid field.

## 2. The form itself (same widget on every layout)

```
 New item                          ← or "Edit item"
 ───────────────────────────────────────────
 Name
 ┌─────────────────────────────────────────┐
 │                                         │
 └─────────────────────────────────────────┘
 Summary
 ┌─────────────────────────────────────────┐
 │                                         │
 └─────────────────────────────────────────┘
                                       0/140
 Category                    Status
 ┌──────────────────────▾┐   ( ✓ Draft | Active )        ← side by side ≥ 600,
 │ General               │                                 stacked on mobile
 └───────────────────────┘
 Description (optional)
 ┌─────────────────────────────────────────┐
 │                                         │
 │                                         │
 │                                         │
 └─────────────────────────────────────────┘
                                      0/2000

                       ( Cancel )  [ Save ]                  ← wide layouts: bottom-right
```

Error state, after Save is pressed with an empty name:

```
 Name
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   2px Error border
 ┃                                         ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 Enter a name.                                  Error colour, Body small
```

**Saving:** Save shows a spinner and all fields are disabled. If saving fails, the form stays filled and a snackbar says "Couldn't save. Try again."

## 3. How it opens on each layout

There are two routes, each rendered per layout like `/app/items/<id>`:
- `/app/items/new` for create;
- `/app/items/<id>/edit` for edit.

Because they're routes, browser Back and refresh work on web.

### Mobile and tablet: a full-screen page (the same level as Item detail)

```
Mobile                                   Tablet
┌──────────────────────────────┐        ┌────┬──────────────────────────────────┐
│ [✕]  New item        [Save]  │        │rail│ ← Items                          │
│──────────────────────────────│        │    │ New item                         │
│ Name                         │        │    │ ┌─ form, max 640 wide ─────────┐ │
│ [                          ] │        │    │ │ Name / Summary               │ │
│ Summary                      │        │    │ │ Category | Status            │ │
│ [                          ] │        │    │ │ Description                  │ │
│ Category                     │        │    │ └──────────────────────────────┘ │
│ [ General               ▾ ]  │        │    │              ( Cancel ) [ Save ] │
│ Status                       │        └────┴──────────────────────────────────┘
│ ( ✓ Draft | Active )         │
│ Description (optional)       │
│ [                          ] │
│                              │
└──────────────────────────────┘
bottom bar hidden while the form is open (it's a task, not a destination)
```

### Desktop and web: three options for the wide layouts

**A: in the detail pane (chosen).** The split stays. The form replaces the detail pane, and the list stays visible. On create, the list has no selected row.

```
┌────┬───────────────────────────┬─────────────────────────────────────────┐
│rail│ Items                     │ New item                                │
│    │ [🔍 Search items       ]  │ Name                                    │
│    │ (All)(Active)(Draft)(Arch)│ [                                     ] │
│    │ [+ New item]  (disabled)  │ Summary                                 │
│    │ ● Item one     Active     │ [                                     ] │
│    │ ● Item two     Active     │ Category            Status              │
│    │ ● Item three   Draft      │ [ General      ▾ ]  ( ✓ Draft | Active )│
│    │                           │ Description (optional)                  │
│    │                           │ [                                     ] │
│    │                           │                     ( Cancel ) [ Save ] │
└────┴───────────────────────────┴─────────────────────────────────────────┘
```

**B: a centred dialog.** The form floats over the split, behind a scrim, about 560 wide.

```
┌────┬───────────────────────────┬─────────────────────────────────────────┐
│rail│ Items░░░░░░░┌──────────────────────────────┐░░░░░░░░░░░░░░░░░░░░░░░ │
│    │ ░░░░░░░░░░░░│ New item                  ✕  │░░░░░░░░░░░░░░░░░░░░░░░ │
│    │ ░░░░░░░░░░░░│ Name / Summary / Category …  │░░░░░░░░░░░░░░░░░░░░░░░ │
│    │ ░░░░░░░░░░░░│            ( Cancel ) [Save] │░░░░░░░░░░░░░░░░░░░░░░░ │
│    │ ░░░░░░░░░░░░└──────────────────────────────┘░░░░░░░░░░░░░░░░░░░░░░░ │
└────┴───────────────────────────┴─────────────────────────────────────────┘
```

**C: a side sheet from the right.** About 420 wide, behind a scrim, covering part of the detail pane.

```
┌────┬───────────────────────────┬────────────────┬────────────────────────┐
│rail│ Items                     │ detail ░░░░░░░ │ New item            ✕  │
│    │ ● Item one     Active     │ ░░░░░░░░░░░░░░ │ Name                   │
│    │ ● Item two     Active     │ ░░░░░░░░░░░░░░ │ Summary                │
│    │                           │ ░░░░░░░░░░░░░░ │ Category · Status      │
│    │                           │ ░░░░░░░░░░░░░░ │ Description            │
│    │                           │ ░░░░░░░░░░░░░░ │      ( Cancel ) [Save] │
└────┴───────────────────────────┴────────────────┴────────────────────────┘
```

| | A: detail pane | B: dialog | C: side sheet |
|---|---|---|---|
| Works as a route (browser back, refresh) | naturally | awkward (a dialog on a route) | awkward |
| Space for Description | full pane | cramped | narrow |
| Consistent with the split decision | yes: the pane shows whatever is selected | adds a second pattern | adds a second pattern |
| Clicking another list row while editing | discard prompt (see 4) | blocked by the scrim | blocked by the scrim |

## 4. After Save, Cancel and Delete

| Action | What happens |
|---|---|
| **Save on create** | The item is created (owner = display name; activity `created`). The app goes to `/app/items/<newId>`: the detail page on mobile and tablet, the split with the new row selected on wide layouts. Snackbar: "Item created". |
| **Save on edit** | The item is updated (activity `edited`; plus `statusChanged` and an alert if the status changed). The app goes back to `/app/items/<id>`. Snackbar: "Changes saved". On edit, Save is disabled until something has changed. |
| **Cancel / ✕ / back / browser back, nothing changed** | Go back to where the form was opened from (the Items list, Item detail, or Home for "Add an item"). |
| **…, with unsaved changes** | A dialog asks "Discard changes?" with Keep editing · Discard. The same prompt appears when another list row or a nav destination is clicked on a wide layout. |
| **Delete** (Item detail ⋮ menu → "Delete item") | A dialog asks *Delete "Item name"?* "This can't be undone." with Cancel · **Delete** (Error colour). The item and its activity are deleted; alerts that were already raised stay. The app goes to `/app/items` (the placeholder on wide layouts). Snackbar: "Item deleted". There's no undo. |

**The Item detail ⋮ menu** has: Archive (or Unarchive, which sets the status back to Active) and Delete item. Edit and Share are buttons, as in the design.

**Entry points:**
- **New item:** the FAB on mobile; the inline button on tablet and wider (disabled while a form is open on wide layouts); "Add an item" on Home (the Featured primary button and the Quick action). All of these go to `/app/items/new`.
- **Edit:** the Edit button on Item detail and in the detail pane goes to `/app/items/<id>/edit`.
- **A bad edit route:** `/app/items/<id>/edit` with an unknown id falls back to `/app/items`, the same as detail does.
