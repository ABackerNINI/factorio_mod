local LC = "__ab_logisticscenter__"

require("config")

local names = get_names()

data:extend({
    {
        type = "technology",
        name = names.tech_lc_capacity,
        icon = LC.."/graphics/technology/logistics-center-capacity.png",
        icon_size = 128,
        enable = false,
        prerequisites = {},
        -- upgrade = true,
        effects = {},
        unit = {
            count = 100,
            ingredients = {{"science-pack-1", 1}},
            time = 5
        },
        max_level = "infinite",
        order = "lc-a-a",
    }
})