local LC = require('logistics_center.logistics_center')
local LCC = require('logistics_center.logistics_center_controller')

TECH = {}

local math_ceil = math.ceil
local math_floor = math.floor

-- local names = g_names
local config = g_config
local names = g_names
local startup_settings = g_startup_settings

-- TECHNOLOGIES
-- local tech_lc_capacity_names = {}
-- for i = 1, 4 do
--     tech_lc_capacity_names[i] = names.tech_lc_capacity .. '-' .. (i * 10 - 9)
-- end

local tech_lc_capacity_increment_sum = {} -- {0, 190000, 490000, 990000, 1990000}
tech_lc_capacity_increment_sum[1] = 0
for i = 2, 5 do
    tech_lc_capacity_increment_sum[i] = tech_lc_capacity_increment_sum[i - 1] + config.tech_lc_capacity_increment[i - 1] * 10
end

-- local tech_power_consumption_names = {}
-- for i = 1, 4 do
--     tech_power_consumption_names[i] = names.tech_power_consumption .. '-' .. (i * 10 - 9)
-- end

local tech_power_consumption_decrement_sum = {} -- {0, 0.15, 0.30, 0.45, 0.6}
tech_power_consumption_decrement_sum[1] = 0
for i = 2, 5 do
    tech_power_consumption_decrement_sum[i] = tech_power_consumption_decrement_sum[i - 1] + config.tech_power_consumption_decrement[i - 1] * 10
end

function TECH:research_lc_capacity(research)
    local tech = global.technologies

    -- tech.tech_lc_capacity_real_level = tech.tech_lc_capacity_real_level + 1

    local level = math_floor(research.level / 10) + 1
    local remain = research.level - (level - 1) * 10
    local increment = tech_lc_capacity_increment_sum[level]
    if remain > 0 then
        increment = increment + config.tech_lc_capacity_increment[level] * remain
    end

    tech.lc_capacity = config.default_lc_capacity + increment

    -- the maximum logistics center capacity increment is 1990000 when researched all technologies
    if increment < 0 or increment > 1990000 * 10 then
        if increment < 0 then
            increment = 0
        else
            increment = 1990000 * 10
        end
        game.print({names.locale_print_when_error_detected, 'LC_CAPACITY_RESEARCH_LEVEL: ' .. research.level})
    end

    -- update max_control
    for k, v in pairs(global.items_stock.items) do
        v.max_control = tech.lc_capacity
    end

    LCC:update_signals()

    game.print(
        {
            'ab-logisticscenter-text.print-after-tech-lc-capacity-researched',
            tech.lc_capacity
        }
    )
end

function TECH:research_chest_power_consumption(research)
    local tech = global.technologies

    -- tech.tech_power_consumption_real_level = tech.tech_power_consumption_real_level + 1

    -- game.print(i .. ', ' .. tech.tech_power_consumption_real_level .. ', ' .. research.level)

    local level = math_floor(research.level / 10) + 1
    local remain = research.level - (level - 1) * 10
    local decrement = tech_power_consumption_decrement_sum[level]
    if remain > 0 then
        decrement = decrement + config.tech_power_consumption_decrement[level] * remain
    end
    local power_consumption_percentage = 1 - decrement

    -- the maximum power consumption decrement is 0.6 when researched all technologies
    -- the minimum power_consumption_percentage should be 0.4
    if power_consumption_percentage < 0.1 or power_consumption_percentage >= 1 then
        if power_consumption_percentage < 0.1 then
            power_consumption_percentage = 0.1
        else
            power_consumption_percentage = 1
        end
        game.print({names.locale_print_when_error_detected, 'CHEST_POWER_CONSUMPTION_RESEARCH_LEVEL: ' .. research.level})
    end

    tech.power_consumption_percentage = power_consumption_percentage

    tech.cc_power_consumption = math_ceil(startup_settings.default_cc_power_consumption * power_consumption_percentage)
    tech.rc_power_consumption = math_ceil(startup_settings.default_rc_power_consumption * power_consumption_percentage)

    game.print(
        {
            names.locale_print_after_tech_power_consumption_researched,
            tech.cc_power_consumption,
            tech.rc_power_consumption
        }
    )

    -- recalc distance
    LC:recalc_distance_when_power_consumption_changed()
end

return TECH
