local EB = require('logistics_center.energy_bar')

function on_load()
    EB:re_register_handler()
end
