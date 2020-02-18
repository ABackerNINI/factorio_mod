ITEM = require('item')

LCC = {}

local math_min = math.min

-- update lc controller
function LCC:update_signals()
    if global.lcc_entity.parameters == nil then
        return
    end

    local signals = global.lcc_entity.parameters.parameters
    local item1 = nil -- item the controller set
    local item2 = nil -- item to replace
    for k, v in pairs(signals) do
        if v.signal.type == 'item' and v.signal.name ~= nil then
            item1 = global.items_stock.items[v.signal.name]
            if item1 == nil and v.count ~= -1 then
                item1 = ITEM:add(v.signal.name)
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
                        ITEM:remove(v.signal.name)
                    end
                else -- set limit and change the signal place
                    item1.max_control = math_min(v.count, global.technologies.lc_capacity)
                end
            end
        end
    end
end

function LCC:add(entity)
    -- caution: loop with big_number
    for index = 1, 100000000 do
        if global.lcc_entity.entities[index] == nil then -- or global.lcc_entity.entities[index].valid == false
            if global.lcc_entity.parameters ~= nil then
                -- set parameters
                local control_behavior = entity.get_or_create_control_behavior()
                control_behavior.parameters = global.lcc_entity.parameters

                -- update lc controller
                if global.lcc_entity.count == 0 then
                    LCC:update_signals()
                end
            end

            global.lcc_entity.entities[index] = entity
            global.lcc_entity.count = global.lcc_entity.count + 1
            break
        end
    end
end

function LCC:destroy(entity)
    -- caution: loop with big_number
    for index = 1, 100000000 do
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

function LCC:update(entity)
    local parameters = entity.get_or_create_control_behavior().parameters

    -- update all other lcc-s
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
    LCC:update_signals()
    LC:update_all_lc_signals()
end

return LCC
