HUD_CONFIGS.treating_timer = {
    elements = { },
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 30, _, bg, 0xd72a323c )
        self.elements.bg = bg

        self.elements.lbl_left = ibCreateLabel( 18, 15, 0, 0, "Следующее посещение врача через", bg, _, _, _, "left", "center", ibFonts.regular_11 )
        self.elements.lbl_right = ibCreateLabel( 325, 15, 0, 0, "", bg, _, _, _, "right", "center", ibFonts.bold_11 )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function UpdateTimerLabel( time )
    local id = "treating_timer"
    local self = HUD_CONFIGS[ id ]
    
    time = time - 1
    self.elements.lbl_right:ibData( "text", getTimerString( time ) )

    if time > 0 then
        update_timer = setTimer( UpdateTimerLabel, 1000, 1, time )
    else
        RemoveHUDBlock( "treating_timer" )
    end
end

local update_timer = false
function onClientSetTreatingTimer_handler( time_left )
    if not time_left or time_left <= 0 then return end
    AddHUDBlock( "treating_timer" )
    if isTimer( update_timer ) then killTimer( update_timer ) end
    UpdateTimerLabel( time_left )
end
addEvent( "onClientSetTreatingTimer", true )
addEventHandler( "onClientSetTreatingTimer", root, onClientSetTreatingTimer_handler )