loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShPlayer" )
Extend( "ShHelmet" )
Extend( "ShClothesShops" )

local bg = nil

addEvent( "showWindowOfSafetyUseHelmets", true )
addEventHandler( "showWindowOfSafetyUseHelmets", root, function ( )
    if bg or localPlayer:HasHelmet( ) then return end

    -- use real fonts as PS
    ibUseRealFonts( true )

    -- background
    bg = ibCreateBackground( nil, function()
        if isElement( bg ) then
            bg:destroy( )
            showCursor( false )
        end
    end, true, true )
    :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
    :ibOnDestroy( function ( )
        showCursor( false )
        bg = nil
    end )

    -- window
    local window = ibCreateImage( 0, 0, 600, 400, "img/bg.png", bg ):center( )

    -- close button
    ibCreateButton( 550, 25, 22, 22, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        bg:destroy( )
    end )
    :ibData( "priority", 1 )

    -- header
    ibCreateLabel( 30, 25, 0, 0, "Безопасность", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )

    -- button of find
    ibCreateButton(
        194, 328, 213, 42, window,
        "img/btn_find.png", "img/btn_find_hover.png", "img/btn_find_hover.png",
        nil, nil, 0xFFAAAAAA
    ):ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        bg:destroy( )

        triggerEvent( "ToggleGPS", localPlayer, CLOTHES_SHOPS_LIST, true )
    end )

    showCursor( true )
end )