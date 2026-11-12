<!-- Template version 1. Regenerate explicitly; shared wording has one source. -->
# Liminal Union product

## Objective and boundaries

The current user request defines scope and approval. The user decides goals and architecture; the AI handles implementation details within that scope. Host permissions enforce actual access.

Scope: Preserve mechanics, IDs, values, advancement, events, persistent variables, assets, runtime paths and translation domains. Workers, buildings, terraforming and units/nations/ belong to the product. Product changes require a concrete assignment.

## Project and sources

Separate requirements, observations, proposals, historical evidence and open checks. Inspect current sources before relying on earlier reports. Never read or copy credentials.

Sources: Code is the authority; there are no canon or design documents. Read only the row for your task.

| Task | Read |
|---|---|
| Unit stats, attacks, advancement | the unit file in `units/`; current values of all units: `./suite.sh profiles` in `../../umc-development/projects/liminal-union/` |
| Rules: resonance, conductor, interlock, anchor, formation ZOC | skill `lu-mechanics` ([card](../../umc-development/.agents/skills/lu-mechanics/SKILL.md)), then `lua/resonance.lua` and `macros/abilities.cfg` |
| Any Lua | [engine quirks](../../umc-hace/wesnoth/engine-quirks.md) and skill `lu-wml-lua-work` ([routing](../../umc-development/.agents/skills/lu-wml-lua-work/SKILL.md)) |
| Balance runs and reports | [HOWTO](../../umc-development/projects/liminal-union/HOWTO.md) |

Lore and tone live only in unit descriptions: keep the Union's voice (ancient, civic, severe) and the distinction between permitted arcane matter and forbidden living spellcraft. Do not invent unsupported paths or engine guarantees; mark unverified claims. `_server.ign` keeps development files out of the upload.

## Working method

Use small, reviewable changes. Preserve unrelated work. Keep English documentation concise. Do not weaken checks to obtain a passing result. Git writes, publication and further deletion need their own authorization.

Local workflow: Keep the game independent of development tools: no test includes or tool dependencies; generated work stays outside the product. Do not read upload credentials. Use the [shared method](../../umc-hace/generic/skills/development/SKILL.md). Comments say why and where, not what; update a comment with the code it explains. Extend an existing reference instead of adding a parallel one.

## Verification and completion

Check the requested outcome and implementation quality separately. Report what changed, evidence, limitations and the next decision. Distinguish passed, failed, not run and not applicable; a missing required check prevents success.

Acceptance: Check the assigned change and identify unverified runtime behavior. Static compatibility does not prove gameplay, multiplayer, save/load, replay or balance. Instruction files alone do not prove host discovery.
