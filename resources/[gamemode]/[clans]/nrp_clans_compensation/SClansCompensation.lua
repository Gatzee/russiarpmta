loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SDB" )

OLD_CLANS = { }

function onResourceStart_handler( )
    LoadOldClans( )

    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            CheckOldClan( v )
        end
    end, 1000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function LoadOldClans( )
    local query = DB:query( "SELECT ckey, cvalue FROM nrp_clans_data" )
    local result = query:poll( -1 )
    if result then
        for i, row in pairs( result ) do
            local clan_id = row.ckey
            if type( clan_id ) == "string" and clan_id:find( "^clan_" ) and clan_id ~= "clan_Korrupcioneri_528" then
                local data_tbl = fromJSON( row.cvalue )
                if data_tbl then
                    OLD_CLANS[ clan_id ] = data_tbl.config
                end
            end
        end
        UpdateOldSeasonWinnerClan( )
    end
end

function CheckOldClan( player )
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local old_clan_data = OLD_CLANS[ clan_id ]

    if not old_clan_data then
        if not tonumber( clan_id ) then
            player:SetClanID( nil )
        end
        return
    end

    player:SetClanID( nil )
    CheckOldSeasonReward( player, clan_id )
    
    if player:GetUserID( ) == old_clan_data.owner then
        if player:GetPermanentData( "old_clan_compensation" ) then return end

        player:GiveMoney( 5000000, "old_clan_compensation" )

        local old_clan_compensation = {
            slots_upgrade = 1,
        }
        if old_clan_data.upgrades and old_clan_data.upgrades.slots then
            if old_clan_data.upgrades.slots == 1 then
                old_clan_compensation.slots_upgrade = 3
            elseif ( old_clan_data.upgrades.slots or 0 ) >= 2 then
                old_clan_compensation.slots_upgrade = 5
            end
        end

        if ( old_clan_data.cash or 0 ) > 0 then
            old_clan_compensation.money = old_clan_data.cash
        end
        player:SetPermanentData( "old_clan_compensation", old_clan_compensation )
        
        triggerClientEvent( player, "ShowClansCompensationUI", player, true )
    end
end
addCommandHandler( "testblit", function( me )
    CheckOldClan( me )
end )

addEventHandler( "onPlayerCompleteLogin", root, function( )
    CheckOldClan( source )
end, true, "high+10000000" )