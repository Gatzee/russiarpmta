REGISTERED_CLAN_WARS = { }
CLAN_WARS_LOBBIES = { }

REGISTER_AVAILABLE_AFTER_DURATION = 15 * 60
REGISTER_AVAILABLE_DURATION = 15 * 60

CARTEL_WARS_WAITING_DURATION = 3 * 60 * 60

function CheckCartelWars( )
	print( "CheckCartelWars", formatTimestamp( os.time( ) ) )
	local leaderboard = LOCKED_SEASON_LEADEBOARD
	for cartel_id = 1, 2 do
		local candidate_clan_id = leaderboard[ cartel_id ] and leaderboard[ cartel_id ][ LB_CLAN_ID ]
		local candidate_clan = CLANS_BY_ID[ candidate_clan_id ]
		if candidate_clan_id and candidate_clan then
			if not CARTEL_CLANS[ cartel_id ] then
				SetCartelClan( cartel_id, candidate_clan_id )
				
				local all_clans_players = GetPlayersInGame( )
				for i, player in pairs( all_clans_players ) do
					if not player:IsInClan( ) then
						all_clans_players[ i ] = nil
					end
				end
				triggerClientEvent( all_clans_players, "onClientCartelHouseWarFinish", resourceRoot, nil, candidate_clan_id )
			else
				RegisterClanWar( candidate_clan_id, CARTEL_CLANS[ cartel_id ].id, CLAN_EVENT_CARTEL_CAPTURE )
			end
		end
	end
end

function RegisterClanWar( clan_id, enemy_clan_id, event_id )
    local start_date = os.time( ) + REGISTER_AVAILABLE_AFTER_DURATION
    REGISTERED_CLAN_WARS[ clan_id ] = {
        enemy_clan_id = enemy_clan_id,
        event_id = event_id,
        date = os.time( ),
        start_date = start_date,
        expires_date = start_date + REGISTER_AVAILABLE_DURATION,
    }
    REGISTERED_CLAN_WARS[ enemy_clan_id ] = {
        enemy_clan_id = clan_id,
        event_id = event_id,
        date = os.time( ),
        start_date = start_date,
        expires_date = start_date + REGISTER_AVAILABLE_DURATION,
    }
    setTimer( CreateClanWarLobby, REGISTER_AVAILABLE_AFTER_DURATION * 1000, 1, clan_id, enemy_clan_id, event_id )

    local clan = CLANS_BY_ID[ clan_id ]
    local enemy_clan = CLANS_BY_ID[ enemy_clan_id ]
    triggerClientEvent( clan:GetOnlineMembers( ), "onClientClanWarEventStateChange", resourceRoot, event_id, true, _, start_date, enemy_clan_id )
    triggerClientEvent( enemy_clan:GetOnlineMembers( ), "onClientClanWarEventStateChange", resourceRoot, event_id, true, _, start_date, clan_id )
end

function CreateClanWarLobby( clan_id, enemy_clan_id, event_id )
    local lobby = exports.nrp_clans_events:CreateLobby( event_id, { enemy_clan_id, clan_id } )
    
    lobby.teams = { clan_id, enemy_clan_id }
    CLAN_WARS_LOBBIES[ lobby.id ] = lobby
    REGISTERED_CLAN_WARS[ clan_id ].lobby_id = lobby.id
    REGISTERED_CLAN_WARS[ enemy_clan_id ].lobby_id = lobby.id
    
    local clan = CLANS_BY_ID[ clan_id ]
    local enemy_clan = CLANS_BY_ID[ enemy_clan_id ]

    local start_date = os.time( ) + REGISTER_AVAILABLE_DURATION
    triggerClientEvent( clan:GetOnlineMembers( ), "onClientClanWarEventStateChange", resourceRoot, event_id, true, lobby.id, start_date, enemy_clan_id )
    triggerClientEvent( enemy_clan:GetOnlineMembers( ), "onClientClanWarEventStateChange", resourceRoot, event_id, true, lobby.id, start_date, clan_id )

    -- setTimer( OnClanWarJoinTimeExpired, REGISTER_AVAILABLE_DURATION * 1000, 1, clan_id )
