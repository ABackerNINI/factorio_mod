local LC = '__ab_logisticscenter__'

local function make_bars()
    local neutral_flags = {'not-repairable', 'not-blueprintable', 'not-deconstructable', 'placeable-off-grid', 'not-on-map', 'placeable-neutral'}

    for index = 0, 13 do
        data:extend(
            {
                {
                    type = 'simple-entity',
                    name = 'energy-bar-' .. index,
                    icon = LC .. '/graphics/nothing.png',
                    icon_size = 4,
                    flags = neutral_flags,
                    render_layer = 'entity-info-icon',
                    order = 'pb2' .. index,
                    pictures = {
                        {
                            filename = LC .. '/graphics/progress_bar/liquid-square-' .. index .. '.png',
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
