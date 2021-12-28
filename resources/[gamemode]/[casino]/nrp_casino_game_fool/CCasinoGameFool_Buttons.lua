---------------------------------------
----- Кнопки управления действиями -----
---------------------------------------

BUTTONS = {
    { 
        id = "btn_take",
        image = "img/btn_take.png",
        px = 680, py = 458,
        sx = 100, sy = 44,
        check_fn = function( )
            return CURRENT_PLAYER_TARGET == localPlayer
        end,
        event = "onCasinoGameFoolTakeRequest",
    },

    { 
        id = "btn_drop",
        image = "img/btn_drop.png",
        px = 680, py = 516,
        sx = 100, sy = 44,
        check_fn = function( )
            return CURRENT_PLAYER_TURN == localPlayer
        end,
        event = "onCasinoGameFoolDropRequest",
    },
}

function CreateButtons( )
    RemoveButtons( )

    if not isElement( UI_elements.bg ) then return end

    for i, v in pairs( table.copy( BUTTONS ) ) do
        local button = ibCreateButton(  v.px, v.py, v.sx, v.sy, UI_elements.bg, 
                                        v.image, v.image, v.image, 
                                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        button:ibData( "color_disabled", 0X77aaaaaa )
        UI_elements[ "buttons_row_" .. v.id ] = button

        addEventHandler( "ibOnElementMouseClick", button, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            if v.last_click and getTickCount() - v.last_click <= 3500 then
                return
            end
            --iprint( "event triggered", getTickCount() )
            v.last_click = getTickCount()
            triggerEvent( v.event, root )
        end, false )
    end

    UpdateButtons( )
end

function UpdateButtons( )
    for i, v in pairs( BUTTONS ) do
        local button = UI_elements[ "buttons_row_" .. v.id ]
        if isElement( button ) then
            local check_fn = v.check_fn()
            button:ibData( "disabled", not check_fn )
        end
    end
end

function RemoveButtons( )
    for i, v in pairs( BUTTONS ) do
        local button = UI_elements[ "buttons_row_" .. v.id ]
        if isElement( button ) then destroyElement( button ) end
    end
end

function onCasinoGameFoolTakeRequest_handler( )
    triggerServerEvent( "onCasinoGameFoolTakeRequestServerside", localPlayer )
end
addEvent( "onCasinoGameFoolTakeRequest", true )
addEventHandler( "onCasinoGameFoolTakeRequest", root, onCasinoGameFoolTakeRequest_handler )

function onCasinoGameFoolDropRequest_handler( )
    triggerServerEvent( "onCasinoGameFoolDropRequestServerside", localPlayer )
end
addEvent( "onCasinoGameFoolDropRequest", true )
addEventHandler( "onCasinoGameFoolDropRequest", root, onCasinoGameFoolDropRequest_handler )