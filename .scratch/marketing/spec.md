# Spec: marketing

**Status:** ready-for-agent
**Source:** the wayfinder map `.scratch/stencil-v1/map.md`; decisions point to `.scratch/stencil-v1/issues/` by ticket number. Designs: `.refs/design/web/marketing/{light,dark}/` (13 pages, desktop width only).
**Order:** spec 4 of 5 (Foundation → CI/CD → Onboarding → **marketing** → app screens).

## Assumes

**Foundation**, **CI/CD** and **Onboarding** are done:
- **Placeholders to replace:** every marketing route (`/`, `/features`, `/whats-new`, `/about`, `/articles`, `/premium`, `/reviews`, `/press`, `/changelog`, `/contact`, `/privacy`, `/terms`, `/support`, `/delete-data`), with redirects that keep marketing web-only.
- **Shared pieces:** theme, l10n for 10 languages, the shared widget kit (cards, chips, filter chips, buttons, text fields, image placeholder, state views), the language button, layout selection (web layout ≥ 600, mobile layout below).
- **The session.**
- **The downloads and social config file:** site URL, four store URLs, social links.
- **Data:** the fake `ContactRepository`, and the app-wide delete-account action.
- **Real pages** at `/login`, `/signup` and `/onboarding`.
- **Deploys:** CI deploys `build/web` to Netlify, with the SPA rewrite.

## Problem Statement

A visitor who finds stencil's website has nothing to read: every marketing route is a placeholder. A product built from stencil needs:
- a public site that explains the product;
- pricing, reviews, press coverage, articles and release notes;
- help and contact options;
- the legal pages app stores require (privacy, terms, support, data deletion);
- clear ways to sign up, sign in or download the app.

It must work on a phone browser as well as a desktop, in 10 languages, and be easy for the product owner to fill with real content without touching layout code.

## Solution

Fourteen web pages, one per marketing route, plus an article page at `/articles/<slug>`. They're built from the 13 designs and share one **marketing frame**:
- a top bar with the logo, app name, five nav links, and "Sign in" / "Get started" (or "Open app" when signed in);
- a footer with four link columns, downloads and the language button.

At phone width the top bar collapses into a menu drawer and every section stacks.

**Where the content comes from:**
- **Page copy:** the translation files, so it's in all 10 languages.
- **Long-form content** (articles, release notes, changelog, FAQs, reviews, press, pricing, team, legal text): bundled data files, read through a `MarketingContentRepository`.
- **Links:** download, social and press-kit links come from the config file, and each one is hidden while its URL is empty.

**What visitors can do:**
- send a message from Contact Us (saved through the fake repository; nothing is emailed);
- subscribe to the newsletter (saved, nothing sent);
- search the FAQs;
- filter articles and reviews;
- switch pricing between monthly and yearly;
- delete their account from `/delete-data` when signed in.

## User Stories

