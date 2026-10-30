# Changelog

This file tracks notable, public-facing changes to **Liminal Union**. 

Treat this changelog as the clearest human-readable record of documentation-level changes.

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-10-30 — Canon & lore expansion: reactive/medicinal alloys, Eighth-Day Severance, and Vampire Covenant
### Added (canon)
- `docs/canon/CANON_LOCK.md` — new **Biological and metallurgical lock** and expanded **Historical lock**, **Diplomatic baselines**, and **Stable names**:
  - Canonical metallurgy grounding `Pyrite` (Fire), `Kryonite` (Cold), `Arcanite` (Arcane), and `Uranite` (Conductance) alongside the forest-mountain medicinal alloys `Zoelite` and `Akosite` (passive detoxifying conduits reacting to `Phoinix` warmth).
  - **The Eighth-Day Severance**: seven days of quiet shelter with `Zoelite` nursing-draughts (*smelting-milk*) followed on the eighth day by the `Catharite` bath in warm liquefied `Akosite` and fontanelle poultice, untethering Halfelven newborns from the Faerie plane and establishing full mortal citizenship.
  - **The Treaty of the Living and the Bound** (*Dark Forest Charter*): canonical framework for the non-necromantic vampiric exiles in the Dark Forest — buffer enclave against Evercrown, sealed bio-resonance cells for officer `Uranite` conductance rods, and strictly regulated exchange of containment craft for ritual mineral residues.
- `docs/canon/STYLE_GUIDE.md` — added canonical alloys (`Pyrite`, `Kryonite`, `Uranite`, `Zoelite`, `Akosite`) and rites/compacts (`Eighth-Day Severance`, `Catharite bath`, `smelting-milk`, `Treaty of the Living and the Bound`, `Dark Forest Charter`) to preferred terminology.
- `docs/lore/HISTORY.md` — added *The Sundering, the Eighth-Day Severance, and the Bound of the Dark Forest* and expanded *Arcanite and lawful artifice*.
- `docs/lore/LORE.md` — added *The Eighth-Day Severance*, expanded *Lawful artifice and the canonical alloys*, and added *The Treaty of the Living and the Bound* under *Foreign powers*.
- `docs/lore/SUMMARY` — updated overview with the canonical alloys, the Eighth-Day Severance, and the Treaty of the Living and the Bound.
- `docs/style/VISUAL_STYLE_GUIDE.md` — added `Uranite` and `Zoelite / Akosite` to the material palette table.
- `_server.pbl` — replaced placeholder add-on `description` with the updated canonical Liminal Union faction and era description, and added `[translation]` blocks for `de`, `fr`, `es`, and `it`.
- **Multi-language Localization (`de`, `fr`, `es`, `it`)**:
  - Marked all remaining user-facing strings in `lua/*.lua` (`lua/promotion-handler.lua`, `lua/g9_overclock.lua`, `lua/phoinix_courier.lua`, `lua/maiden_wingsuit.lua`, `lua/marine_grounding.lua`, `lua/resonance.lua`) with `_ "..."` under textdomain `wesnoth-liminal-union`.
  - Extracted `translations/template.pot` (501 `msgid`s) via `wmlxgettext` and added complete `.po` and compiled `.mo` translations for German (`translations/de/`), French (`translations/fr/`), Spanish (`translations/es/`), and Italian (`translations/it/`).


## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-10-25 — Resonance Phase 5.1 Reform & Conductance Visual Overhaul
### Added
- **Resonance Visuals & Conductance Animations**:
  - Ground Halos (`[standing_anim]` with `halo="halo/conductance-aura-[1~4].webp"`), rendering soft foreground grounding circuit rings without obstructing unit sprites.
  - Hexagonal Ground Sigils for Resonance Tiers 1–3 (`images/halo/resonance-[alloy]-t[1~3].webp`): Dynamic isometric rings under unit feet (Tier 1 = 2 lit nodes, Tier 2 = 4 nodes / broken ring, Tier 3 = complete 6-node ring + alloy mark: Amber reticle for Pyrite, Cyan chevron for Kryonite, Violet lattice for Arcanite).
  - Conductor Command Beacon (`images/halo/conductor-beacon.webp`): Radiant golden diamond under officer feet.
  - Floating Text & Status Icons (`overlays/conducted.png`, `<span color='#00e5ff'>Conducted</span>`, `<span color='#ffd700'>ZOC Lock</span>`, `<span color='#ffd700'>✦ Tier 3 Lock ✦</span>`, `<span color='#4fc3f7'>-X Interlock</span>`).
  - Arcane spark attack/defense anim frames with electric discharge sounds.
