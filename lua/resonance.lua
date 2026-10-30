-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Wesnoth engine globals (not visible to static analysis)
---@diagnostic disable: undefined-global

local resonance = {}

-- Calculates hex distance between two coordinates in Wesnoth odd-r layout
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

-- Resolves the armor alloy for a unit (robust to [base_unit] variable dropping)
function resonance.get_unit_alloy(u)
    if not u or u.hitpoints <= 0 then return nil end
    local var_alloy = u.variables.lu_alloy
    if var_alloy and var_alloy ~= "" then return var_alloy end

    local cfg = u.__cfg
    if cfg then
        local abilities = wml.get_child(cfg, "abilities")
        if abilities then
            for ab in wml.child_range(abilities, "dummy") do
                if ab.id == "LIUN_resonance_pyrite" then
                    u.variables.lu_alloy = "pyrite"
                    return "pyrite"
                elseif ab.id == "LIUN_resonance_kryonite" then
                    u.variables.lu_alloy = "kryonite"
                    return "kryonite"
                elseif ab.id == "LIUN_resonance_arcanite" then
                    u.variables.lu_alloy = "arcanite"
                    return "arcanite"
                end
            end
        end
    end

    local utype = tostring(u.type or "")
    if utype:sub(1, 5) == "LIUN_" then
        if u.race == "maidengolem" then
            u.variables.lu_alloy = "arcanite"
            return "arcanite"
        elseif u.race == "maidencommand" then
            if not utype:find("Ensign") and not utype:find("Cornet") and not utype:find("Captain") and not utype:find("Colonel") then
                u.variables.lu_alloy = "pyrite"
                return "pyrite"
            end
        elseif u.race == "marinecommand" then
            if not utype:find("Ensign") and not utype:find("Cornet") and not utype:find("Captain") and not utype:find("Colonel") then
                u.variables.lu_alloy = "kryonite"
                return "kryonite"
            end
        end
    end

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

-- Checks if a level 0 troop is eligible for Formation ZOC (pod of >= 2 allied troops)
-- Active immediately upon grouping with allied troops.
-- Slowed units retain Formation ZOC if adjacent to at least one non-slowed ally.
function resonance.get_formation_zoc(u)
    if not u or u.hitpoints <= 0 then return false end
    if u.level ~= 0 then return false end
    local alloy = resonance.get_unit_alloy(u)
    if not alloy and not resonance.is_conductor(u) then return false end
    if u.status.poisoned then return false end

    -- Count adjacent allies from same side who are not poisoned and have alloy or conductor
    local raw_allies = wesnoth.units.find_on_map({
        side = u.side,
        { "filter_adjacent", { id = u.id } }
    })

    local non_slowed_allies = 0
    local total_valid_allies = 0
    for idx, a in ipairs(raw_allies) do
        if a.hitpoints > 0 and (resonance.get_unit_alloy(a) or resonance.is_conductor(a)) and not a.status.poisoned then
            total_valid_allies = total_valid_allies + 1
            if not a.status.slowed then
                non_slowed_allies = non_slowed_allies + 1
            end
        end
    end

    if u.status.slowed then
        -- Slowed unit retains Formation ZOC if adjacent to at least one non-slowed ally
        return non_slowed_allies >= 1
    else
        -- Non-slowed unit gains Formation ZOC in a pod of >= 2 (self + at least 1 valid ally)
        return total_valid_allies >= 1
    end
end

-- Updates a single unit based on Conductor proximity.
-- Conductor provides Conducted Alignment to all adjacent liminal allies regardless of level.
function resonance.update_unit_alignment(u)
    if not u or u.hitpoints <= 0 then return end
    if u.alignment ~= "liminal" and u.alignment ~= "LIUN_liminal" and u.alignment ~= "LIUN_liminal_conducted" then
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

    -- Prototype Step 5: Phoinix Airborne Signal Relay
    -- Relays Conductance if adjacent to a Phoinix within 3 hexes of a Conductor
    if not has_conductor then
        local ok, phoinix_courier = pcall(wesnoth.require, "~add-ons/liminal-union/lua/phoinix_courier.lua")
        if ok and phoinix_courier and phoinix_courier.is_adjacent_to_relaying_phoinix(u) then
            has_conductor = true
        end
    end

    local was_conducted = u.variables.lu_conducted
    u.variables.lu_conducted = has_conductor

    -- Visual Status Icon & Floating Label (Agenda 1 - Option 2)
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
        if not was_conducted and wesnoth.interface and wesnoth.interface.float_label then
            wesnoth.interface.float_label(u.x, u.y, "<span color='#00e5ff'>Conducted</span>")
        end
    end
