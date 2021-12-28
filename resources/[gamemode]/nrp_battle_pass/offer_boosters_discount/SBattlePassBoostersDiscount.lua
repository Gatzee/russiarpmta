BOOSTERS_DISCOUNT_DATA = {
	season = 9,
	duration = 24 * 60 * 60,
	boosters = {
		nil,
		{ days = 3, cost = 269, discount = 10 },
		{ days = 5, cost = 339, discount = 15 },
		{ days = 7, cost = 399, discount = 20 },
	}
}

function onPlayerCompleteLogin_handler_boostersDiscount( player )
	local player = isElement( player ) and player or source
	if not player:HasFinishedTutorial( ) then return end

	if BP_CURRENT_SEASON_ID ~= BOOSTERS_DISCOUNT_DATA.season then return end
	if BP_CURRENT_SEASON_STAGE_ID <= 1 then return end

	local stage_start_ts = BP_STAGES[ BP_CURRENT_SEASON_STAGE_ID ].start_ts
	if getRealTimestamp( ) - stage_start_ts > BOOSTERS_DISCOUNT_DATA.duration then return end
	if player:GetPermanentData( "bp_boosters_discount_used_ts" ) == stage_start_ts then return end

	BOOSTERS_DISCOUNT_DATA.start_ts = stage_start_ts
	player:setData( "bp_boosters_discount", BOOSTERS_DISCOUNT_DATA, false )

	triggerClientEvent( player, "BP:ShowBoostersDiscount", resourceRoot, BOOSTERS_DISCOUNT_DATA )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler_boostersDiscount )

addEvent( "onServerPlayerPurchaseBattlePassBooster" )
addEventHandler( "onServerPlayerPurchaseBattlePassBooster", root, function( )
	local player = source
	local offer_data = player:getData( "bp_boosters_discount" )
	if offer_data then
		player:setData( "bp_boosters_discount", nil, false )
		player:SetPermanentData( "bp_boosters_discount_used_ts", offer_data.start_ts )
	end
end )

addEventHandler( "onResourceStart", resourceRoot, function( )
	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler_boostersDiscount( player )
		end
	end, 1000, 1 )
end )