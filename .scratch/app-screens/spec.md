# Spec: app screens

**Status:** ready-for-agent
**Source:** the wayfinder map `.scratch/stencil-v1/map.md`; decisions point to `.scratch/stencil-v1/issues/` by ticket number. Designs: `.refs/design/{mobile,tablet,desktop,web}/app/{light,dark}/`. Sketches: `.scratch/stencil-v1/prototypes/device-layouts.md`, `item-form.md`, `edit-profile.md`.
**Order:** spec 5 of 5 (Foundation → CI/CD → Onboarding → marketing → **app screens**).

## Assumes

Foundation, CI/CD, Onboarding and marketing are done:
- **Placeholders to replace:** the routes `/app`, `/app/items`, `/app/items/new`, `/app/items/<id>`, `/app/items/<id>/edit`, `/app/alerts`, `/app/settings`, `/app/settings/profile`, with redirects.
- **Shells and layouts:**
  - the mobile, rail and web-top-bar shells, including the option that hides the bottom bar;
  - layout selection;
  - the 1120 content cap.
- **Shared widgets:**
  - the kit: cards, Featured and Tip cards, metric tile, item row, status and filter chips, text field, segmented control, toggle row, option card, buttons, image placeholder;
  - the language button and its picker;
  - the avatar;
  - the four skeleton shapes;
  - the state views;
  - the async content wrapper.
- **Data and state:**
  - the session, with sign-in method;
  - the theme and language notifiers;
  - `PlatformCapabilities`.
- **Repositories:** the fake `UserRepository`, `ItemsRepository` (with activity, and an alert raised on status change), `AlertsRepository`, `NotificationPermissionRepository`, the demo seed, `AppFailure` codes, the `FAKE_*` flags, and the delete-account action.
- **Other pieces:** the `ProfileFields` widget (from Onboarding), and the marketing routes `/terms`, `/privacy`, `/support` and `/contact` on web.

## Problem Statement

After onboarding, a signed-in user lands on placeholder screens. The boilerplate's core promise isn't delivered: a real, working app on every device, built around a sample **item** with:
- a dashboard;
- a list and detail;
- create and edit;
- alerts;
- settings.

A product team can't judge the architecture, rename the **item**, or demo the app until these screens work, with live data, on phone, tablet, desktop and web.

## Solution

Five screens plus two forms, each with one view model that every layout reads:

- **Home:** a live dashboard computed from the user's items and alerts.
- **Items:**
  - a searchable, filterable list;
  - a separate detail page on mobile and tablet;
  - a permanent list + detail split on desktop and web.
- **Item detail:** summary, image placeholder, description, details, the latest activity, plus Edit, Share, Archive and Delete.
- **Item form:** create and edit at `/app/items/new` and `/app/items/<id>/edit`.
- **Alerts:** the feed with All / Unread, "Mark all as read", and a notification settings card on wide layouts.
- **Settings:** profile, language, appearance, notification toggles, about links, sign out and delete account.
- **Edit profile:** at `/app/settings/profile`.

Every screen uses Foundation's loading, empty, error and offline handling, and follows the accessibility rules.

## User Stories

### Home

1. As a user, I want Home to greet me by name ("Welcome back, <name>"), or by the part of my email before the @ if I haven't set a name, so that it feels personal.
2. As a user on desktop or web, I want the greeting as the page title with "Here's what's happening today." under it, and on a phone or tablet the title "Home" with the greeting beneath, so that each layout reads naturally.
3. As a user, I want a Featured card with a headline and a line about the app, "Add an item" and "View items", so that the main actions are front and centre.
4. As a desktop or web user, I want the Featured card to show an area chart of my activity per day over the last 14 days, so that I see how busy I've been.
5. As a screen-reader user, I want the chart summarised as "Activity, last 14 days: N changes, busiest day <date>", so that I get the same information.
6. As a user, I want an Overview card showing how many of my non-archived items are Active ("4 of 6") with a progress bar, so that I see progress at a glance.
7. As a user with drafts, I want the Overview to say "N drafts waiting to be finished" and show "Next up" with my most recently updated Draft, which opens when tapped, so that I know what to do next.
8. As a user without drafts, I want "Everything's active" and no Next up block, so that the card doesn't nag me.
9. As a user, I want an "Active" chip on the Overview only when at least one item is Active, so that the chip means something.
10. As a user, I want three metric tiles (Active items "of N total", Drafts "to finish", Unread alerts "in Alerts") that open the filtered list when tapped, so that I can jump straight to them.
11. As a user, I want Recent items showing my 4 most recently updated non-archived items, each opening its detail, with "See all", so that I can pick up where I left off.
12. As a user, I want a Tip card with one of three tips, changing daily, whose "Learn more" opens the screen it's about, so that I discover features.
13. As a user, I want Quick actions (Add an item, Invite someone, Open settings), so that common tasks are one tap away.
14. As a user, I want "Invite someone" to open my device's share sheet with an invite message and the download link (or copy it on browsers without sharing), so that I can tell a friend without sharing my data.
15. As a user, I want Home to update by itself when I change an item or read an alert elsewhere, so that the numbers are always right.
16. As a user with no items, I want Home to show zeros, "0 of 0" and an inline "No items yet" with "Add an item", rather than an empty screen, so that I know how to start.

