loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")
Extend("CVehicle")
Extend("ShUtils")
Extend( "ib" )

local UI_elements = {}
local screen_size_x, screen_size_y = guiGetScreenSize()

local SHOW_LEVEL_UP_TMR = nil

function ShowUILevelUp(new_level)
	if isElement(UI_elements.bg_img) then return end

	showCursor(true)
	local close_func = function( )
		Timer( DestroyUI, 250, 1 )

		if new_level == 4 or new_level == 6 then
			Timer(function() triggerEvent( "ShowPremiumOffer", localPlayer, true ) end, 1000, 1)
		end

		if new_level == 3 then
			Timer(function() triggerEvent( "RPRShowNotification", localPlayer ) end, 1000, 1)
		end

		triggerEvent( "onClientUILevelUpClose", localPlayer, new_level )
	end

	UI_elements.black_bg = ibCreateBackground( 0x00000000, close_func, true, true )
	UI_elements.bg_img = ibCreateImage( 0, 0, screen_size_x, screen_size_y, _, UI_elements.black_bg, 0xF2344554 )
	:ibData( "alpha", 0 )
	:ibAlphaTo( 255, 200 )

	UI_elements.info_texture			= dxCreateTexture("images/info.png")
	UI_elements.info_img = ibCreateImage( (screen_size_x - 302) / 2, (screen_size_y - 218) / 2 - 200, 302, 218, UI_elements.info_texture, UI_elements.bg_img )
	:ibData( "alpha", 0 )
	:ibAlphaTo( 255, 500 )
	:ibMoveTo( (screen_size_x - 302) / 2, (screen_size_y - 218) / 2, 200 )

	UI_elements.label_city = ibCreateLabel( 151, 80, 0, 0, new_level, UI_elements.info_img, 0xFFFFFFFF, _, _, 'center', 'center', ibFonts.bold_28 )
	UI_elements.button_okey_idle_tex = dxCreateTexture("images/button_okey_idle.png")
	UI_elements.button_okey_hover_tex = dxCreateTexture("images/button_okey_hover.png")
	UI_elements.button_okey_click_tex = dxCreateTexture("images/button_okey_click.png")

	UI_elements.button_okey = ibCreateButton(
		(screen_size_x - 174) / 2, (screen_size_y + 268) / 2, 174, 56,
		UI_elements.bg_img,
		UI_elements.button_okey_idle_tex, UI_elements.button_okey_hover_tex, UI_elements.button_okey_click_tex,
		0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
	
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "up" then return end

		UI_elements.bg_img:ibAlphaTo( 0, 200 )
		close_func( )
	end )

	playSound("sounds/level_up.wav")
end

addEvent( "PlayerLevelUp", true )
addEventHandler( "PlayerLevelUp", root, function( new_level )
	if isTimer( SHOW_LEVEL_UP_TMR ) then killTimer( SHOW_LEVEL_UP_TMR ) end

	SHOW_LEVEL_UP_TMR = setTimer( function()
		if localPlayer:getData( "quest_reward_window" ) then return end

		killTimer( SHOW_LEVEL_UP_TMR )
		ShowUILevelUp( new_level )
	end, 3500, 0 )
end )

function DestroyUI()
	if isElement( UI_elements.bg_img ) then destroyElement( UI_elements.bg_img ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
	end

	UI_elements = {}

	showCursor( false )
end