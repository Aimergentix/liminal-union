-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

---@diagnostic disable: undefined-global

local marine_grounding = {}

-- Only Kryonite troops carry the Pylum; Officers share race=marinecommand but not the alloy.
-- The resonance dummy ability is static per unit type, unlike [unit_type][variables],
-- which the engine does not copy to unit instances.
local KRYONITE_ABILITY = "LIUN_resonance_kryonite"

local function is_elemental(damage_type)
    return damage_type == "fire" or damage_type == "cold" or damage_type == "arcane"
end

-- Checks if a unit has a fire, cold, or arcane attack
local function has_elemental_threat(u)
    if not u or not u.__cfg then return false end
    for atk in wml.child_range(u.__cfg, "attack") do
        if is_elemental(atk.type) then
            return true
        end
    end
    return false
end

-- Highest damage × strikes among a unit's attacks that match `pred`, 0 if none
local function best_output(u, pred)
    local best = 0
    if not u or not u.__cfg then return best end
    for atk in wml.child_range(u.__cfg, "attack") do
        if pred(atk) then
            best = math.max(best, (atk.damage or 0) * (atk.number or 0))
        end
    end
    return best
end

local function is_blade_or_impact_melee(atk)
    return atk.range == "melee" and (atk.type == "blade" or atk.type == "impact")
end

local function is_elemental_attack(atk)
    return is_elemental(atk.type)
end

-- A real melee threat to the Pylum's +20% Blade/Impact cost. A caster's backup staff or an
-- archer's short sword does not count: the blade/impact melee must reach BRUISER_MIN_OUTPUT
-- and be at least as strong as the unit's best elemental attack (Mage 5×1 staff vs 7×3 fire).
local BRUISER_MIN_OUTPUT = 12
local function is_physical_bruiser(u)
    local melee = best_output(u, is_blade_or_impact_melee)
    return melee >= BRUISER_MIN_OUTPUT and melee >= best_output(u, is_elemental_attack)
end

-- Checks if a unit is eligible to deploy the Salt-Grounding Pylum
function marine_grounding.can_ground(u)
    if not u or u.hitpoints <= 0 then return false end
    if u.side ~= wesnoth.current.side then return false end
    if not u:matches({ ability = KRYONITE_ABILITY }) then return false end
    -- Sergeants and above carry the Pylum; level 0 Privates do not.
    if u.level < 1 then return false end
    if u.variables.lu_grounded then return false end
    return true
end

-- Evaluates whether an AI-controlled Marine should deploy the Salt-Grounding Pylum
function marine_grounding.should_ai_ground(u)
    if not marine_grounding.can_ground(u) then return false end
    if u.canrecruit or u.hitpoints < 14 then return false end

    -- AI sides only, as fixed at prestart (replay-safe; see side_control.lua).
    if not wesnoth.require("~add-ons/liminal-union/lua/side_control.lua").is_ai_side(u.side) then return false end

    local adj_allies = {}
    local enemies = {}
    local adj_elemental_enemies = 0
    local ally_threats = 0
    local adj_physical_bruisers = 0

    -- Engine distance: Wesnoth offsets columns, so a row-offset formula misreads adjacency.
    -- Enemies up to 3 hexes away can be within 2 hexes of an adjacent ally.
    for idx, other in ipairs(wesnoth.units.find_on_map({})) do
        if other.hitpoints > 0 and other.id ~= u.id then
            local dist = wesnoth.map.distance_between(u.x, u.y, other.x, other.y)
            if not wesnoth.sides.is_enemy(u.side, other.side) then
                if dist == 1 then table.insert(adj_allies, other) end
            elseif dist <= 3 then
                table.insert(enemies, { unit = other, dist = dist })
            end
        end
    end

    for idx, e in ipairs(enemies) do
        if e.dist == 1 and is_physical_bruiser(e.unit) then
            adj_physical_bruisers = adj_physical_bruisers + 1
        end
        if has_elemental_threat(e.unit) then
            if e.dist == 1 then
                adj_elemental_enemies = adj_elemental_enemies + 1
            else
                -- The ward covers adjacent allies, so measure the threat from them, not from the Marine.
                for jdx, ally in ipairs(adj_allies) do
                    if wesnoth.map.distance_between(ally.x, ally.y, e.unit.x, e.unit.y) <= 2 then
                        ally_threats = ally_threats + 1
                        break
                    end
                end
            end
        end
    end

    -- Must either dampen an adjacent elemental enemy OR ward an adjacent ally that an elemental enemy within 2 hexes threatens
    if adj_elemental_enemies == 0 and ally_threats == 0 then
        return false
    end

    -- Avoid +20% Blade/Impact vulnerability if exposed to multiple physical bruisers
    if adj_physical_bruisers >= 2 then
        return false
    end
    if adj_physical_bruisers == 1 and adj_elemental_enemies == 0 and u.hitpoints < 22 then
        return false
    end

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

    -- 3. Apply auras to adjacent units, each effect at most once per unit: resistance objects
    --    add up, so a unit touching several grounded Marines must not gain +40% or more.
    local warded, dampened = {}, {}
    for idx, gm in ipairs(grounded_marines) do
        local adjacents = wesnoth.units.find_on_map({
            { "filter_adjacent", { id = gm.id } }
        })

        for jdx, target in ipairs(adjacents) do
            local hostile = wesnoth.sides.is_enemy(gm.side, target.side)
            local done = hostile and dampened or warded
            if target.hitpoints > 0 and not done[target.id] then
                done[target.id] = true
                if not hostile then
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
                    -- Adjacent Enemy: cap fire/cold/arcane accuracy (max 50% CTH) & -20% elemental damage
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
                                    description = _ "Fire, cold and arcane accuracy is grounded by the Salt-Grounding Pylum: maximum 50% chance to hit.",
                                    -- max_value caps; value with cumulative=no would set 50 and raise lower odds.
                                    max_value = 50,
                                    priority = 100
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
    u:remove_modifications({ id = "LIUN_grounding_stance_mod" })

    -- Vulnerability Cost: 0 MP for turn + +20% vulnerability to melee Blade/Impact until the next own turn.
    -- A plain resistance effect would also hit ranged Blade/Impact, so the cost is a resistance ability
    -- filtered on the opponent's weapon; removing the stance object removes it. The sidebar resistance
    -- table ignores weapon filters (engine reports.cpp, unit::resistance_against), so it shows the cost
    -- for ranged attacks too; the named ability explains this to the player.
    u.moves = 0
    u:add_modification("object", {
        id = "LIUN_grounding_stance_mod",
        silent = true,
        { "effect", {
            apply_to = "new_ability",
            { "abilities", {
                { "resistance", {
                    id = "LIUN_grounding_melee_cost",
                    name = _ "grounded",
                    description = _ "Salt-Grounding Pylum deployed: +20% vulnerability to melee blade and impact attacks until this unit's next turn. The resistance table also lists it for ranged attacks, where it does not apply; the attack preview shows the true damage.",
                    add = -20,
                    max_value = 100,
                    apply_to = "blade,impact",
                    affect_self = true,
                    { "filter_second_weapon", { range = "melee" } }
                }}
            }}
        }},
        { "effect", {
            apply_to = "overlay",
            add = "overlays/salt-grounding.webp"
        }}
    })

    -- Sound effect and floating notification
    wesnoth.audio.play("lightning.ogg")
    if wesnoth.interface and wesnoth.interface.float_label then
        wesnoth.interface.float_label(u.x, u.y, _ "<span color='#55ffff'>⚡ Salt-Grounding Pylum [0 MP, Ward Active]</span>")
    end

    -- Update wards across adjacent hexes
    marine_grounding.update_wards()

    -- Repaint now, as the engine's [object] tag does after a visible change.
    wesnoth.wml_actions.redraw{}
