EASING_TYPES = {
    [ OVERLAY_ERROR ] = "OutBounce",
}

EASING_DURATIONS = {
    [ OVERLAY_ERROR ] = 700,
}

local flags = {
    [ "RU" ] = "Российский",
    [ "UK" ] = "Украинский",
    [ "KZ" ] = "Казахстанский",
    [ "GE" ] = "Грузинский",
    [ "CH" ] = "Чеченский",
}

function AddFlags( )
    local data = { }

    for type, name in pairs( flags ) do
        table.insert( data, type )
    end

    return data
end

function onOverlayNotificationRequest_handler( overlay_type, data, isWindowOverlay )
	if not isElement( UI and UI.bg ) then
        triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer )
        return 
    end
	
	local parent = GetCurrentContentArea( )
	local headerOffset = 0
	if isWindowOverlay then
		parent = UI.bg
		headerOffset = 70
	end

    ibOverlaySound()
    
    local overlay_area = ibCreateArea( 0, headerOffset, parent:width( ), parent:height( ) - headerOffset, parent )
		:ibBatchData( { priority = 2, overlay = true } )

    local overlay_bg = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( ) - headerOffset, _, overlay_area, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibMoveTo( 0, 0, EASING_DURATIONS[ overlay_type ] or 200, EASING_TYPES[ overlay_type ] )

    if OVERLAYS[ overlay_type ] then
        OVERLAYS[ overlay_type ]( overlay_bg, data )
    end
end
addEvent( "onOverlayNotificationRequest", true )
addEventHandler( "onOverlayNotificationRequest", root, onOverlayNotificationRequest_handler )

