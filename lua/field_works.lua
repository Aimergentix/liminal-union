-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Field works: finite charges carried by three unit lines, spent through synced
-- right-click actions (and a minimal AI reflex at side turn end).
--   Mechatronic: "aimergent-core" charges, builds a G8 Simulacrum (L0) for 10 gold.
--   Techtronic:  "aimergent-core" charges, builds a G9 AI (L0) for 16 gold, its recall cost.
--   Shieldguard: "ember capsules", opens one to call a Phoinix (L0) for 10 gold;
--                kindles the ash of a fallen own Phoinix for free (no capsule).
-- Charges live in unit variables (saved, replayed) and are shown as a sidebar
-- ability whose name carries the count. Every new unit of a line, and every unit
-- at scenario start, holds CHARGES; the count only changes inside synced actions.

---@diagnostic disable: undefined-global

local field_works = {}

local CHARGES = 3
local DISPLAY_ID = "LIUN_charge_display"

local LINES = {
    { prefix = "LIUN_Shieldguard", line = "shieldguard", var = "lu_ember" },
    { prefix = "LIUN_Mechatronic", line = "mechatronic", var = "lu_cores", build = "LIUN_G8_Simulacrum", price = 10 },
    { prefix = "LIUN_Techtronic",  line = "techtronic",  var = "lu_cores", build = "LIUN_G9_AI",         price = 16 },
}
local CALL_PRICE = 10
local PHOINIX_L0 = "LIUN_Phoinix"

