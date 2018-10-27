local LC = "__ab_logisticscenter__"

require("config")

local names = get_names()

data:extend({
    {
        type = "technology",
        name = names.tech_lc_capacity,
        icon = F.."/graphics/technology/factory-architecture-1.png",
        icon_size = 128,
        prerequisites = {"stone-walls", "logistics"},
        effects = {
            {type = "unlock-recipe", recipe = "factory-1"},
        },
        unit = {
            count = easy_research and 30 or 200,
            ingredients = {{"science-pack-1", 1}},
            time = 30
        },
        order = "a-a",
    }
})