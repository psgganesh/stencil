# Home dashboard content

Type: grilling
Status: resolved
Blocked by: 08

## Question

The Home design (`.refs/design/*/app/*/… Home.png`) shows:
- a "Welcome back" featured card with a chart;
- an overview card with progress;
- metric tiles;
- recent items;
- a tip card;
- quick actions.

For each one, decide whether it's **computed from real data** (for example counts of items by status, or activity over time) or **placeholder content**. If it's computed, from what? Decide also what each quick action does, and where the tip text comes from.

## Answer

Resolved by grilling on 2026-10-19.

Every number on Home is **computed from the items and alerts repositories**. The copy is fixed, translated placeholder text. Items have no deadlines, so "progress" and "next up" come from status and dates.

### Header

- **Name:** `displayName`, falling back to the part of the email before the @.
- **Subtitle:** fixed copy, "Here's what's happening today."
- **Mobile and tablet:** the app bar title is "Home", with "Welcome back, [Name]" underneath.
- **Desktop and web:** the greeting is the page title.

### Featured card

- **Headline and supporting text:** fixed, translated placeholder copy about the boilerplate (for example "Welcome to Stencil").
- **Chart (desktop and web only; hidden on mobile and tablet, as in the design):** an area chart of activity entries per day over the last 14 days, across all items.
- **Demo data:** the fake's demo-data seed spreads its activity dates over the past 14 days, so the chart isn't flat.
- **Primary, "Add an item":** opens the create form (see [Item create and edit form](11-item-create-edit-form.md)).
- **Secondary, "View items":** goes to Items.

### Overview card

- **Progress:** Active items out of non-archived items (e.g. "4 of 6").
- **One line:** "N drafts waiting to be finished", or "Everything's active" when there are no drafts.
- **Next up:** the most recently updated Draft, shown as its updated date and name. Tapping it opens that item. The block is hidden when there are no drafts.
- **Chip:** "Active" when at least one item is Active, otherwise hidden.

### Metric tiles

| Tile | Value | Caption | Tap |
|---|---|---|---|
| Active items | count of Active | "of N total" | Items, Active filter |
| Drafts | count of Draft | "to finish" | Items, Draft filter |
| Unread alerts | count of `read == false` | "in Alerts" | Alerts, Unread filter |

### Recent items

- **Which items:** the 4 most recently updated (`updatedAt`), excluding Archived.
- **Rows:** the same row as the Items list (letter avatar, name, summary · date, status chip).
- **Tapping a row** opens Item detail at `/app/items/<id>`: the split view on desktop and web, a separate page on mobile and tablet.
- **"See all":** goes to Items.

### Tip card

- **Source:** a fixed list of 3 tips in the ARB files. Home picks one by day of the year. There's no dismiss and no remote content.
- **"Learn more"** goes to an in-app destination, never to marketing:
  - the theme and language tip → Settings;
  - the status filters tip → Items;
  - the "mark all as read" tip → Alerts.

### Quick actions

- **Add an item:** opens the create form.
- **Invite someone:** opens the OS share sheet with a translated invite message plus the download or web link from the downloads and social config file. Where sharing isn't available (some web browsers), it copies the text to the clipboard and shows a snackbar. It never shares the user's data.
- **Open settings:** switches to the Settings tab.

### Live updates

One `HomeViewModel` watches the items and alerts repositories and derives everything above, so Home stays live when data changes elsewhere. No dashboard numbers are stored. Empty, error and loading behaviour is left to [Empty, error, loading and offline states](13-empty-error-loading-offline-states.md).
