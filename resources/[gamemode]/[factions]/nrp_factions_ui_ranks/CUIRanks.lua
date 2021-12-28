local sizeX, sizeY = 600, 450

local ui = {}

function InitRanks( )
	if not _RANKS_INIT then
		loadstring( exports.interfacer:extend( "Interfacer" ) )( )
		Extend( "Globals" )
		Extend( "ShUtils" )
		Extend( "ib" )
		_RANKS_INIT = true
	end
end

function ShowUI( state, faction, exp )
	if state then
		InitRanks( )		
		ShowUI( false )
		showCursor( true )

		ui.black_bg = ibCreateBackground( 0xBF1D252E, ShowUI, nil, true )
		ui.main = ibCreateImage( 0, 0, sizeX, sizeY, "files/img/bg.png", ui.black_bg ):center( )
		ui.close = ibCreateButton( sizeX-50, 25, 25, 25, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end

				ShowUI( false )
			end )

		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 70, sizeX+10, sizeY-70, ui.main, { scroll_px = -30 } )
		ui.scrollbar:ibSetStyle( "slim_nobg" )

		for k, name in ipairs( FACTIONS_LEVEL_NAMES[ faction ] ) do
			local rank_bg = ibCreateButton( 302 * ( (k - 1) % 2 ), 142 * math.floor( (k - 1) / 2 ), 298, 140,
											ui.scrollpane, nil, nil, nil, 0x33000000, 0x55000000, 0x11FFFFFF )
			
			local rank_img_path = ":nrp_factions_ui_info/images/ranks/".. FACTIONS_LEVEL_ICONS[ faction ] .."/".. k ..".png"
			ibCreateImage( 32, 32, 62, 80, rank_img_path, rank_bg )
				:ibData( "disabled", true )

			ibCreateLabel( 110, 20, 190, 40, name, rank_bg, 0xFFf3d88f )
				:ibBatchData{ font = utf8.len( name ) <= 12 and ibFonts.bold_14 or ibFonts.bold_12, disabled = true }

			if FACTION_EXPERIENCE[ k - 1 ] and FACTION_EXPERIENCE[ k - 1 ] > 0 then
				ibCreateLabel( 110, 60, 190, 40, "Необходимо опыта:", rank_bg, 0xFF8c8c8c )
					:ibBatchData{ font = ibFonts.regular_12, disabled = true }

				ibCreateLabel( 110, 85, 190, 40, format_price( FACTION_EXPERIENCE[ k - 1 ] ) .." оч.", rank_bg )
					:ibBatchData{ font = ibFonts.regular_12, disabled = true }
			end
		end

		ui.scrollpane:AdaptHeightToContents()
		ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )	
	else
		DestroyTableElements( ui )
		ui = {}
		showCursor( false )
	end
end
addEvent( "ShowUIFactionRanksList" )
addEventHandler( "ShowUIFactionRanksList", root, ShowUI )