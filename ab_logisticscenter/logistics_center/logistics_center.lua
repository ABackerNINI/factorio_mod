require('helper')
local CHEST = require('chest')
local EB = require('energy_bar')

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

function LC:add(entity)
    -- disable signal output of the lc on default except the very first one
    -- this will cause a problem that signals don't show up immediately after control-behavior enabled
    if global.lc_entities.count > 0 then
        entity.get_or_create_control_behavior().enabled = false
    end

    -- will conflict when entity on different surfaces?
    -- global.lc_entities.entities[position_to_string(entity.position)] = {
    local p_str = surface_and_position_to_string(entity)
    local pack = {
        lc = entity,
        -- create the electric energy interface
        eei = entity.surface.create_entity {
            name = names.electric_energy_interface,
            position = entity.position,
            force = entity.force
        }
        -- animation = entity.surface.create_entity {
        --     name = names.logistics_center_animation,
        --     position = entity.position,
        --     force = entity.force
        -- }
    }
    -- pack.animation.active = false
    -- pack.eei.active = false
    global.lc_entities.entities[p_str] = pack

    global.lc_entities.count = global.lc_entities.count + 1

    -- recalc distance
    LC:recalc_distance()
end

function LC:destroy(entity)
    global.lc_entities.count = global.lc_entities.count - 1

    -- local p_str = position_to_string(entity.position)
    local p_str = surface_and_position_to_string(entity)
    -- game.print("pre-mined:"..p_str)
    local lc = global.lc_entities.entities[p_str]
    -- destroy the electric energy interface
    lc.eei.destroy()
    -- lc.animation.destroy()
    -- destroy the energy bar
    EB:remove(lc)
    global.lc_entities.entities[p_str] = nil

    -- recalc distance
    LC:recalc_distance()
end

function LC:create_energy_bar(entity)
    -- Create or destroy energy bar for the rotated logistics center

    local p_str = surface_and_position_to_string(entity)
    local lc = global.lc_entities.entities[p_str]

    if lc.energy_bar_index == nil then
        EB:add(lc)
    else
        EB:remove(lc)
    end
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

-- recalc distance from cc/rc to the nearest lc
-- call after lc entity being created or destroyed
function LC:recalc_distance()
    -- recalc cc
    for index, v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = CHEST:find_nearest_lc(v.entity, 1)
        else
            CHEST:remove_cc(index)
        end
    end

    -- recalc rc
    for index, v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = CHEST:find_nearest_lc(v.entity, 2)
        else
            CHEST:remove_rc(index)
        end
    end
end

return LC
