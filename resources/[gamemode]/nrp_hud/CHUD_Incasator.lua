HUD_CONFIGS.incasator = {
    elements = { },
    use_real_fonts = true,

    create = function( self )
        local bg = ibCreateImage( 0, 0, 337, 119, "img/bg_incasator.png", bg )
        self.elements.bg = bg
        self.elements.progress_bar = ibCreateImage( 19, 91, 0, 12, _, self.elements.bg, 0xFFFF975E )
        self.elements.progress_text = ibCreateLabel( 238, 73, 0, 0, "0%", self.elements.bg, 0xFFFFFFFF, _, _, "left", "top", ibFonts.regular_12 )
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

function onClientUpdateVanFull_handler( value )
    if isElement( HUD_CONFIGS.incasator.elements.progress_bar ) then
        HUD_CONFIGS.incasator.elements.progress_text:ibData( "text", math.round( value, 1 ) * 100 .. "%" )
        HUD_CONFIGS.incasator.elements.progress_bar:ibData( "sx", 242 * value )
    end
end
addEvent( "onClientUpdateVanFull", true )
addEventHandler( "onClientUpdateVanFull", root, onClientUpdateVanFull_handler )

function onClientCreateIncasatorInfo_handler()
    if not isElement( HUD_CONFIGS.incasator.elements.bg ) then
        AddHUDBlock( "incasator" )
    end
end
addEvent( "onClientCreateIncasatorInfo" )
addEventHandler( "onClientCreateIncasatorInfo", root, onClientCreateIncasatorInfo_handler )

function onClientDestroyIncasatorInfo_handler( )
    RemoveHUDBlock( "incasator" )
end
addEvent( "onClientDestroyIncasatorInfo", true )
addEventHandler( "onClientDestroyIncasatorInfo", root, onClientDestroyIncasatorInfo_handler )