BOOSTER_OFFER_DATA = {
	start_ts = getTimestampFromString( "23.06.2021" ),
	finish_ts = getTimestampFromString( "24.06.2021" ),
	booster_id = 1,
	discount = 10,
	cost = 179,
}

-- addEventHandler( "onSpecialDataUpdate", root, function( key, value )
-- 	if key ~= "battle_pass_booster_offer" then return end

-- 	if not value or next( value ) == nil then 
-- 		BOOSTER_OFFER_DATA = { }
-- 	else
-- 		BOOSTER_OFFER_DATA = value[ 1 ]
-- 		BOOSTER_OFFER_DATA.start_ts = getTimestampFromString( BOOSTER_OFFER_DATA.start_ts )
-- 		BOOSTER_OFFER_DATA.finish_ts = getTimestampFromString( BOOSTER_OFFER_DATA.finish_ts )
-- 	end
-- end )
-- triggerEvent( "onSpecialDataRequest", resourceRoot, "battle_pass_booster_offer" )

function onPlayerCompleteLogin_handler_boosterOffer( player )
	local player = isElement( player ) and player or source

	local current_ts = getRealTimestamp( )
	if not BOOSTER_OFFER_DATA.start_ts then return end
	if BOOSTER_OFFER_DATA.start_ts > current_ts or current_ts > BOOSTER_OFFER_DATA.finish_ts then return end
	if not player:HasFinishedTutorial( ) then return end

	if player:IsBattlePassBoosterActive( ) then return end

	triggerClientEvent( player, "BP:ShowBoosterOffer", resourceRoot, BOOSTER_OFFER_DATA )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler_boosterOffer )

addEventHandler( "onResourceStart", resourceRoot, function( )
	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler_boosterOffer( player )
		end
	end, 1000, 1 )
end )