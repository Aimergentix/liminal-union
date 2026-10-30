# Wesnoth Lua Coding Guidelines & Pitfalls

This document records architectural conventions, engine constraints, and critical gotchas for developing Lua modules in **Liminal Union** under Battle for Wesnoth 1.19+.

---

## 1. The Textdomain `_` Variable Shadowing Trap (Critical)

### The Issue
Wesnoth Lua conventions bind the gettext translation function to the local identifier `_`:
```lua
-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'
```
In standard Lua programming, `_` is commonly used as a throwaway dummy variable for unused loop indices:
```lua
-- DANGEROUS PATTERN:
for _, unit in ipairs(units) do
    unit:add_modification("object", {
        { "effect", {
            apply_to = "new_ability",
            { "abilities", {
                { "skirmisher", {
                    name = _ "wingsuit glide"  -- CRASH!
                }}
            }}
        }}
    })
end
```

### The Error
Inside the loop, the local loop variable `_` shadows the file-scope `_` function and holds the numeric iteration index (`1`, `2`, ...).
When the translation macro `_ "..."` evaluates, the engine attempts to invoke the number:
```text
Error occurred inside [lua]: lua/<file>.lua:<line>: attempt to call a number value (local '_')
```

### Mandatory Rule
**Never use `_` as a loop index variable in any Lua file that imports a textdomain.**
Always use explicit index names such as `idx`, `i`, or `k`:
```lua
-- SAFE PATTERN:
for idx, unit in ipairs(units) do
    ...
    name = _ "wingsuit glide"  -- Safe: calls wesnoth.textdomain
end
```

---

## 2. Odd-r Hex Layout Distance Calculations

Wesnoth uses an odd-r hexagonal coordinate system. Naive Euclidean or Manhattan distance formulas produce distorted distances and diagonal anomalies.

### Canonical Axial Distance Formula
```lua
local function hex_distance(x1, y1, x2, y2)
    if not x1 or not y1 or not x2 or not y2 then return 999 end
    local q1 = x1 - math.floor((y1 - (y1 % 2)) / 2)
    local r1 = y1
    local s1 = -q1 - r1
    local q2 = x2 - math.floor((y2 - (y2 % 2)) / 2)
    local r2 = y2
    local s2 = -q2 - r2
    return math.max(math.abs(q1 - q2), math.abs(r1 - r2), math.abs(s1 - s2))
end
```

---

## 3. Dynamic Unit Modifications and IDs

- Always provide a unique `id` attribute when calling `unit:add_modification("object", { id = "...", ... })`.
- Before adding a dynamic or transient modification (such as a turn-based ability, overlay, or resistance buff), remove any previous instance with:
  ```lua
  unit:remove_modifications({ id = "LIUN_my_mod_id" })
  ```
- Failure to clear modifications leads to stacked attributes across turns and bloated save files.

---

## 4. Floating Labels & Interface Safeguards

When triggering floating combat text or HUD indicators:
```lua
if wesnoth.interface and wesnoth.interface.float_label then
    wesnoth.interface.float_label(u.x, u.y, "<span color='#ffd700'>...</span>")
end
```
Always guard with `if wesnoth.interface and wesnoth.interface.float_label` because AI turns, headless benchmarks, or automated tests run without an active interface.

