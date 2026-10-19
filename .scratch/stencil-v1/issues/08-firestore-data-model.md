# Firestore data model and security rules

Type: grilling
Status: open
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
