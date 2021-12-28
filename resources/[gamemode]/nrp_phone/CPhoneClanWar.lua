Extend( "ShClans" )

CLANWARAPP = nil

local DATA = { }

APPLICATIONS.clan_war = {
    id = "clan_war",
    icon = "img/apps/clan_war.png",
    name = "Война кланов",
	elements = { },
	
	create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf

		self.elements.header = ibCreateImage( 0, 0, 0, 0, "img/elements/clan_war/header.png", parent ):ibSetRealSize( )

		self:create_list( )

        CLANWARAPP = self
        return self
	end,

	create_list = function( self )
		ibUseRealFonts( true )

		if isElement( self.elements.bg_list ) then
			destroyElement( self.elements.bg_list )
		end

		local resource = getResourceFromName( "nrp_clans_events" )
		if not resource or getResourceState( resource ) ~= "running" then
			ibCreateLabel( 0, 0, 0, 0, "Временно недоступно", self.parent, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.bold_12 )
				:center( )
			return
		end

		self.elements.bg_list = ibCreateArea( 0, self.elements.header:ibGetAfterY( ), self.parent:ibData( "sx" ), 0, self.parent )

		local offset_y = 0

		local events = exports.nrp_clans_events:GetEventConfigs( )
		for event_id, event_conf in ipairs( events ) do
			local resource = getResourceFromName( event_conf.resource_name )
			if resource and getResourceState( resource ) == "running" and event_conf.is_available then
				local bg = ibCreateArea( 0, offset_y, 204, 74, self.elements.bg_list )
				ibCreateImage( 0, 0, 0, 0, "img/elements/clan_war/icons/" .. event_conf.key .. ".png", bg ):ibSetRealSize( ):center( -73, 0 )
				ibCreateLabel( 58, 20, 0, 0, event_conf.name, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_12 )

				offset_y = offset_y + 74

				-- Ожидание игроков
				if DATA.event_id == event_id then
					local btn_cancel = ibCreateButton( 58, 35, 71, 23, bg, 
							"img/elements/clan_war/btn_cancel.png", "img/elements/clan_war/btn_cancel_hover.png", 
							"img/elements/clan_war/btn_cancel_hover.png", _, _, 0xFFAAAAAA )
						:ibOnClick( function( key, state )
							if key ~= "left" or state ~= "up" then return end
							if ( CLICK_TIMEOUT or 0 ) > getTickCount( ) then return end
							CLICK_TIMEOUT = getTickCount( ) + 500
							ibClick( )

							triggerServerEvent( "onPlayerWantCancelRegisterOnClanEvent", localPlayer )
						end )

					local str = "Поиск игры\n" .. DATA.registered_players_count .. "/" .. event_conf.players_count_per_clan
					if DATA.registered_players_count >= event_conf.players_count_per_clan then
						btn_cancel:ibBatchData( {
							disabled = true,
							alpha = 150,
						} )
						str = "Поиск \nоппонентов"
					end
					ibCreateLabel( 134, 46, 0, 0, str, bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_10 )

				-- Регистрация
				else
					local dt = os.date( "*t" )
					local timezone_offset = os.time( ) - ( os.time( os.date( "!*t" ) ) + 3 * 60 * 60 )
					local current_date = getRealTimestamp( )
					local next_start_date = not event_conf.reg_starts and not event_conf.lobby_id and event_conf.start_date
					if event_conf.reg_starts then
						next_start_date = math.huge
						for i, time_str in pairs( event_conf.reg_starts ) do
							local hour, min = unpack( split( time_str, ":" ) )
							hour = tonumber( hour )
							min = tonumber( min )

							local start_date = os.time( { year = dt.year, month = dt.month, day = dt.day, hour = hour, min = min } ) + timezone_offset
							if current_date < start_date then
								next_start_date = math.min( next_start_date, start_date )
							elseif current_date >= start_date + event_conf.reg_duration then
								next_start_date = math.min( next_start_date, start_date + 24 * 60 * 60 )
							else
								next_start_date = false
								break
							end
						end
					end

					if next_start_date then
						local lbl_count = ibCreateLabel( 58, 36, 0, 0, "До начала регистрации:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_10 )
						local lbl_found_count = ibCreateLabel( 58, 50, 0, 0, getTimerString( next_start_date, true ), bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_10 )
							:ibTimer( function( self )
								self:ibData( "text", getTimerString( next_start_date, true ) )
							end, 1000, 0 )
					else
						ibCreateButton( 58, 35, 97, 23, bg, 
								"img/elements/clan_war/btn_register.png", "img/elements/clan_war/btn_register_hover.png", 
								"img/elements/clan_war/btn_register_hover.png", _, _, 0xFFAAAAAA )
							:ibBatchData( {
								disabled = not not DATA.event_id,
								alpha = ( not not DATA.event_id ) and 122 or 255,
							} )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								if ( CLICK_TIMEOUT or 0 ) > getTickCount( ) then return end
								CLICK_TIMEOUT = getTickCount( ) + 500
								ibClick( )
								
								local can_join, msg = localPlayer:CanJoinToEvent( { event_type = "clan_event_register", skip_check_job = true } )
								if not can_join then
									localPlayer:ShowError( msg )
									return
								end
								
								if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
									onTryStopJobByEvent( event_conf.name, function( )
										triggerServerEvent( event_conf.join_event_name or "onPlayerWantRegisterOnClanEvent", localPlayer, event_id, event_conf.lobby_id )
									end )
									return
								end
		
								triggerServerEvent( event_conf.join_event_name or "onPlayerWantRegisterOnClanEvent", localPlayer, event_id, event_conf.lobby_id )
							end )
					end
				end

				ibCreateImage( 0, offset_y - 1, 204, 1, _, self.elements.bg_list, ibApplyAlpha( COLOR_BLACK, 10 ) )
			end
		end

		ibUseRealFonts( false )
	end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        CLANWARAPP = nil
    end,
}

