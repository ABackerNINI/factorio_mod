data:extend({
	{
		type = "string-setting",
		name = "ab-mapsettings-peaceful-mode",
		setting_type = "runtime-global",
        default_value = "none",
        allowed_values =  {"none","true","false"},
        order = "a-a"
	},

	-- Black = {r=0,g=0,b=0,a=0},
    -- Green = {r=0,g=255,b=0,a=0}
    -- Cyan = {r=0,g=255,b=255,a=0},
    -- Pink = {r=255,g=192,b=203,a=0},
    -- DeepPink = {r=255,g=20,b=147,a=0},
    -- Purple = {r=128,g=0,b=128,a=0},
    -- Blue = {r=0,g=0,b=255,a=0},
    -- DeepSkyBlue = {r=0,g=191,b=255,a=0},
    -- MediumSpringGreen = {r=0,g=255,b=127,a=0},
    -- Lime = {r=0,g=255,b=0,a=0},
    -- Yellow = {r=255,g=255,b=0,a=0},
    -- Gold = {r=255,g=215,b=0,a=0},
    -- Orange = {r=255,g=165,b=0,a=0},
    -- OrangeRed = {r=255,g=69,b=0,a=0},
    -- Red = {r=255,g=0,b=0,a=0},
    -- White = {r=255,g=255,b=255,a=0},
    -- Olive = {r=128,g=128,b=0,a=0},
	{
		type = "string-setting",
		name = "ab-mapsettings-player-color-colors",
		setting_type = "runtime-per-user",
        default_value = "none",
		allowed_values =  {"none","Black","Green","Cyan","Pink","DeepPink","Purple","Blue","DeepSkyBlue","MediumSpringGreen","Lime","Yellow","Gold","Orange","OrangeRed","Red","Green","White","Olive"},
        order = "a-b"
	},

	--user-define-color
	{
		type = "bool-setting",
		name = "ab-mapsettings-player-color-using-user-defined-color",
		setting_type = "runtime-per-user",
        default_value = false,
        order = "a-c"
	},	
	{
		type = "int-setting",
		name = "ab-mapsettings-player-color-user-defined-color-r",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		maximum_value = 255,
		default_value = 0,
        order = "a-c-1"
	},
	{
		type = "int-setting",
		name = "ab-mapsettings-player-color-user-defined-color-g",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		maximum_value = 255,
		default_value = 0,
        order = "a-c-2"
	},
	{
		type = "int-setting",
		name = "ab-mapsettings-player-color-user-defined-color-b",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		maximum_value = 255,
		default_value = 0,
        order = "a-c-3"
	},
	{
		type = "int-setting",
		name = "ab-mapsettings-player-color-user-defined-color-a",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		maximum_value = 1,
		default_value = 0,
        order = "a-c-4"
	},
  })