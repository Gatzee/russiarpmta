loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

OFFER_DATA = { }

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "cases_premium_discount" then return end

	if not value or next( value ) == nil then 
		OFFER_DATA = { }
	else
		OFFER_DATA = value[ 1 ]
		OFFER_DATA.start_ts = getTimestampFromString( OFFER_DATA.startTime )
		OFFER_DATA.finish_ts = getTimestampFromString( OFFER_DATA.endTime )
	end
end )
triggerEvent( "onSpecialDataRequest", resourceRoot, "cases_premium_discount" )

 addEvent( "onPlayerGetCasesPremiumDiscount", true )
 addEventHandler( "onPlayerGetCasesPremiumDiscount", resourceRoot, function ( )
    local player = client
    local cases_premium_discount_init = player:GetPermanentData( "cases_premium_discount_init" ) or 0
    if cases_premium_discount_init ~= OFFER_DATA.start_ts then
        player:SetPermanentData( "cases_premium_discount_init", OFFER_DATA.start_ts )

        -- Первый показ оффера игроку
        SendElasticGameEvent( player:GetClientID( ), "premium_discount_case_first" )
    end
 end )







if SERVER_NUMBER > 100 then

    addCommandHandler( "clear_cases_premium_discount", function( player )
        player:SetPermanentData( "cases_premium_discount_init", false )
    end )

end