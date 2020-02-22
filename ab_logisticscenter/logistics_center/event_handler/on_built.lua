require('config')
local CHEST = require('logistics_center.chest')
local LC = require('logistics_center.logistics_center')
local LCC = require('logistics_center.logistics_center_controller')

local names = g_names

function on_built(event)
    local entity = event.created_entity
    
    -- incase a nil value by script_raised_built by other mods
    if entity == nil then return end

    local name = entity.name

    -- if string.match(name,names.collecter_chest_pattern) ~= nil then  --- this is not recommended
    if name == names.collecter_chest_1_1 then -- or
        -- if string.match(name,names.requester_chest_pattern) ~= nil then  --- this is not recommended
        -- name == names.collecter_chest_3_6 or
        -- name == names.collecter_chest_6_3
        CHEST:add_cc(entity)
    elseif name == names.requester_chest_1_1 then -- or
        -- name == names.requester_chest_3_6 or
        -- name == names.requester_chest_6_3
        CHEST:add_rc(entity)
    elseif name == names.logistics_center then
        LC:add(entity)
    elseif name == names.logistics_center_controller then
        LCC:add(entity)
    end
end
