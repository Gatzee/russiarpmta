table.insert( CLAN_SEASON_REWARDS[ 1 ].clan, { type = "cartel_war" } )
table.insert( CLAN_SEASON_REWARDS[ 2 ].clan, { type = "cartel_war" } )

TABS_CONF.rewards = {
    fn_create = function( self, parent )
        local scrollpane, scrollbar = ibCreateScrollpane( 0, 0, 
            parent:ibData( "sx" ), parent:ibData( "sy" ), 
            parent, { scroll_px = -20 }
        )
        scrollbar:ibSetStyle( "slim_nobg" )

        ibCreateLabel( 30, 14, 0, 0, "Награды за текущий сезон", scrollpane, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )

        local bg = ibCreateImage( 0, 0, 1024, 426, "img/rewards/bg.png", scrollpane )

        local positions_grid = {
            {
                {
                    px = 190,
                    py = 324,
                    position = 2,
                },
                {
                    px = 516,
                    py = 324,
                    position = 1,
                },
                {
                    px = 837,
                    py = 324,
                    position = 3,
                },
            },
            {
                {
                    px = 351,
                    py = 0,
                    position = 4,
                    position_text = "IV-V",
                },
                {
                    px = 672,
                    py = 0,
                    position = 6,
                    position_text = "VI-VIII",
                },
            },
        }

        local upper_row_bottom_py = 0
        for row_i, cols in pairs( positions_grid ) do
            local row_bottom_py = 0
            
            for col_i, col in pairs( cols ) do
                local px, py = col.px - 92, upper_row_bottom_py + col.py

                if col.position_text then
                    py = py + 80
                    ibCreateImage( px + 25, py, 136, 123, "img/rewards/bg_position.png", scrollpane )
                    ibCreateLabel( px + 25, py, 136, 123, col.position_text, scrollpane, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_26 ) 
                    py = py + 123 + 30
                end

                local rewards = CLAN_SEASON_REWARDS[ col.position ]
                for reward_receiver, items in pairs( rewards ) do
                    local str = reward_receiver == "clan" and "В общак клана:" or "Участникам клана:"
                    ibCreateLabel( px + 92, py, 0, 0, str, scrollpane, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.bold_16 )
                    py = py + 20
                    for i, item in pairs( items ) do
                        local area = ibCreateArea( px - 40, py, 0, 40, scrollpane )
                        -- reward icon
                        ibCreateImage( 0, 0, 0, 0, "img/rewards/icon_" .. item.type .. ".png", area )
                            :ibSetRealSize( )
                            :center( 24 )
                        -- reward name and count
                        local text =    item.type == "money"            and format_price( item.count ) .. " р."
                                        or item.type == "weapon"        and item.count .. " шт. " .. WEAPONS_LIST[ item.id ].Name
                                        or item.type == "cartel_war"    and "Война за Дом Картеля"
                        ibCreateLabel( 68, 0, 0, 0, text, area, COLOR_WHITE, 1, 1, "left", "center" )
                            :ibData( "font", item.type == "money" and ibFonts.bold_14 or ibFonts.regular_14 )
                            :center( 68 )
                        py = py + 40
                    end
                    py = py + 20
                end

                row_bottom_py = math.max( row_bottom_py, py )
            end
            
            for col_i, col in pairs( cols ) do
                if col_i ~= 1 then
                    local px = 30 + ( col_i - 1 ) * ( scrollpane:width( ) - 60 ) / #cols
                    local py = upper_row_bottom_py + 81
                    ibCreateImage( px, py, 1, row_bottom_py - 71 - upper_row_bottom_py, _, scrollpane, ibApplyAlpha( COLOR_WHITE, 10 ) )
                end
            end
            upper_row_bottom_py = row_bottom_py
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}