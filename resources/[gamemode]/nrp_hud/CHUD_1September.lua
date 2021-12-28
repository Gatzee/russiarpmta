HUD_CONFIGS["1september"] = {
    elements = { },

    create = function( self, time_left )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_1september.png", bg ) 
        self.elements.bg = bg

        local label = ibCreateLabel( 89, 48, 0, 50, "", bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_10)
        
        local function UpdateTime( )
            if time_left >= 1 then
                time_left = time_left - 1
                label:ibData( "text", "Время ожидания: "..getHumanTimeString( time_left, false, true ) )
            else
                label:ibData( "text", "Букет готов, забери его!" )
            end
        end
        UpdateTime( )
        label:ibTimer( UpdateTime, 60000, 0 )

        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function Show1SeptemberTimer_handler( state, time_left )
    if state then
        AddHUDBlock( "1september", time_left )
    else
        RemoveHUDBlock( "1september" )
    end
end
addEvent( "Show1SeptemberTimer", true )
addEventHandler( "Show1SeptemberTimer", root, Show1SeptemberTimer_handler )