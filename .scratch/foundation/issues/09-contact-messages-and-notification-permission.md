# 09: Contact messages and notification permission

**What to build:** The app can save a contact message (nothing is sent). It can also report and request the notification permission correctly on every platform: not asked, granted, denied, on by default, or unavailable. It offers to open the OS settings where that's possible, and re-checks when the app comes back to the foreground. See `../spec.md` → "Fake data layer" (`ContactRepository`, `NotificationPermissionRepository`).

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] **`ContactRepository`** (interface + in-memory fake): create a message with name, email, topic (General, Support, Billing, Press, Other), message and optional uid.
- [ ] **`NotificationPermissionRepository`** (interface + an implementation on flutter_local_notifications + a fake for tests):
  - [ ] the status is derived from the capabilities kind, the plugin's check, and an "asked once" flag in preferences;
  - [ ] request shows the OS prompt (on web, only from a user tap);
  - [ ] open settings opens the app's OS settings on Android, iOS and macOS;
  - [ ] the status is re-checked on app resume;
  - [ ] the browser's `default` result counts as denied.
- [ ] **Status mapping:**

  | Platform | Status |
  |---|---|
  | Windows, Linux, Android ≤ 12 | on by default |
  | web without the Notification API | unavailable |
  | iOS / macOS, before asking | not asked |
  | iOS / macOS, after a refusal | denied |

- [ ] Contract suites (seam 2):
  - [ ] the contact message is recorded with and without uid;
  - [ ] the permission status for each capabilities kind and plugin result, including the "asked once" flag;
  - [ ] request and open-settings calls against a faked plugin boundary.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
