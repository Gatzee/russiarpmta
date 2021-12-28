Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SPlayerCommon" )

PARTY_POS_START = Vector3( 2212.667, 1371.925, 22.889 )
SAVE_LIST_FREQ = 600 -- 10 minutes
MIN_LEVEL_FOR_PARTY = 5
PARTY_LIST = { }

function loadParty( party )
    -- methods
    party.FindPlayer = function ( self, player_id )
        for idx, member in pairs( self.members ) do
            if member.id == player_id then
                return idx
            end
        end
    end

    party.AddPlayer = function ( self, player_id, role )
        local idx = self:FindPlayer( player_id )
        if idx then table.remove( self.members, idx ) end

        local player = GetPlayer( player_id )
        if player then
            table.insert( self.members, {
                id = player:GetID( ),
                client_id = player:GetClientID( ),
                nickname = player:GetNickName( ),
                party_role = role,
            } )
        else
            DB:queryAsync( function ( query )
                if not query then return end

                local result = dbPoll( query, -1 ) or { }
                local data = result[ 1 ]

                if data and data.nickname and data.client_id then
                    table.insert( self.members, {
                        id = player_id,
                        client_id = data.client_id,
                        nickname = data.nickname,
                        party_role = role,
                    } )
                end
            end, { }, "SELECT nickname, client_id FROM nrp_players WHERE id = ? LIMIT 1", player_id )
        end
    end

    party.RemovePlayer = function ( self, player_id )
        local idx = self:FindPlayer( player_id )
        if not idx then return end

        table.remove( self.members, idx )
    end

    -- update members
    updatePartyMembers( party )

    -- save
    party.draw_result = party.draw_result and ( fromJSON( party.draw_result ) or { } ) or { }
    party.top_list = party.top_list and ( fromJSON( party.top_list ) or { } ) or { }
    party.invitations = { }
    party.watchers = { }
    party.players_on_party = { }
    party.top_10 = { }
    party.counter = party.counter or 0
    party.total_online_players = 0

    -- fix indexs of tables
    party.draw_result = FixTableKeys( party.draw_result )
    party.top_list = FixTableKeys( party.top_list )

    PARTY_LIST[ party.id ] = party

    return party
end

function getParty( party_id )
    return PARTY_LIST[ party_id ]
end

function createParty( player_owner )
    local name = "Тусовка"
    local client_id = player_owner:GetClientID( )
    -- local name = player_owner:GetNickName( )
    -- name = utf8.match( name, "(%w+)(.+)" )

    DB:exec( "INSERT INTO " .. DB_TABLE_NAME .. " ( name, last_play, youtuber_id ) VALUES ( ?, ?, ? )", name, 0, client_id )
    DB:queryAsync( function ( query )
        if not query then return end
        local result = dbPoll( query, -1 ) or { }
        if not result[ 1 ] or not result[ 1 ].id then return end

        if not isElement( player_owner ) then -- 1 chance / 1.000.000
            DB:exec( "DELETE FROM " .. DB_TABLE_NAME .. " WHERE id = ?", result[ 1 ].id )
            return
        end

        loadParty( {
            id          = result[ 1 ].id,
            name        = name,
            last_play   = 0,
            pack_id     = 1,
            youtuber_id = client_id,
        } )

        player_owner:SetPartyID( result[ 1 ].id )
        player_owner:SetPartyRole( PARTY_ROLE_LEADER )
        triggerClientEvent( player_owner, "onClientShowPartyInfo", resourceRoot ) -- show guide
        player_owner:ShowSuccess( "Тусовка успешно создана" )
    end, { }, "SELECT id FROM " .. DB_TABLE_NAME .. " ORDER BY id DESC LIMIT 1" )
end

function saveAllParties( )
    for _, party in pairs( PARTY_LIST ) do
        local query = "UPDATE " .. DB_TABLE_NAME .. " SET name = ?, last_play = ?, draw_result = ?, top_list = ?, counter = ?, pack_id = ? WHERE id = ? LIMIT 1"
        DB:exec( query, party.name, party.last_play or 0, toJSON( party.draw_result ), toJSON( party.top_list ), party.counter, party.pack_id, party.id )
    end
end
setTimer( saveAllParties, SAVE_LIST_FREQ * 1000, 0 )

function updateTopList( party, client )
    party.top_10 = { }
    party.top_list_last_update = getRealTimestamp( )

    for idx, data in pairs( party.top_list ) do
        party.top_10[ idx ] = {
            nickname = ( data.client_id ):GetNickName( ) or "?",
            reward_name = data.r_name,
        }
    end

    if client then
        triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_TOP_LIST, party.top_10 )
    end
