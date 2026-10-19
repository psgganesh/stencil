# What onboarding Preferences control

Type: grilling
Status: resolved
Blocked by:

## Question

The onboarding Preferences step (`.refs/design/*/onboarding/*/… Preferences.png`) asks for preferences, but nothing decides what they do. Decide:
- which options the step shows, and what each one changes in the app (for example the starting theme, which Home cards show, or the item category used by default), or whether they're placeholder answers that are only saved;
- where they're saved (the user record or the device), and whether Settings shows or edits them afterwards;
- how they relate to the Settings "Preferences" card (language and appearance), so the word **preference** means one thing (see `GLOSSARY.md` → notification).

## Answer

Resolved by grilling on 2026-10-19.

The Preferences step (step 4 of 5) is real, not placeholder. Every option in it changes the app, and all of them can be changed again later in Settings.

| Option | Default | When it's saved | Where it's kept | Where it's edited later |
|---|---|---|---|---|
| **Appearance** (Light / Dark / System) | System | **immediately**, and the theme changes live | the device (`shared_preferences`), through the same theme notifier as Settings | Settings → Preferences card |
| **Email updates** | off | held in memory, written at **Done** | the user record, `notifications.emailUpdates` | Settings → Notifications card |
| **Weekly summary** | off | held in memory, written at **Done** | the user record, `notifications.weeklySummary` | Settings → Notifications card |

- **The Push toggle is removed from this step.** This is a deliberate change from the design, for the Onboarding spec. Push is decided only by the Permissions step, as set in [Permissions step and notification toggles](10-permissions-and-notifications.md); that rule is unchanged. Settings still shows all three toggles (Push is hidden on Windows and Linux).
- **Language** at step 1 works like Appearance: it's applied and saved straight away, not at Done.
- The step has no placeholder options.

### Glossary

**preference** now means any setting the user chooses about how the app looks or reaches them: appearance, language, and each notification channel. Appearance and language are kept on the device; notification preferences are kept on the user record. The **notification** entry now uses the term.
