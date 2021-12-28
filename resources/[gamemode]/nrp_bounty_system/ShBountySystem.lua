loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShBounty" )
Extend( "ShClans" )
Extend( "ShUtils" )

SEARCH_TIME = 60 * 60 * 3 -- 3 hours
HIDE_NICK_TIME = 3600 -- 1 hour

COPS_HUNTERS_REWARDS = {
    2500,
    2500,
    2500,
    2500,
    2500,
    2500,
    2500,
    2500,
    2500,
    2500,
    5000,
    5000,
}

CLAN_MEMBER_REWARDS = {
    [ CLAN_ROLE_LEADER ] = 5000,
    [ CLAN_ROLE_MODERATOR ] = 3000,
    [ CLAN_ROLE_SENIOR ] = 3000,
    [ CLAN_ROLE_MIDDLE ] = 2500,
    [ CLAN_ROLE_JUNIOR ] = 2500,
}

COPS_FACTIONS = {
    [ F_POLICE_PPS_GORKI ] = true,
    [ F_POLICE_PPS_NSK ] = true,
    [ F_POLICE_PPS_MSK ] = true,
}