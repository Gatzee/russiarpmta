local TEMP_REWARDS_CACHE = { }

function OnPlayerRequestTakeAwards( pPlayer, iDay, iSelection, is_premium )
	local pPlayer = pPlayer or client
	local iDay = iDay or GetAwardDay( pPlayer )
	local index = is_premium and 3 or 2
	local inverse_index = is_premium and 2 or 3

	if PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] == 1 and not PLAYER_AWARDS[ pPlayer ][ iDay][ inverse_index ] ~= -1 then
		TEMP_REWARDS_CACHE[ pPlayer ] = GetPlayerRewardsByDay( iDay, iSelection, is_premium )
		CheckRewards( pPlayer )

		pPlayer:CompleteDailyQuest( "np_daily_reward" )

		triggerEvent( "onPlayerTakeDailyAwards", pPlayer, iDay, iSelection, is_premium )
	elseif PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] == 0 then
		pPlayer:ShowError( "Награда не открыта" )
	elseif PLAYER_AWARDS[ pPlayer ][ iDay][ index ] == -1 or PLAYER_AWARDS[ pPlayer ][ iDay][ inverse_index ] == -1 then
		pPlayer:ShowError( "Награда уже получена" )
	end
end
addEvent( "DA:OnPlayerRequestTakeAwards", true )
addEventHandler( "DA:OnPlayerRequestTakeAwards", resourceRoot, OnPlayerRequestTakeAwards )

function GiveRewards( pPlayer )
	if not isElement( pPlayer ) then return end

	local awards = TEMP_REWARDS_CACHE[ pPlayer ]
	if not awards then return end

	local iDay = awards.day or 1
	local index = awards.is_premium and 3 or 2

	if PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] ~= 1 then
		return false
	end

	for k, v in pairs(awards.list) do
		POSSIBLE_ITEMS[v.class]:func_receive( pPlayer, v.params )
	end

	pPlayer:InfoWindow("Ежедневная награда успешно получена!")
	triggerClientEvent( pPlayer, "DA:OnAwardGiven", resourceRoot )

	PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] = - 1
	PLAYER_AWARDS[ pPlayer ][ iDay ][ 4 ] = awards.selection

	pPlayer:SetPermanentData( "dawards", PLAYER_AWARDS[ pPlayer ] )

	SendToLogserver( "Игрок " .. pPlayer:GetNickName( ) .. " забрал награду", { day = iDay, dawards_data = PLAYER_AWARDS[ pPlayer ], premium = awards.is_premium, selection = awards.selection, current_dawward_day = CURRENT_DAWARD_DATE } )

	TEMP_REWARDS_CACHE[ pPlayer ] = nil
	TRACKED_PLAYERS[ pPlayer ] = nil
end

function CheckRewards( pPlayer )
	for k, v in pairs( TEMP_REWARDS_CACHE[ pPlayer ].list ) do
		if POSSIBLE_ITEMS[ v.class ].requested_params then
			local has_params = true
			for key, value in pairs( POSSIBLE_ITEMS[ v.class ].requested_params ) do
				if v.params[value] == nil then
					has_params = false
					break
				end
			end

			if not has_params then
				v.awaiting_for_params = true
				POSSIBLE_ITEMS[ v.class ]:func_request_params( pPlayer, v )
				removeEventHandler( "DA:OnItemParamsReceived", pPlayer, OnItemParamsReceived )
				addEventHandler( "DA:OnItemParamsReceived", pPlayer, OnItemParamsReceived )
				return false
			end
		end
	end

	GiveRewards( pPlayer )
end

function OnItemParamsReceived( params )
	local pPlayer = client

	if not isElement( pPlayer ) then return end
	if not TEMP_REWARDS_CACHE[ pPlayer ] then return end

	for k, v in pairs( TEMP_REWARDS_CACHE[ pPlayer ].list ) do
		if v.awaiting_for_params then
			for key, value in pairs( params ) do
				v.params[ key ] = value
			end

			v.awaiting_for_params = false
		end
	end

	removeEventHandler( "DA:OnItemParamsReceived", pPlayer, OnItemParamsReceived )
	CheckRewards( pPlayer )
end
addEvent( "DA:OnItemParamsReceived", true )

function GetPlayerRewardsByDay( iDay, iSelection, is_premium )
	local seasonNum = getCurrentSeason( )
	local pData = {
		day = iDay,
		selection = iSelection or 1,
		is_premium = is_premium,
	}

	if is_premium then
		pData.list = table.copy( REWARDS_BY_DAYS[ seasonNum ][ iDay ].premium )
	else
		pData.list = table.copy( REWARDS_BY_DAYS[ seasonNum ][ iDay ].regular[ iSelection ] )
	end

	return pData
end