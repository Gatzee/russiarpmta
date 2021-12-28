loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShVehicle" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShVehicleConfig" )
Extend( "ShApartments" )
Extend( "ShBounty" )
Extend( "ShSkin" )
Extend( "ShAccessories" )
Extend( "ShVinyls" )
Extend( "ShPhone" )
Extend( "ShClothesShops" )
Extend( "ShInventoryConfig" )
Extend( "CPayments" )
Extend( "ShDiseases" )

ibUseRealFonts( true )

TABS_CONF = { }

CONST_GET_DATA_URL = nil

function onClientResourceStart_handler( )
    -- Генерация слайдеров для спешелухи
    SPECIAL_SLIDER_GENERATE_FNS = {
        vehicle = function( offer )
            return {   
                id = "vehicle" .. offer.model,
                active = function( )
                    return IsSpecialOfferActive( offer )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/bg_vehicle.png", parent )
                    ibCreateContentImage( 67, 25, 300, 160, "vehicle", offer.model, bg )
                    ibCreateLabel( 380, 36, 0, 0, "Встречайте " .. offer.name .. "!", bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
                    local lbl_cost_original = ibCreateLabel( 524, 100, 0, 0, format_price( offer.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_16 )
                    ibCreateLine( 498, 100, lbl_cost_original:ibGetAfterX( 3 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
                    local lbl_cost = ibCreateLabel( 557, 126, 0, 0, format_price( offer.cost ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_24 )
                    if offer.finish_date then
                        CreateHumanTimer( 380, 55, bg, "Закончится через:", offer.finish_date )
                    end
                    CreateDetailsButton( 380, 146, bg )
                    return bg
                end,
            }
        end,
        
        skin = function( offer )
            return {   
                id = "skin" .. offer.model,
                active = function( )
                    return IsSpecialOfferActive( offer )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/bg_skin.png", parent )
                    ibCreateContentImage( 67, -10, 300, 220, "skin", offer.model, bg )
                    CreateHumanTimer( 380, 83, bg, "Закончится через:", offer.finish_date )
                    CreateDetailsButton( 380, 119, bg )
                    return bg
                end,
            }
        end,

        accessory = function( offer )
            return {   
                id = "accessory" .. offer.model,
                active = function( )
                    return IsSpecialOfferActive( offer )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/bg_accessory.png", parent )
                    ibCreateContentImage( 67, 15, 300, 180, "accessory", offer.model, bg )
                    CreateHumanTimer( 380, 83, bg, "Закончится через:", offer.finish_date )
                    CreateDetailsButton( 380, 119, bg )
                    return bg
                end,
            }
        end,

        pack = function( offer )
            return {   
                id = "pack" .. offer.model,
                active = function( )
                    return IsSpecialOfferActive( offer )
                end,
                fn = function( parent )
                    local bg = ibCreateContentImage( 0, 278, 741, 210, "pack", offer.model, parent )
                    CreateHumanTimer( 380, 55, bg, "Закончится через:", offer.finish_date, true )
                    local lbl_cost_original = ibCreateLabel( 524, 100, 0, 0, format_price( offer.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_16 )
                    ibCreateLine( 498, 100, lbl_cost_original:ibGetAfterX( 3 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
                    local lbl_cost = ibCreateLabel( 557, 126, 0, 0, format_price( offer.cost ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_24 )
                    CreateDetailsButton( 380, 146, bg )
                    return bg
                end,
            }
        end,
    }

    function GenerateSlidersForSpecials( )
        AVAILABLE_SLIDERS.special = { }
        for k, offer in pairs( OFFERS_LIST ) do
            if SPECIAL_SLIDER_GENERATE_FNS[ offer.class ] then
                if IsSpecialOfferActive( offer ) then
                    table.insert( AVAILABLE_SLIDERS.special, SPECIAL_SLIDER_GENERATE_FNS[ offer.class ]( offer ) )
                end
            end
        end
    end

    -- Слайдеры в меню (все возможные)
    AVAILABLE_SLIDERS = {
        special = { },
        other = {
            {
                id = "transfer",
                active = function( )
                    return localPlayer:getData( "account_transfer" )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_transfer.png", parent )

                    ibCreateImage( 385, 118, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "march_offer",
                active = function( )
                    local offer = localPlayer:getData( "march_offer" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_march_offer.png", parent )

                    local offer = localPlayer:getData( "march_offer" )
                    CreateSliderTimer( offer.finish_ts, 381, 83, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowOffer8March", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "battle_pass",
                active = function( )
                    return ( exports.nrp_battle_pass:GetCurrentSeasonEndDate( ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_battle_pass.png", parent )

                    CreateHumanTimer( 538, 72, bg, "", exports.nrp_battle_pass:GetCurrentSeasonEndDate( ), true, true )

                    ibCreateImage( 373, 129, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
                            ShowDonateUI( false )
                        end )
                    return bg
                end,
            },
            {
                id = "annuity_payment",
                active = function( )
                    if localPlayer:getData( "annuity_payment" ) then return end

                    local ts = getRealTimestamp( )
                    local annuity_payment_timeout = localPlayer:getData( "annuity_payment_timeout" )
                    return annuity_payment_timeout and annuity_payment_timeout >= ts
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 741, 221, "img/sliders/slider_annuity_payment.png", parent )
                    CreateSliderTimer( localPlayer:getData( "annuity_payment_timeout" ), 384, 74, bg )

                    ibCreateButton( 379, 154, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "payoffer",
                active = function( )
                    local ts = getRealTimestamp( )
                    return PAYOFFER and PAYOFFER.start <= ts and PAYOFFER.finish >= ts
                end,
                fn = function( parent )
                    local name = PAYOFFER.name
                    local bg_textures = {
                        newyear = "slider_newyear",
                        format1 = "slider_payoffer_format1",
                        format2 = "slider_payoffer_format2",
                        format3 = "slider_payoffer_format3",
                    }
                    local bg_tex = bg_textures[ name ] or "slider_payoffer"
                    local x_offsets = {
                        format1 = 41,
                        format2 = 41,
                        format3 = 41,
                    }
                    local x_offset = x_offsets[ name ] or 0

                    local friendly_name = PAYOFFER.friendly_name and PAYOFFER.friendly_name or "Акция на донат валюту"
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/" .. bg_tex .. ".png", parent )
                    CreateSliderTimer( PAYOFFER and PAYOFFER.finish or getRealTimestamp( ) + 24 * 60 * 60, 335 + x_offset, 89, bg )
                    ibCreateLabel( 335 + x_offset, 50, 0, 0, friendly_name, bg, COLOR_WHITE, _, _, "left", "top", ibFonts.bold_19 )
                    ibCreateButton( 332 + x_offset, 140, 156, 38, bg, "img/sliders/btn_check.png",
                        "img/sliders/btn_check.png", "img/sliders/btn_check.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        SwitchNavbar( "offers", "slider" )
                    end )

                    return bg
                end,
            },
            {
                id = "returnoffer",
                active = function( )
                    local offer_data = localPlayer:getData( "offer_data" )
                    return offer_data and offer_data.time_finish > getRealTimestamp( )
                end,
                fn = function( parent )
                    local text = {
                        "Удваиваем платеж!\nАкция действует 48 часов",
                        "Утраиваем платеж!\nАкция действует 48 часов",
                    }
                    local offer_data = localPlayer:getData( "offer_data" )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_returnoffer.png", parent )
                    CreateSliderTimer( offer_data.time_finish, 256, 89, bg )
                    ibCreateLabel( 410, 87, 0, 0, text[ offer_data.offer ], bg, _, _, _, _, _, ibFonts.regular_14 )
                    ibCreateButton( 250, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "onClientPlayerShowCurrentOfferRequest", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_for_whales",
                active = function( )
                    local offer_end_time = localPlayer:getData( "offer_for_whales" )
                    return offer_end_time and offer_end_time > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_for_whales.png", parent )

                    local end_time = localPlayer:getData( "offer_for_whales" )
                    CreateSliderTimer( end_time, 380, 80, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "onPlayerShowSpecialOfferForWhales", localPlayer )
                        end )
                    return bg
                end,
            },
            {   
                id = "retention_tasks",
                active = function( )
                    local ts = getRealTimestamp( )
                    return next( CONF.retention_tasks ) ~= nil
                end,
                fn = function( parent )
                    local retention_tasks = CONF.retention_tasks
                    local reward_sum = 0
                    local earliest_finish = math.huge
                    local reward_name

                    for id, data in pairs( retention_tasks ) do
                        reward_sum = reward_sum + ( localPlayer:getData( "economy_hard_test" ) and (exports.nrp_retention_tasks:GetRetentionTaskValue( id, "reward_economy_test" ) or 0) or (exports.nrp_retention_tasks:GetRetentionTaskValue( id, "reward" ) or 0) )
                        earliest_finish = math.min( earliest_finish, data.timestamp_end )

                        local name = exports.nrp_retention_tasks:GetRetentionTaskValue( id, "reward_name" )
                        reward_name = name and name or reward_name
                    end

                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/retention_tasks/retention_tasks.png", parent )
                    
                    ibCreateImage( 387, 140, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )

                    ibCreateLabel( 389, 32, 0, 0, "Встречай уникальные акции!", bg, _, _, _, _, _, ibFonts.bold_18 )
                    
                    CreateHumanTimer( 389, 68, bg, "Продлятся еще:", earliest_finish, true )

                    local lbl_reward = ibCreateLabel( 389, 105, 0, 0, "Награда:", bg, _, _, _, _, _, ibFonts.regular_14 )

                    if reward_name then
                        ibCreateLabel( 389 + 65, 102, 0, 0, reward_name, bg, _, _, _, _, _, ibFonts.bold_18 )
                    else
                        local lbl_amount = ibCreateLabel( lbl_reward:ibGetAfterX( 5 ), lbl_reward:ibData( "py" ) - 10, 0, 0, format_price( reward_sum ), bg, _, _, _, _, _, ibFonts.bold_28 )
                        local icon_soft = ibCreateImage( lbl_amount:ibGetAfterX( 5 ), lbl_amount:ibGetCenterY( -13 ), 30, 26, "img/special_offers/icon_soft.png", bg )
                    end

                    return bg
                end,
            },
            {   
                id = "1september",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts >= 1567134000 and ts <= 1567814400
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_1september.png", parent )
                    ibCreateImage( 372, 140, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "cases30",
                active = function( )
                    local discounts = HasDiscounts( )
                    return discounts and discounts.id == "cases30_weekly"
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_cases30.png", parent )
                    CreateSliderTimer( GetDiscountFinishTime( ), 399, 87, bg )
                    ibCreateButton( 397, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "cases", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "cases30_last_discount",
                active = function( )
                    local discounts = HasDiscounts( )
                    return discounts and discounts.id == "cases30_last_discount"
                end,
                fn = function( parent )
                    local discounts = HasDiscounts( )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_cases30_last_discount.png", parent )
                    CreateSliderTimer( discounts.finish_time, 380, 87, bg )
                    ibCreateButton( 397, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "cases", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "special_x2",
                active = function( )
                    return ( tonumber( localPlayer:getData( "x2_offer_finish" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_x2.png", parent )
                    CreateSliderTimer( localPlayer:getData( "x2_offer_finish" ), 256, 89, bg )
                    ibCreateButton( 257, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowX2UI_Remembered", root )
                        end )
                    return bg
                end,
            },

            {
                id = "offer_vehicle",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_vehicle_finish" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_personal_vehicle.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_vehicle_finish" ), 381, 77, bg )
                    ibCreateButton( 381, 135, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "onClientTryShowOfferVehicle", root )
                        end )
                    return bg
                end,
            },

            {
                id = "offer_comfort",
                active = function( )
                    return ( tonumber( localPlayer:getData( "comfort_test_offer_end_date" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_offer_comfort.png", parent )
                    CreateSliderTimer( localPlayer:getData( "comfort_test_offer_end_date" ), 383, 87, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "onPlayerShowOfferComfortStart", localPlayer, true )
                        end )
                    return bg
                end,
            },

            {
                id = "offer_gun_license_slider",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_gun_license_time_left" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_gun_license.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_gun_license_time_left" ), 380, 87, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "onShowOfferWeaponLicense", root, true )
                        end )
                    return bg
                end,
            },

            {
                id = "offer_newyear_auction_slider",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_newyear_auction_time_left" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_newyear_auction.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_newyear_auction_time_left" ), 381, 96, bg )
                    ibCreateButton( 382, 147, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerServerEvent( "onServerPlayerRequestNewYearAuction", localPlayer )
                        end )
                    return bg
                end,
            },

            {
                id = "slider_ingame_draw",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_ingame_draw" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_ingame_draw.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_ingame_draw" ), 381, 74, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )

                            triggerServerEvent( "onServerRequestIngameDraw", root )
                        end )
                    return bg
                end,
            },

            {
                id = "slider_valentine_day",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_valentine_day_time_left" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_valentine_day_" .. GetCurrentSegment() .. ".png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_valentine_day_time_left" ), 381, 96, bg )
                    ibCreateButton( 381, 147, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            
                            triggerServerEvent( "onServerRequestShowValentineDayOffer", root )
                        end )
                    return bg
                end,
            },

            {
                id = "slider_defender_fatherland_day",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_defender_fatherland_day_time_left" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_defender_fatherland_day_" .. GetCurrentSegment() .. ".png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_defender_fatherland_day_time_left" ), 379, 77, bg )
                    ibCreateButton( 379, 130, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            
                            triggerServerEvent( "onServerRequestShowDefenderFatherlandDayOffer", root )
                        end )
                    return bg
                end,
            },

            {
                id = "slider_discount_gift",
                active = function( )
                    return ( tonumber( localPlayer:getData( "offer_discount_gift_time_left" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_discount_gift.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_discount_gift_time_left" ), 381, 74, bg )
                    ibCreateButton( 381, 127, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            
                            triggerEvent( "onClientShowOfferDiscountGift", root )
                        end )
                    return bg
                end,
            },

            {
                id = "slider_cardiscount",
                active = function( self )
                    local data = localPlayer:GetAllVehiclesDiscount( )
                    return data and data.timestamp >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_cardiscount.png", parent )
                    CreateSliderTimer( localPlayer:GetAllVehiclesDiscount( ).timestamp, 380, 79, bg )
                    
                    ibCreateImage( 378, 131, 0, 0, "img/sliders/btn_show_on_map.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ToggleGPS", localPlayer, {
                                { x = -1011.761, y = -1478.894, z = 21.741 },
                                { x = -362.385, y = -1752.450, z = 20.928 },
                                { x = 1792.201, y = -625.773, z = 60.704 },
                                { x = 2044.341, y = -803.662, z = 62.621 },
                                { x = 1242.287, y = 2466.162, z = 11.046 },
                            } )
                        end )
                    return bg
                end,
            },
            {
                id = "big_discount",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts >= getTimestampFromString( "28 сентября 2019 00:00" ) and ts <= getTimestampFromString( "29 сентября 2019 23:59" )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 740, 210, "img/sliders/slider_big_discount.png", parent )
                    ibCreateButton( 417, 122, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "segmented_premium",
                active = function( self )
                    local discount = GetPremiumDiscountFinishTime( ) and HasPremiumDiscounts( )
                    return discount and ( discount.id == "segmented_premium" or discount.id == "premium_discount" )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_segmented_premium.png", parent )
                    local img = ibCreateImage( 290, 100, 22, 24, "img/icon_timer.png", bg )
                    local time_desc_label = ibCreateLabel( img:ibGetAfterX( 10 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.regular_14 )
                    local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                    
                    local function UpdateTime( self )
                        if not GetPremiumDiscountFinishTime( ) then
                            self:destroy()
                            return
                        end
                        time_label:ibData( "text", getHumanTimeString( GetPremiumDiscountFinishTime( ), true ) )
                    end
                    UpdateTime( )
                    time_label:ibTimer( UpdateTime, 500, 0 )

                    ibCreateImage( 290, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "premium", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "special_3days",
                active = function( )
                    return ( tonumber( localPlayer:getData( "3days_offer_finish" ) ) or 0 ) > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 232, "img/sliders/slider_3days.png", parent )
                    CreateSliderTimer( localPlayer:getData( "3days_offer_finish" ), 256, 89, bg )
                    ibCreateButton( 257, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "Show3days_Remembered", root )
                        end )
                    return bg
                end,
            },
            {
                id = "vinyl",
                active = function( self )
                    local ts = getRealTimestamp( )

                    if not OFFERS_ARRAY or not OFFERS_ARRAY.special then
                        return false
                    end

                    for k, offer in pairs( OFFERS_ARRAY.special ) do
                        if offer and offer.class == "vinyl" then
                            if ts >= offer.start_date and ts <= offer.finish_date then
                                self.finish_date = offer.finish_date
                                return true
                            end
                        end
                    end
                end,
                fn = function( parent, self )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_vinyls.png", parent )
                    CreateHumanTimer( 380, 89, bg, "Закончится через:", self.finish_date, true )
                    CreateDetailsButton( 379, 120, bg )
                    return bg
                end,
            },
            {
                id = "neon",
                active = function( self )
                    local ts = getRealTimestamp( )

                    if not OFFERS_ARRAY or not OFFERS_ARRAY.special then
                        return false
                    end

                    for k, offer in pairs( OFFERS_ARRAY.special ) do
                        if offer and offer.class == "neon" then
                            if ts >= offer.start_date and ts <= offer.finish_date then
                                self.finish_date = offer.finish_date
                                return true
                            end
                        end
                    end

                    return false
                end,
                fn = function( parent, self )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_neons.png", parent )
                    CreateDetailsButton( 380, 120, bg )
                    CreateHumanTimer( 380, 80, bg, "Закончится через:", self.finish_date, true  )
                    return bg
                end,
            },
            {   
                id = "number_plates",
                active = function( )
                    local ts = getRealTimestamp()

                    if not OFFERS_ARRAY or not OFFERS_ARRAY.special then
                        return false
                    end

                    for k, offer in pairs(OFFERS_ARRAY.special) do
                        if offer and offer.class == "numberplate" then
                            if ts >= offer.start_date and ts <= offer.finish_date then
                                return true
                            end
                        end
                    end

                    return false
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_numbers.png", parent )

                    CreateDetailsButton( 380, 120, bg )
                    
                    local next_finish_date
                    local iCurrentTimestamp = getRealTimestamp()

                    for k, offer in pairs(OFFERS_ARRAY.special) do
                        if offer and offer.class == "numberplate" then
                            if iCurrentTimestamp > offer.start_date and iCurrentTimestamp < offer.finish_date then
                                next_finish_date = offer.finish_date
                                break
                            end
                        end
                    end

                    CreateHumanTimer( 380, 87, bg, "Акция действует ещё:", next_finish_date, true  )

                    return bg
                end,
            },
            {
                id = "slider_fnf",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts <= 1567630800 + 14 * 24 * 60 * 60 and ts >= 1567630800
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 221, "img/sliders/slider_fnf.png", parent )
                        :ibData( "alpha", 245 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 245, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "special", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "halloween",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts >= getTimestampFromString( "29 октября 2020 00:00" ) and ts <= getTimestampFromString( "12 ноября 2020 23:59" )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_halloween.png", parent )

                    ibCreateImage( 379, 120, 156, 38, "img/sliders/btn_details_common.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "new_year_event",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts >= EVENTS_TIMES.new_year.from and ts <= EVENTS_TIMES.new_year.to
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_new_year_event.png", parent )

                    ibCreateImage( 379, 120, 156, 38, "img/sliders/btn_details_common.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "may_events",
                active = function( )
                    local ts = getRealTimestamp( )
                    return ts >= EVENTS_TIMES.may_events.from and ts <= EVENTS_TIMES.may_events.to
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_may_events.png", parent )

                    ibCreateImage( 379, 120, 156, 38, "img/sliders/btn_details_common.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {   
                id = "slider_birthday",
                active = function( self )
                    local ts = getRealTimestamp( )
                    if ts >= getTimestampFromString( "12 декабря 2019 00:00" ) and ts <= getTimestampFromString( "15 декабря 2019 23:59" ) then 
                        return true
                    end
                    return false
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_birtthday.png", parent )

                    ibCreateImage( 378, 141, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerServerEvent( "onPlayerRequestShowBirthdayEvent", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_businesses_offer",
                active = function( )
                    local businesses_offer = localPlayer:getData( "businesses_offer" )
                    return businesses_offer and businesses_offer.segment > 0 and businesses_offer.count > 0 and businesses_offer.end_timestamp > getRealTimestamp( )
                end,
                fn = function( parent )
                    local businesses_offer = localPlayer:getData( "businesses_offer" )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_businesses_offer.png", parent )
                    CreateSliderTimer( businesses_offer.end_timestamp, 336, 83, bg )
                    ibCreateButton( 330, 140, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowBusinessesOffer", root )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_apartments_offer",
                active = function( )
                    local apartments_offer = localPlayer:getData( "apartments_offer" )
                    return apartments_offer and apartments_offer > getRealTimestamp( )
                end,
                fn = function( parent )
                    local apartments_offer = localPlayer:getData( "apartments_offer" )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_apartments_offer.png", parent )
                    CreateSliderTimer( apartments_offer, 370, 83, bg )
                    ibCreateButton( 365, 139, 156, 38, bg,
                                    "img/sliders/btn_check.png", "img/sliders/btn_check.png", "img/sliders/btn_check.png",
                                    0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowApartmentsOffer", root )
                        end )
                    return bg
                end,
            },
            {
                id = "vinyl_cases_discount",
                active = function( )
                    return exports.nrp_vinyl_cases_discount:IsOfferActive( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_vinyl_cases_discount.png", parent )

                    ibCreateImage( 380, 104, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SwitchNavbar( "offers", "slider" )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_for_3rd_payment",
                active = function( )
                    local offer_end_time = localPlayer:getData( "third_payment_end_date" )
                    return offer_end_time and offer_end_time > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 290, 741, 210, "img/sliders/slider_3rd_payment.png", parent )

                    local end_time = localPlayer:getData( "third_payment_end_date" )
                    CreateSliderTimer( end_time, 381, 73, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowOfferThirdPaymentUI_Remembered", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "bp_premium_offer",
                active = function( )
                    local offer = localPlayer:getData( "bp_premium_offer" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_bp_premium_offer.png", parent )

                    local offer = localPlayer:getData( "bp_premium_offer" )
                    CreateSliderTimer( offer.finish_ts, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "BP:ShowPremiumOffer", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "bp_booster_offer",
                active = function( )
                    local offer = localPlayer:getData( "bp_booster_offer" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_bp_booster_offer.png", parent )

                    local offer = localPlayer:getData( "bp_booster_offer" )
                    CreateSliderTimer( offer.finish_ts, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "BP:ShowBoosterOffer", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "bp_boosters_discount",
                active = function( )
                    local offer = localPlayer:getData( "bp_boosters_discount" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_bp_booster_offer.png", parent )

                    local offer = localPlayer:getData( "bp_boosters_discount" )
                    CreateSliderTimer( offer.finish_ts, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "BP:ShowBoosterOffer", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "bp_hard_offer",
                active = function( )
                    local offer = localPlayer:getData( "bp_hard_offer" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_bp_hard_offer.png", parent )

                    local offer = localPlayer:getData( "bp_hard_offer" )
                    CreateSliderTimer( offer.finish_ts, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "BP:ShowHardOffer", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "bosow_bundle",
                active = function( )
                    local offer = localPlayer:getData( "bosow_bundle" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_bosow_bundle.png", parent )

                    local offer = localPlayer:getData( "bosow_bundle" )
                    CreateSliderTimer( offer.finish_ts, 379, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowBosowBundle", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "danilych_bundle",
                active = function( )
                    local offer = localPlayer:getData( "danilych_bundle" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_danilych_bundle.png", parent )

                    local offer = localPlayer:getData( "danilych_bundle" )
                    CreateSliderTimer( offer.finish_ts, 379, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowDanilychBundle", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "cases_pack_offer",
                active = function( )
                    local offer = localPlayer:getData( "cases_pack_offer" )
                    return offer and offer.finish_ts > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_cases_pack_offer.png", parent )

                    local offer = localPlayer:getData( "cases_pack_offer" )
                    CreateSliderTimer( offer.finish_ts, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowCasesPackOffer", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "cases_premium_discount",
                active = function( )
                    local discounts = HasDiscounts( )
                    return discounts and discounts.id == "cases_premium_discount" and discounts.finish_time > getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_cases_premium_discount.png", parent )

                    local discounts = HasDiscounts( )
                    local case_id = next( discounts.array )
                    ibCreateContentImage( 148, 1, 360, 280, "case", case_id, bg ):ibBatchData( { sx = 232, sy = 180 } )
                    local case_id = next( discounts.array, case_id )
                    ibCreateContentImage( 24, -4, 360, 280, "case", case_id, bg ):ibBatchData( { sx = 275, sy = 214 } )

                    CreateSliderTimer( discounts.finish_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowCasesPremuimDiscount", localPlayer )
                        end )
                    return bg
                end,
            },
            {
                id = "premium_discount",
                active = function( )
                    return ( ( localPlayer:getData( "offer_premium_fast" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_premium_discount.png", parent )

                    local end_time = localPlayer:getData( "offer_premium_fast" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPremiumDaily", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "premium_extension",
                active = function( )
                    return ( ( localPlayer:getData( "offer_premium_extension" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_premium_extension.png", parent )

                    local end_time = localPlayer:getData( "offer_premium_extension" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPremiumExtension", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_5lvl_up",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_5lvl_up" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_5lvl_up.png", parent )

                    local end_time = localPlayer:getData( "offer_short_5lvl_up" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOffer5LVL", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_vacation_time",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_vacation_time" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_vacation_time.png", parent )

                    local end_time = localPlayer:getData( "offer_short_vacation_time" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferVacationTime", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_casino",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_casino" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_casino.png", parent )

                    local end_time = localPlayer:getData( "offer_short_casino" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferCasino", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_rally",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_rally" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_rally.png", parent )

                    local end_time = localPlayer:getData( "offer_short_rally" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferRally", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_first_house",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_first_house" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local img_path = "img/sliders/slider_offer_short_first_house_" .. localPlayer:GetGender( ) .. ".png"
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, img_path, parent )

                    local end_time = localPlayer:getData( "offer_short_first_house" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferFH", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_first_moto",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_first_moto" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_first_moto.png", parent )

                    local end_time = localPlayer:getData( "offer_short_first_moto" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferFM", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_sick_player",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_sick_player" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_sick_player.png", parent )

                    local end_time = localPlayer:getData( "offer_short_sick_player" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferSick", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_clan_recruit",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_clan_recruit" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_clan_recruit.png", parent )

                    local end_time = localPlayer:getData( "offer_short_clan_recruit" ).time_to
                    CreateSliderTimer( end_time, 376, 86, bg )

                    ibCreateImage( 375, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferClan", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_first_vehicle",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_first_vehicle" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_first_vehicle.png", parent )

                    local end_time = localPlayer:getData( "offer_short_first_vehicle" ).time_to
                    CreateSliderTimer( end_time, 376, 97, bg )

                    ibCreateImage( 375, 150, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferFV", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_short_second_vehicle",
                active = function( )
                    return ( ( localPlayer:getData( "offer_short_second_vehicle" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278 - 11, 740, 231, "img/sliders/slider_offer_short_second_vehicle.png", parent )

                    local end_time = localPlayer:getData( "offer_short_second_vehicle" ).time_to
                    CreateSliderTimer( end_time, 376, 107, bg )

                    ibCreateImage( 375, 160, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShortOfferSV", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "premium_3d",
                active = function( )
                    return ( ( localPlayer:getData( "offer_premium_3d" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_premium_3d.png", parent )

                    local end_time = localPlayer:getData( "offer_premium_3d" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPremium3D", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_tuning_kit",
                active = function( )
                    return ( ( localPlayer:getData( "offer_tuning_kit" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_tuning_kit.png", parent )

                    local end_time = localPlayer:getData( "offer_tuning_kit" ).time_to
                    CreateSliderTimer( end_time, 381, 74, bg )

                    ibCreateImage( 380, 127, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferTuningKit", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "premium_share",
                active = function( )
                    if not localPlayer:IsPremiumActive( ) then return false end
                    return ( ( localPlayer:getData( "offer_premium_share" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_premium_share.png", parent )

                    local end_time = localPlayer:getData( "offer_premium_share" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPremiumShare", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "premium_nopurchase",
                active = function( )
                    return ( ( localPlayer:getData( "offer_premium_np" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local data = localPlayer:getData( "offer_premium_np" )
                    local img_path = data.variant == 1 and "img/sliders/slider_premium_np.png" or "img/sliders/slider_premium_np_2.png"

                    local bg = ibCreateImage( 0, 278, 741, 210, img_path, parent )

                    CreateSliderTimer( data.time_to, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPremiumNopurchase", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "slider_offer_last_wealth",
                active = function( )
                    return ( localPlayer:getData( "offer_last_wealth_time_left" ) or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_last_wealth.png", parent )
                    CreateSliderTimer( localPlayer:getData( "offer_last_wealth_time_left" ), 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerServerEvent( "onServerPlayerRequestDataOfferLastWealth", root )
                        end )

                    return bg
                end,
            },
            {
                id = "double_mayhem_offer",
                active = function( )
                    return ( ( localPlayer:getData( "double_mayhem_offer_finish" ) ) or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_double_mayhem.png", parent )
                    local name, model = exports.nrp_double_mayhem:GetOffersConfig()

                    ibCreateLabel( 380, 52, 0, 0, name, bg, nil, nil, nil, nil, "center", ibFonts.bold_20 )
                    ibCreateContentImage( 67, 25, 300, 160, "vehicle", model, bg )

                    CreateSliderTimer( localPlayer:getData( "double_mayhem_offer_finish" ), 381, 77, bg )
                    ibCreateButton( 381, 135, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerServerEvent( "onServerRequestDoubleMayhemOffer", root )
                        end )
                    return bg
                end,
            },
            {
                id = "gun_shop_offer",
                active = function( )
                    local licenses = localPlayer:getData( "gun_licenses" )
                    local time = getRealTimestamp( )
                    local is_lecenses = licenses and licenses > time or false

                    return ( ( localPlayer:getData( "gun_shop_offer_finish" ) ) or 0 ) >= time and is_lecenses
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_gun_shop.png", parent )
                    CreateSliderTimer( localPlayer:getData( "gun_shop_offer_finish" ), 381, 84, bg )
                    ibCreateButton( 381, 135, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            triggerEvent( "ShowGunShopOffer", root, true )
                        end )
                    return bg
                end,
            },
            {
                id = "assembly_vehicle",
                active = function( )
                    local ts = getRealTimestamp( )
                    if ts >= ( localPlayer:getData( "assembly_vehicle_start" ) or 0 ) and ts <= ( localPlayer:getData( "assembly_vehicle_finish" ) or 0 ) then
                        return true
                    end
                    return false
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/assembly_vehicle.png", parent )

                    local end_time = localPlayer:getData( "assembly_vehicle_finish" )
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowOfferAssemblyVehicle", root, true )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_first_weapon",
                active = function( )
                    return ( ( localPlayer:getData( "offer_first_weapon" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_first_weapon.png", parent )

                    local end_time = localPlayer:getData( "offer_first_weapon" ).time_to
                    CreateSliderTimer( end_time, 381, 96, bg )

                    ibCreateImage( 380, 148, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferFirstWeapon", localPlayer )
                    end )
                    return bg
                end,
            },
            {
                id = "offer_skin",
                active = function( )
                    return ( ( localPlayer:getData( "offer_skin" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_skin.png", parent )

                    local end_time = localPlayer:getData( "offer_skin" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 378, 131, 0, 0, "img/sliders/btn_show_on_map.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ToggleGPS", localPlayer, CLOTHES_SHOPS_LIST, true )
                        localPlayer:ShowInfo( "Установлена метка до ближайшего магазина одежды" )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_piggy_bank",
                active = function( )
                    return localPlayer:getData( "offer_piggy_bank" ) and true or false
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_piggy_bank.png", parent )

                    ibCreateImage( 378, 131, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferPiggyBank", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "offer_clan",
                active = function( )
                    return ( ( localPlayer:getData( "offer_clan" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_offer_clan.png", parent )

                    local end_time = localPlayer:getData( "offer_clan" ).time_to
                    CreateSliderTimer( end_time, 381, 77, bg )

                    ibCreateImage( 378, 131, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferClan", localPlayer )
                    end )

                    return bg
                end,
            },
            {
                id = "apart20_offer",
                active = function( )
                    return ( ( localPlayer:getData( "offer_property" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
                end,
                fn = function( parent )
                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_apart20.png", parent )

                    local end_time = localPlayer:getData( "offer_property" ).time_to
                    CreateSliderTimer( end_time, 370, 73, bg )

                    ibCreateImage( 380, 135, 0, 0, "img/sliders/btn_details.png", bg )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferProperty", localPlayer )
                    end )
                    return bg
                end,
            },
            {
                id = "slider_7cases_discount",
                active = function( )
                    return localPlayer:getData("7cases_discounts")
                end,
                fn = function( parent )
                    local pDiscountData = exports.nrp_cases_7discount:Get7CasesDiscountData()

                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_7cases_discount.png", parent )

                    -- Best offered case
                    local case_area = ibCreateArea( 0, 0, 420, 210, bg )
                    local case_img = ibCreateContentImage( 0, 0, 360, 280, "case", pDiscountData.cases[#pDiscountData.cases].case_id, case_area )
                    :center()

                    local points_img = ibCreateImage( 240, 60, 84, 87, "img/sliders/icon_case_points.png", case_img )

                    CreateSliderTimer( pDiscountData.finish_ts, 381, 77, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )
                            
                            triggerEvent( "ShowUI_7CasesDiscount", localPlayer, true )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_wholesome_case_discount",
                active = function( )
                    return localPlayer:getData("wholesome_case_discount")
                end,
                fn = function( parent )
                    local pDiscountData = exports.nrp_cases_wholesome_discount:GetWholesomeCaseDiscountData()

                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_wholesome_case.png", parent )

                    -- Best offered case
                    local case_area = ibCreateArea( 0, 0, 420, 210, bg )
                    local case_img = ibCreateContentImage( 0, 0, 360, 280, "case", pDiscountData.cases[#pDiscountData.cases].case_id, case_area )
                    :center()

                    CreateSliderTimer( pDiscountData.finish_ts, 381, 86, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )

                            triggerEvent( "ShowUI_WholesomeCaseDiscount", localPlayer, true )
                        end )
                    return bg
                end,
            },
            {
                id = "slider_vehicle_auction",
                active = function( )
                    return localPlayer:getData("vehicle_auction")
                end,
                fn = function( parent )
                    local auction_data = localPlayer:getData( "vehicle_auction" )

                    local bg = ibCreateImage( 0, 278, 741, 210, "img/sliders/slider_vehicle_auction.png", parent )

                    local vehicle_area = ibCreateArea( 0, 0, 420, 210, bg )
                    local vehicle_img = ibCreateContentImage( 0, 0, 300, 160, "vehicle", auction_data.items[3].id, vehicle_area )
                    :center()

                    CreateSliderTimer( auction_data.finish_ts, 381, 96, bg )
                    ibCreateButton( 382, 140, 156, 38, bg, "img/sliders/btn_details.png", "img/sliders/btn_details.png", "img/sliders/btn_details.png", 0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowDonateUI( false )

                            triggerEvent( "ShowUI_VehicleAuction", localPlayer, true )
                        end )
                    return bg
                end,
            },
        },
    }
    -- Всевозможные офферы
    OFFERS = {
        {
            id = "transfer",
            active = function( self )
                return localPlayer:getData( "account_transfer" )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/transfer.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "transfer" } )
                        ShowDonateUI( false )

                        triggerEvent( "onClientPlayerShowTransferAgain", localPlayer )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "annuity_payment",
            active = function( )
				if not localPlayer:getData( "annuity_payment" ) then return end

				local annuity_days = localPlayer:getData( "annuity_days" )
				if not annuity_days then return end

                for day = 1, 10 do
					if not annuity_days[ day ] or annuity_days[ day ] == 2 then
						return true
					end
				end
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/annuity_payment.png", area ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "annuity_payment" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowAnnuityPaymentsUI", root, localPlayer:getData( "annuity_days" ) )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "annuity_payment_time",
            active = function( )
				if localPlayer:getData( "annuity_payment" ) then return end

                local ts = getRealTimestamp( )
				local annuity_payment_timeout = localPlayer:getData( "annuity_payment_timeout" )
                return annuity_payment_timeout and annuity_payment_timeout >= ts
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/annuity_payment_time.png", area ):ibData( "disabled", true )

				local time_desc_label = ibCreateLabel( 79, 55, 0, 0, "Акция действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( localPlayer:getData( "annuity_payment_timeout" ), true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "annuity_payment_time" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowAnnuityPaymentsUI", root )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "universal",
            active = function( )
                local ts = getRealTimestamp( )
                return PAYOFFER and PAYOFFER.start <= ts and PAYOFFER.finish >= ts
            end,
            fn_create = function( self )
                local name = PAYOFFER.name
                local bg_textures = {
                    format1 = "bg_offers_format1",
                    format2 = "bg_offers_format2",
                    format3 = "bg_offers_format3",
                }
                local bg_tex = bg_textures[ name ] or "bg_offers"
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/" .. bg_tex .. ".png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/" .. bg_tex .. "_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local n = PAYOFFER.friendly_name or "Акция на донат валюту"
                ibCreateLabel( 0, 10, 0, 0, n, bg, COLOR_WHITE, _, _, "center", "top", ibFonts.regular_16 ):center_x( )

                local textures = {
                    format1 = "payoffer_format1",
                    format2 = "payoffer_format2",
                    format3 = "payoffer_format3",
                }
                local offer_tex = textures[ name ] or "payoffer"
                ibCreateImage( 0, 70, 0, 0, "img/offers/" .. offer_tex .. ".png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

                local img = ibCreateImage( 50, 40, 22, 24, "img/icon_timer.png", bg )
                local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
                local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( PAYOFFER.finish, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = name } )
                    ShowDonateUI( false )
                    triggerServerEvent( "ShowPayoffer", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "return_offer",
			active = function( )
                local offer_data = localPlayer:getData( "offer_data" )
                return offer_data and offer_data.time_finish > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateLabel( 0, 10, 0, 0, "Акция на донат валюту", bg, COLOR_WHITE, _, _, "center", "top", ibFonts.regular_14 ):center_x( )

                ibCreateImage( 0, 70, 0, 0, "img/offers/payoffer.png", area ):ibSetRealSize( ):center_x( ):ibData( "disabled", true )

                local img = ibCreateImage( 50, 30, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					local offer_data = localPlayer:getData( "offer_data" )
					if offer_data then
						time_label:ibData( "text", getHumanTimeString( offer_data.time_finish, true ) )
					end
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        ShowDonateUI( false )
                        triggerEvent( "onClientPlayerShowCurrentOfferRequest", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "special_x2",
            active = function( )
                return ( tonumber( localPlayer:getData( "x2_offer_finish" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateLabel( 0, 10, 0, 0, "Уникальное предложение", bg, COLOR_WHITE, _, _, "center", "top", ibFonts.regular_14 ):center_x( )
                ibCreateImage( 0, 70, 0, 0, "img/offers/payoffer.png", area ):ibSetRealSize( ):center_x( ):ibData( "disabled", true )

                local img = ibCreateImage( 50, 30, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "x2_offer_finish" ) ), true ) )
				end
				UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )
                
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "special_x2" } )
                    ShowDonateUI( false )
                    triggerEvent( "ShowX2UI_Remembered", root )
                end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },

        {
            id = "offer_vehicle",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_vehicle_finish" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_vehicle.png", area ):ibSetRealSize( ):center_x( ):ibData( "disabled", true )

                local img = ibCreateImage( 50, 45, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )

                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_vehicle_finish" ) ), true ) )
				end
				UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_vehicle" } )
                    ShowDonateUI( false )
                    triggerEvent( "onClientTryShowOfferVehicle", root )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_comfort",
            active = function( )
                return ( tonumber( localPlayer:getData( "comfort_test_offer_end_date" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_comfort.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 232, 54, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "comfort_test_offer_end_date" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )
                
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShowOfferComfortStart", localPlayer, true )
                end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_gun_license",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_gun_license_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_gun_license.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 259, 54, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_gun_license_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )
                
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_gun_license" } )
                    ShowDonateUI( false )
                    
                    triggerEvent( "onShowOfferWeaponLicense", root, true )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_last_wealth",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_last_wealth_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_last_wealth.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 232, 54, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )

                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_last_wealth_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_last_wealth" } )
                    ShowDonateUI( false )
                    triggerServerEvent( "onServerPlayerRequestDataOfferLastWealth", root )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_newyear_auction",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_newyear_auction_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offers_newyear_auction.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 231, 63, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )

                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_newyear_auction_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )

                ibCreateImage( 105, 230, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
				    	SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_newyear_auction" } )
                        ShowDonateUI( false )

                        triggerServerEvent( "onServerPlayerRequestNewYearAuction", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_ingame_draw",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_ingame_draw" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer_bg = ibCreateImage( 0, 0, 0, 0, "img/offers/offer_ingame_draw.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 232, 49, 0, 0, "", offer_bg, ibApplyAlpha( COLOR_WHITE, 100 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_ingame_draw" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )

                ibCreateImage( 105, 230, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
				    	SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_ingame_draw" } )
                        ShowDonateUI( false )

                        triggerServerEvent( "onServerRequestIngameDraw", root )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_valentine_day",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_valentine_day_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_valentine_day_" .. GetCurrentSegment() .. ".png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 232, 68, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_valentine_day_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )
                
                ibCreateImage( 106, 230, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
				    	SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_valentine_day" } )
                        ShowDonateUI( false )

                        triggerServerEvent( "onServerRequestShowValentineDayOffer", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_defender_fatherland_day",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_defender_fatherland_day_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_defender_fatherland_day_" .. GetCurrentSegment() .. ".png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 232, 55, 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_defender_fatherland_day_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )
                
                ibCreateImage( 106, 230, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
				    	SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_defender_fatherland_day" } )
                        ShowDonateUI( false )

                        triggerServerEvent( "onServerRequestShowDefenderFatherlandDayOffer", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_discount_gift",
            active = function( )
                return ( tonumber( localPlayer:getData( "offer_discount_gift_time_left" ) ) or 0 ) > getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local bg_offer = ibCreateImage( 0, 0, 0, 0, "img/offers/offer_discount_gift.png", area ):ibSetRealSize( ):center( ):ibData( "disabled", true )

				local time_label = ibCreateLabel( 217, 54, 0, 0, "", bg_offer, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( tonumber( localPlayer:getData( "offer_discount_gift_time_left" ) ), true ) )
				end
                time_label:ibTimer( UpdateTime, 500, 0 )
                UpdateTime( )
                
                ibCreateImage( 106, 230, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
				    	SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_discount_gift" } )
                        ShowDonateUI( false )

                        triggerEvent( "onClientShowOfferDiscountGift", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "1september",
            active = function( )
                local ts = getRealTimestamp( )
                return ts >= 1567134000 and ts <= 1567814400
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )
                bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerServerEvent("OnPlayerRequest1SeptemberUI", localPlayer)
                end)

                ibCreateImage( 0, -20, 0, 0, "img/offers/offer_1september.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "1september" } )
                    ShowDonateUI( false )
                    triggerServerEvent("OnPlayerRequest1SeptemberUI", localPlayer)
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },

        {
            id = "premium",
            finish_date = 1563753600,

            active = function( self )
                if self.finish_date <= getRealTimestamp( ) then
                    return false
                end

                return true
            end,

            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_premium.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                if self.finish_date then
                    local img = ibCreateImage( 50, 20, 22, 24, "img/icon_timer.png", bg )
                    local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
                    local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                    local function UpdateTime( )
                        time_label:ibData( "text", getHumanTimeString( self.finish_date, true ) )
                    end
                    UpdateTime( )
                    time_label:ibTimer( UpdateTime, 500, 0 )
                end

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "premium" } )
                        SwitchNavbar( "premium" )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "halloween",
            active = function( self )
                local ts = getRealTimestamp( )
                return ts >= getTimestampFromString( "29 октября 2020 00:00" ) and ts <= getTimestampFromString( "12 ноября 2020 23:59" )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/halloween.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "halloween" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowEventUIMainOffer", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "double_mayhem",
            active = function( self )
                return ( ( localPlayer:getData( "double_mayhem_offer_finish" ) ) or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local bg_double_mayhem = ibCreateImage( 0, 0, 360, 280, "img/offers/double_mayhem.png", area ):ibData( "disabled", true )
                local name, model = exports.nrp_double_mayhem:GetOffersConfig()

                ibCreateContentImage( 30, 70, 300, 160, "vehicle", model, bg_double_mayhem )
                ibCreateLabel( 0, 22, 0, 0, name, area, nil, nil, nil, "center", "center", ibFonts.regular_16 ):center_x( )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", bg_double_mayhem,
                    ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "double_mayhem_offer_finish" )
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", bg_double_mayhem )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "double_mayhem" } )
                        ShowDonateUI( false )
                        triggerServerEvent( "onServerRequestDoubleMayhemOffer", root )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "gun_shop",
            active = function( self )
                local licenses = localPlayer:getData( "gun_licenses" )
                local time = getRealTimestamp( )
                local is_lecenses = licenses and licenses > time or false

                return ( ( localPlayer:getData( "gun_shop_offer_finish" ) ) or 0 ) >= time and is_lecenses
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/gun_shop.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 218, 58, 0, 0, "", area,
                    ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "gun_shop_offer_finish" )
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "gun_shop" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowGunShopOffer", root, true )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "new_year_event",
            active = function( self )
                local ts = getRealTimestamp( )
                return ts >= EVENTS_TIMES.new_year.from and ts <= EVENTS_TIMES.new_year.to
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/new_year_event.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "new_year_event" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowEventUIMainOffer", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "new_year_event_boosters",
            active = function( self )
                local ts = getRealTimestamp( )
                return ts >= EVENTS_TIMES.new_year.from and ts <= EVENTS_TIMES.new_year.to
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/new_year_event_boosters.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "new_year_event_boosters" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowUIEventBoosters", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "may_events",
            active = function( self )
                local ts = getRealTimestamp( )
                return ts >= EVENTS_TIMES.may_events.from and ts <= EVENTS_TIMES.may_events.to
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/may_events.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "may_events" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowEventUIMainOffer", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "may_events_boosters",
            active = function( self )
                local ts = getRealTimestamp( )
                return ts >= EVENTS_TIMES.may_events.from and ts <= EVENTS_TIMES.may_events.to
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/may_events_boosters.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "may_events_boosters" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowUIEventBoosters", root )
                    end )
                
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "question_clan",
            active = function( self )
                local ts = getRealTimestamp( )
                if (ts >= 1572123600 and ts <= 1572209999) and localPlayer:GetClanID() and localPlayer:GetClanRank() >= 4 then 
                    return true
                end
                return false
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )
                bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    triggerServerEvent( "onPlayerRequestOpenForm", localPlayer )
                end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/question_clan.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_birthday",
            active = function( self )
                local ts = getRealTimestamp( )
                if ts >= getTimestampFromString( "12 декабря 2019 00:00" ) and ts <= getTimestampFromString( "15 декабря 2019 23:59" ) then 
                    return true
                end
                return false
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_birthday.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "offer_birthday" } )
                        ShowDonateUI( false )
                        triggerServerEvent( "onPlayerRequestShowBirthdayEvent", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "vinyl_cases_discount",
            active = function( )
                return exports.nrp_vinyl_cases_discount:IsOfferActive( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/vinyl_cases_discount.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, 
                    ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    local offerEndTime = exports.nrp_vinyl_cases_discount:GetOfferEndTime( )
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "vinyl_cases_discount" } )
                        ShowDonateUI( false )
                        triggerServerEvent( "PlayerWantShowVinylCasesDiscount", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "bp_premium_offer",
            active = function( )
                local offer = localPlayer:getData( "bp_premium_offer" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/bp_premium_offer.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "bp_premium_offer" )
                ibCreateLabel( 265, 24, 0, 0, "ВЫГОДА " .. offer.discount .. "%", area, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "BP:ShowPremiumOffer", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "bp_booster_offer",
            active = function( )
                local offer = localPlayer:getData( "bp_booster_offer" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/bp_booster_offer.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "bp_booster_offer" )
                ibCreateLabel( 265, 24, 0, 0, "ВЫГОДА " .. offer.discount .. "%", area, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "BP:ShowBoosterOffer", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "bp_boosters_discount",
            active = function( )
                local offer = localPlayer:getData( "bp_boosters_discount" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/bp_booster_offer.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "bp_boosters_discount" )
                ibCreateLabel( 265, 24, 0, 0, "ВЫГОДА " .. offer.discount .. "%", area, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "BP:ShowBoosterOffer", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "bp_hard_offer",
            active = function( )
                local offer = localPlayer:getData( "bp_hard_offer" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/bp_hard_offer.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "bp_hard_offer" )
                ibCreateLabel( 245, 24, 0, 0, "ВЫГОДА " .. offer.discount .. "%", area, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "BP:ShowHardOffer", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "bosow_bundle",
            active = function( )
                local offer = localPlayer:getData( "bosow_bundle" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/bosow_bundle.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "bosow_bundle" )
                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowBosowBundle", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "danilych_bundle",
            active = function( )
                local offer = localPlayer:getData( "danilych_bundle" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/danilych_bundle.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "danilych_bundle" )
                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowDanilychBundle", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "march_offer",
            active = function( )
                local offer = localPlayer:getData( "march_offer" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/march_offer.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local offer = localPlayer:getData( "march_offer" )
                local time_label = ibCreateLabel( 234, 58, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowOffer8March", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "cases_pack_offer",
            active = function( )
                local offer = localPlayer:getData( "cases_pack_offer" )
                return offer and offer.finish_ts > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/cases_pack_offer.png", area ):ibData( "disabled", true )

                local offer = localPlayer:getData( "cases_pack_offer" )
                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( offer.finish_ts, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowCasesPackOffer", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "cases_premium_discount",
            active = function( )
                local discounts = HasDiscounts( )
                return discounts and discounts.id == "cases_premium_discount" and discounts.finish_time > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/cases_premium_discount.png", area )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    :ibData( "priority", -1)

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local discounts = HasDiscounts( )
                local case_id = next( discounts.array )
                ibCreateContentImage( 119, 49, 360, 280, "case", case_id, bg ):ibBatchData( { sx = 232, sy = 180 } )
                local case_id = next( discounts.array, case_id )
                ibCreateContentImage( -4, 44, 360, 280, "case", case_id, bg ):ibBatchData( { sx = 275, sy = 214 } )

                local offer = localPlayer:getData( "cases_pack_offer" )
                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
				local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( discounts.finish_time, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowCasesPremuimDiscount", localPlayer )
                    end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_discount",
            active = function( )
                return ( ( localPlayer:getData( "offer_premium_fast" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/premium_discount.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_premium_fast" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPremiumDaily", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_extension",
            active = function( )
                return ( ( localPlayer:getData( "offer_premium_extension" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/premium_extension.png", area ):ibData( "disabled", true )

                local days = ( localPlayer:getData( "offer_premium_extension" ) or { } ).duration or "-"
                ibCreateLabel( 0, 205, 360, 0, "Премиум на " .. days .. " дн.", bg, nil, nil, nil, "center", "center", ibFonts.regular_14 )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_premium_extension" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPremiumExtension", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_3d",
            active = function( )
                return ( ( localPlayer:getData( "offer_premium_3d" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/premium_3d.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_premium_3d" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPremium3D", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_3d",
            active = function( )
                return ( ( localPlayer:getData( "offer_tuning_kit" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_tuning_kit.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_tuning_kit" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferTuningKit", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_share",
            active = function( )
                if not localPlayer:IsPremiumActive( ) then return false end
                return ( ( localPlayer:getData( "offer_premium_share" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/premium_share.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_premium_share" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPremiumShare", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_nopurchase",
            active = function( )
                return ( ( localPlayer:getData( "offer_premium_np" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local data = localPlayer:getData( "offer_premium_np" )
                local img_path = data.variant == 1 and "img/offers/premium_np.png" or "img/offers/premium_np_2.png"

                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, img_path, area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( data.time_to, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPremiumNopurchase", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "premium_3d",
            active = function( )
                return ( ( localPlayer:getData( "offer_first_weapon" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/first_weapon.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 58, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_first_weapon" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferFirstWeapon", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_5lvl_up",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_5lvl_up" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_5lvl_up.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_5lvl_up" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOffer5LVL", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_vacation_time",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_vacation_time" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_vacation_time.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_vacation_time" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferVacationTime", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_casino",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_casino" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_casino.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_casino" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferCasino", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_first_house",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_first_house" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                local img_path = "img/offers/offer_short_first_house_" .. localPlayer:GetGender( ) .. ".png"
                ibCreateImage( 0, 0, 360, 280, img_path, area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_first_house" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferFH", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_first_moto",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_first_moto" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_first_moto.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_first_moto" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                        :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferFM", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_sick_player",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_sick_player" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_sick_player.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_sick_player" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferSick", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_clan_recruit",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_clan_recruit" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_clan_recruit.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_clan_recruit" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferClan", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_rally",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_rally" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_rally.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_rally" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferRally", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_first_vehicle",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_first_vehicle" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_first_vehicle.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_first_vehicle" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferFV", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "offer_short_second_vehicle",
            active = function( )
                return ( ( localPlayer:getData( "offer_short_second_vehicle" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( parent )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/offer_short_second_vehicle.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "offer_short_second_vehicle" ).time_to
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerShortOfferSV", localPlayer )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },
        {
            id = "for_whales",
            active = function( self )
                local offer_end_time = localPlayer:getData( "offer_for_whales" )
                return offer_end_time and offer_end_time > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "offer_for_whales" )
				local time_label = ibCreateLabel( 232, 55, 0, 0, end_time, area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( end_time, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_for_whales.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "for_whales" } )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerShowSpecialOfferForWhales", localPlayer )
                    end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "cases_offers",
            active = function( self )
                if localPlayer:getData( "cases_offers_group" ) ~= "pack" then return false end

                local offer_end_time = localPlayer:getData( "cases_offers_end_date" )
                return offer_end_time and offer_end_time > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "cases_offers_end_date" )
                local time_label = ibCreateLabel( 232, 55, 0, 0, end_time, area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( end_time, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, -22, 0, 0, "img/offers/offers_cases.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                        :ibSetRealSize( )
                        :ibData( "alpha", 200 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "cases_offers" } )
                    ShowDonateUI( false )
                    triggerServerEvent( "onCasesOfferUIRequest", localPlayer )
                end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "apart20_offer",
            active = function( self )
                return ( ( localPlayer:getData( "offer_property" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "offer_property" ).time_to
				local time_label = ibCreateLabel( 232, 55, 0, 0, end_time, area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( end_time, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 10, 12, 0, 0, "img/offers/offer_apart20.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "onPlayerOfferProperty", localPlayer )
                    end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "offer_skin",
            active = function( self )
                return ( ( localPlayer:getData( "offer_skin" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "offer_skin" ).time_to
                local time_label = ibCreateLabel( 232, 54, 0, 0, end_time, area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( end_time, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_skin.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferSkin", localPlayer )
                end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "offer_piggy_bank",
            active = function( self )
                return localPlayer:getData( "offer_piggy_bank" ) and true or false
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_piggy_bank.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferPiggyBank", localPlayer )
                end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "offer_clan",
            active = function( self )
                return ( ( localPlayer:getData( "offer_clan" ) or { } ).time_to or 0 ) >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "offer_clan" ).time_to
                local time_label = ibCreateLabel( 260, 54, 0, 0, end_time, area, nil, _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( end_time, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_clan.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "onPlayerOfferClan", localPlayer )
                end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "offer_cardiscount",
            active = function( self )
                local data = localPlayer:GetAllVehiclesDiscount( )
                return data and data.timestamp >= getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 0, 0, "img/offers/offer_cardiscount.png", area ):ibSetRealSize( ):ibData( "disabled", true )

                local data = localPlayer:GetAllVehiclesDiscount( )
                local end_time = data.timestamp

                local time_label = ibCreateLabel( 233, 54, 0, 0, end_time, area, nil, _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    time_label:ibData( "text", getHumanTimeString( end_time, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 80, 230, 200, 34, "img/offers/btn_show_on_map.png", area )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ToggleGPS", localPlayer, {
                            { x = -1011.761, y = -1478.894, z = 21.741 },
                            { x = -362.385, y = -1752.450, z = 20.928 },
                            { x = 1792.201, y = -625.773, z = 60.704 },
                            { x = 2044.341, y = -803.662, z = 62.621 },
                            { x = 1242.287, y = 2466.162, z = 11.046 },
                        } )
                    end )
                
                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

		{
            id = "3rd_payment",
            active = function( self )
                local offer_end_time = localPlayer:getData( "third_payment_end_date" )
                return offer_end_time and offer_end_time > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local end_time = localPlayer:getData( "third_payment_end_date" )
				local time_label = ibCreateLabel( 232, 55, 0, 0, end_time, area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( end_time, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, -12, 0, 0, "img/offers/3rd_payment.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowDonateUI( false )
                        triggerEvent( "ShowOfferThirdPaymentUI_Remembered", localPlayer )
                    end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
		},
        
        {
            id = "businesses_offer",
            active = function( self )
                local businesses_offer = localPlayer:getData( "businesses_offer" )
                return businesses_offer and businesses_offer.segment > 0 and businesses_offer.count > 0 and businesses_offer.end_timestamp > getRealTimestamp( )
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 1, 1, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                    :ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

                local businesses_offer = localPlayer:getData( "businesses_offer" )
				local time_label = ibCreateLabel( 232, 55, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( businesses_offer.end_timestamp, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                ibCreateImage( 0, 0, 0, 0, "img/offers/businesses_offer.png", area ):ibSetRealSize( ):ibData( "disabled", true )
                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                    :ibSetRealSize( )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) bg_hover:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_promo_purchase_button_click", { promo_name = "businesses_offer" } )
                        ShowDonateUI( false )
                        triggerEvent( "ShowBusinessesOffer", root )
                    end )
                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end
        },

        {
            id = "assembly_vehicle",
            active = function( )
                local ts = getRealTimestamp( )
                if ts >= ( localPlayer:getData( "assembly_vehicle_start" ) or 0 ) and ts <= ( localPlayer:getData( "assembly_vehicle_finish" ) or 0 ) then
                    return true
                end
                return false
            end,
            fn_create = function( self )
                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
                :ibData( "disabled", true )
                :ibData( "alpha", 0 )
                :ibData( "priority", -1 )

                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateImage( 0, 0, 360, 280, "img/offers/assembly_vehicle.png", area ):ibData( "disabled", true )

                local time_label = ibCreateLabel( 234, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = localPlayer:getData( "assembly_vehicle_finish" )
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "ShowOfferAssemblyVehicle", root, true )
                end )

                area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                return area
            end,
        },

        {
            id = "7cases_discount",
            active = function( )
                return localPlayer:getData("7cases_discounts")
            end,
            fn_create = function( parent )
                local pDiscountData = exports.nrp_cases_7discount:Get7CasesDiscountData()

                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_p.png", area ):ibSetRealSize( )
                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_p_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                
                bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )
                bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    
                    triggerEvent( "ShowUI_7CasesDiscount", localPlayer, true )
                end)

                local time_label = ibCreateLabel( 230, 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                :ibData( "disabled", true )

                local function UpdateTime( )
                    local offerEndTime = pDiscountData.finish_ts
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                local case_img = ibCreateContentImage( 0, 0, 360, 280, "case", pDiscountData.cases[#pDiscountData.cases].case_id, area )
                :center()
                :ibData( "disabled", true )

                local points_img = ibCreateImage( 240, 60, 84, 87, "img/sliders/icon_case_points.png", case_img )
                :ibData( "disabled", true )

                local btn_details = ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "ShowUI_7CasesDiscount", localPlayer, true )
                end )

                if pDiscountData.finish_ts - getRealTimestamp() <= 60 * 60 * 1 then
                    ibCreateImage( 360-23, 0, 23, 23, "img/icon_indicator_new.png", area ):ibData( "priority", 3 )
                    SetNavbarTabNew( "offers" )
                end

                return area
            end,
        },

        {
            id = "vehicle_auction",
            active = function( )
                return localPlayer:getData("vehicle_auction")
            end,
            fn_create = function( parent )
                local auction_data = localPlayer:getData("vehicle_auction")

                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 360, 280, "img/offers/offer_vehicle_auction.png", area )

                bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )

                    triggerEvent( "ShowUI_VehicleAuction", localPlayer, true )
                end)

                local time_label = ibCreateLabel( 220, 52, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
                :ibData( "disabled", true )

                local function UpdateTime( )
                    local offerEndTime = auction_data.finish_ts
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                local vehicle_img = ibCreateContentImage( 0, 0, 300, 160, "vehicle", auction_data.items[3].id, bg )
                :center( 0, 10 )
                :ibData( "disabled", true )

                local btn_details = ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", bg )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "ShowUI_VehicleAuction", localPlayer, true )
                end )

                if auction_data.finish_ts - getRealTimestamp() <= 60 * 60 * 1 then
                    ibCreateImage( 360-23, 0, 23, 23, "img/icon_indicator_new.png", area ):ibData( "priority", 3 )
                    SetNavbarTabNew( "offers" )
                end

                return area
            end,
        },

        {
            id = "wholesome_case_discount",
            active = function( )
                return localPlayer:getData("wholesome_case_discount")
            end,
            fn_create = function( parent )
                local pDiscountData = exports.nrp_cases_wholesome_discount:GetWholesomeCaseDiscountData()

                local area = ibCreateArea( 0, 0, 360, 280, parent )
                local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/wholesome_case.png", area ):ibSetRealSize( )

                local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_p_hover.png", area ):ibSetRealSize( )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )

                bg:ibOnHover( function( ) bg:ibAlphaTo( 255, 200 ) end )
                bg:ibOnLeave( function( ) bg:ibAlphaTo( 255*0.9, 200 ) end )

                bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )

                    triggerEvent( "ShowUI_WholesomeCaseDiscount", localPlayer, true )
                end)

                local case_img = ibCreateContentImage( 0, 0, 360, 280, "case", pDiscountData.cases[#pDiscountData.cases].case_id, bg )
                :center()
                :ibData( "disabled", true )

                local img = ibCreateImage( 50, 56, 22, 24, "img/icon_timer.png", bg )
                local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Акция действует ещё:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
                local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
                local function UpdateTime( )
                    local offerEndTime = pDiscountData.finish_ts
                    time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
                end
                UpdateTime( )
                time_label:ibTimer( UpdateTime, 1000, 0 )

                local btn_details = ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
                :ibSetRealSize( )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowDonateUI( false )
                    triggerEvent( "ShowUI_WholesomeCaseDiscount", localPlayer, true )
                end )

                if pDiscountData.finish_ts - getRealTimestamp() <= 60 * 60 * 1 then
                    ibCreateImage( 360-23, 0, 23, 23, "img/icon_indicator_new.png", area ):ibData( "priority", 3 )
                    SetNavbarTabNew( "offers" )
                end

                return area
            end,
        },

        {
            id = "ind_offer_accessory",
            active = function( self )
                return self.data and self.data.finish_ts > getRealTimestamp( )
            end,
            fn_details = function( self )
                triggerEvent( "IO:ShowOffer", getResourceFromName( "nrp_" .. self.id ).rootElement )
            end,
            fn_create = function( self )
                return CreateOfferItem( parent, self, {
                    bg = "img/offers/" .. self.id .. ".png",
                    bg_hover = "img/offers/" .. self.id .. "_hover.png",
                    discount = { px = 239, text = "ВЫГОДА " .. self.data.discount .. "%" },
                    timer = self.data.finish_ts,
                } )
            end,
            fn_create_slider = function( parent, self )
                return CreateOfferSlider( parent, self, {
                    bg = "img/sliders/slider_" .. self.id .. ".png",
                    timer = { self.data.finish_ts, is_digital = true },
                    discount = self.data.discount,
                    btn = { px = 380, py = 128 },
                } )
            end,
        },
        {
            id = "ind_offer_vehicle",
            active = function( self )
                return self.data and self.data.finish_ts > getRealTimestamp( )
            end,
            fn_details = function( self )
                triggerEvent( "IO:ShowOffer", getResourceFromName( "nrp_" .. self.id ).rootElement )
            end,
            fn_create = function( self )
                return CreateOfferItem( parent, self, {
                    bg = "img/offers/" .. self.id .. ".png",
                    bg_hover = "img/offers/" .. self.id .. "_hover.png",
                    discount = { px = 272, text = "ВЫГОДА " .. self.data.discount .. "%" },
                    timer = self.data.finish_ts,
                } )
            end,
            fn_create_slider = function( parent, self )
                return CreateOfferSlider( parent, self, {
                    bg = "img/sliders/slider_" .. self.id .. ".png",
                    timer = { self.data.finish_ts, is_digital = true },
                    discount = self.data.discount,
                    btn = { px = 380, py = 128 },
                } )
            end,
        },
        {
            id = "ind_offer_wof",
            active = function( self )
                return self.data and self.data.finish_ts > getRealTimestamp( )
            end,
            fn_details = function( self )
                triggerEvent( "IO:ShowOffer", getResourceFromName( "nrp_" .. self.id ).rootElement )
            end,
            fn_create = function( self )
                return CreateOfferItem( parent, self, {
                    bg = "img/offers/" .. self.id .. ".png",
                    bg_hover = "img/offers/" .. self.id .. "_hover.png",
                    discount = { px = 245, text = "ВЫГОДА " .. self.data.discount .. "%" },
                    timer = self.data.finish_ts,
                } )
            end,
            fn_create_slider = function( parent, self )
                return CreateOfferSlider( parent, self, {
                    bg = "img/sliders/slider_" .. self.id .. ".png",
                    timer = { self.data.finish_ts, is_digital = true },
                    discount = self.data.discount,
                    btn = { px = 380, py = 128 },
                } )
            end,
        },
    }

    for n, v in pairs( OFFERS ) do
        if v.fn_create_slider then
            table.insert( AVAILABLE_SLIDERS.other, v )
        end
    end

    -- Услуги
    SERVICES = {
            {
                id = "sex_change",
                icon = "service_sex",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_sex.png", area ):ibSetRealSize( )

                    local cost, coupon_discount_value = localPlayer:GetCostService( 3 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "change_gender" } )
                            onOverlayNotificationRequest_handler( OVERLAY_CHANGE_SEX )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "remove_diseases",
                icon = "remove_diseases",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/remove_diseases.png", area ):ibSetRealSize( )

                    local cost, coupon_discount_value = localPlayer:GetCostService( 14 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                    :ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then
                            return
                        end

                        ibClick( )

                        local diseases = localPlayer:getData( "diseases" ) or { }
                        if not next( diseases ) then
                            localPlayer:ShowInfo( "Ты полностью здоров, лечение не требуется" )
                            return
                        end

                        SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "disease_treatment" } )
                        onOverlayNotificationRequest_handler( OVERLAY_REMOVE_DISEASES, diseases )
                    end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "hide_nickname",
                icon = "hide_nickname",
                active = true,
                fn_create = function( parent )
                    local hunting = localPlayer:getData( "hunting" ) or { timeTo = 0 }
                    local time_left = hunting.timeTo - getRealTimestamp( )

                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/hide_nickname.png", area ):ibSetRealSize( )

                    if time_left > 0 then
                        local area_discount = ibCreateArea( 0, 0, 1, 1, bg )
                        ibCreateLabel( 100, 160, 0, 0, "Старая цена: ", area_discount, ibApplyAlpha( COLOR_WHITE, 75 ), nil, nil, nil, nil, ibFonts.regular_14 )
                        ibCreateImage( 198, 160, 23, 23, ":nrp_shared/img/hard_money_icon.png", area_discount )
                        ibCreateLabel( 227, 159, 0, 0, SHOP_SERVICES[ 8 ].iPrice, area_discount, ibApplyAlpha( COLOR_WHITE, 75 ), nil, nil, nil, nil, ibFonts.bold_16 )
                        ibCreateImage( 193, 170, 68, 1, nil, area_discount, COLOR_WHITE )

                        ibCreateLabel( 90, 185, 0, 0, "Уникальная цена: ", area_discount, nil, nil, nil, nil, nil, ibFonts.regular_14 )
                        ibCreateImage( 222, 185, 23, 23, ":nrp_shared/img/hard_money_icon.png", area_discount )
                        ibCreateLabel( 252, 183, 0, 0, SHOP_SERVICES[ 8 ].iFinishPrice, area_discount, nil, nil, nil, nil, nil, ibFonts.bold_18 )

                        CreateHumanTimer( 65, 32, bg, "Скидка действует еще:", hunting.timeTo, true )
                        :ibTimer( function ( self )
                            self:destroy( )
                            area_discount:destroy( )

                            ibCreateLabel( 150, 170, 0, 0, format_price( SHOP_SERVICES[ 8 ].iPrice ), bg ):ibData( "font", ibFonts.semibold_21 )
                            ibCreateImage( 192, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )
                        end, time_left * 1000, 1 )
                    else
                        local cost, coupon_discount_value = localPlayer:GetCostService( 8 )
                        local cost_lbl = ibCreateLabel( 150, 170, 0, 0, format_price( cost ), bg ):ibData( "font", ibFonts.semibold_21 )
                        ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )
                    end

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                    :ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "hide_nickname" } )

                        local cost = hunting.timeTo - getRealTimestamp() > 0 and SHOP_SERVICES[ 8 ].iFinishPrice or localPlayer:GetCostService( 8 )
                        onOverlayNotificationRequest_handler(
                            OVERLAY_PURCHASE_HARD,
                            {
                                text = "Ты действительно хочешь\nприобрести скрытие никнейма на 1 час?",
                                cost = cost,
                                fn = function( )
                                    if localPlayer:GetDonate( ) < cost then
                                        onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для покупки услуги!" } )
                                        return
                                    end
                                    triggerServerEvent( "onPlayerRequestBuyHiddenNick", localPlayer, cost )
                                end,
                            }
                        )
                    end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "nickname_change",
                icon = "service_nickname",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_nickname.png", area ):ibSetRealSize( )

                    local cost, coupon_discount_value = localPlayer:GetCostService( 2 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "change_nickname" } )
                            onOverlayNotificationRequest_handler( OVERLAY_CHANGE_NICKNAME )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "marry_start",
                icon = "marry_start",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/marry_start.png", area ):ibSetRealSize( )
                    
                    local cost, coupon_discount_value = localPlayer:GetCostService( 10 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )
                    
                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "wedding_box" } )

                            local cost = localPlayer:GetCostService( 10 )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь\nприобрести Свадебный набор?",
                                    cost = cost,
                                    fn = function( )
                                        if localPlayer:GetDonate( ) < cost then
                                            onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для покупки набора!" } )
                                            return
                                        end
                                        triggerServerEvent( "onWeddingPlayerWeddingShopBuyItem", root, "wedding" )
                                    end,
                                }
                            )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "marry_divorce",
                icon = "marry_divorce",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/marry_divorce.png", area ):ibSetRealSize( )
                    
                    local cost, coupon_discount_value = localPlayer:GetCostService( 11 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "divorce_papers" } )
                            
                            local cost = localPlayer:GetCostService( 11 )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь\nприобрести Документы на развод?",
                                    cost = cost,
                                    fn = function( )
                                        if localPlayer:GetDonate( ) < cost then
                                            onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для покупки набора!" } )
                                            return
                                        end
                                        triggerServerEvent( "onWeddingPlayerWeddingShopBuyItem", root, "divorce" )
                                    end,
                                }
                            )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "military_purchase",
                icon = "service_military",
                active = function( ) return not localPlayer:HasMilitaryTicket( ) end,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_military.png", area ):ibSetRealSize( )
                    
                    local cost, coupon_discount_value = localPlayer:GetCostService( 1 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "military_document" } )
                            
                            local cost = localPlayer:GetCostService( 1 )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь\nприобрести Военный Билет?",
                                    cost = cost,
                                    fn = function( ) triggerServerEvent( "onBuyMilitaryTicketRequest", resourceRoot ) end,
                                }
                            )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
            {
                id = "carslot_purchase",
                icon = "service_car",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_car.png", area ):ibSetRealSize( )
                    local slot_cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_services", CONF.car_slot_cost )
                    local label_money = ibCreateLabel( 150, 170, 0, 0, format_price( slot_cost or 0 ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( label_money:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )
                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 255 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "auto_slot" } )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь\nприобрести Слот для машины?",
                                    cost = slot_cost,
                                    fn = function( )
                                        if localPlayer:GetDonate( ) < slot_cost then
											onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для покупки Слота!" } )
											triggerEvent( "onShopNotEnoughHard", localPlayer, "Car slot" )
                                            return
                                        end
                                        triggerServerEvent( "onBuySlotRequest", resourceRoot )
                                        if slot_cost == 50 then slot_cost = 100
                                        elseif slot_cost == 100 then slot_cost = 150
                                        elseif slot_cost >= 150 and slot_cost < 600 then slot_cost = slot_cost * 2 end
                                        label_money:ibData( "text", math.min( 600, slot_cost ) )
                                        icon_money:ibData( "px", label_money:ibGetAfterX() + 5 )
                                    end,
                                }
                            )
                        end )

                        area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                        return area
                end,
            },
            {
                id = "region_purchase",
                icon = "service_region",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_region.png", area ):ibSetRealSize( )
                    local cost, coupon_discount_value = localPlayer:GetCostService( 7 )
                    local label_money = ibCreateLabel( 150 - 30, 170, 0, 0, "от " .. format_price( cost ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( 190, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )
                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 255 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "change_region" } )
                            onOverlayNotificationRequest_handler( OVERLAY_CHANGE_NUMBERPLATE_REGION )
                        end )

                        area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                        return area
                end,
            },

            {
                id = "prison_end_purchase",
                icon = "prison_end",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/prison_end.png", area ):ibSetRealSize( )

                    local cost = localPlayer:GetCostService( 12 )
                    local cost_lbl = ibCreateLabel( 150, 170, 0, 0, cost, bg ):ibData( "font", ibFonts.semibold_21 )
                    ibCreateImage( cost_lbl:ibGetAfterX() + 5, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
							SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "prison_end" } )
                            onOverlayNotificationRequest_handler( OVERLAY_PURCHASE_JAILKEYS )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },

            {
                id = "reset_social_rating",
                icon = "service_srating",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/service_srating.png", area ):ibSetRealSize( )
                    local cost = localPlayer:GetCostService( 13 )
                    local label_money = ibCreateLabel( 150, 170, 0, 0, format_price( cost or 0 ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( 190, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "service_srating" } )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь\nобнулить свой рейтинг?",
                                    cost = cost,
                                    fn = function( )
                                        if localPlayer:GetDonate( ) < cost then
                                            onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для сброса рейтинга!" } )
                                            triggerEvent( "onShopNotEnoughHard", localPlayer, "Social rating reset" )
                                            return
                                        end
                                        triggerServerEvent( "onBuyRatingResetRequest", resourceRoot )
                                        label_money:ibData( "text", cost )
                                    end,
                                }
                            )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },

            {
                id = "inventory_player",
                icon = "inventory_player",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/inventory_player.png", area ):ibSetRealSize( )
                    local cost = SHOP_SERVICES.inventory_player.cost
                    local label_money = ibCreateLabel( 150, 170, 0, 0, format_price( cost or 0 ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( 190, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "invent_pers_up" } )
                            onOverlayNotificationRequest_handler(
                                OVERLAY_PURCHASE_HARD,
                                {
                                    text = "Ты действительно хочешь расширить\nвместимость инвентаря персонажа на " .. SHOP_SERVICES.inventory_player.value .. " ед?",
                                    cost = cost,
                                    fn = function( )
                                        if localPlayer:GetDonate( ) < cost then
                                            onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
                                            triggerEvent( "onShopNotEnoughHard", localPlayer, "inventory_player" )
                                            return
                                        end
                                        triggerServerEvent( "onPlayerWantExpandInventory", resourceRoot, localPlayer )
                                        label_money:ibData( "text", cost )
                                    end,
                                }
                            )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },

            {
                id = "inventory_vehicle",
                icon = "inventory_vehicle",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/inventory_vehicle.png", area ):ibSetRealSize( )
                    local cost = SHOP_SERVICES.inventory_vehicle.cost
                    local label_money = ibCreateLabel( 150, 170, 0, 0, format_price( cost or 0 ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( 190, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "invent_car_up" } )
                            onOverlayNotificationRequest_handler( OVERLAY_EXPAND_INVENTORY_VEHICLE )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },

            {
                id = "inventory_house",
                icon = "inventory_house",
                active = true,
                fn_create = function( parent )
                    local area = ibCreateArea( 0, 0, 1, 1, parent )
                    local bg = ibCreateImage( 0, 0, 0, 0, "img/services/inventory_house.png", area ):ibSetRealSize( )
                    local cost = SHOP_SERVICES.inventory_house.cost
                    local label_money = ibCreateLabel( 150, 170, 0, 0, format_price( cost or 0 ), bg ):ibData( "font", ibFonts.semibold_21 )
                    local icon_money = ibCreateImage( 190, 170, 30, 30, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )

                    local btn = ibCreateImage( 120, 216, 120, 44, "img/services/btn_buy.png", area )
                    ibCreateImage( 0, 0, 0, 0, "img/services/btn_buy_hover.png", btn ):ibSetRealSize( ):center( )
                        :ibData( "alpha", 0 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SendElasticGameEvent( "f4r_f4_services_purchase_button_click", { service = "invent_pers_up" } )
                            onOverlayNotificationRequest_handler( OVERLAY_EXPAND_INVENTORY_HOUSE )
                        end )

                    area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
                    return area
                end,
            },
        }


    UPDATE_COUNTERS = { }
    if fileExists( "counters.nrp" ) then
        local file = fileOpen( "counters.nrp" )
        if file then
            local contents = fileRead( file, fileGetSize( file ) )
            UPDATE_COUNTERS = contents and fromJSON( contents ) or { }
            fileClose( file )
            --iprint( "Loaded saved counters", UPDATE_COUNTERS )
        end
    end


    -- Активные вкладки в их порядке
    ACTIVE_TABS = {
        {
            name = "Главная",
            key  = "main",
        },
        {
            name = "Пополнение",
            key  = "donate",
        },
        {
            name = "Акции",
            key  = "offers",
            update_count = 5,
        },
        {
            name = "Премиум",
            key  = "premium",
        },
        {
            name = "Уникальные предложения",
            key  = "special",
            update_count = 7,
        },
        {
            name = "Кейсы",
            key  = "cases",
            update_count = 4,
        },
        {
            name = "Услуги",
            key  = "services",
            update_count = 1,
        },
        {
            name = "Рефералы",
            key  = "refferals",
        },
        {
            name = "Колесо Фортуны",
            key  = "roulette",
        },
    }
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )

function SaveUpdateCounters( )
    if fileExists( "counters.nrp" ) then fileDelete( "counters.nrp" ) end

    local file = fileCreate( "counters.nrp" )
    fileWrite( file, toJSON( UPDATE_COUNTERS or { }, true ) )
    fileClose( file )
    --iprint( "Counters saved" )
end

function LoadWebData( data )
    local server = localPlayer:getData( "_srv" )[ 1 ]
    local url = data.get_data_url .. server
    local additional_ids = GetAdditionalCasesIDs( )
    if #additional_ids > 0 then
        url = url .. "?additional=" .. table.concat( additional_ids, "," )
    end
    if root:getData( "timestamp_fake_diff" ) then
        url = url .. ( #additional_ids > 0 and "&" or "?" ) .. "fake_ts=" .. getRealTimestamp()
    end

    fetchRemote( url,
        {
            queueName = "f4_data",
            connectionAttempts = 10,
            connectTimeout = 15000,
            method = "GET",
        },
        function( json_data, err )
            -- Если ошибка чтения, но раньше уже читались кейсы
            if ( not err.success or err.statusCode ~= 200 ) then
                UpdateCasesInfo( false )
                return
            end

            local data = fromJSON( json_data )
            UpdateLimitedSpecialOffersSoldCount( data.offers_counts )
            UpdateCasesInfo( data.cases_info )
        end
    )
end

function onPlayerShowDonate_handler( data )
    LoadWebData( data )
    ShowDonateUI( true, data )

    CONST_GET_DATA_URL = data.get_data_url
end
addEvent( "onPlayerShowDonate", true )
addEventHandler( "onPlayerShowDonate", root, onPlayerShowDonate_handler )

function onPlayerLoadData_handler( data )
    LoadWebData( data )

    CONST_GET_DATA_URL = data.get_data_url
end
addEvent( "onPlayerLoadWebData", true )
addEventHandler( "onPlayerLoadWebData", localPlayer, onPlayerLoadData_handler )

function onPlayerNotHaveSlotsForPurchase_handler( not_from_window )
	ibConfirm( {
        title = "НЕДОСТАТОЧНО СЛОТОВ",
        text = "У вас закончились свободные слоты для транспорта.\nЖелаете купить свободный слот?",
        fn = function( self )
            SendElasticGameEvent( "f4r_f4_unique_auto_slot_proposal_ok" )

            if not_from_window then
                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
            else
                SwitchNavbar( "services" )
            end

            self:destroy( )
        end,
        escape_close = true,
    } )
end
addEvent( "onPlayerNotHaveSlotsForPurchase", true )
addEventHandler( "onPlayerNotHaveSlotsForPurchase", root, onPlayerNotHaveSlotsForPurchase_handler )

function onPayofferInitialize_handler( payoffer )
    PAYOFFER = payoffer
end
addEvent( "onPayofferInitialize", true )
addEventHandler( "onPayofferInitialize", root, onPayofferInitialize_handler )

function GetConstDataURL( )
    return CONST_GET_DATA_URL
end