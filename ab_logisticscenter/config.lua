function get_config()
    return {
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

        --check all collecter chests every nth tick,default = 50
        check_cc_on_nth_tick = 50,

        --check all requester chests every nth tick,default = 30
        check_rc_on_nth_tick = 20,

        --update all signals ever nth tick,default = 180
        update_all_signals_on_nth_tick = 180,

        --check 20% collecter chests every 'check_cc_on_nth_tick'
        check_cc_percentage = 0.20,

        --check 20% requester chests every 'check_rc_on_nth_tick'
        check_rc_percentage = 0.20,

        --logistic slots count of requester chests,default = 5
        rc_logistic_slots_count = 5,

        --item slot count of logistics center,default = 200
        lc_item_slot_count = 200,

        eei_basic_power_consumption = 2000000, --W [2MW]

        eei_input_flow_limit = 10000000, --W [10MW]
        
        eei_buffer_capacity  = 20000000  --J [20MJ]
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