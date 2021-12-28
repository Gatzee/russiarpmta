loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )

function ShowInfoUI( state )
    if state then
        ShowInfoUI( false )
        Extend( "ib" )

        UI_elements = { }
        local x, y = guiGetScreenSize()

        UI_elements.black_bg    = ibCreateBackground( _, _, 0xaa000000 )
        UI_elements.bg_texture  = dxCreateTexture( "img/bg.png" )

        local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2

        local elastic_duration  = 2200
        local alpha_duration    = 700
        UI_elements.bg = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )

        UI_elements.button_close = ibCreateButton(  sx - 24 - 26, 26, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.button_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowInfoUI( false )
        end, false )

        local sections = {
            { 20, 190 },
            { 280, 190 },
            { 540, 190 }
        }
        for i = 1, 3 do
            local px, py = unpack( sections[ i ] )
            local img = ibCreateImage( px, py, 240, 350, "img/" .. i .. ".png", UI_elements.bg ):ibData( "alpha", 0 )
            setTimer( function( ) img:ibAlphaTo( 200, 300 ) end, 100 + i * 300, 1 )
            addEventHandler( "ibOnElementMouseEnter", img, function( )
                if img:ibData( "alpha" ) ~= 0 then
                    img:ibAlphaTo( 255, 200 )
                end
            end, false )

            addEventHandler( "ibOnElementMouseLeave", img, function( )
                if img:ibData( "alpha" ) ~= 0 then
                    img:ibAlphaTo( 200, 200 )
                end
            end, false )
        end

        UI_elements.bg:ibMoveTo( px, py, elastic_duration, "OutElastic" ):ibAlphaTo( 255, alpha_duration )
        UI_elements.cursor_timer = setTimer( function( ) showCursor( true ) end, 1000, 1 )
    else
        for i, v in pairs( UI_elements or { } ) do
            if isTimer( v ) then killTimer( v ) end
            if isElement( v ) then destroyElement( v ) end
        end
        UI_elements = nil
        showCursor( false )
    end
end

function onClientPlayerNRPSpawn_handler( spawn_mode )
    if spawn_mode == 3 then return end
    if localPlayer:GetLevel() < 2 then return end

    ShowInfoUI( true )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, onClientPlayerNRPSpawn_handler )
