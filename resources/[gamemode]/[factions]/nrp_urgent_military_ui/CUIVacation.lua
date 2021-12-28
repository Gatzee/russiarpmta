local UI_elements = {}

addEventHandler( "onClientResourceStart", resourceRoot, function()
	local config = {
		radius = 2,
		x = -2379.481, y = -181.59 + 860, z = 21.07;
		marker_text = "Штаб";
		interior = 0;
		dimension = URGENT_MILITARY_DIMENSION;
	}

	info_marker = TeleportPoint( config )
	info_marker.keypress = "lalt"
	info_marker.text = "ALT Взаимодействие"
	info_marker.marker:setColor( 128, 128, 245, 100 )
	info_marker.element:setData( "material", true, false )
	info_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 128, 245, 255, 1.6 } )
	info_marker.PostJoin = function( self, player )
		local current_quest = localPlayer:getData( "current_quest" )
		if current_quest then
			localPlayer:ShowError( "Сначала закончи выполняемую задачу" )
			return
		end

		local last_enter_urgent_military_base = localPlayer:getData( "last_enter_urgent_military_base" )
		if last_enter_urgent_military_base then
			local server_timestamp = getRealTimestamp()

			if ( last_enter_urgent_military_base + URGENT_MILITARY_VACATION_TIMEOUT ) > server_timestamp then
				local time_data = ConvertSecondsToTime( last_enter_urgent_military_base + URGENT_MILITARY_VACATION_TIMEOUT - server_timestamp )
				localPlayer:ShowError( "Увольнительную можно получить только через ".. ( time_data.minute > 0 and ( time_data.minute .." мин. " ) or "" ) .. time_data.second .." сек." )
				return
			end
		end

		UIVacation()
	end
	info_marker.PostLeave = function( self, player )
		DestroyUIVacation()
	end
end )

function UIVacation()
	if not localPlayer:IsInGame() then return end
	if not localPlayer:IsOnUrgentMilitary() or not localPlayer:IsInUrgentMilitaryBase() then return end
	if isElement( UI_elements.bg_img ) then return end

	showCursor( true )
	UI_elements.black_bg = ibCreateImage( 0, 0, scX, scY, _, _, 0x80495F76 )
	
	UI_elements.bg_img = ibCreateImage( (scX - 500) / 2, (scY - 340) / 2, 500, 340, "images/vacation/bg.png", UI_elements.black_bg )

	UI_elements.button_close = ibCreateButton( 447, 25, 24, 24, UI_elements.bg_img, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "up" then return end
		DestroyUIVacation()
	end )

	UI_elements.button_get = ibCreateButton( 147, 255, 206, 56, UI_elements.bg_img,"images/vacation/button_get_idle.png", "images/vacation/button_get_hover.png", "images/vacation/button_get_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "up" then return end
		DestroyUIVacation()
		triggerServerEvent( "PlayerWantGetUrgentMilitaryVacation", resourceRoot )
	end )
end
addEvent( "ShowUIVacation", true )
addEventHandler( "ShowUIVacation", resourceRoot, UIVacation )

function DestroyUIVacation()
	if isElement( UI_elements.bg_img ) then destroyElement( UI_elements.bg_img ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
	end

	UI_elements = { }

	showCursor( false )
end