data:extend(
    {
        -- BASIC SETTINGS
        {
            -- Quick start
            type = 'int-setting',
            name = 'ab-logistics-center-quick-start',
            order = 'ab-lc-a',
            setting_type = 'startup',
            default_value = 1,
            allowed_values = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
        },
        {
            -- Tech cost
            type = 'int-setting',
            name = 'ab-logistics-center-tech-cost',
            order = 'ab-lc-b',
            setting_type = 'startup',
            default_value = 3,
            allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 50, 100}
        },
        {
            -- Item type limitation
            type = 'string-setting',
            name = 'ab-logistics-center-item-type-limitation',
            order = 'ab-lc-c',
            setting_type = 'startup',
            default_value = 'all',
            allowed_values = {'all', 'ores only', 'except ores'}
        },
        {
            -- Requester chest logistics slots count
            type = 'int-setting',
            name = 'ab-logistics-center-rc-logistic-slots-count',
            order = 'ab-lc-d',
            setting_type = 'startup',
            default_value = 5,
            allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20}
        },
        {
            -- Logistics center item slot count
            type = 'int-setting',
            name = 'ab-logistics-center-lc-item-slot-count',
            order = 'ab-lc-e',
            setting_type = 'startup',
            default_value = 500,
            allowed_values = {20, 40, 60, 80, 100, 150, 200, 300, 400, 500, 600, 1000, 2000}
        },
        -- POWER CONSUMPTIN SETTINGS
        {
            -- Logistics center power consumption
            type = 'int-setting',
            name = 'ab-logistics-center-lc-power-consumption',
            order = 'ab-lc-p-a',
            setting_type = 'startup',
            default_value = 2000,
            allowed_values = {100, 300, 500, 1000, 1500, 1800, 2000, 3000, 4000, 5000, 8000, 10000, 20000, 30000, 50000,100000}
        },
        {
            -- Default collecter chest power consumption
            type = 'int-setting',
            name = 'ab-logistics-center-default-cc-power-consumption',
            order = 'ab-lc-p-b',
            setting_type = 'startup',
            default_value = 1000,
            allowed_values = {100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1500, 1800, 2000, 3000, 5000, 10000}
        },
        {
            -- Default requester chest power consumption
            type = 'int-setting',
            name = 'ab-logistics-center-default-rc-power-consumption',
            order = 'ab-lc-p-c',
            setting_type = 'startup',
            default_value = 100,
            allowed_values = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 150, 180, 200, 300, 500, 1000, 2000, 3000, 5000}
        },
        -- Warning: the following four settings are important. Modify them unless you know exactly what will happen if modified.
        {
            -- Check collecter chest on nth tick
            type = 'int-setting',
            name = 'ab-logistics-center-check-cc-on-nth-tick',
            order = 'ab-lc-w-a',
            setting_type = 'startup',
            default_value = 50,
            allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50, 100, 200, 500, 1000}
        },
        {
            -- Check requester chest on nth tick
            type = 'int-setting',
            name = 'ab-logistics-center-check-rc-on-nth-tick',
            order = 'ab-lc-w-b',
            setting_type = 'startup',
            default_value = 30,
            allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50, 100, 200, 500, 1000}
        },
        {
            -- Check collecter chest percentages
            type = 'double-setting',
            name = 'ab-logistics-center-check-cc-percentages',
            order = 'ab-lc-w-c',
            setting_type = 'startup',
            default_value = 0.015,
            allowed_values = {0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.012, 0.015, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1}
        },
        {
            -- Check requester chest percentages
            type = 'double-setting',
            name = 'ab-logistics-center-check-rc-percentages',
            order = 'ab-lc-w-d',
            setting_type = 'startup',
            default_value = 0.015,
            allowed_values = {0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.012, 0.015, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1}
        }
    }
)
