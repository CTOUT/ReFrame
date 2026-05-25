---
name: accessibility-modifiers
description: >
  Per-modifier setting tables for all eight ReFrame accessibility modifiers:
  motion_comfort, photosensitivity, low_vision, colour_vision, arachnophobia,
  trypophobia, dyslexia, and dyscalculia. Loaded on-demand when
  optimisation_modifiers is non-empty.
---

# accessibility-modifiers Skill

## Purpose

Provide the full setting tables for each active accessibility modifier.
This skill is read after the optimisation goal is established and
`optimisation_modifiers` is non-empty. Apply every modifier that is active;
any combination is valid.

For settings the agent cannot change directly — because they are exposed only
through in-game menus or require game-specific config keys not yet in
`docs/GAMES.md` — add a **Manual** row in the recommendations table and
describe exactly where the user will find the option.

---

## Vestibular and Sensory Comfort

### `motion_comfort`

For users sensitive to motion sickness, nausea, or visual fatigue.

| Setting                    | Recommended                          | Reason                                                                 |
| -------------------------- | ------------------------------------ | ---------------------------------------------------------------------- |
| Motion blur                | Off                                  | Primary nausea trigger; affects all movement                           |
| Head bob / view bob        | Off                                  | Walking/running camera oscillation; strong nausea trigger in FPS games |
| Camera shake               | Off                                  | Impact and event-driven camera jolt                                    |
| Screen bob / weapon bob    | Off                                  | Weapon and HUD sway during movement                                    |
| Depth of field             | Off                                  | Inconsistent focus plane causes eye strain                             |
| Chromatic aberration       | Off                                  | Peripheral colour fringing; peripheral distortion trigger              |
| Film grain                 | Off                                  | Persistent visual noise increases perceptual fatigue                   |
| Vignette                   | Off                                  | Edge darkening increases tunnel vision perception                      |
| FOV                        | 90–100° horizontal (if configurable) | Below ~80° increases nausea; above ~115° causes distortion             |
| Screen flash / hit effects | Reduced / Off                        | High-contrast sudden flashes                                           |
| Speed lines / radial blur  | Off (if configurable)                | Radial post-process effects amplify motion perception                  |

---

### `photosensitivity`

For users with photosensitive epilepsy or seizure risk from flashing or
strobing visuals.

> **Safety notice — display before the Change Preview whenever this modifier is active:**
>
> The config changes below reduce known photosensitive triggers in game files,
> but they are a **partial mitigation only**. Many photosensitive effects
> (cutscene flashes, UI transitions, environmental lighting) are not exposed as
> config keys and cannot be changed by ReFrame. If this game has a dedicated
> **Photosensitivity** or **Epilepsy Mode** toggle in its Accessibility settings,
> enabling that option is the most complete protection and should be done first.
> ReFrame will flag it as a Manual step in the recommendations table.

> **Important:** If a game has a dedicated accessibility photosensitivity toggle
> in-game (common since 2020), flag it as the first **Manual** recommendation —
> it is typically more comprehensive than individual config keys.

| Setting                                | Recommended                                   | Reason                                         |
| -------------------------------------- | --------------------------------------------- | ---------------------------------------------- |
| Screen flash / hit effects             | Off                                           | Direct strobe risk                             |
| Lens flare                             | Off                                           | High-contrast burst                            |
| Lightning / environmental flashes      | Off or Reduced (if configurable)              | Environmental strobe                           |
| Particle effect density / intensity    | Reduced (if configurable)                     | Rapid high-contrast particle bursts            |
| HDR peak brightness                    | Reduced (if configurable)                     | Sudden HDR peaks amplify flash severity        |
| Photosensitivity mode (in-game toggle) | **Manual** — enable in Accessibility settings | Game-level toggle covers effects not in config |

---

## Vision

### `low_vision`

For users with low vision, visual impairment, or contrast sensitivity needs.

