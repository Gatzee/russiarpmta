HUD_CONFIGS.nodamage = {
    elements = { },
    use_real_fonts = false,
    order = 0,
    create = function( self, duration )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_nodamage.png", bg )
        self.elements.bg = bg

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function NodamageUpdateState( data )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( true )

    local bg = HUD_CONFIGS.nodamage.elements.bg
    DestroyTableElements( getElementChildren( bg ) )

    if data.style == "progress" then
        local progress_bg = ibCreateImage( 83, 49, 237, 12, "img/nodamage_progress_bg.png", bg )
        local max_width = progress_bg:width( ) - 2

        local progress = ibCreateImage( 1, 1, 0, 10, _, progress_bg, 0xffedcb2d )
            :ibData( "sx", data.from * max_width )
            :ibResizeTo( data.to * max_width, _, data.duration, "Linear" )

        ibCreateLabel( 83, 28, 0, 0, data.text, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_14 )

    elseif data.style == "keyhelp" then
        ibCreateLabel( 83, 28, 0, 0, data.main_text, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_14 )

        local lbl = ibCreateLabel( 83, 57, 0, 0, data.text, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_12 )
        local key_bg = ibCreateImage( lbl:ibGetAfterX( 5 ), lbl:ibGetBeforeY( 1 ), 0, 0, "img/icon_key.png", bg ):ibSetRealSize( )
        ibCreateLabel( 25, 8, 0, 0, data.key, key_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_11 )

    elseif data.style == "timeout" then
        ibCreateLabel( 83, 28, 0, 0, data.main_text, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_14 )
        local lbl = ibCreateLabel( 83, 57, 0, 0, data.text, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_12 )

        local finish = getRealTime( ).timestamp + data.timeout_duration
        local lbl_time = ibCreateLabel( lbl:ibGetAfterX( 5 ), lbl:ibGetCenterY( ), 0, 0, "", bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_11 )
        local function update( )
            local left = finish - getRealTime( ).timestamp
            local minutes = math.floor( left / 60 )
            local seconds = left - minutes * 60
            lbl_time:ibData( "text", string.format( "%d мин. %02d сек.", minutes, seconds ) )
        end
        lbl_time:ibTimer( update, 500, 0 )
        update( )
    end

    ibUseRealFonts( fonts_real )
end

addEvent( "onNodamageUpdateState" )
addEventHandler( "onNodamageUpdateState", root, function( data )
    NodamageUpdateState( data )
end )

addEvent( "onNodamageStart" )
addEventHandler( "onNodamageStart", root, function( )
    RemoveHUDBlock( "nodamage" )
    AddHUDBlock( "nodamage" )
end )

addEvent( "onNodamageStop" )
addEventHandler( "onNodamageStop", root, function( )
    RemoveHUDBlock( "nodamage" )
end )