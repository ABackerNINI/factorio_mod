require('config')

local names = g_names
local config = g_config

function on_destroy(event)
    local entity = event.entity

    -- incase a nil value by script_raised_destroy by other mods
    if entity == nil then return end

    -- can't get index by entity except using 'for'
    -- no need to remove chest here,
    -- but should check valid before using entities stored in the watch-list
    -- if entity.name == names.collecter_chest then
    -- elseif entity.name == names.requester_chest then
    -- else
    if entity.name == names.logistics_center then
        LC:remove(entity)
    elseif entity.name == names.logistics_center_controller then
        LCC:remove(entity)
    end
end
