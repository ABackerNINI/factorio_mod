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