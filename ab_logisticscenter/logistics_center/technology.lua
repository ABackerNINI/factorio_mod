local LC = require('logistics_center.logistics_center')
local LCC = require('logistics_center.logistics_center_controller')

TECH = {}

local math_ceil = math.ceil

local names = g_names
local config = g_config
local startup_settings = g_startup_settings

-- TECHNOLOGIES
local tech_lc_capacity_names = {}
for i = 1, 4 do
    tech_lc_capacity_names[i] = names.tech_lc_capacity .. '-' .. (i * 10 - 9)
end

local tech_lc_capacity_increment_sum = {} -- 0, 200000, 500000, 1000000
tech_lc_capacity_increment_sum[1] = 0
for i = 2, 4 do
    tech_lc_capacity_increment_sum[i] = tech_lc_capacity_increment_sum[i - 1] + config.tech_lc_capacity_increment[i - 1] * 10
end

local tech_power_consumption_names = {}
for i = 1, 4 do
    tech_power_consumption_names[i] = names.tech_power_consumption .. '-' .. (i * 10 - 9)
end

local tech_power_consumption_decrement_sum = {} -- {0, 0.15, 0.30, 0.45, 0.6}
tech_power_consumption_decrement_sum[1] = 0
for i = 2, 5 do
    tech_power_consumption_decrement_sum[i] = tech_power_consumption_decrement_sum[i - 1] + config.tech_power_consumption_decrement[i - 1] * 10
end

function TECH:research_lc_capacity(research)
    for i = 1, 4 do
        if research.name == tech_lc_capacity_names[i] then
            global.technologies.tech_lc_capacity_real_level = global.technologies.tech_lc_capacity_real_level + 1

            -- fixed wrong lc capacity after calling research_all_technologies() through Lua script or in sandbox mode
            if global.technologies.tech_lc_capacity_real_level < (i - 1) * 10 then
                global.technologies.lc_capacity =
                    config.default_lc_capacity + tech_lc_capacity_increment_sum[i] +
                    config.tech_lc_capacity_increment[i] * (global.technologies.tech_lc_capacity_real_level - (i - 1)) * 10
            else
                global.technologies.lc_capacity =
                    config.default_lc_capacity + tech_lc_capacity_increment_sum[i] +
                    config.tech_lc_capacity_increment[i] * (global.technologies.tech_lc_capacity_real_level - (i - 1) * 10)
            end

            -- update max_control
            for k, v in pairs(global.items_stock.items) do
                v.max_control = global.technologies.lc_capacity
            end
            LCC:update()

            game.print(
                {
                    'ab-logisticscenter-text.print-after-tech-lc-capacity-researched',
                    global.technologies.lc_capacity
                }
            )

            break
        end
    end
end

function TECH:research_chest_power_consumption(research)
    for i = 1, 4 do
        if research.name == tech_power_consumption_names[i] then
            global.technologies.tech_power_consumption_real_level = global.technologies.tech_power_consumption_real_level + 1

            -- game.print(i .. ', ' .. global.technologies.tech_power_consumption_real_level .. ', ' .. research.level)

            local blevel = (research.level / 10) + 1
            local remain = research.level - (blevel - 1) * 10
            local decrement = tech_power_consumption_decrement_sum[blevel]
            if remain > 0 then
                decrement = decrement + config.tech_power_consumption_decrement[blevel] * remain
            end
            local power_consumption_percentage = 1 - decrement

            global.technologies.power_consumption_percentage = power_consumption_percentage

            global.technologies.cc_power_consumption = math_ceil(startup_settings.default_cc_power_consumption * power_consumption_percentage)

            global.technologies.rc_power_consumption = math_ceil(startup_settings.default_rc_power_consumption * power_consumption_percentage)

            game.print(
                {
                    config.locale_print_after_tech_power_consumption_researched,
                    global.technologies.cc_power_consumption,
                    global.technologies.rc_power_consumption
                }
            )

            break
        end
    end

    -- recalc distance
    LC:recalc_distance()
end

return TECH
