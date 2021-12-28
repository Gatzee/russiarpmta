OLD_SEASON_WINNER_CLAN_ID = nil
OLD_SEASON_REWARD_END_DATE = getTimestampFromString( "18 июня 2020 00:00" )

function UpdateOldSeasonWinnerClan( )
    local exp = 0
    for clan_id, clan in pairs( OLD_CLANS ) do
        local clan_exp = clan.exp or 0
        if clan_exp > exp then
            OLD_SEASON_WINNER_CLAN_ID = clan_id
            exp = clan_exp
        end
    end
end

function CheckOldSeasonReward( player, clan_id )
    if OLD_SEASON_WINNER_CLAN_ID ~= clan_id then return end
    if os.time( ) > OLD_SEASON_REWARD_END_DATE then return end

    player:GiveMoney( 250000, "old_clan_season_compensation" )
    player:InventoryAddItem( IN_WEAPON, { 24, 10 }, 1 )
    player:InventoryAddItem( IN_WEAPON, { 29, 30 }, 1 )
    player:InventoryAddItem( IN_WEAPON, { 30, 15 }, 1 )

    player:PhoneNotification( { 
        title = "Компенсация", 
        msg = "Вы получили компенсацию наград за победу в старом сезоне банд:\n250 000р.\nДигл 10 пт.\nMP5 30 пт.\nАК-47 15 пт.", 
    } )
end






if SERVER_NUMBER > 100 then



    addCommandHandler( "showoldseasonwinner", function( )
        outputConsole( inspect( OLD_SEASON_WINNER_CLAN_ID ) )
    end )



end