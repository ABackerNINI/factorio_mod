local ITEM = require('logistics_center.item')
local CHEST = require('logistics_center.chest')
local LC = require('logistics_center.logistics_center')

local math_floor = math.floor
local math_min = math.min

-- check all collector chests, all items
function check_ccs_on_nth_tick_all(nth_tick_event)
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
        local chest = global.cc_entities.entities[index]
        if chest ~= nil then
            if chest.entity.valid then
                if chest.nearest_lc ~= nil then
                    local inventory = chest.entity.get_output_inventory()
                    if not inventory.is_empty() then
                        local eei = chest.nearest_lc.eei
                        local power_consumption = chest.nearest_lc.power_consumption
                        local contents = inventory.get_contents()

                        for name, count in pairs(contents) do
                            -- stock.get_item(name)
                            local item = global.items_stock.items[name]
                            if item == nil then
                                item = ITEM:add(name)
                            end

                            -- enough energy?
                            count = math_min(count, math_floor(eei.energy / power_consumption))
                            -- calc max_control
                            count = math_min(count, item.max_control - item.stock)

                            if count > 0 then
                                crc_item_stack.name = name
                                crc_item_stack.count = count
                                count = inventory.remove(crc_item_stack)
                                item.stock = item.stock + count
                                eei.energy = eei.energy - count * power_consumption
                                LC:update_lc_signal(item, name)

                                if eei.energy < power_consumption then
                                    break
                                end
                            end
                        end
                    end
                end
            else
                CHEST:remove_cc(index)
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
function check_ccs_on_nth_tick_ores_only(nth_tick_event)
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
        local chest = global.cc_entities.entities[index]
        if chest ~= nil then
            if chest.entity.valid then
                if chest.nearest_lc ~= nil then
                    local inventory = chest.entity.get_output_inventory()
                    if not inventory.is_empty() then
                        local eei = chest.nearest_lc.eei
                        local power_consumption = chest.nearest_lc.power_consumption
                        local contents = inventory.get_contents()

                        for name, count in pairs(contents) do
                            ore_entity = game.entity_prototypes[name]
                            if ore_entity ~= nil and ore_entity.type == 'resource' then -- game.item_prototypes[name] ~= nil?
                                -- stock.get_item(name)
                                local item = global.items_stock.items[name]
                                if item == nil then
                                    item = ITEM:add(name)
                                end

                                -- enough energy?
                                count = math_min(count, math_floor(eei.energy / power_consumption))
                                -- calc max_control
                                count = math_min(count, item.max_control - item.stock)

                                if count > 0 then
                                    crc_item_stack.name = name
                                    crc_item_stack.count = count
                                    count = inventory.remove(crc_item_stack)
                                    item.stock = item.stock + count
                                    eei.energy = eei.energy - count * power_consumption
                                    LC:update_lc_signal(item, name)

                                    if eei.energy < power_consumption then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            else
                CHEST:remove_cc(index)
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
function check_ccs_on_nth_tick_except_ores(nth_tick_event)
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
        local chest = global.cc_entities.entities[index]
        if chest ~= nil then
            if chest.entity.valid then
                if chest.nearest_lc ~= nil then
                    local inventory = chest.entity.get_output_inventory()
                    if not inventory.is_empty() then
                        local eei = chest.nearest_lc.eei
                        local power_consumption = chest.nearest_lc.power_consumption
                        local contents = inventory.get_contents()

                        for name, count in pairs(contents) do
                            ore_entity = game.entity_prototypes[name]
                            if ore_entity == nil or game.entity_prototypes[name].type ~= 'resource' then
                                -- stock.get_item(name)
                                local item = global.items_stock.items[name]
                                if item == nil then
                                    item = ITEM:add(name)
                                end

                                -- enough energy?
                                count = math_min(count, math_floor(eei.energy / power_consumption))
                                -- calc max_control
                                count = math_min(count, item.max_control - item.stock)

                                if count > 0 then
                                    crc_item_stack.name = name
                                    crc_item_stack.count = count
                                    count = inventory.remove(crc_item_stack)
                                    item.stock = item.stock + count
                                    eei.energy = eei.energy - count * power_consumption
                                    LC:update_lc_signal(item, name)

                                    if eei.energy < power_consumption then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            else
                CHEST:remove_cc(index)
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
