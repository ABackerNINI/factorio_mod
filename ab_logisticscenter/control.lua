require('config')
require('updates')

local config = get_config()
local names = get_names()
local startup_settings = get_startup_settings()

local math_ceil = math.ceil
local math_floor = math.floor
local math_min = math.min
local math_max = math.max

-- INIT FUNCTIONS
-- init globals
-- call on mod init.should call it only once
local function init_globals()
    global.global_data_version = config.global_data_version

    -- {index,items = {["item_name"] = {index,stock,enable,max_control}}}
    global.items_stock =
        global.items_stock or
        {
            index = 1,
            items = {}
        }

    -- multi-lc causes a severe bug on energy consumption
    -- {count,entities = {["pos_str"] = {lc,eei}}}
    global.lc_entities =
        global.lc_entities or
        {
            count = 0,
            entities = {}
        }

    -- {index,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,eei}}}}
    global.cc_entities =
        global.cc_entities or
        {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

    -- {index,empty_stack,entities = {[index] = {entity,nearest_lc = {power_consumption,eei}}}}
    global.rc_entities =
        global.rc_entities or
        {
            index = 1,
            empty_stack = {count = 0, data = {}},
            entities = {}
        }

    -- {count,parameters,entities={[index] = entity}
    global.lcc_entity =
        global.lcc_entity or
        {
            count = 0,
            parameters = nil,
            entities = {}
        }

    global.technologies =
        global.technologies or
        {
            lc_capacity = config.default_lc_capacity,
            cc_power_consumption = startup_settings.default_cc_power_consumption,
            rc_power_consumption = startup_settings.default_rc_power_consumption,
            power_consumption_percentage = 1,
            tech_lc_capacity_real_level = 0,
            tech_power_consumption_real_level = 0
        }

    global.runtime_vars =
        global.runtime_vars or
        {
            cc_check_per_round = 0,
            cc_checked_index = 0,
            rc_check_per_round = 0,
            rc_checked_index = 0
        }
end

script.on_init(
    function()
        init_globals()
    end
)

-- will be called on every save and load
-- script.on_load(
--     function()
--     end
-- )

script.on_configuration_changed(
    function(config_changed_data)
        global_data_migrations()

        -- in case global tables were altered in global_data_migrations()
        -- and cc/rc counts may change after migrations
        global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
        global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)

        -- recalc power consumption if configuration changed
        local default_power_consumption_changed = false

        if
            global.technologies.cc_power_consumption ~= math_ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage) or
                global.technologies.rc_power_consumption ~= math_ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)
         then
            default_power_consumption_changed = true
        end

        global.technologies.cc_power_consumption = math_ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage)
        global.technologies.rc_power_consumption = math_ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)

        if default_power_consumption_changed == true then
            game.print(
                {
                    config.locale_print_after_power_consumption_configuration_changed,
                    global.technologies.cc_power_consumption,
                    global.technologies.rc_power_consumption
                }
            )
        end

        -- check if item were removed
        for k, v in pairs(global.items_stock.items) do
            if game.item_prototypes[k] ~= nil then
                v.enable = true
            else
                v.enable = false
            end
        end
    end
)

local function calc_distance_between_two_points(p1, p2)
    local dx = math.abs(p1.x - p2.x)
    local dy = math.abs(p1.y - p2.y)
    return math.sqrt(dx * dx + dy * dy)
end

local function position_to_string(p)
    return p.x .. ',' .. p.y
end

-- add item
local function add_item(name)
    -- find the smallest index not in use
    local indexs = {}
    for k, v in pairs(global.items_stock.items) do
        indexs[v.index] = 1
    end

    -- default index = config.lc_item_slot_count + 1
    local index = startup_settings.lc_item_slot_count + 1
    for i = 1, startup_settings.lc_item_slot_count do
        if indexs[i] == nil then
            index = i
            break
        end
    end

    -- add item
    local item = {index = index, stock = 0, enable = true, max_control = global.technologies.lc_capacity}
    global.items_stock.items[name] = item
    global.items_stock.index = global.items_stock.index + 1
    return item
end

-- del item
local function del_item(name)
    global.items_stock.items[name] = nil
end

local function remove_cc(index)
    -- remove invalid chest
    global.cc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.cc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
end

local function remove_rc(index)
    -- remove invalid chest
    global.rc_entities.entities[index] = nil

    -- push the index to the stack
    local empty_stack = global.rc_entities.empty_stack
    empty_stack.count = empty_stack.count + 1
    empty_stack.data[empty_stack.count] = index

    -- recalc cpr
    global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
