require('config')
local LC = require('logistics_center.logistics_center')

local names = g_names
local config = g_config

function on_rotated(event)
    local entity = event.entity
    if entity.name == names.logistics_center then -- Logistics center
        LC:create_energy_bar(entity)
    end
end
