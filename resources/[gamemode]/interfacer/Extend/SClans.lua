Import( "ShClans" )
Import( "ShAsync" )

CallClanFunction = function( clan_id, ... )
    return exports.nrp_clans:CallClanFunction( clan_id, ... )
end

GetClanName = function( clan_id, key )
    return CallClanFunction( clan_id, "GetPermanentData", "name" )
end

----------------------------------------------------------------

GetClanData = function( clan_id, key )
    return CallClanFunction( clan_id, "GetPermanentData", key )
end

SetClanData = function( clan_id, key, value )
    return CallClanFunction( clan_id, "SetPermanentData", key, value )
end

----------------------------------------------------------------

GetClanHonor = function( clan_id, ... )
    return CallClanFunction( clan_id, "GetHonor", ... )
end

GiveClanHonor = function( clan_id, ... )
    return CallClanFunction( clan_id, "GiveHonor", ... )
end

TakeClanHonor = function( clan_id, ... )
    return CallClanFunction( clan_id, "TakeHonor", ... )
end

----------------------------------------------------------------

GetClanMoney = function( clan_id, ... )
    return CallClanFunction( clan_id, "GetMoney", ... )
end

GiveClanMoney = function( clan_id, ... )
    return CallClanFunction( clan_id, "GiveMoney", ... )
end

TakeClanMoney = function( clan_id, ... )
    return CallClanFunction( clan_id, "TakeMoney", ... )
end

----------------------------------------------------------------

GetClanUpgradeLevel = function( clan_id, upgrade_id )
    return CallClanFunction( clan_id, "GetUpgradeLevel", upgrade_id ) or 0
end

GetClanBuffValue = function( clan_id, buff_upgrade_id )
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, buff_upgrade_id )
    return upgrade_lvl > 0 and CLAN_UPGRADES_LIST[ buff_upgrade_id ][ upgrade_lvl ].buff_value or 0
end