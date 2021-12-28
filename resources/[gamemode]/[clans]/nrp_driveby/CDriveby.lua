loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "Globals" )

local CURRENT_NUM = 1

local SLOTS = { 
    [ 2 ] = true, -- handgun
    --[ 3 ] = true, -- shotgun
    [ 4 ] = true, -- SMG
    [ 5 ] = true, -- rifle
    --[ 6 ] = true, -- sniper
}

local IGNORED_WEAPONS = {
    [ 0 ] = true, -- пустота
    [ 10 ] = true, -- медичная хуйня
    [ 23 ] = true, -- тайзер
}

local is_bounnd = false

function onClientPlayerVehicleEnter_handler( _, seat )
    setPedWeaponSlot( localPlayer, 0 )

    if localPlayer:getData( "is_handcuffed" ) then return end
    if localPlayer:getData( "realdriveby_disabled" ) then return end

    onClientVehicleStartExit_handler( localPlayer )

    if not localPlayer.vehicle then return end
    if localPlayer.vehicle.occupants[ 0 ] == localPlayer then
        local faction = localPlayer:GetFaction()
        if not FACTION_RIGHTS.DRIVEBY[ faction ] then
            return
        end
    end

    bindKey( "mouse2", "both", ToggleDriveby )
    is_bounnd = true
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, onClientPlayerVehicleEnter_handler )

function onClientVehicleStartExit_handler( player )
    if player ~= localPlayer then return end
    if not is_bounnd then return end

    unbindKey( "mouse2", "both", ToggleDriveby )
    is_bounnd = false
end
addEventHandler( "onClientVehicleExit", root, onClientVehicleStartExit_handler )
addEventHandler( "onClientVehicleStartExit", root, onClientVehicleStartExit_handler )

local VEHICLE_WINDOW_BY_SEAT = {
    [ 0 ] = 4,  [ 1 ] = 2,
    [ 2 ] = 5,  [ 3 ] = 3,
}

function ToggleDriveby( key, state )
    if localPlayer:getData( "tuning_active" ) then
        return
    end
    local faction = localPlayer:GetFaction()
    local in_gz_disable = getElementData( localPlayer, "_greenzone" ) and not FACTION_RIGHTS.DRIVEBY[ faction ]
    if not localPlayer:IsInGame() or localPlayer.dead or in_gz_disable or getElementData(localPlayer, "bFirstPerson") or getElementData( localPlayer, "jailed" ) then
        if is_bounnd then 
            unbindKey( "mouse2", "both", ToggleDriveby ) 
            is_bounnd = false 
        end
        state = "up"
    end

    unbindKey( "mouse_wheel_up", "down", ScrollWeapons )
    unbindKey( "mouse_wheel_down", "down", ScrollWeapons )

    local vehicle = localPlayer.vehicle
    if not localPlayer.vehicle then return end

    if state == "up" then
        setPedWeaponSlot( localPlayer, 0 )
        if isPedDoingGangDriveby( localPlayer ) then
            setPedDoingGangDriveby( localPlayer, false )
            setVehicleWindowOpen ( vehicle, VEHICLE_WINDOW_BY_SEAT[ localPlayer.vehicleSeat ], false )
            triggerEvent( "onClientPlayerDrivebyStateChange", localPlayer, false )
            setCameraTarget( localPlayer, localPlayer )
        end
    else
        if #getAvailableSlots( ) <= 0 then return end
        bindKey( "mouse_wheel_up", "down", ScrollWeapons )
        bindKey( "mouse_wheel_down", "down", ScrollWeapons )
        ScrollWeapons()
        setPedDoingGangDriveby( localPlayer, true )
        triggerEvent( "onClientPlayerDrivebyStateChange", localPlayer, true )
    end
end

addEvent( "OnElementGreenZoneEnter", true )
addEventHandler("OnElementGreenZoneEnter", localPlayer, function ( )
    if localPlayer.vehicle then
        setPedWeaponSlot( localPlayer, 0 )
        onClientVehicleStartExit_handler( localPlayer )
    end
end )

addEvent( "OnElementGreenZoneExit", true )
addEventHandler("OnElementGreenZoneExit", localPlayer, function ( )
    if localPlayer.vehicle then
        onClientPlayerVehicleEnter_handler( )
    end
end )

function onClientPlayerWeaponFire_handler()
    if not localPlayer.vehicle or not isPedDoingGangDriveby( localPlayer ) then return end
    ScrollWeapons()
end
addEventHandler( "onClientPlayerWeaponFire", localPlayer, onClientPlayerWeaponFire_handler )

function ScrollWeapons( key, state )
    if key == "mouse_wheel_up" then
        CURRENT_NUM = CURRENT_NUM - 1
    elseif key == "mouse_wheel_down" then
        CURRENT_NUM = CURRENT_NUM + 1
    end

    local slots_list = getAvailableSlots( )

    if CURRENT_NUM > #slots_list then
        CURRENT_NUM = 1
    elseif CURRENT_NUM < 1 then
        CURRENT_NUM = #slots_list
    end

    if getPedWeaponSlot( localPlayer ) ~= slots_list[ CURRENT_NUM ] then
        setPedWeaponSlot( localPlayer, slots_list[ CURRENT_NUM ] )
    end
end

function getAvailableSlots( )
	local weapons = {} 
	for i = 2, 9 do
		local weapon = getPedWeapon( localPlayer, i )
		if weapon and SLOTS[ i ] and not IGNORED_WEAPONS[ weapon ] then
			table.insert( weapons, i )
		end
	end
	return weapons
end

if localPlayer.vehicle then onClientPlayerVehicleEnter_handler() end