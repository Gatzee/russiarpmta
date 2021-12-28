Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )

local COLUMNS_SEQUENCE = 
{
	{ 
		key = "date",
		name = "Дата приема",
		sx = 160,
		func = function( value )
			return os.date( "%d/%m/%Y %H:%M", tonumber( value ) or 0 )
		end
	},
	{ 
		key = "disease_id",
		name = "Наименование болезни",
		sx = 400,
		func = function( value )
			return DISEASES_INFO[ value ] and DISEASES_INFO[ value ].name or value
		end,
	},
	{ 
		key = "note",
		name = "Рекомендации",
		sx = 400,
		wordbreak = true,
		func = function( value )
			return value or ""
		end
	},
}

local UI = { }

function ShowMedbookUI( state, data, new_disease_id, last_drugs_use_date, note, is_update )
	if not localPlayer:SetStateShowDocuments( state, source ) and not is_update then return end

	if is_update then
		ShowMedbookUI( false )
	end

	if state then
		if last_drugs_use_date and os.time( ) - last_drugs_use_date < 12 * 60 * 60 then
			table.insert( data, {
				date = last_drugs_use_date, 
				disease_id = "Употребление наркотиков", 
				note = "",
			} )
		end

		if new_disease_id then
			table.insert( data, {
				date = os.time( ), 
				disease_id = new_disease_id, 
				note = true,
			} )
		end

		showCursor( true )

		UI.bg = ibCreateImage( 0, 0, 0, 0, "img/medbook_bg.png" )
			:ibSetRealSize( ):center( )
			:ibData( "alpha", localPlayer:GetAccessLevel( ) >= ACCESS_LEVEL_SUPERVISOR and 255 or 0 ):ibAlphaTo( 255, 500 )
		
		ibCreateLabel( UI.bg:width( ) - 5, UI.bg:height( ) - 3, 0, 0, source:GetNickName( ), UI.bg, COLOR_BLACK, 1, 1, "right", "bottom", ibFonts.regular_14 )
		
		ibCreateButton( UI.bg:ibData( "sx" ) - 30 - 24, 30, 24, 24, UI.bg, 
						":nrp_shared/img/confirm_btn_close.png", _, _, 0xFF646464, 0xFF000000, 0xFF808080 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ShowMedbookUI( false )
			end)
		
		ibCreateButton( UI.bg:ibData( "sx" ) - 72 - 129, 30, 129, 24, UI.bg, 
						"img/button_info.png", _, _, 0xFFFFFFFF, 0xFF909090, 0xFF646464 )
			:ibOnClick( function( btn, state )
				if btn == "left" and state == "up" then
					local info_bg = ibCreateImage( 0, 0, UI.bg:width( ), UI.bg:height( ), nil, UI.bg, 0xF01f2934 )
						:ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
			
					ibCreateImage( 0, 0, 0, 0, "img/medbook_info.png", info_bg )
						:ibSetRealSize( ):center( 0, -60 )
					
					ibCreateButton( 0, 0, 0, 0, info_bg, "img/button_hide.png", _, _, 0xCCFFFFFF, 0xFFFFFFFF, 0xFF909090 )
						:ibSetRealSize( ):center( 0, 100 )
						:ibOnClick( function( btn, state )
							if btn == "left" and state == "up" then
								info_bg:destroy( )
							end 
						end)
				end 
			end )
		
		local px, py = 31, 126
		local scrollpane, scrollbar = ibCreateScrollpane( px, py, 
			UI.bg:ibData( "sx" ) - px * 2, UI.bg:ibData( "sy" ) - py - 31, 
			UI.bg, { scroll_px = 10 }
		)
		scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData( { 
			handle_color = 0x55000000, handle_color_hover = 0x88000000, handle_color_click = 0xaa000000,
		} )

		py = 0
		for k, v in pairs( data ) do
			local row_sy = 44
			px = 0
			for i, column in pairs( COLUMNS_SEQUENCE ) do
				local raw_value = v[ column.key ]

				if new_disease_id and column.key == "note" and raw_value == true then
						triggerServerEvent( "onMedicAddNoteToMedbook", localPlayer, source, new_disease_id, note )
						ShowMedbookUI( false )
						data[ #data ].note = note
						ShowMedbookUI( true, data )
				else
					if column.key == "note" and localPlayer:GetAccessLevel( ) < ACCESS_LEVEL_ADMIN then
						raw_value = utf8.gsub( raw_value, "\nUserID:(.+)", "" )
					end
					local text, lines_count = column.func( raw_value ) or "-"
					if column.wordbreak then
						text, lines_count = GetWrappedText( text, column.sx - 40, ibFonts.regular_14 )
						row_sy = row_sy + ( lines_count - 1 ) * dxGetFontHeight ( 1, ibFonts.regular_14 )
					end
					ibCreateLabel( px + 20, py + 11, column.sx - 40, row_sy - 25, text, scrollpane, 0xBB000000 )
						:ibBatchData{ font = ibFonts.regular_14, clip = column.wordbreak, wordbreak = column.wordbreak }

					-- удалить запись в медкнижке
					if column.key == "note" and localPlayer:GetAccessLevel( ) >= ACCESS_LEVEL_SUPERVISOR then
						ibCreateButton( scrollpane:ibData( "sx" ) - 7 - 16, py + 7, 16, 16, scrollpane,
						":nrp_shared/img/confirm_btn_close.png", _, _, 0xFF646464, 0xFF000000, 0xFF808080 )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								if confirmation then confirmation:destroy( ) end
								if not isElement( source ) then return localPlayer:ShowError( "Владелец мед.книжки вышел из игры." ) end

								confirmation = ibConfirm({
										title = "УДАЛЕНИЕ",
										text = "Удалить эту запись в мед.книжке?",
										fn = function( self )
											self:destroy( )
											local recorded_at = v.date
											if UI.loading then UI.loading:destroy( ); UI.loading = nil end
											UI.loading = ibLoading( { parent = UI.bg } )
											triggerServerEvent( "onAdminRemoveMedbookRecord", resourceRoot, source, recorded_at )
										end,
										escape_close = true,
									})
							end )
					end
				end

				px = px + column.sx + 1
			end
			py = py + row_sy
			ibCreateImage( 0, py - 1, scrollpane:ibData( "sx" ), 1, _, scrollpane, 0x26000000 )
		end

		if not isElement( scrollpane ) then return end

		scrollpane:AdaptHeightToContents()
		scrollbar:ibData( "position", 1 ):UpdateScrollbarVisibility( scrollpane )
	else
		if isElement( UI.bg ) then
			destroyElement( UI.bg )
		end
		showCursor( false )
	end
end
addEvent( "onShowMedbookUI", true )
addEventHandler( "onShowMedbookUI", root, ShowMedbookUI )

function GetWrappedText( text, max_sx, font )
	text = string.gsub( text, "\n", " ` " )

	local strs = { }
	local line_sx = 0
	local lines_count = 1
	for _word in string.gmatch( text, "%S+" ) do
		local word = _word == "`" and "" or ( _word .. " " )
		local word_sx = word == "" and 0 or dxGetTextWidth( word, 1, font )
		if word_sx > max_sx then
			lines_count = lines_count + math.floor( dxGetTextWidth( _word, 1, font ) / max_sx )
		end
		line_sx = line_sx + word_sx
		if word == "" or ( line_sx > max_sx and #strs > 0 ) then
			lines_count = lines_count + 1
			strs[ #strs + 1 ] = "\n"
			strs[ #strs + 1 ] = word
			line_sx = word_sx
		else
			strs[ #strs + 1 ] = word
		end
	end
	
	return table.concat( strs ), lines_count
end