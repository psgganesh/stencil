# Handoff: Foundation → Codex

**Date:** 2026-10-19
**From:** Claude Code (planning)
**To:** Codex (implementation)

## What this is

stencil is a cross-platform Flutter boilerplate: a public marketing site on web, plus a signed-in app on web, macOS, Windows, iOS and Android. Planning is finished. The work is split into five specs, and Codex builds them one at a time, in this order:

1. **Foundation** ← you are here
2. CI/CD (`.scratch/ci-cd/spec.md`)
3. Onboarding (`.scratch/onboarding/spec.md`)
4. marketing (`.scratch/marketing/spec.md`)
5. app screens (`.scratch/app-screens/spec.md`)

Only Foundation has tickets. The other specs get their tickets from Claude just before their own hand-off, so **don't start them**.

## Read first

1. **`AGENTS.md` → "Implementation workflow"**: how to pick, implement, verify and close a ticket. Follow it exactly: one commit per ticket, message `<NN>: <ticket title>`, and no pushing.
2. **`AGENTS.md` → "Architecture"**: MVVM with Riverpod 3 only, no codegen, the keep-alive and auto-dispose rules, retry off, `SharedPreferencesWithCache`, `PlatformCapabilities`, routing.
3. **`.scratch/foundation/spec.md`**: the Foundation spec. Its "Testing Decisions" section defines the three test seams.
4. **`GLOSSARY.md`**: domain terms (item, alert, notification, preference, sign-in method, app identity, …). Use these words in code and copy.
5. **`DESIGN.md`**: colours, type, components and states, including the dark-mode filled-button exception.

Background, only when a ticket points you there:
- **Decision history:** `.scratch/stencil-v1/map.md` lists every decision; `.scratch/stencil-v1/issues/NN-*.md` holds each one in detail.
- **Prototypes and research:** sketches in `.scratch/stencil-v1/prototypes/`, findings in `.scratch/stencil-v1/research/`.
- **Designs:** `.refs/design/`.

The `.scratch/stencil-v1/` files are **wayfinder planning tickets**. Leave them alone.

## Tickets ready, in order

All 10 are in `.scratch/foundation/issues/`, each marked `**Status:** ready-for-agent`.

| # | Ticket | Blocked by |
|---|---|---|
| 01 | Packages, platform settings and app identity | none (**start here**) |
| 02 | Theme, fonts and appearance | 01 |
| 03 | Translations and language | 02 |
| 04 | Routing, session and fake sign-in | 03 |
| 05 | Layout shells | 04 |
| 06 | Fake data layer and demo seed | 04 |
| 07 | Shared widget kit | 05 |
| 08 | State views and the async wrapper | 06, 07 |
| 09 | Contact messages and notification permission | 06 |
| 10 | Delete account | 06, 09 |

Working one at a time, the lowest-numbered unblocked ticket gives the order 01 → 02 → … → 10.

## Things to know

- **Fakes only.** v1 builds only the in-memory fake repositories. The Firebase packages are added (ticket 01) so the config check compiles, but nothing uses a Firestore or Firebase Auth repository yet.
- **Placeholder screens must be easy to replace.** Later specs swap the widget a route builds and never touch routing (ticket 04).
- **Developer sign-in** on the `/login` and `/signup` placeholders is temporary. The Onboarding spec removes it.
- **Strings:** add only Foundation's own strings, in all 10 ARB files. English must be complete; the other 9 are machine drafts marked for review.
- **Starting state:** the repo is still the empty Flutter template, with no `test/` directory. Ticket 01 is the first code.
- **Before you start:** the planning files from this session (specs, tickets, map, `AGENTS.md`, `DESIGN.md`, `GLOSSARY.md`, `docs/manual-tasks.md`) may still be uncommitted. If `git status` shows them, ask the human to commit them first, so each ticket commit contains only that ticket's code and ticket file.
- **When stuck:** if a ticket is ambiguous or contradicts the spec, stop and append the question under `## Comments` in the ticket file (per `AGENTS.md`). Don't guess.

## When Foundation is done

Tell the human. Claude will then run `/to-tickets` and `/handoff` for **CI/CD**.
