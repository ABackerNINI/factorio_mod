ITEM = {}

local startup_settings = g_startup_settings

-- Add item
function ITEM:add(name)
    -- find the smallest index not in use
    local index_s = {}
    for k, v in pairs(global.items_stock.items) do
        index_s[v.index] = 1
    end

    -- default index = config.lc_item_slot_count + 1
    local index = startup_settings.lc_item_slot_count + 1
    for i = 1, startup_settings.lc_item_slot_count do
        if index_s[i] == nil then
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

-- Del item
function ITEM:remove(name)
    global.items_stock.items[name] = nil
end

return ITEM
