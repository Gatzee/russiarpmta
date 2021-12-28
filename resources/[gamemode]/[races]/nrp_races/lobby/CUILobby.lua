local bReady = false
local pData = {}

local time_out_time = 60000
local selection = 1
local sections = 
{
	{
        id = "type_race",
        title = "Тип гонки",
        color = 0xFF6988a8,
		host = true,
	},
	{
        id = "start_search",
		title = "Начать поиск",
		host = true,
		color = 0xAA65B971,
		on_enter = function( )
			if pData.is_searching and pData.search_started then
				if getTickCount() - pData.search_started <= time_out_time then
					return false
				end
				UI_elements.black_bg:ibData( "can_destroy", true )
			else
				UI_elements.black_bg:ibData( "can_destroy", false )
			end
			

			local pDataToSend = 
			{
				race_type = pData.allowed_types[ 1 ],
				is_searching = not pData.is_searching,
			}
			triggerServerEvent( "RC:OnPlayerUpdateLobbySettings", resourceRoot, localPlayer, pDataToSend )
		end,
	},
	{
        id = "start_race",
		title = "Начало заезда",
		color = 0xAA65B971,
		on_enter = function( )
			if localPlayer == pData.host then
				triggerServerEvent( "RC:OnPlayerRequestStartRace", resourceRoot, localPlayer )
			else
				bReady = not bReady
				triggerServerEvent( "RC:OnPlayerReadyStateChanged", resourceRoot, localPlayer, bReady )
				UI_elements.label_start_race:ibData( "text", bReady and "Не готов" or "Готов" )
			end
		end
	},
	{
        id = "exit",
		title = "Выйти",
		color = 0xAAB96571,
		on_enter = function( )
			if localPlayer == pData.host and pData.is_searching and pData.search_started then
				if getTickCount() - pData.search_started <= time_out_time then
					return false
				end
			end
			localPlayer.position = localPlayer.position + Vector3( 0, 0, 1 )
			ShowUI_Lobby( false )
			OnRacePostFinished()
			triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer )
        end,
        offset = 22,
	},
}

local info_sections = 
{
	{
		id = "type_race",
		title = "Тип гонки",
		body = function()
			return pData.race_type and RACE_TYPES_DATA[ pData.race_type ].name or "Спринт"
		end
	},
	{
		id = "leader",
		title = "Лидер",
		body = function()
			return pData.host and pData.host:GetNickName() or "-"
		end
	},
	{
		id = "class_race",
		title = "Класс гонки",
		body = function()
			return pData.class and RACE_VEHICLE_CLASSES_NAMES[ pData.class ] or "-"
		end
	},
	{
		id = "min_part",
		title = "Минимальное число участников:",
		body = function()
			return pData.min_players or 2
		end
	},
	{
		id = "time_search",
		title = "Время поиска:",
		body = function()
			if pData.search_started then
				return GetSearchingTime( getTickCount() - pData.search_started )
			end
			return ""
		end
	},
	{
		id = "reward",
		title = "Награда",
		body = function()
			return format_price( pData.bet or 0 )
		end
	},
}

local function SwitchSection( value, is_click )
	local new_section = is_click and value or selection + value
	if sections[ new_section ] then
		if sections[ new_section ].host and localPlayer ~= pData.host then
			SwitchSection( value + 1 )
			return
        end
        
		UI_elements[ "section_" .. sections[ selection ].id ]:ibData( "color", 0x00FFFFFF )
		UI_elements[ "section_" .. sections[ new_section ].id ]:ibData( "color", sections[ new_section ].color )
		selection = new_section
	end
end

local function KeyHandler( key, state )
	if not state then return end

	if key ~= "z" then
		cancelEvent()
	end
	if key == "arrow_r" and sections[ selection ].on_right then
		sections[ selection ].on_right()
    
    elseif key == "arrow_l" and sections[selection].on_left then
		sections[ selection ].on_left()
    
    elseif key == "enter" and sections[selection].on_enter then
		sections[ selection ].on_enter()

    elseif key == "arrow_u" then
		SwitchSection( -1 )
    
    elseif key == "arrow_d" then
		SwitchSection( 1 )
	end
