-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'
-- promotion-handler.lua
-- Sarcastic Medal Citations & Dynamic Floating Banter (Prototype Step 3)
-- Wesnoth engine globals (not visible to static analysis)
---@diagnostic disable: undefined-global

local CITATIONS_L0_MEDAL = {
    _ "🎖️ Citation: Strict Protocol Adherence",
    _ "🎖️ Award: Unsolicited Tenacity",
    _ "🎖️ Notice: Hazard Pay Approved",
    _ "🎖️ Commendation: Orderly Retaliation",
    _ "🎖️ Certified: Surviving the Draft",
    _ "🎖️ Field Bandage: Civic Issue (+2 HP)"
}

local CITATIONS_L1_MEDAL = {
    _ "🎖️ Bronze Star: Merit under Hostile Audit",
    _ "🎖️ Commendation: Rational Composure",
    _ "🎖️ Certified: Senior Dispute Arbitrator",
    _ "🎖️ Citation: Excessive Civic Zeal"
}

local CITATIONS_PROMOTION = {
    _ "⭐ Promotion: Authorized to Question Orders",
    _ "⭐ Promoted: Certified Line Overseer",
    _ "⭐ Grade Advance: Seniority Validated",
    _ "⭐ Promoted: Field Tribunal Delegate"
}

local G9_MEDAL_NOTICES = {
    _ "🤖 [WEAR CYCLE LOGGED: TOLERANCE -10%]",
    _ "🤖 [ASSERTION: FRAME INTEGRITY SUB-OPTIMAL]",
    _ "🤖 [CHASSIS WEAR: WITHIN MUNICIPAL CODE]",
    _ "🤖 [PARCHMENT SCRIPT: SYNTAX AMBIGUOUS]"
}

local G9_PROMOTIONS = {
    _ "🤖 [NEURAL CURIE PROMOTION: LOGIC EXPANDED]",
    _ "🤖 [FRAME RE-INDEXED: MAINSERIES STATUS]"
}

-- add_repeating passes its own dummy arguments ({__quick_lua_event = true}), never
-- nil, so handlers must read the event from wesnoth.current.event_context.

-- A doctrine stage (sub-level) replaces the unit type but keeps its level. The
-- engine heals fully on every type change; Union stages grant only +2 HP and keep
-- poison and slow. Full level-ups, AMLAs and non-Union units keep engine healing.
-- An AMLA may also change the type at the same level (the Phoinix Elder's renewal),
-- so a unit that had nothing left to advance to is never a doctrine stage.
local function is_doctrine_stage(u, old_type, old_lvl, was_amla)
    return not was_amla and old_type ~= nil and u.type ~= old_type and u.level == old_lvl
        and tostring(u.type):sub(1, 5) == "LIUN_"
end

wesnoth.game_events.add_repeating("advance", function()
    local ec = wesnoth.current.event_context
    if not ec or not ec.x1 or not ec.y1 then return end
    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then return end
    -- Store temporary data in unit variables
    u.variables["promotion_hp"] = u.hitpoints
    u.variables["promotion_lvl"] = u.level
    u.variables["promotion_type"] = u.type
    u.variables["promotion_amla"] = #u.advances_to == 0
    u.variables["promotion_poisoned"] = u.status.poisoned
    u.variables["promotion_slowed"] = u.status.slowed
end)

local function pick_synced(tbl, u)
    if not tbl or #tbl == 0 then return "" end
    local turn = (wesnoth.current and wesnoth.current.turn) or 1
    local idx = ((u.x or 1) * 31 + (u.y or 1) * 17 + turn) % #tbl + 1
    return tbl[idx]
end

wesnoth.game_events.add_repeating("post_advance", function()
    local ec = wesnoth.current.event_context
    if not ec or not ec.x1 or not ec.y1 then return end
    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then return end
    local old_hp = u.variables["promotion_hp"]
    local old_lvl = u.variables["promotion_lvl"]
    local old_type = u.variables["promotion_type"]
    local was_amla = u.variables["promotion_amla"]
    local is_union = tostring(u.type):sub(1, 5) == "LIUN_"

    local is_golem = (u.race == "maidengolem")

    if old_hp and is_doctrine_stage(u, old_type, old_lvl, was_amla) then
        u.hitpoints = math.min(u.max_hitpoints, old_hp + 2)
        u.status.poisoned = u.variables["promotion_poisoned"]
        u.status.slowed = u.variables["promotion_slowed"]

        -- Dynamic Sarcastic Medal Floating Text (deterministic selection, 100% OOS safe)
        if wesnoth.interface and wesnoth.interface.float_label then
            if is_golem then
                local notice = pick_synced(G9_MEDAL_NOTICES, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#b388ff'>%s</span>", tostring(notice)))
            elseif u.level == 0 then
                local citation = pick_synced(CITATIONS_L0_MEDAL, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#ffd700'>%s</span>", tostring(citation)))
            else
                local citation = pick_synced(CITATIONS_L1_MEDAL, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#ffd700'>%s</span>", tostring(citation)))
            end
        end
    elseif is_union and old_lvl and u.level > old_lvl then
        -- Full Level Advancement
        if wesnoth.interface and wesnoth.interface.float_label then
            if is_golem then
                local notice = pick_synced(G9_PROMOTIONS, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#00e5ff'>%s</span>", tostring(notice)))
            else
                local promo = pick_synced(CITATIONS_PROMOTION, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#00e5ff'>%s</span>", tostring(promo)))
            end
        end
    end

    -- Cleanup variables
    u.variables["promotion_hp"] = nil
    u.variables["promotion_lvl"] = nil
    u.variables["promotion_type"] = nil
    u.variables["promotion_amla"] = nil
    u.variables["promotion_poisoned"] = nil
    u.variables["promotion_slowed"] = nil
end)

-- Combat kill banter: deadpan civic rationalist response to victory
wesnoth.game_events.add_repeating("die", function()
    local ec = wesnoth.current.event_context
    if not ec or not ec.x2 or not ec.y2 then return end
    local killer = wesnoth.units.get(ec.x2, ec.y2)
    local victim = wesnoth.units.get(ec.x1, ec.y1)
    if not killer or not victim then return end

    -- Only Liminal Union killers trigger civic commentary
    if not (killer.variables.lu_alloy or killer.variables.lu_conductor) then return end

    -- Check kill scenarios
    if wesnoth.interface and wesnoth.interface.float_label then
        local v_type = tostring(victim.type):lower()
        if v_type:find("mage") or v_type:find("adept") or v_type:find("lich") or v_type:find("necromancer") then
            wesnoth.interface.float_label(killer.x, killer.y, _ "<span color='#ffaa55'>\"Unlicensed Spellcraft Quashed.\"</span>")
        elseif (victim.level or 0) >= 2 and (killer.level or 0) == 0 then
            wesnoth.interface.float_label(killer.x, killer.y, _ "<span color='#ffd700'>\"Field Audit: Sovereignty Revoked.\"</span>")
        end
    end
end)