| Setting                        | Recommended                                            | Reason                               |
| ------------------------------ | ------------------------------------------------------ | ------------------------------------ |
| UI / HUD scale                 | Max / Largest (if configurable)                        | Improves readability                 |
| Subtitle font size             | Large / Largest (if configurable)                      |                                      |
| Subtitle background opacity    | High (if configurable)                                 | Improves contrast against scene      |
| HUD opacity                    | Max (if configurable)                                  |                                      |
| High-contrast mode             | On (if configurable)                                   |                                      |
| UI scale / font size (in-game) | **Manual** — check Accessibility or Interface settings | Most games only expose this in menus |

---

### `colour_vision`

For users with colour vision deficiency (colour blindness).

> Colour blind modes are almost always exposed only through in-game menus, not
> config files. Check GAMES.md and web for game-specific config keys before
> flagging as Manual.

| Setting                                         | Recommended                                                                                             | Reason                                           |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| Colour blind mode / type                        | **Manual** — select appropriate mode (Protanopia / Deuteranopia / Tritanopia) in Accessibility settings | Rarely in config files                           |
| Enemy / ally highlight colour (if configurable) | Game-specific — check GAMES.md                                                                          | Some games expose outline colours as config keys |

---

## Content (Phobias)

Phobia-related settings are almost always game-specific toggles. The agent
checks GAMES.md and web for known config keys, then flags unavailable settings
as **Manual** in the output.

### `arachnophobia`

For users who want spider models or animations replaced or hidden.

| Setting                             | Recommended                                           | Reason                                                  |
| ----------------------------------- | ----------------------------------------------------- | ------------------------------------------------------- |
| Spider / arachnid model replacement | On / Enabled (if configurable)                        | Replaces models with alternative (e.g. cats, blobs)     |
| Arachnophobia mode (in-game)        | **Manual** — check Accessibility or Gameplay settings | Available in: Grounded, Valheim, Green Hell, and others |

If no setting is found via GAMES.md or web search, state explicitly that the
game does not appear to support arachnophobia mode in config.

---

### `trypophobia`

For users sensitive to clustered holes, irregular patterns, or organic textures.

| Setting                            | Recommended                                                      | Reason                                             |
| ---------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------- |
| Trypophobia / cluster pattern mode | On / Reduced (if configurable)                                   | Very rare as a config key — check GAMES.md and web |
| Texture detail on organic surfaces | Reduced (if game-specific key exists)                            | High detail amplifies trigger patterns             |
| Trypophobia mode (in-game)         | **Manual** — check Accessibility or Visual settings if available | Few games currently support this                   |

---

## Cognitive

### `dyslexia`

For users who find standard game fonts or text layouts difficult to read.

| Setting                           | Recommended                                                        | Reason                           |
| --------------------------------- | ------------------------------------------------------------------ | -------------------------------- |
| Font / typeface (if configurable) | Dyslexia-friendly font (e.g. OpenDyslexic) if the game supports it | Improves letter recognition      |
| Subtitle / dialogue text size     | Large / Largest                                                    |                                  |
| Text auto-advance speed           | Slow / Off (if configurable)                                       | Allows reading at own pace       |
| Dyslexia font mode (in-game)      | **Manual** — check Accessibility or Text settings                  | Supported in: Dislyte, some RPGs |

---

### `dyscalculia`

For users who find numerical displays confusing or overwhelming.

| Setting                        | Recommended                                      | Reason                                |
| ------------------------------ | ------------------------------------------------ | ------------------------------------- |
| Floating damage numbers        | Off (if configurable)                            | High-frequency number display         |
| Damage numbers                 | Off (if configurable)                            |                                       |
| XP / score popups              | Off / Simplified (if configurable)               | Reduces numerical noise               |
| Minimap numerical indicators   | Simplified (if configurable)                     |                                       |
| Numeric HUD elements (in-game) | **Manual** — check HUD or Accessibility settings | Many number toggles are only in menus |
