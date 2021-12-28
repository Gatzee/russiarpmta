function CreateCookingTab( )
    local left_col_area = ibCreateArea( 0, 0, 523, UI.tab_area:ibData( "sy" ), UI.tab_area )
    
    ibCreateImage( left_col_area:ibGetAfterX( ), 0, 1, left_col_area:ibData( "sy" ), _, UI.tab_area, ibApplyAlpha( COLOR_WHITE, 10 ) )

    ibCreateLabel( 0, 26, 0, 0, "Ваши рецепты:", left_col_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 ):center_x( )

    if not next( PLAYER_RECIPES ) then
        ibCreateLabel( 0, 0, 0, 0, "У вас нет рецептов", left_col_area, 0xFFaaaaaa, 1, 1, "center", "center", ibFonts.regular_14 ):center( )
        return
    end

	local scrollpane, scrollbar = ibCreateScrollpane( 0, 73, left_col_area:ibData( "sx" ), left_col_area:ibData( "sy" ) - 20, UI.tab_area, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )

    local item_sx = scrollpane:ibData( "sx" )
    local item_sy = 60

    local selected_item_bg = ibCreateArea( 0, 0, item_sx, item_sy, scrollpane )
        :ibData( "disabled", true ):ibData( "priority", 1 )
    ibCreateImage( 0, 0, item_sx, 2, _, selected_item_bg, 0x9078afeb )
    ibCreateImage( 0, 2, 2, item_sy - 2, _, selected_item_bg, 0x9078afeb )
    ibCreateImage( item_sx, 2, -2, item_sy - 2, _, selected_item_bg, 0x9078afeb )
    ibCreateImage( 2, item_sy, item_sx - 4, -2, _, selected_item_bg, 0x9078afeb )
    
    local i = 0
    for recipe_id in pairs( PLAYER_RECIPES ) do
        i = i + 1
        local recipe = RECIPES[ recipe_id ]
        local item_bg = ibCreateImage( 0, item_sy * ( i - 1 ), item_sx, item_sy, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )
        ibCreateImage( 30, 0, 0, 0, "images/dishes/" .. recipe.img .. ".png", item_bg )
            :ibSetRealSize( ):center_y( )

        local name_lbl = ibCreateLabel( 84, 18, 0, 0, recipe.name, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        ibCreateImage( name_lbl:ibGetAfterX( 14 ), 21, 20, 16, "images/icon_calories.png", item_bg )
        ibCreateLabel( name_lbl:ibGetAfterX( 41 ), 18, 0, 0, recipe.calories, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_18 )

        local btn_select = ibCreateButton( item_bg:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_bg, 
            "images/button_select_idle.png", "images/button_select_hover.png", "images/button_select_hover.png", _, _, 0xFFCCCCCC )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                
                ibClick( )

                selected_item_bg:ibMoveTo( 0, item_bg:ibData( "py" ), 150 )
                ShowRecipeInfo( recipe )
            end )
    end

	scrollpane:AdaptHeightToContents()
    scrollbar:UpdateScrollbarVisibility( scrollpane )
    

    
    local right_col_area

    function ShowRecipeInfo( recipe )
        if isElement( right_col_area ) then
            right_col_area:ibAlphaTo( 0, 350 ):ibTimer( destroyElement, 350, 1 )
        end
        if not recipe then return end

        right_col_area = ibCreateArea( left_col_area:ibGetAfterX( 1 ), 0, UI.tab_area:ibData( "sx" ) - left_col_area:ibData( "sx" ), UI.tab_area:ibData( "sy" ), UI.tab_area )
            :ibData( "alpha", 0 ):ibAlphaTo( 255, 350 )

        ibCreateLabel( 0, 26, 0, 0, "Описание:", right_col_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 ):center_x( )
        
        ibCreateLabel( 30, 70, right_col_area:ibData( "sx" ) - 60, 50, recipe.description, right_col_area, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "top", ibFonts.regular_14 )
            -- :ibData( "wordbreak", true )
        local __, lines_count = string.gsub( recipe.description, "\n", "" )
        local line = ibCreateImage( 30, 124 + lines_count * 17, right_col_area:ibData( "sx" ) - 60, 1, _, right_col_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
        
        ibCreateLabel( 0, line:ibGetBeforeY( 30 ), 0, 0, "Требуемые продукты:", right_col_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 ):center_x( )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, line:ibGetBeforeY( 77 ), right_col_area:ibData( "sx" ), right_col_area:ibData( "sy" ) - line:ibGetBeforeY( 77 ) - 20, right_col_area, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local ox = 49
        local can_cook = true
        
        for i, v in pairs( recipe.ingredients ) do
            local ingredient_id = v[ 1 ]
            local need_count = v[ 2 ]
            local ingredient_data = FOOD_INGREDIENTS[ ingredient_id ]
            local px = ox + ( i - 1 ) % 3 * 140
            local py = math.floor( ( i - 1 ) / 3 ) * 140
            local item_bg = ibCreateImage( px, py, 122, 122, "images/item_bg.png", scrollpane )
            local item_img = ibCreateImage( 30, 30, 0, 0, "images/ingredients/big/" .. ingredient_data.sid .. ".png", item_bg )
                :ibSetRealSize( ):center( 0, -14 )
            if ingredient_data.tooltip then
                item_img:ibAttachTooltip( ingredient_data.tooltip )
            end

            local have_count = PLAYER_INGREDIENTS[ ingredient_id ] or 0
            ibCreateLabel( 0, 84, 0, 0, need_count .. " #c0c5cb/ " .. have_count, item_bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 )
                :center_x( ):ibBatchData( {
                    color = ( have_count >= need_count ) and 0xFFFFFFFF or 0xFFFF0000,
                    colored = true,
                } )

            can_cook = can_cook and have_count >= need_count
        end
        -- ibCreateImage( 0, math.ceil( ( #recipe.ingredients * 2 ) / 3 ) * 140, 20, can_cook and 100 or 20, _, scrollpane, 0 )

        scrollpane:AdaptHeightToContents()
        scrollbar:UpdateScrollbarVisibility( scrollpane )

        if can_cook then
            ibCreateImage( ox, right_col_area:ibGetAfterY( -270 ), right_col_area:ibData( "sx" ) - ox * 2, 270, "images/gradient.png", right_col_area )
                :ibData( "disabled", true )

            ibCreateButton( 0, right_col_area:ibGetAfterY( -30 - 44 ), 190, 44, right_col_area, 
                "images/button_cook_idle.png", "images/button_cook_hover.png", "images/button_cook_hover.png", _, _, 0xFFCCCCCC )
                :center_x( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if CLICK_TIMEOUT > getTickCount() then return end
                    CLICK_TIMEOUT = getTickCount() + 700
                    ibClick( )

                    triggerServerEvent( "onPlayerWantCookDish", localPlayer, recipe.id )
                end )
        end
    end

    ShowRecipeInfo( RECIPES[ next( PLAYER_RECIPES ) ] )
end