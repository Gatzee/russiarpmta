
JOB_DATA[ JOB_CLASS_TOWTRUCKER ] =
{
    task_resource = "task_tow_company",
	onStartWork = "onServerTowStartWork",
	onEndWork = "onServerTowEndWork",

    markers_positions = 
    {
		-- НСК
    	{
    		city = 0,
    		name = "Работа эвакуаторщика",
    		x = -1011.190, y = 99.1750, z = 22.93327331543,
    	},
	},
	
	blip_id = 65,

	company_name = "tow",
    conf = 
    {
    	{
			level = 13,
    	},
    	{
    		level = 15,
    	},
    	{
    		level = 17,
		},
    },

    vehicle_data = 
    {
		-- НСК
    	[ 0 ] = 
    	{
			vehicle_model = 408,
			positions = 
			{
    			{ position = Vector3( -998.7304077148438, -719.4714965820312 + 860, 23.62596130371094 ), rotation = Vector3( 359.7593383789063, 0.05548095703125, 99.12054443 ) },
    			{ position = Vector3( -997.4561767578125, -715.1693878173828 + 860, 23.62426948547363 ), rotation = Vector3( 359.7484130859375, 0.03173828125231, 99.32122802 ) },
    			{ position = Vector3( -996.1811523437523, -711.0138549804687 + 860, 23.62340354919434 ), rotation = Vector3( 359.7133789062521, 0.07397460937531, 99.91796875 ) },
				{ position = Vector3( -994.6506347656252, -706.5584564208984 + 860, 23.62573623657227 ), rotation = Vector3( 359.7337646484375, 359.793701171875, 101.6773681 ) },

				{ position = Vector3( -985.896, -671.5 + 860, 23.623 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -985.044, -666.613 + 860, 23.620 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -984.169, -662.117 + 860, 23.618 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3(  -983.267, -657.728 + 860, 23.615 ), rotation = Vector3( 0, 0, 105 ) },

				{ position = Vector3( -982.354, -653.212 + 860, 23.614  ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -981.304, -648.666 + 860, 23.616 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -980.664, -644.172 + 860, 23.613 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -979.675, -639.614 + 860, 23.616 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -978.952, -635.146, 23.618 ), rotation = Vector3( 0, 0, 105 ) },
				{ position = Vector3( -977.690, -630.657 + 860, 23.616 ), rotation = Vector3( 0, 0, 105 ) },
			},
    	},
    }
}
