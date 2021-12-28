
local UI_elements = nil
local cfX, cfY = _SCREEN_X / 1920, _SCREEN_Y / 1080
local RATE_DURATION = nil
local BACKGROUND_SOUND = nil

-------------------------------------------------
-- Config
-------------------------------------------------

local MIN_RATE = 500
local MAX_RATE = 15000

enum "eClassicRouletteRates" {
    "CR_RATE_500",
    "CR_RATE_1000",
    "CR_RATE_2000",
    "CR_RATE_3000",
    "CR_RATE_4000",
    "CR_RATE_5000",
}

local RATES_VALUES =
{
    [ CR_RATE_500  ] = 500,
    [ CR_RATE_1000 ] = 1000,
    [ CR_RATE_2000 ] = 2000,
    [ CR_RATE_3000 ] = 3000,
    [ CR_RATE_4000 ] = 4000,
    [ CR_RATE_5000 ] = 5000,
}

enum "eClassicRouletteStates" {
    "CR_STATE_RATE",
    "CR_STATE_ROTATE_DIAL",
    "CR_STATE_SHOW_RESULTS",
}

local TIME_MOVE_CAMERA = 2
local TIMEOUT_TIME = 200

local DURATION_STATE =
{
    [ CR_STATE_RATE ]         = 25 + TIME_MOVE_CAMERA,
    [ CR_STATE_ROTATE_DIAL ]  = 13,
    [ CR_STATE_SHOW_RESULTS ] = 4,
}

local CAMERA_POSITIONS = 
{
    [ CR_STATE_RATE ]        = { -86.6412, -471.5094, 916.0059, -86.7284, -471.5094, 915.0097, 0, 70 },
    [ CR_STATE_ROTATE_DIAL ] = { -86.6420, -469.4750, 916.1079, -86.7291, -469.4750, 915.1117, 0, 75 },
    [ CR_STATE_SHOW_RESULTS ] = { -86.6420, -469.4750, 916.1079, -86.7291, -469.4750, 915.1117, 0, 75 },
}

local DIAL_SPEED =
{
    [ CR_STATE_RATE ] = 0,
    [ CR_STATE_ROTATE_DIAL ] = 6,
}

enum "eClassicRouletteNumberColors" {
	"CR_BLACK",
	"CR_RED",
    "CR_GREEN",
    "CR_RED_ALL",
    "CR_BLACK_ALL",
}

local COLOR_NAMES = 
{
    [ CR_BLACK ] = "black",
    [ CR_RED ] = "red",
    [ CR_GREEN ] = "green",
}

