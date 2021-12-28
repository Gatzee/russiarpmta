loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CActionTasksUtils" )
Extend( "CPlayer" )
Extend( "CAI" )
Extend( "CUI" )
Extend( "ib" )

ibUseRealFonts( true )

ROULETTE_DATA = nil
BACKGROUND_SOUND = nil
COUNT_BALL_PATHS = 1

-------------------------------------------------
-- Функционал механики игры
-------------------------------------------------

function CreateRouletteGame( roulette_data )
    ROULETTE_DATA = {}
    ROULETTE_DATA.casino_id = roulette_data.casino_id
    ROULETTE_DATA.game      = roulette_data.game
    ROULETTE_DATA.currency  = roulette_data.game == CASINO_GAME_CLASSIC_ROULETTE_VIP and "hard" or "soft"
    ROULETTE_DATA.timeout   = getTickCount()
    ROULETTE_DATA.current_state = roulette_data.current_state
    ROULETTE_DATA.time_left_iteration = getTickCount() + roulette_data.time_left_iteration
    
    setCameraMatrix( unpack( CAMERA_POSITIONS[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.current_state ] ) )
    
    DisableHUD( true )
    DisableControls()
    CreateRoulleteUI()
    
    CreateRouletteObjects()
    ChangeRouletteGameState( roulette_data )
    localPlayer:setData( "hide_wanted", true, false )

    BACKGROUND_SOUND = playSound( ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE_VIP and "sfx/bg_vip_sound.ogg" or ":nrp_casino_game_dice/sfx/bg1.ogg", true )
    BACKGROUND_SOUND.volume = 0.35
    UI_elements.rates_count = {}
    
    triggerEvent( "onClientClassicRouletteEnterQuit", root, true )
    triggerEvent( "onClientSetChatState", root, true )
end

function ChangeRouletteGameState( roulette_data )     
    if isElement( ROULETTE_DATA.sound_rotate_dial ) then
        destroyElement( ROULETTE_DATA.sound_rotate_dial )
    end

    if UI_elements and UI_elements.hint then
        UI_elements.hint:destroy()
    end

    if ROULETTE_DATA.current_state ~= roulette_data.current_state then
        ROULETTE_DATA.move_camera = CameraFromTo( CAMERA_POSITIONS[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.current_state ], CAMERA_POSITIONS[ ROULETTE_DATA.casino_id ][ roulette_data.current_state ], TIME_MOVE_CAMERA * 1000, "Linear", function()
            if ROULETTE_DATA.current_state == CR_STATE_RATE then
                ROULETTE_DATA.time_left_iteration = getTickCount() + (DURATION_STATE[ CR_STATE_RATE ] - TIME_MOVE_CAMERA) * 1000
                RATE_DURATION = (DURATION_STATE[ CR_STATE_RATE ] - TIME_MOVE_CAMERA) * 1000
                ChangeUIAccess()
            end
        end )
        
        ROULETTE_DATA.ticks = getTickCount()
        ROULETTE_DATA.current_speed = ROULETTE_DATA.current_speed or DIAL_SPEED[ ROULETTE_DATA.current_state ]
        ROULETTE_DATA.target_speed = DIAL_SPEED[ roulette_data.current_state ]
    else
        ChangeUIAccess()
    end
    ROULETTE_DATA.current_state = roulette_data.current_state
    if ROULETTE_DATA.current_state == CR_STATE_ROTATE_DIAL then
        ROULETTE_DATA.win_field = roulette_data.win_field
        StartMoveBall( roulette_data )
        ChangeUIAccess()

        FixProgressBar()
    elseif ROULETTE_DATA.current_state == CR_STATE_RATE then
        ROULETTE_DATA.top_list = roulette_data.win_list
        RefreshTopUI()

        for k, v in pairs( UI_elements.rates_count or {} ) do
            if isElement( v ) then
                destroyElement( v )
            end
        end
        UI_elements.rates_count = {}

        for k, v in pairs( ROULETTE_DATA.rates_on_field or {} ) do
            v:destroy()
        end
        ROULETTE_DATA.rates_on_field = {}

        ROULETTE_DATA.summ_rate = 0
        ChangeCurrentSummUI( ROULETTE_DATA.summ_rate )

        if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
            if UI_elements.hint then
                UI_elements.hint:destroy()
            end

            UI_elements.hint = CreateSutiationalHint({
                py = scY - 250 * cfY,
                text = "Нажми key=ЛКМ для выбора размера ставки",
                condition = function()
                    return true
                end,
            })
        end
    end
    
    if ROULETTE_DATA.current_chip then
        local sx, sy = 90 * cfX, 90 * cfX
        UI_elements.rates[ ROULETTE_DATA.current_chip ]:ibBatchData({ 
            sx = sx, 
            sy = sy,
            texture = "img/chip_" .. ROULETTE_DATA.currency .. "_" .. ROULETTE_DATA.current_chip .. ".png",
        })
        UI_elements.rates[ ROULETTE_DATA.current_chip .. "lbl" ]:ibBatchData({ sx = sx, sy = sy, font = ibFonts[ "bold_" .. math.ceil( 18 * cfY ) ] })
        ROULETTE_DATA.current_chip = nil
    end
