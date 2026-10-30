-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local formation = {}

-- Returns true if the unit at (x, y) has the specified ability id.
function formation.has_formation_ability(x, y, ability_id)
    local u = wesnoth.units.get(x, y)
    if not u then
        return false
    end
    local abilities = wml.get_child(u.__cfg, "abilities")
    if abilities then
        for ability in wml.child_range(abilities, "dummy") do
            if ability.id == ability_id then
                return true
            end
        end
    end
    return false
end

return formation
