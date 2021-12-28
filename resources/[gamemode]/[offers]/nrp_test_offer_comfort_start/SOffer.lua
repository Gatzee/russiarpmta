loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SDB" )
Extend( "SPlayer" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

CONST_DB_NAME = "offers_comfort_start_test"
CONST_96_HOURS = 96 * 3600 -- 96 hours
CONST_OFFER_TIME = 48 * 3600 -- 48 hours
CONST_DAY_MAX_COUNT = 500
CONST_MAX_COUNT = 5000

local PACKAGES = {
    {
        name = "Базовый",
        en_name = "basic",
        cost = 99,
        reward = {
            items = {
                { id = IN_CANISTER, count = 2 },
                { id = IN_REPAIRBOX, count = 2 },
                { id = IN_JAILKEYS },
                { id = IN_FIRSTAID, count = 2 },
            },
            premium_days = 1,
        }
    },
    {
        name = "Стандартный",
        en_name = "standart",
        cost = 149,
        reward = {
            items = {
                { id = IN_CANISTER, count = 3 },
                { id = IN_REPAIRBOX, count = 3 },
                { id = IN_JAILKEYS, count = 2 },
                { id = IN_FIRSTAID, count = 3 },
            },
            premium_days = 3,
        }
    },
    {
        name = "Комфортный",
        en_name = "comfort",
        cost = 199,
        reward = {
            items = {
                { id = IN_CANISTER, count = 5 },
                { id = IN_REPAIRBOX, count = 5 },
                { id = IN_JAILKEYS, count = 3 },
                { id = IN_FIRSTAID, count = 5 },
                { id = IN_FOOD_LUNCHBOX, count = 5 },
            },
            premium_days = 7,
        }
    },
}

function allocatePlayer( player )
    local client_id = player:GetClientID( )
    CommonDB:queryAsync( function( query, player )
        if not isElement( player ) then
            dbFree( query )
            return
        end

        local result = query:poll( -1 )
        local timestamp = getRealTimestamp( )
        local today = getRealTime( timestamp )
        local avg = false

        for idx, group in pairs( result or { } ) do
            local day = getRealTime( group.today_date )

            if day.monthday ~= today.monthday or day.month ~= today.month or day.year ~= today.year then
                group.today_count = 0
                group.today_date = timestamp
            end

            if group.today_count < CONST_DAY_MAX_COUNT and ( group.count < CONST_MAX_COUNT or group.group_name == "test" ) then
                if not avg or avg.today_count > group.today_count then
                    avg = group
                end
            end
        end

        if avg then
            if SERVER_NUMBER > 100 then
                iprint( player, "move to group", avg.group_name )
            end

            if avg.group_name == "test" then
                player:SetPermanentData( "comfort_test_offer_end_date", timestamp + CONST_OFFER_TIME )
                onPlayerShowOffer( player, timestamp + CONST_OFFER_TIME )

                -- analytics
                SendElasticGameEvent( client_id, "test_comfort_start_offer_show_first" )
            else
                resetOffer( player )
            end

            CommonDB:exec(
                "UPDATE " .. CONST_DB_NAME .. " SET count = `count` + 1, today_count = ?, today_date = ? WHERE id= ? LIMIT 1",
                avg.today_count + 1, avg.today_date, avg.id
            )

            -- analytics
            SendElasticGameEvent( client_id, "test_comfort_start_offer_is_test", { test_group = avg.group_name } )
        else
            resetOffer( player )
        end
    end, { player }, "SELECT * FROM " .. CONST_DB_NAME )
end

function onPlayerPreShowOffer( player )
    if player:GetPermanentData( "comfort_test_offer_passed" ) then return end -- offer was passed
    if not player:GetPermanentData( "is_first_character" ) then return end -- not first char

    local timestamp = getRealTimestamp( )
    local offerEndDate = player:GetPermanentData( "comfort_test_offer_end_date" )

    if offerEndDate then
        if offerEndDate > timestamp then
            onPlayerShowOffer( player, offerEndDate ) -- show offer
            triggerClientEvent( player, "ShowSplitOfferInfo", player, offerEndDate - timestamp )
        else
            resetOffer( player ) -- time of offer was passed
        end

    elseif ( timestamp - player:GetPermanentData( "reg_date" ) < CONST_96_HOURS ) or SERVER_NUMBER > 100 then
        player:GetCommonData( { "X2_start" }, { player }, function( result, player )
            if not isElement( player ) then return end
            if not result.X2_start or result.X2_start - timestamp > 0 then return end -- offer 'x2 start' was not passed

            allocatePlayer( player )
        end )
    else
        resetOffer( player )
    end
end

function onPlayerShowOffer( player, end_date )
    player:SetPrivateData( "comfort_test_offer_end_date", end_date )

    triggerClientEvent( player, "onPlayerShowOfferComfortStart", player, true )
end

function resetOffer( player, purchase )
    if purchase then player:SetPermanentData( "comfort_test_offer_purchase", purchase ) end
    player:SetPermanentData( "comfort_test_offer_passed", true )
    player:SetPermanentData( "comfort_test_offer_end_date", nil )

    player:SetPrivateData( "comfort_test_offer_end_date", nil )
end

addEventHandler( "onResourceStart", resourceRoot, function( )
    CommonDB:createTable( CONST_DB_NAME, {
        { Field = "id",					Type = "int(11) unsigned",	    Null = "NO",    Key = "PRI",    Extra = "auto_increment"	},
        { Field = "group_name",			Type = "varchar(128)",	    	Null = "YES",	Key = "",	                                },
        { Field = "count",				Type = "int(11) unsigned",	    Null = "NO",	Key = "",	    Default = 0                 },
        { Field = "today_count",		Type = "int(11) unsigned",	    Null = "NO",	Key = "",	    Default = 0                 },
        { Field = "today_date",		    Type = "int(11) unsigned",	    Null = "NO",	Key = "",	    Default = 0                 },
    } )

    CommonDB:queryAsync( function( query )
        local result = query:poll( -1 )

        if not next( result ) then
            CommonDB:exec("INSERT INTO " .. CONST_DB_NAME .. " ( group_name ) VALUES ( 'control' )" )
            CommonDB:exec("INSERT INTO " .. CONST_DB_NAME .. " ( group_name ) VALUES ( 'test' )" )
        end
    end, { }, "SELECT group_name FROM " .. CONST_DB_NAME )
end )

addEvent( "onPlayerOfferComfortStartUIRequest", true )
addEventHandler( "onPlayerOfferComfortStartUIRequest", root, function ( )
    if not isElement( client ) then return end

    onPlayerPreShowOffer( client )
end )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    onPlayerPreShowOffer( source )
end, true, "high" )

