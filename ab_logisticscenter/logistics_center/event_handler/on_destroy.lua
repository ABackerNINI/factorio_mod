require('config')

local names = g_names
local config = g_config

function on_destroy(event)
    local entity = event.entity

    -- can't get index by entity except using 'for'
    -- no need to remove chest here,
    -- but should check valid before using entities stored in the watch-list
    -- if entity.name == names.collecter_chest then
    -- elseif entity.name == names.requester_chest then
    -- else
    if entity.name == names.logistics_center then
        LC:destroy(entity)
    elseif entity.name == names.logistics_center_controller then
        LCC:destroy(entity)
    end
end
