function get_config()
    return {
        global_data_version = 4,

        --capacity of the logistics center of each item,default = 1000000
        lc_capacity = 1000000, --[1M] 

        --stability of collecter chests,default = 0.9
        -- cc_stability = 0.9,

        --stability of requester chests,default = 0.9
        -- rc_stability = 0.9,

        --power consumption of collector chests per distance per item transferring,default = 1000
        cc_power_consumption = 1000,  --J

        --power consumption of requester chests per distance per item transferring,default = 100
        rc_power_consumption = 100,   --J

        --!!ATTENTION! the values "xx_on_nth_tick" below can NOT be the same with each other.

        --check all collecter chests every nth tick,default = 5
        check_cc_on_nth_tick = 5,

        --check all requester chests every nth tick,default = 3
        check_rc_on_nth_tick = 3,

        --update all signals ever nth tick,default = 600
        update_all_signals_on_nth_tick = 600,

        --check 20% collecter chests every 'check_cc_on_nth_tick'
        check_cc_percentage = 0.015,

        --check 20% requester chests every 'check_rc_on_nth_tick'
        check_rc_percentage = 0.015,

        --logistic slots count of requester chests,default = 5
        rc_logistic_slots_count = 5,

        --item slot count of logistics center,default = 200
        lc_item_slot_count = 200,

        eei_basic_power_consumption = 2000000, --W [2MW]

        eei_input_flow_limit = 20000000, --W [20MW]
        
        eei_buffer_capacity  = 40000000  --J [40MJ]
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
        tech_power_consumption = "ab-lc-tech-power-consumption"
    }
end