Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShVehicle" )
Extend( "CPlayer" )
Extend( "Globals" )

ibUseRealFonts( true )

local UI = { }

function math.round( num, idp )
    local mult = 10 ^ ( idp or 0 )
    return math.floor( num * mult + 0.5 ) / mult
end

addEvent( "onPlayerOfferTuningKit", true )
addEventHandler( "onPlayerOfferTuningKit", localPlayer, function ( vehicle )
    destroyWindow( )

    if not vehicle then
        vehicle = localPlayer.vehicle

        if not vehicle or vehicle:GetOwnerID( ) ~= localPlayer:GetID( ) or not isAvailableModel( vehicle.model ) then
            localPlayer:InfoWindow( "Для просмотра данного предложения, ты должен находиться в личном автомобиле/мотоцикле" )
            return
        end
    end

    showCursor( true )

    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
    UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg ):center( )

    ibCreateButton( 967, 34, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        destroyWindow( )
    end, false )

    local time_to = ( localPlayer:getData( DATA_NAME ) or { } ).time_to or 0
    local lbl_timer = ibCreateLabel( 839, 41, 0, 0, "00 ч. 00 мин.", UI.bg, nil, nil, nil, nil, "center", ibFonts.oxaniumbold_16 )

    local function updateTimer( )
        local time_diff = time_to - getRealTimestamp( )
        if time_diff < 0 then destroyWindow( ) return end

        local hours = math.floor( time_diff / 60 / 60 )
        local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )

        minutes = string.format( "%02d", math.min( minutes, 59 ) )
        local str = hours .. " ч. " .. minutes .. " мин."
        lbl_timer:ibData( "text", str )
    end
    lbl_timer:ibTimer( updateTimer, 500, 0 )
    updateTimer( )

    local types_pos = { 36, 118, 199 }
    local tier = vehicle:GetTier( )
    local selected_types = { }

    for pack_id, data in pairs( PACKS ) do
        local area = ibCreateArea( data.pos, 0, 308, 0, UI.bg )
        local selected_type = false

        for type, pos in pairs( types_pos ) do
            UI[ "filter_" .. pack_id .. type ] = ibCreateButton( pos, 450, 72, 35, area, "img/btn_" .. type, true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then
                    return
                end

                selected_types[ pack_id ] = type

                for i in pairs( types_pos ) do
                    UI[ "filter_" .. pack_id .. i ]:ibData( "texture", "img/btn_" .. i .. "_i.png" )

                    if tier == 6 then
                        break
                    end
                end

                UI[ "filter_" .. pack_id .. type ]:ibData( "texture", "img/btn_" .. type .. "_c.png" )
                selected_type = type

                ibClick( )
            end )

            if tier == 6 then
                break
            end
        end

        ibCreateImage( 143, 498, 21, 22, "img/icon_info.png", area )
        :ibAttachTooltip( "Type R - идеальное сочетание скорости и управляемости\nType X - идеально подходит для прямых заездов\nType F - созданы для затяжных заносов", nil, "left", "center" )

        local prices = data.price_by_class[ tier ]
        local percent = math.round( 100 - prices.new_price / prices.old_price * 100 )
        local img_src = ":nrp_shared/img/" .. ( prices.is_hard and "hard_" or "" ) .. "money_icon.png"
        local color = ibApplyAlpha( 0xffffffff, 75 )

        ibCreateLabel( 0, 544, 0, 0, "ВЫГОДА: " .. percent .. "%", area, nil, nil, nil, "center", "center", ibFonts.extrabold_12 )
        :center_x( )

        -- new price
        local lbl_price_name = ibCreateLabel( 0, 579, 0, 0, "Цена со скидкой:", area, nil, nil, nil, "left", "center", ibFonts.regular_14 )
        local lbl_price = ibCreateLabel( 0, 577, 0, 0, format_price( prices.new_price ), area, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_18 )

        lbl_price_name:center_x( - lbl_price_name:width( ) / 2 - lbl_price:width( ) / 2 - 6 - 12 )
        lbl_price:ibData( "px", lbl_price_name:ibData( "px" ) + lbl_price_name:width( ) + 4 )

        ibCreateImage( lbl_price:ibData( "px" ) + lbl_price:width( ) + 8, 566, 24, 24, img_src, area )

        -- old price
        local lbl_price_name2 = ibCreateLabel( 0, 604, 0, 0, "Цена без скидки:", area, color, nil, nil, "left", "center", ibFonts.regular_14 )
        local lbl_price2 = ibCreateLabel( 0, 602, 0, 0, format_price( prices.old_price ), area, color, nil, nil, "left", "center", ibFonts.oxaniumbold_16 )

        lbl_price_name2:center_x( - lbl_price_name2:width( ) / 2 - lbl_price2:width( ) / 2 - 6 - 12 )
        lbl_price2:ibData( "px", lbl_price_name2:ibData( "px" ) + lbl_price_name2:width( ) + 4 )

        ibCreateImage( lbl_price2:ibData( "px" ) + lbl_price2:width( ) + 8, 592, 22, 22, img_src, area )

        ibCreateImage( lbl_price2:ibData( "px" ) - 2, 602, lbl_price2:width( ) + 36, 1, nil, area, 0xffffffff )

        -- button 'buy'
        ibCreateButton( 0, 624, 160, 46, area, "img/btn_buy", true ):center_x( )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then
                return
            end

            ibClick( )

            if not selected_type then
                localPlayer:ShowError( "Выберите тип тюнинг кейсов (R/X/F)" )
            else
                if confirmation then confirmation:destroy( ) end

                local c_n = VEHICLE_CLASSES_NAMES[ tier ]
                local info = "Кейсы входящие в набор, будут привязаны к транспорту " .. c_n .. " класса"
                local currency = prices.is_hard and "" or " рублей"

                confirmation = ibConfirm( {
                    title = "НАБОР",
                    text = "Ты действительно желаешь приобрести данный набор за " .. format_price( prices.new_price ) .. currency .. "? " .. info,
                    fn = function( self )
                        self:destroy( )

                        triggerServerEvent( "onPlayerWantBuyTuningKit", localPlayer, pack_id, tier, selected_type )
                    end,
                    escape_close = true,
                } )
            end
        end )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then
        destroyElement( UI.black_bg )
    end

    showCursor( false )
end