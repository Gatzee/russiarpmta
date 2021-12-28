loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")

VEHICLE_TIMERS = { }

function CheckTemporaryVehicle( vehicle )
	local vehicle = vehicle or source

	KillTemporaryTimer( vehicle )

	local timestamp = vehicle:GetPermanentData( "temp_timeout" )
	timestamp = timestamp and timestamp > 0 and timestamp

	-- Если нет срока истечения, то похуй
	if not timestamp then return end

	local difference = ( timestamp - getRealTimestamp( ) ) * 1000

	-- Ебучий таймер начинается с 50мс
	if difference >= 50 then
		VEHICLE_TIMERS[ vehicle ] = setTimer( RemoveTemporaryVehicle, difference, 1, vehicle )
		addEventHandler( "onElementDestroy", vehicle, onElementDestroy_handler )

	-- Удаляем сразу
	else
		RemoveTemporaryVehicle( vehicle )
	end
end
addEvent( "CheckTemporaryVehicle", true )
addEventHandler( "CheckTemporaryVehicle", root, CheckTemporaryVehicle )

function KillTemporaryTimer( vehicle )
	if isTimer( VEHICLE_TIMERS[ vehicle ] ) then killTimer( VEHICLE_TIMERS[ vehicle ] ) end
	VEHICLE_TIMERS[ vehicle ] = nil
	removeEventHandler( "onElementDestroy", vehicle, onElementDestroy_handler )
end

function RemoveTemporaryVehicle( vehicle )
	if not isElement( vehicle ) then return end
	
	local id = vehicle:GetID( )
	local pid = vehicle:GetOwnerID()
	local player = GetPlayer( pid )
	local is_discount = vehicle:GetPermanentData( "activate_discount" )

	if is_discount and player then
		triggerEvent( "OnVehicleTemporaryDiscountActivated", root, player, vehicle.model, is_discount )
	end

	WriteLog( "vehicle_temp", "%s была удалена (владелец %s)", vehicle, player or pid )

	exports.nrp_vehicle:DestroyForever( id, "Как временный автомобиль" )

	if player then
		triggerEvent( "CheckPlayerVehiclesSlots", player )
	end
end

addEvent( "onResourceStart", true )
addEventHandler( "onResourceStart", resourceRoot, function()
	for i, v in pairs( getElementsByType( "vehicle" ) ) do
		CheckTemporaryVehicle( v )
	end
end )

function OnVehiclePostLoad_handler( )
	CheckTemporaryVehicle( source )
end
addEvent( "onVehiclePostLoad" )
addEventHandler( "onVehiclePostLoad", root, OnVehiclePostLoad_handler )

function onElementDestroy_handler( )
	KillTemporaryTimer( source )
end

addEventHandler( "onVehicleEnter", root, function( player, seat )
	local temp_timeout = source:GetPermanentData( "temp_timeout" )
	if not temp_timeout then return end

	if seat ~= 0 or source:GetOwnerID( ) ~= player:GetUserID( ) then return end

	local timestamp = getRealTimestamp( )
	if temp_timeout >= timestamp then
		local time_left = temp_timeout - timestamp

		local hours = string.format( "%02d", math.floor( time_left / 60 / 60 ) )
		local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 * 60 ) / 60 ) )

		player:ShowInfo( "Траспорт будет изьят через ".. hours .." ч. и ".. minutes .." м." )
	end
end )