- **Formation ZOC**: Level 0 units (Privates, G9 AI, Ensigns) in stationary pods of $\ge 2$ allied troops exert full Zone of Control (`apply_to=zoc`), enabling tactical line holding and cavalry interception.
- **Field Redistribution ("Interlock")**: 30% of combat damage taken by resonating Kryonite Marines is absorbed across adjacent stationary Kryonite allies, conserving total army damage while preventing focus-fire assassinations (cannot reduce allies below 1 HP).
- **Prototype: Kinetic Relay (Pulsed Marching Resonance)**: When resonant units start adjacent and advance together in formation (ending their moves on adjacent hexes), their resonance tier drops by only 1 instead of collapsing to 0 (Tier 3 squad retains Tier 2 on the march; Tier 2 retains Tier 1). Moving level 0 troops in kinetic formation retain Formation ZOC.
- **Prototype: G9 "Emergency Overclock" (The Meltdown Lever)**: Right-click context action for G9 Warforms. Bypasses core safety protocols to grant +1 melee strike and +2 damage for the turn at the cost of 4 HP core thermal stress at turn end (terminal notices: `[PROTOCOL BYPASS: OVERCLOCK ACTIVE]`, `[WARRANTY VOIDED]`).
- **Prototype: Sarcastic Medal Citations & Dynamic Floating Banter**: Leveled/medaled troops and G9s now float deadpan civic rationalist citations upon earning medals (*"Citation: Strict Protocol Adherence"*, *"Award: Unsolicited Tenacity"*, *"Chassis Wear: Within Municipal Code"*) and trigger dry combat banter when revoking enemy sovereignty or quashing unlicensed spellcraft.
- **Prototype: Maiden "Wingsuit Slingshot" (Aerial Surprise)**: Maidens starting their turn on elevated terrain (Hills or Mountains) gain the Thermal Glide bonus (+2 MP and Skirmisher for that turn), allowing tactical swoops over enemy battlelines from mountain ridges.
- **Prototype: Phoinix "Civil Registry Courier" (Tactical Utility)**: Phoinixes act as Airborne Conductance Relays when hovering within 3 hexes of an allied Conductor (relaying Conducted alignment to adjacent comrades). Upon falling in combat, a Phoinix leaves an ashen Civic Memorial Archive granting +3 XP to the first allied soldier to recover it (*"Registry Archive Preserved"*).

### Changed
- **Pure Conductance Aura**: Replaced Command line Leadership with pure Conductance aura granting symmetric +15% Day and +15% Night alignment offsets to all adjacent liminal troops regardless of level.
- **Uranite Command Line**: Removed Uranite resonance from command units, establishing them as pure Conductors.
- **Resonance Tier 3 Threshold**: Lowered from 6+ units down to 4+ units (Pod 2 = Tier 1, Pod 3 = Tier 2, Pod 4+ = Tier 3).
- **Pyrite Armor Recalibration**: Tier 3 Pyrite grants +15% Fire and +15% Arcane resistance alongside ranged Focus (60% min hit).
- **Resonance Healing Stripped**: Completely removed passive HP regeneration from resonance pods.
- **Medal Bandage & XP Calibration**: Intermediate medal heals calibrated to +2 HP; recruit XP thresholds adjusted (+15-20%).
- **Documentation**: Updated `STRATEGY.md`, `BALANCE_HANDOVER.md`, and all unit descriptions to reflect the reformed mechanics.







## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-18 — Maintenance audit follow-up (WML/docs path and textdomain fixes)
##  Version 
-   0.2.4alpha : normalized version identifier across repository

### Fixed
- `_main.cfg` — corrected `[textdomain] name` from `Liminal_Union` to `wesnoth-liminal-union` so translatable strings resolve in the intended add-on domain
- `macros/traits.cfg` — corrected `#textdomain` from `wesnoth-multiplayer` to `wesnoth-liminal-union` for LIUN-specific trait strings
- `era.cfg` — corrected `#textdomain` from `wesnoth-multiplayer` to `wesnoth-liminal-union` for LIUN era strings
- `_server.pbl` — corrected grammar in description (`An Wesnoth era` -> `A Wesnoth era`)
- `factions/liminal-union-braves.cfg` and `factions/liminal-union-heroes.cfg` — replaced broken description image reference (`portraits/liminal_union.webp`) with existing faction assets:
  - braves: `factions/liminal-union-default.webp`
  - heroes: `factions/liminal-union-aoh.webp`

