TABS_CONF.stats = {
    fn_create = function( self, parent )
        local keys = {
            "total_kills",
            "total_time",
            "score_earned",
            "foe_kills",
            "points_captured",
            "weapons_bought",
            "tags",
            "arrests",
            "jail_time",
        }

        local time_value = {
            total_time = true,
            jail_time = true,
        }

        local time_online =  math.floor( ( getRealTimestamp( ) - localPlayer:getData( "time_clan_login" ) ) / 60 )

        if CLAN_DATA.stats[ "total_time" ] then
            CLAN_DATA.stats[ "total_time" ] = CLAN_DATA.stats[ "total_time" ] + time_online
        else
            CLAN_DATA.stats[ "total_time" ] = time_online
        end

        local bg = ibCreateImage( 30, 20, 965, 429, "img/stats/bg.png", parent )
        local col_count = 3
        for i, key in pairs( keys ) do
            local px = 141 + 328 * ( ( i - 1 ) % col_count )
            local py = 84 + 130 * math.floor( ( i - 1 ) / col_count )
            local value = CLAN_DATA.stats[ key ] or 0
            local text = time_value[ key ] and ( value or 0 ) > 0 and getHumanTimeString( value, true, true ) or value
            ibCreateLabel( px, py, 0, 0, text, bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        end
    end,
}