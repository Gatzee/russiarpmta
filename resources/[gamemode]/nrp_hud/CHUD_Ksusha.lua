
local last_duration = nil
local remove_tick = nil

HUD_CONFIGS.ksusha = {
    elements = { },
    order = 997,
    create = function( self, duration )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_ksusha.png", bg )
        self.elements.bg = bg

        local positions = {
            { 33, 40 },
            { 62, 40 },
            { 84, 38 },
            { 108, 40 },
            { 136, 40 },
        }

        if not duration and last_duration then 
            duration = last_duration
        end

        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        local tick = getTickCount( )
        function UpdateTimer( )
            local time_diff = duration - math.floor( ( getTickCount( ) - tick ) / 1000 )

            if time_diff <= 0 then
                RemoveHUDBlock( "ksusha" )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.ceil( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", hours )
            minutes = string.format( "%02d", minutes )

            local str = hours .. ":" .. minutes
            for i = 1, #positions do
                local symbol = utf8.sub( str, i, i )
                self.elements[ "lbl_symbol_" .. i ]:ibData( "text", symbol )
            end

            last_duration = time_diff
        end

        self.elements.timer = setTimer( UpdateTimer, 200, 0 )
        UpdateTimer( )

        last_duration = duration
        return bg
    end,

    destroy = function( self )
        remove_tick = getTickCount()

        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

addEvent( "onKsushaWaitStart" )
addEventHandler( "onKsushaWaitStart", root, function( duration )
    RemoveHUDBlock( "ksusha" )
    if duration or last_duration then
        local time_left = duration or last_duration
        if remove_tick then
            local time_passed  = math.floor( ( getTickCount( ) - remove_tick ) / 1000 )
            time_left = time_left - time_passed
        end

        AddHUDBlock( "ksusha", time_left )
    end
end )

addEvent( "onKsushaWaitStop" )
addEventHandler( "onKsushaWaitStop", root, function( duration )
    RemoveHUDBlock( "ksusha" )
end )