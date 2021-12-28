loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

START_DATE = getTimestampFromString( "15 июля 2020 00:00" )
END_DATE = getTimestampFromString( "17 июля 2020 23:59" )

PREMIUM_DAYS = 3

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source

	local current_time = getRealTimestamp( )
	if START_DATE > current_time or current_time > END_DATE then return end

	if player:GetPermanentData( "premium_giveaway_ts" ) == END_DATE then return end
	player:SetPermanentData( "premium_giveaway_ts", END_DATE )

	player:GivePremiumExpirationTime( PREMIUM_DAYS )

	triggerClientEvent( player, "onClientPremiumGiveaway", resourceRoot, PREMIUM_DAYS )

	SendElasticGameEvent( player:GetClientID( ), "gift_prem_take" )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler, true, "low-9999999" )

function onResourceStart_handler( )
	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler( player )
		end
	end, 1000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )