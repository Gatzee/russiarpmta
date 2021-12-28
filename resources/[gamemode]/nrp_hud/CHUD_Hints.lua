local CURRENT_ALPHA = 255

HUD_CONFIGS.hints = {
    elements = { },
    fns = { },
    independent = true, -- Не управлять позицией худа
    use_real_fonts = false,
    create = function( self, text )
        local x, y = guiGetScreenSize( )

        iprint( getTickCount( ), "Create alpha", CURRENT_ALPHA )
        local bg = ibCreateArea( 0, y - 70 - 20, 551, 70 ):center_x( )
        local bg_img = ibCreateImage( 0, 0, 551, 70, "img/hints/bg.png", bg )

        local inner_area = ibCreateArea( 0, 23, 0, 0, bg )
        local lbl_before = ibCreateLabel( 0, 0, 0, 0, "Нажмите", inner_area, _, _, _, _, _, ibFonts.bold_14 ):ibData( "outline", 1 )
        local icon_f1 = ibCreateImage( lbl_before:ibGetAfterX( 15 ), 0, 0, 0, "img/hints/f1.png", inner_area ):ibSetRealSize( )
        local lbl_after = ibCreateLabel( icon_f1:ibGetAfterX( 15 ), 0, 0, 0, text or "Чтобы открыть горячие клавиши", inner_area, _, _, _, _, _, ibFonts.bold_14 ):ibData( "outline", 1 )

        inner_area:ibData( "sx", lbl_after:ibGetAfterX( ) ):center_x( )
        
        table.insert( self.elements, bg )
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        self.elements = { }
    end,
}

function onHintsAlphaRequest_handler( alpha )
    if isElement( HUD_CONFIGS.hints.elements[ 1 ] ) then
        HUD_CONFIGS.hints.elements[ 1 ]:ibAlphaTo( alpha, 100 )
    end
    CURRENT_ALPHA = alpha
end
addEvent( "onHintsAlphaRequest", true )
addEventHandler( "onHintsAlphaRequest", root, onHintsAlphaRequest_handler )

function onHUDDisplayHint_handler( hint, values )
    RemoveHUDBlock( "hints" )
    if hint then
        AddHUDBlock( "hints", values and values.text )
        onHintsAlphaRequest_handler( CURRENT_ALPHA )
    end
end
addEvent( "onHUDDisplayHint", true )
addEventHandler( "onHUDDisplayHint", root, onHUDDisplayHint_handler )