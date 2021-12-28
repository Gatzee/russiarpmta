TABS_CONF.levels = {
    fn_create = function( self, parent )
        local scrollpane, scrollbar = ibCreateScrollpane( 0, 0, 
            parent:ibData( "sx" ), parent:ibData( "sy" ), 
            parent, { scroll_px = -20 }
        )
        scrollbar:ibSetStyle( "slim_nobg" )

        local bg = ibCreateImage( 29, 81, 966, 729, _, scrollpane, 0xFF3e5165 )
        local bg_img = ibCreateImage( 0, -61, 966, 790, "img/levels/bg_" .. ( CLAN_DATA.way or 1 ) .. ".png", bg )

        local item_sx, item_sy = 241, 242
        local col_count = 4
        for level = 1, 10 do
            local px = item_sx * ( ( level - 1 ) % col_count )
            local py = item_sy * math.floor( ( level - 1 ) / col_count )

            if CLAN_DATA.rank >= level then
                ibCreateImage( px + 58, py + 10, 14, 14, "img/levels/icon_unlocked.png", bg )
                ibCreateImage( px, py, item_sx, item_sy, "img/levels/bg_unlocked.png", bg )
                    :ibData( "priority", -1 )
            else
                ibCreateImage( px + 58, py + 10, 14, 14, "img/levels/icon_locked.png", bg )
                ibCreateImage( px, py + 39, item_sx - 1, item_sy - 39, _, bg, ibApplyAlpha( 0xFF3e5165, 60 ) )
            end
        end

        ibCreateArea( 534, 256, 139, 36, bg_img )
            :ibAttachTooltip( "Активация баффов клана, полученных при развитии тематики клана" )

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}