1. As a visitor, I want the Home page to tell me in one line what the app does and for whom, so that I know in seconds whether it's for me.
2. As a visitor, I want "Get started free" and "See features" on Home, so that I can either sign up or learn more.
3. As a visitor on a phone, I want "Get it on iOS" and "Get it on Android" buttons on Home, so that I can install the app directly.
4. As a product owner, I want any store button whose URL isn't set yet to be hidden, so that visitors never hit a dead link.
5. As a visitor, I want an "As seen in" strip of press names, so that the product feels credible.
6. As a visitor, I want three feature highlights and two feature deep-dives on Home, each "Learn more" going to Features, so that I can explore further.
7. As a visitor, I want a stats band and three reviews on Home, so that I see social proof.
8. As a visitor, I want a closing "Ready to get started?" band with the same two buttons on Home, Features, Premium, Reviews and About Us, so that I can act wherever I finish reading.
9. As a visitor, I want a top bar on every page with Home, Features, What's new, About Us and Articles, with the current page highlighted, so that I always know where I am.
10. As a signed-out visitor, I want "Sign in" and "Get started" in the top bar, so that I can get into the app from anywhere.
11. As a signed-in visitor, I want a single "Open app" button instead, so that I go straight back to my data.
12. As a visitor on a phone, I want the top bar to collapse into a menu button that opens a drawer with every link, so that navigation fits a small screen.
13. As a visitor, I want a footer on every page with Our app, Resources, Connect and Downloads columns, the app description, the language button and a copyright line, so that every page is one click away.
14. As a visitor, I want social links that aren't set yet hidden from the footer and Contact Us, so that I'm never sent nowhere.
15. As a visitor, I want to switch the whole site into one of 10 languages from the footer or the drawer, so that I can read it in my own language.
16. As a visitor, I want each browser tab titled "<Page> · <app name>", so that my tabs and history make sense.
17. As a visitor, I want the Features page to show six feature cards and two deep-dives, so that I understand everything the app does.
18. As a visitor, I want What's new to show the latest releases with version, date, headline and summary, alternating left and right with an image, so that I see the product moving.
19. As a visitor, I want "Read the full notes" to open the Changelog at that version, so that I can read every detail.
20. As a visitor, I want the Changelog to list every version, newest first, with its date and each change tagged Added, Improved or Fixed, so that I can scan what changed.
21. As a visitor, I want About Us to show the mission, our story, three values and the team, so that I know who's behind the product.
22. As a visitor, I want Articles to show a featured article and then a grid of article cards, so that I can find something to read.
23. As a visitor, I want to filter articles by category with chips, so that I see only what interests me.
24. As a visitor, I want articles paged 6 at a time with Previous, page numbers and Next, so that the page stays short.
25. As a visitor, I want the page and category kept in the URL, so that I can share or bookmark a filtered page and browser back works.
26. As a visitor, I want to open an article and read it on its own page, with a link back to Articles, so that I can read in comfort.
27. As a visitor who follows a broken article link, I want to land on Articles, not a blank page.
28. As a visitor, I want to subscribe to the newsletter from Articles or What's new with my email, and be told "Thanks, you're subscribed.", so that I know it worked.
29. As a visitor who types a bad email, I want "Enter a valid email.", so that I can fix it.
30. As a visitor, I want Premium to show Free, Premium and Team plans, with Premium marked "Most popular", so that I can compare quickly.
31. As a visitor, I want a Monthly / Yearly switch that changes every price, so that I can see what I'd save.
32. As a visitor, I want every "Choose" button to take me to sign-up, so that I can start straight away.
33. As a visitor, I want a "Compare plans" table and pricing questions I can expand, so that I understand the differences.
34. As a visitor, I want Reviews to show the average rating, the number of reviews and a bar for each star level, so that I see the overall picture.
35. As a visitor, I want to filter reviews by platform (All, iOS, Android, macOS, Windows), so that I see reviews for my device.
36. As a journalist, I want Press to offer the logo pack, screenshots and brand guidelines, so that I can write about the product.
37. As a journalist, I want an "In the news" list where each item opens the article on the publication's site, so that I can see existing coverage.
38. As a journalist, I want a press enquiries email and a "Contact us" button, so that I can reach the team.
39. As a product owner, I want press-kit buttons whose URLs aren't set yet hidden, so that nothing breaks before I upload the files.
40. As a visitor needing help, I want the Support page to let me search the FAQs as I type, so that I find answers fast.
41. As a visitor, I want topic cards (Getting started, Account, Notifications, Privacy) that filter the FAQs, and a second tap to show all again, so that I can browse by topic.
42. As a visitor, I want the FAQs to open and close one at a time, so that the page stays readable.
43. As a visitor whose search finds nothing, I want "No answers match" and the "Still need help?" card, so that I know where to go next.
44. As a visitor, I want a Contact Us form with my name, email, a topic (General, Support, Billing, Press, Other) and a message, so that I can reach the team.
45. As a visitor, I want clear errors when a contact field is missing or my email is invalid, so that I can fix them before sending.
46. As a visitor, I want "Thanks, we'll be in touch." after sending, with the form cleared, so that I know it worked.
47. As an app user who hit an error, I want "Contact support" to open Contact Us with the topic set to Support and the error code already in the message, so that I don't have to explain.
48. As a signed-in visitor, I want my message linked to my account, so that support knows who I am.
49. As a visitor, I want the email, support and office contact cards and the "Follow us" links on Contact Us, so that I have other ways to reach the team.
50. As a visitor, I want the Privacy Policy and Terms pages to show the last-updated date, an "On this page" list and numbered sections, so that I can find the part I need.
51. As a visitor, I want the "On this page" links to scroll to their section, so that I don't have to scroll through legal text.
52. As an app store reviewer, I want `/privacy`, `/terms`, `/support` and `/delete-data` to be public pages, so that the store listing requirements are met.
53. As a signed-in user who wants to leave, I want `/delete-data` to explain what's deleted and offer "Delete my account and data", with a confirmation, so that I can remove everything myself.
54. As a signed-out visitor on `/delete-data`, I want the instructions and a "Sign in to delete your account" link, so that I know how to do it.
55. As a user who deletes their account from `/delete-data`, I want to end up on the marketing Home with nothing left behind, so that it's really gone.
56. As a visitor on a phone, I want every multi-column section to stack into one column, so that nothing is squeezed.
57. As a screen-reader user, I want each page's heading announced, decorative images skipped, star ratings read as "5 out of 5 stars", and chips and accordions read with their state, so that I can use the site without sight.
58. As a keyboard user, I want to tab through the top bar, page and footer in order, open FAQs with Enter or Space, and close the drawer with Esc, so that I can use the site without a mouse.
59. As a visitor with large text, I want every page to work at 200% without clipping, so that I can read it.
60. As a product owner, I want all long-form content in data files and all page copy in translation files, so that I can replace the placeholders without editing layout code.

