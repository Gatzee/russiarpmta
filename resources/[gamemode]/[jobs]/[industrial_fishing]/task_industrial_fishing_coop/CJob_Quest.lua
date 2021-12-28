loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "CQuestCoop" )
Extend( "CActionTasksUtils" )

ibUseRealFonts( true )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuestCoop( QUEST_DATA )
end )

OFF_CONTROLS = { "fire", "action", "next_weapon", "previous_weapon", "vehicle_fire", "vehicle_secondary_fire", "aim_weapon" }
DISABLE_JOB_KEYS = { q = true, tab = true }
for k, v in pairs( getBoundKeys("change_camera") ) do
	DISABLE_JOB_KEYS[ k ] = true
end

function ChangeControlsState( state, keys )
    for k, key in pairs( keys ) do
        toggleControl( key, not state )
    end
end

function ChangeBindsState( keys, state, handler_func )
    local func = state and bindKey or unbindKey
    for k, v in pairs( keys ) do
        func( v, "both", handler_func )
    end
end

function DisableJobControls( state )
	for k, v in pairs( OFF_CONTROLS ) do
        toggleControl( v, not state )
    end	
end

function DisableJobKeys( state )
    removeEventHandler( "onClientKey", root, OnClientKey_handler )
    if state then
        addEventHandler( "onClientKey", root, OnClientKey_handler )
    end
end

function OnClientKey_handler( key, state )
	if DISABLE_JOB_KEYS[ key ] then
		cancelEvent()
		return
	end
end

function ShowInfoControls( state )
	if isElement( GEs.bg_info_controls ) then destroyElement( GEs.bg_info_controls ) end

	if state then
		local role_id = localPlayer:getData( "coop_job_role_id" )
		local role_string_id = QUEST_DATA.roles[ role_id ].id
		if not role_string_id then return end
		GEs.bg_info_controls = ibCreateImage( 0, _SCREEN_Y - 220, 0, 0, "img/info_controls_" .. role_string_id .. ".png" ):ibSetRealSize():center_x():ibData( "priority", -1 )
	end
end

function PressKeyHandler( conf )
	local self = conf or { }

	self.destroy = function( )
		unbindKey( self.key, "both", self.bind_handler )
		setmetatable( self, nil )
	end

	self.protect_destroy = function( )
		if self.key_handler then
			self:key_handler( )
		end

		if not self.no_auto_destroy then
			self.destroy( )
		end
	end

	self.bind_handler = function( key, state )
		if state == ( self.key_state or "up" ) then
			self.protect_destroy( )
		end
	end
	bindKey( self.key, "both", self.bind_handler )

	return self
end

function FadeCameraStep( )
    fadeCamera( false, 0 )
    GEs.fade_camera_tmr = setTimer( fadeCamera, 3500, 1, true, 1 )
end

local DEPTH_MUL = 2

function GetDepthIndexByPosition( z )
	return z > -1.5 and 0 or math.min( math.floor((math.abs( z ) * FISH_DEPTHS[ 1 ] / DEPTH_MUL) / FISH_DEPTHS[ #FISH_DEPTHS ] * 10), FISH_DEPTHS[ #FISH_DEPTHS ] )
end

function GetPositionByDepthIndex( depth_index )
	return - FISH_DEPTHS[ depth_index ] / FISH_DEPTHS[ 1 ] * DEPTH_MUL
end