function get_config()
    return {
        global_data_version = 7,

        --TECHNOLOGIES
        --increment of lc_capacity of each research
        tech_lc_capacity_increment = {19000,30000,50000,100000},

        --decrement of cc/rc power_consumption of each research
        tech_power_consumption_decrement = {0.015,0.015,0.015,0.015},


        --DEFAULT CONFIGS
        --capacity of the logistics center of each item,default = 1000000
        default_lc_capacity = 10000, --[10K] 

        --power consumption of collector chests per distance per item transferring,default = 1000
        default_cc_power_consumption = 1000,  --J

        --power consumption of requester chests per distance per item transferring,default = 100
        default_rc_power_consumption = 100,   --J


        --ENTITY PROPERTIES
        --logistic slots count of requester chests,default = 5
        rc_logistic_slots_count = 5,

        --item slot count of logistics center,default = 200
        lc_item_slot_count = 200,

        eei_basic_power_consumption = 2000000, --W [2MW]

        eei_input_flow_limit = 20000000, --W [20MW]
        
        eei_buffer_capacity  = 100000000,  --J [100MJ]


        --RUNTIME CONFIGS
        --!!ATTENTION! the values "xx_on_nth_tick" below can NOT be the same with each other.

        --check all collecter chests every nth tick,default = 5
        check_cc_on_nth_tick = 5,

        --check all requester chests every nth tick,default = 3
        check_rc_on_nth_tick = 3,

        --check 20% collecter chests every 'check_cc_on_nth_tick'
        check_cc_percentage = 0.015,

        --check 20% requester chests every 'check_rc_on_nth_tick'
        check_rc_percentage = 0.015,

        --update all signals ever nth tick,default = 600
        -- update_all_signals_on_nth_tick = 600,


        --LOCALES
        locale_flying_text_when_build_chest = "ab-logisticscenter-text.flying-text-when-building-chest",
        locale_print_after_tech_lc_capacity_researched = "ab-logisticscenter-text.print-after-tech-lc-capacity-researched",
        locale_print_after_tech_power_consumption_researched = "ab-logisticscenter-text.print-after-tech-power-consumption-researched",


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
        collecter_chest = "ab-collecter-chest",
        requester_chest = "ab-requester-chest",
        logistics_center = "ab-logistic-center",
        electric_energy_interface = "ab-lc-electric-energy-interface",

        --technology
        tech_lc_capacity = "ab-lc-tech-lc-capacity",
        tech_power_consumption = "ab-lc-tech-power-consumption",

        --match pattern string
        tech_lc_capacity_pattern = "ab%-lc%-tech%-lc%-capacity",
        tech_power_consumption_pattern = "ab%-lc%-tech%-power%-consumption"
    }
end