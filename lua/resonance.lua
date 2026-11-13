-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Wesnoth engine globals (not visible to static analysis)
---@diagnostic disable: undefined-global

local resonance = {}

-- Resolves the armor alloy for a unit (robust to [base_unit] variable dropping).
-- The cache lu_alloy is valid only for the type it was read from (lu_alloy_type):
-- a Pyrite Mechatronic promoted to Arcanite Techtronic must not keep "pyrite".
local function remember(u, alloy)
    u.variables.lu_alloy = alloy
    u.variables.lu_alloy_type = u.type
    return alloy
end

function resonance.get_unit_alloy(u)
    if not u or u.hitpoints <= 0 then return nil end
    local var_alloy = u.variables.lu_alloy
    if var_alloy and var_alloy ~= "" and u.variables.lu_alloy_type == u.type then return var_alloy end

    local cfg = u.__cfg
    if cfg then
        local abilities = wml.get_child(cfg, "abilities")
        if abilities then
            for ab in wml.child_range(abilities, "dummy") do
                if ab.id == "LIUN_resonance_pyrite" then
                    return remember(u, "pyrite")
                elseif ab.id == "LIUN_resonance_kryonite" then
                    return remember(u, "kryonite")
                elseif ab.id == "LIUN_resonance_arcanite" then
                    return remember(u, "arcanite")
                end
            end
        end
    end

    local utype = tostring(u.type or "")
    if utype:sub(1, 5) == "LIUN_" then
        if u.race == "maidengolem" then
            return remember(u, "arcanite")
        elseif u.race == "maidencommand" then
            return remember(u, "pyrite")
        elseif u.race == "marinecommand" then
            return remember(u, "kryonite")
        end
    end

    u.variables.lu_alloy = nil
    u.variables.lu_alloy_type = nil
    return nil
end

-- Checks if a unit has a specific dummy ability id
function resonance.has_dummy_ability(u, ability_id)
    if not u or u.hitpoints <= 0 then return false end
    local cfg = u.__cfg
    if cfg then
        local abilities = wml.get_child(cfg, "abilities")
        if abilities then
            for ab in wml.child_range(abilities, "dummy") do
                if ab.id == ability_id then
                    return true
                end
            end
        end
    end
    return false
end

-- Checks if a unit is a Conductor officer
function resonance.is_conductor(u)
    if not u or u.hitpoints <= 0 then return false end
    if u.variables.lu_conductor == "yes" then return true end

    local cfg = u.__cfg
    if cfg then
        local abilities = wml.get_child(cfg, "abilities")
        if abilities then
            for ab in wml.child_range(abilities, "dummy") do
                if ab.id == "LIUN_conductor" then
                    u.variables.lu_conductor = "yes"
                    return true
                end
            end
        end
    end

    local utype = tostring(u.type or "")
    if utype:sub(1, 5) == "LIUN_" then
        if utype:find("Ensign") or utype:find("Cornet") or utype:find("Captain") or utype:find("Colonel") then
            u.variables.lu_conductor = "yes"
            return true
        end
    end

    return false
end

-- Calculates the raw pod tier based on adjacent same-alloy allies (alive, not poisoned)
-- Pods containing a slowed unit maintain Tier 1 Resonance.
function resonance.calculate_pod_tier(u)
    if not u or u.hitpoints <= 0 then return 0 end
    if u.status.poisoned then return 0 end

    local alloy = resonance.get_unit_alloy(u)
    if not alloy then return 0 end

    local raw_allies = wesnoth.units.find_on_map({
        side = u.side,
        { "filter_adjacent", { id = u.id } }
    })

    local non_slowed_allies = 0
    local slowed_allies = 0
    for idx, a in ipairs(raw_allies) do
        if a.hitpoints > 0 and not a.status.poisoned then
            if resonance.get_unit_alloy(a) == alloy then
                if a.status.slowed then
                    slowed_allies = slowed_allies + 1
                else
                    non_slowed_allies = non_slowed_allies + 1
                end
            end
        end
    end

    local total_allies = non_slowed_allies + slowed_allies
    local pod_size = total_allies + 1
    if pod_size < 2 then
        return 0
    end

    -- If u itself is slowed:
    if u.status.slowed then
        -- Slowed unit maintains Tier 1 Resonance if adjacent to at least one non-slowed ally
        if non_slowed_allies >= 1 then
            return 1
        else
            return 0
        end
    end

    -- If u is not slowed:
    local non_slowed_pod_size = non_slowed_allies + 1
    local normal_tier = 0
    if non_slowed_pod_size >= 4 then normal_tier = 3
    elseif non_slowed_pod_size >= 3 then normal_tier = 2
    elseif non_slowed_pod_size >= 2 then normal_tier = 1
    end

    if slowed_allies > 0 then
        -- Pod contains a slowed unit; maintain at least Tier 1 Resonance
        return math.max(1, normal_tier)
    else
        return normal_tier
    end