local function line_of(u)
    local t = tostring(u and u.type or "")
    for idx, l in ipairs(LINES) do
        if t:sub(1, #l.prefix) == l.prefix then return l end
    end
    return nil
end

local function charges(u, l)
    return tonumber(u.variables[l.var]) or 0
end

local function render(u, l)
    u:remove_modifications({ id = DISPLAY_ID })
    if not l then return end
    local n = charges(u, l)
    local ability
    if l.line == "shieldguard" then
        ability = {
            id = "LIUN_ember_capsules",
            name = string.format(_ "ember capsules (%d)", n),
            female_name = string.format(_ "female^ember capsules (%d)", n),
            description = _ "Sealed alloy capsules hold the preserved ash of Phoinix Messengers; a trace of Zoelite rekindles it. Right-click a free hex beside this Shieldguard to open a capsule and call a young Phoinix (10 gold): the Shieldguard must not have moved this turn, spends its whole turn, and neither its hex nor the target hex may be a village, castle or keep. Right-click the ash of a fallen Phoinix of your side beside it to kindle it without gold or capsule; this spends its attack. Each new Shieldguard, and every Shieldguard at the start of a scenario, carries 3 capsules.",
        }
    else
        ability = {
            id = "LIUN_aimergent_core",
            name = string.format(_ "aimergent-core (%d)", n),
            female_name = string.format(_ "female^aimergent-core (%d)", n),
            description = _ "Sealed Curie energy cores, each with a bound intellect, ready to quicken a warform. While standing on a village, castle or keep, right-click a free hex beside this artificer to build: a Mechatronic builds a G8 Simulacrum (10 gold), a Techtronic a G9 AI (16 gold). Building spends the artificer's attack, at most once per turn; the warform arrives without moves or attack, costs no upkeep and never advances a level. Each new artificer, and every artificer at the start of a scenario, carries 3 cores.",
        }
    end
    u:add_modification("object", {
        id = DISPLAY_ID,
        silent = true,
        { "effect", { apply_to = "new_ability", { "abilities", { { "dummy", ability } } } } },
    })
end

-- Gives a unit its line's charges when it is new to the line (or when reset=true).
function field_works.refresh(u, reset)
    if not u then return end
    local l = line_of(u)
    if not l then
        if u.variables.lu_charge_line then
            u.variables.lu_charge_line = nil
            u:remove_modifications({ id = DISPLAY_ID })
        end
        return
    end
    if reset or u.variables.lu_charge_line ~= l.line then
        u.variables[l.var] = CHARGES
        u.variables.lu_charge_line = l.line
    end
    render(u, l)
end

-- Scenario start: every unit of a charge line, on the map or on a recall list, starts full.
function field_works.on_prestart()
    for idx, u in ipairs(wesnoth.units.find_on_map({})) do field_works.refresh(u, true) end
    for idx, u in ipairs(wesnoth.units.find_on_recall({})) do field_works.refresh(u, true) end
end

function field_works.on_unit_event(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    field_works.refresh(wesnoth.units.get(ctx.x1, ctx.y1), false)
end

-- Terrain helpers -------------------------------------------------------------

local function terrain_info(x, y)
    return wesnoth.terrain_types[wesnoth.current.map[{ x, y }]]
end

local function is_settlement(x, y)
    local t = terrain_info(x, y)
    return t and (t.village or t.castle or t.keep) or false
end

local function free_hex_for(type_id, side, x, y)
    if not wesnoth.current.map:on_board(x, y) then return false end
    if wesnoth.units.get(x, y) then return false end
    local probe = wesnoth.units.create({ type = type_id, side = side, random_traits = false })
    return wesnoth.units.movement_on(probe, wesnoth.current.map[{ x, y }]) < 99
end

local function adjacent_own(side, x, y, pred)
    local found = wesnoth.units.find_on_map({
        side = side,
        { "filter_location", { { "filter_adjacent_location", { x = x, y = y } } } },
    })
    table.sort(found, function(a, b) return a.id < b.id end)
    for idx, u in ipairs(found) do
        if u.hitpoints > 0 and pred(u) then return u end
    end
    return nil
end

local function gold(side) return wesnoth.sides[side].gold end

-- Eligibility (shared by menus, commands and the AI) ------------------------------

function field_works.builder_for(side, x, y)
    for idx, l in ipairs(LINES) do
        if l.build and gold(side) >= l.price and free_hex_for(l.build, side, x, y) then
            local b = adjacent_own(side, x, y, function(u)
                local ul = line_of(u)
                return ul == l and charges(u, l) > 0 and u.attacks_left > 0
                    and u.variables.lu_built_turn ~= wesnoth.current.turn
                    and is_settlement(u.x, u.y)
            end)
            if b then return b, l end
        end
    end
    return nil
end

function field_works.caller_for(side, x, y)
    if gold(side) < CALL_PRICE or is_settlement(x, y) then return nil end
    if not free_hex_for(PHOINIX_L0, side, x, y) then return nil end
    return adjacent_own(side, x, y, function(u)
        local l = line_of(u)
        return l and l.line == "shieldguard" and charges(u, l) > 0
            and u.moves == u.max_moves and u.attacks_left > 0
            and not is_settlement(u.x, u.y)
    end)
end

function field_works.kindler_for(side, x, y)
    local courier = wesnoth.require("~add-ons/liminal-union/lua/phoinix_courier.lua")
    if not courier.has_archive(x, y, side) then return nil end
    if not free_hex_for(PHOINIX_L0, side, x, y) then return nil end
    return adjacent_own(side, x, y, function(u)
        local l = line_of(u)
        return l and l.line == "shieldguard" and u.attacks_left > 0
    end)
end

-- Synced actions ---------------------------------------------------------------

local function place(type_id, side, x, y)
    wesnoth.wml_actions.unit({ type = type_id, side = side, x = x, y = y, moves = 0, attacks_left = 0 })
    local ctx = { x1 = x, y1 = y }
    wesnoth.require("~add-ons/liminal-union/lua/resonance.lua").on_unit_placed(ctx)
    wesnoth.require("~add-ons/liminal-union/lua/marine_grounding.lua").on_unit_placed(ctx)
end

local function label(x, y, text)
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(x, y, text)
    end
end

function field_works.build(x, y)
    local side = wesnoth.current.side
    local b, l = field_works.builder_for(side, x, y)
    if not b then return false end
    wesnoth.sides[side].gold = gold(side) - l.price
    b.variables[l.var] = charges(b, l) - 1
    b.variables.lu_built_turn = wesnoth.current.turn
    b.attacks_left = 0
    render(b, l)
    place(l.build, side, x, y)
    label(x, y, _ "<span color='#b388ff'>Warform quickened</span>")
    return true
end

function field_works.call_phoinix(x, y)
    local side = wesnoth.current.side
    local s = field_works.caller_for(side, x, y)
    if not s then return false end
    local l = line_of(s)
    wesnoth.sides[side].gold = gold(side) - CALL_PRICE
    s.variables[l.var] = charges(s, l) - 1
    s.moves = 0
    s.attacks_left = 0
    render(s, l)
    place(PHOINIX_L0, side, x, y)
    label(x, y, _ "<span color='#ffaa33'>Ember capsule opened</span>")
    return true
end

function field_works.kindle_ash(x, y)
    local side = wesnoth.current.side
    local s = field_works.kindler_for(side, x, y)
    if not s then return false end
    local courier = wesnoth.require("~add-ons/liminal-union/lua/phoinix_courier.lua")
    courier.take_archive(x, y, side)
    s.attacks_left = 0
    place(PHOINIX_L0, side, x, y)
    label(x, y, _ "<span color='#ffaa33'>Ash rekindled</span>")
    return true
end

-- Minimal AI reflex ------------------------------------------------------------
-- Runs at side turn end for AI sides only, as fixed at prestart (replay-safe; see
-- side_control.lua and LUA_GUIDELINES.md §5).

local AI_GOLD_RESERVE = 5

local function nearest_enemy_distance(side, x, y)
    local best = 999
    for idx, e in ipairs(wesnoth.units.find_on_map({ { "filter_side", { { "enemy_of", { side = side } } } } })) do
        local d = wesnoth.map.distance_between(x, y, e.x, e.y)
        if d < best then best = d end
    end
    return best
end

-- Free hexes beside (ux, uy), best first: not settlements, nearest to an enemy, then x, y.
local function candidate_hexes(side, ux, uy)
    local out = {}
    -- get_adjacent_hexes returns six locations as separate values.
    for idx, loc in ipairs({ wesnoth.map.get_adjacent_hexes(ux, uy) }) do
        local x, y = loc.x or loc[1], loc.y or loc[2]
        if wesnoth.current.map:on_board(x, y) and not wesnoth.units.get(x, y) and not is_settlement(x, y) then
            out[#out + 1] = { x = x, y = y, d = nearest_enemy_distance(side, x, y) }
        end
    end
    table.sort(out, function(a, b)
        if a.d ~= b.d then return a.d < b.d end
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    return out
end

function field_works.on_side_turn_end(side_num)
    side_num = side_num or wesnoth.current.side
    if not wesnoth.require("~add-ons/liminal-union/lua/side_control.lua").is_ai_side(side_num) then return end
    local courier = wesnoth.require("~add-ons/liminal-union/lua/phoinix_courier.lua")

    -- 1. Kindle own ash (free).
    for idx, a in ipairs(courier.archives_of(side_num)) do
        field_works.kindle_ash(a.x, a.y)
    end

    local units = wesnoth.units.find_on_map({ side = side_num })
    table.sort(units, function(a, b) return a.id < b.id end)
    for idx, u in ipairs(units) do
        local l = line_of(u)
        if l and l.build and gold(side_num) >= l.price + AI_GOLD_RESERVE then
            -- 2. Build one warform per artificer on a village, castle or keep.
            for idx, h in ipairs(candidate_hexes(side_num, u.x, u.y)) do
                local b = field_works.builder_for(side_num, h.x, h.y)
                if b and b.id == u.id then field_works.build(h.x, h.y); break end
            end
        elseif l and l.line == "shieldguard" and gold(side_num) >= CALL_PRICE + AI_GOLD_RESERVE then
            -- 3. Call a Phoinix when the side has fewer than two.
            if #wesnoth.units.find_on_map({ side = side_num, race = "marinephoinix" }) < 2 then
                for idx, h in ipairs(candidate_hexes(side_num, u.x, u.y)) do
                    local s = field_works.caller_for(side_num, h.x, h.y)
                    if s and s.id == u.id then field_works.call_phoinix(h.x, h.y); break end
                end
            end
        end
    end
end

return field_works
