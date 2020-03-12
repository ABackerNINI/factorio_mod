require('config')

local v = 18

-- global_data_version: 17 -> 18
function re_create_lc_animations()
    if global.global_data_version < v then
        game.print({g_names.locale_print_when_global_data_migrate, v - 1})

        for k, v in pairs(global.lc_entities.entities) do
            if v.animation ~= nil then
                v.animation.destroy()
                v.animation =
                    v.lc.surface.create_entity {
                    name = g_names.logistics_center_animation,
                    position = {x = v.lc.position.x, y = v.lc.position.y + 0.5},
                    force = v.lc.force
                }
            end
        end

        -- set global_data_version
        global.global_data_version = v
    end
end
