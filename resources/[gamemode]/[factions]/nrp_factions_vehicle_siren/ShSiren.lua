loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShVehicle" )

VEHICLE_SIREN_CONFIG = 
{
	-- Приора ППС
	[540] = 
	{
		points = {
			{ x = -0.3, y = 0.1, z = 1, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = 0.1, z = 1, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",

		no_by_faction = {
			[ F_GOVERNMENT_GORKI ] = true;
			[ F_GOVERNMENT_NSK ] = true;
			[ F_GOVERNMENT_MSK ] = true,
			[ F_ARMY ] = true;
		},
	},

	-- 2114
	[426] = 
	{
		points = {
			{ x = -0.3, y = 0.1, z = 0.9, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = 0.1, z = 0.9, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",
	},

	-- Lancer
	[405] = 
	{
		points = {
			{ x = -0.3, y = -0.25, z = 1, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = -0.25, z = 1, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",
	},

	-- Accord
	[546] = 
	{
		points = {
			{ x = -0.3, y = 0, z = 0.9, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = 0, z = 0.9, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",

		no_by_faction = {
			[ F_ARMY ] = true;
		},
	},

	-- Panamera
	[580] = 
	{
		points = {
			{ x = -0.3, y = -0.25, z = 1, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = -0.25, z = 1, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",
	},

	-- Гелик
	[579] = 
	{
		points = {
			{ x = -0.3, y = 0, z = 1.2, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = 0, z = 1.2, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",

		no_by_faction = {
			[ F_ARMY ] = true;
		},

		by_faction = {
			[ F_GOVERNMENT_GORKI ] = {
				points = {
					{ x = -0.63, y = 0.2, z = 1.2, r = 0, g = 0, b = 255 },
				},
				sound = "siren2.wav",
			};
			[ F_GOVERNMENT_NSK ] = {
				points = {
					{ x = -0.63, y = 0.2, z = 1.2, r = 0, g = 0, b = 255 },
				},
				sound = "siren2.wav",
			};
			[ F_GOVERNMENT_MSK ] = {
				points = {
					{ x = -0.63, y = 0.2, z = 1.2, r = 0, g = 0, b = 255 },
				},
				sound = "siren2.wav",
			};
		};
	},

	-- Мерс 
	[507] = 
	{
		points = {
			{ x = -0.38, y = 0.2, z = 0.94, r = 0, g = 0, b = 255 },
		},
		sound = "siren2.wav",
	},

	-- Ланд Крузер 
	[445] = 
	{
		points = {
			{ x = -0.57, y = 0.3, z = 1, r = 0, g = 0, b = 255 },
		},
		sound = "siren2.wav",
	},

	-- УАЗ Полиции
	[400] = 
	{
		points = {
			{ x = -0.3, y = -0.25, z = 1.6, r = 255, g = 0, b = 0 },
			{ x = 0.3, y = -0.25, z = 1.6, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",

		no_by_faction = {
			[ F_ARMY ] = true;
		},
	},

	-- Toyota Camry
	[420] = 
	{
		points = {
			{ x = -0.3, y = 0, z = 1, r = 0, g = 0, b = 255 },
			{ x = 0.3, y = 0, z = 1, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",
	},

	-- Ford Transit
	[416] = 
	{
		points = {
			{ x = -0.4, y = 0.55, z = 1.7, r = 0, g = 0, b = 255 },
			{ x = 0.4, y = 0.55, z = 1.7, r = 0, g = 0, b = 255 },
		},
		sound = "siren1.wav",
	},

	-- Газель 3221
	[482] = 
	{
		points = {
			{ x = -0.4, y = 1.3, z = 1.5, r = 255, g = 0, b = 0 },
			{ x = 0.4, y = 1.3, z = 1.5, r = 255, g = 0, b = 0 },
		},
		sound = "siren1.wav",
	},
	
}
