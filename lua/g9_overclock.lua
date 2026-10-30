-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local g9_overclock = {}

-- Checks whether a unit can activate Emergency Overclock
function g9_overclock.can_overclock(u)
    if not u or u.hitpoints <= 4 then return false end
    if u.side ~= wesnoth.current.side then return false end
    if u.race ~= "maidengolem" then return false end
    if u.variables.lu_overclocked then return false end
    if (u.attacks_left or 0) <= 0 then return false end
    return true
end

-- Activates Emergency Overclock on a G9 Warform
function g9_overclock.activate(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not g9_overclock.can_overclock(u) then
        if u and wesnoth.interface and wesnoth.interface.float_label then
            if u.hitpoints <= 4 then
                wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ff5555'>[CRITICAL: CORE INTEGRITY ≤4 HP]</span>")
            elseif u.variables.lu_overclocked then
                wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffaa33'>[CORE ALREADY OVERCLOCKED]</span>")
            elseif (u.attacks_left or 0) <= 0 then
                wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffaa33'>[NO ATTACKS REMAINING]</span>")
            end
        end
        return
    end

    u.variables.lu_overclocked = true

    -- Apply combat boost: +1 strike, +2 damage, and Stun weapon special
    u:add_modification("object", {
        id = "LIUN_g9_overclock_mod",
        silent = true,
        { "effect", {
            apply_to = "attack",
            range = "melee",
            increase_attacks = 1,
            increase_damage = 2,
            { "set_specials", {
                mode = "append",
                { "stun", {
                    id = "stun",
                    name = _ "stun",
                    description = _ "This attack hits so hard that the opponent is dazed and can no longer enforce a zone of control. The effect wears off on the opponent’s next turn."
                }}
            }}
        }},
        { "effect", {
            apply_to = "overlay",
            add = "projectiles/misfire-spark-1.png"
        }}
    })

    -- Play sound and display terminal notices
    wesnoth.audio.play_sound("lightning.ogg")
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ff3333'>[PROTOCOL BYPASS: OVERCLOCK + STUN ACTIVE]</span>")
    end
end

-- Handles turn end / side turn to apply thermal stress and clean up overclock
function g9_overclock.on_side_turn_end(side_num)
    side_num = side_num or wesnoth.current.side
    local golems = wesnoth.units.find_on_map({
        side = side_num,
        race = "maidengolem"
    })

    for idx, u in ipairs(golems) do
        if u.variables.lu_overclocked then
            u:remove_modifications({ id = "LIUN_g9_overclock_mod" })
            u.variables.lu_overclocked = false

            -- Core thermal stress damage (-4 HP, cannot kill, min 1 HP)
            local dmg = math.min(3, math.max(0, u.hitpoints - 1))
            if dmg > 0 then
                u.hitpoints = u.hitpoints - dmg
                if wesnoth.interface and wesnoth.interface.float_label then
                    wesnoth.interface.float_label(u.x, u.y, string.format(tostring(_ "<span color='#ff5555'>-%d HP [CORE THERMAL STRESS]</span>"), dmg))
                end
            end
        end
    end
end

return g9_overclock
