Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ib" )

ibUseRealFonts( true )

function PreJoin( self, player )
	if player:GetClanCartelID( ) ~= self.cartel_id then
		return false, "Этот гараж доступен только членам " .. ( self.cartel_id == 1 and "Зап. Картеля" or "Вост. Картеля" )
	end
	return true
end

function PostJoin( self, player )
    ShowCartelVehicleSelectorUI_handler( true, self.cartel_id )
end

function PostLeave( self, player )
    ShowCartelVehicleSelectorUI_handler( false )
end

for i, v in pairs( CARTELS_VEHICLE_MARKERS ) do
	local conf = v
	conf.radius = 2
	conf.marker_text = "Гараж картеля"
	conf.keypress = "lalt"
	conf.text = "ALT Взаимодействие"
	conf.PreJoin = PreJoin
	conf.PostJoin = PostJoin
	conf.PostLeave = PostLeave
    
    local r, g, b, a = 0, 255, 255, 50
	if conf.color then
		r, g, b, a = unpack( conf.color )
	end
    
    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255, 1.55 } )
    tpoint.element:setData( "material", true, false )   

	
	tpoint.marker:setColor( r, g, b, a )

	CARTELS_VEHICLE_MARKERS[ i ] = tpoint
end

function ShowCartelVehicleSelectorUI_handler( state, cartel_id )
    if state then
        ShowCartelVehicleSelectorUI_handler( false )
        showCursor( true )
        ibInterfaceSound( )

        UI = { }

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowCartelVehicleSelectorUI_handler, true, true )
		UI.bg = ibCreateImage( 0, 0, 800, 600, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 97 ) )
			:center( )
    
        UI.head_bg    = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 72, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                        ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
        UI.head_label = ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), "Гараж картеля", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
        
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 55, 24, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
    
                ShowCartelVehicleSelectorUI_handler( false )
            end )
        
        UI.loading = ibLoading( { parent = UI.bg } )
        
        triggerServerEvent( "onPlayerRequestCartelVehicles", localPlayer, cartel_id )
        CURRENT_CARTEL_ID = cartel_id
    else
        DestroyTableElements( UI )
        showCursor( false )
    end
end

function CreateVehiclesList( vehicles_in_use )
    if not isElement( UI.bg ) then return end

    vehicles_in_use = vehicles_in_use or { }

    UI.loading:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )

    UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, UI.head_bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg, { scroll_px = -20 } )
    UI.scrollbar:ibSetStyle( "slim_nobg" )
    
    for i, info in pairs( CARTEL_VEHICLES_LIST ) do
        local is_locked = localPlayer:GetClanRank( ) < info.need_rank or localPlayer:GetClanRole( ) < info.need_role
        local is_used = vehicles_in_use[ info.num ] 

        local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UI.scrollpane:ibData( "sx" ), 91, UI.scrollpane )
        if i > 1 then
            ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
        end

        ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )

        local txt_area = ibCreateArea( 100, 0, 100, 91, item_area )
        local name = VEHICLE_CONFIG[ info.model ] and VEHICLE_CONFIG[ info.model ].model or getVehicleNameFromModel( info.model ) or "Неизв."
        local name_label = ibCreateLabel( 0, 0, 0, 0, name, txt_area, ( is_used or is_locked ) and 0x35ffffff or 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
        local text = "Доступно с " .. info.need_rank .. " ранга и звания " .. CLAN_ROLES_NAMES[ info.need_role ]
        local text_label = ibCreateLabel( 0, name_label:ibGetAfterY( 14 ), 0, 0, text, txt_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.regular_14 )
        txt_area:ibData( "sy", text_label:ibGetAfterY( -7 ) ):center_y( )
        
        if is_used then
            ibCreateLabel( item_area:ibData( "sx" ) - 30, 0, 0, 0, "Используется", item_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "right", "center", ibFonts.bold_14 ):center_y( )
        elseif not is_locked then
            ibCreateButton( item_area:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_area, 
                            "images/button_get_idle.png", "images/button_get_hover.png", "images/button_get_hover.png", 
                            _, _, 0xFFCCCCCC )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                        
                    if click_timeout and click_timeout > getTickCount( ) then return end
                    click_timeout = getTickCount( ) + 700                        
                    ibClick( )

                    triggerServerEvent( "onCartelVehicleSpawnRequest", resourceRoot, i, CURRENT_CARTEL_ID )
                    ShowCartelVehicleSelectorUI_handler( false )
                end )
        else
            ibCreateImage( item_area:ibData( "sx" ) - 30 - 20, 30, 20, 24, "images/icon_locked.png", item_area, ibApplyAlpha( COLOR_WHITE, 50 ) ):center_y( )
        end

        item_area
            :ibData( "alpha", 0 )
            :ibTimer( function( self )
                self:ibAlphaTo( 255, 250 )
            end, 50 * ( i - 1 ), 1 )
    end

    UI.scrollpane:AdaptHeightToContents( )
    UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
end
addEvent( "onClientUpdateCartelVehicles", true )
addEventHandler( "onClientUpdateCartelVehicles", root, CreateVehiclesList )