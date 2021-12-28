REGISTERED_ITEMS.vehicle = {
	rewardPlayer_func = function( player, params )
		local vehicles = player:GetVehicles()
		if params.temp_days then
			for _, vehicle in pairs( vehicles ) do
				if params.model == vehicle.model then
					local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
					if temp_timeout and temp_timeout >= getRealTime().timestamp then
						vehicle:SetPermanentData( "temp_timeout", temp_timeout + params.temp_days * 24 * 60 * 60 )
						triggerEvent( "CheckTemporaryVehicle", vehicle )
						return
					end
				end
			end
		else
			for _, vehicle in pairs( vehicles ) do
				local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
				if params.model == vehicle.model and temp_timeout and temp_timeout > 0 then
					exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
				end
			end
		end

		local sOwnerPID = "p:" .. player:GetUserID()

		local pRow	= {
			model 		  = params.model;
			variant		  = params.variant or 1;
			owner_pid	  = sOwnerPID;
			first_owner   = sOwnerPID,
			temp_timeout  = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) ),
			parked        = "yes",
			showroom_cost = VEHICLE_CONFIG[ params.model ].variants[ params.variant or 1 ].cost,
			showroom_date = getRealTime().timestamp,
		}
		if params.tuning then
			for k, v in pairs( params.tuning ) do
				pRow[ k ] = v
			end
		end
	
		exports.nrp_vehicle:AddVehicle( pRow, true, "OnLotteryVehicleAdded", { player = player } )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 13, 42, 90, 90, id, params.model .. ( params.color and "_" .. params.color or "" ), bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 13, 42, 300, 160, id, params.model .. ( params.color and "_" .. params.color or "" ), bg )
	end;

	uiCreatePlayersTopItem_func = function( id, params, bg )
		local config = VEHICLE_CONFIG[ params.model ]
		local name = config.model
		if config.variants[ 2 ] then
			name = name .. " " .. config.variants[ params.variant or 1 ].mod
		end
		local lbl = ibCreateLabel( 0, 0, 0, 0, name, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 ):center_y( )
		ibCreateImage( lbl:ibGetAfterX( 10 ), 0, 38, 26, "img/icon_best_reward.png", bg ):center_y( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		local config = VEHICLE_CONFIG[ params.model ]
		local name = config.model
		if config.variants[ 2 ] then
			name = name .. " " .. config.variants[ params.variant or 1 ].mod
		end
		return {
			title = name;
		}
	end;
}

function OnVehicleAdded_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent( "OnLotteryVehicleAdded", true )
addEventHandler( "OnLotteryVehicleAdded", resourceRoot, OnVehicleAdded_handler )