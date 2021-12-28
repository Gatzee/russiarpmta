loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ib" )
Extend( "CInterior" )

ibUseRealFonts( true )

local UIe = { }
local GOV_STATE_CACHE = { }

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	for gov_id, conf in pairs( CITYHALL_CONTROL_POSITIONS ) do
		conf.radius = 2
		conf.color = { 145, 145, 255, 40 }
		conf.marker_text = "Настройка\nгос.надбавок"
		conf.keypress = "lalt"
		conf.text = "ALT Взаимодействие"
		local marker = TeleportPoint( conf )
		marker:SetImage( "images/marker_icon.png" )
		marker.element:setData( "material", true, false )
		marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 145, 145, 255, 255, 1.45 } )

		marker.PostJoin = function( self, player )
			if localPlayer:GetFaction() ~= gov_id then return end
			if not localPlayer:IsFactionOwner( ) then return end

			triggerServerEvent( "ClientRequestShowUIGovControl", resourceRoot )
		end
	end
end )

function ShowUIGovControl( gov_state, updated )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
		if not updated then return end

	elseif updated then
		return
	end

	GOV_STATE_CACHE = gov_state

	UIe.black_bg = ibCreateBackground( _, HideUIGovControl, _, true )
	showCursor( true )

	UIe.bg				= ibCreateImage( 0, 0, 800, 600, "images/bg.png", UIe.black_bg )
							:center():ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

	UIe.btn_close		= ibCreateButton(	746, 24, 24, 24, UIe.bg,
											":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
											0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
							:ibData( "priority", 1 )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )
								HideUIGovControl()
							end, false )


	CreateCityTab( )
end
addEvent( "ShowUIGovControl", true )
addEventHandler( "ShowUIGovControl", resourceRoot, ShowUIGovControl )

function HideUIGovControl( )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )
end

