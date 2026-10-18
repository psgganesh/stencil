# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

## Claude Code's role: ideation and planning only

All implementation in this repo is done by Codex (see "Implementation workflow" in `AGENTS.md`). Claude Code never writes code here — not production code, not tests, not throwaway prototypes.

- **What Claude does:** grilling, domain modeling (`GLOSSARY.md`, `docs/adr/`), research, wayfinder maps and tickets, specs (`/to-spec`), implementation tickets (`/to-tickets`), handoffs. Write only markdown docs under `.scratch/`, `docs/` and the repo root.
- **Prototype tickets:** resolve them without code — ASCII/markdown UI sketches, state tables, or written behaviour walkthroughs — and record that in the ticket's answer.
- **End of the flow:** once tickets are written with `Status: ready-for-agent`, the user runs `/handoff` to pass the work to Codex. Don't start implementing, even if asked to "just do the next one" — point to Codex instead.
- **Handoffs to Codex:** override the handoff skill's save location — write it to `.scratch/<feature>/handoff.md` in the repo (not `$TMPDIR`) so Codex finds it. Instead of "suggested skills", list which tickets are ready and in what order, and point Codex at the "Implementation workflow" section of `AGENTS.md`. Codex doesn't have this repo's Claude skills.
- Running read-only commands (`flutter analyze`, `flutter test`, `flutter doctor`) to understand the current state is fine.