end

function DestroyRouletteGame( is_forced )   
    localPlayer:setData( "hide_wanted", false, false )
    if isElement( BACKGROUND_SOUND ) then
        destroyElement( BACKGROUND_SOUND )
        BACKGROUND_SOUND = nil
    end
    if ROULETTE_DATA and ROULETTE_DATA.move_camera then
        ROULETTE_DATA.move_camera:destroy()
    end

    DisableHUD( false )
    EnableControls()
    DestroyRouletteUI()
    DestroyRouletteObjects()
    
    DestroyTableElements( ROULETTE_DATA )
    ROULETTE_DATA = nil
    
    if not is_forced then
        fadeCamera( false, 0 )
        setTimer(function()
	    	fadeCamera( true, 1 )
	    	setCameraTarget( localPlayer )
        end, 300, 1)
    end
    
    triggerEvent( "onClientClassicRouletteEnterQuit", root, false )
end

function OnTryLeftGame()
    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
    UI_elements.confirmation = ibConfirm({
        title = "ВЫХОД ИЗ ИГРЫ", 
        text = "Ты точно хочешь выйти из игры?\n" .. (next( ROULETTE_DATA.rates_on_field or {} ) and "Твоя ставка будет утеряна!" or ""),
        fn = function( self ) 
            self:destroy()
            triggerServerEvent( "onClassicRouletteTableLeaveRequest", localPlayer, _, _, "exit" )
        end,
        escape_close = true,
    })
end

addEvent( "onClientChangeClassicRouletteState", true )
addEventHandler( "onClientChangeClassicRouletteState", resourceRoot, function( state_data )
    ChangeRouletteGameState( state_data )
end )

-------------------------------------------------
-- Обработчики добавления/удаления ставок
-------------------------------------------------

function OnTryAddRate( roulette_field )
    if ROULETTE_DATA.timeout > getTickCount() or ROULETTE_DATA.current_state ~= CR_STATE_RATE or UI_elements.confirmation then return end
    ROULETTE_DATA.timeout = getTickCount() + TIMEOUT_TIME

    local rate_value = RATES_VALUES[ ROULETTE_DATA.casino_id  ][ ROULETTE_DATA.game ][ ROULETTE_DATA.current_chip ]
    if rate_value and (ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE and not localPlayer:HasMoney( rate_value ) or (ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE_VIP and not localPlayer:HasDonate( rate_value )) ) then
        localPlayer:ShowError( "У Вас недостаточно средств для ставки!" )
        return
    end
    
    local cur_sum = (ROULETTE_DATA.summ_rate or 0 ) + rate_value
    if cur_sum <= MAX_RATES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ] then
        triggerServerEvent( "onServerPlayerTryAddRate", resourceRoot, roulette_field.id, ROULETTE_DATA.current_chip )
    else
        localPlayer:ShowError( "Максимальная ставка " .. format_price( MAX_RATES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ] ) .. "р." )
    end
end

function AddRate( field_id, chip )
    if not ROULETTE_DATA.rates_on_field then
        ROULETTE_DATA.rates_on_field = {}
    end
    
    local rate_item = CreateRateItem( GetRouletteFieldById( field_id ), chip )
    table.insert( ROULETTE_DATA.rates_on_field, rate_item )

    ROULETTE_DATA.summ_rate = (ROULETTE_DATA.summ_rate or 0 ) + RATES_VALUES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ][ chip ]
    ChangeCurrentSummUI( ROULETTE_DATA.summ_rate )
    soundChip()
end

