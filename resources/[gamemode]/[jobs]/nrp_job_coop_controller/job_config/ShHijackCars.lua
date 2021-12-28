
JOB_DATA[ JOB_CLASS_HIJACK_CARS ] =
{
    task_resource = "task_hijack_cars_coop",
	onStartWork = "onServerHijackCarsStartWork",
	onEndWork = "onServerHijackCarsEndWork",

    markers_positions = 
    {
    	{
    		city = 2,
    		name = JOB_NAMES[ JOB_CLASS_HIJACK_CARS ],
			x = -1069.94, y = 768.25 + 860, z = 20.39,
    	},
	},
	
	blip_id = 82,
	company_name = JOB_ID[ JOB_CLASS_HIJACK_CARS ],

    conf = 
    {
    	{
			level = 12,
    	},
    	{
    		level = 17,
    	},
    	{
    		level = 23,
		},
    },

    job_join_condition = function( lobby, player, is_start, is_show_player )
		if player:GetSocialRating() >= 0 then
			return false, (is_show_player and "У тебя" or "У игрока") .. " должен быть отрицательный социальный рейтинг"
		end
		return true
	end,

    vehicle_data = 
    {
    	[ 2 ] = 
    	{
			vehicle_model = 6574,
			positions = 
			{
                { position = Vector3( -1039.33, 764.59 + 860, 21.01 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1041.39, 755.01 + 860, 21.02 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1044.48, 740.08 + 860, 21.02 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1036.63, 739.40 + 860, 21.07 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1035.03, 750.13 + 860, 21.08 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1032.73, 756.05 + 860, 21.05 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1031.14, 761.67 + 860, 21.05 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1029.61, 768.03 + 860, 21.05 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1038.20, 770.38 + 860, 21.05 ), rotation = Vector3( 0, 0, 0 ) },
                { position = Vector3( -1021.50, 765.82 + 860, 21.08 ), rotation = Vector3( 0, 0, 0 ) },
			},
            apply_fn = function( vehicle )
				setVehicleColor( vehicle, 0, 0, 0 )
                vehicle:SetWindowsColor( 0, 0, 0, 255 )
			end,
    	},
    }
}
