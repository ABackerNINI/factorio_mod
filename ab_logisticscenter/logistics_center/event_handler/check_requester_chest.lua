-- require('logistics_center.item')
require('logistics_center.chest')
require('logistics_center.update_lc_signal')

local math_floor = math.floor
local math_min = math.min

local startup_settings = g_startup_settings

-- check all requester chests
function check_rcs_on_nth_tick(nth_tick_event)
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
                        --     item = add_item(name)  --- do not add signals requested
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
                                update_lc_signal(item, name)

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