OVERLAYS = {
    [ OVERLAY_ERROR ] = function( parent, data )
        ibCreateLabel( 0, 177, 0, 0, data.title or "ОШИБКА", parent, 0xffff4d4d, _, _, "center", _, ibFonts.regular_18 ):center_x( )
        ibCreateLabel( 0, 245, 0, 0, data.text,parent, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_18 ):center_x( )
        ibError( )
        ibCreateImage( 0, 305, 0, 0, "img/btn_notification_hide.png", parent )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
            end )
    end,





    [ OVERLAY_CHANGE_SEX ] = function( parent, data )
        CreateHideButton( parent )
        ibCreateLabel( 0, 94, 0, 0, "Выбери желаемый пол:", parent, COLOR_WHITE, _, _, "center", _, ibFonts.regular_16 ):center_x( )
        ibCreateLabel( 0, 213, 0, 0, "Выбери свой будущий скин:", parent, COLOR_WHITE, _, _, "center", _, ibFonts.regular_16 ):center_x( )

        local skins_by_gender = SERVICE_SKIN_LIST

        --[[
            SKINS_LIST = {
                [0] = {
                    [ 0 ] = { 117, "Гопник" },
                    [ 1 ] = { 118, "Четкий" },
                    [ 2 ] = { 156, "Знаменитый" },
                    [ 3 ] = { 120, "Пацан" },
                    [ 4 ] = { 82, "Старый" },
                };
                [1] = {
                    [ 0 ] = { 139, "Скромная" },
                    [ 1 ] = { 141, "Кокетка" },
                    [ 2 ] = { 157, "Конфетка" },
                    [ 3 ] = { 145, "Милаха" },
                }
            }
        ]]

        local gender_areas = { }
        local gender_hovers = { }
        local gender_current_selections = { }

        for gender, values in pairs( skins_by_gender ) do
            gender_areas[ gender ] = ibCreateArea( 0, 256 + 32, 0, 0, parent )
            gender_hovers[ gender ] = { }

            local npx = 0
            for i, skin in pairs( values ) do
                local bg = ibCreateImage( npx, 0, 0, 0, "img/skins/" .. skin .. "_unselected.png", gender_areas[ gender ] )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/skins/" .. skin .. "_selected.png", bg ):ibBatchData( { disabled = true, alpha = 0 } )

                bg:ibSetRealSize( )
                bg_hover:ibSetRealSize( )

                bg:center_y( )

                local real_sx = bg:ibGetTextureSize( )
                bg
                    :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( )
                        if gender_current_selections[ gender ] ~= i then
                            bg_hover:ibAlphaTo( 0, 200 )
                        end
                    end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        for n, v in pairs( gender_hovers[ gender ] ) do
                            if n ~= i then v:ibAlphaTo( 0, 200 ) end
                        end
                        gender_current_selections[ gender ] = i
                    end )

                gender_hovers[ gender ][ i ] = bg_hover

                npx = npx + real_sx + 7
            end

            gender_areas[ gender ]:ibData( "sx", npx - 7 ):center_x( )
        end

        local genders = {
            [ 0 ] = "Мужской",
            [ 1 ] = "Женский",
        }
        local gender_name = genders[ localPlayer:GetGender( ) ]
        ibCreateLabel( 0, 171, 0, 0, "Твой текущий пол: " .. gender_name, parent, ibApplyAlpha( COLOR_WHITE, 20 ), _, _, "center", _, ibFonts.regular_12 ):center_x( )

        local gender_area = ibCreateArea( 0, 131, 0, 0, parent )
        local gender_name_areas = { }
        local fns = { }
        local current_gender
        local gender_handle
        fns.SelectGender = function( gender_num )
            if current_gender == gender_num then return end
            for i, v in pairs( gender_name_areas ) do
                if i ~= gender_num then v:ibAlphaTo( ibGetAlpha( 20 ), 200 ) end
            end

            gender_name_areas[ gender_num ]:ibAlphaTo( 255, 200 )

            local sx = dxGetTextWidth( genders[ gender_num ], 1, ibFonts.bold_16 )
            local px = gender_name_areas[ gender_num ]:ibGetCenterX( ) - sx / 2
            if isElement( gender_handle ) then
                gender_handle:ibMoveTo( px, _, 200 ):ibResizeTo( sx, _, 200 )
            else
                gender_handle = ibCreateImage( px, 26, sx, 2, _, gender_area, ibApplyAlpha( COLOR_WHITE, 40 ) ):ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
            end

            if current_gender and gender_num > current_gender then
                for i, v in pairs( gender_areas ) do
                    if i ~= gender_num then
                        v:ibMoveTo( -v:width( ), _, 300 ):ibAlphaTo( 0, 200 )
                    end
                end
                gender_areas[ gender_num ]
                    :ibData( "px", parent:width( ) )
                    :ibMoveTo( parent:ibData( "sx" ) / 2 - gender_areas[ gender_num ]:width( ) / 2, _, 300 )
                    :ibAlphaTo( 255, 200 )
            else
                for i, v in pairs( gender_areas ) do
                    if i ~= gender_num then
                        v:ibMoveTo( parent:width( ), _, 300 ):ibAlphaTo( 0, 200 )
                    end
                end
                gender_areas[ gender_num ]
                    :ibData( "px", -gender_areas[ gender_num ]:width( ) )
                    :ibMoveTo( parent:ibData( "sx" ) / 2 - gender_areas[ gender_num ]:width( ) / 2, _, 300 )
                    :ibAlphaTo( 255, 200 )
            end

            current_gender = gender_num
        end

        local npx = 0
        local genders_count = 0
        for i, v in pairs( genders ) do
            local area = ibCreateArea( npx, 0, 90, 26, gender_area )
            ibCreateLabel( 0, 0, 90, 26, v, area, _, _, _, "center", "center", ibFonts.bold_16 ):ibData( "disabled", true )

            area:ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                fns.SelectGender( i )
            end )

            gender_name_areas[ i ] = area
            genders_count = genders_count + 1
            npx = npx + 90 + 20
        end
        gender_area:ibData( "sx", genders_count * 90 + ( genders_count - 1 ) * 20 ):center_x( )

        fns.SelectGender( localPlayer:GetGender( ) == 0 and 1 or 0 )

        ibCreateImage( 0, 341, 0, 0, "img/btn_change.png", parent )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --iprint( "CHANGE SEX" )
                if current_gender and gender_current_selections[ current_gender ] then
                    HideMenu( parent )
                    triggerServerEvent( "onBuyChangeSexRequest", resourceRoot, { current_gender, gender_current_selections[ current_gender ] } )
                else
                    onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Нужно выбрать пол и скин" } )
                end
            end )
    end,

    [ OVERLAY_REMOVE_DISEASES ] = function( parent, data )
        ibCreateLabel( 0, 138, 0, 0, "Ты действительно хочешь вылечить все свои болезни?", parent, COLOR_WHITE, nil, nil, "center", "center", ibFonts.bold_18 ):center_x( )
        ibCreateLabel( 0, 174, 0, 0, "Твои болезни:", parent, COLOR_WHITE, nil, nil, "center", "center", ibFonts.bold_18 ):center_x( )

        local i = 0
        for id, stage in pairs( data ) do
            ibCreateLabel( 0, 200 + 24 * i, 0, 0, DISEASES_INFO[ id ].name .. ", " .. stage .. " стадия", parent, ibApplyAlpha( nil, 60 ), nil, nil, "center", "center", ibFonts.regular_16 ):center_x( )
            i = i + 1
        end

        local inner_area = ibCreateArea( 0, 265, 0, 0, parent ):center_x( )
        local lbl_cost = ibCreateLabel( 0, 0, 0, 0, "Стоимость:", inner_area, ibApplyAlpha( COLOR_WHITE, 40 ) ):ibData( "font", ibFonts.regular_16 )
        local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 19 ), -5, 30, 30, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )

        local cost = localPlayer:GetCostService( 14 )
        local lbl_money = ibCreateLabel( icon_money:ibGetAfterX( 8 ), -5, 0, 0, format_price( cost ), inner_area ):ibData( "font", ibFonts.bold_21 )
        inner_area:ibData( "sx", lbl_money:ibGetAfterX( ) ):center_x( )

        ibCreateImage( 323, 320, 0, 0, "img/btn_no.png", parent )
        :ibSetRealSize( )
        :ibData( "alpha", 200 )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            HideMenu( parent )
        end )

        ibCreateImage( 404, 320, 0, 0, "img/btn_yes.png", parent )
        :ibSetRealSize( )
        :ibData( "alpha", 200 )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            HideMenu( parent )

            triggerServerEvent( "onPlayerTryBuyRemoveDiseases", resourceRoot )
        end )
    end,

    [ OVERLAY_CHANGE_NICKNAME ] = function( parent, data )
        CreateHideButton( parent )
        ibCreateLabel( 0, 152, 0, 0, "Введи желаемое имя персонажа:", parent, COLOR_WHITE, _, _, "center", _, ibFonts.regular_16 ):center_x( )
        ibCreateLabel( 0, 181, 0, 0, "Запрещено: Мать Админа, Молодой Человек и т.д.", parent, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "center", _, ibFonts.regular_12 ):center_x( )

        local bg_edit = ibCreateImage( 238, 218, 325, 44, "img/bg_input_overlay.png", parent )
        local edit = ibCreateEdit( 15, 0, 310, 44, "", bg_edit, COLOR_WHITE, 0, ibApplyAlpha( COLOR_WHITE, 75 ) ):ibData( "font", ibFonts.bold_18 )

        ibCreateImage( 0, 282, 0, 0, "img/btn_change.png", parent )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
                --iprint( "CHANGE" )
                triggerServerEvent( "onBuyNicknameRequest", resourceRoot, edit:ibData( "text" ) )
            end )
    end,

    [ OVERLAY_PURCHASE_JAILKEYS ] = function( parent, data )
        ibCreateLabel( 0, 210, 0, 0, "Ты действительно хочешь приобрести карточку выхода из тюрьмы?", parent, COLOR_WHITE, _, _, "center", "bottom", ibFonts.bold_18 ):center_x( )

        local inner_area = ibCreateArea( 0, 265, 0, 0, parent ):center_x( )
        local lbl_cost = ibCreateLabel( 0, 0, 0, 0, "Стоимость:", inner_area, ibApplyAlpha( COLOR_WHITE, 40 ) ):ibData( "font", ibFonts.regular_16 )
        local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 19 ), -5, 30, 30, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
        
        local cost = localPlayer:GetCostService( 12 )
        local lbl_money = ibCreateLabel( icon_money:ibGetAfterX( 8 ), -5, 0, 0, format_price( cost ), inner_area ):ibData( "font", ibFonts.semibold_21 )
        inner_area:ibData( "sx", lbl_money:ibGetAfterX( ) ):center_x( )

        ibCreateImage( 323, 320, 0, 0, "img/btn_no.png", parent )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
            end )

        ibCreateImage( 404, 320, 0, 0, "img/btn_yes.png", parent )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
                triggerServerEvent( "onServerBuyJailkeys", resourceRoot )
            end )
    end,






    [ OVERLAY_DONATE_CONVERT ] = function( parent, data )
        ibCreateLabel( 0, 207, 0, 0, "Ты успешно совершил обмен", parent, ibApplyAlpha( COLOR_WHITE, 40 ), _, _, "center", _, ibFonts.regular_18 ):center_x( )

        local inner_area = ibCreateArea( 0, 255, 0, 0, parent ):center_x( )
        local icon_money = ibCreateImage( 0, -4, 30, 30, ":nrp_shared/img/money_icon.png", inner_area ):ibData( "disabled", true )
        local lbl_money = ibCreateLabel( icon_money:ibGetAfterX( 8 ), -5, 0, 0, "+ " .. format_price( data.amount or 0 ), inner_area ):ibData( "font", ibFonts.semibold_21 )
        inner_area:ibData( "sx", lbl_money:ibGetAfterX( ) ):center_x( )

        ibCreateImage( 0, 305, 0, 0, "img/btn_thanks.png", parent )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
            end )
        ibBuyDonateSound()
    end,






    [ OVERLAY_PURCHASE_HARD ] = function( parent, data )
        --CreateHideButton( parent )

        ibCreateLabel( 0, 230, 0, 0, data.text, parent, COLOR_WHITE, _, _, "center", "bottom", ibFonts.bold_18 ):center_x( )

        local inner_area = ibCreateArea( 0, 265, 0, 0, parent ):center_x( )
        local lbl_cost = ibCreateLabel( 0, 0, 0, 0, "Стоимость:", inner_area, ibApplyAlpha( COLOR_WHITE, 40 ) ):ibData( "font", ibFonts.regular_16 )
        local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 19 ), -5, 30, 30, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
        local lbl_money = ibCreateLabel( icon_money:ibGetAfterX( 8 ), -5, 0, 0, format_price( data.cost or 0 ), inner_area ):ibData( "font", ibFonts.semibold_21 )
        inner_area:ibData( "sx", lbl_money:ibGetAfterX( ) ):center_x( )

        ibCreateImage( 323, 320, 0, 0, "img/btn_no.png", parent )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
            end )

        ibCreateImage( 404, 320, 0, 0, "img/btn_yes.png", parent )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideMenu( parent )
                data.fn( )
            end )
    end,






    [ OVERLAY_PROLONG_SUBSCRIPTION ] = function( parent, data )
        CreateHideButton( parent )
        ibCreateImage( 288, 66, 0, 0, "img/subscription/icon_subscription_blue.png", parent ):ibSetRealSize( )
        ibCreateLabel( 331, 71, 0, 0, "Продление подписки", parent ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( parent:width( ) / 2, 104, 0, 0, "Твоя подписка будет действовать еще - " .. getHumanTimeString( localPlayer:getData( "subscription_time_left" ) ), parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )
    
        local durations = {
            {
                days = 30,
                cost = 999,
            },
            {
                days = 90,
                cost = 2997,
            }
        }

        local selected_item

        local buttons_area
        local function ShowButtons( )
            if buttons_area then return end
            buttons_area = ibCreateArea( 0, 30, 0, 0, parent )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 200 )
                :ibMoveTo( 0, 0, 200 )

            ibCreateImage( 313, 283, 0, 0, "img/subscription/btn_prolong_big.png", buttons_area )
                :ibData( "alpha", 200 )
                :ibSetRealSize( )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    triggerServerEvent( "onSubscriptionBuyRequest", resourceRoot, selected_item )
                end )
                

            ibCreateImage( 443, 283, 0, 0, "img/premium/btn_gift.png", buttons_area )
                :ibData( "alpha", 200 )
                :ibSetRealSize( )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if input then input:destroy() end
                    input = ibInput(
                        {
                            title = "ПОДПИСКА В ПОДАРОК", 
                            text = "",
                            edit_text = "Введи имя игрока, кому хочешь подарить подписку на " .. durations[ selected_item ].days .. " д.",
                            btn_text = "ПОДАРИТЬ",
                            fn = function( self, text )
                                triggerServerEvent( "onSubscriptionBuyRequest", resourceRoot, selected_item, text )
                                self:destroy()
                            end
                        }
                    )
                end )
        end


        local sx, sy = 140, 100
        local npx, npy = ( parent:width( ) - sx * #durations + ( 10 * ( #durations - 1 ) ) ) / 2, 153
        local bgs = { }
        for i, v in pairs( durations ) do
            local area = ibCreateArea( npx, npy, sx, sy, parent )
            ibCreateImage( 0, 0, sx, sy, _, area, ibApplyAlpha( 0xff333d4c, 50 ) )
            local bg_hover = ibCreateImage( 0, 0, sx, sy, _, area, 0xff6a84a8 ):ibData( "alpha", 0 )
            bgs[ i ] = bg_hover

            ibCreateLabel( area:width( ) / 2, 23, 0, 0, v.days .. " " .. plural( v.days, "день", "дня", "дней" ), area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "center", _, ibFonts.bold_18 )
            
            local text = "за " .. v.cost
            local inner_area = ibCreateArea( 0, 51, 0, 0, area ):center_x( )
            local lbl_cost = ibCreateLabel( 0, 0, 0, 0, text, inner_area ):ibData( "font", ibFonts.semibold_20 )
            local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 6, 18, 18, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
            inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

            ibCreateArea( 0, 0, sx, sy, area )
                :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) if selected_item ~= i then bg_hover:ibAlphaTo( 0, 200 ) end end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if not selected_item or selected_item ~= i then
                        for n, v in pairs( bgs ) do if n ~= i then v:ibAlphaTo( 0, 200 ) end end
                        selected_item = i
                        ibClick( )
                        ShowButtons( )
                    end
                end )
            npx = npx + sx + 10
        end
    end,

    [ OVERLAY_PROLONG_PREMIUM ] = function( parent, data )
        local function get_premium_string( )
            return "Твой премиум будет действовать ещё - " .. getHumanTimeString( localPlayer:getData( "premium_time_left" ) )
        end
        
        CreateHideButton( parent )
        ibCreateImage( 288, 66, 0, 0, "img/premium/icon_crown_small.png", parent ):ibSetRealSize( )
        ibCreateLabel( 331, 71, 0, 0, "Продление премиума", parent ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( parent:width( ) / 2, 104, 0, 0, get_premium_string( ), parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )
            :ibTimer( function( self )
                self:ibData( "text", get_premium_string( ) )
            end, 500, 0 )


        local durations = {
            {
                title = "3 дня",
                days = 3,
                cost = 199, --299,
                old_cost = 299,
            },
            {
                title = "7 дней",
                days = 7,
                cost = 399, --599,
                old_cost = 599,
            },
            {
                title = "14 дней",
                days = 14,
                cost = 499, --799,
                old_cost = 799,
            },
            {
                title = "1 месяц",
                days = 30,
                cost = 799, --999,
                old_cost = 999,
            },
            --[[{
                title = "3 месяца",
                days = 90,
                cost = 1999,
            },]]
        }

        local selected_item

        local buttons_area
        local function ShowButtons( )
            if buttons_area then return end
            buttons_area = ibCreateArea( 0, 30, 0, 0, parent )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 200 )
                :ibMoveTo( 0, 0, 200 )

            ibCreateImage( 313, 383, 0, 0, "img/premium/btn_extend.png", buttons_area )
                :ibData( "alpha", 200 )
                :ibSetRealSize( )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if localPlayer:GetDonate( ) < durations[ selected_item ].cost then
                        ShowPaymentForPremium( durations[ selected_item ].days )
                    else
                        triggerServerEvent( "onPremiumPurchaseRequest", resourceRoot, durations[ selected_item ].days )
                    end
                end )
                

            ibCreateImage( 443, 380, 0, 0, "img/premium/btn_gift.png", buttons_area )
                :ibData( "alpha", 200 )
                :ibSetRealSize( )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if input then input:destroy() end
                    input = ibInput(
                        {
                            title = "ПРЕМИУМ В ПОДАРОК", 
                            text = "",
                            edit_text = "Введи имя игрока, кому хочешь подарить премиум на " .. durations[ selected_item ].days .. " д.",
                            btn_text = "ПОДАРИТЬ",
                            fn = function( self, text )
                                triggerServerEvent( "onPremiumGiftRequest", resourceRoot, durations[ selected_item ].days, text )
                                self:destroy()
                            end
                        }
                    )
                end )
        end


        local sx, sy = 140, 100
        local npx, npy = ( parent:width( ) - sx * 2 + ( 10 * ( 2 - 1 ) ) ) / 2, 153
        local bgs = { }
        for i, v in pairs( durations ) do
            local area = ibCreateArea( npx, npy, sx, sy, parent )
            ibCreateImage( 0, 0, sx, sy, _, area, ibApplyAlpha( 0xff333d4c, 50 ) )
            local bg_hover = ibCreateImage( 0, 0, sx, sy, _, area, 0xff6a84a8 ):ibData( "alpha", 0 )
            bgs[ i ] = bg_hover

            local discount = GetPremiumDiscountsForDays( v.days )
            if discount and DoesPremiumIncludeProlonging( ) then
                ibCreateLabel( area:width( ) / 2, 10, 0, 0, v.title, area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "center", _, ibFonts.bold_18 )
                local text = "за " .. v.cost
                local inner_area = ibCreateArea( 0, 35, 0, 0, area ):center_x( )
                local lbl_cost = ibCreateLabel( 0, 0, 0, 0, text, inner_area ):ibData( "font", ibFonts.bold_21 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 6, 18, 18, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
                inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

                local text = "вместо " .. v.old_cost
                local inner_area = ibCreateArea( 0, 65, 0, 0, area ):center_x( )
                local lbl_cost = ibCreateLabel( 0, 0, 0, 0, text, inner_area, 0x80FFFFFF ):ibData( "font", ibFonts.regular_16 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 2, 18, 18, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
                ibCreateImage( lbl_cost:width()-35, 10, 60, 1, nil, inner_area, 0x80FFFFFF )
                inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

                ibCreateArea( 0, 0, sx, sy, area )
                    :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) if selected_item ~= i then bg_hover:ibAlphaTo( 0, 200 ) end end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        if not selected_item or selected_item ~= i then
                            for n, v in pairs( bgs ) do if n ~= i then v:ibAlphaTo( 0, 200 ) end end
                            selected_item = i
                            ibClick( )
                            ShowButtons( )
                        end
                    end )
            else
                ibCreateLabel( area:width( ) / 2, 20, 0, 0, v.title, area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "center", _, ibFonts.bold_18 )
                local text = "за " .. v.old_cost or v.cost
                local inner_area = ibCreateArea( 0, 51, 0, 0, area ):center_x( )
                local lbl_cost = ibCreateLabel( 0, 0, 0, 0, text, inner_area ):ibData( "font", ibFonts.bold_21 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 6, 18, 18, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )
                inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

                ibCreateArea( 0, 0, sx, sy, area )
                    :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) if selected_item ~= i then bg_hover:ibAlphaTo( 0, 200 ) end end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        if not selected_item or selected_item ~= i then
                            for n, v in pairs( bgs ) do if n ~= i then v:ibAlphaTo( 0, 200 ) end end
                            selected_item = i
                            ibClick( )
                            ShowButtons( )
                        end
                    end )
            end
            npx = npx + sx + 10

            if i == 2 then
                npx = ( parent:width( ) - sx * 2 + ( 10 * ( 2 - 1 ) ) ) / 2
                npy = npy + sy + 10
            end
        end
    end,

    [ OVERLAY_PREMIUM_FEATURES ] = function( parent, data )
        CreateHideButton( parent )

        local pDescriptionLines = 
        {
            { 
                title = { s_type = "img", sx = 18, sy = 18, path = "img/premium/icon_calendar.png" }, 
                s_body = "Специальные ежедневные награды",
            },

            { 
                title = { s_type = "img", sx = 18, sy = 18, path = "img/premium/icon_crown_tiny.png" }, 
                s_body = "Уникальное украшение для твоего ника",
            },

            { 
                title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                s_body = "Опыт на всех работах",
            },

            { 
                title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                s_body = "Внутреннего опыта во фракциях и бандах",
            },

            { 
                title = { s_type = "string", text = "X1.5", color = 0xFF23f965, font = "bold_18" }, 
                s_body = "Зарплаты во фракциях",
            },

            { 
                title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                s_body = "Опыт за выполнение квестов",
            },

            { 
                title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                s_body = "Денег за выполнение квестов",
            },

            { 
                title = { s_type = "string", text = "+20%", color = 0xFFffd236, font = "bold_18" }, 
                s_body = "К зарплате на всех работах",
            },

            { 
                title = { s_type = "string", text = "15%", color = 0xFFff5252, font = "bold_18" }, 
                s_body = "Скидка на весь товар у барыги и в оружейном магазине",
            },

            { 
                title = { s_type = "string", text = "50%", color = 0xFFff5252, font = "bold_18" }, 
                s_body = "Снижение стоимости содержания недвижимости",
            },

            {
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Выдача дополнительного одного жетона Колеса фортуны",
            },

            { 
                title = { s_type = "string", text = "+1", color = 0xFFffd236, font = "bold_18" }, 
                s_body = "Час к смене на работе",
            },

            { 
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Уникальные аксессуары для персонажа",
            },

            { 
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Выбор цвета ника",
            },

            { 
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Черный рынок для машин",
            },

            { 
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Доступ к особым машинам",
            },

            { 
                title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                s_body = "Доступ к особым скинам",
            },
        }

        ibCreateLabel( 30, 60, 0, 0, "Полный список того, что даёт новый премиум:", parent, 0xFFFFFFFF ):ibData("font", ibFonts.regular_16)

        local desc, desc_scrollbar = ibCreateScrollpane( 0, 90, 790, 320, parent, { scroll_px = -10 } )
        desc_scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

        local py = 0
        for k,v in pairs(pDescriptionLines) do
            if v.title.s_type == "string" then
                local label_title = ibCreateLabel( 30, py, 0, 30, v.title.text, desc, v.title.color, _, _, "left", "center" ):ibData("font", ibFonts[ v.title.font ])
                ibCreateLabel( 30 + label_title:width(), py, 0, 30, " - "..v.s_body, desc, 0x99FFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.regular_14)
            elseif v.title.s_type == "img" then
                ibCreateImage( 30, py+15-v.title.sy/2, v.title.sx, v.title.sy, v.title.path, desc )
                ibCreateLabel( 32 + v.title.sx, py, 0, 30, " - "..v.s_body, desc, 0x99FFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.regular_14)
            end

            py = py + 25
        end

        desc:AdaptHeightToContents( )
        desc_scrollbar:UpdateScrollbarVisibility( desc )
    end,

    [ OVERLAY_APPLY_NUMBERPLATE ] = function( parent, data )
        CreateHideButton( parent )
        ibCreateLabel( 0, 78, parent:width(), 0, "Установка номера", parent, 0xffffffff, _, _, "center" ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( 0, 105, parent:width(), 0, "Выберите автомобиль на который хотите желаете установить приобретённый номер", parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, parent:width(), 250, parent, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local sx, sy = parent:width(), 74
        local px, py = 0, 0

        ibCreateImage( 30, 140, sx-60, 1, nil, parent, 0xff59616a )

        local pVehicles = localPlayer:GetVehicles()

        for i, v in pairs( pVehicles ) do
            if not VEHICLE_CONFIG[ v.model ].is_moto and not VEHICLES_NO_NUMBERPLATES[ v.model ] then
                local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData("alpha", 0)
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( px+30, py+sy/2-16, 49, 33, "img/icon_vehicle.png", scrollpane ):ibData("disabled", true)
                ibCreateLabel( px+100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData("disabled", true)
                
                ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0xff59616a )

                ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png" )
                :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
					SendElasticGameEvent( "f4r_f4_unique_auto_accessory_choose_auto_click" )
                    ibConfirm(
                        {
                            title = "УСТАНОВКА НОМЕРА", 
                            text = "Ты действительно хочешь установить номер ".. data.name .." на автомобиль ".. VEHICLE_CONFIG[ v.model ].model .." за",
                            cost = data.cost,
                            cost_is_soft = false,
                            fn = function( self )

                                data.region = tonumber( data.region ) and string.format( "%02d", data.region ) or data.region

								SendElasticGameEvent( "f4r_f4_unique_auto_accessory_confirmation_ok_click" )
                                triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, data.id, data.name, data.segment, v )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )

                end )


                py = py + sy
            end
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
	end,
	
    [ OVERLAY_APPLY_VINYL ] = function( parent, data )
        if not data.received_from_case then
            CreateHideButton( parent )
        end
        
        ibCreateLabel( 0, 78, parent:width( ), 0, "Привязка винила", parent, 0xffffffff, _, _, "center" ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( 0, 105, parent:width( ), 0, "Выберите автомобиль к классу которого вы хотите привязать винил", parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, parent:width( ), data.received_from_case and 368 or 250, parent, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local sx, sy = parent:width( ), 74
        local px, py = 0, 0

        ibCreateImage( 30, 140, sx-60, 1, nil, parent, 0xFF59616A )

        local pVehicles = localPlayer:GetVehicles( nil, true, true )

        for i, v in pairs( pVehicles ) do
            local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

            ibCreateImage( px+30, py+sy/2-16, 49, 33, "img/icon_vehicle.png", scrollpane ):ibData( "disabled", true )
            ibCreateLabel( px+100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )
            
            ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0xFF59616A )

            ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png" )
                :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    if data.received_from_case then
                        triggerServerEvent( "PlayerWantTakeOpenedCaseItem", resourceRoot, { tier = v:GetTier( ), cost = data.cost } )
                        HideMenu( parent )
                    else
                        SendElasticGameEvent( "f4r_f4_unique_auto_accessory_choose_auto_click" )
                        ibConfirm(
                            {
                                title = "ПРИВЯЗКА ВИНИЛА", 
                                text = "Ты действительно хочешь привязать винил ".. data.name .." на автомобиль ".. VEHICLE_CONFIG[ v.model ].model .." за",
                                cost = data.cost,
                                cost_is_soft = false,
                                fn = function( self )
                                    SendElasticGameEvent( "f4r_f4_unique_auto_accessory_confirmation_ok_click" )
                                    triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, data.id, data.name, data.segment, v )
                                    self:destroy( )
                                end,
                                escape_close = true,
                            }
                        )
                    end
                end )
            py = py + sy
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
	
    [ OVERLAY_VEHICLE_DETAILS ] = function( parent, data )
		
		local bg = ibCreateImage( 0, 0, 0, 0, "img/overlays/vehicle_details/overlay_preset.png", parent ):ibSetRealSize( ):center( )
		CreateHideButton( parent )
		ibUseRealFonts( true )

        local variant = data.variant or 1

		--Класс автомобиля
		ibCreateLabel( 576, 23, 0, 0, VEHICLE_CLASSES_NAMES[ tostring( data.model ):GetTier( variant ) ], parent, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_18 )
		--Привод
		ibCreateLabel( 702, 27, 0, 0, DRIVE_TYPE_NAMES[ VEHICLE_CONFIG[ data.model ].variants[ variant ].handling.driveType ], parent, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_14 )
		
		--Цена
        local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_vehicle", data.cost )
        if coupon_discount_value then
            CreateDiscountCoupon( 25, 440, "special_vehicle", coupon_discount_value, bg )
        end

		ibCreateLabel( 504, 378, 0, 0, format_price( cost ), parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_27)
		if data.cost_original then
			--Цена без скидки
			local previous_price = ibCreateLabel( 560, 360, 0, 0, format_price( data.cost_original ), parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_16 )
			--На тот случай если пригодится анимка полоски зачеркивания старой цены
			--ibCreateLine( 536, 370, 536, 370, 0xFFFFFFFF, 1, parent ):ibMoveTo( previous_price:ibGetAfterX( 2 ), 370, 600, "InQuad" )
			ibCreateLine( 536, 370, previous_price:ibGetAfterX( 2 ), 370, 0xFFFFFFFF, 1, parent )
		end
		
		local vehicleIconArea = ibCreateArea( 57, 20, 300, 243, bg )
		--Название транспорта средства
		ibCreateLabel( 0, 0, vehicleIconArea:width( ), 0, data.name, vehicleIconArea, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_22 )
		--Превью транспортного средства
        ibCreateContentImage( 0, 0, 300, 160, "vehicle", data.model, vehicleIconArea ):center( 0, 20 )

        -- triangle
        exports.nrp_tuning_shop:generateTriangleTexture( 140, 290, bg, getVehicleOriginalParameters( data.model ) )

		local vehicleConfig = VEHICLE_CONFIG[ data.model ].variants[ variant ]
		local vPower = vehicleConfig.power
		local vMaxSpeed = vehicleConfig.max_speed
		local vAccelerationTo100 = vehicleConfig.ftc
		local vFuelLoss = vehicleConfig.fuel_loss
        local acceleration = vehicleConfig.stats_acceleration

		local progressbar_width = 316

		local function getProgressWidth( value, maximum )
            return ( ( value / maximum ) * progressbar_width ) > progressbar_width and progressbar_width or ( value / maximum ) * progressbar_width
        end

		-- Мощность
		ibCreateLabel( 462, 74, 308, 0, vPower .. " л.с.", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		ibCreateLine( 456, 99, 456 , 99, 0xFFFF965D, 15, parent ):ibMoveTo( 456 + getProgressWidth( vPower, 600 ), 99, 800, "InOutQuad" )

        -- Разгон от 0 до 100
        ibCreateLabel( 462, 74 + 42, 308, 0, vAccelerationTo100 .. " сек.", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
        ibCreateLine( 456, 141, 456 , 141, 0xFFFF965D, 15, parent ):ibMoveTo( 456 + getProgressWidth( vAccelerationTo100, 30 ), 141, 800, "InOutQuad" )

        -- Расход
        local v = VEHICLE_CONFIG[ data.model ].is_electric and "%" or "л."
        ibCreateLabel( 462, 74 + 42 * 2, 308, 0, vFuelLoss .. " " .. v, parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
        ibCreateLine( 456, 183, 456 , 183, 0xFFFF965D, 15, parent ):ibMoveTo( 456 + getProgressWidth( vFuelLoss, 25 ), 183, 800, "InOutQuad" )

        -- Максимальная скорость
        ibCreateLabel( 462, 74 + 42 * 3 + 3, 308, 0, vMaxSpeed .. " км/ч", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
        ibCreateLine( 456, 228, 456 , 228, 0xFFFF965D, 15, parent ):ibMoveTo( 456 + getProgressWidth( vMaxSpeed, 400 ), 228, 800, "InOutQuad" )

        -- Ускорение
        ibCreateLabel( 462, 74 + 42 * 4 + 2, 308, 0, acceleration, parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
        ibCreateLine( 456, 269, 456 , 269, 0xFFFF965D, 15, parent ):ibMoveTo( 456 + getProgressWidth( acceleration, 400 ), 269, 800, "InOutQuad" )

		--Просто по координатам создаем одну невидимую картинку, по производительности это лучше чем создавать 6 картинок
		local colors_settings = {
			BLUE =      { 	x = 523, 	            color = { 1, 177, 250, 220 } 	},
			RED =       { 	x = 523 + 38, 	        color = { 250, 1, 1, 220 } 		},
			YELLOW =    { 	x = 523 + 38 * 2,	    color = { 250, 207, 1, 220 } 	},
			GRAY =      { 	x = 523 + 38 * 3,       color = { 130, 131, 131, 220 } 	},
			WHITE =     { 	x = 523 + 38 * 4,	    color = { 255, 255, 255, 220 } 	},
			BLACK =     { 	x = 523 + 38 * 5,	    color = { 0, 0, 0, 220 } 		},
		}
		--Сразу выбираем стандартный цвет
		local selected = "WHITE"
		for i, v in pairs( colors_settings ) do
			--Формула вычисления нужного нам смещения из-за свечения (glow.size - colorbox.size) / 2
			colors_settings[i].image = ibCreateImage( v.x - 14, 293, 24, 24, "img/overlays/vehicle_details/color_glow.png", parent, 0xFFFFFFFF )
            :ibSetRealSize( )
            :ibData( "alpha", i == selected and 255 or 0 )

            ibCreateImage( v.x, 307, 24, 24, nil, parent, tocolor( unpack( v.color ) ) )
			:ibOnHover( function( ) colors_settings[ i ].image:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) if selected == i then return end colors_settings[i].image:ibAlphaTo( 0, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --Убираем подсветку с прошлого выбранного цвета
                colors_settings[selected].image:ibAlphaTo( 0, 200 )
                --Сохраняем ключ активного элемента
                selected = i
            end )
		end

		--Кнопка "Купить"
		ibCreateButton( 631, 360, 0, 0, parent, "img/overlays/vehicle_details/btn_buy.png", "img/overlays/vehicle_details/btn_buy_h.png", "img/overlays/vehicle_details/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibSetRealSize()
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				SendElasticGameEvent( "f4r_f4_unique_auto_purchase_button_click" )
				ibConfirm(
					{
						title = "ПОКУПКА ТРАНСПОРТА", 
						text = "Ты хочешь купить "..VEHICLE_CONFIG[ data.model ].model.." за",
                        cost = cost,
                        cost_is_soft = false,
						fn = function( self )
							data.color = colors_settings[ selected ].color
							SendElasticGameEvent( "f4r_f4_unique_auto_confirmation_ok_click" )
							triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, data.id, data.name, data.segment, data.color )
							self:destroy( )
                        end,
                        escape_close = true,
					}
				)
			end )
    end,

    [ OVERLAY_CHANGE_NUMBERPLATE_REGION ] = function( parent, data )
        CreateHideButton( parent )
        local footer_sy = 30 + 42 + 30

        local vehicles_area = ibCreateArea( 0, 0, 0, 0, parent )

        local show_select_region, update_regions_list
        
		-- Colums
		ibCreateLabel( 30, 65, 0, 0, "Номерной знак", vehicles_area, 0x4cffffff, _, _, _, _, ibFonts.regular_12 )
		ibCreateLabel( 196, 65, 0, 0, "Автомобиль", vehicles_area, 0x4cffffff, _, _, _, _, ibFonts.regular_12 )

        -- Vehicles List
        local scrollpane, scrollbar = ibCreateScrollpane( 0, 80, parent:width( ), parent:height( ) - 80 - footer_sy, vehicles_area, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

        local py = 0
        for k,v in pairs( localPlayer:GetVehicles( ) ) do
        	local sNumber = v:GetNumberPlate( )
            local pNumber = split( sNumber, ":" )
            local iNumberType = tonumber( pNumber[1] )

        	if iNumberType == PLATE_TYPE_AUTO or iNumberType == PLATE_TYPE_SPECIAL then
                local region = string.sub( pNumber[2], -2 )
                local is_flag = not tonumber( region )
                local plate = ibCreateImage( 30, py+20, 136, 40, ":nrp_vehicle_numberplates/files/img/icon_number" .. ( is_flag and "_" .. region or "" ) .. ".png", scrollpane )

                ibCreateLabel( 0, 0, 94, 40, string.sub( pNumber[2], 1, -3 ), plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_16 )
                if not is_flag then	ibCreateLabel( 94, 0, 40, 26, region, plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_14 ) end

	        	ibCreateImage( 196, py+25, 40, 30, ":nrp_vehicle_numberplates/files/img/icon_car.png", scrollpane )
	        	ibCreateLabel( 260, py, 0, 80, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 )

	        	ibCreateButton( parent:width( )-150, py+20, 120, 39, scrollpane, ":nrp_vehicle_numberplates/files/img/btn_select.png", ":nrp_vehicle_numberplates/files/img/btn_select_h.png", ":nrp_vehicle_numberplates/files/img/btn_select_h.png" )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						show_select_region( v )
					end )

	        	ibCreateImage( 30, py+79, parent:width( )-60, 1, nil, scrollpane, 0x1affffff )
	        	py = py + 80
	        end
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )

        function show_select_region( selected_vehicle )
            if not isElement( selected_vehicle ) then
                localPlayer:ShowError( "Неизвестная ошибка" )
                return
            end
    
            vehicles_area:ibMoveTo( -parent:width( ), _ )

            -- Номер в заголовке окна F4
    
            local numberplate_area = ibCreateArea( 200, -72, 0, 0, GetCurrentContentArea( ) )
                :ibData( "alpha", 0 ):ibAlphaTo( 255 )
            
            ibCreateLabel( 0, 0, 0, 70, "Ваш номер: ", numberplate_area, 0xffffffff, _, _, "left", "center", ibFonts.regular_14 )

            local sNumber = selected_vehicle:GetNumberPlate( )
            local pNumber = split( sNumber, ":" )
            local region = string.sub( pNumber[2], -2 )
            local is_flag = not tonumber( region )
    
            local plate = ibCreateImage( 91, 16, 136, 40, ":nrp_vehicle_numberplates/files/img/icon_number" .. ( is_flag and "_" .. region or "" ) .. ".png", numberplate_area )

            ibCreateLabel( 0, 0, 94, 40, string.sub( pNumber[2], 1, -3 ), plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_16 )
            if not is_flag then	ibCreateLabel( 94, 0, 40, 26, region, plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_14 ) end

            -- 

            local regions_area = ibCreateArea( parent:width( ), 0, 0, 0, parent )
                :ibMoveTo( 0, _ )
                :ibOnDestroy( function( )
                    numberplate_area:ibAlphaTo( 0 ):ibTimer( destroyElement, 200, 0 )
                end )
    
            local edit_bg = ibCreateImage( 30, 65, 600, 30, ":nrp_vehicle_numberplates/files/img/bg_search.png", regions_area )
                :ibData( "alpha", 255 * 0.5 )
            local edit_field = ibCreateWebEdit( 70, 60, 600-80, 40, "", regions_area, 0x80ffffff, 0 )
                :ibBatchData( {
                    font = "regular_11_400",
                    placeholder = "Введите желаемый регион",
                    placeholder_color = ibApplyAlpha( COLOR_WHITE, 70 ),
                } )
                :ibOnFocusChange( function( focused )
                    edit_bg:ibAlphaTo( focused and 255 or 255 * 0.5, 150 )
                end )
    
            ibCreateButton( 645, 65, 126, 30, regions_area, ":nrp_vehicle_numberplates/files/img/btn_find.png", ":nrp_vehicle_numberplates/files/img/btn_find_h.png", ":nrp_vehicle_numberplates/files/img/btn_find_h.png" )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    local sRequest = edit_field:ibData( "text" )
                    local iRequest = tonumber( sRequest )
    
                    update_regions_list( _, iRequest )
                end )

            local unavailable_regions_list = { }
            local scrollpane, scrollbar

            function update_regions_list( list, request )
                if isElement( scrollpane ) then
                    scrollpane:destroy( )
                    scrollbar:destroy( )
                end
                scrollpane, scrollbar = ibCreateScrollpane( 0, 120, parent:width( ), parent:height( ) - 120 - footer_sy, regions_area, { scroll_px = -20 } )
                scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

                if list then
                    unavailable_regions_list = list or { }
                end

                local available_regions_list = AddFlags( )
                local visible_list = AddFlags( )

                for i = 1, 99 do
                    if not unavailable_regions_list[i] then
                        table.insert( available_regions_list, string.format( "%02d", i ) )
                    end
                end

                local px, py = 40, 30
                if request then
                    for k,v in pairs( available_regions_list ) do
                        if string.find( v, request ) then
                            table.insert( visible_list, v )
                        end
                    end

                    if #visible_list <= 0 then
                        ibCreateLabel( 0, 0, 0, 0, "По вашему запросу, номер региона для текущего государственного\nномера машины отсутствует", scrollpane, 0x99ffffff, _, _, "center", "top", ibFonts.regular_20 )
                            :center_x( )

                        request = math.max( 0, math.min( request, 99 ) )

                        local o = 1
                        while ( #visible_list < 6 and ( request - o > 0 or request + o < 100 ) ) do
                            if request - o > 0 and not unavailable_regions_list[ request - o ] then
                                table.insert( visible_list, string.format( "%02d", request - o ) )
                            end
                            if request + o < 100 and not unavailable_regions_list[ request + o ] then
                                table.insert( visible_list, string.format( "%02d", request + o ) )
                            end
                            o = o + 1
                        end
                        table.sort( visible_list )
                        
                        py = py + 100
                    end
                else
                    visible_list = available_regions_list
                end

                for k,v in pairs( visible_list ) do
                    local plate = ibCreateImage( px, py, 103, 98, ":nrp_vehicle_numberplates/files/img/icon_region" .. ( flags[ v ] and "_" .. v or "" ) .. ".png", scrollpane )
                    
                    local plate_hover = ibCreateImage( px-40, py-40, 183, 178, ":nrp_vehicle_numberplates/files/img/region_hover.png", scrollpane )
                        :ibData( "priority", -1 )
                        :ibData( "disabled", true )
                        :ibData( "alpha", 0 )

                    plate
                        :ibOnHover( function( ) plate_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) plate_hover:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            local cost = localPlayer:GetCostService( flags[ v ] and 9 or 7 )
                            ibConfirm( 
                                {
                                    title = "СМЕНА РЕГИОНА", 
                                    text = "Ты действительно хочешь изменить регион номеров автомобиля ".. VEHICLE_CONFIG[ selected_vehicle.model ].model .." на ".. ( flags[ v ] and flags[ v ] or v ) ..
                                    "?\nСтоимость: "..format_price( cost ),
                                    fn = function( self )
                                        triggerServerEvent( "OnPlayerTryBuyNumberRegion", resourceRoot, selected_vehicle, v, flags[ v ] and true or false )
                                        self:destroy( )
                                    end,
                                    escape_close = true,
                                }
                            )
                        end )

                    if not flags[ v ] then
                        ibCreateLabel( 0, 0, 103, 60, v, plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_40 ):ibData( "disabled", true )
                    end

                    px = px + 123
                    if px >= parent:width( ) - 143 then
                        px = 40
                        py = py + 118
                    end
                end

                scrollpane:AdaptHeightToContents( )
                scrollbar:UpdateScrollbarVisibility( scrollpane )
            end

            local function search_region( key, is_pressed )
                if key ~= "enter" or not is_pressed then return end
                
                local sRequest = edit_field:ibData( "text" )
                local iRequest = tonumber( sRequest )
                update_regions_list( _, iRequest )
            end
            addEventHandler( "onClientKey", root, search_region )
    
            triggerServerEvent( "OnPlayerRequestRegionsList", localPlayer, selected_vehicle )

            addEvent( "OnClientReceiveRegionsList", true )
            addEventHandler( "OnClientReceiveRegionsList", root, update_regions_list )

            local function onClientPlayerBuyNumberPlateRegion_handler( )
                localPlayer:InfoWindow( "Регион номера успешно изменён!" )
                playSound( ":nrp_shared/sfx/fx/buy.wav" )
                HideMenu( parent )
            end
            addEvent( "onClientPlayerBuyNumberPlateRegion", true )
            addEventHandler( "onClientPlayerBuyNumberPlateRegion", root, onClientPlayerBuyNumberPlateRegion_handler )

            regions_area:ibOnDestroy( function( )
                removeEventHandler( "onClientKey", root, search_region )
                removeEventHandler( "OnClientReceiveRegionsList", root, update_regions_list )
                removeEventHandler( "onClientPlayerBuyNumberPlateRegion", root, onClientPlayerBuyNumberPlateRegion_handler )
            end )
        end
    end,
    
    [ OVERLAY_PACK_PURCHASE ]  = function( parent, data )
        local bg = ibCreateImage( 0, 0, parent:width( ), parent:height( ), _, parent, 0xFF1f2934 )

        -- Название пака
        local area_name = ibCreateArea( 0, 28, 0, 0, bg )
        local lbl_name = ibCreateLabel( 0, 0, 0, 0, "Набор «" .. data.name .. "»", area_name, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )
        
        local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_pack", data.cost )
        if coupon_discount_value then
            CreateDiscountCoupon( 25, 370, "special_pack", coupon_discount_value, bg )
        end

        -- Выгода %
        local discount = math.ceil( ( 1 - cost / data.cost_original ) * 100 )
        local bg_discount = ibCreateImage( lbl_name:ibGetAfterX( 10 ), -11, 116, 24, "img/special_offers/bg_discount.png", area_name )
		ibCreateLabel( 0, -1, 0, 0, "ВЫГОДА " .. discount .. "%", bg_discount, 0xFFFFFFFF, _, _, "center", "center", ibFonts.extrabold_14 ):center( )
        area_name:ibData( "sx", bg_discount:ibGetAfterX( ) ):center_x( )

        ibCreateLabel( 0, 54, 0, 0, "Вы получите:", parent, _, _, _, "center", "center", ibFonts.regular_16 ):center_x( )

        ibCreateContentImage( 0, 75, 800, 270, "pack", data.model, bg )

        -- Названия предметов
        local name_lbls_px = {
            skin = 122,
            vehicle = 396,
            tuning_case = 674,
        }
        for i, item in ipairs( data.items ) do
            local item_class = REGISTERED_ITEMS[ item.id ]
            local description_data = item_class.uiGetDescriptionData_func( item.id, item.params )
            ibCreateLabel( name_lbls_px[ item.id ], 94, 0, 0, description_data.title, parent, _, _, _, "center", "center", ibFonts.regular_14 )
        end

        -- Статы машины

        local veh_conf
        for i, item in pairs( data.items ) do
            if item.id == "vehicle" then
                veh_conf = VEHICLE_CONFIG[ item.params.model ].variants[ item.params.variant or 1 ]
            end
        end

        if veh_conf then
            ibCreateImage( 255, 279, 266, 78, "img/overlays/special_packs/bg_vehicle_stats.png", parent )

            local progressbar_width = 218
            local function getProgressWidth( value, maximum )
                return ( ( value / maximum ) * progressbar_width ) > progressbar_width and progressbar_width or ( value / maximum ) * progressbar_width
            end

            -- Максимальная скорость
            ibCreateLabel( 302, 291, 218, 0, veh_conf.max_speed .. " км/ч", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_9 )
            ibCreateImage( 302, 305, 0, 7, _, parent, 0xFFFF965D )
                :ibResizeTo( getProgressWidth( veh_conf.max_speed, 400 ), _, 800, "InOutQuad" )

            -- Разгон от 0 до 100
            ibCreateLabel( 302, 321, 218, 0, veh_conf.ftc .. " c", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_9 )
            ibCreateImage( 302, 335, 0, 7, _, parent, 0xFFFF965D )
                :ibResizeTo( getProgressWidth( veh_conf.ftc, 30 ), _, 800, "InOutQuad" )
        end
		
        --Цена
        ibCreateImage( 214, 360, 154, 63, "img/overlays/special_packs/bg_cost.png", parent )

        local lbl_cost_original = ibCreateLabel( 367, 363, 0, 0, format_price( data.cost_original ), parent,ibApplyAlpha( 0xFFFFFFFF, 75 ), _, _, _, _, ibFonts.bold_16 )
        ibCreateLine( 345, 374, lbl_cost_original:ibGetAfterX( 2 ), _, 0xFFFFFFFF, 1, parent )

        ibCreateLabel( 327, 379, 0, 0, format_price( cost ), parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_27)

		--Кнопка "Купить"
		ibCreateButton( 438, 365, 0, 0, parent, "img/overlays/vehicle_details/btn_buy.png", "img/overlays/vehicle_details/btn_buy_h.png", "img/overlays/vehicle_details/btn_buy.png" )
			:ibSetRealSize()
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				SendElasticGameEvent( "f4r_f4_unique_pack_purchase_button_click" )
				ibConfirm(
					{
						title = "ПОКУПКА НАБОРА", 
                        text = "Ты хочешь купить набор “" .. data.name .. "” за ",
                        cost = cost,
                        cost_is_soft = false,
						fn = function( self )
							SendElasticGameEvent( "f4r_f4_unique_pack_confirmation_ok_click" )
							triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, data.id, data.name, data.segment )
							self:destroy( )
                        end,
                        escape_close = true,
					}
				)
			end )

		CreateHideButton( parent )
    end,

    [ OVERLAY_EXPAND_INVENTORY_VEHICLE ] = function( parent, data )
        CreateHideButton( parent )
        
        ibCreateLabel( 0, 78, parent:width( ), 0, "Расширение багажника", parent, 0xffffffff, _, _, "center" ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( 0, 105, parent:width( ), 0, "Выберете машину для расширения размера инвентаря", parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, parent:width( ), 250, parent, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local sx, sy = parent:width( ), 74
        local px, py = 0, 0

        ibCreateImage( 30, 140, sx-60, 1, nil, parent, 0xFF59616A )

        local py = 0
        for k, v in pairs( localPlayer:GetVehicles( ) ) do
        	if VEHICLES_MAX_WEIGHTS[ v.model ] then
                local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
    
                ibCreateImage( px+30, py+sy/2-16, 49, 33, "img/icon_vehicle.png", scrollpane ):ibData( "disabled", true )
                ibCreateLabel( px+100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )
                
                ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0xFF59616A )
    
                ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png" )
                    :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        -- SendElasticGameEvent( "f4r_f4_unique_auto_accessory_choose_auto_click" )
                        ibConfirm(
                            {
                                title = "РАСШИРЕНИЕ БАГАЖНИКА", 
                                text = "Ты действительно хочешь расширить вместимость багажника этого автомобиля на " .. SHOP_SERVICES.inventory_vehicle.value .. " ед. за",
                                cost = SHOP_SERVICES.inventory_vehicle.cost,
                                cost_is_soft = false,
                                fn = function( self )
                                    -- SendElasticGameEvent( "f4r_f4_unique_auto_accessory_confirmation_ok_click" )
                                    triggerServerEvent( "onPlayerWantExpandInventory", resourceRoot, v )
                                    self:destroy( )
                                end,
                                escape_close = true,
                            }
                        )
                    end )
                py = py + sy
            end
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
	
    [ OVERLAY_EXPAND_INVENTORY_HOUSE ] = function( parent, data )
        CreateHideButton( parent )
        
        ibCreateLabel( 0, 78, parent:width( ), 0, "Расширение хранилища", parent, 0xffffffff, _, _, "center" ):ibData( "font", ibFonts.bold_16 )
        ibCreateLabel( 0, 105, parent:width( ), 0, "Выберете недвижимость для расширения размера инвентаря", parent, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "center", _, ibFonts.regular_14 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, parent:width( ), 250, parent, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local sx, sy = parent:width( ), 74
        local px, py = 0, 0

        ibCreateImage( 30, 140, sx-60, 1, nil, parent, 0xFF59616A )

        for i, v in pairs( localPlayer:GetAllHousesList() ) do
            local location_name, house_name, house_image_path = exports.nrp_house_sale:GetHouseHumanViewData( v )

            local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

            ibCreateImage( px+30, py+sy/2-16, 0, 0, "img/services/house/" .. house_image_path, scrollpane ):ibData( "disabled", true ):ibSetRealSize()
            ibCreateLabel( px+83, py, 0, sy, house_name .. " (" .. location_name .. ")", scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )
            
            ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0xFF59616A )

            ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png" )
                :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    -- SendElasticGameEvent( "f4r_f4_unique_auto_accessory_choose_auto_click" )
                    ibConfirm(
                        {
                            title = "РАСШИРЕНИЕ ХРАНИЛИЩА",
                            text = "Ты действительно хочешь расширить вместимость ящика этого дома на " .. SHOP_SERVICES.inventory_house.value .. " ед. за",
                            cost = SHOP_SERVICES.inventory_house.cost,
                            cost_is_soft = false,
                            fn = function( self )
                                -- SendElasticGameEvent( "f4r_f4_unique_auto_accessory_confirmation_ok_click" )
                                triggerServerEvent( "onPlayerWantExpandInventory", resourceRoot, v.id .. "_" .. v.number )
                                self:destroy( )
                            end,
                            escape_close = true,
                        }
                    )
                end )
            py = py + sy
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}

function CreateHideButton( parent )
    ibCreateImage( 0, 436, 0, 0, "img/btn_notification_hide.png", parent )
        :ibSetRealSize( )
        :center_x( )
        :ibData( "alpha", ibGetAlpha( 75 ) )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( ibGetAlpha( 75 ), 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            HideMenu( parent )
        end )
end

function HideMenu( parent )
    parent
        :ibData( "disabled", true )
        :ibMoveTo( _, parent:height( ), 150 )

    getElementParent( parent )
        :ibTimer( function( self ) self:destroy( ) end, 150, 1 )
end