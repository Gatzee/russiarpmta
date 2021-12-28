
FACTION_ENTER_INTERIOR_POSITIONS =
{
    [ F_ARMY ] =             { -1206.5419, -1286.1767, 21.4300 },  --Армия
    [ F_POLICE_PPS_NSK ] =   { -356.3408, -1672.0124,  20.7572 },  --ППС НСК
    [ F_POLICE_DPS_NSK ] =   { 336.5394,  -2035.0581, 20.9718 },  --ДПС НСК
    [ F_MEDIC ] =            { 398.8274,  -2447.2276, 22.2414 },  --Медики
    [ F_POLICE_PPS_GORKI ] = { 1940.4461,  -739.0047,  60.7769 },  --ППС Горки
    [ F_POLICE_DPS_GORKI ] = { 2232.2683,  -643.3341,  60.8238 },  --ДПС Горки
    [ F_GOVERNMENT_NSK ] =   { -2.4342,   -1696.4391,  20.8128 },  --Мэрия НСК
    [ F_GOVERNMENT_GORKI ] = { 2268.9458, -952.1851,   60.6664 },  --Мэрия Горки
    [ F_GOVERNMENT_MSK ]   = { -119.28, 2117.95, 21.6 },           -- Мэрия МСК
    [ F_FSIN ] =             { -1206.5419, -1286.1767, 21.4300 },  --ФСИН
    [ F_POLICE_PPS_MSK ] =   { 1228.693,    2194.109,   9.686   },  --ППС МСК
    [ F_POLICE_DPS_MSK ] =   { -1473.2,     2546.7,     10.47   },  --ДПС МСК
    [ F_MEDIC_MSK ] =        { 1422.17,     2722.03,    9.91    },  --Медики МСК
}

FACTION_MEGAPHONE_DATA = {}

addEvent( "onServerPlayerUseMegaphone", true )
addEventHandler( "onServerPlayerUseMegaphone", root, function( message )
    
    if not client:IsInFaction() then return end

    local message_len = utf8.len( message )
    if message_len == 0 or message_len > 350 then return end

    local target_faction = client:GetFaction()  
    local cur_time_left = FACTION_MEGAPHONE_DATA[ target_faction ]
    
    local timestamp = getRealTimestamp()
    if not cur_time_left or cur_time_left > timestamp then return end
    
    local target_players = {}
    for k, v in pairs( GetPlayersInGame() ) do
        if v ~= client and v:IsInGame() and not v:IsInFaction() and not v:IsInClan() and not v:getData( "jailed" ) then
            table.insert( target_players, v )
        end
    end

    local pNotification =
	{
		title = FACTIONS_NAMES[ target_faction ],
        msg = message,
        special = "megaphone_notification",
        position = FACTION_ENTER_INTERIOR_POSITIONS[ target_faction ],
	}
    
	triggerClientEvent( target_players, "OnClientReceivePhoneNotification", root, pNotification )
    triggerEvent( "onServerReceiveSentMessage", client, CHAT_TYPE_MEGAPHONE, message, client )

    local time_left = timestamp + 3 * 60 * 60
    FACTION_MEGAPHONE_DATA[ target_faction ] = time_left
    
    for k, v in pairs( GetPlayersInGame() ) do
        if target_faction == v:GetFaction() then
            v:SetPrivateData( "megaphone_time_left", time_left )
        end
    end
end )

function onPlayerReady_handler( pPlayer )
    local pPlayer = pPlayer or source
    if pPlayer:IsInGame() and pPlayer:IsInFaction() then
        local player_faction = pPlayer:GetFaction()
        pPlayer:SetPrivateData( "megaphone_time_left", FACTION_MEGAPHONE_DATA[ player_faction ] or 0 )        
    end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReady_handler, true, "high+1000000" )

function onPlayerFactionChange_handler( player, ignore_team_reset )
    local player = isElement( player ) and player or source
    if player:IsInFaction() then
        onPlayerReady_handler( player )
    end
end
addEvent( "onPlayerFactionChange", true )
addEventHandler( "onPlayerFactionChange", root, onPlayerFactionChange_handler )

function InitializeDataBase()
    for k, v in pairs( FACTION_ENTER_INTERIOR_POSITIONS ) do
        FACTION_MEGAPHONE_DATA[ k ] = 0
    end

    for k, v in pairs( GetPlayersInGame() ) do
        if v:IsInFaction() then
            v:SetPrivateData( "megaphone_time_left", 0 )
        end
    end
end
addEventHandler( "onResourceStart", resourceRoot, InitializeDataBase )