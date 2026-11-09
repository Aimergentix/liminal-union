-- AI candidate action: keep the doctrinal recruitment floor when gold is short.
--
-- The default recruitment CA picks the most important open job without looking at cost.
-- If that first purchase of a turn fails for lack of gold, the game state is unchanged and the
-- RCA loop disables recruitment for the rest of the turn, so cheaper open buckets stay empty.
-- This CA runs just below the default recruitment score: it buys the most important open
-- bucket that is affordable now and skips the unaffordable ones. When every bucket is filled
-- it does nothing and leaves pattern recruiting and gold saving to the default CA.
--
-- [args] floor= lists the bucket usages in priority order; keep it in step with the
-- recruitment_instructions aspect of the faction. Only recruit actions reach the replay, so
-- this decision code runs on the controlling client only and needs no synchronisation.

---@diagnostic disable: undefined-global

local ca = {}

local function split_list(s)
    local out = {}
    for item in tostring(s or ""):gmatch("[^,]+") do
        item = item:match("^%s*(.-)%s*$")
        if item ~= "" then table.insert(out, item) end
    end
    return out
end

-- Usage of a unit type id, cached per call (unit_type.__cfg builds a full config)
local function usage_lookup()
    local cache = {}
    return function(type_id)
        if cache[type_id] == nil then
            local ut = wesnoth.unit_types[type_id]
            cache[type_id] = ut and ut.__cfg.usage or false
        end
        return cache[type_id]
    end
end

-- Counts like the engine's total=yes jobs: own living non-leader units on the map that can
-- move, by the usage of their current type (recruitment.cpp update_own_units_count).
local function count_units(side, usage_of)
    local by_usage, by_type = {}, {}
    for idx, u in ipairs(wesnoth.units.find_on_map({ side = side, canrecruit = false })) do
        if u.hitpoints > 0 and u.max_moves > 0 and not u.status.petrified then
            by_type[u.type] = (by_type[u.type] or 0) + 1
            local usage = usage_of(u.type)
            if usage then by_usage[usage] = (by_usage[usage] or 0) + 1 end
        end
    end
    return by_usage, by_type
end

-- Side recruit list plus the extra recruits of its leaders, in listed order without duplicates
local function recruit_list(side)
    local list, seen = {}, {}
    local function add(type_id)
        if type_id ~= "" and not seen[type_id] then
            seen[type_id] = true
            table.insert(list, type_id)
        end
    end
    for idx, type_id in ipairs(wesnoth.sides[side].recruit) do add(type_id) end
    for idx, leader in ipairs(wesnoth.units.find_on_map({ side = side, canrecruit = true })) do
        for jdx, type_id in ipairs(leader.extra_recruit) do add(type_id) end
    end
    return list
end

-- The recruit to buy now, or nil. Buckets are tried in floor order; within a bucket the type
-- with the fewest units on the map wins, then the dearer one, then the listed order.
local function choose(cfg)
    local side = wesnoth.current.side
    local gold = wesnoth.sides[side].gold
    local usage_of = usage_lookup()
    local by_usage, by_type = count_units(side, usage_of)
    local recruits = recruit_list(side)

    for idx, usage in ipairs(split_list(cfg.floor)) do
        if (by_usage[usage] or 0) == 0 then
            local best, best_count, best_cost
            for jdx, type_id in ipairs(recruits) do
                local ut = wesnoth.unit_types[type_id]
                if ut and usage_of(type_id) == usage and ut.cost <= gold then
                    local count = by_type[type_id] or 0
                    if not best or count < best_count or (count == best_count and ut.cost > best_cost) then
                        if ai.check_recruit(type_id).ok then
                            best, best_count, best_cost = type_id, count, ut.cost
                        end
                    end
                end
            end
            if best then return best end
        end
    end
    return nil
end

function ca:evaluation(cfg)
    if choose(cfg) then return cfg.score or 179000 end
    return 0
end

function ca:execution(cfg)
    local type_id = choose(cfg)
    if type_id then ai.recruit(type_id) end
end

return ca