end

-- Calculates the resonance tier based on Phase 5.1 rules:
-- Active IMMEDIATELY upon formation/adjacency (on recruitment, on movement, and stationary).
-- Pod tiers: Tier 1 (2 units), Tier 2 (3 units), Tier 3 (4+ units).
function resonance.get_tier(u)
    if not u or u.hitpoints <= 0 then return 0 end
    if u.status.poisoned then
        return 0
    end

    local alloy = resonance.get_unit_alloy(u)
    if not alloy then return 0 end

    -- Live pod tier based on adjacent same-alloy allies
    return resonance.calculate_pod_tier(u)
end

-- Checks if a level 0 Union unit exerts Formation ZOC: active whenever the unit is in
-- a Resonance pod (Tier >= 1) or stands beside an allied unpoisoned officer (Conductor).
function resonance.get_formation_zoc(u)
    if not u or u.hitpoints <= 0 then return false end
    if u.level ~= 0 then return false end
    if not resonance.get_unit_alloy(u) and not resonance.is_conductor(u) then return false end
    if u.status.poisoned then return false end

    if resonance.get_tier(u) >= 1 then
        return true
    end

    local adjacent = wesnoth.units.find_on_map({
        side = u.side,
        { "filter_adjacent", { id = u.id } }
    })
    for idx, a in ipairs(adjacent) do
        if a.hitpoints > 0 and not a.status.poisoned and resonance.is_conductor(a) then
            return true
        end
    end
    return false
end

-- Updates a single unit based on Conductor proximity.
-- Marks adjacent liminal allies of a Conductor with a status overlay and variable only; the
-- damage bonus comes from ABILITY_CONDUCTOR leadership, and the unit's alignment never changes.
function resonance.update_unit_alignment(u)
    if not u or u.hitpoints <= 0 then return end
    if u.alignment ~= "liminal" then
        return
    end

    -- Check for adjacent allied Conductors or self as Conductor
    local has_conductor = resonance.is_conductor(u)
    if not has_conductor then
        local raw_conductors = wesnoth.units.find_on_map({
            side = u.side,
            { "filter_adjacent", { id = u.id } }
        })

        for idx, c in ipairs(raw_conductors) do
            if c.hitpoints > 0 and resonance.is_conductor(c) then
                has_conductor = true
                break
            end
        end
    end

    local was_conducted = u.variables.lu_conducted
    u.variables.lu_conducted = has_conductor

    -- Visual Status Icon (floating label consolidated into Resonance I/II/III display)
    u:remove_modifications({ id = "LIUN_conducted_overlay" })
    if has_conductor then
        u:add_modification("object", {
            id = "LIUN_conducted_overlay",
            silent = true,
            { "effect", {
                apply_to = "overlay",
                add = "overlays/conducted.png"
            }}
        })
    end
end

-- Caps on totals including resonance (design: WEAPON_PROFILES.md, "Caps enforced in code").
local ACCURACY_CAP = 20
local SUNDER_CAP = 3
-- Interlock share of a hit, in percent, by Resonance tier.
local INTERLOCK_SHARE = { 30, 40, 50 }

