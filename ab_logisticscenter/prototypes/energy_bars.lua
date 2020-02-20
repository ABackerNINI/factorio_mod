require('config')

local function make_bars()
    local neutral_flags = {'not-repairable', 'not-blueprintable', 'not-deconstructable', 'placeable-off-grid', 'not-on-map', 'placeable-neutral'}

    for index = 0, 13 do
        data:extend(
            {
                {
                    type = 'simple-entity',
                    name = g_names.energy_bar .. index,
                    icon = LC_PATH .. '/graphics/nothing.png',
                    icon_size = 4,
                    flags = neutral_flags,
                    render_layer = 'object', --- 'higher-object-above', --- 'entity-info-icon-above',
                    order = 'pb2' .. index,
                    pictures = {
                        {
                            filename = LC_PATH .. '/graphics/energy_bar/liquid-square-' .. index .. '.png',
                            width = 388,
                            height = 40,
                            scale = 0.25,
                            shift = {0, 0.1}
                        }
                    }
                }
            }
        )
    end
end

make_bars()