### Needs review
- `era.cfg` — `[set_achievement] id=achievement-1a` does not match known IDs in `achievements.cfg`; verify intended achievement ID
- `macros/alignment.cfg` — `image="misc/liminal.png"` points to a missing file; provide intended icon asset/path

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-18 — Codebase error fixes (unit IDs, animations, images)
##  Version 
-   0.2.3alpha : normalized version identifier across repository

### Fixed
- 22 unit files — replaced invalid middle-dot (·) with underscore in `id=` / `advances_to=` fields (102 occurrences); display names keep the · for readability
- 3 idle animations — fixed frame/timing bracket mismatch (`[100*4,200*3,200*3,100*3]` → `[100,200,200,100]`) in Maiden Private, Maiden Ensign, Drake Brave
- 51 AMLA variant images — replaced invalid `~REF()` image function with `~BLIT()` across all unit files
- 2 AMLA base image paths — Techtronic variants pointed to non-existent `maiden-techtronic.webp` (→ `maiden-medic.webp`); Marine Colonel variants pointed to non-existent `marine-colonel.webp` (→ `marine-3b.webp`)
- Hunterkiller movement animation — replaced 8 missing `_flying[1-8]` frames with 5 existing `_jump[1-5]` frames
- 4 unit files — replaced missing `pitchfork-n/ne.webp` projectile images with existing `spear-n/ne.webp` (Maiden Private, Fellah, Drake Brave, Minion)
- 10 halfelven unit files — normalized stale portrait references to the existing `portraits/halfelven/{transparent/,}maiden.webp` and `marine.webp` assets; corrected Maiden Private and Maiden Ensign profiles to use the Maiden portrait

### Added
- `images/portraits/halfelven/transparent/maiden.webp` and `marine.webp` — copied from parent directory to satisfy portrait references
- `images/portraits/golem.webp` and `phoinix.webp` — placeholder portraits created from unit sprites

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-17 — Resonance system implementation (C1–C4)

### Added
- `macros/abilities.cfg` — five alloy-assignment macros (`LIUN_ALLOY_PYRITE`, `LIUN_ALLOY_KRYONITE`, `LIUN_ALLOY_ARCANITE`, `LIUN_ALLOY_URANITE`, `LIUN_CONDUCTOR`) that stamp unit variables for the Lua resonance engine
- `macros/abilities.cfg` — five WML dummy abilities for tooltip display (`ABILITY_RESONANCE_PYRITE`, `ABILITY_RESONANCE_KRYONITE`, `ABILITY_RESONANCE_ARCANITE`, `ABILITY_RESONANCE_URANITE`, `ABILITY_CONDUCTOR`)
- `lua/resonance.lua` — Tier 3 alloy-specific bonuses: Arcanite Warding (+20% fire/cold resistance) and Pyrite Focus (marksman on ranged attacks)

### Changed
- `macros/shared-race-characteristics.cfg` — 7 race macros: `alignment=liminal` → `alignment=lu_liminal` for custom alignment system
- `macros/advancements.cfg` — `AMLA_SIMULACRUM_END` max_times reduced from 9 to 6 to prevent ≤0 HP edge case
- `lua/resonance.lua` — strict debuff counting: adjacent allies excluded from pod count if poisoned, slowed, or moved
- 19 unit files wired with alloy macros and resonance abilities:
  - 4 maiden units → Pyrite
  - 5 marine units → Kryonite
  - 2 golem units → Arcanite
  - 8 command units → Uranite + Conductor
- 58 × `[abilities]` → `[+abilities]` in non-_Base unit variants (medal/public stages) to merge with inherited abilities

### Fixed
- `faction.cfg` — changed `[+units]` to `[units]` to fix invalid closing tag error that prevented the add-on from loading