-- True if an allied Squad Anchor with this dummy ability stands adjacent, alive and not poisoned.
local function has_adjacent_anchor(u, anchor_id)
    local adjacent = wesnoth.units.find_on_map({
        side = u.side,
        { "filter_adjacent", { id = u.id } }
    })
    for idx, a in ipairs(adjacent) do
        if a.hitpoints > 0 and not a.status.poisoned and resonance.has_dummy_ability(a, anchor_id) then
            return true
        end
    end
    return false
end

-- Appends resonance specials to the unit's attacks of one range, clipped per attack:
-- static stat ("accuracy" or "parry") plus bonus never exceeds cap, and clipping never
-- raises the bonus. Attack names repeat within a unit (two "bow", two "sword"), so each
-- [effect] selects its attacks by range and static stat value instead of by name.
-- build_specials(clipped_bonus) returns the special tags; an empty list adds nothing.
local function add_clipped_specials(u, range, stat, cap, bonus, build_specials)
    local effects = { id = "LIUN_resonance_special", silent = true }
    local seen = {}
    for idx, atk in ipairs(u.attacks) do
        local static = atk[stat]
        if atk.range == range and not seen[static] then
            seen[static] = true
            local specials = build_specials(math.min(bonus, cap - static))
            if #specials > 0 then
                specials.mode = "append"
                table.insert(effects, { "effect", {
                    apply_to = "attack",
                    range = range,
                    [stat] = tostring(static),
                    { "set_specials", specials }
                }})
            end
        end
    end
    if #effects > 0 then
        u:add_modification("object", effects)
    end
end

