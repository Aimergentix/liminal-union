-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local portal_warden = {}

local function is_warden(u)
    return u:matches({ ability = "LIUN_portal_warden" })
end

local function has_adjacent_phoinix(u)
    return #wesnoth.units.find_on_map({
        side = u.side,
        race = "marinephoinix",
        { "filter_adjacent", { id = u.id } }
    }) > 0
end

local function open_portal(u)
    if u.variables.lu_portal_open then return end
    u.variables.lu_portal_open = true
    u:add_modification("object", {
        id = "LIUN_portal_open_mod",
        silent = true,
        { "effect", { apply_to = "overlay", add = "overlays/portal-open.webp" } }
    })
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#c79bff'>Portal Open</span>")
    end
end

local function close_portal(u)
    u.variables.lu_portal_ready = nil
    if u.variables.lu_portal_open then
        u.variables.lu_portal_open = nil
        u:remove_modifications({ id = "LIUN_portal_open_mod" })
    end
end

-- One-way tunnels from each side's villages to free hexes beside its open portals.
function portal_warden.install_tunnels()
    for side_num = 1, #wesnoth.sides do
        wesnoth.wml_actions.tunnel({
            id = "LIUN_portal_side_" .. side_num,
            bidirectional = false,
            { "source", {
                gives_income = true,
                formula = "owner_side = teleport_unit.side_number and (unit = teleport_unit or not unit) where unit = unit_at(loc)"
            } },
            { "target", {
                formula = "not unit_at(loc)",
                { "filter_adjacent_location", {
                    { "filter", {
                        side = side_num,
                        { "filter_wml", { { "variables", { lu_portal_open = true } } } }
                    } }
                } }
            } },
            { "filter", {
                side = side_num,
                race = "marinecommand",
                canrecruit = false,
                { "not", { ability = "LIUN_portal_warden" } }
            } }
        })
    end
end

-- A Warden that stood still since its side's last turn is ready; a Phoinix beside it opens the portal.
function portal_warden.on_side_turn(side_num)
    side_num = side_num or wesnoth.current.side
    for idx, u in ipairs(wesnoth.units.find_on_map({ side = side_num, ability = "LIUN_portal_warden" })) do
        if u.variables.lu_portal_moved then
            u.variables.lu_portal_moved = nil
            close_portal(u)
        else
            u.variables.lu_portal_ready = true
            if has_adjacent_phoinix(u) then open_portal(u) end
        end
    end
end

-- The default AI would walk an open portal shut, so an AI side's Warden holds its ground. Runs after moves refresh.
function portal_warden.on_turn_refresh(side_num)
    side_num = side_num or wesnoth.current.side
    if not wesnoth.require("~add-ons/liminal-union/lua/side_control.lua").is_ai_side(side_num) then return end
    for idx, u in ipairs(wesnoth.units.find_on_map({ side = side_num, ability = "LIUN_portal_warden" })) do
        if u.variables.lu_portal_open then u.moves = 0 end
    end
end

-- Detects the tunnel step: consecutive route hexes that are not neighbours. Ends the move there.
function portal_warden.on_enter_hex(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx.x2 or wesnoth.map.distance_between(ctx.x1, ctx.y1, ctx.x2, ctx.y2) <= 1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u or u.race ~= "marinecommand" then return end
    u.variables.lu_portal_arrived = true
    wesnoth.cancel_action()
end

function portal_warden.on_unit_moved(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u then return end

    -- Arrival works like recruitment: no moves and no attack this turn.
    if u.variables.lu_portal_arrived then
        u.variables.lu_portal_arrived = nil
        u.moves = 0
        u.attacks_left = 0
        wesnoth.audio.play("lightning.ogg")
    end

    if is_warden(u) then
        u.variables.lu_portal_moved = true
        close_portal(u)
    elseif u.race == "marinephoinix" then
        for idx, w in ipairs(wesnoth.units.find_on_map({
            side = u.side,
            ability = "LIUN_portal_warden",
            { "filter_adjacent", { id = u.id } }
        })) do
            if w.variables.lu_portal_ready then open_portal(w) end
        end
    end
end

-- A Warden placed this turn has not yet stood still for a round.
function portal_warden.on_unit_placed(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if u and is_warden(u) then u.variables.lu_portal_moved = true end
end

return portal_warden
