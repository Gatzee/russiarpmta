function onPlayerWantShowClanMainUI_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    local data = {
        tag                 = clan.tag,
        way                 = clan.way,
        name                = clan.name,
        motd                = clan.motd,
        desc                = clan.desc,
        money               = clan:GetMoney( ),
        honor               = clan:GetHonor( ),
        score               = clan:GetScore( ),
        slots               = clan.slots,
        members_count       = clan.members_count,
        -- delete_date         = clan.delete_date,
        -- members             = members,
        today_best_member   = clan.today_best_member,
        base_id             = clan.base_id,
        
        exp                 = player:GetClanEXP( ),
        rank                = player:GetClanRank( ),
        stats               = player:GetPermanentData( "clan_stats" ),

        season_data         = GetClansSeasonData( ),

        holdarea_score      = clan.holdarea_score,
        deathmatch_score    = clan.deathmatch_score,
        cargodrops_score    = clan.cargodrops_score,

        freezer             = clan.freezer,
        today_batches       = exports.nrp_clans_freezer:GetClanProductBatches( clan.id ),
    }
    triggerClientEvent( player, "ShowClanMainUI", player, true, data )
end
addEvent( "onPlayerWantShowClanMainUI", true )
addEventHandler( "onPlayerWantShowClanMainUI", root, onPlayerWantShowClanMainUI_handler )

function onPlayerWantShowClanManageUI_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    clan:GetMembers( function( members )
        if not isElement( player ) then return end

        local data = {
            tag                 = clan.tag,
            way                 = clan.way,
            name                = clan.name,
            motd                = clan.motd,
            desc                = clan.desc,
            money               = clan:GetMoney( ),
            honor               = clan:GetHonor( ),
            score               = clan:GetScore( ),
            slots               = clan.slots,
            members             = members,
            members_count       = clan.members_count,
            upgrades            = clan:GetUpgrades( ),
            money_log         = clan.money_log,
            delete_date         = clan.delete_date,
            is_closed           = clan.is_closed,
            sputnik             = clan:GetSputnik( ),
            -- base                = { band.marker.x, band.marker.y, band.marker.z },

            exp                 = player:GetClanEXP( ),
            rank                = player:GetClanRank( ),
        }
        triggerClientEvent( player, "ShowClanManageUI", player, true, data )
    end )
end
addEvent( "onPlayerWantShowClanManageUI", true )
addEventHandler( "onPlayerWantShowClanManageUI", root, onPlayerWantShowClanManageUI_handler )

function onPlayerWantShowClanStorageUI_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    if not clan:HasStorage( ) then
        player:ShowError( "Ваш клан ещё не приобрел хранилище" )
        return
    end

    local data = {
        tag                 = clan.tag,
        name                = clan.name,
        money               = clan:GetMoney( ),
        -- online_members      = clan:GetOnlineMembers( ),
        storage             = clan.storage,
        
        exp                 = player:GetClanEXP( ),
        rank                = player:GetClanRank( ),
    }
    triggerClientEvent( player, "ShowClanStorageUI", player, true, data )
end
addEvent( "onPlayerWantShowClanStorageUI", true )
addEventHandler( "onPlayerWantShowClanStorageUI", root, onPlayerWantShowClanStorageUI_handler )

function onPlayerWantShowGundealerUI_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    local data = {
        money               = clan:GetMoney( ),
        has_storage         = clan:HasStorage( ),
    }
    triggerClientEvent( player, "ShowClanGundealerUI", player, true, data )
end
addEvent( "onPlayerWantShowGundealerUI", true )
addEventHandler( "onPlayerWantShowGundealerUI", root, onPlayerWantShowGundealerUI_handler )

function onPlayerWantShowClanCartelUI_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    if not clan.cartel then
        player:ShowError( "Ваш клан не является картелем!" )
        return
    end

    local data = {
        tag                     = clan.tag,
        name                    = clan.name,
        money                   = clan:GetMoney( ),
        
        exp                     = player:GetClanEXP( ),
        rank                    = player:GetClanRank( ),

        clans_list              = GetCartelTaxPayedClans( clan.cartel ),
        tax_log                 = GetCartelTaxLog( clan.cartel ),
        can_request_tax         = CanCartelsRequestTax( ),
        can_declare_war         = CanCartelsDeclareWar( ),
        next_tax_request_date   = not CanCartelsRequestTax( ) and ALLOW_CARTELS_TAX_REQUESTS_DATE or nil,
    }
    triggerClientEvent( player, "ShowClanCartelUI", player, true, data )
end
addEvent( "onPlayerWantShowClanCartelUI", true )
addEventHandler( "onPlayerWantShowClanCartelUI", root, onPlayerWantShowClanCartelUI_handler )