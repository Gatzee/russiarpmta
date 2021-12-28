function CreateRecipesTab( )
	local scrollpane, scrollbar = ibCreateScrollpane( 0, 20, UI.tab_area:ibData( "sx" ), UI.tab_area:ibData( "sy" ) - 20, UI.tab_area, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )
    
    local i = 0
    for recipe_id, recipe in pairs( RECIPES ) do
        i = i + 1
        local item_bg = ibCreateImage( 0, 115 * ( i - 1 ), scrollpane:ibData( "sx" ), 115, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )
        ibCreateImage( 30, 0, 0, 0, "images/dishes/big/" .. recipe.img .. ".png", item_bg )
            :ibSetRealSize( ):center_y( )

        local name_lbl = ibCreateLabel( 120, 18, 0, 0, recipe.name, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        ibCreateImage( name_lbl:ibGetAfterX( 14 ), 21, 20, 16, "images/icon_calories.png", item_bg )
        ibCreateLabel( name_lbl:ibGetAfterX( 41 ), 18, 0, 0, recipe.calories, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_18 )

        local how_get_lbl = ibCreateLabel( 120, 50, 0, 0, "Способ получения:", item_bg, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "top", ibFonts.regular_14 )
        ibCreateLabel( how_get_lbl:ibGetAfterX( 11 ), how_get_lbl:ibData( "py" ) - 2, 0, 0, recipe.how_get_text, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_16 )

        local desc_lbl = ibCreateLabel( 120, 78, 0, 0, "Описание:", item_bg, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "top", ibFonts.regular_14 )
        ibCreateLabel( desc_lbl:ibGetAfterX( 11 ), desc_lbl:ibData( "py" ) - 2, 0, 0, "Наведите курсор, чтобы посмотреть описание", item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_16 )

        local tooltip_area = ibCreateArea( 0, 0, item_bg:ibData( "sx" ) * 0.6, item_bg:ibData( "sy" ), item_bg )
            :ibAttachTooltip( recipe.description )

        if PLAYER_RECIPES[ recipe_id ] then
            ibCreateLabel( item_bg:ibData( "sx" ) - 30, 0, 0, 0, "в наличии", item_bg, 0xFF7efe4c, 1, 1, "right", "center", ibFonts.bold_16 ):center_y( )

        elseif recipe.hard_cost then
            local btn_buy = ibCreateButton( item_bg:ibData( "sx" ) - 30 - 113, 0, 113, 39, item_bg, 
                "images/button_buy_idle.png", "images/button_buy_hover.png", "images/button_buy_hover.png", _, _, 0xFFCCCCCC )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if CLICK_TIMEOUT > getTickCount() then return end
                    CLICK_TIMEOUT = getTickCount() + 700
                    ibClick( )

                    ibConfirm(
                        {
                            title = "ПОКУПКА РЕЦЕПТА", 
                            text = "Ты хочешь купить рецепт "..recipe.name.." за "..format_price( recipe.hard_cost ).." доната?" ,
                            fn = function( self )
                                triggerServerEvent( "onPlayerWantBuyRecipe", localPlayer, recipe_id )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )
                end )
        
            local cost_area = ibCreateArea( 0, 0, 0, 0, item_bg )
            local cost_text_lbl = ibCreateLabel( 0, 0, 0, 0, "Стоимость:", cost_area, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "top", ibFonts.regular_14 )
            local cost_lbl = ibCreateLabel( cost_text_lbl:ibGetAfterX( 8 ), -4, 0, 0, format_price( recipe.hard_cost ), cost_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
            local cost_money_img = ibCreateImage( cost_lbl:ibGetAfterX( 8 ), -2, 24, 24, ":nrp_shared/img/hard_money_icon.png", cost_area )
            cost_area:ibBatchData( {
                px = btn_buy:ibGetBeforeX( -30 - cost_money_img:ibGetAfterX( ) ),
                sy = cost_text_lbl:ibGetAfterY( ),
            } ):center_y( )

        else
            ibCreateLabel( item_bg:ibData( "sx" ) - 30, 0, 0, 0, "отсутствует", item_bg, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "right", "center", ibFonts.bold_16 ):center_y( )
        end
    end

	scrollpane:AdaptHeightToContents()
	scrollbar:UpdateScrollbarVisibility( scrollpane )
end