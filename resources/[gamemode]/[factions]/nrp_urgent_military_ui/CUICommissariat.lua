loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")
Extend("CInterior")
Extend("ShUtils")
Extend("ib")

local UI_elements = {}
scX, scY = guiGetScreenSize()

addEventHandler( "onClientResourceStart", resourceRoot, function()
	local config = {
		marker_text = "Срочная служба",
		radius = 2,
		x = -1249.084, y = -419.276, z = 1292.131,
		interior = 1,
		dimension = 1,
	}

	info_marker = TeleportPoint( config )
	info_marker.element:setData( "material", true, false )
	info_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 1.55 } )
	info_marker.text = false
	info_marker.keypress = false
	info_marker.marker:setColor( 128, 245, 128, 100 )
	info_marker.PostJoin = function( self, player )
		if not localPlayer:IsInGame() then return end

		local current_quest = localPlayer:getData( "current_quest" )
		if current_quest then
			localPlayer:ShowError( "Сначала закончи выполнять квест" )
			return
		end

		if localPlayer:IsOnUrgentMilitary() then
			UICommissariatVacation()
		else
			if localPlayer:HasMilitaryTicket( ) then
				localPlayer:ShowInfo( "У тебя уже есть военный билет" )
				return
			end

			UICommissariatStart()
		end
	end
	info_marker.PostLeave = function( self, player )
		DestroyUICommissariatVacation()
	end
end )

function UICommissariatVacation()
	if localPlayer:IsInUrgentMilitaryBase() then return end
	if isElement( UI_elements.bg_img ) then return end

	showCursor( true )

	UI_elements.black_bg = ibCreateImage( 0, 0, scX, scY, _, _, 0x80495F76 )

	UI_elements.bg_img = ibCreateImage( (scX - 500) / 2, (scY - 340) / 2, 500, 340, "images/commissariat/vacation_bg.png", UI_elements.black_bg )

	UI_elements.button_close = ibCreateButton( 447, 25, 24, 24, UI_elements.bg_img, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		DestroyUICommissariatVacation()
	end )

	local urgent_military_vacation = localPlayer:getData( "urgent_military_vacation" ) or 0
	local server_timestamp = getRealTimestamp()
	
	local time_data = ConvertSecondsToTime( urgent_military_vacation - server_timestamp )

	UI_elements.time_text = ibCreateLabel( 250, 215, 0, 0, ( time_data.hour > 0 and ( time_data.hour .." ч. " ) or "" ) .. time_data.minute .." мин.", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_20 )

	UI_elements.button_back = ibCreateButton( 147, 255, 206, 56, UI_elements.bg_img,
					"images/commissariat/button_back_idle.png", "images/commissariat/button_back_hover.png", "images/commissariat/button_back_click.png", 
						0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )

	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "up" then return end
		DestroyUICommissariatVacation()
		triggerServerEvent( "PlayerWantBackInUrgentMilitaryBase", resourceRoot )
	end )
end

function UICommissariatStart()
	if isElement( UI_elements.bg_img ) then return end

	showCursor( true )

	UI_elements.black_bg = ibCreateImage( 0, 0, scX, scY, _, _, 0x80495F76 )

	UI_elements.bg_img = ibCreateImage( (scX - 500) / 2, (scY - 340) / 2, 500, 340, "images/commissariat/start_bg.png", UI_elements.black_bg )

	UI_elements.button_start = ibCreateButton( 80, 260, 160, 56, UI_elements.bg_img,
		"images/commissariat/button_start_idle.png", "images/commissariat/button_start_hover.png", "images/commissariat/button_start_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )

	:ibOnClick( function( button,  state)
		if button ~= "left" or state ~= "up" then return end
		DestroyUICommissariatVacation()
		triggerServerEvent( "PlayerWantStartUrgentMilitary", resourceRoot )
	end )


	UI_elements.button_cancel = ibCreateButton( 260, 260, 160, 56, UI_elements.bg_img,
		"images/commissariat/button_cancel_idle.png", "images/commissariat/button_cancel_hover.png", "images/commissariat/button_cancel_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )

	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		DestroyUICommissariatVacation()
	end )
end

function DestroyUICommissariatVacation()
	if isElement( UI_elements.bg_img ) then destroyElement( UI_elements.bg_img ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
	end

	UI_elements = { }

	showCursor( false )
end