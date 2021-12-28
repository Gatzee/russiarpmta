enum "eCoopJobRoles" 
{
    "DRIVER",
    "FISHERMAN",
    "COORDINATOR",
}

HUD_CONFIGS.industrial_fishing = {
    elements = { },
    independent = true,
    use_real_fonts = true,
    role = nil,

    create = function( self )
        local bg = ibCreateBackground( 0x00000000, _, _, true )
        self.elements.bg = bg

        if self.role == DRIVER then
            --заполненность трюма
            self.elements.hold = ibCreateImage( _SCREEN_X - 351, _SCREEN_Y - 221, 333, 55, "img/bg_industrial_fishing.png", self.elements.bg )
            self.elements.progress_bar_hold = ibCreateImage( 14, 27, 0, 12, _, self.elements.hold, 0xFFFF975E )
            self.elements.progress_text_hold = ibCreateLabel( 255, 7, 0, 0, "0%", self.elements.hold, 0xFFFFFFFF, _, _, "right", "top", ibFonts.regular_12 )

            --иконки
            self.elements.fuel_icon = ibCreateImage( _SCREEN_X - 218, _SCREEN_Y - 53, 39, 44, "img/canister_icon.png", self.elements.bg )
            self.elements.repair_icon = ibCreateImage( _SCREEN_X - 94, _SCREEN_Y - 53, 45, 44, "img/repair_icon.png", self.elements.bg )
        elseif self.role == FISHERMAN then
            
            --заполненность сетей
            self.elements.hold = ibCreateImage( _SCREEN_X - 351, _SCREEN_Y - 221, 333, 55, "img/bg_industrial_fishing_2_1.png", self.elements.bg )
            self.elements.progress_bar_hold = ibCreateImage( 14, 27, 0, 12, _, self.elements.hold, 0xFFFF975E )
            self.elements.progress_text_hold = ibCreateLabel( 255, 7, 0, 0, "0%", self.elements.hold, 0xFFFFFFFF, _, _, "right", "top", ibFonts.regular_12 )

            --глубина
            self.elements.depth = ibCreateImage( _SCREEN_X - 351, _SCREEN_Y - 221 + 65, 333, 55, "img/bg_industrial_fishing_2_2.png", self.elements.bg )
            self.elements.progress_bar_depth = ibCreateImage( 14, 27, 0, 12, _, self.elements.depth, 0xFFFF975E )
            self.elements.progress_text_depth = ibCreateLabel( 255, 7, 0, 0, "0М", self.elements.depth, 0xFFFFFFFF, _, _, "right", "top", ibFonts.regular_12 )
        end
        
        return bg
    end,

    destroy = function( self )        
        DestroyTableElements( { self.elements.bg } )
        self.elements = { }
        self.role = nil
    end,
}

function math.round( num,  idp )
	local mult = 10^( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult
end

--прогресс бар
function UpdateIndustrialFishingProgress_handler( data )
    local data = data[ HUD_CONFIGS.industrial_fishing.role ]
    if isElement( HUD_CONFIGS.industrial_fishing.elements[ "progress_bar_" .. data.index ] ) then
        local progress_value = 242 * data.value
        local progress_text = data.depth and (data.depth .. "M") or (math.round( data.value, 2 ) * 100 .. "%")
        HUD_CONFIGS.industrial_fishing.elements[ "progress_text_" .. data.index ]:ibData( "text", progress_text )
        HUD_CONFIGS.industrial_fishing.elements[ "progress_bar_" .. data.index ]:ibData( "sx", progress_value )
    end
end
addEvent( "UpdateIndustrialFishingProgress", true )
addEventHandler( "UpdateIndustrialFishingProgress", root, UpdateIndustrialFishingProgress_handler )


function onClientCreateIndustrialFishingInfo_handler( role )
    if not isElement( HUD_CONFIGS.industrial_fishing.elements.bg ) then
        HUD_CONFIGS.industrial_fishing.role = role
        AddHUDBlock( "industrial_fishing" )
    end
end
addEvent( "onClientCreateIndustrialFishingInfo", true )
addEventHandler( "onClientCreateIndustrialFishingInfo", root, onClientCreateIndustrialFishingInfo_handler )

function onClientDestroyIndustrialFishingInfo_handler( )
    RemoveHUDBlock( "industrial_fishing" )
end
addEvent( "onClientDestroyIndustrialFishingInfo", true )
addEventHandler( "onClientDestroyIndustrialFishingInfo", root, onClientDestroyIndustrialFishingInfo_handler )