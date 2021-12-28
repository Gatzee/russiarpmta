TABS_CONF.main = {
    elements = { },

    fn_create = function( self, parent )
        -- Тайлы главного меню
        local tiles = {
            {
                bg        = 1,
                image     = "img/tiles/tile_donate.png",
                menu_open = "donate",
            },
            {
                bg        = 2,
                image     = "img/tiles/tile_wof.png",
                menu_open = "wof",
            },
            {
                bg        = 3,
                image     = "img/tiles/tile_battle_pass.png",
                fn_create = function( area )
                    if exports.nrp_battle_pass:GetCurrentSeasonEndDate( ) < getRealTimestamp( ) then
                        ibCreateLabel( 0, 151, area:width( ), 0, "(Сезон окончен)", area )
                            :ibBatchData( { font = ibFonts.regular_12, align_x = "center", alpha = 255 * 0.75 } )
                    end
                end,
                fn_open   = function( )
                    triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
                end,
                fn_get_count = function( )
                    return CONF.bp_rewards_count
                end,
            },
            {
                bg        = 4,
                image     = "img/tiles/tile_special.png",
                menu_open = "special",
            },
            {
                bg        = 5,
                image     = "img/tiles/tile_cases.png",
                menu_open = "cases",
                fn_create = function( area, img )
                    local discounts_data = HasDiscounts( )
                    if not discounts_data then return end
                    if discounts_data.id == "7cases_discount" then return end

                    local max_discount = 0
                    for case_id, case in pairs( discounts_data.array ) do
                        max_discount = math.max( max_discount, case.discount )
                    end
                    ibCreateLabel( 0, 126, area:width( ), 0, "(Скидка #FF3939" .. max_discount .. "%#FFFFFF)", area )
                        :ibBatchData( { font = ibFonts.regular_12, align_x = "center", colored = true, alpha = 255 * 0.75 } )

                    img:ibData( "py", img:ibData( "py" ) - 11 )
                end,
            },
        }

        local npx = 30
        local animation_duration = 200
        for i, v in pairs( tiles ) do
            local path          = v.image
            local path_bg       = "img/tiles/tile_bg_" .. v.bg .. ".png"
            local path_bg_hover = "img/tiles/tile_bg_" .. v.bg .. "_hover.png"
            
            local sx, sy = 140, 193

            local area     = ibCreateArea( npx, 65, sx, sy, parent )
            local bg       = ibCreateImage( 0, 0, sx, sy, path_bg, area ):ibData( "blend_mode", "modulate_add" ):ibData( "blend_mode_after", "blend" )
            local bg_hover = ibCreateImage( 0, 0, sx, sy, path_bg_hover, area ):ibData( "alpha", 0 ):ibData( "blend_mode", "modulate_add" ):ibData( "blend_mode_after", "blend" )

            local img = ibCreateImage( 0, 0, sx, sy, path, area )

            if v.fn_create then
                v.fn_create( area, img )
            end

            local count = v.fn_get_count and v.fn_get_count( )
            if count and count > 0 then
                ibCreateImage( 48, 147, 44, 44, "img/icon_indicator_big.png", area ):ibData( "blend_mode", "modulate_add" ):ibData( "blend_mode_after", "blend" )
                ibCreateLabel( 48, 147, 44, 44, count, area, _, _, _, "center", "center", ibFonts.extrabold_14 )
            end

            ibCreateArea( 0, 0, sx, sy, area )
                :ibOnHover( function( )
                    bg:ibAlphaTo( 0, animation_duration )
                    bg_hover:ibAlphaTo( 255, animation_duration )
                end )
                :ibOnLeave( function( )
                    bg:ibAlphaTo( 255, animation_duration )
                    bg_hover:ibAlphaTo( 0, animation_duration )
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if v.fn_open then
                        ShowDonateUI( false )
                        v.fn_open( )
						
						SendElasticGameEvent( "f4r_f4_main_icon_click", { main_icon = "battle_pass" } )
                    elseif v.menu_open then
                        if v.menu_open == "wof" then
                            ShowDonateUI( false )
                            triggerServerEvent( "InitRouletteWindow", localPlayer )
                        else
                            SwitchNavbar( v.menu_open )
                        end
						
						SendElasticGameEvent( "f4r_f4_main_icon_click", { main_icon = v.menu_open } )
                    end
                end )

            npx = npx + sx + 10
        end

        local rt_slider
            = ibCreateRenderTarget( 30, 0, 748, 508, parent )
            :ibData( "priority", -1 )
            :ibData( "blend_mode", "blend" )
            :ibData( "blend_mode_after", "blend" )

        ibCreateImage( 740, 270, 8, 218, _, rt_slider, 0xFF365871 ):ibData( "priority", 10 )

        local sliders_list = { }

        for i, array in pairs( AVAILABLE_SLIDERS ) do
            for i, v in pairs( array ) do
                v.data = localPlayer:getData( v.id )
                if v.active == true or type( v.active ) == "function" and v:active( ) then
                    local result = ( v.fn_create_slider or v.fn )( rt_slider, v )
                    if isElement( result ) then
                        result:ibData( "visible", false )
                        table.insert( sliders_list, result )
                    end
                end
            end
        end

        if #sliders_list <= 0 then
            local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/placeholder.png", rt_slider )

            ibCreateImage( 0, 113, 0, 0, "img/sliders/btn_discounts.png", bg )
                :ibSetRealSize( )
                :center_x( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    SwitchNavbar( "offers" )
                end )
            sliders_list[ 1 ] = bg
        end

        local sliders_indicator_boxes = { }

        local old_num
        local function SwitchSlider( num )
            if not sliders_list[ num ] then return end

            for i, v in pairs( sliders_indicator_boxes ) do
                v:ibData( "color", i == num and 0xffffffff or ibApplyAlpha( 0xff000000, 75 ) )
            end

            local new_image = sliders_list[ num ]
            new_image:ibData( "visible", true )

            if old_num then
                local old_image = sliders_list[ old_num ]
                old_image:ibData( "visible", true )
                -- Анимация вправо
                if num < old_num then
                    new_image:ibData( "px", 741 ):ibMoveTo( 0, _, 200 )
                    old_image:ibMoveTo( -741, _, 200 )
                    
                -- Анимация влево
                elseif num > old_num then
                    new_image:ibData( "px", -741 ):ibMoveTo( 0, _, 200 )
                    old_image:ibMoveTo( 741, _, 200 )

                end
            end

            old_num = num
        end

        local function NextSlider( )
            local num = ( old_num or 0 ) - 1
            local num = 1 + ( num + 1 ) % #sliders_list
            SwitchSlider( num )
        end
        
        local function PreviousSlider( )
            local num = ( old_num or 0 ) - 1
            local num = 1 + ( num - 1 ) % #sliders_list
            SwitchSlider( num )
        end

        local _, timer = rt_slider:ibTimer( NextSlider, 5000, 0 )
        _ = nil

        if #sliders_list > 1 then
            -- Стрелка влево
            ibCreateImage( 30 + 20, 278 + 99, 33, 24, "img/sliders/icon_slider_arrow.png", parent )
                :ibBatchData( { alpha = 200, priority = 1 } )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    if isTimer( timer ) then killTimer( timer ) end
                    --iprint( "clck" )
                    PreviousSlider( )
                end )

            -- Стрелка вправо
            ibCreateImage( 30 + 688, 278 + 99, 33, 24, "img/sliders/icon_slider_arrow.png", parent )
                :ibBatchData( { alpha = 200, priority = 1, rotation = 180 } )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    if isTimer( timer ) then killTimer( timer ) end
                    --iprint( "clck" )
                    NextSlider( )
                end )

            local line_width, padding_width = 30, 10
            local area_width = #sliders_list * line_width + ( #sliders_list - 1 ) * padding_width
            local area = ibCreateArea( 30 + 740 / 2 - area_width / 2, 474, area_width, 4, parent )

            local npx = 0
            for i, v in pairs( sliders_list ) do
                local btn
                    = ibCreateImage( npx, 0, line_width, 4, _, area, ibApplyAlpha( 0xff000000, 75 ) )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "down" then return end
                        SwitchSlider( i )
                    end )

                table.insert( sliders_indicator_boxes, btn )
                npx = npx + line_width + padding_width
            end
        end

        SwitchSlider( 1 )
    end,
    fn_destroy = function( self, parent )


    end,
}

