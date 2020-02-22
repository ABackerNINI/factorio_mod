require('config')

local function make_tech(index, icon, unit)
    local prerequisites = {}
    local name
    if index == 1 then
        name = g_names.tech_lc_capacity .. '-0'
    else
        if index == 2 then
            prerequisites = {g_names.tech_lc_capacity .. '-0'}
        else
            prerequisites = {g_names.tech_lc_capacity .. '-' .. (index * 10 - 19)}
        end
        name = g_names.tech_lc_capacity .. '-' .. (index * 10 - 9)
    end

    data:extend(
        {
            {
                type = 'technology',
                name = name,
                icon = icon,
                icon_size = 128,
                enable = true,
                upgrade = true,
                prerequisites = prerequisites,
                effects = {},
                unit = unit,
                max_level = index * 10,
                localised_name = {'technology-name.ab-lc-tech-lc-capacity-t' .. index},
                localised_description = {'technology-description.ab-lc-tech-lc-capacity-t' .. index},
                order = 'ab-a-a'
            }
        }
    )
end

local unit_1 = {
    count = 100 * g_startup_settings.tech_cost,
    ingredients = {
        {'automation-science-pack', 2},
        {'logistic-science-pack', 1}
    },
    time = 30
}

local unit_2 = {
    count = 150 * g_startup_settings.tech_cost,
    ingredients = {
        {'automation-science-pack', 3},
        {'logistic-science-pack', 2},
        {'chemical-science-pack', 1}
    },
    time = 40
}

local unit_3 = {
    count = 200 * g_startup_settings.tech_cost,
    ingredients = {
        {'automation-science-pack', 3},
        {'logistic-science-pack', 3},
        {'chemical-science-pack', 3},
        {'utility-science-pack', 1},
        {'production-science-pack', 1}
    },
    time = 50
}

local unit_4 = {
    count = 300 * g_startup_settings.tech_cost,
    ingredients = {
        {'automation-science-pack', 3},
        {'logistic-science-pack', 3},
        {'chemical-science-pack', 3},
        {'utility-science-pack', 1},
        {'military-science-pack', 2},
        {'production-science-pack', 1},
        {'space-science-pack', 1}
    },
    time = 60
}

make_tech(1, LC_PATH .. '/graphics/technology/logistics-center-capacity.png', unit_1)
make_tech(2, LC_PATH .. '/graphics/technology/logistics-center-capacity.png', unit_2)
make_tech(3, LC_PATH .. '/graphics/technology/logistics-center-capacity.png', unit_3)
make_tech(4, LC_PATH .. '/graphics/technology/logistics-center-capacity.png', unit_4)
