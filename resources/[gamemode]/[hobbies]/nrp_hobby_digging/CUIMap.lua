local ui = {}
local sizeX, sizeY = 760, 550
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

function ShowUI_Map( state, data )
	if state then
		if isElement( ui.black_bg ) then return end

		ui.black_bg = ibCreateBackground( 0x3f1c252e, ShowUI_Map, _, true )
		ui.map = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/maps/" .. TREASURE_LOCATIONS_LIST[ data.map_id ].id .. ".png", ui.black_bg )

		if not data.no_cursor then
			ui.btn_close = ibCreateButton( sizeX-60, 25, 24, 24, ui.map, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "down" then return end
				ibClick()
				ShowUI_Map(false)	
			end)

			showCursor(true)
		end
	else
		if isElement( ui.black_bg ) then
			destroyElement( ui.black_bg )
		end
		showCursor(false)
	end
end
addEvent( "ShowUI_DiggingMap", true )
addEventHandler( "ShowUI_DiggingMap", root, ShowUI_Map )