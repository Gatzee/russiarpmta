Import( "ShVehicleConfig" )

REGISTERED_ITEMS.vehicle = {
	Give = function( player, params )
		local vehicles = player:GetVehicles()
		if params.temp_days then
			for _, vehicle in pairs( vehicles ) do
				if params.id == vehicle.model then
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
				if params.id == vehicle.model and temp_timeout and temp_timeout > 0 then
					exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
				end
			end
		end

		local sOwnerPID = "p:" .. player:GetUserID()

		local pRow	= {
			model 		  = params.id;
			variant		  = params.variant or 1;
			owner_pid	  = sOwnerPID;
			first_owner   = sOwnerPID,
			temp_timeout  = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) ),
			parked        = "yes",
			showroom_cost = VEHICLE_CONFIG[ params.id ].variants[ params.variant or 1 ].cost,
			showroom_date = getRealTime().timestamp,
		}
		if params.tuning then
			for k, v in pairs( params.tuning ) do
				pRow[ k ] = v
			end
		end
	
		exports.nrp_vehicle:AddVehicle( pRow, true, "8M:OnVehicleAdded", { player = player } )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, id, params.id .. ( params.color and "_" .. params.color or "" ), bg ):center( )
		
		if params.temp_days then
			ibCreateLabel( 0, 0, 0, 0, params.temp_days .." д.", bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
			img:center( 0, -15 )
		end
		
		return img
	end;
	
	uiCreateBigItem = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 300, 160, id, params.id .. ( params.color and "_" .. params.color or "" ), bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		local config = VEHICLE_CONFIG[ params.id ]
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

function OnVehicleAdded_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent( "8M:OnVehicleAdded", true )
addEventHandler( "8M:OnVehicleAdded", resourceRoot, OnVehicleAdded_handler )