---
type: Reference
title: "Visual Style Guide \u2014 Unit Categories"
description: "Product visual guidance subordinate to canon and language style."
---
# Visual Style Guide — Unit Categories

This document provides visual anchors for the four primary unit categories of the Liminal Union, intended for sprite artists and AI-assisted generation.

## Approved sprite redesign direction

Use the [approved weapon progression](../design/LIMINAL_UNION_BALANCE_REFERENCE.md)
for equipment and attack continuity. These designs are not implemented yet.

- Maiden Private starts with the Jaeger's bow and kick; Marine Private starts
  with khopesh and sling. L0 soldiers should visibly belong to their later corps.
- Maiden officers carry lance and shield from Ensign onward; Marine officers
  carry short sword and shield. Elemental applications use the same weapon.
- Show full-level progression through small, readable equipment and silhouette
  changes, keeping proportions, perspective and lighting consistent per line.
  Keep L2 specialists recognizable by their distinct equipment and role.
- Remove the existing troop/leadership rank markers. A small intermediate-stage
  badge is a separate proposed indicator; its artwork and placement remain open.
- Develop and review base sprites before animation frames. Generated concept
  sheets are previews, not validated 72×72 game assets or animation sets.
- Include a matching portrait pair with each distinct character/equipment
  design: a large transparent dialogue portrait and a smaller help portrait
  using the same identity and equipment. Keep the sprite's hair, small
  halfelven ears, armor, helmet stage and weapon role consistent. Portraits
  use painted Wesnoth-style illustration rather than enlarged sprite pixels.
  Verify `profile`/`small_profile` integration and dialogue orientation against
  the installed engine before replacing the legacy portrait references.

Artwork masters and concept sheets named below are kept outside the product, in
`umc-development/projects/liminal-union/artwork/maiden/` (`portrait-masters/`,
`sprite-concepts/`), with their prompts and manifests.

Saved portrait masters: Maiden dialogue v1
and Maiden help v1.
The version manifest
records original dimensions and SHA-256 hashes. These approved L1 artwork masters
are preserved originals, not final engine-sized exports; runtime paths are unchanged.

Current portrait pair for review: Maiden dialogue v5
and Maiden help v5.
The raised-visor direction is user-approved; v5 refines surface rendering and
the trained athletic build. The v5 manifest
records dimensions, hashes and limits: pixel dimensions remain unchanged and
fine skin texture remains. Earlier versions are preserved; v2/v3 nasal-guard
designs are superseded. Runtime references are unchanged.

Current additional portrait pairs for review:

| Unit | Dialogue | Help | Manifest |
|---|---|---|---|
| Private L0 v2 | Portrait | Portrait | Metadata |
| Hunterkiller L2 v1 | Portrait | Portrait | Metadata |
| Techtronic L2 v1 | Portrait | Portrait | Metadata |

All three pairs show folded gliding membranes between the upper arms and torso;
dialogue views also show folded hip panels. Private L0 is bareheaded with small
Pyrite shoulder caps and light forearm guards over a cloth tunic, without a full
breastplate. Hunterkiller has two small decorative service distinctions on the
breastplate; their shapes propose artwork, not canon names or gameplay ranks.
Techtronic carries hand tools, a parts satchel and a crafted fitting, with bow
and quiver slung behind her. L2 portraits use the raised visor.
Private v1 and the first Hunterkiller drafts lack clearly visible wingsuits and
are superseded. They remain preserved. The Jaeger v5 wingsuit depiction still
needs review before it is used as a complete equipment reference.
Each folder includes generation prompts and a manifest with dimensions, hashes
and limitations. These are artwork masters; runtime references are unchanged.

Saved sprite design references: bareheaded Maiden Private L0
and Pyrite Maiden line overview.
These preserved originals are large concept previews, not validated 72×72 assets
or animation frames. The overview predates the approved L1 raised visor; use
the current equipment guidance below. The concept manifest
records dimensions, hashes and remaining limitations.

## Proposed animation scope

