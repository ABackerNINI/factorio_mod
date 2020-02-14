require('config')

local names = g_names

data:extend(
    {
        {
            type = 'flying-text',
            name = names.distance_flying_text,
            speed = 1 / 60, -- tile per tick
            time_to_live = 60 * 5, -- tick
            text_alignment = 'left'
        }
    }
)
