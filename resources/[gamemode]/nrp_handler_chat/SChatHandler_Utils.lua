function get_local_players( player, str, range )
    local range = range or 20

    local x, y, z = getElementPosition( player )
    local dimension = getElementDimension( player )

    local players_in_range = { }

    for k, v in pairs( getElementsByType( "player" ) ) do
		local vx, vy, vz = getElementPosition( v )
		if getDistanceBetweenPoints3D( x, y, z, vx, vy, vz ) <= range and dimension == v.dimension then
            table.insert( players_in_range, v )
		end
	end

    return players_in_range
end

function get_admin_players( player )
    local admin_players = {}
    for i, v in pairs( getElementsByType("player") ) do
        if v:IsAdmin() then
            table.insert( admin_players, v )
        end
    end
    return admin_players
end

function get_faction_players( faction_type )
    local faction_players = {}
    for i, v in pairs( getElementsByType("player") ) do
        if v:GetFaction() == faction_type then
            table.insert( faction_players, v )
        end
    end
    return faction_players
end

function get_allfactions_players( )
    local faction_players = {}
    for i, v in pairs( getElementsByType( "player" ) ) do
        if v:IsInFaction() then
            table.insert( faction_players, v )
        end
    end
    return faction_players
end

function get_megaphone_players( player )
    local target_players = {}
    for k, v in pairs( getElementsByType( "player") ) do
        if v ~= player and v:IsInGame() and not v:IsInFaction() and not v:IsInClan() and not v:getData( "jailed" ) then
            table.insert( target_players, v )
        end
    end
    return target_players
end

function get_clan_players( clan_id )
    local clan_players = {}
    for i, v in pairs( getElementsByType( "player" ) ) do
        local clan_id_target = v:GetClanID()
        if clan_id == clan_id_target then
            table.insert( clan_players, v )
        end
    end
    return clan_players
end

function get_job_players( player )
    local target_players = {}
    local target_job_lobby = player:GetCoopJobLobbyId()
    for k, v in pairs( GetPlayersInGame() ) do
        if target_job_lobby == v:GetCoopJobLobbyId() then
            table.insert( target_players, v )
        end
    end
    return target_players
end