Design proposal, not implementation approval or an engine acceptance result.
Use the documented [animation events](https://wiki.wesnoth.org/AnimationWML),
[timing guidance](https://wiki.wesnoth.org/Advanced_Animation_Tutorial) and
[custom animation actions](https://wiki.wesnoth.org/InterfaceActionsWML#%5Banimate_unit%5D).
Verify exact behavior against the installed engine before runtime integration.

| Set | Proposed coverage |
|---|---|
| Life and attention | Quiet standing loop; 2–3 occasional role-specific idles; brief selection response |
| Travel | Movement cycle, departure and arrival; terrain and actual-state variants where useful |
| Combat | Draw/ready and recover/stow; each distinct physical attack; ammunition effects; hit/miss feedback; directional coverage |
| Defense | Separate dodge and hit reactions; shield/parry poses only as visual reactions to resolved combat |
| Lifecycle | Recruit/recall arrival, level-out/in, restrained post-kill victory, death |
| Support | Healing/repair, being healed, poison damage; leadership/resistance support where the actual ability triggers them |
| Custom mechanics | Short transition cues for real resonance changes, active glide, Overclock and Grounding; additional explicit visual triggers required |

Maiden troop signature: unfolding, tension and folding of the jump-suit;
purposeful bow draw/release and kick; repair-tool gestures for Techtronic.
Marine signature: planted footwork, sling rotation/release, distinct khopesh
thrust and smash; shield bracing for Shieldguard. Officer signature: concise
command gesture, first aid and elemental weapon preparation. G9 signature:
weighty steps, articulated strikes, controlled core/Overclock response and
shutdown. Phoinix signature: varied wing cycles, banking, measured embers and
detox/relay cues only where the associated gameplay effect is confirmed.

Prefer breadth and clear motion to long compulsory sequences. Standing stays
quiet; rare idles may be longer. Do not play a complete multi-strike combo for
every single engine strike. Share body motion across ammunition variants and
inherit animations within a level when equipment is unchanged. Custom effect
animations consume existing state; they do not calculate bonuses or alter combat.
Keep HP bars, team colors and tactical overlays legible throughout.

The approved pilot is Maiden Private L0, not Jaeger L1. Start with her bareheaded
base sprite at game scale, then movement/glide, bow/kick, hit/dodge and lifecycle.
Use the approved 0·0 impact bow and kick; add the arcane projectile variant only
for 0·1, together with its intermediate-stage indicator. Do not give this pilot
the Jaeger's repair role, officer gestures or an L1 helmet. Support animations
initially cover receiving healing and poison damage, not providing treatment.
Review timing, all six directions, team colors, hit/miss/kill, return to standing
and overlaps.
Custom cues also need positive and negative state-transition checks, and relevant
save/load, replay and multiplayer verification. Expand to other lines only after
the pilot establishes the reusable frame and WML conventions.

Maiden Private runtime frames, referenced by its unit file under
`images/units/halfelven/maiden/` (72×72 WebP): existing names `maiden-private`,
`-idle-1`, `-idle-2`, `-defend` (hit reaction); new `-dodge`, `-bow-1`…`-bow-4`
(ready, draw, release, recover), `-kick-1`…`-kick-3`, `-jump-1`…`-jump-4`,
`-death-1`…`-death-3`. Jaeger, Hunterkiller and Techtronic keep their existing
frame names. Maiden troop units now reference review-stage 400×400 portrait
exports (`portraits/halfelven/maiden-<unit>.webp` and `-small.webp`); their
acceptance and in-game integration remain unverified.

## Core Aesthetic: The Ancient Commonwealth – Liminal Union
- **Forbidden:** Science-fiction, mechatronics, steampunk, digital UI, sleek robotics.
- **Required:** Ancient craftsmanship, civic severity, archaic Wesnothian high fantasy, arcane matter (alloys).

## 1. Maiden Corps (The Precision Arm)
- **Role:** Mobile female anti-sorcerous precision.
- **Visuals:** Revered fighters and mothers equipped with the finest, most costly ultralight Pyrite-alloy armor: pale yellow to amber, with a subtle honeycomb construction motif. Compact folded jump-suits; light helmets from L1 onward.
- **Vibe:** "Female, Civic ferocity." Intelligent, severe, family oriented and mobile.

## 2. Marine Corps (The Shield and Water Units)
- **Role:** Tactical male platoon sea/coastal/river defense.
- **Visuals:** Heavy, practical gear. Large shields and sturdy polearms.
- **Vibe:** "Male, Disciplined endurance." Steady, weather-beaten, ancient navy seals like, and grounded.

## 3. G9 Warforms (The Bound Vessels)
- **Role:** Heavy artifice and frontline pressure.
- **Visuals:** Ancient golem-tech. Stone/Alloy construction with visible "Bound Cores" (radiant energy sources and neural ai mainframe cores). Inspectable seams.
- **Vibe:** "Lawful Artifice." Weighty, ancient, and sealed.

## 4. Phoinix Messengers (The Emblems)
- **Role:** Scouting, utility, detoxing, and symbolic presence.
- **Visuals:** Avian forms with "measured fire." Crimson/Sun-red plumage. Ash and ember particles.
- **Vibe:** "Renewal through Ash." Elegant, radiant, and watchful.

## Palette Guidance
Background is transparent!
| Material | Visual Description |
| :--- | :--- |
| **Pyrite** | Warm pale-yellow to amber alloy; fine, lightweight crafted surfaces on Maiden armor. |
| **Kryonite** | Blue-silver, cold, crystalline metal. |
| **Arcanite** | Dark, deep metal with a soft "moonlit" purple/green glow. |
| **Uranite** | Dense, muted golden-amber conductance metal housed in officer rods and beacons. |
| **Zoelite / Akosite** | Smooth, vital pale-iron and clean, silvery-white medicinal alloys worn as keeper rings and conduits. |
| **Cores** | Radiant emerald or sunset orange light emanating from within. |

---
**Authority Note:** This file is subordinate to `STYLE_GUIDE.md`.



# Style Guide in Prose

*Visual Foundations (Shared Across All Units)*
Era/Setting: "High Fantasy / Battle for Wesnoth style."
Palette: Polished metals (Pyrite/Kryonite/Arcanite sheens), deep civic colors (navy, slate, crimson), and radiant core-light (soft blues or sunset oranges).
Aesthetic: "Ancient Southern Commonwealth." Avoid steampunk or sci-fi. Think "Severe Civic Law."

*1. Maiden Corps: The Precision Arm*
The (female) Maidens are high-status (mothers, daughters), mobile, and anti-sorcerous. Their look should be "trained civic ferocity."
Silhouette: Slim, athletic, and agile. Show the jump-suit as compact folded gliding membranes between the upper arms and torso, with restrained featherlike folds at the back and hips. Avoid bulky plates or large avian wings.
Armor/Clothing: The finest, most costly ultralight Pyrite-alloy protection, pale yellow to amber over deep civic cloth. A subtle honeycomb motif can suggest precision construction without digital effects or a science-fiction suit. Their high civic standing as revered fighters and mothers is expressed through excellent protection, care and dignified bearing. Light, open-faced helmets are required from L1 onward; L0 may remain bareheaded.
Appearance for this sprite series: Straight blonde hair, neatly arranged in compact braids or coiled braided side buns that fit the helmets. Halfelven ears are small and only subtly pointed, close to human proportions. These are art-direction choices for the series, not new universal biological canon.
Eyes are green-turquoise, with a warm, friendly, keen and maternal expression.
From L1 onward, use a lightweight helmet with a compact curved face visor on
small temple pivots, narrow cheek plates and a secured leather chin strap.
The visor is raised above the brow in portraits and quiet poses, leaving the
eyes, nose, cheeks and mouth visible; the intended close-combat state lowers
it over the face, with a narrow sight slit and a few breath openings. Remove
the separate nasal guard. This is a Maiden adaptation of historical pivoting
visors, not a reconstruction or a verified protective design. L0 remains
bareheaded. Keep the Maidens athletic, elegant and trained, with warm, keen
maternal confidence. Preserve refined painted portrait rendering; avoid coarse
pixelation or geometric surface artifacts. Bowstrings run continuously between
the nocks at both limb tips. Carry equipment into sprites wherever the game-scale
pixel budget allows; portraits remain painted illustrations.
Equipment: Bows and practical boots for the troop line; lances and shields for officers, following the approved weapon progression. The gear should look exact and well-maintained.
Motifs: Dawn light, sharp edges, and "disciplined mobility."
Prompting Keywords: Disciplined, revered civic fighters and mothers, agile, amber Pyrite-alloy armor, subtle honeycomb pattern, folded gliding suit, light helmet from L1, neat blonde braids, small halfelven ears.

*2. Marine Corps: The Shield of the Threshold*
The (male) Marines are line-holders and guardians of the coast, waterways and all-terain. They embody "disciplined endurance."
Silhouette: Sturdy, grounded, and broader. They should look like they can hold a hex indefinitely.
Armor/Clothing: hightech alloy fabric or reinforced leather. Weather-beaten but clean gear suited for sea, ports and river-mouths.
Equipment: Tactical gear (heater shields), theavy slings and Egyptian swords (khopesh). Tactical gear for "formation sense."
Motifs: Dusk shadows, river stone, crashing waves, and "unyielding law."
Prompting Keywords: Steadfast, line-holding, shields, weather-beaten endurance, practical command, formation-focused, sea and coastal guardian, tactical alloy armor.

*3. G9 Warforms: The Bound Vessels*
These are not robots; they are (bio-mechanical) "old golem-tech" and "Quickbound Golems." They are lawful war-artifice.
Silhouette: Large, heavy, and imposing. Geometric shapes suggesting ancient construction rather than modern assembly lines.
Materiality: Heavy bronze-like alloys, or blackened iron. Visible "seams" and "wards" where the energy is bound. Like the mythical Talon giant of Greek lore.
Key Feature: The Bound Core. A central, glowing (ai) energy source (Neural Curie Mainframe) that should look like a radiant gem or a contained flame, not a digital screen.
Equipment: Integrated heavy weapons or massive physical implements (fists, heavy brass knuckles/knuckle-dusters).
Prompting Keywords: Ancient golem-tech, corebound warform, alloy, radiant energy core, sealed vessel, inspectable seams, powerful/weighty silhouette, Wesnothian artifice.

*4. Phoinix Messengers: The Radiant Emblems*
Small living (mythical) birds, symbols of renewal and memory. Phoinix is Greek for crimson red like the setting sun or the rising sun – the sun also never really dies but renews itself from the dark ashes of night (metaphorically). They represent "rebirth and longevity"
Silhouette: small elegant avian forms, varying from swift scouts to majestic messengers.
Visual Elements: "Measured fire." Their feathers should glow like the morning or evening sun (burning red/crimson).
Details: Intelligent eyes suggesting "watchfulness." They are not pets; they are civic symbols and very intelligent ancient mythical beings.
Motifs: Palingenesis (rebirth), sunrise/sunset colors, rising heat-shimmer, and "transcendence."
Prompting Keywords: Fiery avian, small birs, burning crimson feathers, embers and ash, radiant morning sun, symbolic bird, dignified/watchful, measured fire, renewal motif.
