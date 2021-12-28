loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

local srx, sry = guiGetScreenSize( )
local UIe = nil

function ShowSpecialThksRewardUI_handler( bg_type )
	if isElement( UIe ) then return end

	showCursor( true )

	UIe = ibCreateImage( math.floor( ( srx - 800 ) / 2 ), math.floor( ( sry - 580 ) / 2 ), 800, 580, "images/".. bg_type .."_bg.png" )
	ibCreateButton( 335, 508, 130, 42,  UIe, "images/btn_take_i.png", "images/btn_take_h.png", "images/btn_take_c.png" )
	:ibOnClick( function( button, state ) 
		if button ~= "left" or state ~= "down" then return end

		ibClick( )
		UIe:ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		source:ibData( "disabled", true )
		UIe = nil

		showCursor( false )
	end )
end
addEvent( "ShowSpecialThksRewardUI", true )
addEventHandler( "ShowSpecialThksRewardUI", resourceRoot, ShowSpecialThksRewardUI_handler )