require('config')
require('logistics_center.helper')
local LC = require('logistics_center.logistics_center')
local EB = require('logistics_center.energy_bar')

local names = g_names
local config = g_config

local function on_destroy_logistics_center(entity)
    global.lc_entities.count = global.lc_entities.count - 1

    -- local p_str = position_to_string(entity.position)
    local p_str = surface_and_position_to_string(entity)
    -- game.print("pre-mined:"..p_str)
    local lc = global.lc_entities.entities[p_str]
    -- destroy the electric energy interface
    lc.eei.destroy()
    -- destroy the energy bar
    EB:remove(lc)
    global.lc_entities.entities[p_str] = nil

    -- recalc distance
    LC:recalc_distance()
end

local function on_destroy_logistics_center_controller(entity)
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

function on_destroy(event)
    local entity = event.entity

    -- can't get index by entity except using 'for'
    -- no need to remove chest here,
    -- but should check valid before using entities stored in the watch-list
    -- if entity.name == names.collecter_chest then
    -- elseif entity.name == names.requester_chest then
    -- else
    if entity.name == names.logistics_center then
        on_destroy_logistics_center(entity)
    elseif entity.name == names.logistics_center_controller then
        on_destroy_logistics_center_controller(entity)
    end
end
