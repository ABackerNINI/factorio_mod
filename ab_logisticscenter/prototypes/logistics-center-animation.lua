require('config')

local hsl = 1.5
local hcl = 1.2

local width = 98
local height = 87

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
                    width = width,
                    height = height,
                    frame_count = 231,
                    line_length = 11,
                    animation_speed = 1 / 8,
                    shift = {-0.5, -0.5},
                    -- scale = 1.5
                }
            }
        }
    }
)

---------------------------------------------------------------------------------------
