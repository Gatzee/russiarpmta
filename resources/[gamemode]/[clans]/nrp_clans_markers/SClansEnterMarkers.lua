loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SClans" )

addEvent( "onPlayerWantEnterClanHouse", true )
addEventHandler( "onPlayerWantEnterClanHouse", root, function( base_id )
    local player = client or source

    local clan_id = player:GetClanID( )
    if not clan_id then
        player:ShowError( "Вы не состоите в клане" )
        return
    end

    local cartel_id = player:GetClanCartelID( )
    if cartel_id then
        if base_id ~= CARTEL_BASEMENTS[ cartel_id ] then
            player:ShowError( "Бункер вашего клана находится \nна базе вашего Картеля")
            return
        end
    else
        local clan_base_id = GetClanData( clan_id, "base_id" ) or 1
        if clan_base_id ~= base_id then
            player:ShowError( "Бункер вашего клана находится \nв " .. CLAN_BASEMENT_MARKER_CONFIGS[ clan_base_id ].name )
            return
        end
    end

    -- player:SetPermanentData( "enter_position", { getElementPosition( player ) } )
    -- triggerClientEvent( player, "onClientPlayerEnterClanBunker", player )

    player:Teleport( Vector3( -4.349, 88.010, 1267.282 ), 50 + GetClanData( clan_id, "id" ) % 10000, 1, 1000 )
end )

addEvent( "onPlayerWantExitClanHouse", true )
addEventHandler( "onPlayerWantExitClanHouse", root, function( )
    local player = client or source
    local clan_id = player:GetClanID( )
    local clan_base_id = GetClanData( clan_id, "base_id" ) or 1
    local cartel_id = player:GetClanCartelID( )
    if cartel_id then
        clan_base_id = CARTEL_BASEMENTS[ cartel_id ]
    end

    player:Teleport( Vector3( CLAN_BASEMENT_MARKER_CONFIGS[ clan_base_id ] ), 0, 0, 50 )
end )

addEvent( "onPlayerLeaveClan" )
addEventHandler( "onPlayerLeaveClan", root, function( clan_id )
    local player = client or source
    local pos = player.position
    local bunker_pos = CLAN_BUNKER_INTERIOR_BOUNDING_BOX
    if  pos.x > bunker_pos.x0 and pos.x < bunker_pos.x1 and
        pos.y > bunker_pos.y0 and pos.y < bunker_pos.y1 and
        pos.z > bunker_pos.z0 and pos.z < bunker_pos.z1 
    then
        local clan_base_id = GetClanData( clan_id, "base_id" ) or 1
        player:Teleport( Vector3( CLAN_BASEMENT_MARKER_CONFIGS[ clan_base_id ] ), 0, 0, 50 )
    end
end )

addEvent( "onPlayerWantEnterCartelHouse", true )
addEventHandler( "onPlayerWantEnterCartelHouse", root, function( cartel_id )
    local player = client or source

    if player:GetClanCartelID( ) ~= cartel_id then
        player:ShowError( "Вы не состоите в этом картеле!" )
        return
    end

    player:SetPermanentData( "enter_position", { getElementPosition( player ) } )
    player:setData( "in_cartel_house", cartel_id, false )
    player:Teleport( Vector3( CARTEL_HOUSES_MARKER_CONFIGS[ cartel_id ].exit_position ), 1337, 1, 1000 )
end )

addEvent( "onPlayerWantExitCartelHouse", true )
addEventHandler( "onPlayerWantExitCartelHouse", root, function( )
    local player = client or source
    local enter_position = player:GetPermanentData( "enter_position" )

    player:setData( "in_cartel_house", false, false )
    player:Teleport( Vector3( enter_position or { x = 1988.662, y = -52.586, z = 60.65 } ), 0, 0, 50 )
end )

-- На случай, если игрок заспавнится внутри дома (при перезаходе)
addEvent( "onPlayerSpawnedInCartelHouse", true )
addEventHandler( "onPlayerSpawnedInCartelHouse", root, function( cartel_id )
    local player = client or source
    player:setData( "in_cartel_house", cartel_id, false )
end )