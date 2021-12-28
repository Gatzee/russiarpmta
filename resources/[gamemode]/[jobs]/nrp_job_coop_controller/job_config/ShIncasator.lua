
JOB_DATA[ JOB_CLASS_INKASSATOR ] =
{
    task_resource = "task_incasator_coop",
	onStartWork = "onServerIncasatorStartWork",
	onEndWork = "onServerIncasatorEndWork",

    markers_positions = 
    {
        {
    		city = 2,
    		name = "Работа инкассатором",
			-- x = -658.090, y = 2141.539, z = 21.65,
			x = -728.519, y = 2152.910 + 860, z = 20.1,
			blip_size = 1.8,
    	},
    },
    blip_id = 72,

	company_name = JOB_ID[ JOB_CLASS_INKASSATOR ],
    conf = 
    {
    	{
			level = 18,
    	},
    	{
    		level = 21,
    	},
    	{
    		level = 25,
		},
	},
	
	job_join_condition = function( lobby, player, is_start, show_player )
		if player:GetSocialRating() < 0 then
			return false, (show_player and "У тебя" or "У игрока") .. " низкий социальный рейтинг"
		end
		return true
	end,

    vehicle_data = {
    	[ 2 ] = {
			vehicle_model = 459,
			positions = {
				{ position = Vector3( { x = -720.831, y = 2169.254 + 860, z = 19.679 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 275.587 } ), },
				{ position = Vector3( { x = -720.010, y = 2165.475 + 860, z = 19.686 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 287.172 } ), },
				{ position = Vector3( { x = -718.554, y = 2162.104 + 860, z = 19.686 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 298.015 } ), },
				{ position = Vector3( { x = -716.536, y = 2159.175 + 860, z = 19.692 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 309.171 } ), },
				{ position = Vector3( { x = -713.972, y = 2156.781 + 860, z = 19.693 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 320.542 } ), },
				{ position = Vector3( { x = -711.049, y = 2154.832 + 860, z = 19.695 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 331.745 } ), },
				{ position = Vector3( { x = -707.743, y = 2153.539 + 860, z = 19.689 } ), rotation = Vector3( { x = 0.000, y = 0.000, z = 343.445 } ), },
			},
			idle_time = 15,
            apply_fn = function( vehicle )
				setVehiclePaintjob( vehicle, 0 )
				setVehicleColor( vehicle, 250, 240, 185 )
			end,
    	},
    }
}
