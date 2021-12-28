Extend("Globals")
Extend("SPlayer")

local SAVED_POSITIONS = { }

addEvent( "DS:onPlayerShowUI", true )
addEventHandler( "DS:onPlayerShowUI", root, function( show_state )
	SAVED_POSITIONS[ client ] = show_state and { client.position, client.interior, client.dimension } or nil
end )

addEventHandler( "onPlayerPreLogout", root, function( )
	local pos = SAVED_POSITIONS[ source ]
	if pos then
		source.position = pos[ 1 ]
		source.interior = pos[ 2 ]
		source.dimension = pos[ 3 ]
		SAVED_POSITIONS[ source ] = nil
	end
end )

addEventHandler("onResourceStart", resourceRoot, function()
	for k,v in pairs( getElementsByType("player") ) do
		OnPlayerJoin( v )
	end
end)

function OnPlayerJoin( pPlayer )
	local pPlayer = pPlayer or source
	local pAnimations = pPlayer:GetPermanentData("unlocked_animations") or {}
	pPlayer:SetPrivateData("unlocked_animations", pAnimations)
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerJoin, true, "high+1000000" )

function OnPlayerTryBuyDance( pPlayer, iDance )
	local pDanceData = DANCES_LIST[iDance]

	if pDanceData.cost > pPlayer:GetMoney() then
		pPlayer:EnoughMoneyOffer( "Dancing school purchase", pDanceData.cost, "OnPlayerTryBuyDance", getResourceRootElement(), pPlayer, iDance )
		return
	end

	if pPlayer:HasDance( iDance ) then
		pPlayer:ShowError("Ты уже изучил это движение!")
		return
	end

	pPlayer:TakeMoney( pDanceData.cost, "anim_purchase" )
	pPlayer:AddDance( iDance )
	triggerClientEvent( pPlayer, "DS:UpdateUI", resourceRoot, {
		dance = iDance,
	} )

	if pDanceData.cost == 0 then
		triggerEvent( "onPlayerSomeDo", pPlayer, "learn_free_dances" ) -- achievements
	end

	triggerEvent( "onPlayerDancePurchase", pPlayer, iDance, pDanceData.name, pDanceData.cost )
end
addEvent("OnPlayerTryBuyDance", true)
addEventHandler("OnPlayerTryBuyDance", resourceRoot, OnPlayerTryBuyDance)

function OnPlayerStartDancing( iDance )
	if not client:HasDance( iDance ) then
		client:ShowError("Ты ещё не изучил это движение")
		return
	end

	if client.vehicle then
		client:ShowError("Ты не можешь сделать это сидя в машине")
		return
	end

	if isElementInWater( client ) or not isPedOnGround( client ) or client.frozen then
		return
	end

	client.position = client.position
	local pPlayersAround = getElementsWithinRange( client.position, 180 )
	triggerClientEvent( pPlayersAround, "OnPlayerStartDancing", resourceRoot, client, iDance )
end
addEvent("OnPlayerStartDancing", true)
addEventHandler("OnPlayerStartDancing", root, OnPlayerStartDancing)

function OnPlayerStopDancing( pPlayer )
	local pPlayersAround = getElementsWithinRange( pPlayer.position, 180 )
	triggerClientEvent( pPlayersAround, "OnPlayerStopDancing", resourceRoot, pPlayer )
end
addEvent("OnPlayerStopDancing", true)
addEventHandler("OnPlayerStopDancing", resourceRoot, OnPlayerStopDancing)

if SERVER_NUMBER > 100 then
	addCommandHandler( "start_animation", function( player, cmd, animation_id )
		if not animation_id or not DANCES_LIST[ tonumber( animation_id ) or 0 ] then
			player:ShowError("Не указан или неверный ID анимации" )
			return
		end

		triggerClientEvent( player, "OnPlayerStartDancing", resourceRoot, player, tonumber( animation_id ) )
	end )
end