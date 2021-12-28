local click_timeout = 0
local UI_elements = {}
local scX, scY = guiGetScreenSize()

function UIList( id, max_slots, apartments_owners, wedded_at )
	if isElement( UI_elements.bg_img ) then return end

	showCursor( true )
	ibInterfaceSound()

	UI_elements.black_bg = ibCreateBackground(0x80495F76, DestroyUIList, true, true)
	UI_elements.bg_img = ibCreateImage( (scX - 500) / 2, (scY - 500) / 2, 500, 532, "images/list/bg.png", UI_elements.black_bg )

	UI_elements.button_pay = ibCreateButton( 476, 0, 24, 24, UI_elements.bg_img,  "images/button_close.png", "images/button_close.png", "images/button_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "down" then return end
		DestroyUIList()
	end )

	UI_elements.scroll_bg_texture	= dxCreateTexture("images/scroll_bg.png")
	UI_elements.free_bg_texture		= dxCreateTexture("images/list/free_bg.png")
	UI_elements.owned_bg_texture	= dxCreateTexture("images/list/owned_bg.png")
	UI_elements.my_bg_texture		= dxCreateTexture("images/list/my_bg.png")
	UI_elements.wedded_bg_texture	= dxCreateTexture("images/list/wedded_bg.png")

	UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 40, 138, 438, 360, UI_elements.bg_img, { scroll_px = -20 } )

	local user_id = localPlayer:GetUserID()
	for i = 1, max_slots do
		local owned_info = apartments_owners[ i ]
		local is_owned = owned_info and owned_info.user_id ~= 0
		local owned_str, color
		if ( wedded_at and owned_info ) and ( wedded_at == owned_info.user_id ) then
			owned_str = "wedded"
			color = 0xFF895757
		else
			owned_str = is_owned and ( owned_info.user_id == user_id and "my" or "owned" ) or "free"
			color = is_owned and not ( owned_info.user_id == user_id ) and 0xFF895757 or 0xFFFFFFFF
		end

		UI_elements[ "list_"..i ] = ibCreateButton( 80 * ((i - 1) % 5), 80 * (math.floor((i - 1) / 5)), 74, 74, UI_elements.scrollpane, 
				UI_elements[owned_str .."_bg_texture"], UI_elements[owned_str .."_bg_texture"], UI_elements[owned_str .."_bg_texture"], 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			if click_timeout > getTickCount() then return end
			
			click_timeout = getTickCount() + 700
			
			triggerServerEvent("PlayerWantShowApartmentsInfo", resourceRoot, id, i)
			DestroyUIList()
		end )
		ibCreateLabel( 0, 0, 74, 74, i, UI_elements[ "list_"..i ], color, 1, 1, "center", "center", ibFonts.bold_18 )
		:ibData( "disabled", true )		
	end

	UI_elements.scrollpane:AdaptHeightToContents()
	UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
end
addEvent( "ShowUIList", true )
addEventHandler( "ShowUIList", resourceRoot, UIList )

addEvent( "HideUIList", true )
addEventHandler( "HideUIList", resourceRoot, function()
	DestroyUIList()
end)

function DestroyUIList()
	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end
	UI_elements = { }

	showCursor( false )
end