function CreateCityTab( )
	if isElement( UIe.tab_bg ) then
		if isElement( UIe.last_tab_bg ) then
			destroyElement( UIe.last_tab_bg )
		end

		UIe.last_tab_bg = UIe.tab_bg
		UIe.last_tab_bg:ibAlphaTo( 0, 255 )

		Timer( function()
			if isElement( UIe.last_tab_bg ) then
				destroyElement( UIe.last_tab_bg )
			end
		end, 255, 1 )
	end

	local gov_state_chgs = { }

	UIe.tab_bg			= ibCreateImage( 0, 72, 800, 528, "images/city_bg.png", UIe.bg )
							:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

	ibCreateLabel( 30, -37, 0, 0, "Финансовое положение города", UIe.tab_bg ):ibBatchData( { font = ibFonts.bold_24, align_x = "left", align_y = "center" } )

	local chg_blocked = false

	local timeout_text = getHumanTimeString( GOV_STATE_CACHE.timeout, true )
	if timeout_text then
		chg_blocked = true
		ibCreateLabel( 677, 385, 0, 0, "Доступно через ".. timeout_text, UIe.tab_bg, 0xfffc5454 ):ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center" } )
	end

	local controls = { "businesses", "factions", "jobs", "rating" }

	local free_points = GOV_STATE_CACHE.points
	for i, control_id in pairs( controls ) do
		free_points = free_points - GOV_STATE_CACHE.data[ control_id ].points
	end

	for i, control_id in pairs( controls ) do
		local offset_x = 401 * ( ( i - 1 ) % 2 )
		local offset_y = 160 * math.floor( ( i - 1 ) / 2 )

		UIe[ "state_label_".. control_id ]	= ibCreateLabel( 276 + offset_x, 81 + offset_y, 0, 0, GOV_STATE_CACHE.data[ control_id ].points .."%", UIe.tab_bg)
												:ibBatchData( { font = ibFonts.bold_20, align_x = "center", align_y = "center" } )

		ibCreateButton(	199 + offset_x, 67 + offset_y, 26, 26, UIe.tab_bg, "images/btn_minus.png", "images/btn_minus.png", "images/btn_minus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if GOV_STATE_CACHE.data[ control_id ].points == 0 then return end

				if GOV_STATE_CACHE.data[ control_id ].data then
					local data_used_points = 0
					local count = 0
					for i, v in pairs( GOV_STATE_CACHE.data[ control_id ].data ) do
						data_used_points = data_used_points + ( type( v ) == "table" and v.points or v )
						count = count + 1
					end
	
					if ( GOV_STATE_CACHE.data[ control_id ].points * count - data_used_points ) < count then
						localPlayer:ShowError( "Все средства внутри структуру уже распределены. Освободите не меньше ".. count .." перков фракции" )
						return
					end
				end

				if not gov_state_chgs[ control_id ] then
					gov_state_chgs[ control_id ] = GOV_STATE_CACHE.data[ control_id ].points
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points + 1
				UIe.points_text:ibData( "text", free_points .."%" )

				GOV_STATE_CACHE.data[ control_id ].points = GOV_STATE_CACHE.data[ control_id ].points - 1
				UIe[ "state_label_".. control_id ]:ibData( "text", GOV_STATE_CACHE.data[ control_id ].points .."%" )

				if gov_state_chgs[ control_id ] == GOV_STATE_CACHE.data[ control_id ].points then
					gov_state_chgs[ control_id ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )

		ibCreateButton(	324 + offset_x, 67 + offset_y, 26, 26, UIe.tab_bg, "images/btn_plus.png", "images/btn_plus.png", "images/btn_plus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if free_points == 0 then
					localPlayer:ShowError( "Свободные средства закончились" )
					return
				end

				if GOV_STATE_CACHE.data[ control_id ].points >= 10 then
					localPlayer:ShowError( "Нельзя выставить больше 10%" )
					return
				end

				if not gov_state_chgs[ control_id ] then
					gov_state_chgs[ control_id ] = GOV_STATE_CACHE.data[ control_id ].points
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points - 1
				UIe.points_text:ibData( "text", free_points .."%" )

				GOV_STATE_CACHE.data[ control_id ].points = GOV_STATE_CACHE.data[ control_id ].points + 1
				UIe[ "state_label_".. control_id ]:ibData( "text", GOV_STATE_CACHE.data[ control_id ].points .."%" )

				if gov_state_chgs[ control_id ] == GOV_STATE_CACHE.data[ control_id ].points then
					gov_state_chgs[ control_id ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )

		ibCreateButton(	55 + offset_x, 84 + offset_y, 90, 20, UIe.tab_bg, "images/btn_chg_i.png", "images/btn_chg_h.png", "images/btn_chg_c.png" )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", not _G[ "CreateSubTab_".. control_id ] )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if next( gov_state_chgs ) then
					localPlayer:ShowError( "Изменения не сохранены" )
					return
				end

				_G[ "CreateSubTab_".. control_id ]( )
			end, false )
	end

	UIe.points_text		= ibCreateLabel( 345, 354, 0, 0, free_points .."%", UIe.tab_bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

	UIe.chgs_text		= ibCreateLabel( 677, 385, 0, 0, "Изменения не сохранены", UIe.tab_bg, 0xfffcf654 )
							:ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center", visible = false } )

	ibCreateButton(	584, 337, 186, 35, UIe.tab_bg, "images/btn_apply_i.png", "images/btn_apply_h.png", "images/btn_apply_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if not next( gov_state_chgs ) then return end

			UIe.saving = ibLoading( { parent = UIe.tab_bg, text = "Сохранение...", font = ibFonts.regular_12 } )

			local new_gov_state = { }
			for control_id, value in pairs( GOV_STATE_CACHE.data ) do
				new_gov_state[ control_id ] = value.points
			end

			triggerServerEvent( "PlayerUpdateGovStateData", resourceRoot, new_gov_state, gov_state_chgs )
		end, false )

	ibCreateButton(	584, 405, 186, 35, UIe.tab_bg, "images/btn_reset_i.png", "images/btn_reset_h.png", "images/btn_reset_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if not next( gov_state_chgs ) then return end

			for control_id, value in pairs( gov_state_chgs ) do
				free_points = free_points + ( GOV_STATE_CACHE.data[ control_id ].points - value )
				UIe.points_text:ibData( "text", free_points .."%" )

				GOV_STATE_CACHE.data[ control_id ].points = value
				UIe[ "state_label_".. control_id ]:ibData( "text", value .."%" )
			end

			gov_state_chgs = { }
			UIe.chgs_text:ibData( "visible", false )
		end, false )	
end


function CreateSubTab_factions( )
	if isElement( UIe.tab_bg ) then
		if isElement( UIe.last_tab_bg ) then
			destroyElement( UIe.last_tab_bg )
		end

		UIe.last_tab_bg = UIe.tab_bg
		UIe.last_tab_bg:ibAlphaTo( 0, 255 )

		Timer( function()
			if isElement( UIe.last_tab_bg ) then
				destroyElement( UIe.last_tab_bg )
			end
		end, 255, 1 )
	end

	local gov_state_chgs = { }

	UIe.tab_bg			= ibCreateArea( 0, 72, 800, 528, UIe.bg )
	ibCreateLabel( 30, 25, 0, 0, "Фракция", UIe.tab_bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "left", align_y = "center" } )
	ibCreateLabel( 695, 25, 0, 0, "Коэфф. надбавки", UIe.tab_bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "center", align_y = "center" } )

	ibCreateLabel( 155, -37, 0, 0, "Распределение бюджета по фракциям", UIe.tab_bg ):ibBatchData( { font = ibFonts.bold_24, align_x = "left", align_y = "center" } )
	ibCreateButton(	15, -54, 130, 40, UIe.tab_bg, "images/btn_back.png", "images/btn_back.png", "images/btn_back.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if next( gov_state_chgs ) then
				localPlayer:ShowError( "Изменения не сохранены" )
				return
			end

			CreateCityTab( )
		end, false )

	local city_data = GOV_STATE_CACHE.data.factions

	local chg_blocked = false

	local timeout_text = getHumanTimeString( city_data.timeout, true )
	if timeout_text then
		chg_blocked = true
		ibCreateLabel( 400, 500, 0, 0, "Доступно через ".. timeout_text, UIe.tab_bg, 0xfffc5454 )
			:ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center" } )
	end

	UIe.list_pane, scroll_v = ibCreateScrollpane( 0, 42, 800, 320, UIe.tab_bg, { scroll_px = -18, bg_color = 0x00FFFFFF } )
	scroll_v:ibData( "sensivity", 0.25 ):ibSetStyle( "slim_nobg" )

	local free_points = 0
	local convert_cost = 0
	for faction_id, faction_data in pairs( city_data.data ) do
		free_points = free_points - faction_data.points
		convert_cost = convert_cost + 1
	end
	free_points = free_points + city_data.points * convert_cost

	local i = 0
	for faction_id, faction_data in pairs( city_data.data ) do
		local bg = ibCreateImage( 0, 40 * i, 800, 40, _, UIe.list_pane, ( i % 2 == 1 and 0x40314050 or 0x00FFFFFF ) )
		i = i + 1

		ibCreateLabel( 30, 20, 0, 0, FACTIONS_NAMES[ faction_id ], bg ):ibBatchData( { font = ibFonts.regular_16, align_x = "left", align_y = "center" } )

		ibCreateImage( 670, 7, 50, 26, _, bg, 0x26000000 )
		UIe[ "state_label_".. faction_id ] = ibCreateLabel( 695, 21, 0, 0, faction_data.points, bg ):ibBatchData( { font = ibFonts.bold_14, align_x = "center", align_y = "center" } )

		ibCreateButton(	620, 7, 26, 26, bg, "images/btn_minus.png", "images/btn_minus.png", "images/btn_minus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if city_data.data[ faction_id ].points == 0 then return end

				if city_data.data[ faction_id ].data then
					local data_used_points = 0
					local count = 0
					for i, v in pairs( city_data.data[ faction_id ].data ) do
						data_used_points = data_used_points + ( type( v ) == "table" and v.points or v )
						count = count + 1
					end
	
					if ( city_data.data[ faction_id ].points * count - data_used_points ) < count then
						localPlayer:ShowError( "Все перки внутри фракции уже распределены. Освободите не меньше ".. count .." перков ранга" )
						return
					end
				end

				if not gov_state_chgs[ faction_id ] then
					gov_state_chgs[ faction_id ] = city_data.data[ faction_id ].points
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points + 1
				UIe.points_text:ibData( "text", free_points .." ед." )

				city_data.data[ faction_id ].points = city_data.data[ faction_id ].points - 1
				UIe[ "state_label_".. faction_id ]:ibData( "text", city_data.data[ faction_id ].points )

				if gov_state_chgs[ faction_id ] == city_data.data[ faction_id ].points then
					gov_state_chgs[ faction_id ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )

		ibCreateButton(	744, 7, 26, 26, bg, "images/btn_plus.png", "images/btn_plus.png", "images/btn_plus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if free_points == 0 then
					localPlayer:ShowError( "Свободные перки закончились" )
					return
				end
				if city_data.data[ faction_id ].points >= 10 then
					localPlayer:ShowError( "Нельзя выставить больше 10" )
					return
				end

				if not gov_state_chgs[ faction_id ] then
					gov_state_chgs[ faction_id ] = city_data.data[ faction_id ].points
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points - 1
				UIe.points_text:ibData( "text", free_points .." ед." )

				city_data.data[ faction_id ].points = city_data.data[ faction_id ].points + 1
				UIe[ "state_label_".. faction_id ]:ibData( "text", city_data.data[ faction_id ].points )

				if gov_state_chgs[ faction_id ] == city_data.data[ faction_id ].points then
					gov_state_chgs[ faction_id ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )

		ibCreateButton(	30 + 10 + dxGetTextWidth( FACTIONS_NAMES[ faction_id ], 1, ibFonts.regular_16 ), 10, 90, 20, bg, "images/btn_chg_i.png", "images/btn_chg_h.png", "images/btn_chg_c.png" )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", not FACTION_RIGHTS.ECONOMY[ localPlayer:GetFaction( ) ][ faction_id ] )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				CreateSubTab_FactionLevels( faction_id )
			end, false )
	end

	UIe.list_pane:AdaptHeightToContents( )
	scroll_v:UpdateScrollbarVisibility( UIe.list_pane )

	ibCreateLabel( 30, 390, 0, 0, "Свободные перки фракции:", UIe.tab_bg, 0x99FFFFFF ):ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" } )
	UIe.points_text		= ibCreateLabel( 300, 390, 0, 0, free_points .." ед.", UIe.tab_bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

	ibCreateLabel( 30, 420, 0, 0, "Выделенный из бюджета 1% конвертируется в ".. convert_cost .." ".. plural( convert_cost, "перк", "перка", "перков" ) .." фракции", UIe.tab_bg, 0x99FFFFFF ):ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" } )

	UIe.chgs_text		= ibCreateLabel( 400, 500, 0, 0, "Изменения не сохранены", UIe.tab_bg, 0xfffcf654 )
							:ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center", visible = false } )

	ibCreateButton(	204, 450, 186, 35, UIe.tab_bg, "images/btn_reset_i.png", "images/btn_reset_h.png", "images/btn_reset_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if not next( gov_state_chgs ) then return end

			for faction_id, value in pairs( gov_state_chgs ) do
				free_points = free_points + ( city_data.data[ faction_id ].points - value )
				UIe.points_text:ibData( "text", free_points .." ед." )

				city_data.data[ faction_id ].points = value
				UIe[ "state_label_".. faction_id ]:ibData( "text", value )
			end

			gov_state_chgs = { }
			UIe.chgs_text:ibData( "visible", false )
		end, false )

	ibCreateButton(	410, 450, 186, 35, UIe.tab_bg, "images/btn_apply_i.png", "images/btn_apply_h.png", "images/btn_apply_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if not next( gov_state_chgs ) then return end

			UIe.saving = ibLoading( { parent = UIe.tab_bg, text = "Сохранение...", font = ibFonts.regular_12 } )

			local new_gov_state = { }
			for faction_id, value in pairs( city_data.data ) do
				new_gov_state[ faction_id ] = value.points
			end

			triggerServerEvent( "PlayerUpdateGovStateData", resourceRoot, new_gov_state, gov_state_chgs, { "factions" } )
		end, false )
end

function CreateSubTab_FactionLevels( faction_id )
	if not FACTIONS_BY_CITYHALL[ faction_id ] or FACTIONS_BY_CITYHALL[ faction_id ] ~= localPlayer:GetFaction( ) then return end

	if isElement( UIe.tab_bg ) then
		if isElement( UIe.last_tab_bg ) then
			destroyElement( UIe.last_tab_bg )
		end

		UIe.last_tab_bg = UIe.tab_bg
		UIe.last_tab_bg:ibAlphaTo( 0, 255 )

		Timer( function()
			if isElement( UIe.last_tab_bg ) then
				destroyElement( UIe.last_tab_bg )
			end
		end, 255, 1 )
	end

	local gov_state_chgs = { }

	UIe.tab_bg			= ibCreateArea( 0, 72, 800, 528, UIe.bg )
	ibCreateLabel( 30, 25, 0, 0, "Должность", UIe.tab_bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "left", align_y = "center" } )
	ibCreateLabel( 695, 25, 0, 0, "Коэфф. надбавки", UIe.tab_bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "center", align_y = "center" } )

	ibCreateLabel( 155, -37, 0, 0, FACTIONS_NAMES[ faction_id ], UIe.tab_bg ):ibBatchData( { font = ibFonts.bold_24, align_x = "left", align_y = "center" } )
	ibCreateButton(	15, -54, 130, 40, UIe.tab_bg, "images/btn_back.png", "images/btn_back.png", "images/btn_back.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if next( gov_state_chgs ) then
				localPlayer:ShowError( "Изменения не сохранены" )
				return
			end

			CreateSubTab_factions( )
		end, false )

	local city_data = GOV_STATE_CACHE.data.factions.data[ faction_id ]

	local chg_blocked = false

	local timeout_text = getHumanTimeString( city_data.timeout, true )
	if timeout_text then
		chg_blocked = true
		ibCreateLabel( 400, 500, 0, 0, "Доступно через ".. timeout_text, UIe.tab_bg, 0xfffc5454 )
			:ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center" } )
	end

	UIe.list_pane, scroll_v = ibCreateScrollpane( 0, 42, 800, 320, UIe.tab_bg, { scroll_px = -18, bg_color = 0x00FFFFFF } )
	scroll_v:ibData( "sensivity", 0.25 ):ibSetStyle( "slim_nobg" )

	local free_points = 0
	local convert_cost = 0
	for level, points in pairs( city_data.data ) do
		free_points = free_points - points
		convert_cost = convert_cost + 1
	end
	free_points = free_points + city_data.points * convert_cost

	for i in pairs( city_data.data ) do
		local bg = ibCreateImage( 0, 40 * ( i - 1 ), 800, 40, _, UIe.list_pane, ( i % 2 == 0 and 0x40314050 or 0x00FFFFFF ) )

		ibCreateLabel( 30, 20, 0, 0, FACTIONS_LEVEL_NAMES[ faction_id ][ i ], bg ):ibBatchData( { font = ibFonts.regular_16, align_x = "left", align_y = "center" } )

		ibCreateImage( 670, 7, 50, 26, _, bg, 0x26000000 )
		UIe[ "state_label_".. i ] = ibCreateLabel( 695, 21, 0, 0, city_data.data[ i ], bg ):ibBatchData( { font = ibFonts.bold_14, align_x = "center", align_y = "center" } )

		ibCreateButton(	620, 7, 26, 26, bg, "images/btn_minus.png", "images/btn_minus.png", "images/btn_minus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if city_data.data[ i ] == 0 then return end

				if not gov_state_chgs[ i ] then
					gov_state_chgs[ i ] = city_data.data[ i ]
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points + 1
				UIe.points_text:ibData( "text", free_points .." ед." )

				city_data.data[ i ] = city_data.data[ i ] - 1
				UIe[ "state_label_".. i ]:ibData( "text", city_data.data[ i ] )

				if gov_state_chgs[ i ] == city_data.data[ i ] then
					gov_state_chgs[ i ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )

		ibCreateButton(	744, 7, 26, 26, bg, "images/btn_plus.png", "images/btn_plus.png", "images/btn_plus.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", chg_blocked )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if free_points == 0 then
					localPlayer:ShowError( "Свободные средства закончились" )
					return
				end
				if city_data.data[ i ] >= 10 then
					localPlayer:ShowError( "Нельзя выставить больше 10" )
					return
				end

				if not gov_state_chgs[ i ] then
					gov_state_chgs[ i ] = city_data.data[ i ]
					UIe.chgs_text:ibData( "visible", true )
				end

				free_points = free_points - 1
				UIe.points_text:ibData( "text", free_points .." ед." )

				city_data.data[ i ] = city_data.data[ i ] + 1
				UIe[ "state_label_".. i ]:ibData( "text", city_data.data[ i ] )

				if gov_state_chgs[ i ] == city_data.data[ i ] then
					gov_state_chgs[ i ] = nil
					UIe.chgs_text:ibData( "visible", false )
				end
			end, false )
	end

	UIe.list_pane:AdaptHeightToContents( )
	scroll_v:UpdateScrollbarVisibility( UIe.list_pane )

	ibCreateLabel( 30, 390, 0, 0, "Свободные перки ранга:", UIe.tab_bg, 0x99FFFFFF ):ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" } )
	UIe.points_text		= ibCreateLabel( 270, 390, 0, 0, free_points .." ед.", UIe.tab_bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

	ibCreateLabel( 30, 420, 0, 0, "Выделенный 1 перк фракции конвертируется в ".. convert_cost .." ".. plural( convert_cost, "перк", "перка", "перков" ) .." ранга", UIe.tab_bg, 0x99FFFFFF ):ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" } )

	UIe.chgs_text		= ibCreateLabel( 400, 500, 0, 0, "Изменения не сохранены", UIe.tab_bg, 0xfffcf654 )
							:ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "center", visible = false } )

	ibCreateButton(	204, 450, 186, 35, UIe.tab_bg, "images/btn_reset_i.png", "images/btn_reset_h.png", "images/btn_reset_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			for level, value in pairs( gov_state_chgs ) do
				free_points = free_points + ( city_data.data[ level ] - value )
				UIe.points_text:ibData( "text", free_points .."%" )

				city_data.data[ level ] = value
				UIe[ "state_label_".. level ]:ibData( "text", value .."%" )
			end

			gov_state_chgs = { }
			UIe.chgs_text:ibData( "visible", false )
		end, false )

	ibCreateButton(	410, 450, 186, 35, UIe.tab_bg, "images/btn_apply_i.png", "images/btn_apply_h.png", "images/btn_apply_c.png" )
		:ibData( "color_disabled", 0x80FFFFFF )
		:ibData( "disabled", chg_blocked )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if not next( gov_state_chgs ) then return end

			UIe.saving = ibLoading( { parent = UIe.tab_bg, text = "Сохранение...", font = ibFonts.regular_12 } )

			local new_gov_state = { }
			for level, value in pairs( city_data.data ) do
				new_gov_state[ level ] = value
			end

			triggerServerEvent( "PlayerUpdateGovStateData", resourceRoot, new_gov_state, gov_state_chgs, { "factions", faction_id } )
		end, false )
end