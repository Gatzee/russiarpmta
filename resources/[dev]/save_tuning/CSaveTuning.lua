loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UI = { }

function ShowParseUI( state )
	if not state then
		if isElement( UI.bg ) then
			UI.bg:ibTimer( destroyElement, 200, 1 )
		end
		showCursor( false )
		return
	end

	ShowParseUI( false )
	showCursor( true )

	UI.bg = ibCreateImage( 0, 0, 400, 100, nil, nil, 0xFF385B74 ):center( )

	UI.edit = ibCreateWebEdit( 30, 30, 400 - 60 - 100 - 20, 40, "", UI.bg, COLOR_WHITE )
		:ibBatchData( {
			font = "regular_10",
			placeholder = "Вставить сюда",
			placeholder_color = ibApplyAlpha( COLOR_WHITE, 40 ),
			bg_color = 0xFF3e5065,
			bg_color_focused = 0xFF2c3a49,
		} )

	UI.btn = ibCreateButton( 400 -30 -100, 30, 100, 40, UI.bg, _, _, _, 0x33000000, 0x77000000, 0xAA000000 )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				local str = UI.edit:ibData( "text" )
				ShowParseUI( false )

				if str:sub( 1, 1 ) == "\"" then
					str = str:sub( 2, -2 )
				end
				str = str:gsub( '""', '"' )
				
				local fn, error = loadstring( "return " .. str )
				local data = fn and fn( )
				if not data or type( data ) ~= "table" then
					localPlayer:ErrorWindow( "Ошибка" )
					return
				end
				triggerServerEvent( "ApplyTuning", resourceRoot, data )
			end
		end)
	ibCreateLabel( 0, 0, 0, 0, "Применить", UI.btn, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_12 ):center( )
end
addCommandHandler( "parse_tuning", ShowParseUI )

addEvent( "SaveDataToClipboard", true )
addEventHandler( "SaveDataToClipboard", root, function( data )
	data = inspect( data, { indent = "    " } )
	outputConsole( data )
	setClipboard( data )
end )