# 08: State views and the async wrapper

**What to build:** Any screen that loads data shows nothing for 300 ms, then a skeleton in the shape of its content with a thin progress bar. When the data arrives it shows the content. A failed load shows the Error state (or Offline) with "Try again" and "Contact support". A failed reload keeps the content and shows a snackbar. The placeholder screens show every state when the `FAKE_*` flags are set. See `../spec.md` → "Shared widget kit" (skeleton, state views, async wrapper, Contact support, config file).

**Blocked by:** 06, 07

**Status:** ready-for-agent

- [ ] **State views** that replace only the content area (the shell and title stay):
  - [ ] **Empty:** configurable icon, title, body, optional filled and outlined buttons;
  - [ ] **Error:** fixed copy, "Error code: <code>", "Try again" and "Contact support";
  - [ ] **Offline:** fixed copy, "Try again" only;
  - [ ] **Placeholder:** icon, title, body, no buttons.
- [ ] **Skeleton** in four shapes (Home, List, Detail, Settings), with the 4 px progress bar. The shimmer is off under reduced motion.
- [ ] **Async content wrapper:**
  - [ ] first load: nothing for 300 ms, then the skeleton;
  - [ ] error with no data: Error, or Offline for the `offline` code;
  - [ ] data: the content;
  - [ ] reload with data: content plus the progress bar only;
  - [ ] failed reload with data: keeps the data and shows a snackbar.
- [ ] **Downloads and social config file:** holds the site URL, four empty store URLs and the social links. Foundation reads only the site URL.
- [ ] **"Contact support":** opens `/contact?topic=support&code=<code>`, in-app on web and the site URL in the browser (`url_launcher`) on native.
- [ ] Root-widget tests using repository overrides:
  - [ ] no skeleton before 300 ms, skeleton after;
  - [ ] the Error state with the code;
  - [ ] Offline;
  - [ ] Try again reloading;
  - [ ] reload keeping data plus a snackbar;
  - [ ] the Contact support target on web vs native;
  - [ ] guidelines in light and dark.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