-- Updates alignment, Formation ZOC, and physical & alloy resistance bonuses
function resonance.update_unit_state(u)
    if not u or u.hitpoints <= 0 then return end

    -- Guard: If unit is not Liminal Union (no alloy, not conductor, not liminal), clean up and exit
    local alloy = resonance.get_unit_alloy(u)
    local is_cond = resonance.is_conductor(u)
    local is_liminal = (u.alignment == "liminal")
    if not alloy and not is_cond and not is_liminal then
        u.halo = ""
        u:remove_modifications({ id = "LIUN_conductor_beacon" })
        u:remove_modifications({ id = "LIUN_conducted_overlay" })
        u:remove_modifications({ id = "LIUN_formation_zoc" })
        u:remove_modifications({ id = "LIUN_resonance_res" })
        u:remove_modifications({ id = "LIUN_resonance_special" })
        u:remove_modifications({ id = "LIUN_resonance_t3" })
        u:remove_modifications({ id = "LIUN_resonance_sigil" })
        return
    end

    -- 1. Update Alignment & Overlay (Conductor logic)
    resonance.update_unit_alignment(u)

    -- Remove deprecated conductor beacon overlay if present
    u:remove_modifications({ id = "LIUN_conductor_beacon" })

    -- 2. Formation ZOC for level 0 units in a pod (Tier >= 1) or beside an allied officer
    u:remove_modifications({ id = "LIUN_formation_zoc" })
    local has_zoc = resonance.get_formation_zoc(u)
    if has_zoc then
        u:add_modification("object", {
            id = "LIUN_formation_zoc",
            silent = true,
            { "effect", {
                apply_to = "zoc",
                value = true
            }},
            { "effect", {
                apply_to = "new_ability",
                { "abilities", {
                    { "dummy", {
                        id = "LIUN_formation_zoc_active",
                        name = _ "formation zoc",
                        description = _ "In Resonance formation (Tier 1+) or beside an allied officer. Exerting Zone of Control."
                    }}
                }}
            }}
        })
        u.variables.lu_zoc_active = true
    else
        u.variables.lu_zoc_active = nil
    end

    -- 3. Update Physical Resistances, Dynamic Ground Sigil & Gradual Alloy Specials (Tier 1-3)
    u:remove_modifications({ id = "LIUN_resonance_res" })
    u:remove_modifications({ id = "LIUN_resonance_special" })
    u:remove_modifications({ id = "LIUN_resonance_t3" })
    u:remove_modifications({ id = "LIUN_resonance_sigil" })

    local prev_tier = tonumber(u.variables.lu_active_tier) or 0
    local tier = resonance.get_tier(u)
    u.variables.lu_active_tier = tier

    if tier > 0 then
        -- Tier 1: 5% | Tier 2: 10% | Tier 3: 15%
        local bonus = tier * 5
        u:add_modification("object", {
            id = "LIUN_resonance_res",
            silent = true,
            { "effect", {
                apply_to = "resistance",
                { "resistance", {
                    blade = -bonus,
                    pierce = -bonus,
                    impact = -bonus
                }}
            }}
        })

        -- Gradual Alloy Signature Specials (Tiers 1, 2, 3)
        local alloy = resonance.get_unit_alloy(u)
        if alloy == "pyrite" then
            -- Pyrite Focus: +5% (T1) -> +10% (T2) -> +15% (T3) CTH on ranged offense
            -- Plus +10% CTH if adjacent to an allied Pyrite Squad Anchor (2·2).
            -- Clipped per attack so that static accuracy plus Focus stays at or below +20.
            local focus_add = tier * 5
            if has_adjacent_anchor(u, "LIUN_squad_anchor_pyrite") then
                focus_add = focus_add + 10
            end
            add_clipped_specials(u, "ranged", "accuracy", ACCURACY_CAP, focus_add, function(focus)
                if focus <= 0 then return {} end
                return {
                    { "chance_to_hit", {
                        id = "LIUN_pyrite_focus",
                        name = _ "focus",
                        description = string.format(_ "Pyrite resonance sharpens aim: +%d%% chance to hit at range on offense.", focus),
                        add = focus,
                        cumulative = true,
                        active_on = "offense"
                    }}
                }
            end)
        elseif alloy == "kryonite" then
            -- Kryonite has no attack special below Tier 3: its signature is Interlock,
            -- which scales with the tier in handle_damage_redistribution.
        elseif alloy == "arcanite" then
            -- Arcanite Sunder: +1 (T1) -> +2 (T2) -> +3 (T3) melee damage on offense
            -- Plus +1 if adjacent to an allied Arcanite Squad Anchor (2·2), at most +3 in total.
            local sunder_dmg = tier
            if has_adjacent_anchor(u, "LIUN_squad_anchor_arcanite") then
                sunder_dmg = math.min(SUNDER_CAP, sunder_dmg + 1)
            end
            u:add_modification("object", {
                id = "LIUN_resonance_special",
                silent = true,
                { "effect", {
                    apply_to = "attack",
                    range = "melee",
                    { "set_specials", {
                        mode = "append",
                        { "damage", {
                            id = "LIUN_arcanite_sunder",
                            name = _ "sunder",
                            description = string.format(_ "Piston-driven hydraulic force increases melee strike damage by +%d on offense.", sunder_dmg),
                            add = sunder_dmg,
                            cumulative = true,
                            active_on = "offense"
                        }}
                    }}
                }}
            })
        end

        -- Dynamic Ground Sigil & 0.5 Hz Breathing Pulse Halo
        if alloy then
            local sigil_path = string.format("halo/resonance-%s-t%d.webp", alloy, tier)
            local halo_str = string.format(
                "halo/resonance-%s-pulse-1.webp:500,halo/resonance-%s-pulse-2.webp:500,halo/resonance-%s-pulse-3.webp:500,halo/resonance-%s-pulse-4.webp:500",
                alloy, alloy, alloy, alloy
            )
            u.halo = halo_str
            u:add_modification("object", {
                id = "LIUN_resonance_sigil",
                silent = true,
                { "effect", {
                    apply_to = "overlay",
                    add = sigil_path
                }}
            })
        else
            u.halo = ""
        end

        -- Unified Resonance I / II / III floating label on tier change
        if alloy and tier ~= prev_tier and wesnoth.interface and wesnoth.interface.float_label then
            local roman = (tier == 1 and "I") or (tier == 2 and "II") or "III"
            local alloy_label = (alloy == "pyrite" and _ "Pyrite") or (alloy == "kryonite" and _ "Kryonite") or _ "Arcanite"
            local color = (tier == 3) and "#ffd700" or "#00e5ff"
            local prefix = (tier == 3) and "✦ " or ""
            local suffix = (tier == 3) and " ✦" or ""
            wesnoth.interface.float_label(
                u.x, u.y,
                string.format("<span color='%s'>%s%s %s (%s)%s</span>", color, prefix, tostring(_ "Resonance"), roman, tostring(alloy_label), suffix)
            )
        end
    else
        u.halo = ""
    end

    -- 4. Tier 3: first strike on defense with the alloy's fighting range. First strike only
    -- matters on defense, because the attacker strikes first anyway.
    local T3_RANGE = { pyrite = "ranged", kryonite = "melee", arcanite = "melee" }
    local t3_range = tier == 3 and T3_RANGE[resonance.get_unit_alloy(u) or ""]
    if t3_range then
        u:add_modification("object", {
            id = "LIUN_resonance_t3",
            silent = true,
            { "effect", {
                apply_to = "attack",
                range = t3_range,
                { "set_specials", {
                    mode = "append",
                    { "firststrike", {
                        id = "LIUN_resonance_firststrike",
                        name = _ "first strike",
                        description = _ "Tier 3 Resonance: this unit always strikes first with this attack when defending.",
                        active_on = "defense"
                    }}
                }}
            }}
        })
    end
