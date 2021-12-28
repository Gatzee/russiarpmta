TABS_CONF.boosters = {
    fn_create = function( self, parent )
        CreateLevelProgressBar( "boosters", 918, parent )

        local bg = ibCreateImage( 30, 70, 964, 513, "img/boosters/bg.png", parent )

        local blocks = {
            { sx = 306, booster_id = 2 },
            { sx = 308, booster_id = 4 },
            { sx = 306, booster_id = 3 },
        }
        local gap = 22
        local px = 0
        for i, block in pairs( blocks ) do
            local area = ibCreateArea( px, 0, block.sx, 306, bg )

            local booster = BP_BOOSTERS[ block.booster_id ]
            local cost, discount = GetBattlePassBoosterCost( block.booster_id )

            local days_area = ibCreateArea( 0, 60, 0, 0, area )
            local lbl_days_text = ibCreateLabel( 0, 0, 0, 0, "на ", days_area, ibApplyAlpha( COLOR_WHITE, 65 ), _, _, "left", "center", ibFonts.regular_16 )
            local lbl_days_number = ibCreateLabel( lbl_days_text:ibGetAfterX( ), 0, 0, 0, booster.days, days_area, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
            local lbl_days_text = ibCreateLabel( lbl_days_number:ibGetAfterX( 1 ), 0, 0, 0, plural( booster.days, " день", " дня", " дней" ), days_area, ibApplyAlpha( COLOR_WHITE, 65 ), _, _, "left", "center", ibFonts.regular_16 )
            days_area:ibData( "px", ( block.sx - lbl_days_text:ibGetAfterX( ) ) * 0.5 )

            local cost_area = ibCreateArea( 0, 387, 0, 0, area )
            local cost_text_lbl = ibCreateLabel( 0, 0, 0, 0, "Стоимость:", cost_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_14 )
            local cost_lbl = ibCreateLabel( cost_text_lbl:ibGetAfterX( 8 ), 0, 0, 0, format_price( cost ), cost_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
            local cost_money_img = ibCreateImage( cost_lbl:ibGetAfterX( 8 ), 0, 24, 24, ":nrp_shared/img/hard_money_icon.png", cost_area ):center_y( )
            cost_area:ibData( "px", ( block.sx - cost_money_img:ibGetAfterX( ) ) * 0.5 )

            if discount then
                local bg_discount = ibCreateImage( 182, -9, 136, 136, "img/boosters/sale.png", area )
                ibCreateLabel( 85, 48, 0, 0, discount .. "%", bg_discount, COLOR_WHITE, 1.2, 1, "center", "center", ibFonts.oxaniumextrabold_28 ):ibData( "rotation", 45 )

                AddUpdateEventHandler( "booster_end_ts", "booster_discount" .. i, function()
                    if not isElement( bg_discount ) then return end
                    bg_discount:ibAlphaTo( 0 ):ibTimer( destroyElement, 200, 1 )

                    cost, discount = GetBattlePassBoosterCost( block.booster_id )
                    cost_lbl:ibData( "text", cost )
                end )
            end

            ibCreateButton( 0, 411, 130, 46, area, 
                    "img/boosters/btn_buy.png", "img/boosters/btn_buy_h.png", "img/boosters/btn_buy_h.png", 
                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                :center_x( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    ibConfirm( {
                        title = "ПОДТВЕРЖДЕНИЕ", 
                        text = "Ты хочешь купить усиление за",
                        cost = cost,
                        cost_is_soft = false,
                        fn = function( self ) 
                            self:destroy()
                            triggerServerEvent( "BP:onPlayerWantBuyBooster", resourceRoot, block.booster_id )
                        end,
                        escape_close = true,
                    } )
                end )

            px = px + block.sx + gap
        end
    end,
}