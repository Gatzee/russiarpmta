local color_name_rgb = {
	[ "green" ] = { 65, 94, 66 },
	[ "black" ] = { 0, 0, 0 },
	[ "red" ] = { 255, 0, 0 },
}

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
			model 		= params.model;
			variant		= params.variant or 1;
			x			= 0;
			y			= 0;
			z			= 0;
			rx			= 0;
			ry			= 0;
			rz			= 0;
			owner_pid	= sOwnerPID;
			color		= color_name_rgb[ params.color ] or { 255, 255, 255 };
			temp_timeout = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) )
		}
		if params.tuning then
			for k, v in pairs( params.tuning ) do
				pRow[ k ] = v
			end
		end
	
		exports.nrp_vehicle:AddVehicle( pRow, true, "OnCasesVehicleAdded", { color = pRow.color, player = player, cost = VEHICLE_CONFIG[ params.model ].variants[ params.variant or 1 ].cost, temp_days = params.temp_days, temp_timeout = pRow.temp_timeout } )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, id, params.model .. ( params.color and "_" .. params.color or "" ), bg ):center( )
		
		if params.temp_days then
			ibCreateLabel( 0, 0, 0, 0, params.temp_days .." д.", bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
			img:center( 0, -15 )
		end
	end;
	
	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 600, 316, id, params.model .. ( params.color and "_" .. params.color or "" ), bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
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

	uiGetContentTextureRolling = function( id, params )
		return id, params.model .. ( params.color and "_" .. params.color or "" ), 300, 160
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}

function OnVehicleAdded_handler( vehicle, data )
	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" .. data.player:GetUserID()

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )

		if data.color then
			local r, g, b = unpack( data.color )
			vehicle:SetColor( r, g, b )
		else
			vehicle:SetColor( 255, 255, 255 )
		end

		vehicle:SetParked( true )

		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTime().timestamp )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		vehicle:SetPermanentData( "temp_timeout", data.temp_timeout )
		triggerEvent( "CheckTemporaryVehicle", vehicle )

		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent("OnCasesVehicleAdded", true)
addEventHandler("OnCasesVehicleAdded", resourceRoot, OnVehicleAdded_handler)