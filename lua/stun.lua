-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Stun: a hit from a weapon with a special of id "stun" removes the struck unit's zone
-- of control until its own side's next turn begins. Level 0 units have no zone of
-- control and are not affected; a stunned unit is not stunned again.
-- Sources: the G9 Overclock object (lua/g9_overclock.lua, offense only, because the
-- overclock ends with its owner's turn) and WEAPON_SPECIAL_LIUN_STUN (Merman Brawler tail,
-- offense and defense). Wired to attacker_hits, defender_hits and side turn in faction.cfg.

local stun = {}

local SPECIAL_ID = "stun"
local STUN_MOD = "LIUN_stun_mod"

-- True if the event weapon (a [weapon] / [second_weapon] child) carries the stun special.
function stun.has_stun(weapon)
    if not weapon then return false end
    local specials = wml.get_child(weapon, "specials")
    if not specials then return false end
    for idx, sp in ipairs(specials) do
        if sp[2].id == SPECIAL_ID then return true end
    end
    return false
end

function stun.apply(u)
    if not u or u.hitpoints <= 0 or u.level < 1 or u.status.stunned then return end
    u.status.stunned = true
    u:add_modification("object", {
        id = STUN_MOD,
        silent = true,
        { "effect", { apply_to = "zoc", value = false } },
        { "effect", { apply_to = "image_mod", add = "CS(50,50,0)" } }
    })
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#ffcc33'>stunned</span>")
    end
end

-- Attacker hits: the defender (x2, y2) is struck by the attacker's weapon.
function stun.on_attacker_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x2 or not ctx.y2 then return end
    if stun.has_stun(wml.get_child(ctx, "weapon")) then
        stun.apply(wesnoth.units.get(ctx.x2, ctx.y2))
    end
end

-- Defender hits: the attacker (x1, y1) is struck by the defender's weapon.
function stun.on_defender_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    if stun.has_stun(wml.get_child(ctx, "second_weapon")) then
        stun.apply(wesnoth.units.get(ctx.x1, ctx.y1))
    end
end

-- Stun wears off when the stunned unit's own side begins its turn.
function stun.on_side_turn(side_num)
    side_num = side_num or wesnoth.current.side
    for idx, u in ipairs(wesnoth.units.find_on_map({ side = side_num, status = "stunned" })) do
        u:remove_modifications({ id = STUN_MOD })
        u.status.stunned = false
    end
end

return stun
