# stencil

A cross-platform Flutter boilerplate: one codebase that ships a public website and a signed-in product on web, macOS, Windows, iOS and Android.

## Language

**marketing**:
The public, signed-out pages that describe and promote the product (Home, Features, Premium, Articles, legal pages and so on), reached through the top bar and footer. Web only.
_Avoid_: website, landing site, web (ambiguous), Marketing site

**app**:
The product itself, on every platform: onboarding, sign-in and the signed-in screens.
_Avoid_: main app, application, web app, App

**user**:
A person who has signed in to the app. There is one user per email address, whether they sign in with a password, Google or Apple.
_Avoid_: account, member, profile (when meaning the person)

**sign-in method**:
How the user signed in this time: email (with a password), Google or Apple. Only email users have a password to change.
_Avoid_: provider, login type, auth method

**onboarding**:
The flow a new user goes through once, in this order: Welcome (native only), Language, SignIn, Profile, Preferences, Permissions, Done. Its **steps** are Language through Permissions, labelled "Step 1 of 5" to "Step 5 of 5". It is **finished** when the user taps Done.
_Avoid_: signup flow, setup wizard, tutorial

**item**:
The sample record the app is built around (a name, a summary, a description, a status of Active, Draft or Archived, an owner, a category, dates and an activity history). Each user's items are their own; nothing is shared between users. A real product renames or replaces it.
_Avoid_: entry, record, entity

**alert**:
A message shown to the signed-in user in the app's Alerts feed. Alerts are either welcome messages given when onboarding is finished, or raised when one of the user's items changes status. Each alert is unread until the user reads it.
_Avoid_: notification (when meaning the feed), inbox item

**role**:
The user's answer to "What best describes you?" in the onboarding Profile step.
_Avoid_: persona, user type, use case

**notification**:
A delivery channel that sends alerts outside the app (push or email), along with the user's settings for it. The user's on/off choice for a channel is a **preference**. It is separate from the device's **permission** to show notifications, which the OS grants or denies and which push needs as well.
_Avoid_: alert (when meaning the channel), push setting

**preference**:
A setting the user chooses about how the app looks or reaches them: appearance (light, dark or system), language, and each notification channel on or off. Appearance and language are kept on the device; notification preferences are kept on the user record.
_Avoid_: option, setting (when meaning one of these), config

**app identity**:
The product's name, its app ID (reverse DNS) and its store identity values. They are defined in one place and applied to every platform, so renaming the boilerplate into a real product is a single edit.
_Avoid_: bundle ID (when meaning all of it), branding, app config
