# Edit profile

Type: prototype
Status: resolved
Blocked by:

## Question

Settings has an "Edit profile" button, but there's no design for the screen it opens. Sketch it (ASCII) from `DESIGN.md` components and the onboarding Profile step (`.refs/design/*/onboarding/*/… Profile.png`):
- which fields can be edited (`displayName` and `role` from the user record, per [Firestore data model](08-firestore-data-model.md)), and whether email or password show here (email is read-only and comes from Auth; password reset uses Firebase's hosted page, per [Real email sign-in flow](01-real-email-sign-in-flow.md));
- whether it reuses the Profile step's body widget;
- how it opens on each layout (a full-screen page, the detail pane, or a dialog), and its route, if it has one;
- validation, save and cancel, following [Item create and edit form](11-item-create-edit-form.md) for consistency.

## Answer

Resolved on 2026-10-19 with an ASCII prototype (no code): [edit-profile.md](../prototypes/edit-profile.md).

### What it shows

| Row | Behaviour |
|---|---|
| **Your name** | optional, ≤ 50 characters. If it's empty, the part of the email before the @ is shown. |
| **Role** | the three option cards from onboarding; one is always selected. |
| **Email** | read-only. |
| **"Change password"** | a text button, **only for users who signed in with email**. It sends Firebase's password-reset email (the hosted page) and shows "We've sent a reset link to <email>". The fake only shows that message. |

There's no photo upload.

### Sign-in method

The session records the **sign-in method** (email, Google or Apple), and the fake records it too. This is what hides "Change password" for Google and Apple users.

### Shared widget

The name field and the role cards are one `ProfileFields` widget, used by both the onboarding Profile step and Edit profile. Each screen supplies its own header and buttons.

### How it opens

- **Route:** `/app/settings/profile`, opened from Settings → "Edit profile".
- **Mobile and tablet:** a full-screen page with ✕ and Save; the bottom bar is hidden.
- **Desktop and web:** a page in the content column, at most 640 wide, with "← Settings" and the navigation still visible. A dialog was rejected.

### Save and cancel (same as the item form)

- Save stays disabled until something changes.
- Saving writes `displayName` and `role`, goes back to Settings and shows "Profile saved". The new name shows straight away on the Settings card, the Home greeting and the avatar.
- Leaving with unsaved changes asks "Discard changes?" (Keep editing / Discard).
- If saving fails, the form keeps what was typed and a snackbar says "Couldn't save. Try again."
