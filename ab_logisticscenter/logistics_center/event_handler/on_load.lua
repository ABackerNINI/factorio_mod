local EB = require('logistics_center.energy_bar')
local LC = require('logistics_center.logistics_center')

function on_load()
    EB:re_register_handler()
    LC:re_register_check_animation_handler()
end
