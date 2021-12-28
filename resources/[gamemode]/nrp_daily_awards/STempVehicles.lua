SALE_VEHICLES = 
{
	[ 526 ] = true,
}

function OnVehicleTemporaryDiscountActivated( player, iModel, discount_params )
	if isElement( player ) and discount_params then
		if player:GetPermanentData( "temp_vehicle_discount" ) then
			player:SetPrivateData( "temp_vehicle_discount", false )
		end

		local data = {
			model = iModel,
			variant = discount_params.variant,
			timestamp = getRealTimestamp( ) + discount_params.time,
			percent = discount_params.percent,
		}

		player:SetPermanentData( "temp_vehicle_discount", data )
		player:SetPrivateData( "temp_vehicle_discount", data )

		data.timestamp = nil
		data.time_left = discount_params.time

		triggerClientEvent( player, "ShowUI_VehicleSale", resourceRoot, true, data )
	end
end
addEvent( "OnVehicleTemporaryDiscountActivated" )
addEventHandler( "OnVehicleTemporaryDiscountActivated", root, OnVehicleTemporaryDiscountActivated )

function OnVehicleAdded_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		local sOwnerPID = "p:" .. data.player:GetUserID( )

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )
		vehicle:SetColor( 255, 255, 255 )
		vehicle:SetParked( true )
		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTimestamp( ) )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		vehicle:SetPermanentData( "temp_timeout", data.temp_timeout )
		vehicle:SetPermanentData( "activate_discount", data.discount_params or false )

		triggerEvent( "CheckTemporaryVehicle", vehicle )
		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent( "OnDailyAwardsVehicleAdded" )
addEventHandler( "OnDailyAwardsVehicleAdded", resourceRoot, OnVehicleAdded_handler )