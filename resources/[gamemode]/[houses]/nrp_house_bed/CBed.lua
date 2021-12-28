loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend("ShApartments")
Extend("ShVipHouses")
Extend( "CPlayer" )

local SLEEPING_PLAYERS = {}
local HEALING_TIMER
local IS_IN_BED = false

local trigger_tick = 0

local CHECK_COL = createColSphere( 0, 0, 0, 1 )
addEventHandler( "onClientColShapeLeave", CHECK_COL, function( element )
	if IS_IN_BED and element == localPlayer then
		StopPlayerSleepOnBed( )
	end
end)

local can_apply_anim = false

local is_ifp_loaded = engineLoadIFP( "files/sleep.ifp", "SLEEP" )

addEvent( "onPlayerVerifyReadyToSpawn", true )
addEventHandler( "onPlayerVerifyReadyToSpawn", root, function( )
	if not is_ifp_loaded then
		engineLoadIFP( "files/sleep.ifp", "SLEEP" )
	end
	setTimer( function( )
		can_apply_anim = true
	end, 2000, 1 )
end )

function Player.SetSleepAnimation( self, anim_name, ... )
	if can_apply_anim then
		self:setAnimation( "SLEEP", anim_name, ... )
	elseif anim_name ~= "Sleep" then
		setTimer( function( ... )
			if SLEEPING_PLAYERS[self] then
				self:setAnimation( "SLEEP", anim_name, ... )
			end
		end, 1000, 3, ... )
	end
end

function SetPlayerSleepAnimation( )
	source:SetSleepAnimation( "Sleep3", -1, false, false, false, true, 0 )
end

function StopPlayerSleepOnBed( )
	SetPlayerSleepOnBed( false )
end

function OnClientPlayerSleepOnBed_handler( player, state, force_anim )
	if not isElement( player ) then return end
	if state then
		SLEEPING_PLAYERS[player] = true
		if player:isStreamedIn( ) then
			if force_anim then
				player:SetSleepAnimation( "Sleep3", -1, false, false, false, true, 0 )
			else
				player:SetSleepAnimation( "Sleep3", -1, false, false, false, true )
			end
		else
			addEventHandler( "onClientElementStreamIn", player, SetPlayerSleepAnimation )
		end
		
		if player == localPlayer then
			IS_IN_BED = true
			if not isTimer( HEALING_TIMER ) then
				HEALING_TIMER = setTimer( HandleSleepHealing, SLEEP_ADD_1HP_TIMER_INTERVAL, 0 )
			end

			local position = localPlayer.position - Vector3( 0, 0, 0.5 )
			setCameraMatrix( position + localPlayer.matrix.forward * 3 + Vector3( 0, 0, 1.5 ), position )
			
			if trigger_tick == 0 then
				CHECK_COL.position = localPlayer.position
			end
			bindKey( "lalt", "up", StopPlayerSleepOnBed )
			
			localPlayer:InfoWindow( "Твой персонаж полностью восстановится в течение 4 ч. \nСон также работает в режиме офлайн. \nДля того, чтобы встать с кровати нажми ALT" )
		
			setElementData( localPlayer, "radial_disabled", true, false )
		end
	else
		SLEEPING_PLAYERS[player] = nil
		player:setAnimation(false)
		-- эта строка перестала работать)0
		-- player:SetSleepAnimation( "Sleep", 0, false, false, false, false )
		removeEventHandler( "onClientElementStreamIn", player, SetPlayerSleepAnimation )

		if player == localPlayer then
			IS_IN_BED = false
			if isTimer( HEALING_TIMER ) then killTimer( HEALING_TIMER ) end

			setTimer( setCameraTarget, 200, 1, localPlayer )

			unbindKey( "lalt", "up", StopPlayerSleepOnBed )

			setElementData( localPlayer, "radial_disabled", false, false )
		end
	end
end
addEvent( "OnClientPlayerSleepOnBed", true )
addEventHandler( "OnClientPlayerSleepOnBed", root, OnClientPlayerSleepOnBed_handler )

function StopPlayersSleepAnimation( )
	for player in pairs( SLEEPING_PLAYERS ) do
		OnClientPlayerSleepOnBed_handler( player, false )
	end
	SLEEPING_PLAYERS = {}
end
addEvent( "onClientPlayerHouseExit", true )
addEventHandler( "onClientPlayerHouseExit", root, StopPlayersSleepAnimation )

function onPlayersSleepingOnBed_handler( data )
	for player in pairs( data ) do
		OnClientPlayerSleepOnBed_handler( player, true, true )
	end
end
addEvent( "onPlayersSleepingOnBed", true )
addEventHandler( "onPlayersSleepingOnBed", root, onPlayersSleepingOnBed_handler )

function HandleSleepHealing( )
	if IS_IN_BED then
		if isPedOnFire( localPlayer ) then
			setPedOnFire( localPlayer, false )
        end

		if localPlayer.health < 100 then
			local hp = SLEEP_HP_PER_MS * SLEEP_ADD_1HP_TIMER_INTERVAL
            localPlayer:SetHP( localPlayer.health + hp )
            triggerServerEvent( "onPlayerSleepHealing", localPlayer )
		end
	else
		killTimer( HEALING_TIMER )
	end
end

function SetPlayerSleepOnBed( state, house_id, house_number, bed_id )
	if getTickCount( ) - trigger_tick < 1000 then return end
	trigger_tick = getTickCount( )

	if state then
		if IS_IN_BED then return end
		local class_id = house_id > 0 and APARTMENTS_LIST[ house_id ].class or VIP_HOUSES_LIST[ house_number ].apartments_class or 0
		local house_data = class_id > 0 and APARTMENTS_CLASSES[ class_id ] or VIP_HOUSES_LIST[ house_number ]
		
		CHECK_COL.position = Vector3( house_data.bed_position[ bed_id or 1 ] )
		
        triggerServerEvent( "PlayerWantSleepOnBed", resourceRoot, house_id, house_number, bed_id )
	elseif IS_IN_BED then
		triggerServerEvent( "PlayerWantLeaveBed", resourceRoot )
    end
	unbindKey( "lalt", "up", StopPlayerSleepOnBed )
end
addEvent( "SetPlayerSleepOnBed", true )
addEventHandler( "SetPlayerSleepOnBed", root, SetPlayerSleepOnBed )