end

-- find nearest lc
local function find_nearest_lc(entity)
    if global.lc_entities.count == 0 then
        return nil
    end

    local eei = nil
    local nearest_distance = config.big_number -- should big enough
    for k, v in pairs(global.lc_entities.entities) do
        local distance = calc_distance_between_two_points(entity.position, v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            eei = v.eei
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
        game.print("[ab_logisticscenter]:error,didn't find@find_nearest_lc")
        return nil
    end
end

-- recalc distance from cc/rc to the nearest lc
-- call after lc entity being created or destoried
local function recalc_distance()
    -- recalc cc
    for index, v in pairs(global.cc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_cc(index)
        end
    end

    -- recalc rc
    for index, v in pairs(global.rc_entities.entities) do
        if v.entity.valid then
            v.nearest_lc = find_nearest_lc(v.entity)
        else
            remove_rc(index)
        end
    end
end

-- update signals
local function update_signals(item, item_name)
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

-- update lc controller
local function update_lc_controller()
    if global.lcc_entity.parameters == nil then
        return
    end

    local signals = global.lcc_entity.parameters.parameters
    local item1 = nil -- item the contoller set
    local item2 = nil -- item to replace
    for k, v in pairs(signals) do
        if v.signal.type == 'item' and v.signal.name ~= nil then
            item1 = global.items_stock.items[v.signal.name]
            if item1 == nil and v.count ~= -1 then
                item1 = add_item(v.signal.name)
            end

            if item1 ~= nil then
                item2 = nil
                for k2, v2 in pairs(global.items_stock.items) do
                    if v2.index == v.index then
                        item2 = v2
                        break
                    end
                end
                if item2 ~= nil then
                    item2.index = item1.index
                end

                item1.index = v.index
                if v.count == 1 then -- no limit,just change the signal place
                    item1.max_control = global.technologies.lc_capacity
                elseif v.count == -1 then -- delete item if item stock is zero
                    if item1.stock == 0 then
                        del_item(v.signal.name)
                    end
                else -- set limit and change the signal place
                    item1.max_control = math_min(v.count, global.technologies.lc_capacity)
                end
            end
        end
    end
end

-- on built
script.on_event(
    {defines.events.on_built_entity, defines.events.on_robot_built_entity},
    function(event)
        local entity = event.created_entity
        local name = entity.name

        -- if string.match(name,names.collecter_chest_pattern) ~= nil then  --- this is not recommanded
        if name == names.collecter_chest_1_1 then -- or
            -- if string.match(name,names.requester_chest_pattern) ~= nil then  --- this is not recommanded
            -- name == names.collecter_chest_3_6 or
            -- name == names.collecter_chest_6_3
            -- add cc to the watch-list
            local index = global.cc_entities.index
            local empty_stack = global.cc_entities.empty_stack
            if empty_stack.count > 0 then
                index = empty_stack.data[empty_stack.count]
                empty_stack.count = empty_stack.count - 1
            end
            global.cc_entities.entities[index] = {entity = entity, nearest_lc = find_nearest_lc(entity)}

            -- show flying text
            if global.cc_entities.entities[index].nearest_lc ~= nil then
                entity.surface.create_entity {
                    name = 'flying-text',
                    position = {x = entity.position.x, y = entity.position.y - 1},
                    color = {r = 228 / 255, g = 236 / 255, b = 0},
                    text = {
                        config.locale_flying_text_when_build_chest,
                        string.format('%.1f', calc_distance_between_two_points(entity.position, global.cc_entities.entities[index].nearest_lc.eei.position))
                    }
                }
            end

            global.cc_entities.index = global.cc_entities.index + 1

            -- recalc cpr
            global.runtime_vars.cc_check_per_round = math_ceil(global.cc_entities.index * startup_settings.check_cc_percentages)
        elseif name == names.requester_chest_1_1 then -- or
            -- name == names.requester_chest_3_6 or
            -- name == names.requester_chest_6_3
            -- add rc to the watch-list
            local index = global.rc_entities.index
            local empty_stack = global.rc_entities.empty_stack
            if empty_stack.count > 0 then
                index = empty_stack.data[empty_stack.count]
                empty_stack.count = empty_stack.count - 1
            end
            global.rc_entities.entities[index] = {entity = entity, nearest_lc = find_nearest_lc(entity)}

            -- show flying text
            if global.rc_entities.entities[index].nearest_lc ~= nil then
                entity.surface.create_entity {
                    name = 'flying-text',
                    position = {x = entity.position.x, y = entity.position.y - 1},
                    color = {r = 228 / 255, g = 236 / 255, b = 0},
                    text = {
                        config.locale_flying_text_when_build_chest,
                        string.format('%.1f', calc_distance_between_two_points(entity.position, global.rc_entities.entities[index].nearest_lc.eei.position))
                    }
                }
            end

            global.rc_entities.index = global.rc_entities.index + 1

            -- recalc cpr
            global.runtime_vars.rc_check_per_round = math_ceil(global.rc_entities.index * startup_settings.check_rc_percentages)
        elseif name == names.logistics_center then
            -- disable signal output of the lc on default except the very first one
            -- this will cause a problem that signals don't show up immediately after control-behavior enabled
            if global.lc_entities.count > 0 then
                entity.get_or_create_control_behavior().enabled = false
            end

            -- will confilct when entity on diffrent surfaces?
            global.lc_entities.entities[position_to_string(entity.position)] = {
                lc = entity,
                -- create the electric energy interface
                eei = entity.surface.create_entity {
                    name = names.electric_energy_interface,
                    position = entity.position,
                    force = entity.force
                }
                -- ani = entity.surface.create_entity{
                --     name = names.logistics_center_animation,
                --     position = entity.position,
                --     force = entity.force
                -- }
            }

            global.lc_entities.count = global.lc_entities.count + 1

            -- recalc distance
            recalc_distance()
        elseif name == names.logistics_center_controller then
            -- caution:loop with big_number
            for index = 1, config.big_number do
                if global.lcc_entity.entities[index] == nil then -- or global.lcc_entity.entities[index].valid == false
                    if global.lcc_entity.parameters ~= nil then
                        -- set parameters
                        local control_behavior = entity.get_or_create_control_behavior()
                        control_behavior.parameters = global.lcc_entity.parameters

                        -- update lc controller
                        if global.lcc_entity.count == 0 then
                            update_lc_controller()
                        end
                    end

                    global.lcc_entity.entities[index] = entity
                    global.lcc_entity.count = global.lcc_entity.count + 1
                    break
                end
            end
        end
    end
)

-- on pre-mined-item/entity-died
script.on_event(
    {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died},
    function(event)
        local entity = event.entity

        -- can't get index by entity except using 'for'
        -- no need to remove chest here,
        -- but should check valid before using entities stored in the watch-list
        -- if entity.name == names.collecter_chest then
        -- elseif entity.name == names.requester_chest then
        -- else
        if entity.name == names.logistics_center then
            global.lc_entities.count = global.lc_entities.count - 1

            local p_str = position_to_string(entity.position)
            -- game.print("pre-mined:"..p_str)
            -- destroy the electric energy interface
            local eei = global.lc_entities.entities[p_str].eei
            if eei ~= nil then -- it may be nil accidentally and I do not figure out why.
                eei.destroy()
                global.lc_entities.entities[p_str] = nil
            end

            -- recalc distance
            recalc_distance()
        elseif entity.name == names.logistics_center_controller then
            -- caution:loop with big_number
            for index = 1, config.big_number do
                if global.lcc_entity.entities[index] == entity then
                    global.lcc_entity.entities[index] = nil
                    global.lcc_entity.count = global.lcc_entity.count - 1
                    break
                end
            end

            if global.lcc_entity.count == 0 then
                -- reset all max_control
                for k, v in pairs(global.items_stock.items) do
                    v.max_control = global.technologies.lc_capacity
                end
            end
        end
    end
)

-- check all collector chests, all items
local function check_ccs_on_nth_tick_all(nth_tick_event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}

    local index_begin = global.runtime_vars.cc_checked_index + 1
    local index_end = index_begin + global.runtime_vars.cc_check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.cc_entities.index then
            index = index - global.cc_entities.index
        end
        local v = global.cc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = v.nearest_lc.power_consumption
                    local contents = inventory.get_contents()
                    local eei = v.nearest_lc.eei

                    for name, count in pairs(contents) do
                        -- stock.get_item(name)
                        local item = global.items_stock.items[name]
                        if item == nil then
                            item = add_item(name)
                        end

                        -- enough energy?
                        count = math_min(count, math_floor(eei.energy / power_consumption))
                        -- calc max_control
                        count = math_min(count, item.max_control - item.stock)

                        if count > 0 then
                            crc_item_stack.name = name
                            crc_item_stack.count = count
                            inventory.remove(crc_item_stack)
                            item.stock = item.stock + count
                            eei.energy = eei.energy - count * power_consumption
                            update_signals(item, name)

                            if eei.energy < power_consumption then
                                break
                            end
                        end
                    end
                end
            else
                remove_cc(index)
            end
        end
    end

    -- calc checked_index
    if global.cc_entities.index ~= 0 then
        global.runtime_vars.cc_checked_index = index_end % global.cc_entities.index
    else
        global.runtime_vars.cc_checked_index = 0
    end
end

-- check all collector chests, ores only
local function check_ccs_on_nth_tick_ores_only(nth_tick_event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}
    local ore_entity

    local index_begin = global.runtime_vars.cc_checked_index + 1
    local index_end = index_begin + global.runtime_vars.cc_check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.cc_entities.index then
            index = index - global.cc_entities.index
        end
        local v = global.cc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = v.nearest_lc.power_consumption
                    local contents = inventory.get_contents()
                    local eei = v.nearest_lc.eei

                    for name, count in pairs(contents) do
                        ore_entity = game.entity_prototypes[name]
                        if ore_entity ~= nil and ore_entity.type == 'resource' then -- game.item_prototypes[name] ~= nil?
                            -- stock.get_item(name)
                            local item = global.items_stock.items[name]
                            if item == nil then
                                item = add_item(name)
                            end

                            -- enough energy?
                            count = math_min(count, math_floor(eei.energy / power_consumption))
                            -- calc max_control
                            count = math_min(count, item.max_control - item.stock)

                            if count > 0 then
                                crc_item_stack.name = name
                                crc_item_stack.count = count
                                inventory.remove(crc_item_stack)
                                item.stock = item.stock + count
                                eei.energy = eei.energy - count * power_consumption
                                update_signals(item, name)

                                if eei.energy < power_consumption then
                                    break
                                end
                            end
                        end
                    end
                end
            else
                remove_cc(index)
            end
        end
    end

    -- calc checked_index
    if global.cc_entities.index ~= 0 then
        global.runtime_vars.cc_checked_index = index_end % global.cc_entities.index
    else
        global.runtime_vars.cc_checked_index = 0
    end
end

-- check all collector chests, except ores
local function check_ccs_on_nth_tick_except_ores(nth_tick_event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}
    local ore_entity

    local index_begin = global.runtime_vars.cc_checked_index + 1
    local index_end = index_begin + global.runtime_vars.cc_check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.cc_entities.index then
            index = index - global.cc_entities.index
        end
        local v = global.cc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = v.nearest_lc.power_consumption
                    local contents = inventory.get_contents()
                    local eei = v.nearest_lc.eei

                    for name, count in pairs(contents) do
                        ore_entity = game.entity_prototypes[name]
                        if ore_entity == nil or game.entity_prototypes[name].type ~= 'resource' then
                            -- stock.get_item(name)
                            local item = global.items_stock.items[name]
                            if item == nil then
                                item = add_item(name)
                            end

                            -- enough energy?
                            count = math_min(count, math_floor(eei.energy / power_consumption))
                            -- calc max_control
                            count = math_min(count, item.max_control - item.stock)

                            if count > 0 then
                                crc_item_stack.name = name
                                crc_item_stack.count = count
                                inventory.remove(crc_item_stack)
                                item.stock = item.stock + count
                                eei.energy = eei.energy - count * power_consumption
                                update_signals(item, name)

                                if eei.energy < power_consumption then
                                    break
                                end
                            end
                        end
                    end
                end
            else
                remove_cc(index)
            end
        end
    end

    -- calc checked_index
    if global.cc_entities.index ~= 0 then
        global.runtime_vars.cc_checked_index = index_end % global.cc_entities.index
    else
        global.runtime_vars.cc_checked_index = 0
    end
end

-- check all requester chests
local function check_rcs_on_nth_tick(nth_tick_event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}

    local index_begin = global.runtime_vars.rc_checked_index + 1
    local index_end = index_begin + global.runtime_vars.rc_check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("rc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.rc_entities.index then
            index = index - global.rc_entities.index
        end
        local v = global.rc_entities.entities[index]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                local eei = v.nearest_lc.eei
                local power_consumption = v.nearest_lc.power_consumption

                for i = 1, startup_settings.rc_logistic_slots_count do
                    local request_slot = v.entity.get_request_slot(i)
                    if request_slot ~= nil then
                        local name = request_slot.name
                        local count = request_slot.count

                        -- stock.get_item(name)
                        local item = global.items_stock.items[name]
                        -- if item == nil then
                        --     item = add_item(name)
                        -- end
                        if item ~= nil then
                            -- calc shortage
                            count = count - inventory.get_item_count(name)
                            -- enough stock?
                            count = math_min(count, item.stock)
                            -- enough energy?
                            count = math_min(count, math_floor(eei.energy / power_consumption))

                            if count > 0 then
                                crc_item_stack.name = name
                                crc_item_stack.count = count
                                -- in case the inventory is full
                                local inserted_count = inventory.insert(crc_item_stack)
                                item.stock = item.stock - inserted_count
                                eei.energy = eei.energy - inserted_count * power_consumption
                                update_signals(item, name)

                                if eei.energy < power_consumption then
                                    break
                                end
                            end
                        end
                    end
                end
            else
                remove_rc(index)
            end
        end
    end

    -- calc checked_index
    if global.rc_entities.index ~= 0 then
        global.runtime_vars.rc_checked_index = index_end % global.rc_entities.index
    else
        global.runtime_vars.rc_checked_index = 0
    end
end

-- check all collecter chests
if startup_settings.item_type_limitation == nil or startup_settings.item_type_limitation == 'all' then
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_all)
elseif startup_settings.item_type_limitation == 'ores only' then
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_ores_only)
else
    script.on_nth_tick(startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick_except_ores)
end
-- check all requester chests
script.on_nth_tick(startup_settings.check_rc_on_nth_tick, check_rcs_on_nth_tick)

-- update all signals
local function update_lc_signals(entity)
    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signals to the lc(s) which control_behavior are enabled
    -- local parameters = {parameters = signals}
    -- for _, v in pairs(global.lc_entities.entities) do
    --     local control_behavior = v.lc.get_or_create_control_behavior()
    --     if control_behavior.enabled then
    --         control_behavior.parameters = parameters
    --     else
    --         control_behavior.parameters = nil
    --     end
    -- end
    local control_behavior = entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        -- pack all the signals
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
        control_behavior.parameters = parameters
    else
        control_behavior.parameters = nil
    end
end

-- on opened the logistics center
script.on_event(
    defines.events.on_gui_opened,
    function(event)
        local entity = event.entity

        if entity ~= nil and entity.name == names.logistics_center then
            -- update_all_signals()
            local control_behavior = entity.get_or_create_control_behavior()
            if control_behavior.enabled then
                update_lc_signals(entity)
            else
                control_behavior.parameters = nil
            end
        end
    end
)

-- on closed the `logistics center` and `logistics center controller`
script.on_event(
    defines.events.on_gui_closed,
    function(event)
        local entity = event.entity

        if entity ~= nil then
            if entity ~= nil and entity.name == names.logistics_center then -- Logistics Center
                -- update_all_signals()
                local control_behavior = entity.get_or_create_control_behavior()
                if control_behavior.enabled then
                    update_lc_signals(entity)
                else
                    control_behavior.parameters = nil
                end
            elseif entity.name == names.logistics_center_controller then -- Logistics Center Controller
                local parameters = entity.get_or_create_control_behavior().parameters

                -- update all other lccs
                for _, v in pairs(global.lcc_entity.entities) do
                    local control_behavior = v.get_or_create_control_behavior()
                    if control_behavior.enabled == true then
                        control_behavior.parameters = parameters
                    else
                        control_behavior.parameters = nil
                    end
                end

                -- update global parameters
                global.lcc_entity.parameters = parameters

                -- update lc controller
                update_lc_controller()
            end
        end
    end
)

-- commands.add_command("abc()",{"update all signals"},function(event)
--     update_all_signals()
-- end)
-- TECHNOLOGIES
local tech_lc_capacity_names = {}
for i = 1, 4 do
    tech_lc_capacity_names[i] = names.tech_lc_capacity .. '-' .. (i * 10 - 9)
end

local tech_lc_capacity_increment_sum = {} -- 0,200000,500000,1000000
tech_lc_capacity_increment_sum[1] = 0
for i = 2, 4 do
    tech_lc_capacity_increment_sum[i] = tech_lc_capacity_increment_sum[i - 1] + config.tech_lc_capacity_increment[i - 1] * 10
end

local tech_power_consumption_names = {}
for i = 1, 4 do
    tech_power_consumption_names[i] = names.tech_power_consumption .. '-' .. (i * 10 - 9)
end

local tech_power_consumption_decrement_sum = {} -- {0, 0.015, 0.030, 0.045}
tech_power_consumption_decrement_sum[1] = 0
for i = 2, 4 do
    tech_power_consumption_decrement_sum[i] = tech_power_consumption_decrement_sum[i - 1] + config.tech_power_consumption_decrement[i - 1] * 10
end

-- on research finished
script.on_event(
    defines.events.on_research_finished,
    function(event)
        local research = event.research

        if string.match(research.name, names.tech_lc_capacity_pattern) ~= nil then
            for i = 1, 4 do
                if research.name == tech_lc_capacity_names[i] then
                    global.technologies.tech_lc_capacity_real_level = global.technologies.tech_lc_capacity_real_level + 1

                    -- fixed wrong lc capacity after calling research_all_technologies() through Lua script or in sandbox mode
                    if global.technologies.tech_lc_capacity_real_level < (i - 1) * 10 then
                        global.technologies.lc_capacity =
                            config.default_lc_capacity + tech_lc_capacity_increment_sum[i] +
                            config.tech_lc_capacity_increment[i] * (global.technologies.tech_lc_capacity_real_level - (i - 1)) * 10
                    else
                        global.technologies.lc_capacity =
                            config.default_lc_capacity + tech_lc_capacity_increment_sum[i] +
                            config.tech_lc_capacity_increment[i] * (global.technologies.tech_lc_capacity_real_level - (i - 1) * 10)
                    end

                    -- update max_control
                    for k, v in pairs(global.items_stock.items) do
                        v.max_control = global.technologies.lc_capacity
                    end
                    update_lc_controller()

                    game.print(
                        {
                            'ab-logisticscenter-text.print-after-tech-lc-capacity-researched',
                            global.technologies.lc_capacity
                        }
                    )

                    break
                end
            end
        elseif string.match(research.name, names.tech_power_consumption_pattern) ~= nil then
            for i = 1, 4 do
                if research.name == tech_power_consumption_names[i] then
                    global.technologies.tech_power_consumption_real_level = global.technologies.tech_power_consumption_real_level + 1
                    local power_consumption_percentage

                    -- fixed wrong power consumption after calling research_all_technologies() through Lua script or in sandbox mode
                    if global.technologies.tech_power_consumption_real_level < (i - 1) * 10 then -- fix with calling research_all_technologies() through Lua script
                        power_consumption_percentage =
                            1 -
                            (tech_power_consumption_decrement_sum[i] +
                                config.tech_power_consumption_decrement[i] * (global.technologies.tech_power_consumption_real_level - (i - 1)) * 10)
                    else
                        power_consumption_percentage =
                            1 -
                            (tech_power_consumption_decrement_sum[i] +
                                config.tech_power_consumption_decrement[i] * (global.technologies.tech_power_consumption_real_level - (i - 1) * 10))
                    end

                    global.technologies.power_consumption_percentage = power_consumption_percentage

                    global.technologies.cc_power_consumption = math_ceil(startup_settings.default_cc_power_consumption * power_consumption_percentage)

                    global.technologies.rc_power_consumption = math_ceil(startup_settings.default_rc_power_consumption * power_consumption_percentage)

                    game.print(
                        {
                            config.locale_print_after_tech_power_consumption_researched,
                            global.technologies.cc_power_consumption,
                            global.technologies.rc_power_consumption
                        }
                    )

                    break
                end
            end

            -- recalc distance
            recalc_distance()
        end
    end
)

-- on player created
script.on_event(
    defines.events.on_player_created,
    function(event)
        local player = game.players[event.player_index]
        local quick_start = startup_settings.quick_start

        if quick_start == nil then
            quick_start = 1
        end

        if quick_start > 0 then
            local items = {
                {names.logistics_center, quick_start},
                {names.collecter_chest_1_1, 50},
                {names.requester_chest_1_1, 50}
            }

            local inventory = player.get_main_inventory() -- get_inventory(defines.inventory.character_main)
            if inventory ~= nil then
                for k, v in pairs(items) do
                    inventory.insert({name = v[1], count = v[2]})
                end
            end
        end
    end
)
