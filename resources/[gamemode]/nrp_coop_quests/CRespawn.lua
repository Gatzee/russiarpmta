function OnClientPlayerWasted( )
	if not GetCoopQuestData( "respawns_enabled" ) then return end

	ShowUI_Wasted( true )
end
addEvent( "OnClientPlayerWasted", true )
addEventHandler( "OnClientPlayerWasted", resourceRoot, OnClientPlayerWasted )

local ui = { }

function ShowUI_Wasted( state )
	if state then
		ShowUI_Wasted( false )

		ui.black_bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, _, 0xff101010 )
		:ibData( "alpha", 0 ):ibAlphaTo( 255*0.75, 5000, "InOutQuad" )

		local countdown = 10
		ui.countdown = ibCreateLabel( 0, 0, _SCREEN_X, _SCREEN_Y, "ВОЗРОЖДЕНИЕ ЧЕРЕЗ 10", _, _, _, _, "center", "center", ibFonts.oxaniumbold_30 )
		:ibTimer( function()
			if not isPedDead( localPlayer ) then
				ShowUI_Wasted( false )
				return
			end

			countdown = countdown - 1

			if countdown <= 1 then
				ui.countdown:ibAlphaTo( 0, 1500, "InOutQuad" )
				ui.black_bg:ibAlphaTo( 0, 2000, "InOutQuad" )
				ui.black_bg:ibTimer( function( ) ShowUI_Wasted( false ) end, 2000, 1)

				return
			end

			ui.countdown:ibData( "text", "ВОЗРОЖДЕНИЕ ЧЕРЕЗ "..countdown )
		end, 1000, 11)
	else
		DestroyTableElements( ui )
	end
end