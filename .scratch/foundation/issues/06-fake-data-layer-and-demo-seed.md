# 06: Fake data layer and demo seed

**What to build:** A signed-in user has realistic data straight away: 7 sample items with activity spread over the last 14 days, and 3 welcome alerts. Item changes record activity and raise alerts. A developer can add latency to every load, or make every load fail with a chosen failure code, using run flags that release builds ignore. The app detects whether Firebase is configured and uses the fakes either way in v1. The Home placeholder shows live item counts. See `../spec.md` → "Fake data layer", "Startup".

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] Each repository is an abstract interface with an in-memory fake, provided by a keep-alive provider and overridable in tests:
  - [ ] **`UserRepository`:** the user record with `displayName`, `role`, `notifications` (all false by default), `onboardingFinishedAt` and `createdAt`; watch and update.
  - [ ] **`ItemsRepository`:**
    - [ ] reads: watch the list; watch one item with its latest 3 activity entries;
    - [ ] create sets the owner and writes `created`;
    - [ ] update writes `edited`, plus `statusChanged` and a raised alert when the status changes;
    - [ ] delete removes the item and its activity;
    - [ ] a fixed list of 4 placeholder categories.
  - [ ] **`AlertsRepository`:** watch newest first, mark one read, mark all read, raise, and seed the 3 welcome alerts.
- [ ] **Demo seed:** on sign-in or startup with no data for the user: 7 items (Active, Draft and Archived mixed) with activity dated within the last 14 days, plus the 3 welcome alerts.
- [ ] **`AppFailure`:** one type with codes `offline`, `permission`, `not-found`, `unknown`.
- [ ] **Run flags:** `FAKE_LATENCY_MS` delays every fake load; `FAKE_FAILURE` makes every load fail with that code. Both are injectable for tests, and ignored in release builds.
- [ ] **Firebase detection:** a stub Firebase options file is committed. Startup tries the options and initialisation; any failure, or `USE_FAKES=true`, is recorded as "fakes". The fakes are used in both cases in v1.
- [ ] Startup wires the repository overrides into the `ProviderScope`.
- [ ] The Home placeholder shows live counts of Active, Draft and Archived items.
- [ ] **Contract suites (seam 2)**, through `ProviderContainer.test()` with retry off, one per repository interface:
  - [ ] the seed contents and dates;
  - [ ] activity entries on each change;
  - [ ] the alert raised on a status change;
  - [ ] mark read and mark all read;
  - [ ] the latency and failure injection.
- [ ] `dart format .`, `flutter analyze` and `flutter test` pass.
