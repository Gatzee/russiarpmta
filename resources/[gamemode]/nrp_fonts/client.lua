local FONTS	= { }
local S_FONTS_RESOURCE_PATH = "Resources/Fonts/"

function getPathFromFontPointer( pointer )

end

function onClientResourceStop_handler( )
	addEvent( "ibClearFontsCache", true )
	triggerEvent( "ibClearFontsCache", root )
end
addEventHandler( "onClientResourceStop", resourceRoot, onClientResourceStop_handler )

function DXFont( font_name, size, _, quality )
	local size = size or 9
	if not FONTS[ font_name ] then FONTS[ font_name ] = { } end
	local font_conf = FONTS[ font_name ]
	font_conf[ size ] = font_conf[ size ] or dxCreateFont( S_FONTS_RESOURCE_PATH .. font_name, size, false, quality or "antialiased" )
	
	return font_conf[ size ]
end