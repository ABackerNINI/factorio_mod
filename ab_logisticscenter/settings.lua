data:extend({
    {
        type = "int-setting",
        name = "ab-logistics-center-quick-start",
        order = "ab-lc-a",
        setting_type = "startup",
        default_value = 1,
        allowed_values =  {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-tech-cost",
        order = "ab-lc-b",
        setting_type = "startup",
        default_value = 3,
        allowed_values =  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 50, 100}
    },
    {
        type = "string-setting",
        name = "ab-logistics-center-item-type-limitation",
        order = "ab-lc-c",
        setting_type = "startup",
        default_value = "all",
        allowed_values =  {"all","ores only", "except ores"}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-rc-logistic-slots-count",
        order = "ab-lc-d",
        setting_type = "startup",
        default_value = 5,
        allowed_values =  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-lc-item-slot-count",
        order = "ab-lc-e",
        setting_type = "startup",
        default_value = 500,
        allowed_values =  {20, 40, 60, 80, 100, 150, 200, 300, 400, 500, 600, 1000, 2000}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-default-cc-power-consumption",
        order = "ab-lc-f",
        setting_type = "startup",
        default_value = 1000,
        allowed_values =  {100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1500, 1800, 2000, 3000, 5000, 10000}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-default-rc-power-consumption",
        order = "ab-lc-g",
        setting_type = "startup",
        default_value = 100,
        allowed_values =  {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 150, 180, 200, 300, 500, 1000, 2000, 3000, 5000}
    },

    --Warning: these settings are important.Modify them unless you know exactly what will happen if modified.
    {
        type = "int-setting",
        name = "ab-logistics-center-check-cc-on-nth-tick",
        order = "ab-lc-w-a",
        setting_type = "startup",
        default_value = 5,
        allowed_values =  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50}
    },
    {
        type = "int-setting",
        name = "ab-logistics-center-check-rc-on-nth-tick",
        order = "ab-lc-w-b",
        setting_type = "startup",
        default_value = 3,
        allowed_values =  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50}
    },
    {
        type = "double-setting",
        name = "ab-logistics-center-check-cc-percentages",
        order = "ab-lc-w-c",
        setting_type = "startup",
        default_value = 0.015,
        allowed_values =  {0.005, 0.006, 0.007, 0.008, 0.009, 0.010, 0.012, 0.015, 0.020, 0.030, 0.040, 0.050, 0.060, 0.070, 0.080, 0.090, 0.100},
    },
    {
        type = "double-setting",
        name = "ab-logistics-center-check-rc-percentages",
        order = "ab-lc-w-d",
        setting_type = "startup",
        default_value = 0.015,
        allowed_values =  {0.005, 0.006, 0.007, 0.008, 0.009, 0.010, 0.012, 0.015, 0.020, 0.030, 0.040, 0.050, 0.060, 0.070, 0.080, 0.090, 0.100},
    },
})