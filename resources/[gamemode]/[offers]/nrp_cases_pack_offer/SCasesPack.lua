loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

CASES_PACKS = {
    [ 1 ] = {
        analytics_name = "monte_carlo",
        cases = { 
            [ "monte_carlo" ] = 2,
            [ "sea" ] = 1,
            [ "major" ] = 1,
            [ "mechanic" ] = 1,
            [ "crazy" ] = 1,
        },
        cost = 3095,
    },

    [ 2 ] = {
        analytics_name = "lamba",
        cases = { 
            [ "lamba" ] = 2,
            [ "monte_carlo" ] = 1,
            [ "german" ] = 1,
            [ "male" ] = 1,
            [ "powerful" ] = 1,
        },
        cost = 2395,
    },

    [ 3 ] = {
        analytics_name = "forsage",
        cases = { 
            [ "forsage" ] = 2,
            [ "lamba" ] = 1,
            [ "japan" ] = 1,
            [ "fashionable" ] = 1,
            [ "4etkii" ] = 1,
        },
        cost = 1895,
    },

    [ 4 ] = {
        analytics_name = "brigada",
        cases = { 
            [ "brigada" ] = 2,
            [ "patriot" ] = 1,
            [ "pontovy" ] = 1,
            [ "russian" ] = 1,
        },
        cost = 1325,
    },
}
for id, pack in pairs( CASES_PACKS ) do
    pack.analytics_id = "casepack_" .. id
end

OFFER_DATA = { }

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "cases_pack_offer" then return end

	if not value or next( value ) == nil then 
		OFFER_DATA = { }
	else
		OFFER_DATA = value[ 1 ]
		OFFER_DATA.cost = CASES_PACKS[ OFFER_DATA.pack_id ].cost
		OFFER_DATA.start_ts = getTimestampFromString( OFFER_DATA.start_ts )
		OFFER_DATA.finish_ts = getTimestampFromString( OFFER_DATA.finish_ts )
	end
end )
triggerEvent( "onSpecialDataRequest", resourceRoot, "cases_pack_offer" )

function InitOffer( player )
    if not player:HasFinishedTutorial( ) then return end

    -- Оффер активен
	local current_ts = getRealTimestamp( )
	if not OFFER_DATA.start_ts then return end
    if OFFER_DATA.start_ts > current_ts or current_ts > OFFER_DATA.finish_ts then return end

    -- Игрок не воспользовался оффером
    if OFFER_DATA.start_ts == player:GetPermanentData( "cases_pack_offer_used" ) then return end
    
    -- Первый показ оффера игроку
    local cases_pack_offer_init = player:GetPermanentData( "cases_pack_offer_init" ) or 0
    if cases_pack_offer_init ~= OFFER_DATA.start_ts then
        player:SetPermanentData( "cases_pack_offer_init", OFFER_DATA.start_ts )

        SendElasticGameEvent( player:GetClientID( ), "newyear_case_pack_offer_first", {
            id = CASES_PACKS[ OFFER_DATA.pack_id ].analytics_id,
        } )
    end
    
    triggerClientEvent( player, "ShowCasesPackOffer", player, OFFER_DATA )
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end, true, "low" )

addEvent( "onPlayerWantBuyCasesPack", true )
addEventHandler( "onPlayerWantBuyCasesPack", resourceRoot, function ( pack_id )
    local player = client
    local pack = CASES_PACKS[ pack_id ]

    if not player:TakeDonate( pack.cost, "newyear_case_pack_offer", pack.analytics_id ) then
        triggerEvent( "onPlayerRequestDonateMenu", player, "donate", "newyear_case_pack_offer" )
        return
    end

    for case_id, count in pairs( pack.cases ) do
        player:GiveCase( case_id, count )
    end
    client:ShowSuccess( "Ты успешно приобрёл кейсы!" )
    triggerEvent( "onPlayerRequestDonateMenu", player, "cases", "newyear_case_pack_offer" )
    
    player:SetPermanentData( "cases_pack_offer_used", OFFER_DATA.start_ts )

    SendElasticGameEvent( player:GetClientID( ), "newyear_case_pack_offer_purchase", {
        id = pack.analytics_id,
        name = pack.analytics_name,
        cost = pack.cost,
        quantity = 1,
        spend_sum = pack.cost,
        currency = "hard",
    } )
end )







if SERVER_NUMBER > 100 then

    addCommandHandler( "init_cases_pack_offer", function( player )
        InitOffer( player )
    end )

end