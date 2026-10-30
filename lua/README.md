# Liminal Union Lua Modules

This directory contains the runtime logic, formation dynamics, and prototype mechanics for the Liminal Union faction.

## Directory Index
- `resonance.lua` — Core resonance pod evaluation, Conductance bonuses, Formation ZOC, Interlock damage redistribution, and dynamic ground sigils. Formation effects are recalculated from current adjacency; there is no Kinetic Relay march grace.
- `formation.lua` — Formation coordinate helpers and adjacent ally queries.
- `g9_overclock.lua` — Prototype 2: Emergency Overclock right-click context menu and thermal stress handler.
- `promotion-handler.lua` — Prototype 3: Medal citation logging, civic floating banter, and intermediate HP replenishment.
- `maiden_wingsuit.lua` — Prototype 4: High ground (Hills/Mountains) Wingsuit Glide detection (+2 MP, Skirmisher).
- `phoinix_courier.lua` — Prototype 5: Airborne Conductor relaying and post-mortem Civic Memorial Archives (+3 XP on recovery).
- `marine_grounding.lua` — Prototype 6: Salt-Grounding Pylum context menu, aetheric dispersal, and anti-sorcery ward handler.

## Crucial Implementation Rule
**Textdomain Shadowing:**
Never use `_` as a throwaway loop variable (e.g. `for _, u in ipairs(...) do`) in files declaring `local _ = wesnoth.textdomain ...`. Loop variable `_` shadows the gettext lookup function with the numeric iteration index, crashing with `attempt to call a number value (local '_')` whenever translatable strings (`_ "..."`) are evaluated. Always use `idx`, `i`, or `k`.

See `docs/design/LUA_GUIDELINES.md` for full details.

