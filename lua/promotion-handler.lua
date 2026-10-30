-- #textdomain wesnoth-liminal-union
-- promotion-handler.lua
-- Sarcastic Medal Citations & Dynamic Floating Banter (Prototype Step 3)
-- Wesnoth engine globals (not visible to static analysis)
---@diagnostic disable: undefined-global

local CITATIONS_L0_MEDAL = {
    "🎖️ Citation: Strict Protocol Adherence",
    "🎖️ Award: Unsolicited Tenacity",
    "🎖️ Notice: Hazard Pay Approved",
    "🎖️ Commendation: Orderly Retaliation",
    "🎖️ Certified: Surviving the Draft",
    "🎖️ Field Bandage: Civic Issue (+2 HP)"
}

local CITATIONS_L1_MEDAL = {
    "🎖️ Bronze Star: Merit under Hostile Audit",
    "🎖️ Commendation: Rational Composure",
    "🎖️ Certified: Senior Dispute Arbitrator",
    "🎖️ Citation: Excessive Civic Zeal"
}

local CITATIONS_PROMOTION = {
    "⭐ Promotion: Authorized to Question Orders",
    "⭐ Promoted: Certified Line Overseer",
    "⭐ Grade Advance: Seniority Validated",
    "⭐ Promoted: Field Tribunal Delegate"
}

local G9_MEDAL_NOTICES = {
    "🤖 [WEAR CYCLE LOGGED: TOLERANCE -10%]",
    "🤖 [ASSERTION: FRAME INTEGRITY SUB-OPTIMAL]",
    "🤖 [CHASSIS WEAR: WITHIN MUNICIPAL CODE]",
    "🤖 [PARCHMENT SCRIPT: SYNTAX AMBIGUOUS]"
}

local G9_PROMOTIONS = {
    "🤖 [NEURAL CURIE PROMOTION: LOGIC EXPANDED]",
    "🤖 [FRAME RE-INDEXED: MAINSERIES STATUS]"
}

wesnoth.game_events.add_repeating("advance", function(context)
    local ec = context or wesnoth.current.event_context
    if not ec or not ec.x1 or not ec.y1 then return end
    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then return end
    -- Store temporary data in unit variables
    u.variables["promotion_hp"] = u.hitpoints
    u.variables["promotion_lvl"] = u.level
    u.variables["promotion_poisoned"] = u.status.poisoned
    u.variables["promotion_slowed"] = u.status.slowed
end)

local function pick_synced(tbl, u)
    if not tbl or #tbl == 0 then return "" end
    local turn = (wesnoth.current and wesnoth.current.turn) or 1
    local idx = ((u.x or 1) * 31 + (u.y or 1) * 17 + turn) % #tbl + 1
    return tbl[idx]
end

wesnoth.game_events.add_repeating("post_advance", function(context)
    local ec = context or wesnoth.current.event_context
    if not ec or not ec.x1 or not ec.y1 then return end
    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then return end
    local old_hp = u.variables["promotion_hp"]
    local old_lvl = u.variables["promotion_lvl"]

    local is_golem = (u.race == "maidengolem")

    -- If level is unchanged, it was an intermediate medal
    if old_hp and u.level == old_lvl then
        u.hitpoints = math.min(u.max_hitpoints, old_hp + 2)
        u.status.poisoned = u.variables["promotion_poisoned"]
        u.status.slowed = u.variables["promotion_slowed"]

        -- Dynamic Sarcastic Medal Floating Text (deterministic selection, 100% OOS safe)
        if wesnoth.interface and wesnoth.interface.float_label then
            if is_golem then
                local notice = pick_synced(G9_MEDAL_NOTICES, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#b388ff'>%s</span>", notice))
            elseif u.level == 0 then
                local citation = pick_synced(CITATIONS_L0_MEDAL, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#ffd700'>%s</span>", citation))
            else
                local citation = pick_synced(CITATIONS_L1_MEDAL, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#ffd700'>%s</span>", citation))
            end
        end
    elseif old_lvl and u.level > old_lvl then
        -- Full Level Advancement
        if wesnoth.interface and wesnoth.interface.float_label then
            if is_golem then
                local notice = pick_synced(G9_PROMOTIONS, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#00e5ff'>%s</span>", notice))
            else
                local promo = pick_synced(CITATIONS_PROMOTION, u)
                wesnoth.interface.float_label(u.x, u.y, string.format("<span color='#00e5ff'>%s</span>", promo))
            end
        end
    end

    -- Cleanup variables
    u.variables["promotion_hp"] = nil
    u.variables["promotion_lvl"] = nil
    u.variables["promotion_poisoned"] = nil
    u.variables["promotion_slowed"] = nil
end)

-- Combat kill banter: deadpan civic rationalist response to victory
wesnoth.game_events.add_repeating("die", function(context)
    local ec = context or wesnoth.current.event_context
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
            wesnoth.interface.float_label(killer.x, killer.y, "<span color='#ffaa55'>\"Unlicensed Spellcraft Quashed.\"</span>")
        elseif (victim.level or 0) >= 2 and (killer.level or 0) == 0 then
            wesnoth.interface.float_label(killer.x, killer.y, "<span color='#ffd700'>\"Field Audit: Sovereignty Revoked.\"</span>")
        end
    end
end)
