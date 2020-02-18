require('config')

data:extend(
    {
        {
            type = 'simple-entity',
            -- type = 'assembling-machine',
            name = g_names.logistics_center_animation,
            icon = LC_PATH .. '/graphics/icons/logistics-center.png',
            icon_size = 32,
            flags = {'not-on-map'},
            selectable_in_game = false,
            -- minable = nil,
            -- max_health = 1,
            -- corpse = "big-remnants",
            -- dying_explosion = "medium-explosion",
            -- collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            -- selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            -- crafting_categories = {'crafting'},
            -- crafting_speed = 1,
            -- energy_source = {
            --     type = 'void',
            --     usage_priority = 'secondary-input',
            --     input_flow_limit = 0 ,
            --     buffer_capacity = 0
            -- },
            -- energy_usage = 0 .. 'W',
            animations = {
                {
                    filename = LC_PATH .. '/graphics/entity/logistics-center.png',
                    priority = 'high',
                    width = 113,
                    height = 91,
                    frame_count = 33,
                    line_length = 11,
                    animation_speed = 1 / 5,
                    shift = {-0.3, -0.3}
                    -- scale = entity_corner * 2 / 3
                }
            }
        }
    }
)

---------------------------------------------------------------------------------------
