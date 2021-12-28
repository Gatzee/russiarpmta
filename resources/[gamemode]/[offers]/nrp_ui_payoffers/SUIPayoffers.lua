loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerCommon" )
Extend( "SWebshop" )

MS24H = 24 * 60 * 60 * 1000
MS1M = 60 * 1000
DB_SOLD_NAME = "offers_packs_sold_count"
PAYOFFERS = { }
FIRST_SHOW_EVENTS = {
    format1 = "more_donate_pack_offer_show_first",
    format2 = "locked_donate_pack_offer_show_first",
    format3 = "limited_donate_pack_offer_show_first",
}
LIMITED_PACKS_SOLD_COUNTER = { }

function UpdatePacksSoldCounter( )
    CommonDB:queryAsync( function( query )
        local result = query:poll( 0 )

        for i, data in pairs( result or { } ) do
            local key = data.pack_id .. data.start_date .. data.finish_date
            LIMITED_PACKS_SOLD_COUNTER[ key ] = data.count
        end

        if GetCurrentPayoffer( ) then
            setTimer( UpdatePacksSoldCounter, MS1M, 1 )
        end
    end, { }, "SELECT * FROM " .. DB_SOLD_NAME )
end

function ClearExpiredOffersPacks( )
    CommonDB:exec( "DELETE FROM " .. DB_SOLD_NAME .. " WHERE finish_date > 0 AND finish_date <= UNIX_TIMESTAMP( NOW( ) )" )
end

function GetCurrentPayoffer( )
    local timestamp = getRealTimestamp( )

    for i, v in pairs( PAYOFFERS ) do
        if v.start <= timestamp and v.finish >= timestamp then
            return v
        end
    end
end

function showPayOffer( player, just_connected )
    local payoffer = GetCurrentPayoffer( )
    if not payoffer or not player:HasFinishedTutorial( ) then return end

    local name = payoffer.name or ""
    local time = player:GetPermanentData( "payoffer_time" ) or { }

    if FIRST_SHOW_EVENTS[ name ] and time[ name ] ~= payoffer.start then
        time[ name ] = payoffer.start

        player:SetPermanentData( "payoffer_time", time )

        -- delete the key
        if payoffer.name == "format2" then
            player:SetCommonData( { format2_unlocked = false } )
            player:SetPrivateData( "format2_unlocked", nil )
        end

        -- show offer
        player:triggerEvent( "ShowPayofferUI", player, payoffer, LIMITED_PACKS_SOLD_COUNTER )

        -- first show analytic's event
        SendElasticGameEvent( player:GetClientID( ), FIRST_SHOW_EVENTS[ name ] )

    elseif just_connected and payoffer.name == "format2" then
        player:GetCommonData( { "format2_unlocked" }, { player }, function( result, the_player )
            if not isElement( the_player ) then return end

            if result.format2_unlocked then
                the_player:SetPrivateData( "format2_unlocked", true )
            end

            -- show offer
            player:triggerEvent( "ShowPayofferUI", player, payoffer, LIMITED_PACKS_SOLD_COUNTER )
        end )
    else
        -- show offer
        player:triggerEvent( "ShowPayofferUI", player, payoffer, LIMITED_PACKS_SOLD_COUNTER )
    end
end

addEvent( "ShowPayoffer", true )
addEventHandler( "ShowPayoffer", root, function ( )
    showPayOffer( source )
end )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    showPayOffer( source, true )
end )

addEvent( "onPlayerBoughtDonatePack", false )
addEventHandler( "onPlayerBoughtDonatePack", root, function ( client_id, pack_id )
    local pack = PACKS[ pack_id ]
    if not pack then
        return
    end

    if pack_id == PACK_FORMAT_2_4 then -- bought pack with the "key"
        client_id:SetCommonData( { format2_unlocked = true } )

        if source.type == "player" then
            source:SetPrivateData( "format2_unlocked", true )
            triggerClientEvent( source, "onClientBoughtOfferWithKey", resourceRoot )
        end
    elseif pack.limit then -- bought limited pack
        local payoffer = GetCurrentPayoffer( )

        if payoffer then
            local key = pack_id .. payoffer.start .. payoffer.finish
            LIMITED_PACKS_SOLD_COUNTER[ key ] = ( LIMITED_PACKS_SOLD_COUNTER[ key ] or 0 ) + 1

            CommonDB:exec( [[
                INSERT INTO ]] .. DB_SOLD_NAME .. [[ ( pack_id, start_date, finish_date ) VALUES ( ?, ?, ? )
                ON DUPLICATE KEY UPDATE count = count + 1;
            ]], pack_id, payoffer.start, payoffer.finish )
        end
    end

    SendElasticGameEvent( client_id, pack.event, {
        id          = pack.analytics_id,
        name        = pack.analytics_id_default,
        cost        = pack.price,
        hard_sum    = pack.hard,
        currency    = "hard",
        quantity    = 1,
        spend_sum   = pack.price,
    } )
end )

addEventHandler( "onResourceStart", resourceRoot, function ( )
    CommonDB:createTable( DB_SOLD_NAME, {
        { Field = "pack_id"    , Type = "int(11) unsigned", Null = "NO", Key = "PRI",                          },
        { Field = "start_date" , Type = "int(11) unsigned", Null = "NO", Key = ""   ,                          },
        { Field = "finish_date", Type = "int(11) unsigned", Null = "NO", Key = ""   ,                          },
        { Field = "count"      , Type = "int(11) unsigned", Null = "NO", Key = ""   , Default = 1              },
    } )

    ClearExpiredOffersPacks( )
    setTimer( ClearExpiredOffersPacks, MS24H, 0 )
end )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "hard_discount" then return end

	if not value or next( value ) == nil then 
		PAYOFFERS = { }
	else
		for i,v in pairs( value ) do 
			v.start = getTimestampFromString( v.start_date )
			v.finish = getTimestampFromString( v.finish_date )
			v.start_date = nil
			v.finish_date = nil
		end
		PAYOFFERS = value

        if GetCurrentPayoffer( ) then
            setTimer( UpdatePacksSoldCounter, MS1M, 1 )
        end
	end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "hard_discount" )
