require("config")
local config = get_config()
local names = get_names()

--global data migrations
--call only in script.on_configuration_changed()
function global_data_migrations()
    --first change,global.global_data_version = nil
    --
    -- if global.global_data_version < 2 then
    --     game.print({config.locale_print_when_global_data_migrate,1})

    --     --set global_data_version
    --     global.global_data_version = 2
    -- end

    -- global.global_data_version = config.global_data_version
end