### Planned
- giving the advancement tree further diversity:
  - sub-lvl-ups in lvl0 brings new attacks or leadership for officer line
  - sub-lvl-ups in lvl0 bring abilities/weapon_specials (enemy debuffs) conncted to resonance armor
  - sub-lvl-ups in lvl1 bring abilities/weapon_specials conncted to different resonance armor types
  - sub-lvl-ups in lvl2 bring normal abilities/weapon_specials for further damage type specialization
  - each su-lvl-up should bring + one attack (lets say +pierce to blade,impact) 
  - each sub-lvl-up brings specialisation on the field according to enemy's recruit pattern

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-16 — Canon refinement: law of the open threshold — reciprocal duty

### Changed (canon)
- `docs/canon/CANON_LOCK.md` — **Founding character lock** refined: law of mutual obligation now emphasizes reciprocal duty — treat the stranger and former enemy as you wish to be treated, because the founders were refugees themselves
- `docs/lore/HISTORY.md` — *The founding flight and the law of the open threshold* rewritten to emphasize that founders "vowed that when they had built their commonwealth, it would treat the stranger...as they themselves wished to have been treated"
- `docs/lore/LORE.md` — *The open threshold* rewritten with stronger reciprocal language: stranger received "as a potential member," enemy "bound by the same oath," fund of common provision justified as essential to a real commonwealth (not sentiment)

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-10 — Canon expansion: civic compact, refugee origins, public obligation, literacy

### Added (canon)
- `docs/canon/CANON_LOCK.md` — new binding **Founding character lock**: Sayyon as city of threshold-crossers built by those who fled tyranny; law of the open threshold; public fund of common provision as civic obligation (not charity); full civic standing for the lowborn regardless of birth
- `docs/lore/HISTORY.md` — new section *The founding flight and the law of the open threshold*
- `docs/lore/LORE.md` — new section *The open threshold* in full lore register; Civic learning section expanded with literacy-as-minimum-equipment-of-a-free-citizen framing
- `.github/skills/liminal-union/SKILL.md` — Core Faction Principles updated with founding character and expanded education entries

### Notes
- All framing avoids banned modern ideological labels (socialist, welfare-state, etc.) per STYLE_GUIDE; concepts expressed as ancient, severe, unsentimental civic doctrine rooted in the Union's founding history

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-06 — Canon expansion: civic education and universal military service
##  Version 
-   0.2.2alpha : normalized version identifier across repository

### Added (canon)
- `docs/canon/CANON_LOCK.md` — two new binding locks:
  - **Civic education lock**: compulsory children's education, the Halls of Inquiry as the oldest higher-learning institutions on the Great Continent, doctrine that knowledge is civic property, and the Union's people as unusually capable through generations of open public instruction (not bloodline)
  - **Military service lock**: universal civic draft, rank by merit and oath, defense obligation extends to scholars and artificers
- `docs/lore/HISTORY.md` — new section *The Halls of Inquiry and public learning* covering the origin and doctrine of universal public education
- `docs/lore/LORE.md` — new section *Civic learning* expressing the education policy in full lore register
- `docs/genai/GenAI_GUIDE.md` — Halls of Inquiry added to stable canonical names
- `.github/skills/liminal-union/SKILL.md` — Core Faction Principles updated with education and draft pillars

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-04 — GenAI steering documentation overhaul
##  Version 
-   0.2.1alpha : normalized version identifier across repository

### Added
- `.github/skills/liminal-union/SKILL.md` — new VS Code Copilot skill file consolidating all GenAI guidance for the project into a single, auto-loaded context; covers authority hierarchy, agent roles, safe terminology table, tone requirements, WML guardrails, faction pillars, diplomatic baselines, forbidden inventions, and validation checklist

### Changed
- `docs/genai/GenAI_GUIDE.md` — four critical sections added:
  - **Uncertainty labels**: standardized `# [NEEDS REVIEW — ...]` tag vocabulary
  - **Files that do not exist**: explicit list of ghost files (`TERMINOLOGY_LOCK.md`, `DIPLOMATIC_MATRIX.md`, `docs/design/`) that must not be cited; `tmp/` content flagged as draft material only
  - **Stable canonical names**: exact spellings including `Phoinix` (not Phoenix), `NCM`, Arcanite family, Scarlet Faerie Stone rule
  - **Diplomatic anchors**: fixed 8-power baseline table with hard necromancy rule

### Notes
- `tmp/GenAI_AGENTS.md`, `tmp/GenAI_CONTEXT.md`, `tmp/GenAI_META.md` analysed as source material; content distilled into `SKILL.md`; originals remain in `tmp/` as archived drafts

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-02 — Codebase modernization and cleanup
##  Version 
-   0.2.0alpha : normalized version identifier across repository

