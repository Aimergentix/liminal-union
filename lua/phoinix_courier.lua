-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local phoinix_courier = {}

-- Memorial archives live in a scenario variable, so saved games and replays keep
-- them; a module-level Lua table was lost on every load.
local ARCHIVES = "LIUN_memorial_archives"

local function find_archive(list, x, y)
    for i, a in ipairs(list) do
        if a.x == x and a.y == y then return i end
    end
    return nil
end

local ASH_IMAGE = "projectiles/misfire-spark-2.png"

function phoinix_courier.has_archive(x, y, side)
    local list = wml.array_access.get(ARCHIVES)
    local i = find_archive(list, x, y)
    return i ~= nil and list[i].side == side
end

-- Archives (ash) of one side, in stored order: { {x=, y=, side=}, ... }
function phoinix_courier.archives_of(side)
    local out = {}
    for _, a in ipairs(wml.array_access.get(ARCHIVES)) do
        if a.side == side then out[#out + 1] = { x = a.x, y = a.y, side = a.side } end
    end
    return out
end

-- Removes an archive and its marker; used when a Shieldguard rekindles the ash.
function phoinix_courier.take_archive(x, y, side)
    local list = wml.array_access.get(ARCHIVES)
    local i = find_archive(list, x, y)
    if not i or list[i].side ~= side then return false end
    table.remove(list, i)
    wml.array_access.set(ARCHIVES, list)
    wesnoth.wml_actions.remove_item({ x = x, y = y, image = ASH_IMAGE })
    return true
end

-- Handles Phoinix death: leaves an ashen Civic Memorial Archive on the hex
function phoinix_courier.on_phoinix_died(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u or u.race ~= "marinephoinix" then return end

    local list = wml.array_access.get(ARCHIVES)
    local i = find_archive(list, ctx.x1, ctx.y1)
    if i then
        list[i].side = u.side
    else
        list[#list + 1] = { x = ctx.x1, y = ctx.y1, side = u.side }
    end
    wml.array_access.set(ARCHIVES, list)

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
    local list = wml.array_access.get(ARCHIVES)
    local i = find_archive(list, ctx.x1, ctx.y1)
    if not i then return end

    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u or u.side ~= list[i].side then return end

    -- Recover the archive (+3 XP)
    table.remove(list, i)
    wml.array_access.set(ARCHIVES, list)
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