end

function OnTryLeftLobby()
	if localPlayer == pData.host and pData.is_searching and pData.search_started then
		if getTickCount() - pData.search_started <= time_out_time then
			return false
		end
	end
	localPlayer.position = localPlayer.position + Vector3( 0, 0, 1 )
	triggerServerEvent("RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer )
	ShowUI_Lobby( false )
	OnRacePostFinished()
end

function ShowUI_Lobby( state, data, is_leaving )
    if state then
        ShowUI_Selector(false)
		localPlayer:setData( "in_race_lobby", true, false )

        pData = data
		selection = 1
        bReady = false
        
        localPlayer.frozen = true
		triggerEvent( "onClientOffPhoneRadio", localPlayer, true )
        triggerServerEvent( "RC:OnPlayerRequestTrack", resourceRoot, data.track_name )
		
		UI_elements.black_bg = ibCreateBackground( 0x00000000, OnTryLeftLobby, true, true )

		UI_elements.settings = ibCreateImage( 60, 95, 360, 250, nil, UI_elements.black_bg,  0xEE475D75 )
		UI_elements.header_settings = ibCreateImage( 0, 0, 360, 50, nil, UI_elements.settings, 0xFF59738F )
		ibCreateLabel( 0, 0, 360, 50, "Настройки", UI_elements.header_settings, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )

		local py = 50
		for k, v in pairs( sections ) do
			UI_elements[ "section_" .. v.id ] = ibCreateImage( 0, py, 360, 50, nil, UI_elements.settings, 0x00FFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()

                if selection == k and sections[ k ].on_enter then
					sections[ k ].on_enter()
				else
					SwitchSection( k, true )
				end
            end )

            UI_elements[ "label_" .. v.id ] = ibCreateLabel( 25 + (v.offset or 0), 0, 360, 50, v.title, UI_elements[ "section_" .. v.id ], 0xFFDDDDDD, 1, 1, "left", "center", ibFonts.semibold_14 ):ibData( "disabled", true )
            if k ~= #sections then
                ibCreateImage( 0, py + 50, 360, 1, nil, UI_elements.settings, 0x22FFFFFF )
            end
			py = py + 50
		end

		UI_elements.icon_search = ibCreateImage( 324, 14, 22, 24, "files/img/lobby/icon_search.png", UI_elements[ "section_start_search" ] ):ibData( "alpha", 0 )
		if localPlayer == pData.host then
			UI_elements.time_search = ibCreateLabel( 310, 0, 0, 50, "Доступно через: 00:59", UI_elements[ "section_start_search" ], 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.semibold_14 ):ibData( "alpha", 0 )
		end

		UI_elements.label_type = ibCreateLabel( 270, 0, 0, 50, RACE_TYPES_DATA[ data.race_type ].name, UI_elements[ "section_type_race" ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 )
		UI_elements.icon_exit = ibCreateImage( 25, 13, 18, 20, "files/img/lobby/icon_leave.png", UI_elements["section_exit"] )

		UI_elements.players_list = ibCreateImage( 430, 95, 360, 50 + data.max_players * 50, nil, false,  0xEE475D75 )
		UI_elements.header_players = ibCreateImage( 0, 0, 360, 50, nil, UI_elements.players_list, 0xFF59738F )
		UI_elements.header_players_label = ibCreateLabel( 0, 0, 360, 50, "Игроки: 1 из ".. pData.min_players .."-".. pData.max_players, UI_elements.header_players, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )

		UI_elements.info = ibCreateImage( 800, 95, 360, 460, nil, false,  0xEE475D75 )
		UI_elements.header_info = ibCreateImage( 0, 0, 360, 50, nil, UI_elements.info, 0xFF59738F )
		ibCreateLabel( 0, 0, 360, 50, "Информация", UI_elements.header_info, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )

		local py = 160
		for k,v in pairs( info_sections ) do
			UI_elements[ "info_section_" .. v.id ] = ibCreateImage( 0, py, 360, 50, nil, UI_elements.info, 0x00FFFFFF )
			UI_elements[ "info_label_" .. v.id ] = ibCreateLabel( 25, 0, 360, 50, v.title, UI_elements[ "info_section_" .. v.id ], 0xFFDDDDDD, 1, 1, "left", "center", ibFonts.semibold_14 )
			UI_elements[ "info_data_" .. v.id ] = ibCreateLabel( 335, 0, 0, 50, v.body(), UI_elements[ "info_section_" .. v.id ], 0xFFEEEEEE, 1, 1, "right", "center", ibFonts.semibold_14 )
            
			if v.id == "reward" then
				local icon_reward = ibCreateImage( 25, 15, 30, 20, "files/img/lobby/icon_reward.png", UI_elements[ "info_section_" .. v.id ] )
				UI_elements[ "info_label_" .. v.id ]:ibData( "px", 65 ):ibData( "color", 0xFFFFD236 )

				local icon_money = ibCreateImage( 311, 14, 24, 21, "files/img/lobby/icon_money.png", UI_elements[ "info_section_" .. v.id ] )
				UI_elements[ "info_data_" .. v.id ]:ibData( "px", 300 )
			end

			if k ~= #info_sections then
                ibCreateImage( 20, py + 50, 320, 1, nil, UI_elements.info, 0x22FFFFFF )
            end
			py = py + 50
		end
		UI_elements.logo = ibCreateImage( 80, 80, 200, 57, "files/img/lobby/logo.png", UI_elements.info )
		UI_elements.controls = ibCreateImage( 60, scY - 54, 580, 54, "files/img/lobby/controls.png" )

		if localPlayer ~= pData.host then
			UI_elements.label_start_race:ibData( "text", "Готов" )
		end

		SwitchSection( 0 )
		UpdatePlayers( data.players_list or {} )
        UpdateLobbyData( data )
        
        DisableHUD( true )
        showCursor( true )
        SwitchMusic( true )
		addEventHandler( "onClientKey", root, KeyHandler )
		addEventHandler( "onClientKey", root, RaceKeyHandler )

	else
		localPlayer:setData( "in_race_lobby", false, false )
		if isElement( DUMMY_VEHICLE ) then
			destroyElement( DUMMY_VEHICLE )
		end

		removeEventHandler( "onClientKey", root, RaceKeyHandler )
        DestroyTableElements( UI_elements )
        UI_elements = {}
		
		DisableHUD( false )
		showCursor( false )
		removeEventHandler( "onClientKey", root, KeyHandler )
		SwitchMusic()

		if is_leaving then
			DestroyTrack()
		end
	end
end
addEvent( "RC:ShowUI_Lobby", true)
addEventHandler( "RC:ShowUI_Lobby", resourceRoot, ShowUI_Lobby )

function UpdatePlayers( players_list, new_host )
	if not isElement( UI_elements.players_list ) then return end
    
    if UI_elements.players then
        DestroyTableElements( UI_elements.players )
    end
    UI_elements.players = {}
    
	pPlayersList = players_list
	if new_host then
		pData.host = new_host

		if new_host == localPlayer then
			UI_elements.label_start_search:ibData( "text", "Начать поиск" )
		end
	end

	local py = 50
	for k = 1, pData.max_players do
		UI_elements.players[ "bg" .. k ] = ibCreateImage( 0, py, 360, 50, nil, UI_elements.players_list, 0x00FFFFFF )
		UI_elements.players[ "name" .. k ] = ibCreateLabel( 25, 0, 360, 50, pData.is_searching and "Поиск игрока..." or "Пустой слот", UI_elements.players[ "bg" .. k ], 0xFFDDDDDD, 1, 1, "left", "center", ibFonts.semibold_14 )
		
		if players_list[ k ] then
			local v = players_list[ k ]
			UI_elements.players[ "name" .. k ]:ibData( "text", v.ele:GetNickName() )
			UI_elements.players[ "status" .. k ] = ibCreateLabel( 335, 0, 0, 50, v.status and "Готов" or "Не готов", UI_elements.players[ "bg" .. k ], v.status and 0xFF3BE26E or 0xFFFF4343, 1, 1, "right", "center", ibFonts.semibold_14 )
			UI_elements.players[ "status_icon" .. k ] = ibCreateImage( 357, 18, 3, 15, "files/img/lobby/icon_ready.png", UI_elements.players[ "bg" .. k ], (v.ele == pData.host or v.status) and 0xFF3BE26E or 0xFFFF4343 )

			if v.ele == pData.host then
				UI_elements.players.host = ibCreateImage( 268, 12, 72, 26, "files/img/lobby/icon_host.png", UI_elements.players[ "bg" .. k ] )
			elseif v.ele == localPlayer then
				UI_elements.label_start_race:ibData( "text", v.status and "Не готов" or "Готов" )
			end
		end

		if k ~= pData.max_players then
            UI_elements.players[ "line" .. k ] = ibCreateImage( 20, py + 50, 320, 1, nil, UI_elements.players_list, 0x22FFFFFF )
        end
		py = py + 50
	end

	UI_elements.header_players_label:ibData( "text", "Игроки: " .. #players_list .. " из " .. pData.min_players .. "-" .. pData.max_players )
end
addEvent( "RC:OnPlayersListUpdated", true )
addEventHandler( "RC:OnPlayersListUpdated", resourceRoot, UpdatePlayers )

function UpdateInfo()
	if not isElement( UI_elements.settings ) then return end
	for k, v in pairs( info_sections ) do
		UI_elements[ "info_data_" .. v.id ]:ibData( "text", v.body() )
	end
end

function UpdateLobbyData( data )
	if not isElement( UI_elements.settings ) then return end
	
	for k,v in pairs( data ) do
		if k == "race_type" then
			UI_elements.label_type:ibData( "text", RACE_TYPES_DATA[ v ].name )
        elseif k == "is_searching" then
			UI_elements[ "label_start_search" ]:ibData( "text", v and "Отмена поиска" or "Начать поиск" )
			UI_elements.icon_search:ibData( "alpha", v and 255 or 0 )
			
			if localPlayer == pData.host then
				UI_elements.time_search:ibData( "alpha", v and 255 or 0 )
			end

            if v then
				UI_elements.label_type:ibData("color", 0x77FFFFFF)
				if pData[ k ] ~= v then
                    if isTimer( pSearchTimer ) then 
                        killTimer( pSearchTimer ) 
                    end
					pData.search_started = getTickCount()
					pSearchTimer = setTimer( UpdateSearchingTimer, 1000, 0 )
				end
			else
				UI_elements.label_type:ibData( "color", 0xFFFFFFFF )
				if pData[ k ] ~= v then
                    if isTimer( pSearchTimer ) then 
                        killTimer( pSearchTimer ) 
                    end
					pData.search_started = false
				end
			end
		end
		pData[ k ] = v
	end

	for k, v in pairs( pPlayersList ) do
		v.status = false
	end
	
	if localPlayer ~= pData.host then
		bReady = false
		UI_elements.label_start_race:ibData( "text", "Готов" )
	end
	
	UpdatePlayers( pPlayersList )
	UpdateInfo( )
end
addEvent( "RC:OnLobbyUpdated", true)
addEventHandler( "RC:OnLobbyUpdated", resourceRoot, UpdateLobbyData )

function GetSearchingTime( time )
	if pData.search_started then
		local iSeconds = math.floor( time / 1000 )
		local iMinutes = math.floor( iSeconds / 60 )
		iSeconds = iSeconds - iMinutes * 60
		return ( "%02d:%02d" ):format( iMinutes, iSeconds )
    end
    return ""
end

function UpdateSearchingTimer()
	local sTime = GetSearchingTime( getTickCount() - pData.search_started )
	if isElement( UI_elements.info_data_time_search ) then
		UI_elements.info_data_time_search:ibData( "text", sTime )
		
		if localPlayer == pData.host then
			local time_left = time_out_time - (getTickCount() - pData.search_started)
			if time_left > 0 then
				UI_elements.time_search:ibData( "text", "Доступно через: " .. GetSearchingTime(time_left  ) )
			else
				UI_elements.time_search:ibData( "alpha", 0 )
			end
		end
	elseif isTimer( pSearchTimer ) then 
        killTimer( pSearchTimer ) 
	end
end