function CreateSliderTimer( timestamp_finish, px, py, parent )
    local label_elements = { 9, 30, 63, 84, 117, 137 }

    local time_font = ibFonts.regular_24
    local elements = { }
    for i, v in pairs( label_elements ) do
        elements[ i ] = ibCreateLabel( px + v, 18 + py, 0, 0, "0", parent ):ibBatchData( { font = time_font, align_x = "center", align_y = "center" } )
    end

    local function UpdateTimer()
		local time_diff = timestamp_finish - getRealTimestamp( )

        if time_diff < 0 then return end

        local hours = math.floor( time_diff / 60 / 60 )
        local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
        local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

        if hours > 99 then minutes = 60; seconds = 0 end

        hours = string.format( "%02d", math.min( hours, 99 ) )
        minutes = string.format( "%02d", math.min( minutes, 60 ) )
        seconds = string.format( "%02d", seconds )

        local str = hours .. minutes .. seconds

        for i = 1, #label_elements do
            local element = elements[ i ]
            if isElement( element ) then
                element:ibData( "text", utf8.sub( str, i, i ) )
            end
        end

    end

    parent:ibTimer( UpdateTimer, 500, 0 )
    UpdateTimer( )
end

function CreateHumanTimer( px, py, parent, text, timestamp_finish, is_short, no_icon )
    if not timestamp_finish then error( "no timestamp_finish", 2 ) end

    local area = ibCreateArea( px, py, 0, 24, parent )
    local img = not no_icon and ibCreateImage( 0, 0, 22, 24, "img/icon_timer.png", area ):ibData( "disabled", true )
    local time_desc_label = ibCreateLabel( img and img:ibGetAfterX( 10 ) or 0, 11, 0, 0, text or "Закончится через:", area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.regular_14 )
    local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
    area:ibData( "sx", time_label:ibGetAfterX( ) )

    local function UpdateTime( )
        time_label:ibData( "text", getHumanTimeString( timestamp_finish, is_short ) )
    end
    UpdateTime( )
    time_label:ibTimer( UpdateTime, 500, 0 )

    return area