local ROULETTE_FIELDS =
{
    { id = 1,  value = 0,  type = CR_GREEN,     position = Vector3( -86.453048400879 - 0.1, -471.51177612305, 913.91497802734 ), ring_id = 28 },
    { id = 2,  value = 3,  type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -472.51678466797, 913.91497802734 ), ring_id = 26 },
    { id = 3,  value = 6,  type = CR_BLACK,     position = Vector3( -87.353050231934 - 0.1, -472.33377075195, 913.91497802734 ), ring_id = 1 },
    { id = 4,  value = 9,  type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -472.15078735352, 913.91497802734 ), ring_id = 18 },
    { id = 5,  value = 12, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -471.96777343751, 913.91497802734 ), ring_id = 24 },
    { id = 6,  value = 15, type = CR_BLACK,     position = Vector3( -87.353050231934 - 0.1, -471.78479003906, 913.91497802734 ), ring_id = 30 },
    { id = 7,  value = 18, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -471.60177612305, 913.91497802734 ), ring_id = 20 },
    { id = 8,  value = 21, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -471.41879272461, 913.91497802734 ), ring_id = 33 },
    { id = 9,  value = 24, type = CR_BLACK,     position = Vector3( -87.353050231934 - 0.1, -471.23577880859, 913.91497802734 ), ring_id = 11 },
    { id = 10, value = 27, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -471.05279541016, 913.91497802734 ), ring_id = 2  },
    { id = 11, value = 30, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -470.86978149414, 913.91497802734 ), ring_id = 6  },
    { id = 12, value = 33, type = CR_BLACK,     position = Vector3( -87.353050231934 - 0.1, -470.68679809572, 913.91497802734 ), ring_id = 13 },
    { id = 13, value = 36, type = CR_RED,       position = Vector3( -87.353050231934 - 0.1, -470.50378417969, 913.91497802734 ), ring_id = 4  },
    { id = 14, value = 2,  type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -472.51678466797, 913.91497802734 ), ring_id = 34 },
    { id = 15, value = 5,  type = CR_RED,       position = Vector3( -87.063049316406 - 0.1, -472.33377075195, 913.91497802734 ), ring_id = 10 },
    { id = 16, value = 8,  type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -472.15078735352, 913.91497802734 ), ring_id = 7  },
    { id = 17, value = 11, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -471.96777343751, 913.91497802734 ), ring_id = 5  },
    { id = 18, value = 14, type = CR_RED,       position = Vector3( -87.063049316406 - 0.1, -471.78479003906, 913.91497802734 ), ring_id = 16 },
    { id = 19, value = 17, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -471.60177612305, 913.91497802734 ), ring_id = 36 },
    { id = 20, value = 20, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -471.41879272461, 913.91497802734 ), ring_id = 15 },
    { id = 21, value = 23, type = CR_RED,       position = Vector3( -87.063049316406 - 0.1, -471.23577880859, 913.91497802734 ), ring_id = 8  },
    { id = 22, value = 26, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -471.05279541016, 913.91497802734 ), ring_id = 27 },
    { id = 23, value = 29, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -470.86978149414, 913.91497802734 ), ring_id = 21 },
    { id = 24, value = 32, type = CR_RED,       position = Vector3( -87.063049316406 - 0.1, -470.68679809572, 913.91497802734 ), ring_id = 29 },
    { id = 25, value = 35, type = CR_BLACK,     position = Vector3( -87.063049316406 - 0.1, -470.50378417969, 913.91497802734 ), ring_id = 25 },
    { id = 26, value = 1,  type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -472.51678466797, 913.91497802734 ), ring_id = 14 },
    { id = 27, value = 4,  type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -472.33377075195, 913.91497802734 ), ring_id = 32 },
    { id = 28, value = 7,  type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -472.15078735352, 913.91497802734 ), ring_id = 22 },
    { id = 29, value = 10, type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -471.96777343751, 913.91497802734 ), ring_id = 9  },
    { id = 30, value = 13, type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -471.78479003906, 913.91497802734 ), ring_id = 3  },
    { id = 31, value = 16, type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -471.60177612305, 913.91497802734 ), ring_id = 12 },
    { id = 32, value = 19, type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -471.41879272461, 913.91497802734 ), ring_id = 31 },
    { id = 33, value = 22, type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -471.23577880859, 913.91497802734 ), ring_id = 19 },
    { id = 34, value = 25, type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -471.05279541016, 913.91497802734 ), ring_id = 35 },
    { id = 35, value = 28, type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -470.86978149414, 913.91497802734 ), ring_id = 23 },
    { id = 36, value = 31, type = CR_BLACK,     position = Vector3( -86.773048400879 - 0.1, -470.68679809572, 913.91497802734 ), ring_id = 17 },
    { id = 37, value = 34, type = CR_RED,       position = Vector3( -86.773048400879 - 0.1, -470.50378417969, 913.91497802734 ), ring_id = 37 },
 
    { id = 38, value = 37, type = CR_RED_ALL,   position = Vector3( -86.453048400879 - 0.1, -472.12078735352, 913.91497802734 ) },
    { id = 39, value = 38, type = CR_BLACK_ALL, position = Vector3( -86.453048400879 - 0.1, -470.91978149414, 913.91497802734 ) },
}

-------------------------------------------------
-- Utils
-------------------------------------------------

function GetRouletteFieldById( field_id )
    for k, v in pairs( ROULETTE_FIELDS ) do
        if k == field_id then
            return table.copy( v )
        end
    end
    return false
end

function GetRouletteFieldByPosition( target_pos )
    local available_fields = {}
    for k, v in pairs( ROULETTE_FIELDS ) do
        local distance_between_points = getDistanceBetweenPoints3D( target_pos, v.position )
        if distance_between_points <= 0.15 then
            table.insert( available_fields, { id = k, distance = distance_between_points } )
        end
    end
    table.sort( available_fields, function( a, b )
        return a.distance < b.distance
    end )
    if #available_fields > 0 then
        return table.copy( ROULETTE_FIELDS[ available_fields[ 1 ].id ] )
    end
    return false
