function get_config()
    return {
        --!!attention! the values "check_xx_on_nth_tick" below can NOT be the same with each other.

        --check all collecter chests every nth tick,default = 120
        check_cc_on_nth_tick = 120,

        --check all requester chests every nth tick,default = 121
        check_rc_on_nth_tick = 121,

        --capacity of the logistics center per ore,default = 1000
        lc_capacity = 1000,

        --stability of collecter chests,default = 0.9
        cc_stability = 0.9,

        --stability of requester chests,default = 0.9
        rc_stability = 0.9,

        --power consumption of collector chests per distance per item transferring
        cc_power_consumption = 1000, --J

        --power consumption of requester chests per distance per item transferring
        rc_power_consumption = 10,   --J

        --logistic slots count of requester chests
        rc_logistic_slots_count = 2,

        --item slot count of logistics center
        lc_item_slot_count = 200,

        eei_basic_power_consumption = 1000000, --W[1MW]

        eei_input_flow_limit = 10000000, --W [10MW]
        
        eei_buffer_capacity  = 20000000  --J [10MJ]
    }
end

function get_entity_names()
    return {
        ores_collecter_chest = "ab-ores-collecter-chest",
        ores_requester_chest = "ab-ores-requester-chest",
        ores_logistics_center = "ab-ores-logistic-center",
        electric_energy_interface = "ab-ores-lc-electric-energy-interface"
    }
end