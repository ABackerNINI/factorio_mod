require('config')

local v = 19

local names = g_names
local startup_settings = g_startup_settings

local math_ceil = math.ceil

local function calc_distance_between_two_points(p1, p2)
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end

local function calc_distance_between_two_points2(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return math.sqrt(dx * dx + dy * dy)
end

local function calc_power_consumption(distance, eei, chest_type)
    if eei ~= nil then
        local ret = {
            power_consumption = 0,
            eei = eei
        }

        -- calc multiplier
        local dis = calc_distance_between_two_points2(eei.position.x, eei.position.y, global.lc_entities.center_pos_x, global.lc_entities.center_pos_y)
        local multiplier
        if dis < 500 then
            multiplier = 1
        else
            -- game.print('multiplier: ' .. multiplier)
            multiplier = 1 + (dis / 500 * 0.1)
        end

        -- if string.match(entity.name,names.collecter_chest_pattern) ~= nil then this is not recommended
        if chest_type == 1 then -- entity.name == names.collecter_chest_1_1 then --- or
            -- entity.name == names.collecter_chest_3_6 or
            -- entity.name == names.collecter_chest_6_3
            ret.power_consumption = math_ceil(distance * global.technologies.cc_power_consumption * multiplier)
        else
            ret.power_consumption = math_ceil(distance * global.technologies.rc_power_consumption * multiplier)
        end
        return ret
    else
        -- game.print("[ab_logisticscenter]: error, didn't find@find_nearest_lc")
        return nil
    end
end

-- Find nearest lc
local function find_nearest_lc(entity, chest_type)
    if global.lc_entities.count == 0 then
        return nil
    end

    local surface = entity.surface.index
    local eei = nil
    local nearest_distance = 1000000000 -- should big enough
    local distance
    for k, v in pairs(global.lc_entities.entities) do
        if surface == v.lc.surface.index then
            distance = calc_distance_between_two_points(entity.position, v.lc.position)
            if distance < nearest_distance then
                nearest_distance = distance
                eei = v.eei
            end
        end
    end

    return calc_power_consumption(nearest_distance, eei, chest_type)
end

-- Add to watch-list
local function re_scan_add_cc(entity)
    local index = global.cc_entities.index
    local nearest_lc = find_nearest_lc(entity, 1)

    global.cc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    global.cc_entities.index = global.cc_entities.index + 1
end

-- Add to watch-list
local function re_scan_add_rc(entity)
    local index = global.rc_entities.index
    local nearest_lc = find_nearest_lc(entity, 2)

    global.rc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    global.rc_entities.index = global.rc_entities.index + 1
end

-- global_data_version: 18 -> 19
function add_lc_rc_count()
    if global.global_data_version < v then
        game.print({g_names.locale_print_when_global_data_migrate, v - 1})

        global.cc_entities = {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

        global.rc_entities = {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

        local total_ccs = 0
        local total_rcs = 0

        for k, surface in pairs(game.surfaces) do
            -- re-scan collector chests
            local ccs = surface.find_entities_filtered {name = names.collecter_chest_1_1}
            for k1, v in pairs(ccs) do
                re_scan_add_cc(v)
            end
            total_ccs = total_ccs + #ccs

            -- re-scan requester chests
            local rcs = surface.find_entities_filtered {name = names.requester_chest_1_1}
            for k1, v in pairs(rcs) do
                re_scan_add_rc(v)
            end
            total_rcs = total_rcs + #rcs
        end

        game.print('requester chests: ' .. total_rcs .. '  collector chests: ' .. total_ccs)

        -- global.cc_entities
        -- OLD {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}
        -- NEW {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}, count}}}
        global.cc_entities.count = total_ccs

        -- global.rc_entities
        -- OLD {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}
        -- NEW {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}, count}}}
        global.rc_entities.count = total_rcs

        -- recalc cpr
        global.runtime_vars.cc_check_per_round = math_ceil(total_ccs * startup_settings.check_cc_percentages)
        global.runtime_vars.rc_check_per_round = math_ceil(total_rcs * startup_settings.check_rc_percentages)

        -- set global_data_version
        global.global_data_version = v
    end
end
