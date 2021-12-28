RIVAL_DATA = nil

MODES[ RACE_TYPE_DRAG ] = 
{
    id = RACE_TYPE_DRAG,
    countdown_text = { "9", "8", "7", "6", "5", "4", "3", "2", "1", "GO", },
    name = RACE_TYPES_DATA[ RACE_TYPE_DRAG ].name,
    tabs = 
    { 
        {
            name = "Заезд",
            create_content = function( parent )
                UI_elements.rival_nickname = ""

                local function CheckRate()
                    if UI_elements.current_rate_id and DRAG_RATES[ UI_elements.current_rate_id ] > localPlayer:GetMoney() then
                        UI_elements.repl_acc:ibBatchData({ disabled = false, alpha = 255 })
                        return false
                    end
                    UI_elements.repl_acc:ibBatchData({ disabled = true, alpha = 0 })
                    return UI_elements.current_rate_id and true or false
                end
                
                local function CheckRival( nickname )
                    UI_elements.rival_nickname = nickname

                    UI_elements.edf_rival_nickname:ibData( "text", nickname )
                    UI_elements.edf_rival_nickname:ibData( "caret_position", utf8.len( nickname ) + 1 )
                    
                    local rival_exist = false
                    local players = GetPlayersInGame()
                    for k, v in pairs( players ) do
                        if v:GetNickName() == nickname and v ~= localPlayer then
                            rival_exist = true
                            break
                        end
                    end
                    
                    UI_elements.rival_state:ibBatchData( {
                        text  = rival_exist and "Соперник выбран" or "Соперник не выбран",
                        color = rival_exist and 0xFFFFDE9E or  0xFFAF5259,
                    } )

                    return rival_exist
                end
                
                ibCreateLabel( 0, 103, 1024, 0, "Поиск соперника", parent, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.bold_20 )
                ibCreateLabel( 0, 212, 1024, 0, "Ставка", parent, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.bold_20 )

                local bg_rival = ibCreateImage( 233, 149, 558, 50, "files/img/mode_selector/bg_edit.png", parent )
                UI_elements.edf_rival_nickname = ibCreateEdit( 15, 0, 420, 50, "", bg_rival, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
                UI_elements.edf_rival_nickname:ibBatchData( { font = ibFonts.regular_16, max_length = 20 } )
                :ibOnDataChange( function( key, value )
                    if key == "text" and UI_elements.rival_nickname ~= value then
                        CheckRival( value )
                    end
                end )
                
                UI_elements.rival_state = ibCreateLabel( 542, 0, 0, 50, "Соперник не выбран", bg_rival, 0xFFAF5259, 1, 1, "right", "center", ibFonts.regular_14 ):ibData( "disabled", true )
                if RIVAL_DATA then
                    CheckRival( RIVAL_DATA.rival_nickname )
                end

                local bg_rate = ibCreateImage( 233, 258, 558, 50, "files/img/mode_selector/bg_edit.png", parent )
                UI_elements.select_rate = ibCreateLabel( 15, 0, 0, 50, "Выберите размер ставки:", bg_rate, 0xAA8C99A7, 1, 1, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )
                UI_elements.rate_value = ibCreateLabel( 16, 0, 0, 50, "0", bg_rate, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                :ibBatchData({ disabled = true, alpha = 0 })
                
                UI_elements.rate_img = ibCreateImage( 0, 15, 24, 20, "files/img/mode_selector/soft.png", bg_rate )
                :ibBatchData({ disabled = true, alpha = 0 })

                ibCreateButton( 423, 490, 177, 50, parent, "files/img/mode_selector/btn_start_race.png", "files/img/mode_selector/btn_start_race_hover.png", "files/img/mode_selector/btn_start_race_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    if not CheckRate() or not CheckRival( UI_elements.rival_nickname ) then return end

                    triggerServerEvent( "RC:onServerTryStartDragRacing", resourceRoot, 
                    {
                        rival_nickname = UI_elements.rival_nickname, 
                        rate_id        = UI_elements.current_rate_id,
                    } )
                end )
                
                UI_elements.repl_acc = ibCreateImage( 291, 387, 441, 16, "files/img/mode_selector/btn_repl_acc.png", parent )
                :ibBatchData({ disabled = true, alpha = 0 })
                :ibOnHover( function( )
                    UI_elements.repl_acc:ibData( "texture", "files/img/mode_selector/btn_repl_acc_hover.png" )
                end )
                :ibOnLeave( function( )
                    UI_elements.repl_acc:ibData( "texture", "files/img/mode_selector/btn_repl_acc.png" )
                end )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
                end )
                UI_elements.repl_acc:ibTimer( function()
                    CheckRate()
                end, 1000, 0 )

                local px, py = 233, 313
                for k, v in pairs( DRAG_RATES ) do
                    UI_elements[ "rate_" .. k ] = ibCreateImage( px, py, 110, 44, _, parent, 0x5A8C99A7 )
                    :ibOnHover( function( )
                        if UI_elements.current_rate_id ~= k then
                            UI_elements[ "rate_" .. k ]:ibData( "color", 0xFF8C99A7 )
                        end
                    end )
                    :ibOnLeave( function( )
                        if UI_elements.current_rate_id ~= k then
                            UI_elements[ "rate_" .. k ]:ibData( "color", 0x5A8C99A7 )
                        end
                    end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                        ibClick()
                        if UI_elements.current_rate_id ~= k then
                            if UI_elements.current_rate_id then
                                UI_elements[ "rate_" .. UI_elements.current_rate_id ]:ibData( "color", 0x5A8C99A7 )
                            else
                                UI_elements.select_rate:ibData( "alpha", 0 )
                                UI_elements.rate_value:ibData( "alpha", 255 )
                                UI_elements.rate_img:ibData( "alpha", 255 )
                            end

                            UI_elements.rate_value:ibData( "text", DRAG_RATES[ k ] )
                            UI_elements.rate_img:ibData( "px", 16 + dxGetTextWidth( DRAG_RATES[ k ], 1, ibFonts.bold_16 ) + 6 )

                            UI_elements.current_rate_id = k
                            UI_elements[ "rate_" .. k ]:ibData( "color", 0xFF8C99A7 )
                            CheckRate()
                        end
                    end )
                    local sx = dxGetTextWidth( v, 1, ibFonts.bold_16 )
                    local pos_x = (110 / 2 - sx + 32) / 2
                    ibCreateLabel( pos_x, 0, 0, 44, v, UI_elements[ "rate_" .. k ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 ):ibData( "disabled", true )
                    ibCreateImage( pos_x + sx + 8, 11, 24, 20, "files/img/mode_selector/soft.png", UI_elements[ "rate_" .. k ] ):ibData( "disabled", true )

                    px = px + 111
                end

                UI_elements.current_rate_id = nil
                RIVAL_DATA = nil

                return parent
            end,
        }, 
        {
            name = "Статистика",
            create_content = MODES[ RACE_TYPE_DRIFT ].tabs[ 2 ].create_content,
        }, 
        {
            name = "Таблица лидеров",
            create_content = MODES[ RACE_TYPE_DRIFT ].tabs[ 3 ].create_content,
        },
        {
            name = "Правила",
            create_content = function( parent )
                local rules_text = [[• В драг-рейсинге всегда участвует только два игрока.
• Инициатор гонки указывает ставку и предлагает участие
  конкретному игроку.
• Если соперник стоит рядом с вами, то вы можете сделать
  “вызов” на гонку через радиальное меню. [ Tab ]
• При вызове вы и ваш соперник должны находиться 
  в машине.
• Для участия в гонке машины должны быть одного класса.                  
• Вы можете участвовать в гонке только на своей машине.]]

                local control_text = [[• В каждой гонке ручное переключение передач.
• Переключение на передачу вверх кнопка - [ стрелка вверх ]
• Переключение передачи вниз кнопка - [ стрелка вниз ] ]]

                ibCreateLabel( 0, 20, 1024, 0, "Правила гонки", parent, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.bold_24 )
                ibCreateLabel( 210, 60, 1024, 0, rules_text, parent, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_20 )

                ibCreateLabel( 0, 330, 1024, 0, "Управление", parent, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.bold_24 )
                ibCreateLabel( 210, 370, 1024, 0, control_text, parent, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_20 )
            end,
        },
    },
    
    detect_wrong_size = true,
    race_sequence_callback = function()
        UI_elements.start_time = getTickCount()
        IS_DRAG_START = true
    end,

    custom_limit_time = 30,
    callback_limit_time = function()
        DestroyDrag()
        triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Слишком медленно" )
    end,

    detect_damage = false,
    leader_boards = false,
    leader_boards = false,

    text_points = "Время",
	prepare_points = function( value )
        local minute = math.floor( value / 60000 )
        local seconds = math.floor( (value - minute * 60000) / 1000 )
        local milliseconds = value - minute * 60000 - seconds * 1000
        return string.format( "%02d:%02d:%02d", minute, seconds, milliseconds )
	end,
}


local GEAR_SHIFT_KEY_UP = "arrow_u"
local GEAR_SHIFT_KEY_DOWN = "arrow_d"

local CURRENT_GEAR = 0 
local GEAR_SETTING =
{
    [ 0 ] =
    {
        name = "R",
        zones = { y = 0.44, g = 0.7, r = 0.85 },
        gear_coeff = { [ 1 ] = -200,[ 2 ] = -200,[ 3 ] = -200,[ 4 ] = -200,[ 5 ] = -200, },
        accl_coeff = { [ 1 ] = 0, [ 2 ] = 0, [ 3 ] = 0, [ 4 ] = 0, [ 5 ] = 0, },
    },
    [ 1 ] =
    {
        name = "1",
        zones = { y = 0.5, g = 0.72, r = 0.85 },
        gear_coeff = { [ 1 ] = -80,[ 2 ] = -100,[ 3 ] = -100,[ 4 ] = -100,[ 5 ] = -100, },
        accl_coeff = { [ 1 ] = 120, [ 2 ] = 100, [ 3 ] = 100, [ 4 ] = 100, [ 5 ] = 100, },
    },
    [ 2 ] =
    {
        name = "2",
        zones = { y = 0.57, g = 0.75, r = 0.85 },
        gear_coeff = { [ 1 ] = -60,[ 2 ] = -80,[ 3 ] = -80,[ 4 ] = -80,[ 5 ] = -80, },
        accl_coeff = { [ 1 ] = 70, [ 2 ] = 50, [ 3 ] = 50, [ 4 ] = 50, [ 5 ] = 50,  },
    },
    [ 3 ] =
    {
        name = "3",
        zones = { y = 0.63, g = 0.78, r = 0.85 },
        gear_coeff = { [ 1 ] = -40,[ 2 ] = -60,[ 3 ] = -60,[ 4 ] = -60,[ 5 ] = -60, },
        accl_coeff = { [ 1 ] = 60, [ 2 ] = 40, [ 3 ] = 40, [ 4 ] = 40, [ 5 ] = 40,  },
    },
    [ 4 ] =
    {
        name = "4",
        zones = { y = 0.67, g = 0.8, r = 0.85 },
        gear_coeff = { [ 1 ] = -10, [ 2 ] = -30, [ 3 ] = -30, [ 4 ] = -30, [ 5 ] = -30, },
        accl_coeff = { [ 1 ] = 50, [ 2 ] = 30, [ 3 ] = 30, [ 4 ] = 30, [ 5 ] = 30,  },
    },
    [ 5 ] =
    {
        name = "5",
        gear_coeff = { [ 1 ] = 0, [ 2 ] = 0, [ 3 ] = 0, [ 4 ] = 0, [ 5 ] = 0, },
        accl_coeff = { [ 1 ] = 0, [ 2 ] = 0, [ 3 ] = 0, [ 4 ] = 0, [ 5 ] = 0, },
    },
}

IS_DRAG_START = false
local NEUTRAL_RPM = 0
local MAX_NEUTRAL_RPM = 1000
local KEYS_FORWARD = getBoundKeys( "forwards" )

enum "eDragSwitchResut" {
	"SWITCH_EARLY",
	"SWITCH_GOOD",
    "SWITCH_NICE",
    "SWITCH_BAD",
}

local SWITCH_REVERSE = 50
local SWITCH_RESULT =
{
    [ SWITCH_EARLY ] = { start_value = 0,  value = 15, text = "Неудача!",  color = 0xFFDF3333 },
    [ SWITCH_GOOD ]  = { start_value = 10, value = 10, text = "Хорошо!",   color = 0xFFDCDF33 },
    [ SWITCH_NICE ]  = { start_value = 15, value = 5,  text = "Идеально!", color = 0xFF54FF58 },
    [ SWITCH_BAD ]   = { start_value = 5,  value = 8,  text = "Неплохо!",  color = 0xFFDF3333 },
}

local DEF_SETTING = nil

function ShowDragUI( state, data )
    if state then
        IS_DRAG_START = false
        DisableHUD( false )
       
        local vehicle = localPlayer.vehicle
        
        triggerEvent( "onClientDragChangeGear", root, vehicle, { max_rpm = MAX_NEUTRAL_RPM, gear = 0 } )

        DEF_SETTING = {}
        localPlayer.vehicle:setData( "custom_gear", 0, false )
        DEF_SETTING.max_rpm = MAX_NEUTRAL_RPM
        DEF_SETTING.speed, DEF_SETTING.accleration, DEF_SETTING.handling = data.stats[ 1 ], data.stats[ 2 ], data.stats[ 3 ]
        resetVehicleParameters( vehicle )

        CURRENT_GEAR = 0
        UI_elements.prev_place = 1
        addEventHandler( "onClientKey", root, onRaceDragKey_handler )
        
        UI_elements.bg_tachometer = ibCreateImage( 60, 0, 296, 646, "files/img/drag/bg_tachometer.png" )
        :center_y()

        UI_elements.race_name = ibCreateLabel( scX - 29, 29, 0, 0, "ДРАГ-РЕЙСИНГ", _, 0xFFFFFFFF, 1, 1, "right", "top", ibFonts.bold_34 )
        :ibData( "outline", 1 )

        UI_elements.race_icon = ibCreateImage( scX - 66, 89, 36, 42, "files/img/drag/timer.png" )

        local ox_bold_25 = dxCreateFont( "files/fonts/Oxanium-Bold.ttf", 25, false, "antialiased" )
        UI_elements.race_time = ibCreateLabel( scX - 87, 92, 0, 42, MODES[ RACE_TYPE_DRAG ].prepare_points( 0 ), _, 0xFFFFFFFF, 1, 1, "right", "center", ox_bold_25 )
        :ibData( "outline", 1 )
        
        UI_elements.podium_icon = ibCreateImage( scX - 65, 156, 36, 42, "files/img/drag/podium.png" )

        local ox_regular_41 = dxCreateFont( "files/fonts/Oxanium-Regular.ttf", 41, false, "antialiased" )
        UI_elements.race_place = ibCreateLabel( scX - 130, 155, 0, 42, "1", _, 0xFFFFFFFF, 1, 1, "right", "center", ox_regular_41 )
        :ibData( "outline", 1 )
        
        local ox_regular_28 = dxCreateFont( "files/fonts/Oxanium-Regular.ttf", 28, false, "antialiased" ) 
        UI_elements.count_places = ibCreateLabel( scX - 88, 163, 0, 42, "/2", _, 0xFF8B8B8B, 1, 1, "right", "center", ox_regular_28 )

        UI_elements.textures = {}
        for k, v in pairs( { 0, 1, 2, 3, 4, 5 } ) do
            UI_elements.textures[ v ] = dxCreateTexture( "files/img/drag/gear_" .. v .. ".png" )
        end
        
        UI_elements.rpm_line = ibCreateImage( 18, 106, 140, 281, UI_elements.textures[ 0 ], UI_elements.bg_tachometer ):ibData( "disabled", true )
        UI_elements.cur_gear = ibCreateLabel(  207, 416, 0, 0, "N", UI_elements.bg_tachometer, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_50 )

        ibCreateImage( 0, 0, 262, 646, "files/img/drag/tachometer_arrows.png", UI_elements.bg_tachometer )

        UI_elements.arrow_rpm = ibCreateImage( 205, 285, 34, 243, "files/img/drag/arrow.png", UI_elements.bg_tachometer )
        :ibData( "rotation_offset_x", 0 )
        :ibData( "rotation_offset_y", -77 )
        :ibOnRender( function()
            if isElement( vehicle ) then
                if CURRENT_GEAR > 0 and DEF_SETTING then
                    local value = (GetVehicleRPM( vehicle ) / DEF_SETTING.max_rpm ) * 180
                    UI_elements.arrow_rpm:ibData( "rotation", math.min( 185, value ) )
                    UI_elements.rpm_line:ibData( "texture", UI_elements.textures[ CURRENT_GEAR ] )
                end
            end
            
            -- Обновления таймера, позиции
            if UI_elements.start_time then
                UI_elements.race_time:ibData( "text", MODES[ RACE_TYPE_DRAG ].prepare_points( getTickCount() - UI_elements.start_time ) )
                
                if pNextVisibleMarker then
                    local next_point = Vector3( pNextVisibleMarker.x, pNextVisibleMarker.y, pNextVisibleMarker.z )
                    local race_place = 1
                    if isElement( RACE_DATA.rival ) then
                        race_place = getDistanceBetweenPoints3D( localPlayer.position, next_point ) > getDistanceBetweenPoints3D( RACE_DATA.rival.position, next_point ) and 2 or 1
                    end
                    if UI_elements.prev_place ~= race_place then
                        UI_elements.prev_place = race_place
                        UI_elements.race_place:ibData( "text", race_place )
                    end
                end
            end
        end )
        
        UI_elements.hint = ibCreateImage( 0, scY - 100, 601, 70, "files/img/drag/hint_shift.png" )
        :center_x()
        :ibTimer( function()
            UI_elements.hint:ibAlphaTo( 0, 150 )
        end, #MODES[ RACE_TYPE_DRAG ].countdown_text * 1000, 1 )

        UI_elements.drag_change_gear_result = ibCreateLabel( 0, 200, scX, 0, "", _, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_24 )
        :ibData( "outline", true )
        localPlayer:setData( "drag_race", true, false )

        setElementFrozen( localPlayer.vehicle, true )
        toggleControl( "handbrake", false )
        setPedControlState( localPlayer, "handbrake", true )
        setCameraClip( true, false )

        NEUTRAL_RPM = 0
        addEventHandler( "onClientPreRender", root, onNeutralRPMCalculate )
        UI_elements.leave_timer = setTimer( AddLimitTimeDrag, 2 * 60 * 1000, 1, MODES[ RACE_TYPE_DRAG ].custom_limit_time )
    end
end

function DestroyDrag()
    if DEF_SETTING then
        localPlayer.vehicle:setData( "custom_gear", false, false )
        resetVehicleParameters( localPlayer.vehicle )
        DEF_SETTING = nil
    end

    setElementFrozen( localPlayer.vehicle, false )
    toggleControl( "handbrake", true )
    setPedControlState( localPlayer, "handbrake", false )
    localPlayer:setData( "drag_race", nil, false )
    removeEventHandler( "onClientPreRender", root, onNeutralRPMCalculate )
    setCameraClip( true, true )
    IS_DRAG_START = false
    removeEventHandler( "onClientKey", root, onRaceDragKey_handler )
end

function onNeutralRPMCalculate( time_slice )
    local forward = false
	for k, v in pairs( KEYS_FORWARD ) do
		if getKeyState( k ) then 
			forward = true
			break
		end
	end
	
	if forward then
		NEUTRAL_RPM = math.min( NEUTRAL_RPM + time_slice, MAX_NEUTRAL_RPM )
	else
		NEUTRAL_RPM = math.max( 0, NEUTRAL_RPM - time_slice )
    end
    
    UI_elements.arrow_rpm:ibData( "rotation", NEUTRAL_RPM / MAX_NEUTRAL_RPM * 180 )
end

function OnClientCreateDragLobby_handler( start_time_lobby_created )
    OnClientIgnoredlDragLobby_handler()
    
    local time = math.min( DRAG_DESTOY_TIME, math.floor( DRAG_DESTOY_TIME - (getRealTimestamp() - start_time_lobby_created )) )
    UI_elements.drag_lobby_timeout = ibCreateLabel( 0, 0, scX, scY / 2, "Ожидание противника\n" .. time, _, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_36 )
    :ibData( "outline", 1 )
    
    UI_elements.drag_lobby_timeout
    :ibTimer( function()
        local time = math.floor( DRAG_DESTOY_TIME - (getRealTimestamp() - start_time_lobby_created ))
        if time > 0 then
            UI_elements.drag_lobby_timeout:ibData( "text", "Ожидание противника\n" .. time )
        else
            UI_elements.drag_lobby_timeout:destroy()
        end
    end, 1000, time + 5)
    
end
addEvent( "RC:OnClientCreateDragLobby", true )
addEventHandler( "RC:OnClientCreateDragLobby", resourceRoot, OnClientCreateDragLobby_handler )

function OnClientIgnoredlDragLobby_handler()
    if isElement( UI_elements and UI_elements.drag_lobby_timeout) then UI_elements.drag_lobby_timeout:destroy() end
    ShowLobbyCreateUI( false )
end
addEvent( "RC:OnClientIgnoredlDragLobby", true )
addEventHandler( "RC:OnClientIgnoredlDragLobby", resourceRoot, OnClientIgnoredlDragLobby_handler )

function onRaceDragKey_handler( key, state )
    if not IS_DRAG_START or not state then return end
    
    local vehicle = localPlayer.vehicle
    local current_rpm = GetVehicleRPM( vehicle ) / DEF_SETTING.max_rpm

    if key == GEAR_SHIFT_KEY_UP and CURRENT_GEAR ~= 5 then
        cancelEvent()
        if CURRENT_GEAR == 0 then
            current_rpm = NEUTRAL_RPM / DEF_SETTING.max_rpm
            setElementFrozen( localPlayer.vehicle, false )
            toggleControl( "handbrake", true )
            setPedControlState( localPlayer, "handbrake", false )
            removeEventHandler( "onClientPreRender", root, onNeutralRPMCalculate )
            ChangeCurrentGear( vehicle, 1 )
            ResetSpeed( vehicle, true, current_rpm )
        elseif CURRENT_GEAR < 5 then
            ChangeCurrentGear( vehicle, 1 )
            ResetSpeed( vehicle, true, current_rpm )
        end
    elseif key == GEAR_SHIFT_KEY_DOWN and CURRENT_GEAR ~= 0 then
        cancelEvent()
        ChangeCurrentGear( vehicle, -1 )
        ResetSpeed( vehicle, false, current_rpm )
    end
end

function ResetSpeed( vehicle, direction, current_rpm )
    local gear = math.max( 1, CURRENT_GEAR - 1 )
    if GEAR_SETTING[ gear ].zones and direction then
        local switch_type = SWITCH_EARLY
        if current_rpm >= GEAR_SETTING[ gear ].zones.y and current_rpm <= GEAR_SETTING[ gear ].zones.g then
            switch_type = SWITCH_GOOD
        elseif current_rpm >= GEAR_SETTING[ gear ].zones.g and current_rpm <= GEAR_SETTING[ gear ].zones.r then
            switch_type = SWITCH_NICE
        elseif current_rpm >= GEAR_SETTING[ gear ].zones.r then
            switch_type = SWITCH_BAD
        end
        if CURRENT_GEAR ~= 1 then
            SeVehicleSpeed( vehicle, GetVehicleSpeed( vehicle ) - SWITCH_RESULT[ switch_type ].value )
        else
            SeVehicleSpeed( vehicle, SWITCH_RESULT[ switch_type ].start_value )
        end
        ShowDragChangeGearResult( SWITCH_RESULT[ switch_type ].text, SWITCH_RESULT[ switch_type ].color )
    elseif not direction and GetVehicleSpeed( vehicle ) >= 50 then
        SeVehicleSpeed( vehicle, GetVehicleSpeed( vehicle ) - SWITCH_REVERSE )
    end
end

function ChangeCurrentGear( vehicle, direction )
    CURRENT_GEAR = math.max( 1, math.min( CURRENT_GEAR + direction, 5 ) )
    localPlayer.vehicle:setData( "custom_gear", CURRENT_GEAR, false )

    UI_elements.cur_gear:ibData( "text", GEAR_SETTING[ CURRENT_GEAR ].name )
    
    resetVehicleParameters( vehicle )
    local offset_speed = (DEF_SETTING.speed / (6 - CURRENT_GEAR)) + GEAR_SETTING[ CURRENT_GEAR ].gear_coeff[ vehicle:GetTier() ]
    setVehicleParameters( vehicle, offset_speed, DEF_SETTING.accleration + GEAR_SETTING[ CURRENT_GEAR ].accl_coeff[ vehicle:GetTier() ], DEF_SETTING.handling )

    local max_speed = getVehicleHandling( vehicle )[ "maxVelocity" ]
    DEF_SETTING.max_rpm = math.floor( (max_speed + max_speed / 10) * 180 + 0.5 )

    triggerEvent( "onClientDragChangeGear", root, vehicle, { max_rpm = DEF_SETTING.max_rpm * 0.85, gear = CURRENT_GEAR } )
end

function ShowDragChangeGearResult( text, color )
    if UI_elements.interpolate_result then
        UI_elements.interpolate_result:destroy()
    end

    UI_elements.drag_change_gear_result:ibBatchData({ text = text, color = color, alpha = 255 })
    UI_elements.interpolate_result = UI_elements.drag_change_gear_result:ibInterpolate( function( self )
	    	if not isElement( self.element ) then return end

	    	self.easing_value = 1 + 0.2 * self.easing_value
            self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )

            if self.easing_value >= 1 then
                self.element:ibAlphaTo( 0, 500 )
                UI_elements.interpolate_result = nil
            end
	    end, 350, "SineCurve" )
end

function GetVehicleRPM( vehicle )
    if CURRENT_GEAR == 0 then
        return NEUTRAL_RPM 
    end
	return math.floor( GetVehicleSpeed( vehicle ) * 180 + 0.5 )
end

function GetVehicleSpeed( vehicle )
    return math.max( 0.01, ( Vector3( getElementVelocity( vehicle ) ) * 180 ).length )
end

function SeVehicleSpeed( vehicle, speed )
    local c_speed = GetVehicleSpeed( vehicle )
    local diff = speed / c_speed
    local x, y, z = getElementVelocity( vehicle )
    setElementVelocity( vehicle, x * diff, y * diff, z * diff )
end

function GetDestroyDragTime()
	return DRAG_DESTOY_TIME
end

function AddLimitTimeDrag( time )
	DestroyLimitTimeRace( )

	local function formatStr( time )
		local s = math.abs( time )
		local m = math.floor( s / 60 )
		local s = math.floor( s - m * 60 )

		return ( m > 0 and ( m .. " " .. plural( m, "минута", "минуты", "минут" ) .. " " ) or "" ) .. ( s > 0 and ( s .. " " .. plural( s, "секунда", "секунды", "секунд" ) ) or "" )
	end

	UI_elements.timeout = ibCreateArea( 0, 30, 0, 0 )
    
	local lbl_name = ibCreateLabel( 0, 0, 0, 0, time > 10 and "До конца состязания:" or "", UI_elements.timeout, ibApplyAlpha( COLOR_WHITE, 80 ), _, _, "left", "center", ibFonts.bold_20 )
	:ibData( "outline", 1 )

	local lbl_time = ibCreateLabel( lbl_name:ibGetAfterX( 8 ), 0, 0, 0, time > 10 and formatStr( time ) or "", UI_elements.timeout, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_24 )
	:ibData( "timestamp", getRealTimestamp() + time )
	:ibData( "outline", 1 )
	:ibTimer( function( self )
		local timestamp = self:ibData( "timestamp" )
		if timestamp then
			local diff = timestamp - getRealTimestamp()
			if diff <= 10 then
				if isElement( lbl_name ) then
					destroyElement( lbl_name )
					destroyElement( self )
					UI_elements.timeout:ibData( "sx", 0 )
					UI_elements.timeout:ibData( "10_sec_end_timer", true )
					UI_elements.timeout:center( 0, -100 )
					
					ibCreateLabel( 0, -15, 0, 0, "Быстрее!", UI_elements.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
					:ibData( "outline", 1 )
					
					ibCreateLabel( 0, 20, 0, 0, "10.00", UI_elements.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
					:ibData( "alpha", 150 )
					:ibData( "time_tick", time * 1000 )
					:ibData( "outline", 1 )
					:ibTimer( function( self )
						local sheeet, time_tick_count, tick_interval = getTimerDetails( sourceTimer )
						if time_tick_count then
							if time_tick_count <= 1 then
								MODES[ RACE_TYPE_DRAG ].callback_limit_time()
								DestroyLimitTimeRace( )
							else
								local tick = time_tick_count * tick_interval
								local seconds = math.floor( tick / 1000 )
								local ms = math.floor( ( tick - seconds * 1000 ) / 10 )
								if ms < 10 then
									ms = "0"..ms
								end
								self:ibData( "text", seconds ..".".. ms )
							end
						end
					end, 50, 200 )
				end
			else
				self:ibData( "text", formatStr( diff ) )
				UI_elements.timeout:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
			end
		end
	end, 1000, 0 )
	UI_elements.timeout:ibData( "sx", lbl_time:ibGetAfterX( ) ):center_x( )
end

function OnClientRivalFinishDragRace_handler()
    if isTimer( UI_elements.leave_timer ) then
        killTimer( UI_elements.leave_timer )
        AddLimitTimeDrag( 10 )
    end
end
addEvent( "RC:OnClientRivalFinishDragRace", true )
addEventHandler( "RC:OnClientRivalFinishDragRace", resourceRoot, OnClientRivalFinishDragRace_handler )