end

-- Updates alignment, Formation ZOC, and physical & alloy resistance bonuses
function resonance.update_unit_state(u)
    if not u or u.hitpoints <= 0 then return end

    -- Guard: If unit is not Liminal Union (no alloy, not conductor, not liminal), clean up and exit
    local alloy = resonance.get_unit_alloy(u)
    local is_cond = resonance.is_conductor(u)
    local is_liminal = (u.alignment == "liminal" or u.alignment == "LIUN_liminal" or u.alignment == "LIUN_liminal_conducted")
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

    -- 2. Formation ZOC for Level 0 troops in pods of >= 2 (Phase 5.1)
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
                        description = _ "Standing in formation with allied troops. Exerting Zone of Control."
                    }}
                }}
            }}
        })
        if not u.variables.lu_zoc_active and wesnoth.interface and wesnoth.interface.float_label then
            wesnoth.interface.float_label(u.x, u.y, "<span color='#ffd700'>ZOC Lock</span>")
            u.variables.lu_zoc_active = true
        end
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
            -- Plus +10% CTH if adjacent to an allied Pyrite Squad Anchor (2·2)
            local focus_add = tier * 5
            local adj_allies = wesnoth.units.find_on_map({
                side = u.side,
                { "filter_adjacent", { id = u.id } }
            })
            for _, a in ipairs(adj_allies) do
                if a.hitpoints > 0 and not a.status.poisoned and resonance.has_dummy_ability(a, "LIUN_squad_anchor_pyrite") then
                    focus_add = focus_add + 10
                    break
                end
            end
            u:add_modification("object", {
                id = "LIUN_resonance_special",
                silent = true,
                { "effect", {
                    apply_to = "attack",
                    range = "ranged",
                    { "set_specials", {
                        mode = "append",
                        { "chance_to_hit", {
                            id = "LIUN_pyrite_focus",
                            name = _ "focus",
                            description = string.format(_ "Pyrite resonance sharpens aim: +%d%% chance to hit at range on offense.", focus_add),
                            add = focus_add,
                            cumulative = true,
                            active_on = "offense"
                        }}
                    }}
                }}
            })
        elseif alloy == "kryonite" then
            -- Kryonite Bulwark: Parry -5% (T1) -> -10% (T2) -> -10% + Firststrike (T3) on melee defense
            local parry_sub = math.min(10, tier * 5)
            local specials_cfg = {
                mode = "append",
                { "chance_to_hit", {
                    id = "LIUN_kryonite_bulwark",
                    name = _ "bulwark",
                    description = string.format(_ "Kryonite formation locks shields: enemies suffer -%d%% chance to hit in melee on offense.", parry_sub),
                    sub = parry_sub,
                    apply_to = "opponent",
                    cumulative = true,
                    active_on = "defense"
                }}
            }
            if tier == 3 then
                table.insert(specials_cfg, { "firststrike", {
                    id = "LIUN_kryonite_firststrike",
                    name = _ "first strike",
                    description = _ "Kryonite phalanx braces: strikes first when defending in melee.",
                    active_on = "defense"
                }})
            end
            u:add_modification("object", {
                id = "LIUN_resonance_special",
                silent = true,
                { "effect", {
                    apply_to = "attack",
                    range = "melee",
                    { "set_specials", specials_cfg }
                }}
            })
        elseif alloy == "arcanite" then
            -- Arcanite Sunder: +1 (T1) -> +2 (T2) -> +3 (T3) melee damage on offense
            local sunder_dmg = tier
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

        -- Tier 3 lock-in visual notification
        if tier == 3 and prev_tier ~= 3 and wesnoth.interface and wesnoth.interface.float_label then
            wesnoth.interface.float_label(u.x, u.y, "<span color='#ffd700'>✦ Tier 3 Lock ✦</span>")
        end
    else
        u.halo = ""
    end

    -- 4. Tier 3 alloy-specific defensive wards (calibrated to multiples of 10)
    if tier == 3 then
        local alloy = resonance.get_unit_alloy(u)
        if alloy == "arcanite" then
            -- Arcanite Warding: +20% fire/cold resistance
            u:add_modification("object", {
                id = "LIUN_resonance_t3",
                silent = true,
                { "effect", {
                    apply_to = "resistance",
                    { "resistance", {
                        fire = -20,
                        cold = -20
                    }}
                }}
            })
        elseif alloy == "pyrite" then
            -- Pyrite Ward: +10% Fire / +10% Arcane resistance
            u:add_modification("object", {
                id = "LIUN_resonance_t3",
                silent = true,
                { "effect", {
                    apply_to = "resistance",
                    { "resistance", {
                        fire = -10,
                        arcane = -10
                    }}
                }}
            })
        elseif alloy == "kryonite" then
            -- Kryonite Temper: +10% cold and arcane resistance
            u:add_modification("object", {
                id = "LIUN_resonance_t3",
                silent = true,
                { "effect", {
                    apply_to = "resistance",
                    { "resistance", {
                        cold = -10,
                        arcane = -10
                    }}
                }}
            })
        end
        -- Uranite Command removed: Pure conductors without Resonance
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
        for _, atk in ipairs(u1.attacks or {}) do
            local sp = atk.__cfg and wml.get_child(atk.__cfg, "specials")
            if sp and wml.get_child(sp, "berserk") then
                return true
            end
        end
    end

    local u2 = ctx.x2 and ctx.y2 and wesnoth.units.get(ctx.x2, ctx.y2)
    if u2 then
        for _, atk in ipairs(u2.attacks or {}) do
            local sp = atk.__cfg and wml.get_child(atk.__cfg, "specials")
            if sp and wml.get_child(sp, "berserk") then
                return true
            end
        end
    end

    return false
