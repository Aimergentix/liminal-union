-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local maiden_wingsuit = {}

-- Checks if a hex is elevated terrain (Hills or Mountains)
local function is_elevated_terrain(x, y)
    if not x or not y then return false end
    local map = wesnoth.current.map
    if not map then return false end
    local code = map[{x, y}]
    if not code then return false end
    local base = code:match("^([^%^]+)") or code
    local first_char = base:sub(1, 1)
    return first_char == "H" or first_char == "M"
end

-- Evaluates all Maidens at side turn start and grants Wingsuit Thermal Glide if on high ground
function maiden_wingsuit.on_side_turn(side_num)
    side_num = side_num or wesnoth.current.side
    local reso = wesnoth.require("~add-ons/liminal-union/lua/resonance.lua")
    local units = wesnoth.units.find_on_map({ side = side_num })

    for idx, u in ipairs(units) do
        local alloy = reso.get_unit_alloy(u)
        if alloy == "pyrite" then
            u:remove_modifications({ id = "LIUN_wingsuit_slingshot" })

            if is_elevated_terrain(u.x, u.y) and not (u.status.poisoned or u.status.slowed) then
                u:add_modification("object", {
                    id = "LIUN_wingsuit_slingshot",
                    silent = true,
                    { "effect", {
                        apply_to = "movement",
                        increase = 1
                    }},
                    { "effect", {
                        apply_to = "overlay",
                        add = "overlays/wingsuit.png"
                    }},
                    { "effect", {
                        apply_to = "new_ability",
                        { "abilities", {
                            { "skirmisher", {
                                id = "LIUN_wingsuit_glide",
                                name = _ "wingsuit glide",
                                female_name = _ "female^wingsuit glide",
                                description = _ "Gliding down from elevated hills or mountain ridges, this maiden gains +1 MP and ignores enemy Zones of Control for this turn."
                            }}
                        }}
                    }}
                })
                u.moves = u.max_moves

                if wesnoth.interface and wesnoth.interface.float_label then
                    wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffdd55'>🪽 Wingsuit Glide (+1 MP, Skirmish)</span>")
                end
            end
        else
            u:remove_modifications({ id = "LIUN_wingsuit_slingshot" })
        end
    end
end

-- Cleans up glide modifications at side turn end
function maiden_wingsuit.on_side_turn_end(side_num)
    side_num = side_num or wesnoth.current.side
    local units = wesnoth.units.find_on_map({ side = side_num })

    for idx, u in ipairs(units) do
        u:remove_modifications({ id = "LIUN_wingsuit_slingshot" })
    end
end

return maiden_wingsuit

