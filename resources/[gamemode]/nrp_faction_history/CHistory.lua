loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "ib" )

COLUMNS_SEQUENCE = {
	{ 
		key = "faction_id",
		name = "Фракция",
		size_x = 150,
		color = 0xFF4b4b4b,
		func = function( value )
			return FACTIONS_NAMES[ tonumber( value ) ]
		end,
	},
	{ 
		key = "action",
		name = "Статус",
		size_x = 105,
		func = function( value )
			local pColors = {
				["Принят"] = 0xFF2b8b28,
				["Повышен"] = 0xFF2b8b28,
				["Уволен"] = 0xFFa53434,
				["Понижен"] = 0xFFa53434,
			}

			return {value, pColors[ value ] or 0xFF2b8b28}
		end
	},
	{ 
		key = "timestamp",
		name = "Дата",
		size_x = 145,
		func = function( value )
			local formatted = formatTimestamp( value )
			formatted = string.gsub( formatted, "-", "/" )
			formatted = string.sub( formatted, 1, #formatted - 3 )
			return formatted
		end
	},
	{ 
		key = "reason",
		name = "Причина",
		size_x = 150,
		func = function( value )
			return value
		end
	},
	{ 
		key = "rank",
		name = "Звание",
		size_x = 120,
		func = function( value )
			return value
		end
	},
}

local total_height = 44
local line_height = 22
local pData = { }
local ui = { }

ibUseRealFonts( true )

function ShowUI( state, source )
	if isElement( ui.loading ) then
		ui.loading:destroy( )
	elseif not localPlayer:SetStateShowDocuments( state, source ) then
		return
	end

	if state then
		ShowUI( false )
		showCursor( true )

		total_height = 44

		for k,v in pairs( pData ) do
			total_height = total_height + 44 + (v.total_lines - 1) * line_height
		end

		local bg_sx, bg_sy = 750, 480
		ui.main = ibCreateImage( 0, 0, bg_sx, bg_sy, "files/img/bg.png" ):center()
		
		ibCreateLabel( ui.main:width( ) - 5, ui.main:height( ) - 3, 0, 0, source:GetNickName( ), ui.main, COLOR_BLACK, 1, 1, "right", "bottom", ibFonts.regular_14 )

		ibCreateButton( bg_sx-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			ShowUI( false )
		end )
		
		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 89, bg_sx, bg_sy-90, ui.main, {
			scroll_px = -25,
			handle_color = 0x99000000,
			bg_color = 0,
		} )

		local px,py = 35, 2
		for i, column in pairs( COLUMNS_SEQUENCE ) do
			ibCreateImage( px, py, column.size_x, 44, _, ui.scrollpane, 0xeec1c1c1 )
			ibCreateLabel( px+15, py, column.size_x, 44, column.name, ui.scrollpane, 0xFF000000, 1, 1, "left", "center", ibFonts.bold_14 )

			ibCreateImage( px, py-1, 1, total_height, _, ui.scrollpane, 0xFFb6b5b6 )

			px = px + column.size_x
		end

		ibCreateImage( 35, py-1, 671, 1, _, ui.scrollpane, 0xFFb6b5b6 )
		ibCreateImage( px, py-1, 1, total_height, _, ui.scrollpane, 0xFFb6b5b6 )
		ibCreateImage( 35, total_height-1, 671, 1, _, ui.scrollpane, 0xFFb6b5b6 )

		py = py + 44

		for k, v in pairs( pData ) do
			local size_y = 44 + (v.total_lines - 1) * line_height
			px = 35
			for i, column in pairs( COLUMNS_SEQUENCE ) do
				local value = v[ column.key ]
				local text = column.key == "action" and ( value[1] or "-" ) or value
				local color = column.key == "action" and value[2] or column.color or 0xFF000000

				ibCreateLabel( px+10, py, column.size_x - 20, size_y, text or "-",
					ui.scrollpane, color or 0xFF000000, 1, 1, "left", "center",
					ibFonts.bold_14 )
				:ibBatchData{ clip = true, wordbreak = true }

				if column.key == "rank" and localPlayer:GetAccessLevel( ) >= ACCESS_LEVEL_SUPERVISOR then
					ibCreateButton( px + column.size_x - 12 - 7, py + 7, 12, 12, ui.scrollpane,
					":nrp_shared/img/confirm_btn_close.png", _, _, 0xFF646464, 0xFF000000, 0xFF808080 )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )

						if confirmation then confirmation:destroy( ) end
						confirmation = ibConfirm( {
							title = "УДАЛЕНИЕ",
							text = "Удалить эту запись в трудовой книжке?",
							fn = function( self )
								if localPlayer:GetAccessLevel( ) < ACCESS_LEVEL_SUPERVISOR then
									return
								end

								self:destroy( )

								if isElement( ui.loading ) then
									ui.loading:destroy( )
								end

								ui.loading = ibLoading( { parent = ui.main } )

								triggerServerEvent( "onAdminRemoveFactionHistoryRecord", resourceRoot, v.id, v.player_id )
							end,
							escape_close = true,
						} )
					end )
				end

				ibCreateImage( px, py-1, 1, size_y, _, ui.scrollpane, 0xFFb6b5b6 )
				px = px + column.size_x
				ibCreateImage( px, py-1, 1, size_y, _, ui.scrollpane, 0xFFb6b5b6 )
			end
			ibCreateImage( 35, py-1, 671, 1, _, ui.scrollpane, 0xFFb6b5b6 )
			py = py + size_y
		end
		
		ui.scrollpane:AdaptHeightToContents()
		ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )
	else
		if isElement( ui.main ) then
			destroyElement( ui.main )
		end

		showCursor( false )
	end
end

function ReceiveFactionHistory( state, data )
	if data then
		for k, v in pairs( data ) do
			v.total_lines = 1
			for i, column in pairs( COLUMNS_SEQUENCE ) do
				v[ column.key ] = column.func( v[ column.key ] )
				
				local value = v[ column.key ]
				local len = value and type( value ) == "string" and dxGetTextWidth( value, 1, ibFonts.bold_14 ) or 0
				local lines = math.ceil( len / ( column.size_x - 20 ) )
				if lines >= v.total_lines then	
					v.total_lines = lines
				end
			end
		end
		pData = data
	end

	ShowUI( state, source )
end
addEvent( "onShowFactionHistoryUI", true )
addEventHandler( "onShowFactionHistoryUI", root, ReceiveFactionHistory )