addEvent( "onPlayerWantBuyPackageComfortStart", true )
addEventHandler( "onPlayerWantBuyPackageComfortStart", resourceRoot, function ( id )
    if not client or not PACKAGES[ id ] then return end

    if ( client:GetPermanentData( "comfort_test_offer_end_date" ) or 0 ) < getRealTimestamp( ) then return end

    if client:TakeDonate( PACKAGES[ id ].cost, "comfort start offer", id ) then
        local reward = PACKAGES[ id ].reward

        if reward.premium_days then
            client:GivePremiumExpirationTime( reward.premium_days )
            client:ShowInfo( "Вы получили " .. reward.premium_days .. " дней премиума" )
        end

        for idx, item in pairs( reward.items or { } ) do
            client:InventoryAddItem( item.id, nil, item.count or 1 )
        end

        client:ShowInfo( 'Вы получили пакет "' .. PACKAGES[ id ].name .. '"')

        resetOffer( client, true )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "test_comfort_start_offer_purchase", {
            pack_cost = PACKAGES[ id ].cost,
            currency = "hard",
            pack_id = id,
            pack_name = PACKAGES[ id ].en_name,
        } )

        triggerClientEvent( client, "onPlayerShowOfferComfortStart", client, false )
    else
        client:ShowError( "Недостаточно средств" )
    end
end )

-- FOR TEST SERVER
if SERVER_NUMBER > 100 then
    addCommandHandler( "removecomfortstartoffer", function( player )
        player:ShowInfo( "Оффер очищен" )

        resetOffer( player )
    end )

    addCommandHandler( "addcomfortstartoffer", function( player )
        resetOffer( player )

        player:SetPermanentData( "comfort_test_offer_passed", nil )
        player:SetPermanentData( "is_first_character", true )

        player:ShowInfo( "Нужные данные для активации акции выставлены!" )
    end )
end