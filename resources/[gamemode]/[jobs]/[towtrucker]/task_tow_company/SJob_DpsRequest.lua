
REAL_VEHICLES = {}
DPS_EVAC_TIMEOUT = {}


DPS_CONST_TIMEOUT_EVACUATE = 10 * 60

setTimer( function()
	local timestamp = getRealTimestamp()
	for k, v in pairs( DPS_EVAC_TIMEOUT ) do
		if not isElement( k ) or v < timestamp then
			DPS_EVAC_TIMEOUT[ k ] = nil
		end
	end
end, DPS_CONST_TIMEOUT_EVACUATE * 1000, 0 )

local RESTRICTED_VEHICLES =
{
	[ 573 ] = true,
}

function onServerDpsQueryEvacuateVehicle_handler( player, vehicle )
	if not isElement( player ) or not isElement( vehicle ) then return end

	local faction_id = player:GetFaction( )

	if not FACTION_RIGHTS.EVACUATION[ faction_id ] then
		return false
	end

	if RESTRICTED_VEHICLES[ vehicle.model ] then
		vehicle:SetParked( true )
		return false
	end

	if IsVehicleReal( vehicle ) or vehicle:getData( "tow_evac_added" ) then
		player:ShowInfo( "Авто уже отмечено на эвакуацию" )
		return false
	end

	local timestamp = getRealTimestamp()
	if DPS_EVAC_TIMEOUT[ vehicle ] and DPS_EVAC_TIMEOUT[ vehicle ] > timestamp then
		player:ShowInfo( "Исчерпан лимит эвакуаций на текущий момент" )
		return false
	else
		DPS_EVAC_TIMEOUT[ vehicle ] = timestamp + DPS_CONST_TIMEOUT_EVACUATE
	end
	
	local vehicle_id = vehicle:GetID()
	if not vehicle_id then return end

	local vehicle_owner = GetPlayer( vehicle:GetOwnerID( ) )
	if vehicle_owner and isElement( vehicle_owner ) then
		local faction_n = FACTIONS_SHORT_NAMES[ faction_id ]
		local player_faction_level = player:GetFactionLevel( )
		local lvl_n = ( FACTIONS_LEVEL_NAMES[ faction_id ] or { } )[ player_faction_level ] or "-"

		local pNotification = {
			title = "Уведомления ДПС",
			msg = "Ваша машина поставлена на эвакуацию\nсотрудником ДПС: " .. player:GetNickName( ) .. "\nПодразделение: " .. faction_n .. "\nЗвание: " .. lvl_n .. "\n",
		}

		vehicle_owner:PhoneNotification( pNotification )
	end

	AddRealVehicle( vehicle )
	player:ShowInfo( "Вы отметили авто для эвакуации" )

	-- Аналитика
	OnDpsVehicleMark( player, vehicle )
end
addEvent( "onServerDpsQueryEvacuateVehicle" )
addEventHandler( "onServerDpsQueryEvacuateVehicle", root, onServerDpsQueryEvacuateVehicle_handler )

function AddRealVehicle( vehicle )
	RemoveRealVehicle( vehicle, "re_add" )
	vehicle:setData( "tow_evacuated_real", true, false )

	REAL_VEHICLES[ vehicle ] = createColSphere( vehicle.position, 15 )
	addEventHandler( "onElementDestroy", vehicle, onRealVehiclePreDestroy )
	addEventHandler( "onColShapeLeave", REAL_VEHICLES[ vehicle ], OnRealVehicleShapezoneLeave )
end

function RemoveRealVehicle( vehicle, reason )
	if REAL_VEHICLES[ vehicle ] then
		removeEventHandler( "onElementDestroy", vehicle, onRealVehiclePreDestroy )
		
		destroyElement( REAL_VEHICLES[ vehicle ] )
		REAL_VEHICLES[ vehicle ] = nil

		vehicle:setData( "tow_evacuated_real", nil, false )
	end
end

function OnRealVehicleShapezoneLeave( element )
	if getElementType( element ) ~= "vehicle" or not element:getData( "tow_evacuated_real" ) then return end
	RemoveRealVehicle( element )
end

function onRealVehiclePreDestroy()
	RemoveRealVehicle( source )
end

function IsVehicleReal( vehicle )
	return vehicle:getData( "tow_evacuated_real" )
end

function onResourceStart_handler()
	for k, v in pairs( getElementsByType("vehicle") ) do
		v:setData( "tow_evac_added", nil, false )
		v:setData( "tow_evacuated_real", nil, false )
	end
end
addEventHandler( 'onResourceStart', resourceRoot, onResourceStart_handler, true, 'high+1000' )