end

-------------------------------------------------
-- entry point
-------------------------------------------------
local GAME_CALLBACK

function CreateRouletteGame( callback )
    GAME_CALLBACK = callback

    ROULETTE_DATA = {}
    ROULETTE_DATA.timeout = getTickCount()
    ROULETTE_DATA.current_state = CR_STATE_RATE
    ROULETTE_DATA.time_left_iteration = getTickCount() + DURATION_STATE[ CR_STATE_RATE ] * 1000
    
    setCameraMatrix( unpack( CAMERA_POSITIONS[ CR_STATE_RATE ] ) )
    
    DisableHUD( true )
    DisableControls()
    CreateRoulleteUI()
    
    CreateRouletteObjects()
    ChangeRouletteGameState( ROULETTE_DATA )
    localPlayer:setData( "hide_wanted", true, false )

    BACKGROUND_SOUND = playSound( ":nrp_casino_game_dice/sfx/bg1.ogg",true )
    BACKGROUND_SOUND.volume = 0.35
    UI_elements.rates_count = {}
    
    triggerEvent( "onClientClassicRouletteEnterQuit", root, true )
    triggerEvent( "onClientSetChatState", root, true )

    fadeCamera( true, 0.5 )
    StartFakeGame()
end

function StartFakeGame()
    UI_elements.rotate_dial_tmr = setTimer( function()
        local win_field = math.random( 1, 39 )
        local rotate_duration = DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000 + 500
        ChangeRouletteGameState({
            current_state = CR_STATE_ROTATE_DIAL,
            time_left_iteration = rotate_duration,
            win_field = win_field
        } )
    
        UI_elements.result_tmr = setTimer( function()
            
            if ROULETTE_DATA.summ_rate > 0 then
                local is_win = false
                local win_amount = GetWinningAmount( win_field )

                local result_rate = {
                    win_amount = win_amount,
                    is_win = win_amount > 0 and true or false,
                }

                if result_rate.is_win then
                    ShowRouletteSuccessRate( result_rate )
                elseif not result_rate.is_win then
                    ShowRouletteFailRate( result_rate )
                end
                UI_elements.end_tmr = setTimer( DestroyRouletteGame, DURATION_STATE[ CR_STATE_SHOW_RESULTS ] * 1000, 1, true )
            else
                DestroyRouletteGame( true )
            end
        end, rotate_duration, 1 )
    end, DURATION_STATE[ CR_STATE_RATE ] * 1000, 1 )
end

function ChangeRouletteGameState( state_data )     
    if isElement( ROULETTE_DATA.sound_rotate_dial ) then
        destroyElement( ROULETTE_DATA.sound_rotate_dial )
    end

    if UI_elements and UI_elements.hint then
        UI_elements.hint:destroy()
    end

    if ROULETTE_DATA.current_state ~= state_data.current_state then
        ROULETTE_DATA.move_camera = CameraFromTo( CAMERA_POSITIONS[ ROULETTE_DATA.current_state ], CAMERA_POSITIONS[ state_data.current_state ], TIME_MOVE_CAMERA * 1000, "Linear", function()
            if ROULETTE_DATA.current_state == CR_STATE_RATE then
                ROULETTE_DATA.time_left_iteration = getTickCount() + (DURATION_STATE[ CR_STATE_RATE ] - TIME_MOVE_CAMERA) * 1000
                RATE_DURATION = (DURATION_STATE[ CR_STATE_RATE ] - TIME_MOVE_CAMERA) * 1000
                ChangeRouletteUIAccess()
            end
        end )
        
        ROULETTE_DATA.ticks = getTickCount()
        ROULETTE_DATA.current_speed = ROULETTE_DATA.current_speed or DIAL_SPEED[ ROULETTE_DATA.current_state ]
        ROULETTE_DATA.target_speed = DIAL_SPEED[ state_data.current_state ]
    else
        ChangeRouletteUIAccess()
    end
    ROULETTE_DATA.current_state = state_data.current_state
    if ROULETTE_DATA.current_state == CR_STATE_ROTATE_DIAL then
        ROULETTE_DATA.win_field = state_data.win_field
        StartRouletteMoveBall( state_data )
        ChangeRouletteUIAccess()

        FixRouletteProgressBar()
    elseif ROULETTE_DATA.current_state == CR_STATE_RATE then
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
        ChangeRouletteCurrentSummUI( ROULETTE_DATA.summ_rate )

        if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
            if UI_elements.hint then
                UI_elements.hint:destroy()
            end

            UI_elements.hint = CreateSutiationalHint({
                py = _SCREEN_Y - 250 * cfY,
                text = "Нажми key=ЛКМ для выбора размера ставки",
                condition = function()
                    return true
                end,
            })
        end
    end
    
    if ROULETTE_DATA.current_chip then
        UI_elements.rates[ ROULETTE_DATA.current_chip ]:ibBatchData({ 
            sx = 90 * cfX, 
            sy = 90 * cfX,
            texture = ":nrp_casino_game_classic_roulette/img/chip_" .. RATES_VALUES[ ROULETTE_DATA.current_chip ] .. ".png",
        })
        ROULETTE_DATA.current_chip = nil
    end
