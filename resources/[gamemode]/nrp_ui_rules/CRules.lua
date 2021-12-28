loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )

local scx, scy = guiGetScreenSize()
local sizeX, sizeY = 850, 500
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2
local ui = { }
local iCurrentSection = 1
local playerFactionID = nil

local function PrepareText( faction_id )
	-- Правила РП-сервера
	local nrp_invite_login = getResourceFromName( "nrp_invite_login" )
	if nrp_invite_login and getResourceState( nrp_invite_login ) == "running" then
		RULES = exports.nrp_invite_login:GetRoleplayRules( )

		local items = { }
		local fake_title = "0. END"
		for text, next_title in utf8.gmatch( "\n" .. RULES .. "\n" ..fake_title .. "\n", "(.-)\n([0-9]%. [%w%p ]+)\n" ) do
			if #items > 0 then
				for subtext, next_title_number, next_title in utf8.gmatch( "\n" .. text .. "\n0.0 END\n", "(.-)\n([0-9]%.[0-9]+%.?[0-9]?) ([%w%p ]+)\n" ) do
					items[ #items ][ 2 ] = items[ #items ][ 2 ] .. subtext
					if next_title_number ~= "0.0" then
						table.insert( items, { next_title_number, next_title, 0 } )
					end
				end
			end
			if next_title ~= fake_title then
				table.insert( items, { next_title, "" } )
			end
		end

		RULES_LIST[ 4 ].pContent = items
	end

	RULES_LIST[ 5 ].pContent = table.copy( FACTIONS_RULES[ faction_id ] or { { "-", " Нет доступных правил..." } } )

	local delimiter = utf8.char( 6158 )
	for i, section in pairs( RULES_LIST ) do
		for k, v in pairs( section.pContent ) do
			local text_sx, text_sy, text = dxGetTextSize( v[1] .. delimiter .. ( v[2] or "" ), sizeX - 425, 1, ibFonts.bold_12, true )
			v[2] = text:gsub( delimiter, v[1]:match( "\n%s*$" ) and "#c5c5c5" or " #c5c5c5" )
			v[3] = text_sy
		end
	end

	playerFactionID = faction_id
end

function SwitchUI(  )
	if not isElement(ui.main) then
		ibAutoclose( )
		ibWindowSound()

		showCursor(true)

        ui.black_bg	= ibCreateBackground( _, SwitchUI, true, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )

        ui.btn_close			= ibCreateButton(	posX + sizeX - 24, posY - 28, 24, 24, ui.black_bg,
													"files/img/close.png", "files/img/close.png", "files/img/close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            SwitchUI( )
        end )

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png", ui.black_bg )

		local py = 80

		ui.selector = ibCreateImage( 0, py+iCurrentSection*70-70, 378, 70, _, ui.main, 0xFF6c809f ):ibData( "disabled", true )

		ui.rt, ui.sc = ibCreateScrollpane( 370, 0, sizeX-370, sizeY, ui.main, 
            {
                scroll_px = -22,
                bg_sx = 0,
                handle_sy = 40,
                handle_sx = 16,
                handle_texture = ":nrp_shared/img/scroll_bg_small.png",
                handle_upper_limit = -40 - 20,
                handle_lower_limit = 20,
            }
        )

		local faction_id = localPlayer:GetFaction( )
		if faction_id ~= playerFactionID then
			PrepareText( faction_id )
		end

		local function RefreshScrollpane()
			DestroyTableElements( ui.labels )

			local py = 0
			ui.labels = { }
			for k, v in pairs( RULES_LIST[ iCurrentSection ].pContent ) do
				ui.labels[ k ] = ibCreateLabel( 30, py + 26, sizeX - 425, v[ 3 ], v[2], ui.rt ):ibBatchData( { font = ibFonts.bold_12, colored = true } )

				py = py + v[ 3 ] + 20
			end

			ui.sc:ibData( "position", 0 )
			ui.rt:ibData( "sy", py + 35 )
			ui.sc:ibData( "sensivity", 100 / py )
		end

		RefreshScrollpane()

		for i, section in pairs(RULES_LIST) do
			ui["section"..i] = ibCreateButton( 0, py, 380, 70, ui.main, nil, nil, nil, 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF)

			ui["icon"..i] = ibCreateImage( 40, 0, 0, 0, "files/img/"..section.sIcon..".png", ui["section"..i] ):ibData( "disabled", true )
				:ibSetRealSize( )
				:center_y( )
			ui["label"..i] = ibCreateLabel( 80, 0, 150, 70, section.sName, ui["section"..i], 0xFFFFFFFF, _, _, _, "center", ibFonts.bold_12 ):ibData( "disabled", true )

			if i ~= iCurrentSection then
				ui["icon"..i]:ibData( "alpha", 100 )
				ui["label"..i]:ibData( "alpha", 100 )
			end

			ui["section"..i]:ibOnClick( function(button, state)
				if button ~= "left" or state ~= "down" then return end
				iCurrentSection = i

				local px, py = ui["section"..i]:ibData( "px" ), ui["section"..i]:ibData( "py" )

				ui.selector:ibMoveTo( px, py, 200, "OutQuad" )

				for i=1, #RULES_LIST do
					if i == iCurrentSection then
						ui["icon"..i]:ibData( "alpha", 255 )
						ui["label"..i]:ibData( "alpha", 255 )
					else
						ui["icon"..i]:ibData( "alpha", 100 )
						ui["label"..i]:ibData( "alpha", 100 )
					end
				end

				RefreshScrollpane()
			end)

			py = py + 70
		end
	else
		if isElement(ui and ui.black_bg) then
			destroyElement( ui.black_bg )
		end
		DestroyTableElements( text )

		showCursor(false)
	end
end
addEvent("ShowRulesUI", true)
addEventHandler("ShowRulesUI", root, SwitchUI)

ibAttachAutoclose( function( ) if isElement(ui.main) then SwitchUI( ) end end )

bindKey("f10", "down", SwitchUI)