HUD_CONFIGS.trashman = {
    elements = { },
    use_real_fonts = true,

    create = function( self )
        local bg = ibCreateImage( 0, 0, 338, 56, "img/bg_job_trashman.png", bg )
        self.elements.bg = bg
        self.elements.progress_bar = ibCreateImage( 19, 28, 0, 12, _, self.elements.bg, 0xFFFF975E )
        self.elements.progress_text = ibCreateLabel( 262, 10, 0, 0, "0%", self.elements.bg, 0xFFFFFFFF, _, _, "right", "top", ibFonts.regular_12 )
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( { self.elements.bg } )
        self.elements = { }
    end,
}

function math.round( num,  idp )
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function onClientUpdateTrashTruckFull_handler( value )
    if isElement( HUD_CONFIGS.trashman.elements.progress_bar ) then
        HUD_CONFIGS.trashman.elements.progress_text:ibData( "text", math.round( value, 1 ) * 100 .. "%" )
        HUD_CONFIGS.trashman.elements.progress_bar:ibData( "sx", 242 * value )
    end
end
addEvent( "onClientUpdateTrashTruckFull", true )
addEventHandler( "onClientUpdateTrashTruckFull", root, onClientUpdateTrashTruckFull_handler )

function onClientShowTrashmanHUD_handler()
    if not isElement( HUD_CONFIGS.trashman.elements.bg ) then
        AddHUDBlock( "trashman" )
    end
end
addEvent( "onClientShowTrashmanHUD" )
addEventHandler( "onClientShowTrashmanHUD", root, onClientShowTrashmanHUD_handler )

function onClientHideTrashmanHUD_handler( )
    RemoveHUDBlock( "trashman" )
end
addEvent( "onClientHideTrashmanHUD", true )
addEventHandler( "onClientHideTrashmanHUD", root, onClientHideTrashmanHUD_handler )