Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ib" )

ibUseRealFonts( true )

function PreJoin( self, player )
	local faction = player:GetFaction()
	if faction ~= self.faction then
		return false, ( "Ты должен быть во фракции '%s' чтобы получать здесь транспорт" ):format( FACTIONS_NAMES[ self.faction ] )
	end
	if not player:IsOnFactionDuty() then
		return false, "Ты должен быть на смене чтоб пользоваться фракционным транспортом"
	end
	if player:getData( "is_handcuffed" ) then
		return false, "Ты в наручниках"
	end
	return true
end

function PostJoin( self, player )
	local faction = player:GetFaction()
	local faction_level = player:GetFactionLevel()
	local list = { }
	local list_reverse = { }
	for i, v in pairs( FACTION_VEHICLES_LIST ) do
		if v.iFaction == faction and v.city == self.city then
			if not list_reverse[ v.iModel ] then
				local conf = {
					model = v.iModel,
					level = v.iMinLevel,
					faction = v.iFaction,
					city = v.city,
				}
				table.insert( list, conf )
				list_reverse[ v.iModel ] = true
			end
		end
	end
	if #list <= 0 then
		player:ShowError( "Для тебя нет подходящего служебного транспорта" )
		return
	end
    ShowFactionVehicleSelectorUI_handler( true, { faction = faction, faction_level = faction_level, list = list } )
end

function PostLeave( self, player )
    ShowFactionVehicleSelectorUI_handler( false )
end

for i, v in pairs( FACTIONS_VEHICLE_MARKERS ) do
	local conf = v
	conf.radius = 3
	conf.keypress = "lalt"
	conf.text = "ALT Взаимодействие"
	conf.marker_text = "Получить\nтранспорт"
	conf.PreJoin = PreJoin
	conf.PostJoin = PostJoin
	conf.PostLeave = PostLeave
	local tpoint = TeleportPoint( conf )

	local r, g, b, a = 0, 255, 255, 50
	if conf.color then
		r, g, b, a = unpack( conf.color )
	end
	tpoint.marker:setColor( r, g, b, a )
	
	tpoint.element:setData( "material", true, false )
	tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255, 2.35 } )


	FACTIONS_VEHICLE_MARKERS[ i ] = tpoint
end

function ShowFactionVehicleSelectorUI_handler( state, data )
    if state then
        ShowFactionVehicleSelectorUI_handler( false )
        showCursor( true )
        ibInterfaceSound()

        UI = { }

        table.sort( data.list, function( a, b ) return a.level < b.level end )

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowFactionVehicleSelectorUI_handler, _, true )
        UI.bg = ibCreateImage( 0, 0, 800, 600, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 97 ) ):center()

        UI.head_bg    = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 72, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                        ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
        UI.head_label = ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), "Выдача служебного транспорта", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
        
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 55, 24, 25, 25, UI.head_bg, "images/btn_close.png", "images/btn_close.png", "images/btn_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
    
                ShowFactionVehicleSelectorUI_handler( false )
            end)
    
        UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, UI.head_bg:ibGetAfterY(), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg, { scroll_px = -20 } )
        UI.scrollbar:ibSetStyle( "slim_nobg" )
    	
        for i = 1, #data.list do
            local info = data.list[ i ]
            local is_locked = info.level > data.faction_level

			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UI.scrollpane:ibData( "sx" ), 91, UI.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )

            local txt_area = ibCreateArea( 100, 0, 100, 91, item_area )
            local name = VEHICLE_CONFIG[ info.model ] and VEHICLE_CONFIG[ info.model ].model or getVehicleNameFromModel( info.model ) or "Неизв."
            local name_label = ibCreateLabel( 0, 0, 0, 0, name, txt_area, is_locked and 0x35ffffff or 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
            local text = "Доступно с ранга ''" .. FACTIONS_LEVEL_NAMES[ data.faction ][ info.level ] .. "'"
            local text_label = ibCreateLabel( 0, name_label:ibGetAfterY( 14 ), 0, 0, text, txt_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.regular_14 )
            txt_area:ibData( "sy", text_label:ibGetAfterY( -7 ) ):center_y( )
            if not is_locked then
                ibCreateButton( item_area:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_area, 
                                "images/button_get_idle.png", "images/button_get_hover.png", "images/button_get_hover.png", 
                                _, _, 0xFFCCCCCC ):center_y( )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end                        
                        if click_timeout and click_timeout > getTickCount() then return end
                        click_timeout = getTickCount() + 700                        
                        ibClick( )

                        triggerServerEvent( "onFactionVehicleSpawnRequest", resourceRoot, info )
                        ShowFactionVehicleSelectorUI_handler( false )
                    end )
            else
                ibCreateImage( item_area:ibData( "sx" ) - 30 - 20, 30, 20, 24, "images/icon_locked.png", item_area, ibApplyAlpha( COLOR_WHITE, 50 ) ):center_y( )
            end

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
        end

        UI.scrollpane:AdaptHeightToContents()
        UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
    else
		if isElement( UI and UI.black_bg ) then
			destroyElement( UI.black_bg )
		end
        showCursor( false )
    end
end
addEvent( "ShowFactionVehicleSelectorUI", true )
addEventHandler( "ShowFactionVehicleSelectorUI", root, ShowFactionVehicleSelectorUI_handler )