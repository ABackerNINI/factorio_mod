require('config')

local hsl = 1.5
local hcl = 1.4

data:extend(
    {
        {
            type = 'simple-entity',
            name = g_names.logistics_center_animation,
            icon = LC_PATH .. '/graphics/icons/logistics-center.png',
            icon_size = 32,
            flags = {'not-on-map'},
            selectable_in_game = false,
            render_layer = 'object', --'entity-info-icon',
            -- collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            -- selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            animations = {
                {
                    filename = LC_PATH .. '/graphics/entity/logistics-center.png',
                    priority = 'extra-high',
                    width = 113,
                    height = 91,
                    frame_count = 33,
                    line_length = 11,
                    animation_speed = 1 / 5,
                    shift = {-0.29, -0.35}
                }
            }
        }
    }
)

---------------------------------------------------------------------------------------
