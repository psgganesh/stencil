# Firestore data model and security rules

Type: grilling
Status: resolved
Blocked by: 05

## Question

Decide on the collections and document shapes that both the fake and the Firestore repositories implement:
- the user profile (filled in by onboarding Profile and Preferences). It also holds whether onboarding is finished, so a user who's already been onboarded skips onboarding on a new device (see [Real email sign-in flow](01-real-email-sign-in-flow.md));
- **items** (the fields come from the Item detail and Items designs: name, status, owner, category, dates, activity);
- **alerts**;
- notification settings;
- Contact Us messages.

Also decide:
- **Ownership:** whose items does a user see? Only their own, or is there sharing?
- **Alerts:** where do they come from, given there's no backend? Seeded? Generated on the device when an item changes?
- **Activity history:** stored as a subcollection or as an array?
- **Delete account:** what does it delete?
- **Security rules:** the outline, so Codex can write `firestore.rules`.

> Context from [Device layouts](03-device-layouts.md): every Items design shows an **Archived** status chip and filter, but `GLOSSARY.md` says an item is Active or Draft. Decide whether `status` includes Archived, and update the glossary.

## Answer

Resolved by grilling on 2026-10-19.

### Firestore comes later; v1 builds only the fakes

- **v1 builds only the in-memory fake repositories.** They're held by keep-alive Riverpod providers, so the data is "in Riverpod state" and is lost on restart. The Firestore repositories, `firestore.rules`, and error handling and persistence edge cases are **a separate effort after v1** (see the map's Out of scope). Views and view models are written against the repository interfaces, so adding Firestore later only swaps implementations.
- The shapes below are still the contract: the fakes implement them now, and Firestore stores them later. Paths are given in their Firestore form.

### Ownership

- **Each user's data is private to them, with no sharing.** Everything for a user lives under `users/{uid}/…`.
- **Owner** on an item is the creator's display name, copied onto the item when it's created.
- **Share** on Item detail opens the OS share sheet with the item's name and summary as text. It doesn't share data with other users.

### Shapes

**`users/{uid}`** — the user record
| field | notes |
|---|---|
| `displayName` | from the onboarding Profile step. When it's missing, the UI shows the part of the email before the @. |
| `role` | answer to "What best describes you?", one of 3 placeholder options |
| `notifications` | `{push, emailUpdates, weeklySummary}` booleans. What they actually do is decided by [Permissions step and notification toggles](10-permissions-and-notifications.md). |
| `onboardingFinishedAt` | null until Done |
| `createdAt` | |

The email comes from Auth and isn't copied into the record. **Theme mode and language are device-only** (`shared_preferences`) and never synced.

**`users/{uid}/items/{itemId}`** — item
| field | notes |
|---|---|
| `name` | required |
| `summary` | one sentence. Shown as "[Short description]" on list rows and under the title on Item detail. |
| `description` | long text, optional |
| `category` | one of a fixed list of placeholder categories defined in app code |
| `status` | `active` · `draft` · `archived` |
| `ownerName` | copied in at creation |
| `createdAt`, `updatedAt` | |

The Item detail image is a **static placeholder**: nothing is uploaded and there's no Storage. The list avatar uses the item name's first letter. Archived items show under "All" and the Archived filter, and editing can change the status back.

**`users/{uid}/items/{itemId}/activity/{id}`** — activity entry: `{type: created|edited|statusChanged, at, byName}`. The app writes one automatically, in the same batch or step as the item change. Item detail shows the latest 3, and there's no "see all" in v1.

**`users/{uid}/alerts/{alertId}`** — alert: `{kind: info|success|warning, title, body, createdAt, read}`. Kind picks the icon, and "New" means `read == false`.
- **Where alerts come from:** 3 welcome alerts (one of each kind, placeholder copy) are seeded when onboarding is finished. An alert is generated on the device whenever one of the user's items changes status.
- **Screen:** titled **"Alerts"**, not the design's "Notifications". The filters are **All · Unread**; the design's Mentions filter is dropped because nothing in a single-user app can mention you. "Mark all as read" sets every alert to read.

**`contactMessages/{id}`** — Contact Us: `{name, email, topic, message, createdAt, uid?}`. `uid` is filled in only when the sender is signed in. Topic comes from a fixed list: General, Support, Billing, Press, Other. In v1 the fake keeps messages in memory and sends no email.

### Fake behaviour across restarts

- **The session persists:** the fake saves "signed in as <email>" in `shared_preferences`, so a restart keeps you signed in, as Firebase does.
- **The data is reseeded:** on sign-in or startup, if the fake has no data for that user, it seeds **demo data**: 7 sample items matching the Items design (a mix of Active, Draft and Archived, each with a few activity entries) and the 3 welcome alerts. The display name and role are lost on restart, so the email-prefix fallback applies.
- Because of this, a user in the fake never sees an empty Items list unless they delete items. [Empty, error, loading and offline states](13-empty-error-loading-offline-states.md) should take that into account. Tests can override the repository with empty data.

### Delete account

Done on the client, with no Cloud Functions:
1. Delete everything under `users/{uid}`: items and their activity, alerts, then the user record.
2. Delete the Auth user. If the sign-in is too old (`requires-recent-login`), ask the user to sign in again, then retry.
3. Clear local preferences (including the fake session), then go to `/login` on native or the marketing Home on web.

Contact messages are kept. The fake wipes its in-memory data the same way. The `/delete-data` button uses the same flow.

### Security rules (principle only; the full rules come with the Firestore effort)

- `users/{uid}` and everything under it: read and write only when `request.auth.uid == uid`.
- `contactMessages`: anyone can create, including signed-out visitors. Nobody can read, update or delete from the client.
- Everything else is denied.
- Field validation, size limits and App Check are deferred to the Firestore effort.

### Glossary

**item** now has the statuses Active, Draft and Archived. **alert** now says where alerts come from and names the screen "Alerts". **role** has been added.
