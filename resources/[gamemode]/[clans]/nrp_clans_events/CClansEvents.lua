loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShClans" )
Extend( "CPlayer" )
Extend( "CUI" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

scx, scy = guiGetScreenSize( )

GAME_DATA = { clans_tags = { } }

local ui = {}

function OnClientPlayerLobbyJoin( data )
	setElementData( localPlayer, "in_clan_event_lobby", true, false )
	setElementData( localPlayer, "radial_disabled", true, false )

	if data.lobby_state == LOBBY_STATE_PREPARATION then
		if data.time_left then
			ShowUI_Countdown( true, data.time_left )
		end
	end

	addEventHandler( "onClientKey", root, KeyHandler )
	addEventHandler( "onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler )
end
addEvent( "CEV:OnClientPlayerLobbyJoin", true )
addEventHandler( "CEV:OnClientPlayerLobbyJoin", root, OnClientPlayerLobbyJoin )

function OnClientPlayerLobbyLeave( )
	if eventName == "onClientResourceStop" and not localPlayer:getData( "in_clan_event_lobby" ) then
		return 
	end

	setElementData( localPlayer, "in_clan_event_lobby", false, false )
	setElementData( localPlayer, "radial_disabled", false, false )

	removeEventHandler( "onClientKey", root, KeyHandler )
	ShowUI_Countdown( false )
	ShowResultUI( false, true )

	toggleAllControls( true )
	removeEventHandler( "onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler )
end
addEvent( "CEV:OnClientPlayerLobbyLeave", true )
addEventHandler( "CEV:OnClientPlayerLobbyLeave", root, OnClientPlayerLobbyLeave )
addEventHandler( "onClientResourceStop", resourceRoot, OnClientPlayerLobbyLeave )

function OnClientGameStarted( data )
	GAME_DATA = data
    ShowUI_Countdown( false )
end
addEvent( "CEV:OnClientGameStarted", true )
addEventHandler( "CEV:OnClientGameStarted", root, OnClientGameStarted )

function OnClientGameFinished( data )
	removeEventHandler( "onClientKey", root, KeyHandler )
	ShowResultUI( true, data )
	-- ShowUI_Countdown( true, 11, "Игра завершается" )
	-- ui.countdown:ibData( "color", 0xFF000000 )
	-- ui.countdown:ibData( "alpha", 0 )
	-- ui.countdown:ibAlphaTo( 255, 8000 )

	toggleAllControls( false )
end
addEvent( "CEV:OnClientGameFinished", true )
addEventHandler( "CEV:OnClientGameFinished", resourceRoot, OnClientGameFinished )

function ShowUI_Countdown( state, time_left, custom_text )
	if state then
		ui.countdown = ibCreateImage( 0, 0, scx, scy, nil, false, 0x00000000 ):ibData( "disabled", true )
		ibCreateLabel( scx/2, scy/3-30, 0, 0, custom_text or "Игра начнётся через:", ui.countdown, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_22 ):ibData( "outline", 1 )
		
        local start_date = getRealTimestamp( ) + ( time_left or 10 )
		ui.time_left = ibCreateLabel( scx/2, scy/3, 0, 0, getTimerString( start_date ), ui.countdown, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_30 ):ibData( "outline", 1 )
			:ibTimer( function( self )
				self:ibData( "text", getTimerString( start_date ) )
			end, 1000, 0 )
	else
		if isElement( ui.countdown ) then
			destroyElement( ui.countdown )
		end
	end
end
addEvent( "CEV:ShowUI_Countdown", true )
addEventHandler( "CEV:ShowUI_Countdown", resourceRoot, ShowUI_Countdown )

function KeyHandler( key, state )
	if not state then return end

	if key == "F1" then
		cancelEvent( )

		if confirmation then confirmation:destroy( ) end
		showCursor( true )

		confirmation = ibConfirm( 
		    {
		        title = "ВЫХОД ИЗ СОБЫТИЯ", 
		        text = "Ты уверен, что хочешь покинуть событие? В случае выхода ты не получишь награды за участие" ,
		        fn = function( self )
		        	triggerServerEvent( "CEV:OnPlayerRequestEventLeave", localPlayer )
		            self:destroy( )
		            showCursor( false )
		        end,

		        fn_cancel = function( self ) 
	                showCursor( false )
				end,
				escape_close = true,
		    }
		 )
	end
end

function OnClientPlayerDamage_handler( pAttacker )
	if isElement( pAttacker ) and getElementType( pAttacker ) == "player" then
		if pAttacker:GetClanID( ) == localPlayer:GetClanID( ) then
			cancelEvent( )
		end
	end
end