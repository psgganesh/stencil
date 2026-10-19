# Empty, error, loading and offline states

Type: grilling
Status: open
Blocked by: 08

## Question

The state designs are now in `.refs/design/<device>/states/` and described in `DESIGN.md` → States. Decide how they behave:

- **Which screens get which states.** For example, does Home show Empty when there are no items, or its own welcome version? Alerts and Item detail need their own empty and not-found copy. Should the Empty copy and buttons be set per screen?
- **Loading:** show the skeleton immediately or only after a short delay, and how its shape matches each screen.
- **Error:** what "Error code: [CODE]" contains (a repository error type? an id?), what "Contact support" opens (`/support`, or Contact Us with the code filled in), and whether there's a retry limit.
- **Offline:** how it is detected (Firestore's own cache and metadata, or a connectivity package, which is a new dependency) and when the full Offline screen replaces content versus a cached list with a banner. The Offline state has only a "Try again" button; the design's "View saved items" is dropped (decided 2026-10-19). Firestore's offline cache is on by default on native and off by default on web (see [Firebase support on each platform](05-firebase-platform-support.md)). With the fake repositories, is offline ever shown?
- **marketing and onboarding:** do they use these states, or only the app screens?

> Context from [Firestore data model and security rules](08-firestore-data-model.md): v1 runs only on the fakes, which reseed 7 demo items and 3 alerts whenever the user's data is empty. So Empty shows only after the user deletes items, or when a test overrides a repository. Firestore's offline behaviour comes later.
