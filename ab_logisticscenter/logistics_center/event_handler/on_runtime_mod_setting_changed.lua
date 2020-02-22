require('config')
local LC = require('logistics_center.logistics_center')
local CHEST = require('logistics_center.chest')

function on_runtime_mod_setting_changed(event)
    if event.setting_type == 'runtime-global' then
        local setting = event.setting
        if setting == g_names.lc_animation then
            LC:on_lc_animation_setting_changed()
        elseif setting == g_names.re_scan_chests then
            -- local re_scan_chests = settings.global[g_names.re_scan_chests].value
            -- if re_scan_chests == true then
            CHEST:re_scan_chests()
        -- end
        end
    -- else --- 'runtime-per-user'
    end
end
