require('config')
require('logistics_center.updates.v0_16_0-v0_18_4-old_version')
require('logistics_center.updates.v0_18_4-v0_18_5-add_center_position')

-- global data migrations
-- call only in script.on_configuration_changed()
function global_data_migrations()
    if global.global_data_version ~= nil then -- and global.global_data_version ~= g_config.global_data_version then
        game.print('ab_logisticscenter: global_data_version: ' .. global.global_data_version)
        if global_data_version == g_config.global_data_version then
            return
        end
    end

    update()

    add_center_position()

    -- global.global_data_version = g_config.global_data_version
end