end

function DestroyRouletteGame( success )   
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

    if GAME_CALLBACK then
        fadeCamera( false, 0.5 )
        setTimer(function()
            if success then GAME_CALLBACK() end
            GAME_CALLBACK = nil

            setCameraTarget( localPlayer )
            fadeCamera( true, 0.5 )
        end, 500, 1)
    end
    
    triggerEvent( "onClientClassicRouletteEnterQuit", root, false )
end

-------------------------------------------------
-- Функционал отображения UI
-------------------------------------------------

function CreateRoulleteUI()
    DestroyRouletteUI()
    UI_elements = {}
    
    RATE_DURATION = DURATION_STATE[ CR_STATE_RATE ] * 1000
    
    UI_elements.help_cur_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - cfY * 152, 0, 0, "сделанная ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.cur_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - cfY * 135, 0, 0, "0", false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.cur_soft_img = ibCreateImage( cfX * 41 + dxGetTextWidth( "0", 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), _SCREEN_Y - 130 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_game_classic_roulette/img/soft.png" )
    
    UI_elements.line_rate = ibCreateImage( 35 * cfX, _SCREEN_Y - 105 * cfY, 104 * cfX, 1, _, _, 0x16FFFFFF )

    local min_price = format_price( MIN_RATE )
    UI_elements.help_min_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - 100 * cfY, 0, 0, "мин.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.min_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - 85 * cfY, 0, 0, min_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.min_soft_img = ibCreateImage( cfX * 41 + dxGetTextWidth( min_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), _SCREEN_Y - 80 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_game_classic_roulette/img/soft.png" )
    
    local max_price = format_price( MAX_RATE )
    UI_elements.help_max_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - 58 * cfY, 0, 0, "макс.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.max_lbl = ibCreateLabel( cfX * 35, _SCREEN_Y - 45 * cfY, 0, 0, max_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.max_soft_img = ibCreateImage( cfX * 41 + dxGetTextWidth( max_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), _SCREEN_Y - 40 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_game_classic_roulette/img/soft.png" )
    
    local px = (_SCREEN_X - 695 * cfX) / 2
    UI_elements.bg_progress_bar = ibCreateImage( px, _SCREEN_Y - 199 * cfY, 695 * cfX, 20 * cfY, ":nrp_casino_game_classic_roulette/img/bg_progress_bar.png" )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 695 * cfX, 20 * cfY, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )
    UI_elements.progress_bar_caret = ibCreateImage( 0, 0, 2 * cfX, 20 * cfY, _, UI_elements.bg_progress_bar, 0xFF9E9395 )
    :ibOnRender( function()
        if not ROULETTE_DATA.time_left_iteration or ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end

        local fProgress = (ROULETTE_DATA.time_left_iteration - getTickCount()) / RATE_DURATION
        if fProgress <= 1 then
            local size_x = interpolateBetween( 0, 0, 0, 695 * cfX, 0, 0, fProgress, "Linear" )
            UI_elements.progress_bar_caret:ibBatchData( {
                px = 696 * cfX - size_x,
            })
            UI_elements.progress_bar:ibBatchData( {
                px = 696 * cfX - size_x,
                sx = size_x,
            })
        end
    end )
    UI_elements.timer_icon = ibCreateImage( px - 44 * cfX, _SCREEN_Y - 205 * cfY, 24 * cfX, 28 * cfY, ":nrp_casino_game_classic_roulette/img/timer_icon.png")
    UI_elements.rate_size = ibCreateImage( _SCREEN_X - 276 * cfX, _SCREEN_Y - 239 * cfY, 256 * cfX, 139 * cfY, ":nrp_casino_game_classic_roulette/img/bg_reward_size.png" )
    UI_elements.info_access = ibCreateImage( (_SCREEN_X - 263 * cfX) / 2, 25 * cfY, 263 * cfX, 95 * cfY, ":nrp_casino_game_classic_roulette/img/text_rate_on.png" ):ibSetRealSize()

     UI_elements.rates = {}
     for k, v in ipairs( RATES_VALUES ) do
        UI_elements.rates[ k ] = ibCreateImage( px, _SCREEN_Y - 140 * cfY, 90 * cfX, 90 * cfX, ":nrp_casino_game_classic_roulette/img/chip_" .. v .. ".png" )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()

                TryRouletteRate( k, v )
            end )
        px = px + 122 * cfX
     end
     
     showCursor( true )
