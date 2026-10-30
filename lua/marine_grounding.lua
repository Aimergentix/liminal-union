-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

---@diagnostic disable: undefined-global

local marine_grounding = {}

-- Canonical odd-r hex distance helper
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

-- Checks if a unit is eligible to deploy the Salt-Grounding Pylum
function marine_grounding.can_ground(u)
    if not u or u.hitpoints <= 0 then return false end
    if u.side ~= wesnoth.current.side then return false end
    if u.race ~= "marinecommand" and u.variables.lu_alloy ~= "kryonite" then return false end
    if u.variables.lu_grounded then return false end
    return true
end

-- Refreshes anti-sorcery auras around all active grounded Marines
function marine_grounding.update_wards()
    -- 1. Strip transient grounding wards from all units on map
    local all_units = wesnoth.units.find_on_map({})
    for idx, u in ipairs(all_units) do
        u:remove_modifications({ id = "LIUN_grounding_ward_ally" })
        u:remove_modifications({ id = "LIUN_grounding_dampen_enemy" })
    end

    -- 2. Find all active grounded Marines
    local grounded_marines = {}
    for idx, u in ipairs(all_units) do
        if u.variables.lu_grounded and u.hitpoints > 0 then
            table.insert(grounded_marines, u)
        end
    end

    if #grounded_marines == 0 then return end

    -- 3. Apply auras to adjacent units
    for idx, gm in ipairs(grounded_marines) do
        local adjacents = wesnoth.units.find_on_map({
            { "filter_adjacent", { id = gm.id } }
        })

        for jdx, target in ipairs(adjacents) do
            if target.hitpoints > 0 then
                if target.side == gm.side then
                    -- Adjacent Ally: +20% Elemental Warding (Fire, Cold, Arcane)
                    target:add_modification("object", {
                        id = "LIUN_grounding_ward_ally",
                        silent = true,
                        { "effect", {
                            apply_to = "resistance",
                            { "resistance", {
                                fire = -20,
                                cold = -20,
                                arcane = -20
                            }}
                        }}
                    })
                else
                    -- Adjacent Enemy: Ground magical accuracy (max 50% CTH) & -20% elemental damage
                    target:add_modification("object", {
                        id = "LIUN_grounding_dampen_enemy",
                        silent = true,
                        { "effect", {
                            apply_to = "attack",
                            type = "fire,cold,arcane",
                            { "set_specials", {
                                mode = "append",
                                { "damage", {
                                    id = "LIUN_grounding_elemental_dampen",
                                    name = _ "grounded",
                                    description = _ "Magical currents are grounded into the earth: -20% damage on elemental attacks.",
                                    multiply = 0.8
                                }},
                                { "chance_to_hit", {
                                    id = "LIUN_grounding_null_magic",
                                    name = _ "grounded",
                                    description = _ "Magical accuracy is grounded by the Salt-Grounding Pylum: maximum 50% chance to hit.",
                                    value = 50,
                                    priority = 100,
                                    cumulative = false
                                }}
                            }}
                        }}
                    })
                end
            end
        end
    end
end

-- Activates Salt-Grounding Pylum on a Marine
function marine_grounding.activate(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not marine_grounding.can_ground(u) then
        if u and wesnoth.interface and wesnoth.interface.float_label then
            if u.variables.lu_grounded then
                wesnoth.interface.float_label(u.x, u.y, _ "<span color='#55ffff'>[PYLUM ALREADY DEPLOYED]</span>")
            else
                wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffaa33'>[GROUNDING UNAVAILABLE]</span>")
            end
        end
        return
    end

    -- Mark grounded
    u.variables.lu_grounded = true

    -- Vulnerability Cost: 0 MP for turn + +20% vulnerability to melee Blade/Impact
    u.moves = 0
    u:add_modification("object", {
        id = "LIUN_grounding_stance_mod",
        silent = true,
        { "effect", {
            apply_to = "resistance",
            { "resistance", {
                blade = 20,
                impact = 20
            }}
        }},
        { "effect", {
            apply_to = "overlay",
            add = "icons/arcane.webp"
        }}
    })

    -- Sound effect and floating notification
    wesnoth.audio.play_sound("lightning.ogg")
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#55ffff'>⚡ Salt-Grounding Pylum [0 MP, Ward Active]</span>")
    end

    -- Update wards across adjacent hexes
    marine_grounding.update_wards()
end

-- Handles unit movement to update aura boundaries dynamically
function marine_grounding.on_unit_moved(ctx)
    marine_grounding.update_wards()
end

-- Handles unit death to clean up wards if a grounded marine falls
function marine_grounding.on_unit_died(ctx)
    marine_grounding.update_wards()
end

-- Handles turn end / side turn to reset grounded stance
function marine_grounding.on_side_turn_end(side_num)
    side_num = side_num or wesnoth.current.side
    local marines = wesnoth.units.find_on_map({
        side = side_num,
        race = "marinecommand"
    })

    for idx, u in ipairs(marines) do
        if u.variables.lu_grounded then
            u:remove_modifications({ id = "LIUN_grounding_stance_mod" })
            u.variables.lu_grounded = nil
        end
    end

    marine_grounding.update_wards()
end

return marine_grounding