end

-- Helper to check if Berserk is active in the combat context
function resonance.is_berserk_combat(ctx)
    if not ctx then return false end

    local function check_weapon(w)
        if not w then return false end
        local specials = wml.get_child(w, "specials")
        if specials then
            if wml.get_child(specials, "berserk") then return true end
            for b in wml.child_range(specials, "berserk") do return true end
        end
        return false
    end

    if check_weapon(ctx.weapon) or check_weapon(ctx.second_weapon) then
        return true
    end

    -- Check units involved in combat for berserk weapons
    local u1 = ctx.x1 and ctx.y1 and wesnoth.units.get(ctx.x1, ctx.y1)
    if u1 then
        for idx_atk, atk in ipairs(u1.attacks or {}) do
            local sp = atk.__cfg and wml.get_child(atk.__cfg, "specials")
            if sp and wml.get_child(sp, "berserk") then
                return true
            end
        end
    end

    local u2 = ctx.x2 and ctx.y2 and wesnoth.units.get(ctx.x2, ctx.y2)
    if u2 then
        for idx_atk, atk in ipairs(u2.attacks or {}) do
            local sp = atk.__cfg and wml.get_child(atk.__cfg, "specials")
            if sp and wml.get_child(sp, "berserk") then
                return true
            end
        end
    end

    return false
end

