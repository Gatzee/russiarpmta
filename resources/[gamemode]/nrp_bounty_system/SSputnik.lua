addEvent( "updateTargetPositionBySputnik", true )
addEventHandler( "updateTargetPositionBySputnik", root, function ( targetID )
    if client ~= source then return end

    local clanID = client:GetClanID( ) or 0
    local factionID = client:GetFaction( ) or 0
    local currentTime = getRealTimestamp( )
    local player = GetPlayer( targetID )

    local function syncSputnikState( user, state )
        for _, v in pairs( GetPlayersInGame( ) ) do
            if ( clanID > 0 and clanID == v:GetClanID( ) ) or ( factionID > 0 and factionID == v:GetFaction( ) ) then
                triggerClientEvent( v, "onPlayerUseSputnikChangeState", user, state )
            end
        end

        user:setData( "use_sputnik", state, false )
    end

    local function endOfSession( user )
        triggerClientEvent( user, "updateTargetPositionBySputnik", user )
        syncSputnikState( user, false )
    end

    if not player then endOfSession( client ) return end

    if clanID > 0 then
        local timeTo = GetClanData( clanID, "sputnik" )
        if currentTime > timeTo or player:IsNickNameHidden( ) then
            endOfSession( client )
            return
        end

    elseif not COPS_FACTIONS[ factionID ] then -- if player left faction
        endOfSession( client )
        return
    end

    local pos = getPlayerPositionForSputnik( player )

    triggerClientEvent( client, "updateTargetPositionBySputnik", client, targetID, pos.x, pos.y, pos.valid_to - currentTime )
    syncSputnikState( client, true )
end )