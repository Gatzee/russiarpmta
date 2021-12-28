loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "CPlayer" )

local UI = { }
local timer = nil

ibUseRealFonts( true )

addEvent( "onClientShowDayOffWindow", true )
addEventHandler( "onClientShowDayOffWindow", localPlayer, function ( time_to, is_stop )
    DestroyUIInfo( )

    -- background
    UI.black_bg = ibCreateBackground( nil, DestroyUIInfo, nil, true )

    -- main window
    local bg_path = is_stop and "img/bg_day_off_end.png" or "img/bg_day_off.png"
    UI.bg = ibCreateImage( 0, 0, 0, 0, bg_path, UI.black_bg )
    :ibSetRealSize( ):center( )

    -- close
    UI.button_close = ibCreateButton( 548, 25, 22, 22, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then
            return
        end

        ibClick( )
        DestroyUIInfo( )
    end, false )

    -- stop timer
    if isTimer( timer ) then
        killTimer( timer )
    end

    if is_stop then
        ibCreateLabel( 239, 358, 0, 0, FACTION_DUTY_VALUE_FOR_DAY_OFF, UI.bg,
        nil, nil, nil, "center", "center", ibFonts.bold_20 )
    else
        -- days
        if not time_to then
            time_to = localPlayer:getData( "factions_day_off" ) or 0
        end

        local current_time = getRealTimestamp( )
        local value = math.floor( ( time_to - current_time ) / 3600 )

        local v = nil
        if value > 24 then
            value = math.floor( value / 24 )
            v = plural( value, "день", "дня", "дней" )
        else
            local faction_name = FACTIONS_NAMES[ localPlayer:GetFaction( ) ] or ""
            localPlayer:PhoneNotification( {
                title = "Отгул",
                msg = 'Сегодня твой последний день отгула ("' .. faction_name .. '")! Успей завершить все свои дела.'
            } )
            v = plural( value, "час", "часа", "часов" )
        end

        ibCreateLabel( 302, 209, 0, 0, value, UI.bg,
        nil, nil, nil, "center", "center", ibFonts.bold_60 )

        ibCreateLabel( 302, 250, 0, 0, v, UI.bg,
        nil, nil, nil, "center", "center", ibFonts.bold_16 )

        ibCreateButton( 0, 328, 240, 42, UI.bg, "img/btn_stop", true ):center_x( )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then
                return
            end

            if UI.confirm then
                UI.confirm:destroy( )
            end

            UI.confirm = ibConfirm( {
                title = "ПОДТВЕРЖДЕНИЕ",
                text = "Ты действительно хочешь досрочно завершить отгул?",
                fn = function( self )
                    triggerServerEvent( "PlayerWantStopDayOffFaction", resourceRoot )

                    self:destroy( )
                    DestroyUIInfo( )
                end,
                escape_close = true,
            } )

            ibClick( )
        end )

        -- start timer
        timer = Timer( function ( )
            triggerServerEvent( "PlayerWantStopDayOffFaction", resourceRoot )
        end, ( time_to - current_time ) * 1000, 1 )
    end

    showCursor( true )
end )

function DestroyUIInfo( )
    if isElement( UI.black_bg ) then
        UI.black_bg:destroy( )
    end

    showCursor( false )
end