end

function onPlayerWantJoinCartelWarEvent_handler( event_id, lobby_id )
    local player = client or source
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local data = REGISTERED_CLAN_WARS[ clan_id ]
    if data then
        triggerEvent( "CEV:OnPlayerRequestEventJoin", player, lobby_id )
    else
        player:ShowError( "Регистрация закрыта" )
    end
end
addEvent( "onPlayerWantJoinCartelWarEvent", true )
addEventHandler( "onPlayerWantJoinCartelWarEvent", root, onPlayerWantJoinCartelWarEvent_handler )

function CEV_OnLobbyStateChanged_handler( lobby_id, state )
    local lobby = CLAN_WARS_LOBBIES[ lobby_id ]
    if lobby and state >= 4 then
        for i, clan_id in pairs( lobby.teams ) do
            if REGISTERED_CLAN_WARS[ clan_id ] then
                if state == 5 then
                    REGISTERED_CLAN_WARS[ clan_id ] = nil
                    CLAN_WARS_LOBBIES[ lobby_id ] = nil
                end

                local clan = CLANS_BY_ID[ clan_id ]
                if not clan then return end
                triggerClientEvent( clan:GetOnlineMembers( ), "onClientClanWarEventStateChange", resourceRoot, lobby.event_id, false )
            end
        end
    end
end
addEvent( "CEV:OnLobbyStateChanged", true )
addEventHandler( "CEV:OnLobbyStateChanged", root, CEV_OnLobbyStateChanged_handler )

function CEV_OnLobbyDestroyed_handler( lobby_id )
    CEV_OnLobbyStateChanged_handler( lobby_id, 5 )
end
addEvent( "CEV:OnLobbyDestroyed", true )
addEventHandler( "CEV:OnLobbyDestroyed", root, CEV_OnLobbyDestroyed_handler )

-- function OnClanWarJoinTimeExpired( clan_id )
--     local data = REGISTERED_CLAN_WARS[ clan_id ]
--     if not data then return end

--     REGISTERED_CLAN_WARS[ clan_id ] = nil
--     REGISTERED_CLAN_WARS[ data.enemy_clan_id ] = nil

--     local clan = CLANS_BY_ID[ clan_id ]
--     if not clan then return end
--     TakeCartelTax( clan )

--     -- CARTEL_CLANS[ 1 ]:GiveMoney( half )
--     -- CARTEL_CLANS[ 2 ]:GiveMoney( half )

--     -- if is_leader_decision then
--     --     triggerClientEvent( clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
--     --         title = "Картель",
--     --         msg = "Ваш лидер клана выплатил налог картелю в 50%",
--     --     } )

--     -- Remove clan players from party maker
-- end

function CheckClanWar( clan, player )
    local clan_war = REGISTERED_CLAN_WARS[ clan.id ]
    if clan_war and clan_war.expires_date > os.time( ) then
        local start_date = clan_war.lobby_id and clan_war.expires_date or clan_war.start_date
        triggerClientEvent( player, "onClientClanWarEventStateChange", player, clan_war.event_id, true, clan_war.lobby_id, start_date, clan_war.enemy_clan_id )
    end
end

if SERVER_NUMBER > 100 then
    

    addCommandHandler( "createlobbylol", function( player )
        -- CreateClanWarLobby( GetPlayer( 1 ):GetClanID( ), 4, CLAN_EVENT_CARTEL_TAX_WAR )
        local enemy_clan_id = next( CLANS_BY_ID, player:GetClanID( ) ) or next( CLANS_BY_ID )
        RegisterClanWar( player:GetClanID( ), enemy_clan_id, CLAN_EVENT_CARTEL_TAX_WAR )
        outputConsole( "Вы успешно создали лообби против клана " .. CLANS_BY_ID[ enemy_clan_id ].name )
    end )

end