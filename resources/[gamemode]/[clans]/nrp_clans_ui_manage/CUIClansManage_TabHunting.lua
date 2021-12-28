TABS_CONF.hunting = {
    fn_create = function( self, parent )
        ibCreateLabel( 30, 20, 0, 0, "Заказы", parent, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )

        -- scroll
        UI.orientScroll, UI.orientBar = ibCreateScrollpane( 30, 53, 964, 560, parent, { scroll_px = 10 } )
        UI.orientBar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.02 ):ibTimer( function ( )
            if CLAN_DATA.sputnik > 0 then
                CLAN_DATA.sputnik = CLAN_DATA.sputnik - 1 -- for sync without triggers
            end
        end, 1000, 0 )

        triggerServerEvent( "onPlayerGetOrientations", localPlayer )
    end,
}

addEvent( "onPlayerGetOrientations", true )
addEventHandler( "onPlayerGetOrientations", localPlayer, function ( orientations )
    if not isElement( UI.orientScroll ) then return end

    if #orientations < 1 then
        ibCreateLabel( 0, 270, 1024, 0, "Охота за головами будет позже, ожидайте заказы от граждан", UI.orientScroll, 0xbbffffff, nil, nil, "center", "center", ibFonts.regular_22 )
    end

    for i, d in pairs( orientations ) do
        local player = GetPlayer( d.target_uid )

        if player then
            local area = ibCreateArea( 0, ( i - 1 ) * 165 + ( i - 1 ) * 20, 967, 195, UI.orientScroll )
            local img = ibCreateImage( 0, 0, 967, 165, "img/hunting/orientation.png", area )

            -- nickname
            ibCreateLabel( 154, 54, 0, 0, player:GetNickName( ), img, 0xffffffff, nil, nil, "left", "top", ibFonts.regular_16 )

            ibCreateContentImage( 1, 3, 130, 160, "skin", d.skin, img )

            -- time left
            ibCreateLabel( 440, 30, 0, 0, "", img, 0xffffffff, nil, nil, "right", "top", ibFonts.regular_14 )
            :ibTimer( function ( self )
                d.time_left = d.time_left - 1

                local hour = math.floor( d.time_left / 3600 )
                local min = math.floor( ( d.time_left - hour * 3600 ) / 60 )
                local sec = math.floor( d.time_left - hour * 3600 - min * 60 )

                self:ibData( "text", string.format( "%2d ч %02d мин %02d сек", hour, min, sec ) )

                if d.time_left < 0 then
                    img:destroy( )
                    UI.orientScroll:AdaptHeightToContents( )
                    UI.orientBar:UpdateScrollbarVisibility( UI.orientScroll )
                end
            end, 1000, 0 )

            -- reward
            local label_r = ibCreateLabel( 154, 110, 0, 0, format_price( CLAN_REWARD ), img, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )
            ibCreateImage( label_r:ibGetAfterX( 10 ), 112, 25, 25, ":nrp_shared/img/money_icon.png", img )

            -- progress bar
            local progress_bg = ibCreateImage( 590, 73, 269, 15, nil, img, ibApplyAlpha( COLOR_BLACK, 25 ) )
            local progress = ibCreateImage( 590, 73, 0, 15, nil, img, 0xFF47afff )

            -- description
            local descriptions = {
                "Спутник, который вы арендовали, сократит зону поисков\nдо квадрата 100 на 100 метров на " .. math.floor( SPUTNIK_TIME_AVAILABLE / 3600 / 24 ) .. " дней.",
                "Вы можете арендовать спутник, который сократит зону\nпоисков до квадрата 100 на 100 метров на " .. math.floor( SPUTNIK_TIME_AVAILABLE / 3600 / 24 ) .. " дней.",
            }

            local lbl_description = ibCreateLabel( 735, 20, 0, 0, "", img, 0xffd7dadc, nil, nil, "center", "top", ibFonts.regular_14 )

            -- find
            local btn_open_map = ibCreateButton(
                741, 100, 202, 38, img,
                "img/hunting/btn_find.png", "img/hunting/btn_find_hover.png", "img/hunting/btn_find_hover.png",
                nil, nil, 0xFFAAAAAA
            ):ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )

                if not isElement( player ) then
                    localPlayer:ShowError( "Данный игрок вышел из игры" )
                    return
                elseif player:IsNickNameHidden( ) then
                    localPlayer:ShowError( "Спутник не может определить\nместоположение игрока" )
                    return
                end

                triggerServerEvent( "updateTargetPositionBySputnik", localPlayer, d.target_uid )
            end )

            -- rent sputnik
            local btn_rent = ibCreateButton(
                500, 100, 213, 42, img,
                "img/hunting/btn_sputnik.png", "img/hunting/btn_sputnik_hover.png", "img/hunting/btn_sputnik_hover.png",
                nil, nil, 0xFFAAAAAA
            ):ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                ibConfirm( {
                    title = "АРЕНДА СПУТНИКА",
                    text = "Ты точно хочешь арендовать спутник (на " .. math.floor( SPUTNIK_TIME_AVAILABLE / 3600 / 24 ) .. " дней),\nза " .. format_price( SPUTNIK_PRICE_FOR_CLAN ) .. " рублей?",
                    fn = function( self )
                        self:destroy( )
                        triggerServerEvent( "onPlayerWantRentSputnik", localPlayer )
                    end
                } )
            end )

            local function update( )
                if CLAN_DATA.sputnik > 0 then -- sputnik available
                    btn_rent:ibData( "visible", false )
                    btn_open_map:ibData( "px", 624 )
                    btn_open_map:ibData( "disabled", false )
                    btn_open_map:ibData( "alpha", 255 )
                    lbl_description:ibData( "text", descriptions[1] )

                    progress_bg:ibData( "visible", true )
                    progress:ibData( "sx", 269 * ( CLAN_DATA.sputnik / SPUTNIK_TIME_AVAILABLE ) )

                else -- sputnik not available
                    btn_rent:ibData( "visible", true )
                    btn_open_map:ibData( "px", 741 )
                    btn_open_map:ibData( "disabled", true )
                    btn_open_map:ibData( "alpha", 120 )
                    lbl_description:ibData( "text", descriptions[2] )

                    progress_bg:ibData( "visible", false )
                    progress:ibData( "sx", 0 )
                end
            end

            update( )
            btn_rent:ibTimer( update, 500, 0 )
        end
    end

    UI.orientScroll:AdaptHeightToContents( )
    UI.orientBar:UpdateScrollbarVisibility( UI.orientScroll )
end )