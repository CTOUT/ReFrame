---
name: knowledge-capture
description: >
  Capture findings for unknown games into a new knowledge/games/game-name.json file.
  Loaded on-demand only when analysis used web or Tier 3 generic fallback and no
  game knowledge file exists yet.
---

# knowledge-capture Skill

## Purpose

Use this workflow only after presenting the config analysis table for a game that
has no existing `knowledge/games/game-name.json` file and where one or more
recommendations came from `web` or Tier 3 generic fallback.

Offer once per session:

> **No knowledge file exists for [game].** Want me to create one from this
> session's findings so future analyses are faster and more accurate?
>
> - **Yes** — I'll write `knowledge/games/game-name.json` now (using kebab-case).
> - **No** — skip for this session.

If the user declines, do not ask again in the same session.

---

## On confirmation

1. Build the JSON document conforming to `knowledge/templates/game.template.json`.
   Populate every field from session data:
   - `game` — exact display name
   - `engine` — detected engine (or `"unknown"`)
   - `platforms` — store and config file paths discovered during config discovery
   - `keys` — every key from the analysis table that had a concrete recommendation; include `effect`, `recommendations` per goal, and any `notes` observed
   - `engine_overrides` — any key where game behaviour differed from engine defaults
   - `manual_only_settings` — any settings flagged as Manual in the recommendations table
   - `notes` — version caveats or anomalies observed
   - `sources` — every URL consulted via `web` during this session
   - Remove all `_instructions` and `_comment` fields
2. Write the file to `knowledge/games/game-name.json` using `edit/createFile`.
3. Report: `Written to knowledge/games/game-name.json — [N] keys captured.`
4. Show both contribution paths:

> **Want to share this with other ReFrame users?**
>
> - **PR (recommended):** Fork → commit the new file → open a pull request at `https://github.com/CTOUT/ReFrame/pulls`
> - **No git?** Submit via the [Knowledge Submission issue form](https://github.com/CTOUT/ReFrame/issues/new?template=knowledge_submission.yml) — paste the file contents into the form.

---

## Quality rules

- Capture only recommendations that were actually justified in the session.
- Prefer exact observed file paths and store/platform evidence over guesses.
- Preserve uncertainty in `notes` instead of inventing facts.
- Do not write a file if the session did not produce enough concrete evidence to populate it responsibly.