end

-- AI tactical reflex before combat: if the defender retaliates with an elemental weapon, deploy Pylum to dampen it.
-- The attack event fires before the strikes and the engine rebuilds the battle context afterwards,
-- so the dampen applies to this exchange. The defender's weapon is already chosen at this point.
function marine_grounding.on_attack(ctx)
    ctx = ctx or wesnoth.current.event_context
    if not ctx or not ctx.x1 or not ctx.y1 or not ctx.x2 or not ctx.y2 then return end
    local u = wesnoth.units.get(ctx.x1, ctx.y1)
    local d = wesnoth.units.get(ctx.x2, ctx.y2)
    if not u or not d or d.hitpoints <= 0 then return end
    -- A physical counter would only meet the +20% Blade/Impact cost; leave that to the turn-end check.
    local retaliation = wml.get_child(ctx, "second_weapon")
    if not retaliation or not is_elemental(retaliation.type) then return end

    if marine_grounding.should_ai_ground(u) then
        marine_grounding.activate({ x1 = u.x, y1 = u.y })
    end
end

-- AI tactical reflex at turn end: deploy Pylum on eligible Marines standing in formation near elemental threats
function marine_grounding.on_side_turn_end(side_num)
    side_num = side_num or wesnoth.current.side
    if not wesnoth.require("~add-ons/liminal-union/lua/side_control.lua").is_ai_side(side_num) then return end

    local marines = wesnoth.units.find_on_map({
        side = side_num,
        ability = KRYONITE_ABILITY
    })
    for idx, u in ipairs(marines) do
        if marine_grounding.should_ai_ground(u) then
            marine_grounding.activate({ x1 = u.x, y1 = u.y })
        end
    end
end

-- Handles unit movement to update aura boundaries dynamically
function marine_grounding.on_unit_moved(ctx)
    marine_grounding.update_wards()
end

-- Recruits and recalls appear without a moveto event, so give them the ward here
function marine_grounding.on_unit_placed(ctx)
    marine_grounding.update_wards()
end

-- Handles unit death to clean up wards if a grounded marine falls
function marine_grounding.on_unit_died(ctx)
    marine_grounding.update_wards()
end

-- Ends the stance when its owner's next turn begins, so it covers the enemy turn in between
function marine_grounding.on_side_turn(side_num)
    side_num = side_num or wesnoth.current.side
    local units = wesnoth.units.find_on_map({ side = side_num })

    for idx, u in ipairs(units) do
        if u.variables.lu_grounded then
            u:remove_modifications({ id = "LIUN_grounding_stance_mod" })
            u.variables.lu_grounded = nil
        end
    end

    marine_grounding.update_wards()
end

return marine_grounding