## Implementation Decisions

### Marketing frame

- **What it is:** a web-only frame that wraps every marketing page. It's separate from the app shells, and never shown on native, where the routes are already redirected by Foundation.
- **Top bar (web layout):**
  - logo, plus `app_name` from the identity constants (both go to `/`);
  - pill links: Home, Features, What's new, About Us, Articles (the current page uses the selected pill style);
  - on the right: a "Sign in" text button → `/login` and a filled "Get started" → `/signup`. When the session is signed in, these become one filled "Open app" → `/app`.
- **Wording:** the design's "Log in" becomes **"Sign in"** (Login, signup and onboarding routes, 02).
- **Phone width (mobile layout):** the top bar shows the logo and app name plus a menu icon button ("Menu"). It opens a drawer with:
  - the five nav links;
  - the same Sign in / Get started (or Open app) buttons;
  - the language button.

  Esc or tapping outside closes it. Every multi-column section stacks into one column, and the footer columns stack.
- **Footer:**
  - **left:** the logo, app name, a one-line placeholder description, and the labelled language button;
  - **Our app:** Sign in (`/login`), Get started (`/signup`), Open the app (`/app`), Premium, Reviews, Press;
  - **Resources:** Support & FAQ, Terms & Conditions, Privacy Policy, Changelog;
  - **Connect:** YouTube, Instagram, TikTok, Twitter (each from the config file, opening in a new tab, hidden when empty), Contact Us;
  - **Downloads:** iOS App, Android App, macOS App, Windows App (each from the config file, hidden when empty; macOS and Windows decided in macOS and Windows distribution, 18);
  - **bottom row:** "© <current year> <app name>. All rights reserved." and Terms · Privacy · Contact.
- **Content width:** max 1120, centred. Bands with a Surface container background run full width with their content inside the 1120 column.
- **Tab titles:** each route sets the browser tab title to "<Page title> · <app name>" (`/` uses just the app name).

### Content sources