end

function DestroyRouletteUI()
    if UI_elements then
        DestroyTableElements( UI_elements )
        UI_elements = nil
    end
    showCursor( false )
end

function TryRouletteRate( chip, chip_value )
    if ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end

    local size_coeff = 0
    if chip == ROULETTE_DATA.current_chip then
        ROULETTE_DATA.current_chip = nil
    else
        if ROULETTE_DATA.current_chip then
            UI_elements.rates[ ROULETTE_DATA.current_chip ]:ibBatchData({ 
                sx = 90 * cfX, sy = 90 * cfX,
                texture = ":nrp_casino_game_classic_roulette/img/chip_" .. RATES_VALUES[ ROULETTE_DATA.current_chip ] .. ".png",
            })
        end
        ROULETTE_DATA.current_chip = chip
        size_coeff = 10 * cfX
    end

    if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
        if UI_elements.hint then
            UI_elements.hint:destroy()
        end
        UI_elements.hint = CreateSutiationalHint({
            py = _SCREEN_Y - 250 * cfY,
            text = "Нажми key=ЛКМ для выбора на какое число поставить",
            condition = function()
                return true
            end,
        })
    end

    UI_elements.rates[ chip ]:ibBatchData({ 
        sx = 90 * cfX + size_coeff, sy = 90 * cfX + size_coeff,
        texture = ROULETTE_DATA.current_chip and ":nrp_casino_game_classic_roulette/img/chip_" .. chip_value .. "_active.png" or ":nrp_casino_game_classic_roulette/img/chip_" .. chip_value .. ".png",
    })
end

function ChangeRouletteCurrentSummUI( summ )
    local rate = format_price ( summ )
    UI_elements.cur_lbl:ibData( "text", rate )
    UI_elements.cur_soft_img:ibData( "px", cfX * 41 + dxGetTextWidth( rate, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ) )
end

function FixRouletteProgressBar()
    UI_elements.progress_bar_caret:ibBatchData( {
        px = 0,
    })
    UI_elements.progress_bar:ibBatchData( {
        px = 0,
        sx = 696,
    })
end

function ChangeRouletteUIAccess()
    if UI_elements then
        UI_elements.info_access:ibData( "texture", ROULETTE_DATA.current_state == CR_STATE_RATE and ":nrp_casino_game_classic_roulette/img/text_rate_on.png" or ":nrp_casino_game_classic_roulette/img/text_rate_off.png" )
        UI_elements.bg_progress_bar:ibData( "alpha", ROULETTE_DATA.current_state == CR_STATE_RATE and 255 or 0 )
        UI_elements.timer_icon:ibData( "alpha", ROULETTE_DATA.current_state == CR_STATE_RATE and 255 or 0 )
    end
end

