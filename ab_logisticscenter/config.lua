local function get_config()
    return {
        global_data_version = 18,
        -------------------------------------------------------------------------------------------
        -- TECHNOLOGIES
        -- increment of lc_capacity of each research, default = {19000, 30000, 50000, 100000}
        tech_lc_capacity_increment = {19000, 30000, 50000, 100000},
        -- decrement of cc/rc power_consumption percentages of each research, default = {0.015, 0.015, 0.015, 0.015}
        tech_power_consumption_decrement = {0.015, 0.015, 0.015, 0.015},
        -------------------------------------------------------------------------------------------
        -- DEFAULT CONFIGS
        -- capacity of the logistics center of each item, default = 10000
        default_lc_capacity = 10000, -- [10K]
        -------------------------------------------------------------------------------------------
        -- ENTITY PROPERTIES
        -- basic power consumption of the electric energy interface, default = 2000000
        -- eei_basic_power_consumption = 2000000, --- W [2MW]
        -- input flow limit of the electric energy interface, default = 10000000000
        eei_input_flow_limit = 50000000, -- W [0.05GW 50MW]
        -- buffer capacity of the electric energy interface, default = 1000000000
        eei_buffer_capacity = 1000000000, -- J [1GJ]
        -------------------------------------------------------------------------------------------
        check_energy_bar_on_nth_tick = 20,
        check_lc_animation_on_nth_tick = 120
    }
end

local function get_names()
    return {
        -- ITEM/ENTITY NAMES
        collecter_chest_1_1 = 'ab-lc-collecter-chest-1_1',
        -- collecter_chest_3_6 = "ab-lc-collecter-chest-3_6",
        -- collecter_chest_6_3 = "ab-lc-collecter-chest-6_3",
        requester_chest_1_1 = 'ab-lc-requester-chest-1_1',
        logistics_center = 'ab-lc-logistics-center',
        logistics_center_controller = 'ab-lc-logistics-center-controller',
        electric_energy_interface = 'ab-lc-electric-energy-interface',
        -- logistics_center_d = "ab-lc-logistics-center-",
        logistics_center_animation = 'ab-lc-logistics-center-animation',
        energy_bar = 'ab-lc-energy-bar',
        -------------------------------------------------------------------------------------------
        -- TECHNOLOGY NAMES
        tech_lc_capacity = 'ab-lc-tech-lc-capacity',
        tech_power_consumption = 'ab-lc-tech-power-consumption',
        distance_flying_text = 'distance-flying-text',
        -------------------------------------------------------------------------------------------
        -- MATCH PATTERN STRINGS
        collecter_chest_pattern = 'ab%-lc%-collecter%-chest',
        requester_chest_pattern = 'ab%-lc%-collecter%-chest',
        tech_lc_capacity_pattern = 'ab%-lc%-tech%-lc%-capacity',
        tech_power_consumption_pattern = 'ab%-lc%-tech%-power%-consumption',
        -------------------------------------------------------------------------------------------
        -- LOCALES
        locale_flying_text_when_build_chest = 'ab-logisticscenter-text.flying-text-when-build-chest',
        locale_flying_text_when_build_chest_no_nearest_lc = 'ab-logisticscenter-text.flying-text-when-build-chest-no-nearest-lc',
        locale_flying_text_when_build_lc = 'ab-logisticscenter-text.flying-text-when-build-lc',
        locale_print_after_tech_lc_capacity_researched = 'ab-logisticscenter-text.print-after-tech-lc-capacity-researched',
        locale_print_after_tech_power_consumption_researched = 'ab-logisticscenter-text.print-after-tech-power-consumption-researched',
        locale_print_after_power_consumption_configuration_changed = 'ab-logisticscenter-text.print-after-power-consumption-configuration-changed',
        locale_print_when_global_data_migrate = 'ab-logisticscenter-text.print-when-global-data-migrate',
        locale_print_when_first_init = 'ab-logisticscenter-text.print-when-first-init',
        locale_print_when_error_detected = 'ab-logisticscenter-text.print-when-error-detected',
        -------------------------------------------------------------------------------------------
        -- RUNTIME MOD SETTINGS
        lc_animation = 'ab-logistics-center-lc-animation',
        re_scan_chests = 'ab-logistics-center-re-scan-chests'
    }
end

local function get_startup_settings()
    local startup_settings = {
        quick_start = settings.startup['ab-logistics-center-quick-start'].value,
        tech_cost = settings.startup['ab-logistics-center-tech-cost'].value,
        item_type_limitation = settings.startup['ab-logistics-center-item-type-limitation'].value,
        -- logistic slots count of requester chests, default = 5
        rc_logistic_slots_count = settings.startup['ab-logistics-center-rc-logistic-slots-count'].value,
        -- item slot count of logistics center, default = 500
        lc_item_slot_count = settings.startup['ab-logistics-center-lc-item-slot-count'].value,
        -------------------------------------------------------------------------------------------
        -- POWER CONSUMPTION SETTINGS
        -- power consumption of logistics center per second, default = 10000 [KW]
        lc_power_consumption = settings.startup['ab-logistics-center-lc-power-consumption'].value,
        -- logistics center input flow limit except standby consumption, default = 40 [MW]
        lc_input_flow_limit = settings.startup['ab-logistics-center-input-flow-limit'].value,
        -- logistics center buffer capacity, default = 1000 [MJ]
        lc_buffer_capacity = settings.startup['ab-logistics-center-buffer-capacity'].value,
        -- power consumption of collector chests per item per distance transferring, default = 1000 [J]
        default_cc_power_consumption = settings.startup['ab-logistics-center-default-cc-power-consumption'].value,
        -- power consumption of requester chests per item per distance transferring, default = 500 [J]
        default_rc_power_consumption = settings.startup['ab-logistics-center-default-rc-power-consumption'].value,
        -------------------------------------------------------------------------------------------
        --!!ATTENTION! the values "xx_on_nth_tick" below can NOT be the same with each other.
        -- check collecter chests every nth tick, default = 20
        check_cc_on_nth_tick = settings.startup['ab-logistics-center-check-cc-on-nth-tick'].value,
        -- check requester chests every nth tick, default = 10
        check_rc_on_nth_tick = settings.startup['ab-logistics-center-check-rc-on-nth-tick'].value,
        -- check 1.5%(on default) collecter chests every 'check_cc_on_nth_tick', default = 0.03
        check_cc_percentages = settings.startup['ab-logistics-center-check-cc-percentages'].value,
        -- check 1.5%(on default) requester chests every 'check_rc_on_nth_tick', default = 0.03
        check_rc_percentages = settings.startup['ab-logistics-center-check-rc-percentages'].value
    }

    if startup_settings.check_cc_on_nth_tick == startup_settings.check_rc_on_nth_tick then
        startup_settings.check_rc_on_nth_tick = startup_settings.check_rc_on_nth_tick + 1
    end

    return startup_settings
end

g_config = get_config()
g_names = get_names()
g_startup_settings = get_startup_settings()
LC_PATH = '__ab_logisticscenter__'