end

function CreateDetailsButton( px, py, parent )
    ibCreateImage( px, py, 156, 38, "img/sliders/btn_details.png", parent )
        :ibSetRealSize( )
        :ibData( "alpha", 200 )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            SwitchNavbar( "special", "slider" )
        end )
end

-- Скидочные купоны
function CreateSaleTab( py, parent, data )
    local bg_sale = ibCreateImage( 0, py, 740, 50, "img/bg_sale.png", parent )

    local offset_x = 0
    if (data.count_special_coupons or 0) > 1 then
        ibCreateLabel( 15, 0, 0, 50, "x" .. data.count_special_coupons, bg_sale, COLOR_WHITE, nil, nil, "left", "center", ibFonts.bold_16 )
        offset_x = 25
    end

    ibCreateImage( offset_x + 15, 6, 50, 41, "img/coupon.png", bg_sale )
    if data.discount_text then
        ibCreateLabel( offset_x + 82, 0, 0, 50, data.discount_text, bg_sale, COLOR_WHITE, nil, nil, "left", "center", ibFonts.bold_14 )
    elseif data.info_text then
        ibCreateLabel( offset_x + 82, 0, 0, 50, data.info_text, bg_sale, COLOR_WHITE, nil, nil, "left", "center", ibFonts.bold_14 )
    end
    
    local time_lbl = ibCreateLabel( 725, 0, 0, 50, getHumanTimeString( localPlayer:getData( "offer_discount_gift_time_left" ), true ), bg_sale, COLOR_WHITE, nil, nil, "right", "center", ibFonts.bold_16 )
    local text_end_time_lbl = ibCreateLabel( time_lbl:ibGetBeforeX() - 8, 0, 0, 50, "До конца скидок:", bg_sale, COLOR_WHITE, nil, nil, "right", "center", ibFonts.regular_14 )
    ibCreateImage( text_end_time_lbl:ibGetBeforeX() - 23, 15, 18, 20, "img/icon_timer.png", bg_sale, 0xFFFFDF93 )
end

function CreateDiscountCoupon( px, py, coupon_type, coupon_discount_value, parent )
    local tooltip_text = 
    {
        special_services    = "Скидка " .. coupon_discount_value .. "% на услуги",
        special_case        = "Скидка " .. coupon_discount_value .. "% на кейсы", 
        special_vehicle     = "Скидка " .. coupon_discount_value .. "% на транспорт", 
        special_skin        = "Скидка " .. coupon_discount_value .. "% на скины",
        special_numberplate = "Скидка " .. coupon_discount_value .. "% на номера",
        special_neon        = "Скидка " .. coupon_discount_value .. "% на неоны", 
        special_vinyl       = "Скидка " .. coupon_discount_value .. "% на винилы", 
        special_vip_wof     = "Скидка " .. coupon_discount_value .. "% на VIP-жетоны",
        special_pack        = "Скидка " .. coupon_discount_value .. "% на набор",
    }

    local area = ibCreateArea( px, py, 70, 41, parent )
    local coupon = ibCreateImage( 0, 0, 50, 41, "img/coupon.png", area ):ibAttachTooltip( tooltip_text[ coupon_type ] )
    ibCreateLabel( coupon:ibGetAfterX(), 0, 0, 35, "x" .. #localPlayer:GetCouponDiscountListByItemType( coupon_type ), area, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_14 )

    return area
end

function CreateSliderDiscount( discount, parent )
    local img = ibCreateImage( 628, 270, 120, 120, "img/sliders/discount_sticker.png", parent.parent )
        :ibData( "priority", 11 )
        :ibTimer( function( self )
            local px = parent:ibData( "px" )
            self
                :ibData( "visible", parent:ibData( "visible" ) )
                :ibData( "alpha", 255 * ( 1 - math.abs( px ) / 740 ) )
                :ibData( "px", px + 628 )
        end, 0, 0 )

    ibCreateLabel( 73, 47, 0, 0, discount, img, _, 1.2, 1, "center", "center", ibFonts.oxaniumextrabold_30 )
        :ibData( "rotation", 45 )
end