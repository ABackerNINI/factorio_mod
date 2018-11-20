function get_config()
    return {
        global_data_version = 10,

        --TECHNOLOGIES
        --increment of lc_capacity of each research,default = {19000,30000,50000,100000}
        tech_lc_capacity_increment = {19000,30000,50000,100000},

        --decrement of cc/rc power_consumption of each research,default = {0.015,0.015,0.015,0.015}
        tech_power_consumption_decrement = {0.015,0.015,0.015,0.015},


        --DEFAULT CONFIGS
        --capacity of the logistics center of each item,default = 10000
        default_lc_capacity = 10000, --[10K] 

        --power consumption of collector chests per distance per item transferring,default = 1000
        default_cc_power_consumption = 1000,  --J

        --power consumption of requester chests per distance per item transferring,default = 100
        default_rc_power_consumption = 100,   --J


        --ENTITY PROPERTIES
        --logistic slots count of requester chests,default = 5
        rc_logistic_slots_count = 5,

        --item slot count of logistics center,default = 200
        lc_item_slot_count = 500,

        --basic power consumption of the electric energy interface,default = 2000000
        eei_basic_power_consumption = 2000000, --W [2MW]

        --input flow limit of the electric energy interface,default = 0
        eei_input_flow_limit = 0, --W [no limit]
        
        --buffer capacity of the electric energy interface,default = 1000000000
        eei_buffer_capacity  = 1000000000,  --J [1GJ]


        --RUNTIME CONFIGS
        --!!ATTENTION! the values "xx_on_nth_tick" below can NOT be the same with each other.

        --check all collecter chests every nth tick,default = 5
        check_cc_on_nth_tick = 5,

        --check all requester chests every nth tick,default = 3
        check_rc_on_nth_tick = 3,

        --check 20% collecter chests every 'check_cc_on_nth_tick',default = 0.015
        check_cc_percentage = 0.015,

        --check 20% requester chests every 'check_rc_on_nth_tick',default = 0.015
        check_rc_percentage = 0.015,

        --update all signals ever nth tick,default = 600
        -- update_all_signals_on_nth_tick = 600,


        --COMMON
        big_number = 1000000000,


        --LOCALES
        locale_flying_text_when_build_chest = "ab-logisticscenter-text.flying-text-when-building-chest",
        locale_print_after_tech_lc_capacity_researched = "ab-logisticscenter-text.print-after-tech-lc-capacity-researched",
        locale_print_after_tech_power_consumption_researched = "ab-logisticscenter-text.print-after-tech-power-consumption-researched",
        locale_print_when_global_data_migrate = "ab-logisticscenter-text.print-when-global-data-migrate",
        locale_print_when_secend_lcc_built = "ab-logisticscenter-text.print-when-secend-lcc-built",


        --FOR GLOBAL DATA MIGRATIONS
        --power consumption of collector chests per distance per item transferring,default = 1000
        cc_power_consumption = 1000,  --J

        --power consumption of requester chests per distance per item transferring,default = 100
        rc_power_consumption = 100,   --J
    }
end

function get_names()
    return {
        --item/entity
        collecter_chest_1_1 = "ab-lc-collecter-chest-1_1",
        collecter_chest_3_6 = "ab-lc-collecter-chest-3_6",
        collecter_chest_6_3 = "ab-lc-collecter-chest-6_3",
        requester_chest_1_1 = "ab-lc-requester-chest-1_1",
        logistics_center = "ab-lc-logistics-center",
        logistics_center_controller = "ab-lc-logistics-center-controller",
        electric_energy_interface = "ab-lc-electric-energy-interface",
        -- logistics_center_d = "ab-lc-logistics-center-",
        -- logistics_center_animation = "ab-lc-logistics-center-animation",

        --technology
        tech_lc_capacity = "ab-lc-tech-lc-capacity",
        tech_power_consumption = "ab-lc-tech-power-consumption",

        --match pattern string
        collecter_chest_pattern = "ab%-lc%-collecter%-chest",
        requester_chest_pattern = "ab%-lc%-collecter%-chest",
        tech_lc_capacity_pattern = "ab%-lc%-tech%-lc%-capacity",
        tech_power_consumption_pattern = "ab%-lc%-tech%-power%-consumption"
    }
end