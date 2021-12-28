Extend( "SPlayer" )
Extend( "SClans" )

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        for i, player in pairs( GetPlayersInGame( ) ) do
            if player:IsInClan( ) then
                triggerClientEvent( player, "onClientClanUpgradesSync", resourceRoot, CallClanFunction( player:GetClanID( ), "GetUpgrades" ) )
                if player:GetClanRank( ) >= NEED_CLAN_RANK then
                    player:ApplyAllClanBuffs( )
                end
            end
        end
    end, 1000, 1 )
end )

function GetPlayerClanBuffs( player )
    local clan_id = player:GetClanID( )
	if not clan_id or player:GetClanRank( ) < NEED_CLAN_RANK then
		return
	end
    local buffs = { }
    for upgrade_id, lvl in pairs( GetClanData( clan_id, "upgrades" ) ) do
        local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
        if upgrade_conf[ 1 ].buff_value then
            buffs[ upgrade_id ] = lvl
        end
    end
	return buffs
end

function GetClanBuffValue( player, buff_upgrade_id )
    local clan_id = player:GetClanID( )
	if not clan_id or player:GetClanRank( ) < NEED_CLAN_RANK then
		return 0
	end
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, buff_upgrade_id )
	return upgrade_lvl > 0 and CLAN_UPGRADES_LIST[ buff_upgrade_id ][ upgrade_lvl ].buff_value or 0
end

addEvent( "onClanUpgrade" )
addEventHandler( "onClanUpgrade", root, function( clan_id, upgrade_id, lvl )
    if CLAN_UPGRADES_LIST[ upgrade_id ].buff_id or CLAN_BUFF_CONTROLLERS[ upgrade_id ] then
        for i, player in pairs( CallClanFunction( clan_id, "GetOnlineMembers" ) ) do
            if player:GetClanRank( ) >= NEED_CLAN_RANK then
                player:ApplyClanBuff( upgrade_id, lvl )
            end
        end
    end
end )

addEvent( "onPlayerCompleteLogin" )
addEventHandler( "onPlayerCompleteLogin", root, function( )
    local player = source
    if player:IsInClan( ) and player:GetClanRank( ) >= NEED_CLAN_RANK then
        player:ApplyAllClanBuffs( )
    end
end )

addEvent( "onPlayerJoinClan" )
addEventHandler( "onPlayerJoinClan", root, function( )
    local player = source
    player:RemoveAllClanBuffs( )
    if player:GetClanRank( ) >= NEED_CLAN_RANK then
        player:ApplyAllClanBuffs( )
    end
end )

addEvent( "onPlayerClanRankReached" )
addEventHandler( "onPlayerClanRankReached", root, function(  )
    local player = source
    if new_rank == NEED_CLAN_RANK then
        player:RemoveAllClanBuffs( )
        player:ApplyAllClanBuffs( )
    end
end )

addEvent( "onPlayerLeaveClan" )
addEventHandler( "onPlayerLeaveClan", root, function( )
    local player = source
    player:RemoveAllClanBuffs( )
end )

addEvent( "onClanWayChange" )
addEventHandler( "onClanWayChange", root, function( clan_id )
    for i, player in pairs( CallClanFunction( clan_id, "GetOnlineMembers" ) ) do
        player:RemoveAllClanBuffs( )
    end
end )

addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, function( )
    local player = source
    if player:IsInClan( ) then
        for upgrade_id, lvl in pairs( GetClanData( player:GetClanID( ), "upgrades" ) ) do
            if CLAN_BUFF_CONTROLLERS[ upgrade_id ] and CLAN_BUFF_CONTROLLERS[ upgrade_id ].Clear then
                CLAN_BUFF_CONTROLLERS[ upgrade_id ]:Clear( player )
            end
        end
    end
end )