function CEV_OnClientUpdatePhoneUI_handler( event_id, registered_players_count )
	localPlayer:setData( "registered_in_clan_event", event_id, false )

	DATA = {
		event_id = event_id,
		registered_players_count = registered_players_count,
	}

	if CLANWARAPP then
		CLANWARAPP:create_list( )
	end
end
addEvent( "CEV:OnClientUpdatePhoneUI", true )
addEventHandler( "CEV:OnClientUpdatePhoneUI", root, CEV_OnClientUpdatePhoneUI_handler )

function CEV_OnClientPlayerLobbyJoin_handler( )
	localPlayer:setData( "registered_in_clan_event", false, false )

	DATA = { }
	ShowPhoneUI( false )
end
addEvent( "CEV:OnClientPlayerLobbyJoin", true )
addEventHandler( "CEV:OnClientPlayerLobbyJoin", root, CEV_OnClientPlayerLobbyJoin_handler )

function onClientClanWarEventStateChange_handler( event_id, state, lobby_id, start_date, enemy_clan_id )
	if CLANWARAPP then
		CLANWARAPP:create_list( )
	end
	
	if not state then return end

	local clan_id = localPlayer:GetClanID( )
	local enemy_clan_name = GetClanName( enemy_clan_id )
	local cartel_id = GetClanTeam( enemy_clan_id ):getData( "cartel" )
	local time_str = getHumanTimeString( start_date, true ) or "15 мин."

	local title, msg, msg_short
	if event_id == CLAN_EVENT_CARTEL_TAX_WAR then
		title = "Война за общак"
		if lobby_id then
			msg_short = "Регистрация открыта!"
			msg = "Регистрация открыта!"
		elseif localPlayer:IsInCartelClan( ) then
			msg = "Клану \"" .. enemy_clan_name .. "\" объявлена война, регистрация будет открыта через " .. time_str
		else
			msg = "Картель \"" .. enemy_clan_name .. "\" объявил войну вашему клану, регистрация будет открыта через " .. time_str
		end

	elseif event_id == CLAN_EVENT_CARTEL_CAPTURE then
		title = "Война за Дом Картеля"
		if lobby_id then
			msg_short = "Регистрация открыта!"
			msg = "Регистрация открыта!"
		elseif localPlayer:IsInCartelClan( ) then
			msg = "Клан \"" .. enemy_clan_name .. "\" претендует на ваш Картель. \"Война за Дом Картеля\" начнётся через " .. time_str
		else
			msg = "Ваш клан претендует на " .. ( cartel_id == 1 and "Зап." or "Вост." ) .. " Картель. \"Война за Дом Картеля\" начнётся через " .. time_str
		end
	end

	localPlayer:PhoneNotification( {
		title = title,
		msg_short = msg_short,
		msg = msg,
	} )
end
addEvent( "onClientClanWarEventStateChange", true )
addEventHandler( "onClientClanWarEventStateChange", root, onClientClanWarEventStateChange_handler, true, "low" )

function onClientCartelHouseWarFinish_handler( old_cartel_clan_id, candidate_clan_id )
	local cartel_id = old_cartel_clan_id and GetClanTeam( old_cartel_clan_id ):getData( "cartel" ) or GetClanTeam( candidate_clan_id ):getData( "cartel" )
	local msg = ""
	if localPlayer:GetClanID( ) == candidate_clan_id then
		if localPlayer:IsInCartelClan( ) then
			msg = "Ваш клан захватил Дом " .. ( cartel_id == 1 and "Зап." or "Вост." ) .. " Картеля."
		else
			msg = "Ваш клан проиграл войну за Дом Картеля."
		end
	elseif old_cartel_clan_id and localPlayer:GetClanID( ) == old_cartel_clan_id then
		if localPlayer:IsInCartelClan( ) then
			msg = "Вы отбили Дом Картеля."
		else
			msg = "Вы потеряли Дом Картеля. Клан \"" .. GetClanName( candidate_clan_id ) .. "\" выиграл войну."
		end
	else
		if old_cartel_clan_id and GetClanTeam( old_cartel_clan_id ):getData( "cartel" ) then
			msg = "Клан \"" .. GetClanName( old_cartel_clan_id ) .. "\" остался " .. ( cartel_id == 1 and "Зап." or "Вост." ) .. " Картелем."
		else
			msg = "Клан \"" .. GetClanName( candidate_clan_id ) .. "\" захватил Дом " .. ( cartel_id == 1 and "Зап." or "Вост." ) .. " Картеля."
		end
	end

	localPlayer:PhoneNotification( {
		title = "Война за Дом Картеля",
		msg = msg,
	} )
end
addEvent( "onClientCartelHouseWarFinish", true )
addEventHandler( "onClientCartelHouseWarFinish", root, onClientCartelHouseWarFinish_handler )