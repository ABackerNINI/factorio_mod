require('config')
local EB = require('logistics_center.energy_bar')

local names = g_names
local config = g_config

local function on_rotated_logistics_center(entity)
    -- Create or destory energy bar for the rotated logistics center

    local p_str = surface_and_position_to_string(entity)
    local lc = global.lc_entities.entities[p_str]

    if lc.energy_bar_index == nil then
        EB:add(lc)
    else
        EB:remove(lc)
    end
end

function on_rotated(event)
    local entity = event.entity
    if entity.name == names.logistics_center then -- Logistics center
        on_rotated_logistics_center(entity)
    end
end
