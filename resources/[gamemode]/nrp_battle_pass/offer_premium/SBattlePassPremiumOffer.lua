PREMIUM_OFFER_DATA = {
	-- start_ts = getTimestampFromString( "6.01.2021" ),
	-- finish_ts = getTimestampFromString( "7.01.2021" ),
	-- discount = 10,
	-- cost = 228,
}

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "battle_pass_premium_offer" then return end

	if not value or next( value ) == nil then 
		PREMIUM_OFFER_DATA = { }
	else
		PREMIUM_OFFER_DATA = value[ 1 ]
		PREMIUM_OFFER_DATA.start_ts = getTimestampFromString( PREMIUM_OFFER_DATA.start_ts )
		PREMIUM_OFFER_DATA.finish_ts = getTimestampFromString( PREMIUM_OFFER_DATA.finish_ts )
	end
end )
triggerEvent( "onSpecialDataRequest", resourceRoot, "battle_pass_premium_offer" )

function onPlayerCompleteLogin_handler_premiumOffer( player )
	local player = isElement( player ) and player or source

	local current_ts = getRealTimestamp( )
	if not PREMIUM_OFFER_DATA.start_ts then return end
	if PREMIUM_OFFER_DATA.start_ts > current_ts or current_ts > PREMIUM_OFFER_DATA.finish_ts then return end
	if not player:HasFinishedTutorial( ) then return end

	if player:IsBattlePassPremiumActive( ) then return end

	triggerClientEvent( player, "BP:ShowPremiumOffer", resourceRoot, PREMIUM_OFFER_DATA )

	-- SendElasticGameEvent( player:GetClientID( ), "case_notification_show" )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler_premiumOffer )

addEventHandler( "onResourceStart", resourceRoot, function( )
	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler_premiumOffer( player )
		end
	end, 1000, 1 )
end )

addEvent( "BP:onPlayerShowPremiumOffer", true )
addEventHandler( "BP:onPlayerShowPremiumOffer", resourceRoot, function( )
    local player = client

    SendElasticGameEvent( player:GetClientID( ), "bp_ticket_offer_show", {
        id = "bp_ticket_offer",
    } )
end )

function onBattlePassPremiumPurchase( player, cost, from_take_button )
    if from_take_button then
        SendElasticGameEvent( player:GetClientID( ), "bp_ticket_offer_purchase", {
            id        = "bp_ticket_offer" ,
            name      = "bp_ticket_offer" ,
            cost      = cost              ,
            quantity  = 1                 ,
            spend_sum = cost              ,
            currency  = "hard"            ,
        } )
    end
end