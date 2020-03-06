require('config')
require('helper')

-- chest
CHEST = {}

local math_ceil = math.ceil

local names = g_names
local startup_settings = g_startup_settings

local function show_flying_text(entity, nearest_lc)
    local text = {}
    if nearest_lc ~= nil then
        text = {
            names.locale_flying_text_when_build_chest,
            string.format('%.1f', calc_distance_between_two_points(entity.position, nearest_lc.eei.position))
        }
    else
        text = {
            names.locale_flying_text_when_build_chest_no_nearest_lc
        }
    end
    entity.surface.create_entity {
        name = names.distance_flying_text,
        position = {x = entity.position.x, y = entity.position.y - 1},
        color = {r = 228 / 255, g = 236 / 255, b = 0},
        text = text
    }
end

-- Add to watch-list
function CHEST:add_cc(entity)
    local index
    local empty_stack = global.cc_entities.empty_stack
    if empty_stack.count > 0 then
        index = empty_stack.data[empty_stack.count]
        empty_stack.count = empty_stack.count - 1
    else
        index = global.cc_entities.index
        global.cc_entities.index = global.cc_entities.index + 1
    end

    local nearest_lc = CHEST:find_nearest_lc(entity, 1)
    global.cc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity, nearest_lc)

    global.cc_entities.count = global.cc_entities.count + 1

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.count * startup_settings.check_cc_percentages)
end

-- Add to watch-list
function CHEST:add_rc(entity)
    local index
    local empty_stack = global.rc_entities.empty_stack
    if empty_stack.count > 0 then
        index = empty_stack.data[empty_stack.count]
        empty_stack.count = empty_stack.count - 1
    else
        index = global.rc_entities.index
        global.rc_entities.index = global.rc_entities.index + 1
    end

    local nearest_lc = CHEST:find_nearest_lc(entity, 2)
    global.rc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity, nearest_lc)

    global.rc_entities.count = global.rc_entities.count + 1

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.count * startup_settings.check_rc_percentages)
end

function CHEST:remove_cc(index)
    -- remove invalid chest
    global.cc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.cc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.count * startup_settings.check_cc_percentages)
end

function CHEST:remove_rc(index)
    -- remove invalid chest
    global.rc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.rc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.count * startup_settings.check_rc_percentages)
end

function CHEST:calc_power_consumption(distance, eei, chest_type)
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
function CHEST:find_nearest_lc(entity, chest_type)
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

    return CHEST:calc_power_consumption(nearest_distance, eei, chest_type)
end

-- Add to watch-list
local function re_scan_add_cc(entity)
    local index = global.cc_entities.index
    local nearest_lc = CHEST:find_nearest_lc(entity, 1)

    global.cc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    global.cc_entities.index = global.cc_entities.index + 1
end

-- Add to watch-list
local function re_scan_add_rc(entity)
    local index = global.rc_entities.index
    local nearest_lc = CHEST:find_nearest_lc(entity, 2)

    global.rc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    global.rc_entities.index = global.rc_entities.index + 1
end

function CHEST:re_scan_chests()
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

    global.cc_entities.count = total_ccs
    global.rc_entities.count = total_rcs

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(total_ccs * startup_settings.check_cc_percentages)
    global.runtime_vars.rc_check_per_round = math_ceil(total_rcs * startup_settings.check_rc_percentages)
end

return CHEST
