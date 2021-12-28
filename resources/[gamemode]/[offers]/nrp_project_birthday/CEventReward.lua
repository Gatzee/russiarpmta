

function ShowUI_Rewards( state, data )
	if state then
		showCursor(true)

		UI_elements.rewards_bg = ibCreateImage( 0, 0, scX, scY, "files/img/rewards_bg.png" ):ibData("alpha", 0)
		:ibAlphaTo(255, 500)
        
        UI_elements.rewards = ibCreateImage( (scX - 460) / 2, (scY - 237) / 2, 460, 237, "files/img/rewards_" .. data.type_operation .. ".png", UI_elements.rewards_bg )
		ibCreateButton( scX/2-70, scY-scY/4, 140, 54, UI_elements.rewards_bg, "files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			triggerServerEvent( "OnPlayerTookReward", resourceRoot )
			ShowUI_Rewards( false )
			ibClick()
		end)

		local sfx = playSound( ":nrp_shop/sfx/reward_small.mp3" )
		setSoundVolume( sfx, 0.75 )
	else
		showCursor( false )
		for k, v in pairs( UI_elements ) do
			if isElement( v ) then
				destroyElement( v )
			end
		end
	end
end
addEvent("ShowUI_Rewards", true)
addEventHandler("ShowUI_Rewards", resourceRoot, ShowUI_Rewards)