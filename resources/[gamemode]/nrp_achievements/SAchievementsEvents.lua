addEvent( "onPlayerSomeDo", false )
addEventHandler( "onPlayerSomeDo", root, function( doing_id )
    source:SomeDo( doing_id )
end )

addEvent( "onClientPlayerSomeDo", true )
addEventHandler( "onClientPlayerSomeDo", resourceRoot, function( doing_id )
    if not client then return end

    client:SomeDo( doing_id, nil, true )
end )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    local achieve_list = source:GetPermanentData( "achievements_list" ) or { }
    local counters = source:GetPermanentData( "achievements_counter" ) or { }

    source:SetPrivateData( "achievements_list", achieve_list )
    source:SetPrivateData( "achievements_counter", counters )
end )

addEvent( "onPlayerVehiclesLoad", false )
addEventHandler( "onPlayerVehiclesLoad", root, function ( )
    if not source:GetPermanentData( "first_check_achievements" ) then
        source:SomeDo( "ready_to_play", true )
        source:SetPermanentData( "first_check_achievements", true )
    end
end )

addEventHandler( "onPlayerWasted", root, function ( _, _, damage_type )
    if damage_type == 54 then
        source:SomeDo( "fall" )
    end
end )

function onPlayerVisitedMarket( market_id )
    local player = client or source

    if not tonumber( market_id ) then return end

    local visited_markets = player:GetPermanentData( "visited_markets" ) or { }
    if visited_markets[ market_id ] then return end

    visited_markets[ tonumber( market_id ) ] = true

    player:SetPermanentData( "visited_markets", visited_markets )
    player:SomeDo( "visit_market" )
end

addEvent( "onPlayerCarsellOpen" )
addEventHandler( "onPlayerCarsellOpen", root, onPlayerVisitedMarket )

addEvent( "onPlayerAirplaneMarketOpen", true )
addEventHandler( "onPlayerAirplaneMarketOpen", root, onPlayerVisitedMarket )

addEvent( "onPlayerBoatMarketOpen", true )
addEventHandler( "onPlayerBoatMarketOpen", root, onPlayerVisitedMarket )