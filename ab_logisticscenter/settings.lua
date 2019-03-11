data:extend({
    {
      type = "int-setting",
      name = "ab-logistics-center-quick-start",
      order = "ab-l-a",
      setting_type = "startup",
      default_value = 1,
      allowed_values =  {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    },
    {
      type = "string-setting",
      name = "ab-logistics-center-item-type-limitation",
      order = "ab-l-b",
      setting_type = "startup",
      default_value = "all",
      allowed_values =  {"all","ores only", "except ores"}
    }
})