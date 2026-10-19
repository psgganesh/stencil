# Prototype: Edit profile (ASCII)

A throwaway sketch for [Edit profile](../issues/14-edit-profile.md). It's based on the onboarding Profile step (`.refs/design/*/onboarding/*/… Profile.png`: "Your name" field, "WHAT BEST DESCRIBES YOU?" with 3 selectable option cards) and follows the conventions of [item-form.md](item-form.md). Confirmed on 2026-10-19: every rule below as written.

## 1. Fields

| Row | Control | Rule |
|---|---|---|
| Your name | outlined text field (the Profile step's) | optional, ≤ 50 chars after trimming; "Keep it under 50 characters." Empty is allowed: the UI falls back to the part of the email before the @ (already decided). |
| What best describes you? | the Profile step's 3 selectable option cards (radio) | **role**: one option is always selected, so there's no error |
| Email | read-only row: label + value, no field border | comes from Auth; can't be changed in v1 |
| Password | text button "Change password" | **email users only** (hidden for Google and Apple). Sends Firebase's password-reset email (the hosted page, as already decided), then shows the snackbar "We've sent a reset link to <email>". The fake only shows the snackbar. |

No avatar upload (there's no Storage). The avatar stays the person icon or initial.

**Shared widget:** the name field and the role cards are one `ProfileFields` widget, used by both the onboarding Profile step and Edit profile. Each screen supplies its own header and buttons.

## 2. Mobile and tablet: a full-screen page, bottom bar hidden

```
┌──────────────────────────────┐
│ [✕]  Edit profile    [Save]  │
│──────────────────────────────│
│ Your name                    │
│ [ Ada Lovelace             ] │
│                              │
│ WHAT BEST DESCRIBES YOU?     │
│ ┌──────────────────────────┐ │
│ │ (●) Option one           │ │  selected: Primary container + 2px border
│ │     Short description.   │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ( ) Option two           │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ( ) Option three         │ │
│ └──────────────────────────┘ │
│ ──────────────────────────── │
│ Email                        │
│ ada@example.com              │  read-only, On surface variant
│ Change password              │  text button (email users only)
└──────────────────────────────┘
```

## 3. Desktop and web: a page in the content column, with the shell still visible

Settings has no split, so there's no detail pane to reuse. The form is a page at max 640 wide, starting from the left of the 1120 column, with a "← Settings" back button like the wide Item detail.

```
┌────┬──────────────────────────────────────────────────────────┐
│rail│ ← Settings                          (🔍) [🌐 English]    │
│    │ Edit profile                                             │
│    │ ┌─ max 640 ───────────────────────┐                      │
│    │ │ Your name                       │                      │
│    │ │ [ Ada Lovelace                ] │                      │
│    │ │ WHAT BEST DESCRIBES YOU?        │                      │
│    │ │ [(●) Option one   ]             │                      │
│    │ │ [( ) Option two   ]             │                      │
│    │ │ [( ) Option three ]             │                      │
│    │ │ Email  ada@example.com          │                      │
│    │ │ Change password                 │                      │
│    │ │              ( Cancel ) [ Save ]│                      │
│    │ └─────────────────────────────────┘                      │
└────┴──────────────────────────────────────────────────────────┘
```

Alternative considered: a dialog over Settings. It was rejected for the same reasons as on the item form: a dialog makes browser back and refresh awkward, and the role cards need the height.

## 4. Route and behaviour

- **Route:** `/app/settings/profile`, opened by Settings → "Edit profile" (and nothing else in v1).
- **Save:** disabled until something changes. It writes `displayName` and `role` to the user record, goes back to Settings, and shows "Profile saved". The new name appears straight away on the Settings profile card, the Home greeting and the avatar initial.
- **Cancel, ✕ or back:** with unsaved changes, the "Discard changes?" dialog appears (Keep editing / Discard), the same as on the item form. Otherwise it goes straight back.
- **Save failure:** the form stays filled, with the snackbar "Couldn't save. Try again."
- **Fake on restart:** `displayName` and `role` are lost (already decided), so after a restart Edit profile opens with an empty name and the first role selected.
