-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local phoinix_courier = {}

-- Axial hex distance helper
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

-- Checks if there is an active allied Conductor within `radius` hexes of (x, y)
function phoinix_courier.is_near_conductor(side, x, y, radius)
    radius = radius or 3
    local reso = wesnoth.require("~add-ons/liminal-union/lua/resonance.lua")
    local conductors = wesnoth.units.find_on_map({ side = side })
    for idx, c in ipairs(conductors) do
        if c.hitpoints > 0 and reso.is_conductor(c) and hex_distance(x, y, c.x, c.y) <= radius then
            return true
        end
    end
    return false
end

-- Checks if a unit at (x, y) is adjacent to an airborne Phoinix currently relaying Conductance
function phoinix_courier.is_adjacent_to_relaying_phoinix(u)
    if not u or u.hitpoints <= 0 then return false end
    local phoinixes = wesnoth.units.find_on_map({
        side = u.side,
        race = "marinephoinix",
        { "filter_adjacent", { id = u.id } }
    })

    for idx, p in ipairs(phoinixes) do
        if p.hitpoints > 0 and phoinix_courier.is_near_conductor(u.side, p.x, p.y, 3) then
            return true
        end
    end
    return false
end

-- State tracking for memorial archive locations: "x,y" -> side
local memorial_archives = {}

-- Handles Phoinix death: leaves an ashen Civic Memorial Archive on the hex
function phoinix_courier.on_phoinix_died(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u or u.race ~= "marinephoinix" then return end

    local key = string.format("%d,%d", ctx.x1, ctx.y1)
    memorial_archives[key] = u.side

    -- Visual marker item on the hex
    wesnoth.wml_actions.item({
        x = ctx.x1,
        y = ctx.y1,
        image = "projectiles/misfire-spark-2.png"
    })

    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(ctx.x1, ctx.y1, _ "<span color='#ffaa33'>\"Registry Archive Preserved\"</span>")
    end
end

-- Handles movement onto a Memorial Archive hex to recover XP
function phoinix_courier.on_unit_moved(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local key = string.format("%d,%d", ctx.x1, ctx.y1)
    local archive_side = memorial_archives[key]
    if not archive_side then return end

    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u or u.side ~= archive_side then return end

    -- Recover the archive (+3 XP)
    memorial_archives[key] = nil
    wesnoth.wml_actions.remove_item({
        x = ctx.x1,
        y = ctx.y1,
        image = "projectiles/misfire-spark-2.png"
    })

    u.experience = u.experience + 3
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffd700'>+3 XP [CIVIC ARCHIVE RECOVERED]</span>")
    end
end

return phoinix_courier

