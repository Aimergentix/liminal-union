-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

local g9_overclock = {}

-- Checks whether a unit can activate Emergency Overclock.
-- in_attack: called from the attack event, where the engine has already spent the attack
-- (attack.cpp sets attacks_left before firing "attack"), so attacks_left is not checked.
function g9_overclock.can_overclock(u, in_attack)
    if not u or u.hitpoints <= 4 then return false end
    if u.side ~= wesnoth.current.side then return false end
    if u.race ~= "maidengolem" then return false end
    if u.variables.lu_overclocked then return false end
    if not in_attack and (u.attacks_left or 0) <= 0 then return false end
    return true
end

-- Activates Emergency Overclock on a G9 Warform
function g9_overclock.activate(ctx, in_attack)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not g9_overclock.can_overclock(u, in_attack) then
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
    u:remove_modifications({ id = "LIUN_g9_overclock_mod" })

    -- Apply combat boost: +1 melee strike and the Stun weapon special
    u:add_modification("object", {
        id = "LIUN_g9_overclock_mod",
        silent = true,
        { "effect", {
            apply_to = "attack",
            range = "melee",
            increase_attacks = 1,
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
    wesnoth.audio.play("lightning.ogg")
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ff3333'>[PROTOCOL BYPASS: OVERCLOCK + STUN ACTIVE]</span>")
    end
end

-- AI tactical reflex: automatically activate Overclock before melee combat under clear tactical conditions
function g9_overclock.on_attack(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 or not ctx.x2 or not ctx.y2 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not g9_overclock.can_overclock(u, true) then return end

    -- The boost only changes melee attacks; do not spend core integrity on anything else.
    local weapon = wml.get_child(ctx, "weapon")
    if not weapon or weapon.range ~= "melee" then return end

    -- side.controller is synced in live games, but replays keep the starting controller.
    -- See LUA_GUIDELINES.md §5 before relying on it further.
    local side_info = wesnoth.sides[u.side]
    if not side_info or side_info.controller ~= "ai" then return end

    local d = wesnoth.units.get(ctx.x2, ctx.y2)
    if not d or d.hitpoints <= 0 then return end

    -- Tactical conditions (the earlier "ZOC or Level 1+" test passed for almost every
    -- enemy, so the reflex fired in 41 of 42 AI G9 engagements):
    -- 1. Safe core integrity: >= 12 HP, so -3 HP thermal stress leaves reserves,
    --    unless the target is the enemy leader.
    -- 2. Payoff: the boost opens a kill window (see likely_damage), or the target is the
    --    enemy leader or Level 2+, where Stun stripping its ZOC matters most.
    local safe_hp = (u.hitpoints >= 12) or d.canrecruit
    if not safe_hp then return end

    local damage, strikes = weapon.damage or 0, weapon.number or 0
    local mult = (100 - wesnoth.units.resistance_against(d, weapon.type or "", false)) / 100
    local kill_window = d.hitpoints > g9_overclock.likely_damage(damage, strikes, mult)
        and d.hitpoints <= g9_overclock.likely_damage(damage, strikes + 1, mult)
    local high_value = d.canrecruit or d.level >= 2
    if kill_window or high_value then
        g9_overclock.activate({ x1 = u.x, y1 = u.y }, true)
    end
end

-- Damage if about half the strikes land (rounded up), after the defender's resistance.
-- Ignores time of day and leadership; a deterministic estimate, safe in synced code.
function g9_overclock.likely_damage(damage, strikes, mult)
    local per_hit = math.max(1, math.floor(damage * mult + 0.5))
    return per_hit * math.ceil(strikes / 2)
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

            -- Core thermal stress damage (-3 HP, cannot kill, min 1 HP)
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
