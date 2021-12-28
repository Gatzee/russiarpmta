HUD_CONFIGS.counter = {
    elements = { },
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 30, _, bg, 0xd72a323c )
        self.elements.bg = bg

        self.elements.lbl_left = ibCreateLabel( 18, 15, 0, 0, "", bg, _, _, _, "left", "center", ibFonts.regular_11 )
        self.elements.lbl_right = ibCreateLabel( 325, 15, 0, 0, "", bg, _, _, _, "right", "center", ibFonts.bold_11 )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function COUNTER_onElementDataChange( key )
    if key == "hud_counter" then
        if localPlayer:getData( key ) then
            AddHUDBlock( "counter" )
            RefreshCounter( )
        else
            RemoveHUDBlock( "counter" )
        end
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, COUNTER_onElementDataChange )

function RefreshCounter( )
    local id = "counter"
    local self = HUD_CONFIGS[ id ]

    local data = localPlayer:getData( "hud_counter" ) or { }

    if data.bg_sy then
        self.elements.bg:ibData( "sy", data.bg_sy )
        
        local py = data.bg_sy / 2
        self.elements.lbl_left:ibData( "py", py )
        self.elements.lbl_right:ibData( "py", py )
    end

    self.elements.lbl_left:ibData( "text", data.left or "" )
    self.elements.lbl_right:ibData( "text", data.right or "" )
end

function COUNTER_onStart( )
    local counter = localPlayer:getData( "hud_counter" )
    if localPlayer:IsInGame( ) and counter then
        AddHUDBlock( "counter" )
        RefreshCounter( )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, COUNTER_onStart )

function COUNTER_onClientPlayerNRPSpawn_handler( spawn_mode )
    if spawn_mode == 3 then return end
    COUNTER_onStart( )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, COUNTER_onClientPlayerNRPSpawn_handler )