function CreateRateItem( roulette_field, chip )
    local rate_item = roulette_field
    rate_item.chip = chip

    local count_chip_on_field, count_chip_on_table = 0, 0
    for k, v in pairs( ROULETTE_DATA.rates_on_field ) do
        if v.value == rate_item.value then
            count_chip_on_field = count_chip_on_field + 1
        end
        if v.chip == chip then
            count_chip_on_table = count_chip_on_table + 1
        end
    end
    
    rate_item.obj = createObject( 931, rate_item.position[ ROULETTE_DATA.casino_id ] + Vector3( 0, 0, count_chip_on_field * 0.01 ) )
    rate_item.obj.dimension = localPlayer.dimension
    rate_item.obj.interior = localPlayer.interior
    
    if not isElement( UI_elements.rates_count[ chip ] ) then
        local px, py = UI_elements.rates[ chip ]:ibData( "px" ), UI_elements.rates[ chip ]:ibData( "py" )
        local text_sx = dxGetTextWidth( "x" .. count_chip_on_field + 1, 1, ibFonts[ "bold_" .. math.ceil( 16 * cfY ) ] )
        UI_elements.rates_count[ chip ] = ibCreateLabel( px - text_sx / 2, py - 25 * cfY, 100 * cfX, 0, "x", false, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 16 * cfY ) ] )
    end
    UI_elements.rates_count[ chip ]:ibData( "text", "x" .. count_chip_on_table + 1 )
    
    rate_item.destroy = function()
        if isElement( rate_item.obj ) then
            rate_item.obj:destroy()
        end
    end

    return rate_item
end

function OnTryRemoveRate( roulette_field )
    if ROULETTE_DATA.timeout > getTickCount() then return end
    ROULETTE_DATA.timeout = getTickCount() + TIMEOUT_TIME

    local target_index = -1
    for k, v in ipairs( ROULETTE_DATA.rates_on_field ) do
        if roulette_field.id == v.id then
            target_index = k
        end
    end
    if target_index ~= -1 then
        local rate_item = ROULETTE_DATA.rates_on_field[ target_index ]
        triggerServerEvent( "onServerPlayerTryRemoveRate", resourceRoot, rate_item.id, rate_item.chip )
    end
end

function RemoveRate( field_id, chip )
    local target_index = -1
    for k, v in ipairs( ROULETTE_DATA.rates_on_field ) do
        if field_id == v.id then
            target_index = k
        end
    end
    
    if target_index ~= -1 then
        local rate_item = ROULETTE_DATA.rates_on_field[ target_index ]
        table.remove( ROULETTE_DATA.rates_on_field, target_index )
        DestroyTableElements( rate_item )
        
        local remove_button = true
        for k, v in ipairs( ROULETTE_DATA.rates_on_field ) do
            if chip == v.chip then
                remove_button = false
                break
            end
        end
        if remove_button then
            UI_elements.rates_count[ chip ]:destroy()
            UI_elements.rates_count[ chip ] = nil
        else
            local count_chip_on_field, count_chip_on_table = 0, 0
            for k, v in pairs( ROULETTE_DATA.rates_on_field ) do
                if v.id == field_id then
                    setElementPosition( v.obj, v.position[ ROULETTE_DATA.casino_id ] + Vector3(0, 0, count_chip_on_field * 0.01) )
                end
                if v.chip == chip then
                    count_chip_on_table = count_chip_on_table + 1
                end
            end
            UI_elements.rates_count[ chip ]:ibData( "text", "x" .. count_chip_on_table )
        end

        ROULETTE_DATA.summ_rate = ROULETTE_DATA.summ_rate - RATES_VALUES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ][ chip ]
        ChangeCurrentSummUI( ROULETTE_DATA.summ_rate )
        soundChip()
    end
end

addEvent( "onClientSuccessAddRate", true )
addEventHandler( "onClientSuccessAddRate", resourceRoot, function( field_id, chip )
    AddRate( field_id, chip )
end )

addEvent( "onClientSuccessRemoveRate", true )
addEventHandler( "onClientSuccessRemoveRate", resourceRoot, function( field_id, chip )
    RemoveRate( field_id, chip )
end )

addEventHandler( "onClientResourceStop", resourceRoot, function()
    if ROULETTE_DATA then
        DestroyRouletteGame( true )
        fadeCamera( true, 1 )
        setCameraTarget( localPlayer )
    end
end )