function OnTryRouletteAddRate( roulette_field )
    local cur_sum = (ROULETTE_DATA.summ_rate or 0 ) + RATES_VALUES[ ROULETTE_DATA.current_chip ]
    if cur_sum <= MAX_RATE then
        if not ROULETTE_DATA.rates_on_field then ROULETTE_DATA.rates_on_field = {} end
        
        local rate_item = CreateRouletteRateItem( GetRouletteFieldById( roulette_field.id ), ROULETTE_DATA.current_chip )
        table.insert( ROULETTE_DATA.rates_on_field, rate_item )
    
        ROULETTE_DATA.summ_rate = (ROULETTE_DATA.summ_rate or 0 ) + RATES_VALUES[ ROULETTE_DATA.current_chip ]
        ChangeRouletteCurrentSummUI( ROULETTE_DATA.summ_rate )
        soundChip()
    else
        localPlayer:ShowError( "Максимальная ставка " .. MAX_RATE .. "р." )
    end
end

function OnTryRemoveRouletteRate( roulette_field )
    local target_index = -1
    for k, v in ipairs( ROULETTE_DATA.rates_on_field ) do
        if roulette_field.id == v.id then
            target_index = k
        end
    end
    if target_index ~= -1 then
        local rate_item = ROULETTE_DATA.rates_on_field[ target_index ]
        RemoveRouletteRate( roulette_field.id, ROULETTE_DATA.current_chip )
    end
end

function RemoveRouletteRate( field_id, chip )
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
                    setElementPosition( v.obj, v.position + Vector3(0, 0, count_chip_on_field * 0.01) )
                end
                if v.chip == chip then
                    count_chip_on_table = count_chip_on_table + 1
                end
            end
            UI_elements.rates_count[ chip ]:ibData( "text", "x" .. count_chip_on_table )
        end

        ROULETTE_DATA.summ_rate = ROULETTE_DATA.summ_rate - RATES_VALUES[ chip ]
        ChangeRouletteCurrentSummUI( ROULETTE_DATA.summ_rate )
        soundChip()
    end
end

-------------------------------------------------
-- Result Data
-------------------------------------------------

function ShowRouletteSuccessRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end

    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_game_classic_roulette/img/bg_green.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfY, _SCREEN_X, 26 * cfY, ":nrp_casino_game_classic_roulette/img/green_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 26 * cfY, "ВЫ ПОБЕДИЛИ", UI_elements.text_effect_result, 0xFF54FF68, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (_SCREEN_X - 939 * cfX) / 2, _SCREEN_Y - 500 * cfY, 939 * cfX, 416 * cfY, ":nrp_casino_game_classic_roulette/img/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ПОЗДРАВЛЯЕМ! ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (_SCREEN_X - 120 * cfX) / 2, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfX, ":nrp_casino_game_classic_roulette/img/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, ":nrp_casino_game_classic_roulette/img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.win_amount ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    
    local ok_texture = ":nrp_casino_game_classic_roulette/img/btn_ok.png"
    local ok_hover_texture = ":nrp_casino_game_classic_roulette/img/btn_ok_hovered.png"
    ibCreateButton( (_SCREEN_X - 100 * cfX) / 2, _SCREEN_Y - 95 * cfY, 100 * cfX, 54 * cfY, UI_elements.black_bg_result, ok_texture, ok_hover_texture, ok_hover_texture )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            destroyElement( UI_elements.black_bg_result )
        end )

    UI_elements.info_access:ibData( "alpha", 0 )
    ibGetRewardSound()
end

function ShowRouletteFailRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_game_classic_roulette/img/bg_red.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, _SCREEN_X, 26 * cfY, ":nrp_casino_game_classic_roulette/img/red_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 26 * cfY, "ВЫ ПРОИГРАЛИ", UI_elements.text_effect_result, 0xFFD42D2D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    local ok_texture = ":nrp_casino_game_classic_roulette/img/btn_ok.png"
    local ok_hover_texture = ":nrp_casino_game_classic_roulette/img/btn_ok_hovered.png"
    ibCreateButton( (_SCREEN_X - 100 * cfX) / 2, _SCREEN_Y - 95 * cfY, 100 * cfX, 54 * cfY, UI_elements.black_bg_result, ok_texture, ok_hover_texture, ok_hover_texture )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            destroyElement( UI_elements.black_bg_result )
        end )
    UI_elements.info_access:ibData( "alpha", 0 )
end

-------------------------------------------------
-- Objects Data
-------------------------------------------------