end

-- Field Redistribution ("Interlock")
-- Absorbs 25%–33% (30%) of damage taken by a Kryonite unit across adjacent alloy allies.
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
        if a.hitpoints > 1 and not a.status.poisoned and resonance.get_unit_alloy(a) == "kryonite" then
            table.insert(eligible_allies, a)
            if resonance.has_dummy_ability(a, "LIUN_squad_anchor_kryonite") then
                has_kryonite_anchor = true
            end
        end
    end

    if #eligible_allies == 0 then return end

    -- Determine amount to redistribute
    local anchor_bonus = has_kryonite_anchor and 2 or 0
    local redistribute_amount
    if is_berserk then
        -- During Berserk, distribute across allies on every round (minimum 1 per eligible ally, up to 50% total)
        local per_ally_share = math.max(1, math.floor(dmg * 0.30))
        redistribute_amount = math.min(math.floor(dmg * 0.50), per_ally_share * #eligible_allies) + anchor_bonus
        redistribute_amount = math.min(dmg, math.max(1, redistribute_amount))
    else
        if dmg < 3 and anchor_bonus == 0 then return end
        redistribute_amount = math.min(dmg, math.floor(dmg * 0.30) + anchor_bonus)
        if redistribute_amount <= 0 then return end
    end

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
                    string.format("<span color='#4fc3f7'>-%d Interlock</span>", actual_share)
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
                string.format("<span color='#81d4fa'>Interlock (+%d)</span>", total_absorbed)
            )
        end
    end
end

-- Attacker hits event: defender (ctx.x2, ctx.y2) takes damage
function resonance.on_attacker_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x2 or not ctx.y2 then return end
    local is_berserk = resonance.is_berserk_combat(ctx)
    resonance.handle_damage_redistribution(ctx.x2, ctx.y2, ctx.damage_inflicted, is_berserk)
end

-- Defender hits event: attacker (ctx.x1, ctx.y1) takes damage
function resonance.on_defender_hits(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 then return end
    local is_berserk = resonance.is_berserk_combat(ctx)
    resonance.handle_damage_redistribution(ctx.x1, ctx.y1, ctx.damage_inflicted, is_berserk)
end

-- Recalculates for all units on a side
function resonance.refresh_side(side_num)
    side_num = side_num or wesnoth.current.side
    local units = wesnoth.units.find_on_map({ side = side_num })

    -- 1. Reset stillness flag, record turn-start coordinates, and clear relay status
    for idx, u in ipairs(units) do
        u.variables.lu_moved = false
        u.variables.lu_start_x = u.x
        u.variables.lu_start_y = u.y
        u.variables.lu_relay_active = false
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
    u.variables.lu_relay_active = false

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

return resonance