### Items

17. As a user, I want Items to list all my items, newest change first, each with a letter avatar, name, "summary · date" and status chip, so that I can scan them.
18. As a user, I want a search field that filters by name and summary as I type, so that I can find an item fast.
19. As a user, I want All / Active / Draft / Archived filter chips, so that I can narrow the list.
20. As a user, I want the status filter in the URL, so that Home's tiles and browser back land on the right filter.
21. As a user whose search or filter matches nothing, I want "No items match" with "Clear filters", so that I can get back to everything.
22. As a user with no items at all, I want "Nothing here yet", "Items you create show up here." and "+ Add your first item", so that I know what to do.
23. As a phone user, I want a "New item" floating button, and on wider screens an inline "New item" button, so that creating is always within reach.
24. As a tablet user, I want the list as a table (Name, Status, Updated, ›), so that the extra width is useful.
25. As a desktop or web user, I want the list and the selected item's detail side by side, so that I can browse without losing my place.
26. As a desktop or web user with nothing selected, I want a "Select an item" placeholder in the detail pane, so that the empty space explains itself.
27. As a desktop or web user, I want ↑ and ↓ to move the selection in the list, so that I can browse from the keyboard.
28. As a user, I want `/app/items/<id>` to open that item on any device, and resizing the window to keep it open, so that links always work.
29. As a user who follows a link to an item that doesn't exist, I want to land on Items, so that I'm never stuck.

### Item detail

