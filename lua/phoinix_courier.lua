-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local phoinix_courier = {}

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