### Changed
- Migrated all image assets from PNG/JPG to WebP format for improved compression and performance
- Updated all 1,380+ image file references across configuration files to use .webp extensions
- Performed comprehensive codebase cleanup addressing redundancies, errors, and inconsistencies
- Migrated legacy balance experiments, WML examples, and unit tables from archived notes to dedicated design notes in `docs/design/` with dates and scope labels

### Fixed
- Corrected achievement ID typo: `brozeheart` → `bronzeheart` in achievements system
- Fixed faction image reference: `guardians_aoh.png` → `liminal_union_aoh.png` for Liminal Union heroes
- Resolved multiple typos across configuration files (distributed, disturb, in between, incur, pickable)
- Standardized macro formatting by removing trailing whitespace and reformatting malformed macros
- Eliminated unused code including deprecated advancement definitions and unused macro definitions

### Optimized
- Reduced file size by converting 965 images to WebP format (25-35% better compression than PNG)
- Removed unused image directories and deprecated files, eliminating wasted bytes
- Improved code consistency with standardized formatting across all configuration files
- Reviewed every file in the uploaded /docs tree and treated those files as the only verified source, since no non-/docs repo contents were available.
- Identified duplication, weak authority boundaries, terminology conflicts, style drift, and file-hygiene problems.
- Did condensed replacement text for the surviving files so the documentation set becomes shorter, stricter, and easier to maintain.

### Technical
- Version updated to `0.2.0alpha`
- All image references now point to WebP format for modern compatibility
- Codebase now free of PNG/JPG references in configuration files

## ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– ––––––––––––––––––––– 
## 2026-04-01 — Documentation 
##  Version 
-   0.1.4alpha : normalized version identifier across repository

### Changed
- Rewrote `docs/README.md` to match the canon hierarchy under `docs/canon/` and the current lore files.
- Removed deprecated lore-facing phrasing that presented the faction primarily in science-fiction terms.
- Reframed the faction publicly as an **ancient southern commonwealth** centered on **Sayyon / Salem**.
- Clarified the doctrinal distinction that the Union is **anti-sorcerous in agency, not anti-arcane in substance**.
- Standardized public roster language around the four canonical pillars:
  - **Maiden Corps**
  - **Marine Corps**
  - **G9 Warforms**
  - **Phoinix Messengers**
- Preserved controlled gameplay exceptions such as **G9** and **NCM** where those labels improve roster recognition.

### Clarified
- `docs/README.md` now distinguishes between:
  - lore-facing terminology;
  - gameplay-facing roster labels;
  - developer-facing repository guidance.
- The repository documentation now points contributors first to:
  1. `docs/canon/CANON_LOCK.md`
  2. `docs/canon/STYLE_GUIDE.md`
  3. `docs/canon/TERMINOLOGY_LOCK.md`

### Normalization note
The repository currently contains more than one version marker.

- `_info.cfg` reports add-on version `6.9.1.1`.
- `_version.cfg` defines `0.1.4alpha`.

These identifiers should be reconciled in a later maintenance pass.

## Legacy balance appendix

The previous changelog contained extensive matchup scratch notes. Those notes were useful as rough design memory but not as a public changelog. The most stable parts are preserved here in distilled form until they are moved into a dedicated design document.

### Broad counter-profile notes

These are legacy design heuristics, not canonical lore claims and not final balance law.

- **Against Drakes:** cold, arcane, and pierce pressure were noted as strong.
- **Against Dwarvish / Knalgan lines:** arcane, fire, and cold pressure were noted as useful, while raw physical trading was less favorable.
- **Against human / Loyalist lines:** fire and pierce pressure were emphasized.
- **Against orcish lines:** arcane pressure was the clearest noted edge.
- **Against elvish / rebel lines:** arcane and fire pressure were emphasized.
- **Against undead lines:** arcane, fire, and impact were repeatedly noted as key tools.
- **Against Dunefolk lines:** pierce and impact pressure were emphasized.

### Internal roster role notes

Legacy matchup notes consistently described the roster in the following broad terms:

- **Marines** as mixed fighters and line-holders.
- **Maidens** as mobility and precision elements.
- **G9 units** as durable anti-pressure pieces.
- **Phoinixes** as fast utility, scouting, and disruption units.