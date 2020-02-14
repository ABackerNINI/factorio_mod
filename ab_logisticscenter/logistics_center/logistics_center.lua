require('helper')
local CHEST = require('chest')

-- logistics center
LC = {}

local math_ceil = math.ceil

local names = g_names
local config = g_config
local startup_settings = g_startup_settings

local function pack_signals()
    -- pack all the signals in items_stock
    local signals = {}
    local i = 1
    for item_name, item in pairs(global.items_stock.items) do
        local signal = nil
        if item.enable == true then
            -- game.print(item_name)
            if item.index < startup_settings.lc_item_slot_count then
                signal = {signal = {type = 'item', name = item_name}, count = item.stock, index = item.index}
            end
        end
        signals[i] = signal
        i = i + 1
    end
    local parameters = {parameters = signals}

    return parameters
end

-- update single lc signal
function LC:update_lc_signal(item, item_name)
    -- pack the signal
    local signal = nil
    -- local item = global.items_stock.items[item_name]
    if item.index < startup_settings.lc_item_slot_count then
        signal = {signal = {type = 'item', name = item_name}, count = item.stock}
    end

    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signal to the lc(s) which control_behavior are enabled
    for _, v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.set_signal(item.index, signal)
        end
    end
end

-- update lc signals
function LC:update_lc_signals(entity)
    local control_behavior = entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        control_behavior.parameters = pack_signals()
    else
        control_behavior.parameters = nil
    end
end

-- update all lc signals
function LC:update_all_lc_signals()
    -- pack all the signals
    -- local signals = {}
    -- local i = 1
    -- for item_name, item in pairs(global.items_stock.items) do
    --     local signal = nil
    --     if item.enable == true then
    --         --- game.print(item_name)
    --         if item.index < startup_settings.lc_item_slot_count then
    --             signal = {signal = {type = 'item', name = item_name}, count = item.stock, index = item.index}
    --         end
    --     end
    --     signals[i] = signal
    --     i = i + 1
    -- end

    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signals to the lc(s) which control_behavior are enabled
    local parameters = pack_signals()
    for _, v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.parameters = parameters
        else
            control_behavior.parameters = nil
        end
    end
end

-- Find nearest lc
function LC:find_nearest_lc(entity)
    if global.lc_entities.count == 0 then
        return nil
    end

    local surface = entity.surface.index
    local eei = nil
    local nearest_distance = 1000000000 -- should big enough
    for k, v in pairs(global.lc_entities.entities) do
        if surface == v.lc.surface.index then
            local distance = calc_distance_between_two_points(entity.position, v.lc.position)
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
        -- if string.match(entity.name,names.collecter_chest_pattern) ~= nil then this is not recommanded
        if entity.name == names.collecter_chest_1_1 then -- or
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

-- recalc distance from cc/rc to the nearest lc
-- call after lc entity being created or destoried
function LC:recalc_distance()
    -- recalc cc
    for index, v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = LC:find_nearest_lc(v.entity)
        else
            CHEST:remove_cc(index)
        end
    end

    -- recalc rc
    for index, v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = LC:find_nearest_lc(v.entity)
        else
            CHEST:remove_rc(index)
        end
    end
end


return LC
