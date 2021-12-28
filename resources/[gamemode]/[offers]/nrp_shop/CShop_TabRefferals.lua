local REFFERALS_DATA, REFFERALS_LIST

addEvent( "OnClientReceiveRefferalsData", true )
addEvent( "onCleanRefRewardsRequest", true )

TABS_CONF.refferals = {
    fn_create = function( self, parent )
        REFFERALS_DATA = { }

        local function ShowInfo( )
            local parent = UI.bg
            local sx, sy = 520, 410
            local px, py = ( parent:width( ) - sx ) / 2, ( parent:height( ) - sy ) / 2

            local black_bg = ibCreateImage( 0, 0, parent:width( ), parent:height( ), _, parent, 0xaa000000 )
                :ibData( "priority", 20 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 300 )
            local bg = ibCreateImage( px, py, sx, sy, _, black_bg, 0xFF0c141b )

            ibCreateButton( sx - 24 - 24, 24, 24, 24, bg,
                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    destroyElement( black_bg )
                end )
                :ibData( "priority", 1 )

            local rt, sc = ibCreateScrollpane( 0, 0, bg:width( ), bg:height( ), bg, { scroll_px = -20 } )
            sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )
            ibCreateLabel( 40, 26, 520, 80, "Награды рефералам", rt ):ibBatchData( { font = ibFonts.bold_14 } )

            local rewards_data = 
            {
                {
                    level = 2,
                    target = { money = 3000 },
                    source = { money = 5000 },
                },
                {
                    level = 6,
                    target = { money = 15000 },
                    source = { money = 10000 },
                    both = { exp = 400 },
                },
                {
                    level = 8,
                    target = { money = 20000 },
                    source = { money = 25000 },
                },
                {
                    level = 10,
                    target = { hard = 30 },
                },
                {
                    level = 24,
                    source = { hard = 100 },
                },
            }

            local px, py = 40, 90

            for k,v in pairs(rewards_data) do
                local line = 0

                ibCreateLabel( px, py, 300, 30, "Приглашенный игрок получил "..v.level.." уровень", rt ):ibData( "font", ibFonts.bold_14 )

                py = py + 40

                local types = { "target", "source", "both" }
                local types_texts = {
                    target = "Игрок который пригласил получает",
                    source = "Игрок которого пригласили получает",
                    both = "Оба игрока получают",
                }

                for i, type_name in pairs( types ) do
                    if v[ type_name ] then
                        local cat_text = types_texts[ type_name ]
                        local t_len = dxGetTextWidth( cat_text, 1, ibFonts.bold_11 ) + 5
                        for key, count in pairs( v[ type_name ] ) do
                            ibCreateLabel( px, py, 300, 30, cat_text, rt ):ibData( "font", ibFonts.bold_11 )
                            ibCreateLabel( px+t_len, py, 100, 30, count, rt ):ibData( "font", ibFonts.bold_11 )

                            local img = ibCreateImage( px+t_len+dxGetTextWidth(count, 1, ibFonts.bold_11) + 7, 
                                        py + dxGetFontHeight(1, ibFonts.bold_11)/2, 0, 0, "img/refferals/icon_" .. key .. ".png", rt )
                                        :ibSetRealSize( )
                            img:ibData( "py", img:ibData( "py" ) - img:height( ) / 2 )

                            line = line + 1
                            py = py + 20
                        end
                    end
                end
                
                py = py + 30
            end

            rt:AdaptHeightToContents( )
        end

        local bg_info = ibCreateImage( 30, 65, 740, 100, "img/refferals/bg_info.png", parent )
            :ibOnDestroy( function( ) REFFERALS_DATA = nil end )
        ibCreateImage( 561, 33, 149, 34, "img/refferals/btn_info.png", bg_info )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --iprint( "INFO" )
				SendElasticGameEvent( "f4r_f4_refferals_details_click" )
                ShowInfo( )
            end )

        ibCreateLine( 510, 195, _, 475, ibApplyAlpha( COLOR_WHITE, 10 ), 1, parent )
        ibCreateLine( 511, 330, 770, _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, parent )

        ibCreateLabel( 30, 200, 0, 0, "Ваш реферальный код:", parent, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibData( "font", ibFonts.regular_14 )
        ibCreateLabel( 30, 360, 0, 0, "Активировать реферальный код:", parent, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibData( "font", ibFonts.regular_14 )

        local bg_edit = ibCreateImage( 30, 223, 459, 40, "img/refferals/bg_input.png", parent )
        REFFERALS_DATA.lbl_code = ibCreateLabel( 15, 9, 0, 0, "Загрузка...", bg_edit, ibApplyAlpha( COLOR_WHITE, 75 ) ):ibData( "font", ibFonts.bold_16 )

        ibCreateImage( 427, 10, 18, 21, "img/refferals/btn_copy.png", bg_edit )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                setClipboard( REFFERALS_DATA.lbl_code:ibData( "text" ) )
                localPlayer:ShowSuccess( "Код скопирован!" )
            end )

        local text = "Твой друг должен ввести промокод в игру до получения 2-го уровня. Не забудь рассказать ему про меню F4 и куда нужно ввести код"
        ibCreateLabel( 30, 283, 425, 0, text, parent, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibBatchData( { wordbreak = true, font = ibFonts.regular_12 } )

        local bg_edit = ibCreateImage( 30, 383, 459, 40, "img/refferals/bg_input.png", parent )
        REFFERALS_DATA.edit_code = ibCreateEdit( 15, 0, 420, 40, "", bg_edit, ibApplyAlpha( COLOR_WHITE, 75 ), 0, ibApplyAlpha( COLOR_WHITE, 75 ) ):ibData( "font", ibFonts.bold_16 )

        ibCreateImage( 179, 439, 161, 39, "img/refferals/btn_activate.png", parent )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --iprint( "ACTIVATE" )
				SendElasticGameEvent( "f4r_f4_refferals_code_activate_button_click" )
                triggerServerEvent( "OnPlayerTryApplyCode", localPlayer, REFFERALS_DATA.edit_code:ibData( "text" ) )
            end )

        ibCreateLabel( 565, 195, 0, 0, "Список приглашенных:", parent, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibData( "font", ibFonts.regular_14 )


        local function ShowRefferalsList( )
            local parent = UI.bg
            local sx, sy = 410, 410
            local px, py = ( parent:width( ) - sx ) / 2, ( parent:height( ) - sy ) / 2

            local black_bg = ibCreateImage( 0, 0, parent:width( ), parent:height( ), _, parent, 0xaa000000 )
                :ibData( "priority", 20 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 300 )
            local bg = ibCreateImage( px, py, sx, sy, _, black_bg, 0xFF0c141b )

            ibCreateButton( sx - 24 - 24, 24, 24, 24, bg,
                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    destroyElement( black_bg )
                end )
                :ibData( "priority", 1 )

            local rt, sc = ibCreateScrollpane( 0, 0, bg:width( ), bg:height( ), bg, { scroll_px = -20 } )
            sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )
            ibCreateLabel( 40, 26, 520, 80, "Твои рефералы", rt ):ibBatchData( { font = ibFonts.bold_14 } )

            local npy = 90

            for i, v in pairs( REFFERALS_LIST ) do
                ibCreateImage( 40, npy, 6, 6, v.online and "img/refferals/circle_green.png" or "img/refferals/circle_red.png", rt )
                ibCreateLabel( 50, npy - 6, 0, 30, v.name .. " (" .. v.level .. " ур.)", rt, ibApplyAlpha( COLOR_WHITE, 60 ) ):ibData( "font", ibFonts.bold_13 )

                npy = npy + 30
            end

            --rt:AdaptHeightToContents( )
            rt:ibData( "sy", math.max( npy, rt:ibData( "viewport_sy" ) ) )
            sc:UpdateScrollbarVisibility( rt )
        end    

        local bg = ibCreateImage( 588, 298, 126, 11, "img/refferals/btn_list.png", parent )
            :ibData( "alpha", 200 )
        ibCreateArea( 588, 298 - 10, 126, 11 + 20, parent )
            :ibOnHover( function( ) bg:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) bg:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                if not REFFERALS_LIST or #REFFERALS_LIST <= 0 then
                    localPlayer:ErrorWindow( "Список рефералов пуст!" )
                    return
                end

                ShowRefferalsList( )
            end )

        ibCreateImage( 595, 439, 111, 39, "img/refferals/btn_take.png", parent )
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --iprint( "TAKE" )
				SendElasticGameEvent( "f4r_f4_refferals_reward_button_click" )
                triggerServerEvent( "OnPlayerReceiveRefferalRewards", localPlayer )
            end )

        ibCreateImage( 575, 371, 0, 0, "img/refferals/icon_money.png", parent ):ibSetRealSize( )
        ibCreateImage( 677, 371, 0, 0, "img/refferals/icon_hard.png", parent ):ibSetRealSize( )
        ibCreateImage( 566, 398, 0, 0, "img/refferals/icon_exp.png", parent ):ibSetRealSize( )
        ibCreateImage( 678, 406, 0, 0, "img/refferals/icon_premium.png", parent ):ibSetRealSize( )

        REFFERALS_DATA.lbl_money   = ibCreateLabel( 607, 372, 0, 0, "0", parent ):ibData( "font", ibFonts.bold_14 )
        REFFERALS_DATA.lbl_exp     = ibCreateLabel( 604, 404, 0, 0, "0", parent ):ibData( "font", ibFonts.bold_14 )
        REFFERALS_DATA.lbl_donate  = ibCreateLabel( 709, 372, 0, 0, "0", parent ):ibData( "font", ibFonts.bold_14 )
        REFFERALS_DATA.lbl_premium = ibCreateLabel( 704, 404, 0, 0, "0 д.", parent ):ibData( "font", ibFonts.bold_14 )
    end,
    fn_open = function( self, parent )
        --iprint( "OPENED REFFERALS" )

        local function UpdateRefferals( data )
            --iprint( data )
            REFFERALS_DATA.lbl_code:ibData( "text", data.my_code )

            REFFERALS_DATA.lbl_money:ibData( "text", format_price( data.rewards.money or 0 ) )
            REFFERALS_DATA.lbl_exp:ibData( "text", format_price( data.rewards.exp or 0 ) )
            REFFERALS_DATA.lbl_donate:ibData( "text", format_price( data.rewards.donate or 0 ) )
            REFFERALS_DATA.lbl_premium:ibData( "text", ( data.rewards.premium or 0 ) .. " д." )


            REFFERALS_LIST = { }
            for i, v in pairs( data.refferals ) do
                local player = v.id and GetPlayer( v.id )
                if player then
                    table.insert( REFFERALS_LIST, { name = player:GetNickName( ), level = player:GetLevel( ), online = true } )
                elseif not v.id then
                    table.insert( REFFERALS_LIST, v )
                end
            end

            -- TEST
            --[[for i = 1, 50 do
                table.insert( REFFERALS_LIST, { name = localPlayer:GetNickName( ), level = math.random( 1, 99 ), online = math.random( 1, 2 ) == 1 }  )
            end]]

            DestroyTableElements( REFFERALS_DATA.elements_list )
            REFFERALS_DATA.elements_list = { }
            local npy = 228
            for i = 1, math.min( 3, #REFFERALS_LIST ) do
                local lbl_name = ibCreateLabel( 530, npy, 0, 0, "- " .. REFFERALS_LIST[ i ].name, parent ):ibData( "font", ibFonts.regular_12 )
                local lbl_level = ibCreateLabel( 770, npy, 0, 0, REFFERALS_LIST[ i ].level .. " ур.", parent, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibBatchData( { font = ibFonts.regular_12, align_x = "right" } )
                
                table.insert( REFFERALS_DATA.elements_list, lbl_name )
                table.insert( REFFERALS_DATA.elements_list, lbl_level )

                npy = npy + 21
            end
        end
        addEventHandler( "OnClientReceiveRefferalsData", root, UpdateRefferals )

        local function onCleanRefRewardsRequest_handler( )
            local data = { rewards = { } }
            REFFERALS_DATA.lbl_money:ibData( "text", format_price( data.rewards.money or 0 ) )
            REFFERALS_DATA.lbl_exp:ibData( "text", format_price( data.rewards.exp or 0 ) )
            REFFERALS_DATA.lbl_donate:ibData( "text", format_price( data.rewards.donate or 0 ) )
            REFFERALS_DATA.lbl_premium:ibData( "text", ( data.rewards.premium or 0 ) .. " д." )
        end
        addEventHandler( "onCleanRefRewardsRequest", root, onCleanRefRewardsRequest_handler )

        parent:ibOnDestroy( function( )
            removeEventHandler( "OnClientReceiveRefferalsData", root, UpdateRefferals )
            removeEventHandler( "onCleanRefRewardsRequest", root, onCleanRefRewardsRequest_handler )
        end )

        triggerServerEvent( "OnPlayerRequestRefferalsData", localPlayer )
    end,
}