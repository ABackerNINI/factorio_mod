require('config')
require('logistics_center.updates.v0_16_0-v0_18_4-old_version')
require('logistics_center.updates.v0_18_4-v0_18_5-add_center_position')
require('logistics_center.updates.v0_18_6-v0_18_7-re_create_lc_animations')

-- global data migrations
-- call only in script.on_configuration_changed()
function global_data_migrations()
    if global.global_data_version ~= nil then -- and global.global_data_version ~= g_config.global_data_version then
        game.print('ab_logisticscenter: global_data_version: ' .. global.global_data_version)
        if global_data_version == g_config.global_data_version then
            return
        end
    end

    -- nil - 16
    update()

    -- 17
    add_center_position()

    -- 18
    re_create_lc_animations()

    -- global.global_data_version = g_config.global_data_version
end