30. As a user, I want Item detail to show the name with its status chip, the summary, an image placeholder, the description, a Details card (Owner, Category, Created, Updated) and the latest 3 activity entries, so that I see everything about the item.
31. As a phone user, I want the top bar to say "Details" with a back arrow; as a tablet user, "← Items"; and in the desktop/web split, no back button, so that going back fits each layout.
32. As a user, I want "Edit" to open the edit form, so that I can change the item.
33. As a user, I want "Share" to open my device's share sheet with the item's name and summary (or copy it where sharing isn't available), so that I can tell someone about it.
34. As a user, I want a ⋮ menu with Archive (or Unarchive) and Delete item, so that less common actions are tucked away.
35. As a user, I want Archive to set the status to Archived, and Unarchive to set it back to Active, each recorded as activity and raising an alert, so that the change is tracked.
36. As a user, I want Delete to ask *Delete "<name>"?* "This can't be undone.", then remove the item and its activity, return me to Items and say "Item deleted", so that I don't delete by accident.
37. As a user, I want activity entries read as "Created", "Edited" or "Status changed to <status>" with date and person, so that the history is clear.

### Item form

38. As a user, I want to create an item with a name, a one-sentence summary, a category, a status and an optional description, so that I can track something new.
39. As a user, I want new items to default to Draft, with only Draft and Active offered, so that I can't create an archived item.
40. As a user editing an item, I want Active, Draft and Archived offered, so that I can change any status.
41. As a user, I want errors to appear only after I first press Save, then update as I type, with focus moved to the first problem, so that I'm not scolded while typing.
42. As a user editing an item, I want Save disabled until I've changed something, so that I don't save nothing.
43. As a user, I want Ctrl/⌘+S to save and Esc to cancel on desktop and web, so that I can work from the keyboard.
44. As a user, I want "Discard changes?" when I leave with unsaved changes (Cancel, ✕, back, browser back, or clicking another item or nav destination), so that I don't lose work.
45. As a user, I want a new item to open in its detail with "Item created", and an edit to return to the item with "Changes saved", so that I see the result.
46. As a user whose save fails, I want my input kept and "Couldn't save. Try again.", so that I can retry.
47. As a phone or tablet user, I want the form full screen with the bottom bar hidden; as a desktop or web user, I want it in the detail pane next to the list, so that it fits each device.

### Alerts

48. As a user, I want the Alerts screen titled "Alerts", listing my alerts newest first under "Today" and "Earlier", with relative times, so that recent ones stand out.
49. As a user, I want each alert's icon to show its kind (info, success, warning), and unread ones marked "New", so that I can tell them apart.
50. As a user, I want tapping an alert to mark it read, so that "New" means what it says.
51. As a user, I want All / Unread filters and "Mark all as read", so that I can clear my alerts quickly.
52. As a user with no alerts, I want "You're all caught up", and with Unread on and nothing unread, "No unread alerts", so that an empty feed is reassuring.
53. As a desktop or web user, I want a "Notification settings" card beside the feed with the same toggles as Settings and "Manage in Settings", so that I can adjust delivery where I read alerts.

### Settings and Edit profile

54. As a user, I want a Profile card with my avatar, name, email and "Edit profile", so that I can see and change who I am.
55. As a user, I want a Preferences card with Language (current language, opening the picker) and Appearance (Light / Dark / System), each applying immediately, so that I can personalise the app.
56. As a user, I want Notifications toggles for Push, Email updates and Weekly summary that save immediately, so that I control how I'm reached.
57. As a Windows or Linux user, I want the Push row hidden, so that I'm not offered something my device can't do.
58. As a user turning Push on without permission, I want the system prompt (if never asked) or the toggle to switch back with "Turned off in device settings" and "Open settings" (if denied), so that the toggle never lies.
59. As a web user whose browser can't show notifications, I want Push disabled with "Not available in this browser".
60. As a user, I want About rows for Terms of service, Privacy policy, Help and support, and Version, so that I can find the legal and help pages.
61. As a user, I want the About links to open those pages in the app on web and on the website in my browser on native, so that they always work.
62. As a user, I want the Version row to show "1.2.0 (34)" and copy it when tapped, so that I can quote it to support.
63. As a user, I want "Sign out" to sign me out straight away, landing on login (native) or the marketing Home (web), so that it's quick.
64. As a user, I want "Delete account" to confirm first, then delete everything, so that I can leave cleanly.
65. As a user whose sign-in is too old to delete the account, I want "Please sign in again to continue." and to be signed out to login, so that I can retry safely.
66. As a user, I want "Edit profile" to open a page where I can change my name (optional, up to 50 characters) and what best describes me, with my email shown read-only, so that I can fix my details.
67. As a user who signed in with email, I want "Change password" there to send me a reset link ("We've sent a reset link to <email>"), and as a Google or Apple user not to see it, so that the option only appears when it makes sense.
68. As a user, I want my new name to show everywhere immediately after "Profile saved", so that the change feels real.

### Everywhere

69. As a user, I want each screen to show a skeleton only when loading takes longer than 300 ms, so that fast loads don't flash.
70. As a user, I want a failed load to show the Error state with its code, "Try again" and "Contact support", and a failed action (save, delete, mark read) to show a snackbar, so that problems are clear but not disruptive.
71. As a screen-reader user, I want page and card titles as headings, item rows, metric tiles and alerts each read as one item, and every icon button labelled, so that I can use the app without sight.
72. As a user with large text, I want every screen to work at 200%, so that I can read it.
73. As a user who prefers reduced motion, I want the chart to appear without animating, so that the app stays calm.

## Implementation Decisions

### View models

There's one view model per screen and form. Each is a per-screen, `isAutoDispose: true` notifier holding immutable state with `copyWith`, `==` and `hashCode`. All layouts of a screen read the same view model.

| View model | Watches | Exposes |
|---|---|---|
| **HomeViewModel** | items, alerts, user | greeting name; 14-day activity series and its text summary; overview (active count, non-archived count, draft count, next-up draft or none); the three metric values; the 4 recent items; today's tip index; nothing stored (Home dashboard content, 09) |
| **ItemsViewModel** | items | the list sorted by `updatedAt` descending; search text; status filter; filtered list; the selected id (desktop/web) |
| **ItemDetailViewModel** | one item with activity, by id | the item; latest 3 activity entries; archive, unarchive, delete; share text |
| **ItemFormViewModel** | the item, in edit mode | field values, errors (after first save), dirty flag, saving flag, save, discard check (Item create and edit form, 11) |
| **AlertsViewModel** | alerts, user | grouped feed (Today / Earlier); filter (All or Unread); unread count; mark one read; mark all read; the notification preferences for the wide card |
| **SettingsViewModel** | user, session, permission status, capabilities | profile summary; notification toggles and their permission-aware states; version; sign out; delete account |
| **EditProfileViewModel** | user | name and role, dirty flag, save, discard check (Edit profile, 14) |

### Routes and URL state

- **`/app` (Home).**
- **`/app/items`:** takes `?status=active|draft|archived` (absent means All). The Home tiles link to `?status=active` and `?status=draft`. The search text isn't in the URL.
- **`/app/items/<id>`:**
  - **mobile and tablet:** the detail page;
  - **desktop and web:** the split with that item selected;
  - **unknown id:** `/app/items`;
  - **resizing:** the route and the item are kept.
- **`/app/items/new` and `/app/items/<id>/edit`:**
  - **mobile and tablet:** a full-screen form with the bottom bar hidden;
  - **desktop and web:** the form in the split's detail pane; "New item" is disabled while it's open.
- **`/app/alerts`:** takes `?filter=unread`. The Unread alerts tile links to it.
- **`/app/settings`** and **`/app/settings/profile`.**

### Home

From Home dashboard content (09) and the layout grid in the device-layouts sketch, §2.

| Card | Contents |
|---|---|
| **Header** | Desktop and web: "Welcome back, <name>" as the page title, with "Here's what's happening today." Mobile and tablet: "Home" in the app bar, with the greeting beneath. |
| **Featured** | Fixed translated headline and line about the boilerplate. "Add an item" (filled, using the dark-mode exception colours) → `/app/items/new`. "View items" (outlined) → `/app/items`. **Area chart:** activity entries per day across all items over the last 14 days. Shown on tablet and wider only, hidden from screen readers, with the text summary instead, and not animated under reduced motion. **Drawn with a custom painter; no chart package is added.** |
| **Overview** | "Active" chip when there's ≥1 Active. The one-line state. "Progress" with "<active> of <non-archived>" and a linear bar. "NEXT UP" block (latest Draft: date · name, tappable) hidden when there are no drafts. |
| **Metric tiles** | Active items / Drafts / Unread alerts, with captions "of N total" / "to finish" / "in Alerts". Each is one merged screen-reader node and opens its filtered list. |
| **Recent items** | The 4 latest non-archived items as item rows, each opening its detail. "See all" → `/app/items`. With none: inline "No items yet" with "Add an item". |
| **Tip** | One of 3 ARB tips, chosen by day of the year. "Learn more →" goes to: Settings (the theme and language tip), Items (the filters tip), or Alerts (the mark-all-read tip). |
| **Quick actions** | Add an item → `/app/items/new`. Invite someone → share. Open settings → `/app/settings`. |

**Layouts:**
- **mobile:** 1 column, in the order Featured, metric row, Overview, Recent, Tip, Quick actions. This is also the reading order on every layout.
- **tablet:** Featured with chart, metrics, then [Overview | Tip + Quick actions], then Recent full width.
- **desktop and web:** [Featured 2/3 | Overview 1/3], metrics, [Recent 2/3 | Tip + Quick actions 1/3].

The metric row stacks into a column above 1.5× text scale.

**Invite and Share** use **`share_plus`**, a new dependency. Invite shares a translated invite message plus the site URL from the config file. Where sharing isn't supported, the text is copied to the clipboard with the snackbar "Copied to clipboard".

**Home never shows the full Empty state.** It uses the Home skeleton while loading.

### Items and Item detail

- **List:**
  - **Search field:** filters by name and summary (case-insensitive) on the device.
  - **Filter chips:** All, Active, Draft, Archived.
  - **Rows:** item rows. On tablet it's a table instead: Name (avatar + name), Status, Updated, ›.
  - **No matches:** inline "No items match" plus a "Clear filters" text button (clears search and status).
  - **No items at all:** the full Empty state, "Nothing here yet" / "Items you create show up here." / "+ Add your first item" (Empty, error, loading and offline states, 13).
- **New item:** a tonal extended FAB on mobile; a filled inline button above the list on tablet and wider.
- **Split (desktop and web):** list pane about 360 wide, detail pane filling the rest.
  - **Selection:** the selected row uses the Primary container fill plus a leading indicator.
  - **Nothing selected:** the detail pane shows the Placeholder state, "Select an item" plus a line of body text.
  - **Keyboard:** ↑ and ↓ move the selection and update the route.
  - **No table:** the design's desktop/web table is dropped; Owner shows in the Details card (Device layouts, 03).
- **Detail header:**
  - **mobile:** app bar "Details" with a back arrow;
  - **tablet:** "← Items" above the heading;
  - **split:** no back button.

  The heading is the item name plus its status chip, shown once (the wide design's duplicate title is a slip). Below it: the summary, then the actions — "Edit" (filled), "Share" (outlined), and ⋮ (Archive or Unarchive, Delete item).
- **Detail body:**
  - **Image:** the static placeholder (no upload, no Storage).
  - **Description card:** with no description, "No description yet." in On surface variant.
  - **Details card:** Owner, Category, Created, Updated.
  - **Activity card:** the latest 3 entries, each a check circle, a title ("Created", "Edited", "Status changed to <status>") and "date · person". There's no "see all".
  - **Layout:** mobile is 1 column; tablet and the split pane use image full width, then [Description | Details], then Activity full width.
- **Archive / Unarchive:** sets the status through the repository. That writes the `statusChanged` activity and raises the alert (Firestore data model and security rules, 08). Snackbar: "Item archived" or "Item restored".
- **Delete:** a confirmation dialog, *Delete "<name>"?* / "This can't be undone." with Cancel · **Delete** (error colour). It deletes the item and its activity (alerts already raised stay), goes to `/app/items` (the placeholder on wide layouts), and shows the snackbar "Item deleted". There's no undo.

### Item form

From Item create and edit form (11); `.scratch/stencil-v1/prototypes/item-form.md`.
- **Fields:**
  - **Name:** required, 1–80 characters after trimming; errors "Enter a name." / "Keep it under 80 characters."
  - **Summary:** required, 1–140, with an `n/140` counter; "Add a one-sentence summary." / "Keep it under 140 characters."
  - **Category:** a dropdown of the fixed placeholder list; the first is preselected on create.
  - **Status:** a segmented control. Create offers Draft · Active, defaulting to Draft; edit offers all three.
  - **Description:** optional, multi-line (at least 4 lines, growing), ≤ 2000, with a counter; "Keep it under 2,000 characters."
  - **Not editable:** owner, dates, activity.
- **Validation:** errors appear after the first Save, then update as the user types. Save moves focus to the first invalid field.
- **Saving:**
  - On edit, Save is disabled until something has changed.
  - While saving, the button shows progress and the fields are disabled.
  - On failure, the form keeps its values and a snackbar says "Couldn't save. Try again."
- **Frame:**
  - **mobile:** an app bar with ✕, "New item" or "Edit item", and Save;
  - **tablet:** a page with "← Items", the title, the form at most 640 wide, and Cancel · Save bottom-right;
  - **split:** the form in the detail pane, with Cancel · Save bottom-right.

  Category and Status sit side by side at 600 and wider, stacked below that.
- **After saving:**
  - create → `/app/items/<newId>` with "Item created" (the new row is selected on wide layouts);
  - edit → `/app/items/<id>` with "Changes saved".
- **Discard check:** when there are unsaved changes, every way out (Cancel, ✕, Esc, back, browser back, another list row, a nav destination) asks "Discard changes?" with Keep editing · Discard. With nothing changed, it goes straight back to where the form was opened from: Items, Item detail, or Home.
- **Keyboard:** Ctrl/⌘+S saves, and Esc cancels with the discard check (Accessibility rules, 16).

### Alerts

From Firestore data model and security rules (08) and Empty, error, loading and offline states (13).
- **Title:** "Alerts" everywhere (the designs say "Notifications"; the glossary term wins).
- **Top of the feed:** All / Unread filter chips, plus a "Mark all as read" text button (disabled when nothing is unread).
- **Feed:** a card with sections headed "TODAY" and "EARLIER" (Today is the device's current calendar day).
  - **Each alert:** a kind icon in a tinted circle (info = Primary container, success = Gain container, warning = Tertiary container), the title, the body, and on the right a relative time plus a "New" chip when unread.
  - **Relative times:** "Just now" (under a minute), "N minutes ago", "N hours ago", "Yesterday", the weekday name (within the last 7 days), "Last week" (7–13 days), then the date.
- **Tapping an alert** marks it read. There's no navigation; alerts don't link to items.
- **Empty:**
  - no alerts at all → the full Empty state, "You're all caught up" / "New alerts show up here." with no buttons;
  - Unread with none → inline "No unread alerts".
- **Wide card:** on desktop and web, a "Notification settings" card sits in the right third. It has the same toggle rows as Settings, with the same permission-aware behaviour and the same Push row hiding, plus an outlined "Manage in Settings" → `/app/settings`. Tablet and mobile have no card.
- **Errors:** a failed mark-read shows a snackbar.

### Settings

From Permissions step and notification toggles (10), Sign-in and data on Windows (12), What onboarding Preferences control (15), Accessibility rules (16).
- **Profile card:** the avatar (initial), name (or the email prefix), email, and an outlined "Edit profile" → `/app/settings/profile`.
- **Preferences card:**
  - "Language" shows the current native name and opens the language picker;
  - "Appearance" is a Light / Dark / System segmented control.

  Both apply and save immediately (device-only).
- **Notifications card:** three toggle rows that each save immediately to the user record.

  | Row | Subtitle | Notes |
  |---|---|---|
  | Push notifications | "Updates on your device." | hidden when `pushDelivery` is false (Windows, Linux) |
  | Email updates | "News and summaries by email." | saves the preference only |
  | Weekly summary | "One short email each week." | saves the preference only |

  **Turning Push on** depends on the permission status:

  | Permission status | What happens |
  |---|---|
  | not asked | the system prompt appears; the toggle stays on if granted, goes back off if denied |
  | denied | the toggle goes back off; the subtitle becomes "Turned off in device settings" with an "Open settings" link (on web: "Blocked in your browser settings.") |
  | unavailable | the row is disabled, subtitle "Not available in this browser" |

  Turning Push off only saves the preference. Nothing is delivered in v1.
- **About card:**
  - "Terms of service" → `/terms`, "Privacy policy" → `/privacy`, "Help and support" → `/support`. These are in-app on web; on native they open `<site URL>/<path>` in the browser through `url_launcher`.
  - "Version" shows "<version> (<build>)" from **`package_info_plus`** (a new dependency). Tapping it copies the version with the snackbar "Version copied".
- **Sign out:** an outlined error-coloured "Sign out" with a leading icon. **No confirmation.** It signs out and goes to `/login` (native) or `/` (web).
- **Delete account:**
  - an error-coloured text button "Delete account";
  - a confirmation dialog: "Delete your account?" / "This deletes your items, alerts and profile. This can't be undone." with Cancel · **Delete**;
  - runs Foundation's delete-account action, which goes to `/login` (native) or `/` (web);
  - **recent sign-in required:** the dialog closes, the snackbar says "Please sign in again to continue.", and the user is signed out to `/login`.
- **Layouts:**
  - **mobile and tablet:** 1 column: Profile, Preferences, Notifications, About, then the Sign out / Delete row;
  - **desktop and web:** [Profile + Preferences + Sign out row | Notifications + About].

### Edit profile

From Edit profile (14); `.scratch/stencil-v1/prototypes/edit-profile.md`.
- **Fields:** `ProfileFields` (name optional, ≤ 50 characters, error "Keep it under 50 characters."; role as three option cards, always one selected), then a read-only Email row.
- **"Change password":** a text button, shown only when the session's sign-in method is email. It calls the auth repository's password-reset method and shows "We've sent a reset link to <email>".
- **No avatar upload.**
- **Frame:**
  - **mobile and tablet:** a full-screen page with ✕, "Edit profile" and Save; the bottom bar is hidden;
  - **desktop and web:** a page in the content column, at most 640 wide, with "← Settings" and Cancel · Save; the shell stays visible.
- **Save:** disabled until something has changed. It writes `displayName` and `role`, goes back to Settings, and shows "Profile saved". The new name appears immediately on the Settings card, the Home greeting and the avatar.
- **Leaving:** the discard check and Ctrl/⌘+S work as on the item form. On failure the values are kept and a snackbar says "Couldn't save. Try again."

### States and loading

- Every screen's data goes through Foundation's async content wrapper (skeleton after 300 ms, Error with code and Contact support, Offline, reload keeping data plus snackbar).
- **Skeleton shapes:** Home → Home; Items and Alerts → List; Item detail → Detail; Settings → Settings.
- **Snackbars:** errors from actions (save, delete, archive, mark read, toggle) always show as snackbars, never as full states.

### Strings and dependencies

- **Strings:** all new copy goes into all 10 ARB files (English, plus machine-drafted translations marked for review). This includes the three tips, the invite message, relative times, and the activity titles.
- **New dependencies:** `share_plus` and `package_info_plus`. No chart package.

## Testing Decisions

- **What a good test is:** it drives the app through its root widget, signed in and onboarded, and checks what the user sees and the resulting repository state. It doesn't read view-model fields or widget internals.
- **The seam:** Foundation's seam 1, the root widget with provider overrides:
  - fake repositories with the demo seed or a small test data set, including a repository that fails on demand;
  - in-memory preferences;
  - `PlatformCapabilities` per platform;
  - `NotificationPermissionRepository` per status;
  - the session with a chosen sign-in method;
  - a clock override for relative times and "today".

  Each test runs at mobile, tablet and desktop/web sizes as relevant. It covers:
  - **Home:** each computed number from a known data set; the next-up rule; the chip rule; the 14-day series and its text summary; tile, row, tip and quick-action targets; Invite falling back to the clipboard; zero-item Home; live updates after an item changes.
  - **Items:** the sort order, search, status filter and `?status=`, no-match and empty states, the FAB vs the inline button, the tablet table, the split with placeholder and selection, ↑/↓ selection, the unknown id, resize keeping the item.
  - **Item detail:** the header per layout, archive and unarchive (activity and alert written), delete confirm and route, the Share fallback.
  - **Item form:** validation timing and messages, Draft default and status options per mode, dirty-gated Save, Ctrl/⌘+S, every discard path, create and edit outcomes and routes, the save failure.
  - **Alerts:** grouping, relative times with a fixed clock, tap to read, Unread and `?filter=unread`, mark all read, both empty variants, the wide settings card present only on desktop/web.
  - **Settings:** language and appearance applying immediately, each toggle saving, every Push permission path, the Push row hidden on Windows/Linux, the About targets on web vs native, the version text and copy, sign out per platform, delete account (success and recent-sign-in outcome).
  - **Edit profile:** fields prefilled, the 50-character limit, "Change password" only for email sign-ins, save updating the name everywhere, the discard check.
  - **Every screen:** light and dark, `meetsGuideline` (tap targets, labels, contrast), and text scale 2.0 at mobile width with no overflow.
- **No new seam.** No new repository methods are added beyond Foundation's, so its contract suites cover the data layer.
- **Prior art:** Foundation's root-widget helpers, and the Onboarding and marketing flow tests.

## Out of Scope

- **Search results** from the header search icon. Only the Items list has a search field.
- **Image upload,** and sharing items with other users.
- **Activity history** beyond the latest 3 entries.
- **Real delivery:** push, email updates and the weekly summary (preferences only).
- **Real auth, real Firestore,** offline detection and the offline banner.
- **Undo** for delete.

## Further Notes

- **Differences from the designs, on purpose:**
  - the Alerts title is "Alerts", not "Notifications";
  - the Mentions filter is dropped;
  - the Archived status and filter are added;
  - the desktop/web Items table becomes the split;
  - the wide Item detail's duplicate title is removed;
  - the tablet header gets a search icon (Foundation);
  - the Weekly summary toggle defaults to off.
- **Details filled in while writing this spec** (not explicitly grilled; reverse them in review if wrong):
  - `?status=` on Items and `?filter=unread` on Alerts;
  - "No description yet.";
  - the relative-time scale;
  - the archive and restore snackbars;
  - the chart drawn with a custom painter rather than a chart package;
  - the Settings delete-dialog copy;
  - the Mark-all-as-read button disabled when nothing is unread.
- **Suggested `/to-tickets` slices:**
  1. Items list + Item detail (mobile and tablet);
  2. the desktop/web split;
  3. the item form;
  4. Home;
  5. Alerts;
  6. Settings;
  7. Edit profile.
