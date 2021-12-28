Extend( "CPlayer" )
Extend( "ShClans" )
Extend( "ShUtils" )

local CURRENT_CLAN_UPGRADES = { }

function GetAppliedBuffs( )
	return CURRENT_CLAN_UPGRADES
end

function GetClanUpgradeLevel( clan_id, upgrade_id )
    local is_buff_upgrade = CLAN_UPGRADES_LIST[ upgrade_id ][ 1 ].buff_value
    if is_buff_upgrade and localPlayer:GetClanRank( ) < NEED_CLAN_RANK then
        return 0
    end
    local upgrade_lvl = CURRENT_CLAN_UPGRADES[ upgrade_id ]
	return upgrade_lvl or 0
end

function GetClanBuffValue( player, buff_upgrade_id )
	if not localPlayer:GetClanID( ) or localPlayer:GetClanRank( ) < NEED_CLAN_RANK then
		return 0
	end
    local upgrade_lvl = CURRENT_CLAN_UPGRADES[ buff_upgrade_id ] or 0
	return upgrade_lvl > 0 and CLAN_UPGRADES_LIST[ buff_upgrade_id ][ upgrade_lvl ].buff_value or 0
end

function ApplyClanBuffs( upgrades )
    localPlayer:RemoveAllClanBuffs( )
    if localPlayer:GetClanRank( ) >= NEED_CLAN_RANK then
        localPlayer:ApplyAllClanBuffs( upgrades )
    end
    CURRENT_CLAN_UPGRADES = upgrades
end
addEvent( "onClientClanUpgradesSync", true ) -- Триггер при входе в игру/вступлении в клан/смене пути развития
addEventHandler( "onClientClanUpgradesSync", root, ApplyClanBuffs )

addEvent( "onClientClanUpgrade", true )
addEventHandler( "onClientClanUpgrade", root, function( upgrade_id, lvl )
    if localPlayer:GetClanRank( ) >= NEED_CLAN_RANK then
        localPlayer:ApplyClanBuff( upgrade_id, lvl )
    end
    CURRENT_CLAN_UPGRADES[ upgrade_id ] = lvl
end )

addEventHandler( "onClientElementDataChange", localPlayer, function( key )
	if key == "clan_rank" and localPlayer:GetClanRank( ) >= NEED_CLAN_RANK then
        localPlayer:ApplyAllClanBuffs( CURRENT_CLAN_UPGRADES )
	end
end )

addEvent( "onClientPlayerLeaveClan", true )
addEventHandler( "onClientPlayerLeaveClan", root, function( )
    localPlayer:RemoveAllClanBuffs( )
    CURRENT_CLAN_UPGRADES = { }
end )
