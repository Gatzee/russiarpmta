loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "ib" )

ibUseRealFonts( true )

local UI_elements = {}

function onShowOfferWeaponLicense_handler( state )
    if state then
        local time_left = localPlayer:getData( "offer_gun_license_time_left" )
        if not time_left or time_left < getRealTimestamp() then return end

        time_left = time_left - getRealTimestamp()

        UI_elements.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png" ):center()        
        
        ibCreateButton( UI_elements.bg:ibData( "sx" ) - 52, 29, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            onShowOfferWeaponLicense_handler( false )
        end )

        local tick = getTickCount( )
        local label_elements = { { 617, 104 }, { 645, 104 }, { 691, 104 }, { 719, 104 }, { 763, 104 }, { 791, 104 }, }

        for i, v in ipairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 24, 49, "0", UI_elements.bg ):ibBatchData( { font = ibFonts.regular_22, align_x = "center", align_y = "center" } )
        end
        
        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( time_left - passed / 1000 )

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI_elements[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        UpdateTimer()
        UI_elements.bg:ibTimer( UpdateTimer, 500, 0 )

        ibCreateButton( 388, 694, 248, 44, UI_elements.bg, "img/btn_mark_map.png", "img/btn_mark_map.png", "img/btn_mark_map.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xDDCCCCCC  )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            triggerEvent( "ToggleGPS", localPlayer, {
                { x = 172.112, y = -2130.621, z = 22.021 },
                { x = -84.85, y = 2512.88, z = 21.61, },
            }, true )
            onShowOfferWeaponLicense_handler( false )
        end, false )

        showCursor( true )
    elseif isElement( UI_elements.bg ) then
        destroyElement( UI_elements.bg )
        showCursor( false )
    end
end
addEvent( "onShowOfferWeaponLicense", true )
addEventHandler( "onShowOfferWeaponLicense", root, onShowOfferWeaponLicense_handler )