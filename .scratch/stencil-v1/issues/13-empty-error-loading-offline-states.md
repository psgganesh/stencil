# Empty, error, loading and offline states

Type: grilling
Status: resolved
Blocked by: 08

## Question

The state designs are now in `.refs/design/<device>/states/` and described in `DESIGN.md` → States. Decide how they behave:

- **Which screens get which states.** For example, does Home show Empty when there are no items, or its own welcome version? Alerts and Item detail need their own empty and not-found copy. Should the Empty copy and buttons be set per screen?
- **Loading:** show the skeleton immediately or only after a short delay, and how its shape matches each screen.
- **Error:** what "Error code: [CODE]" contains (a repository error type? an id?), what "Contact support" opens (`/support`, or Contact Us with the code filled in), and whether there's a retry limit.
- **Offline:** how it is detected (Firestore's own cache and metadata, or a connectivity package, which is a new dependency) and when the full Offline screen replaces content versus a cached list with a banner. The Offline state has only a "Try again" button; the design's "View saved items" is dropped (decided 2026-10-19). Firestore's offline cache is on by default on native and off by default on web (see [Firebase support on each platform](05-firebase-platform-support.md)). With the fake repositories, is offline ever shown?
- **marketing and onboarding:** do they use these states, or only the app screens?

> Context from [Firestore data model and security rules](08-firestore-data-model.md): v1 runs only on the fakes, which reseed 7 demo items and 3 alerts whenever the user's data is empty. So Empty shows only after the user deletes items, or when a test overrides a repository. Firestore's offline behaviour comes later.

## Answer

Resolved by grilling on 2026-10-19.

### Where the states are used

- **Only on the app screens that load data:** Home, Items, Item detail, Alerts and Settings. A state replaces only the content area, as `DESIGN.md` → States says.
- **Onboarding and marketing don't use them.** Their content is local or bundled.
  - A failed Contact Us send shows an inline error under the form.
  - A failure when onboarding is Done (seeding welcome alerts, saving `onboardingFinishedAt`) shows a snackbar with a retry.

### Empty

| Screen | What shows |
|---|---|
| **Items, no items at all** | Full Empty state: "Nothing here yet" / "Items you create show up here." / filled **"+ Add your first item"** → `/app/items/new`. The design's outlined "Learn more" is dropped, because native has no page for it. |
| **Items, filter or search with no matches** | Not the Empty state. An inline line, "No items match", with a "Clear filters" text button. |
| **Home** | Never the full Empty state. The tiles show 0, Overview reads "0 of 0" (the Next up block is hidden), and the Recent items card shows an inline "No items yet" with "Add an item". |
| **Alerts** | Full Empty state: "You're all caught up" / "New alerts show up here.", with no buttons. With the Unread filter on and nothing unread: an inline "No unread alerts". |
| **Item detail** | No not-found state. The existing fallback to `/app/items` covers unknown ids and items deleted while open. |

### Loading

- **First load:** nothing for **300 ms**, then the skeleton plus the 4 px progress bar, so fast loads don't flash.
- **Reloading with data on screen:** the data stays and only the progress bar shows.
- **No pull-to-refresh** in v1.
- **Skeleton shapes:**

  | Screen | Skeleton |
  |---|---|
  | Home | as designed (title, 3 tiles, a list card) |
  | Items and Alerts | title plus 6 list rows |
  | Item detail | header, image block, two cards |
  | Settings | three cards |

### Error

- **Failure type:** repositories throw one small failure type with stable codes: **`offline`, `permission`, `not-found`, `unknown`**. "Error code: [CODE]" shows that code.
- **"↻ Try again"** reloads. There's no retry limit, and the button shows a spinner while it runs.
- **"Contact support":**
  - on web, it goes to `/contact` with Topic set to Support and the message prefilled with "Error code: X";
  - on native, it opens that same URL on the website in the browser. This adds the **`url_launcher`** dependency, and the site URL goes in the existing downloads and social config file.
- **Errors from actions** (save, delete, mark read) show as a snackbar, never the full Error state.
- **A failed reload with data on screen** keeps the data and shows a snackbar.

### Offline

- **Detection is deferred to the Firestore effort.** There's no connectivity package in v1.
- The Offline state shows only when a load fails with code `offline` and there's no data yet. It has the "↻ Try again" button only.
- The "cached list plus offline banner" pattern is also deferred.
- With the fakes, Offline is only ever seen in tests or through the debug switch below.

### Debug switch for the fakes

The fake repositories read two `--dart-define` flags, ignored in release builds:
- **`FAKE_LATENCY_MS`** (default 0) adds a delay before each load;
- **`FAKE_FAILURE=offline|unknown|permission`** makes each load fail with that code.

So every state can be seen in a real run, and Codex can check each one by hand. Tests override the repositories directly.