- **`MarketingContentRepository`:** an abstract interface plus one implementation that reads **bundled data files** (JSON assets). It's provided by a keep-alive provider. Each method returns typed, immutable models.
- **What it holds:**

  | Content | Shape |
  |---|---|
  | **articles** | slug, title, excerpt, category, author name, date, read minutes, featured flag, body paragraphs |
  | **article categories** | the list behind the chips |
  | **releases** (What's new) | version, date, headline, summary |
  | **changelog** | version, date, entries each tagged added, improved or fixed |
  | **FAQs** | question, answer, topic (getting-started, account, notifications, privacy) plus a separate pricing-FAQ list |
  | **pricing** | three plans, each with name, monthly price, yearly price, features, "most popular" flag; plus the compare-plans rows |
  | **reviews** | quote, name, role or location, stars 1–5, platform |
  | **press** | publication, date, headline, external URL; plus "As seen in" names |
  | **team** | name, role |
  | **legal documents** | privacy and terms, each with last-updated date and numbered sections (title, paragraphs) |
  | **stats** | value, label (Home band) |

- **Placeholder content:** bundled in bracketed form like the designs. The data files are **English only in v1**. The repository looks for a file for the current language first and falls back to English, so a product can add translations later without code changes.
- **Page copy** (headings, eyebrows, intro lines, buttons, form labels, errors, empty messages) goes in all 10 ARB files: English, plus machine-drafted translations marked for review.
- **No CMS** (charting decision).
- **The config file** (from Foundation) supplies:
  - the four store URLs and four social URLs;
  - three press-kit URLs, added by this spec (logo pack, screenshots, brand guidelines);
  - three contact addresses, added by this spec (hello email, support email, office address).

  Empty values hide their link, card or button.

### Pages

| Route | Contents and behaviour |
|---|---|
| `/` Home | "New · version <latest release>" eyebrow; headline, two sentences; "Get started free" → `/signup`; "See features" → `/features`; "Get it on iOS / Android" outlined buttons from config (hidden when empty); hero image placeholder. "As seen in" press names. Features band: 3 cards. Two alternating feature deep-dives with 3 checked points and "Learn more →" `/features`. Stats band (3 stats). Reviews: the first 3 reviews. Closing CTA band. |
| `/features` | Eyebrow, headline, intro, the two CTA buttons; 6 feature cards (3×2, stacking on phone); two "Deep dive" sections on a Surface container band; closing CTA band. |
| `/whats-new` | Eyebrow, headline, intro; the releases, newest first, alternating image left and right, each with "New" chip, "Version X · date", headline, summary and "Read the full notes →" → `/changelog#v<version>`; the newsletter band ("Get updates in your inbox"). |
| `/changelog` | Eyebrow, headline, intro; one row per version (version and date on the left; tagged entries on the right: Added = Primary container, Improved = Gain container, Fixed = Tertiary container; always labelled); dividers. Each version has an anchor, and a `#v<version>` fragment scrolls to it on load. |
| `/about` | Eyebrow, headline, mission; "Our story" with image; "What we believe" with 3 value cards on a band; "Team" grid of 4 (image placeholder, name, role; 2 columns on phone); "Join us on the journey" CTA band. |
| `/articles` | Eyebrow, headline, intro; the featured article (image, "Featured" chip, read time, title, excerpt, author · date); category filter chips (All plus categories); a 3-column grid of 6 cards per page (image, category chip, read time, title, excerpt, author · date; 1 column on phone); pagination (Previous, page numbers, Next; disabled at the ends); newsletter band ("Never miss an article"). **The page and category are read from and written to the URL** (`?page=2&category=<slug>`). Changing the category resets to page 1. An invalid page falls back to page 1. The featured article shows only on page 1 with All selected. |
| `/articles/<slug>` | **Added; there's no design.** A reading layout, max 720 wide: "← Articles" link, category chip, title, author · date · read time, image placeholder, body paragraphs, then the newsletter band. An unknown slug redirects to `/articles`. Tab title is the article title. |
| `/premium` | Eyebrow, headline, intro; Monthly / "Yearly · save N%" segmented control (N computed from the data); 3 plan cards (Premium is filled Primary container with a "Most popular" Accent-fill tag); every "Choose <plan>" → `/signup` (charting decision); "Compare plans" table (✓ or "—", read as "Included" / "Not included"; scrolls horizontally on phone); "Pricing questions" accordion; closing CTA band. |
| `/reviews` | Eyebrow, headline, intro; the summary card (average to one decimal, 5 stars, "Based on N reviews", a bar and percentage for each star level, **calculated from the bundled reviews**); platform filter chips All · iOS · Android · macOS · Windows (filters the cards; the summary stays for All); 3-column review cards; closing CTA band. |
| `/press` | Eyebrow, headline, intro; "Press kit" band with Logo pack · Screenshots · Brand guidelines download buttons (config URLs, hidden when empty, open in a new tab); "In the news" list (publication · date, headline, ↗ opens the external URL in a new tab); "Press enquiries" card with the press email and "Contact us" → `/contact?topic=press`. |
| `/support` | Eyebrow, "How can we help?", intro; a search field; 4 topic cards; "Frequently asked questions" accordion on a band; the "Still need help?" card with "Contact us" → `/contact?topic=support`. **Search** filters the FAQ list on the device as the user types (case-insensitive, question and answer). **A topic card** filters by topic; tapping it again clears the filter; the selected card shows the selected style and check. Search and topic combine. With no results: "No answers match" and the accordion is hidden. Only one FAQ is open at a time; the first is open on load. |
| `/contact` | Eyebrow, "Get in touch", reply-time line; the form card and side cards (Email, Support, Office from config, hidden when empty; "Follow us" list of social links). **The form:** Your name (required), Email address (required, valid), Topic (dropdown: General, Support, Billing, Press, Other; required), Message (required, multi-line), "Send message". **Query parameters:** `?topic=<topic>` presets the topic; `&code=<code>` prefills the message with "Error code: <code>" followed by a blank line (from Empty, error, loading and offline states, 13). **Validation:** errors show after the first Send, then live ("Enter your name.", "Enter a valid email.", "Choose a topic.", "Write a message."). **Sending:** calls `ContactRepository.create` with `uid` when signed in. The button shows progress. **Success:** "Thanks, we'll be in touch." and the form clears. **Failure:** an inline error under the button, "Couldn't send your message. Try again.", and the form keeps its contents. |
| `/privacy`, `/terms` | "Legal" eyebrow, title, "Last updated <date>"; a sticky "On this page" card listing numbered section titles (each scrolls to its section; on phone the card sits above the text and isn't sticky); numbered sections with paragraphs. Content from the legal documents in the repository. |
| `/delete-data` | **Added; there's no design.** The legal layout without "On this page": title "Delete your data", placeholder paragraphs (what's deleted: items, activity, alerts, profile; what's kept: contact messages; how long it takes: immediately), and the support email. **Signed in:** an error-coloured "Delete my account and data" button. It opens a confirmation dialog ("Delete your account? This can't be undone." Cancel · **Delete**, in error colour), then runs Foundation's delete-account action. When that action asks for a recent sign-in, the page shows "Please sign in again to continue." with a link to `/login`. On success the action takes the user to `/`. **Signed out:** a "Sign in to delete your account" link → `/login`. |

### Newsletter

- **`NewsletterRepository`:** an abstract interface plus an in-memory fake, provided by a keep-alive provider. Its only method is `subscribe(email)`. It's create-only and sends nothing, the same as contact messages. When Firestore arrives, it maps to a create-only `newsletterSubscriptions` collection with the same rules principle as `contactMessages` (Firestore data model and security rules, 08).
- **The band** (Articles, What's new, article page): an email field plus "Subscribe".
  - **Validation:** a basic email check ("Enter a valid email.").
  - **Success:** "Thanks, you're subscribed." replaces the field and button.
  - **Failure:** an inline "Couldn't subscribe. Try again."
  - **Duplicates:** subscribing the same email twice still shows success.

### Shared marketing pieces

Built once in the marketing feature folder and used across pages: section header (eyebrow chip, heading, intro), CTA band, feature card, deep-dive row (image side alternates), review card (star row read as "N out of 5 stars"), FAQ accordion, newsletter band, legal document layout. They take values from their page and don't read providers.

### Accessibility

From Accessibility rules (16).
- **Headings:** each page heading is the first heading. Section headings are headings too.
- **Hidden from screen readers:** image placeholders and decorative illustrations.
- **Chips** (filter, topic) and the pricing switch expose their selected state.
- **Accordions** expose expanded or collapsed state and toggle with Enter or Space.
- **External links** say they open in a new tab.
- **The drawer** traps focus and closes with Esc.
- **Text scale:** every page works at 2.0. Grids drop columns as needed; the compare table scrolls horizontally rather than clipping.
- **Contrast:** the "Most popular" tag uses text that passes contrast on Accent fill. The tag isn't covered by the palette check, so this needs verifying.

## Testing Decisions

- **What a good test is:** it opens a route through the app's root widget on the web platform and checks what a visitor sees and can do. It doesn't test layout internals.
- **Seam 1, the root widget on web** (Foundation's seam 1, with the platform overridden to web), at desktop width and at phone width, with overrides for the content repository (a small test data set), `ContactRepository`, `NewsletterRepository`, the session, and the config. It covers:
  - every route rendering its heading and key sections; the tab titles;
  - the top bar and footer links going to the right routes; "Open app" replacing both buttons when signed in; empty store, social, press-kit and contact values hiding their elements;
  - the phone-width drawer opening, navigating and closing with Esc;
  - article filtering, pagination, URL parameters (deep-linking to `?page=2&category=x`), the featured article's visibility rule, `/articles/<slug>`, and the unknown-slug redirect;
  - `/changelog#v1.1.0` scrolling to that version; "Read the full notes" linking there;
  - the Premium switch changing prices and the save percentage; "Choose" going to `/signup`;
  - the Reviews summary maths and the platform filter;
  - Support search, topic filter, the combination, and "No answers match";
  - the Contact form's validation, the `topic` and `code` prefill, a successful send (repository received the message, with `uid` when signed in), and the failure message;
  - newsletter validation, success and failure;
  - `/delete-data` when signed out (link) and signed in (confirm → delete action → `/`; recent-sign-in outcome shows the message);
  - each page in light and dark, `meetsGuideline` (tap targets, labels, contrast), and text scale 2.0 at phone width.
- **Seam 2, the repository contracts:**
  - **`MarketingContentRepository` against the real bundled files:** every file parses, every article has a unique slug and a known category, every changelog entry has a valid tag, every FAQ has a known topic, pricing has exactly 3 plans with one "most popular", and the language fallback returns English for a language with no file.
  - **`NewsletterRepository` (fake):** subscribe is recorded, and a duplicate is accepted.
- **Prior art:** Foundation's root-widget and contract-test helpers, and Onboarding's flow tests.

## Out of Scope

- **Sending things:** sending email from Contact Us or the newsletter, and any real newsletter service.
- **A CMS,** remote content, translated long-form content (the data files are English only in v1; the fallback is in place), and SEO extras such as sitemaps, meta descriptions and server-side rendering.
- **Native marketing.** Native platforms open the website in the browser for legal links (Foundation and Onboarding).
- **Real purchases and RevenueCat.** Premium's buttons only go to sign-up.
- **Search across the whole site.** Only the Support page's FAQ search exists.
- **Hosting the press-kit files.** They're linked from the config file.

## Further Notes

- **Differences from the designs, on purpose:**
  - "Log in" becomes "Sign in"; signed-in visitors see "Open app";
  - the phone-width layout and drawer are added (no design);
  - `/articles/<slug>` and `/delete-data` are added (no design);
  - press-kit, store and social links are hidden when empty.
- **Details filled in while writing this spec** (not explicitly grilled; reverse them in review if wrong):
  - the browser tab titles;
  - long-form data files English-only with a fallback to English;
  - the press-kit and contact addresses added to the config file;
  - the featured article shown only on page 1 with All selected;
  - the first FAQ open on load;
  - the newsletter accepting duplicates silently;
  - the `/delete-data` placeholder copy;
  - Contact's `?topic=press` link from Press.
- **Suggested `/to-tickets` slices:**
  1. the marketing frame (top bar, drawer, footer, tab titles) plus `MarketingContentRepository` and its data files;
  2. Home and Features;
  3. What's new and Changelog;
  4. About Us;
  5. Articles and the article page, plus `NewsletterRepository` and the band;
  6. Premium and Reviews;
  7. Press and Support;
  8. Contact Us;
  9. Privacy, Terms and Delete data.
