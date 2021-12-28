Extend( "ShVehicleConfig" )

REGISTERED_ITEMS.vehicle = {
	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, id, params.model .. ( params.color and "_" .. params.color or "" ), bg ):center( )
		
		if params.temp_days then
			ibCreateLabel( 0, 0, 0, 0, params.temp_days .." д.", bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
			img:center( 0, -15 )
		end
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 600, 316, id, params.model .. ( params.color and "_" .. params.color or "" ), bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		local config = VEHICLE_CONFIG[ params.model ]
		local name = config.model
		if config.variants[ 2 ] then
			return {
				title = name .. " " .. config.variants[ params.variant or 1 ].mod;
			}
		else
			return {
				title = name;
			}
		end
	end;
}