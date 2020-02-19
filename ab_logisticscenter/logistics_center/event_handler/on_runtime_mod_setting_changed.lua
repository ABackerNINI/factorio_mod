require('config')
local LC = require('logistics_center.logistics_center')

function on_runtime_mod_setting_changed(event)
    if event.setting_type == 'runtime-global' then
        if event.setting == g_names.lc_animation then
            LC:on_lc_animation_setting_changed()
        end
    -- else --- 'runtime-per-user'
    end
end
