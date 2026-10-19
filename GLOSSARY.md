# stencil

A cross-platform Flutter boilerplate: one codebase that ships a public website and a signed-in product on web, macOS, Windows, iOS and Android.

## Language

**marketing**:
The public, signed-out pages that describe and promote the product (Home, Features, Premium, Articles, legal pages and so on), reached through the top bar and footer. Web only.
_Avoid_: website, landing site, web (ambiguous), Marketing site

**app**:
The product itself, on every platform: onboarding, sign-in and the signed-in screens.
_Avoid_: main app, application, web app, App

**item**:
The sample record the app is built around (a name, a status of Active or Draft, an owner, a category, dates and an activity history). A real product renames or replaces it.
_Avoid_: entry, record, entity

**alert**:
A message shown to the signed-in user in the app's Alerts feed.
_Avoid_: notification (when meaning the feed), inbox item

**notification**:
A delivery channel that sends alerts outside the app (push or email), along with the user's settings for it.
_Avoid_: alert (when meaning the channel), push setting