-- Field Redistribution ("Interlock")
-- Passes INTERLOCK_SHARE[tier] percent of a hit on a Kryonite unit to adjacent Kryonite
-- allies, rounded to the nearest point and at least 1. Interlock replaced Bulwark as the
-- Kryonite tier signature, so it grows with the pod.
-- Conserves total damage dealt; prevents focus-fire assassination without killing allies (cannot drop below 1 HP).
-- During Berserk attacks, ensures damage redistribution triggers on each individual round of combat.
function resonance.handle_damage_redistribution(target_x, target_y, damage_inflicted, is_berserk)
    if not target_x or not target_y then return end
    local target = wesnoth.units.get(target_x, target_y)
    if not target then return end

    local dmg = tonumber(damage_inflicted) or 0
    if dmg <= 0 then return end

    -- Check if target unit had HP before this strike
    -- (In hits events, target.hitpoints has already been decremented by dmg)
    local hp_before_strike = target.hitpoints + dmg
    if hp_before_strike <= 0 then return end

    local alloy = resonance.get_unit_alloy(target)
    if alloy ~= "kryonite" then return end

    -- Interlock requires resonance formation (pod of >= 2)
    local tier = resonance.get_tier(target)
    if tier < 1 then return end

    -- Find eligible adjacent Kryonite allies (not poisoned, > 1 HP)
    local raw_allies = wesnoth.units.find_on_map({
        side = target.side,
        { "filter_adjacent", { id = target.id } }
    })

    local eligible_allies = {}
    local has_kryonite_anchor = false
    for idx, a in ipairs(raw_allies) do
        if a.hitpoints > 1 and not a.status.poisoned and not a.canrecruit and resonance.get_unit_alloy(a) == "kryonite" then
            table.insert(eligible_allies, a)
            if resonance.has_dummy_ability(a, "LIUN_squad_anchor_kryonite") then
                has_kryonite_anchor = true
            end
        end
    end

    if #eligible_allies == 0 then return end

    -- Determine amount to redistribute
    local anchor_bonus = has_kryonite_anchor and 2 or 0
    -- Berserk shares on every round; otherwise hits below 3 damage are not worth sharing.
    if not is_berserk and dmg < 3 and anchor_bonus == 0 then return end
    local share = INTERLOCK_SHARE[math.min(tier, 3)]
    local redistribute_amount = math.max(1, math.floor(dmg * share / 100 + 0.5)) + anchor_bonus
    redistribute_amount = math.min(dmg, redistribute_amount)

    -- Distribute damage across allies without reducing any ally below 1 HP
    local total_absorbed = 0
    local remaining = redistribute_amount

    -- Distribute share per ally
    for i, ally in ipairs(eligible_allies) do
        if remaining <= 0 then break end
        local allies_left = #eligible_allies - i + 1
        local target_share = math.max(1, math.floor(remaining / allies_left))
        local can_take = math.max(0, ally.hitpoints - 1)
        local actual_share = math.min(target_share, can_take, remaining)

        if actual_share > 0 then
            ally.hitpoints = ally.hitpoints - actual_share
            total_absorbed = total_absorbed + actual_share
            remaining = remaining - actual_share

            if wesnoth.interface and wesnoth.interface.float_label then
                wesnoth.interface.float_label(
                    ally.x,
                    ally.y,
                    string.format(tostring(_ "<span color='#4fc3f7'>-%d Interlock</span>"), actual_share)
                )
            end
        end
    end

    -- Restore absorbed damage back to the target unit
    if total_absorbed > 0 then
        local tel = wml.variables and wml.variables["liun_balance_telemetry"]
        if tel == true or tel == "yes" then
            std_print(string.format(
                "LIUN_BALANCE\tINTERLOCK\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
                tostring(target.type), target.side, dmg, total_absorbed,
                #eligible_allies, is_berserk and 1 or 0, tier, target.x, target.y))
        end
        target.hitpoints = math.min(target.max_hitpoints, target.hitpoints + total_absorbed)
        if wesnoth.interface and wesnoth.interface.float_label then
            wesnoth.interface.float_label(
                target.x,
                target.y,
                string.format(tostring(_ "<span color='#81d4fa'>Interlock (+%d)</span>"), total_absorbed)
            )
        end
    end
end

-- Precision strikes bypass Interlock: a magical or marksman special that is active for
-- the hitting side. The engine passes the weapons as [weapon] / [second_weapon] children
-- of the event context; marksman is active_on=offense in mainline.
local PRECISION_SPECIALS = { magical = true, marksman = true }

function resonance.is_precision_strike(weapon, on_offense)
    if not weapon then return false end
    local specials = wml.get_child(weapon, "specials")
    if not specials then return false end
    for idx, sp in ipairs(specials) do
        local cfg = sp[2]
        if PRECISION_SPECIALS[cfg.id or ""] then
            local active_on = cfg.active_on or ""
            if active_on == "" or (active_on == "offense") == on_offense then
                return true
            end
        end
    end
    return false
end

-- Attacker hits event: defender (ctx.x2, ctx.y2) takes damage
function resonance.on_attacker_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x2 or not ctx.y2 then return end
    if resonance.is_precision_strike(wml.get_child(ctx, "weapon"), true) then return end
    local is_berserk = resonance.is_berserk_combat(ctx)
    resonance.handle_damage_redistribution(ctx.x2, ctx.y2, ctx.damage_inflicted, is_berserk)
end

-- Defender hits event: attacker (ctx.x1, ctx.y1) takes damage
function resonance.on_defender_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    if resonance.is_precision_strike(wml.get_child(ctx, "second_weapon"), false) then return end
    local is_berserk = resonance.is_berserk_combat(ctx)
    resonance.handle_damage_redistribution(ctx.x1, ctx.y1, ctx.damage_inflicted, is_berserk)
end

-- Recalculates for all units on a side
function resonance.refresh_side(side_num)
    side_num = side_num or wesnoth.current.side
    local units = wesnoth.units.find_on_map({ side = side_num })

    -- 1. Reset stillness flag and record turn-start coordinates
    for idx, u in ipairs(units) do
        u.variables.lu_moved = false
        u.variables.lu_start_x = u.x
        u.variables.lu_start_y = u.y
    end

    -- 2. Record starting tier for diagnostics and turn-state bookkeeping.
    for idx, u in ipairs(units) do
        u.variables.lu_start_tier = resonance.calculate_pod_tier(u)
    end

    -- 3. Update alignment, ZOC, and physical state
    for idx, u in ipairs(units) do
        resonance.update_unit_state(u)
    end
end

-- Helper to find all units adjacent to a coordinate
local function get_adjacent_units(x, y)
    if not x or not y then return {} end
    return wesnoth.units.find_on_map({
        { "filter_location", {
            { "filter_adjacent_location", { x = x, y = y } }
        } }
    })
end

-- Handles side turn event
function resonance.on_side_turn()
    resonance.refresh_side(wesnoth.current.side)
end

-- Handles movement to ensure auras and ZOC update immediately
function resonance.on_unit_moved(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u then return end

    -- 1. Mark unit as moved (breaks its resonance eligibility)
    u.variables.lu_moved = true

    -- 2. Update the unit that just moved (drops resistance/ZOC)
    resonance.update_unit_state(u)

    -- 3. Update all units adjacent to the new position
    local adj_new = get_adjacent_units(ctx.x1, ctx.y1)
    for idx, n in ipairs(adj_new) do resonance.update_unit_state(n) end

    -- 4. Update all units adjacent to the old position
    if ctx.x2 and ctx.y2 then
        local adj_old = get_adjacent_units(ctx.x2, ctx.y2)
        for idx, n in ipairs(adj_old) do resonance.update_unit_state(n) end
    end
end

-- Handles recruit and recall events
function resonance.on_unit_placed(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u then return end

    u.variables.lu_moved = true
    u.variables.lu_start_tier = 0
    u.variables.lu_start_x = u.x
    u.variables.lu_start_y = u.y

    resonance.update_unit_state(u)

    local adj = get_adjacent_units(ctx.x1, ctx.y1)
    for idx, n in ipairs(adj) do resonance.update_unit_state(n) end
end

-- Handles post advance events
function resonance.on_unit_advanced(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    if not u then return end

    resonance.update_unit_state(u)

    local adj = get_adjacent_units(ctx.x1, ctx.y1)
    for idx, n in ipairs(adj) do resonance.update_unit_state(n) end
end

-- Handles die events so adjacent pod members recalculate when a unit or Conductor falls
function resonance.on_unit_died(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local adj = get_adjacent_units(ctx.x1, ctx.y1)
    for idx, n in ipairs(adj) do
        if n.hitpoints > 0 then
            resonance.update_unit_state(n)
        end
    end
end

-- Attack end: kills, poison and slow inflicted in this fight change pods at once,
-- so both combatants and their neighbours recalculate (same pattern as on_unit_died).
function resonance.on_attack_end(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx then return end
    local done = {}
    local function refresh_around(x, y)
        if not x or not y then return end
        local u = wesnoth.units.get(x, y)
        if u and u.hitpoints > 0 and not done[u.id] then
            done[u.id] = true
            resonance.update_unit_state(u)
        end
        for idx, n in ipairs(get_adjacent_units(x, y)) do
            if n.hitpoints > 0 and not done[n.id] then
                done[n.id] = true
                resonance.update_unit_state(n)
            end
        end
    end
    refresh_around(ctx.x1, ctx.y1)
    refresh_around(ctx.x2, ctx.y2)
end

return resonance