INTERACTIVE_OBJECTS = nil
ROULETTE_OBJECTS_DATA = 
{
    ring_dial =       { id = 922, pos = Vector3( -86.992027, -469.47507, 914.008 ) },
    dial =            { id = 923, pos = Vector3( -86.991203, -469.47507, 914.182 ) },
    ball =            { id = 925, pos = Vector3( -86.992027, -469.47507, 914.008 ) },
    roulette_fields = { id = 930, pos = Vector3( -86.991282, -471.50942, 913.906 ) },
}

START_NUMBERS = 
{
    { field_id = 3, rotation = 12  },
    { field_id = 5, rotation = 10  },
    { field_id = 13, rotation = 13 },
    { field_id = 17, rotation = 13 },
}

CENTER_RING_START_POSITION = Vector3( -86.992027, -469.47507, 914.15 )
CENTER_RING_START_POSITION_CF = 0.44

CENTER_RING_FIELD_POSITION = Vector3( -86.992027, -469.47507, 914.04 )
CENTER_RING_FIELD_POSITION_CF = 0.299

DIAL_SPEED_ROTATION = 1.3
BALL_SPEED_ROTATION = 2.5

function CreateRouletteObjects()    
    INTERACTIVE_OBJECTS = {}
    for k, v in pairs( ROULETTE_OBJECTS_DATA ) do
        INTERACTIVE_OBJECTS[ k ] = createObject( v.id, v.pos )
        INTERACTIVE_OBJECTS[ k ].dimension = localPlayer.dimension
        INTERACTIVE_OBJECTS[ k ].interior  = localPlayer.interior
    end

    removeEventHandler( "onClientClick", root, OnClickOnRouletteField )
    addEventHandler( "onClientClick", root, OnClickOnRouletteField )
end

