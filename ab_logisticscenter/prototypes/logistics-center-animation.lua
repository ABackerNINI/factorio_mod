local LC = '__ab_logisticscenter__'

require('config')

local names = g_names

data:extend(
    {
        {
            type = 'simple-entity',
            name = names.logistics_center_animation,
            icon = LC .. '/graphics/icons/logistics-center.png',
            icon_size = 32,
            flags = {'not-on-map'},
            selectable_in_game = false,
            -- minable = nil,
            -- max_health = 1,
            -- corpse = "big-remnants",
            -- dying_explosion = "medium-explosion",
            -- collision_box = {{-hcl, -hcl}, {hcl, hcl}},
            -- selection_box = {{-hsl, -hsl}, {hsl, hsl}},
            animations = {
                {
                    stripes = {
                        {
                            filename = LC .. '/graphics/entity/animation/1-8.png',
                            width_in_frames = 4,
                            height_in_frames = 2
                        },
                        {
                            filename = LC .. '/graphics/entity/animation/9-16.png',
                            width_in_frames = 4,
                            height_in_frames = 2
                        },
                        {
                            filename = LC .. '/graphics/entity/animation/17-24.png',
                            width_in_frames = 4,
                            height_in_frames = 2
                        },
                        {
                            filename = LC .. '/graphics/entity/animation/25-32.png',
                            width_in_frames = 4,
                            height_in_frames = 2
                        },
                        {
                            filename = LC .. '/graphics/entity/animation/33-40.png',
                            width_in_frames = 4,
                            height_in_frames = 2
                        },
                        {
                            filename = LC .. '/graphics/entity/animation/41-44.png',
                            width_in_frames = 4,
                            height_in_frames = 1
                        }
                    },
                    width = 489,
                    height = 717,
                    scale = 0.5,
                    frame_count = 44,
                    animation_speed = 0.8,
                    shift = {-0.4, -3.4}
                }
            }
        }
    }
)

---------------------------------------------------------------------------------------
