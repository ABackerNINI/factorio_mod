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
            names.locale_flying_text_when_building_chest_no_nearest_lc
        }
    end
    entity.surface.create_entity {
        name = names.distance_flying_text,
        position = {x = entity.position.x, y = entity.position.y - 1},
        color = {r = 228 / 255, g = 236 / 255, b = 0},
        text = text
    }
end

function CHEST:add_cc(entity)
    -- add cc to the watch-list
    local index = global.cc_entities.index
    local empty_stack = global.cc_entities.empty_stack
    if empty_stack.count > 0 then
        index = empty_stack.data[empty_stack.count]
        empty_stack.count = empty_stack.count - 1
    end

    local nearest_lc = CHEST:find_nearest_lc(entity, 1)
    global.cc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity, nearest_lc)

    global.cc_entities.index = global.cc_entities.index + 1

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
end

function CHEST:add_rc(entity)
    -- add rc to the watch-list
    local index = global.rc_entities.index
    local empty_stack = global.rc_entities.empty_stack
    if empty_stack.count > 0 then
        index = empty_stack.data[empty_stack.count]
        empty_stack.count = empty_stack.count - 1
    end

    local nearest_lc = CHEST:find_nearest_lc(entity, 2)
    global.rc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity, nearest_lc)

    global.rc_entities.index = global.rc_entities.index + 1

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
end

function CHEST:remove_cc(index)
    -- remove invalid chest
    global.cc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.cc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
end

function CHEST:remove_rc(index)
    -- remove invalid chest
    global.rc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.rc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
end

-- Find nearest lc
function CHEST:find_nearest_lc(entity, type)
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

    if eei ~= nil then
        local ret = {
            power_consumption = 0,
            eei = eei
        }
        -- if string.match(entity.name,names.collecter_chest_pattern) ~= nil then this is not recommended
        if type == 1 then -- entity.name == names.collecter_chest_1_1 then --- or
            -- entity.name == names.collecter_chest_3_6 or
            -- entity.name == names.collecter_chest_6_3
            ret.power_consumption = math_ceil(nearest_distance * global.technologies.cc_power_consumption)
        else
            ret.power_consumption = math_ceil(nearest_distance * global.technologies.rc_power_consumption)
        end
        return ret
    else
        -- game.print("[ab_logisticscenter]: error, didn't find@find_nearest_lc")
        return nil
    end
end

return CHEST