function StartRouletteMoveBall( state_data )
    ROULETTE_DATA.ball_sound = playSound( ":nrp_casino_game_classic_roulette/sfx/ball_sound.mp3" )
    ROULETTE_DATA.ball_sound.volume = 0.8
    
    ROULETTE_DATA.end_ticks = getTickCount() + state_data.time_left_iteration
    ROULETTE_DATA.dial_data = START_NUMBERS[ math.random( 1, #START_NUMBERS ) ]
    ROULETTE_DATA.end_rotation = ROULETTE_DATA.dial_data.rotation + GetRotationByFieldId( state_data.win_field )
    ROULETTE_DATA.offset = math.random( 1, 4 )  * 90 + ROULETTE_DATA.dial_data.field_id * math.random(15, 30)


    local fProgress = 1 - (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000)
    ROULETTE_DATA.start_rotation, ROULETTE_DATA.last_z = interpolateBetween( ROULETTE_DATA.offset, CENTER_RING_START_POSITION.z, 0, ROULETTE_DATA.offset + 360 * 4, CENTER_RING_START_POSITION.z, 0, fProgress, "Linear" )

    removeEventHandler( "onClientPreRender", root, onRenderObjects )
    addEventHandler( "onClientPreRender", root, onRenderObjects ) 
end

function onRenderObjects( time_slice )
    local fProgress = 1 - (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000)
    if fProgress > 0 and fProgress <= 1 then
        local dial_speed_rotation = GetRouletteDialData( fProgress )
        local ball_speed_rotation, move_dist_cf, ball_z = GetRouletteBallData( fProgress )

        INTERACTIVE_OBJECTS.dial.rotation = Vector3( 0, 0, dial_speed_rotation )
        INTERACTIVE_OBJECTS.ball.rotation = Vector3( 0, 0, ball_speed_rotation )
        INTERACTIVE_OBJECTS.ball.position = Vector3(CENTER_RING_START_POSITION.x, CENTER_RING_START_POSITION.y, ball_z) + Vector3(math.cos( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * move_dist_cf, math.sin( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * move_dist_cf, 0)
    else
        INTERACTIVE_OBJECTS.dial.rotation = Vector3( 0, 0, INTERACTIVE_OBJECTS.dial.rotation.z - time_slice / 15 )
        INTERACTIVE_OBJECTS.ball.rotation = Vector3( 0, 0, INTERACTIVE_OBJECTS.ball.rotation.z - time_slice / 15 )
        INTERACTIVE_OBJECTS.ball.position = Vector3(CENTER_RING_START_POSITION.x, CENTER_RING_START_POSITION.y, INTERACTIVE_OBJECTS.ball.position.z) + Vector3(math.cos( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * CENTER_RING_FIELD_POSITION_CF, math.sin( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * CENTER_RING_FIELD_POSITION_CF, 0)
    end
end

function GetRotationByFieldId( field_id )
    local step = 360 / 37
    return ROULETTE_FIELDS[ field_id ].ring_id * step - step
end

function GetRouletteBallData( fProgress )
    local ball_speed_rotation, ball_z = interpolateBetween( ROULETTE_DATA.offset, CENTER_RING_START_POSITION.z, 0, ROULETTE_DATA.offset + 360 * 4, CENTER_RING_FIELD_POSITION.z, 0, fProgress, "Linear" )
    local move_dist_cf = CENTER_RING_START_POSITION_CF
    if fProgress > 0.925 then
        local dProgress = (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000 * 0.075)
        move_dist_cf = interpolateBetween( CENTER_RING_FIELD_POSITION_CF, 0, 0, CENTER_RING_START_POSITION_CF, 0, 0, dProgress, "Linear" )
    end
    return ball_speed_rotation, move_dist_cf, ball_z
end

function GetRouletteDialData( fProgress )
    local dial_speed_rotation = interpolateBetween( ROULETTE_DATA.offset + 360 * 4 + ROULETTE_DATA.end_rotation, 0, 0, ROULETTE_DATA.offset + ROULETTE_DATA.end_rotation, 0, 0, fProgress, "Linear" )
    return dial_speed_rotation
end

function OnClickOnRouletteField( button, state, _, _, wx, wy, wz )
    if not ROULETTE_DATA or ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end

    if button == "left" and state == "down" then
        local roulette_field = GetRouletteFieldByPosition( Vector3( wx, wy, wz ) )
        if roulette_field then
            if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
                local file = fileCreate( CASINO_GAME_CLASSIC_ROULETTE ) 
                fileClose( file ) 
                if UI_elements.hint then
                    UI_elements.hint:destroy()
                end
                
                UI_elements.hint_return_rate = ibCreateImage( (_SCREEN_X - 402 * cfX) / 2, _SCREEN_Y - 250 * cfY, 402, 34, ":nrp_casino_game_classic_roulette/img/hint1.png" )
                ROULETTE_DATA.time_hide_hint = setTimer( function()
                    UI_elements.hint_return_rate:ibAlphaTo( 0, 250 )
                    ROULETTE_DATA.time_hide_hint = setTimer( function()
                        UI_elements.hint_return_rate:destroy()
                    end, 250, 1 )
                end, 5000, 1 )
            end

            if ROULETTE_DATA.current_chip then
                OnTryRouletteAddRate( roulette_field )
            end
        end
    elseif button == "right" and state == "down" then
        local roulette_field = GetRouletteFieldByPosition( Vector3( wx, wy, wz ) )
        if roulette_field and ROULETTE_DATA then
            OnTryRemoveRouletteRate( roulette_field )
            if isTimer( ROULETTE_DATA.time_hide_hint ) then
                killTimer( ROULETTE_DATA.time_hide_hint )
                UI_elements.hint_return_rate:destroy()
            end
        end
    end
end

function CreateRouletteRateItem( roulette_field, chip )
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
    
    rate_item.obj = createObject( 931, rate_item.position + Vector3( 0, 0, count_chip_on_field * 0.01 ) )
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

function DestroyRouletteObjects()
    removeEventHandler( "onClientClick", root, OnClickOnRouletteField )
    removeEventHandler( "onClientPreRender", root, onRenderObjects )
    for k, v in pairs( INTERACTIVE_OBJECTS or {} ) do
        if isElement( v ) then
            destroyElement( v )
        end
    end
    INTERACTIVE_OBJECTS = nil
end

function GetWinningAmount( win_field_id )
    local amount = 0
    local win_field = ROULETTE_FIELDS[ win_field_id ]
    for k, v in pairs( ROULETTE_DATA.rates_on_field ) do
        if (v.type == CR_RED_ALL and win_field.type == CR_RED) or (v.type == CR_BLACK_ALL and win_field.type == CR_BLACK) then
            amount = amount + RATES_VALUES[ v.chip ] * 2
        elseif v.id == win_field.id then
            amount = amount + RATES_VALUES[ v.chip ] * 35
        end
    end
    return math.ceil( amount )
end