
bFinished = nil

RACE_DATA = {}
HIDE_HUD_BLOCKS = { "main", "notifications", "daily_quest", "factionradio", "cases_discounts", "quest", "ksusha", "wanted", "offers", "offer_ingame_draw", "split_offer", "7cases", }

function OnRaceStarted( data, vehicle, leaders_season )
	vehicle.frozen = true
	localPlayer.frozen = true
	toggleAllControls( false )

	if not TRACK then
		local pTrack = ReadTrack( data.track_name, true )
		LoadTrack( pTrack )
	end

	RACE_DATA = data
	RACE_DATA.leaders_season = leaders_season or {}
	
	bFinished = false
	
	ShowUI_Lobby( false )
	DisableHUD( true )
		
	setTimer( function()
		removeEventHandler( "onClientKey", root, RaceKeyHandler )
		addEventHandler( "onClientKey", root, RaceKeyHandler )
		playSound( "files/sfx/lobby_start.wav" )
		
		toggleAllControls( false )
		setCameraTarget( localPlayer )
		fadeCamera( true, 1 )

		if RACE_DATA.race_type == RACE_TYPE_DRAG then
			UIShowBasis_HUD( true, data )
		end

		vehicle.frozen = false
		localPlayer.frozen = false

		for i, v in pairs( RACE_DATA.players ) do
			if v == localPlayer then
				TRACK.start_position = TRACK.spawns[ i ]
				vehicle.position = Vector3( TRACK.start_position )
			end
		end

		setTimer( function()
			if RACE_DATA and next( RACE_DATA ) then
				vehicle.frozen = true
				localPlayer.frozen = true
			end
		end, 150, 1 )
		
		localPlayer:CompleteDailyQuest( "participate_race" )
	end, 1000, 1 )

	setTimer( function()
		if MODES[ RACE_DATA.race_type ].detect_wrong_size then
			DETECT_WRONG_DIRECTION_TMR = setTimer( DetectWrongDirection, 1000, 0 )
		end
		
		if MODES[ RACE_DATA.race_type ].detect_damage then
			addEventHandler( "onClientVehicleDamage", localPlayer.vehicle, onClientVehicleDamage_handler )
		end

		if MODES[ RACE_DATA.race_type ].limit_time then
			AddLimitTimeRace( MODES[ RACE_DATA.race_type ].limit_time, MODES[ RACE_DATA.race_type ].callback_limit_time )
		end

		for k, v in pairs( getElementsByType( "vehicle" ) ) do
			setElementCollidableWith( localPlayer.vehicle, v, false )
		end
		
		if RACE_DATA.race_type ~= RACE_TYPE_DRAG then
			DisableHUD( false )
			triggerEvent( "ShowInventoryHotbar", localPlayer, false )
			UIShowBasis_HUD( true, data )
			triggerEvent( "onClientSetChatState", localPlayer, false )
		end

		triggerServerEvent( "onServerPlayerReadyToStartRace", resourceRoot )
	end, 4000, 1 )
	
	RACE_DATA.blips = {}
	for k,v in pairs( data.players ) do
		if v ~= localPlayer then
			local blip = createBlipAttachedTo( v, 0, 1, 60, 60, 60, 150, 0, 150 )
			blip.dimension = localPlayer.dimension
			setBlipVisibleDistance( blip, 300 )
			table.insert( RACE_DATA.blips, blip )
		end
	end

	localPlayer:setData( "in_race", true, false )
end
addEvent( "RC:OnRaceStarted", true )
addEventHandler( "RC:OnRaceStarted", resourceRoot, OnRaceStarted )

function onClientStartCountdown_handler()
	if not RACE_DATA then return end
	ShowStartSequence( RACE_DATA.race_type, MODES[ RACE_DATA.race_type ].race_sequence_callback )
end
addEvent( "onClientStartCountdown", true )
addEventHandler( "onClientStartCountdown", resourceRoot, onClientStartCountdown_handler )


function OnRaceFinished( is_forced, result, data )
	bFinished = true
	if isTimer( DETECT_WRONG_DIRECTION_TMR ) then
		killTimer( DETECT_WRONG_DIRECTION_TMR )
	end
	
	if isElement( UI_elements.start_timer_bg ) then
		destroyElement( UI_elements.start_timer_bg )
	end
	
	for k, v in pairs( getElementsByType( "vehicle" ) ) do
		setElementCollidableWith( localPlayer.vehicle, v, true )
	end

	removeEventHandler( "onClientVehicleDamage", localPlayer.vehicle, onClientVehicleDamage_handler )
	
	UIShowBasis_HUD( false )
	
	DestroyTableElements( RACE_DATA.blips )
	ShowFinishUI( true, result, data )
	DestroyTrack( TRACK )
	
	RACE_DATA = {}
	
	TRACK = nil
	pNextMarker = nil
	pNextVisibleMarker = nil
end
addEvent( "RC:OnRaceFinished", true )
addEventHandler( "RC:OnRaceFinished", resourceRoot, OnRaceFinished )

function OnRacePostFinished()
	if isTimer( DETECT_WRONG_DIRECTION_TMR ) then
		killTimer( DETECT_WRONG_DIRECTION_TMR )
	end
	
	triggerEvent( "onClientHideHudComponents", root, HIDE_HUD_BLOCKS, false )

	triggerEvent( "onClientRestoreRadioChannel", resourceRoot )
	triggerEvent( "UpdatePhoneNotificationsIcon", resourceRoot )
	triggerEvent( "onClientRefreshBusinessOffer", resourceRoot )
	triggerEvent( "onClientonRefreshCasesDiscount", resourceRoot )
	triggerEvent( "onClientShowDailyQuests", resourceRoot )
	triggerEvent( "Show3daysInfo", resourceRoot )
	triggerEvent( "onKsushaWaitStart", resourceRoot )
	triggerEvent( "onClientRefreshAngelaDiscount", resourceRoot )
	triggerEvent( "onClientShowWanted", resourceRoot )

	triggerEvent( "onClientSetChatState", resourceRoot, true )
	removeEventHandler( "onClientKey", root, RaceKeyHandler )

	DisableHUD( false )
	localPlayer:setData( "in_race", false, false )
	toggleAllControls( true )
	toggleControl("change_camera", false)
	ShowFinishUI( false )
end
addEvent( "RC:OnRacePostFinished", true )
addEventHandler( "RC:OnRacePostFinished", resourceRoot, OnRacePostFinished )