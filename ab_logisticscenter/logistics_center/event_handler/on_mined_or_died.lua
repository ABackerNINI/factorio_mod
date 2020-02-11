require('config')
require('logistics_center.helper')
require('logistics_center.recalc_distance')

local names = g_names
local config = g_config

function on_mined_or_died(event)
    local entity = event.entity

    -- can't get index by entity except using 'for'
    -- no need to remove chest here,
    -- but should check valid before using entities stored in the watch-list
    -- if entity.name == names.collecter_chest then
    -- elseif entity.name == names.requester_chest then
    -- else
    if entity.name == names.logistics_center then
        global.lc_entities.count = global.lc_entities.count - 1

        -- local p_str = position_to_string(entity.position)
        local p_str = surface_and_position_to_string(entity.surface.index, entity.position)
        -- game.print("pre-mined:"..p_str)
        -- destroy the electric energy interface
        local lc = global.lc_entities.entities[p_str]
        if lc ~= nil then
            local eei = lc.eei
            if eei ~= nil then
                eei.destroy()
                global.lc_entities.entities[p_str] = nil
            end
        else
            game.print('ab_logistics_center: nil lc ' .. p_str .. '@on_mined_or_died')
            game.print('ab_logistics_center: please report this bug on the mod portal, thanks.')
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
