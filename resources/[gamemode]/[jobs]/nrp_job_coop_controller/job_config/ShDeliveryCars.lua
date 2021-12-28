
JOB_DATA[ JOB_CLASS_TRANSPORT_DELIVERY ] =
{
    task_resource = "task_delivery_cars_coop",
	onStartWork = "onServerDeliveryCarsStartWork",
	onEndWork = "onServerDeliveryCarsEndWork",

    markers_positions = 
    {
        {
    		city = 2,
    		name = "Работа \"Доставка транспорта\"",
			x = 312.27, y = 985.74 + 860, z = 21.8,
			blip_size = 1.8,
    	},
    },
    blip_id = 77,

	company_name = JOB_ID[ JOB_CLASS_TRANSPORT_DELIVERY ],
    conf = 
    {
    	{
			level = 16,
    	},
    	{
    		level = 20,
    	},
    	{
    		level = 24,
		},
	},
	
	job_join_condition = function( lobby, player, is_start, show_player )
		return true
	end,
}
