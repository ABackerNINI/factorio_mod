ITEM = require('item')

LCC = {}

local math_min = math.min

-- update lc controller
function LCC:update()
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

return LCC