end

function updatePartyMembers( party, client )
    local counter = 0
    local members = { }

    party.members_last_update = getRealTimestamp( )

    -- load online members
    for _, player in pairs( GetPlayersInGame( ) ) do
        if player:GetPartyID( ) == party.id then
            local role = player:GetPartyRole( )

            table.insert( members, {
                id = player:GetID( ),
                client_id = player:GetClientID( ),
                nickname = player:GetNickName( ),
                party_role = role,
            } ) -- add online player to members list

            if role >= PARTY_ROLE_MEMBER then
                counter = counter + 1
            end
        end
    end

    -- load offline members
    DB:queryAsync( function ( query, client )
        if not query then return end

        for _, user in pairs( dbPoll( query, -1 ) or { } ) do
            if not GetPlayer( user.id ) then
                table.insert( members, user ) -- add offline player to members list

                if user.party_role >= PARTY_ROLE_MEMBER then
                    counter = counter + 1
                end
            end
        end

        if canUpdateRewardPack( party ) then
            party.pack_id = getRewardPackNum( counter + ( party.fake_online or 0 ) )
        end

        -- save
        party.total_online_players = counter
        party.members = members

        -- update for watcher
        if isElement( client ) then
            triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MEMBERS, members )
        end
    end, { client }, "SELECT id, nickname, client_id, party_role FROM nrp_players WHERE party_id = ?", party.id )
end

function getRewardPackNum( players_count )
    local pack_id = 0

    for num, pack in pairs( REWARDS_LIST ) do
        if pack.requirement <= players_count and num > pack_id then
            pack_id = num
        end
    end

    return pack_id > 0 and pack_id or false
end

function canUpdateRewardPack( party )
    return party.last_play == 0 or party.last_play + ONE_DAY_SECONDS * 6 < getRealTimestamp( )
end

function sendInvite( player, player_or_nickname )
    local party = getParty( player:GetPartyID( ) )
    local isOwner = player:GetPartyRole( ) == PARTY_ROLE_LEADER

    if not party or not isOwner then return end

    local timestamp = getRealTimestamp( )
    local target = nil

    if not isElement( player_or_nickname ) then
        local nickname = utf8.upper( tostring( player_or_nickname ) )
        for _, pl in pairs( GetPlayersInGame( ) ) do
            if utf8.upper( pl:GetNickName( ) ) == nickname then
                target = pl
            end
        end
    else
        target = player_or_nickname
    end

    if not target then
        return false, "Игрок с таким ником не найден или не в сети"
    elseif target:GetLevel( ) < MIN_LEVEL_FOR_PARTY then
        return false, "У игрока уровень меньше " .. MIN_LEVEL_FOR_PARTY
    elseif target:GetPartyID( ) > 0 then
        return false, "Игрок уже состоит в одной из тусовок"
    elseif not target:IsChangePartyAvailable( ) then
        local hours = math.ceil( ( target:GetPartyLockedTime( ) - timestamp ) / 3600 )
        return false, "Игроку заблокирована возможность вступления в тусовку на " .. hours .. " ч."
    end

    party.invitations[ target:GetID( ) ] = timestamp + 60 -- give 60 sec for accept invitation
    triggerClientEvent( target, "onClientShowPartyInvite", resourceRoot, party.id, party.name )

    -- analytics
    triggerEvent( "onPlayerGotInviteToParty", target, party.youtuber_id, party.name )

    return true, "Приглашение успешно отправлено"
end

function countPlayersOnParty( party )
    local counter = 0
    for player in pairs( party.players_on_party ) do
        counter = counter + 1
    end
    return counter
end

function partyEnd( party, player, reason, owner_is_leave )
    for pl in pairs( party.players_on_party ) do
        pl:RemoveFromParty( )
        pl:ShowInfo( reason )
    end

    if owner_is_leave then
        party.owner_is_leave = true
        return
    end

    -- analytics
    local counter_unique = party.counter_unique_players or 0
    local c = party.counter_players_on_start
    local c2 = countPlayersOnParty( party )
    local duration = getRealTimestamp( ) - party.last_play

    if player then
        triggerEvent( "onPlayerInitStopParty", player, party.youtuber_id, party.name, party.counter, counter_unique, c, c2, duration )
    end

    -- reset
    party.counter_unique_players = 0
    party.draw_result_names = false
    party.players_on_party = { }
    party.draw = false
    party.is_started = false
    party.time_start = false
end