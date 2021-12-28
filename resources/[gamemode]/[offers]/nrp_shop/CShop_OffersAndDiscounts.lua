CONST_UPDATE_SPECIAL_OFFERS_INTERVAL = 5 * 60 * 1000

OFFERS_LIST, OFFERS_ARRAY = { }, { }
SPECIAL_OFFERS = nil
SPECIAL_OFFERS_LIST = nil
local SEGMENTS_DATA = nil
local WAS_OFFERS_SYNCED = false
local OFFER_ON_SCREEN = nil

function IsSpecialOffersSynced( )
    return WAS_OFFERS_SYNCED
end

local SEGMENT_SORTING_ORDER = {
    [ 1 ] = { 1, 2, 3, 4 },
    [ 2 ] = { 2, 1, 3, 4 },
    [ 3 ] = { 3, 2, 1, 4 },
    [ 4 ] = { 4, 3, 2, 1 },
}
local SEGMENT_SORTING_ORDER_REVERSE = { }
for n, v in pairs( SEGMENT_SORTING_ORDER ) do
    SEGMENT_SORTING_ORDER_REVERSE[ n ] = { }
    for i, k in pairs( v ) do
        SEGMENT_SORTING_ORDER_REVERSE[ n ][ k ] = i
    end
end
local SEGMENT_SORTING_ORDER_CURRENT

local CURRENT_SEGMENT = 4
local function SortBySegments( a, b )
    return SEGMENT_SORTING_ORDER_CURRENT[ a.segment or 4 ] < SEGMENT_SORTING_ORDER_CURRENT[ b.segment or 4 ]
end

function GetOfferDiscountPriceForModel( offer_type, model, variant )
    if IsOfferActiveForModel( offer_type, model ) then
        if not variant or not OFFERS_ARRAY[ offer_type ][ model ].variant or OFFERS_ARRAY[ offer_type ][ model ].variant == variant then
            return OFFERS_ARRAY[ offer_type ][ model ].cost
        end
    end
end

function IsSpecialOfferActive( v )
	local ts = getRealTimestamp( )
	return v.type == "special" 
		and ( not v.finish_date or v.finish_date >= ts )
		and ( not v.start_date or v.start_date <= ts )
		and SPECIAL_OFFERS_CLASSES[ v.class ]:fn_check( v )
end

function IsOfferActiveForModel( offer_type, model )
    if not OFFERS_ARRAY[ offer_type ] or not OFFERS_ARRAY[ offer_type ][ model ] then
        return false
    end

    local model_conf = OFFERS_ARRAY[ offer_type ][ model ]
    if model_conf then
        local ts = getRealTimestamp( )

        local conditions = { }

        if model_conf.finish_date then table.insert( conditions, model_conf.finish_date >= ts ) end
        if model_conf.start_date then table.insert( conditions, model_conf.start_date <= ts ) end

        local result = true

        -- Доп проверка для кастомных акций
        if offer_type == "discounts" then
            result = DISCOUNTS_OFFERS[ model_conf.class ] and DISCOUNTS_OFFERS[ model_conf.class ].fn_check and DISCOUNTS_OFFERS[ model_conf.class ]:fn_check( model_conf )
        end

        for i, v in pairs( conditions ) do result = result and v end

        if result then
            return true
        end
    end
end

function GetCurrentSegment( player )
    return CURRENT_SEGMENT or 4
end

function UpdateLimitedSpecialOffersSoldCount( offers_counts )
    offers_counts = offers_counts or SPECIAL_OFFERS_COUNTS
    if not offers_counts then return end
    SPECIAL_OFFERS_COUNTS = offers_counts

    if not SPECIAL_OFFERS_LIST then return end

    for i, offer in pairs( SPECIAL_OFFERS_LIST ) do
        if offer.limit_count then
            local changed = false
            for i, data in pairs( offers_counts ) do
                if data.class == offer.class and ( tonumber( data.model ) or data.model ) == offer.model and data.start_date == offer.start_date then
                    offer.sold_count = data.count
                    changed = true
                    break
                end
            end

            if not changed and offer.sold_count then
                offer.sold_count = nil
                changed = true
            end

            if changed and TABS_CONF.special.items[ offer.id ] then
                TABS_CONF.special.items[ offer.id ].UpdateCount( offer )
            end

            if not offer.finish_date then
                local sold_count = offer.sold_count or 0
                local limit_count = offer.limit_count or 0
                if sold_count >= limit_count then
                    -- Скрываем распроданные офферы без даты окончания
                    offer.finish_date = 0
                else
                    if OFFER_ON_SCREEN ~= false and offer.class == "vehicle" and offer.start_date <= getRealTimestamp( ) then
                        if not OFFER_ON_SCREEN or offer.start_date > OFFER_ON_SCREEN.start_date then
                            OFFER_ON_SCREEN = offer
                        end
                    end
                end
            end
        end
    end

    if OFFER_ON_SCREEN then
        showLimitedUI( true, OFFER_ON_SCREEN )
        OFFER_ON_SCREEN = false
    end
end

addEvent( "onClientUpdateSpecialOfferCount", true )
addEventHandler( "onClientUpdateSpecialOfferCount", resourceRoot, function( offer_id, count )
    local offer = SPECIAL_OFFERS[ offer_id ]
    offer.sold_count = count
    TABS_CONF.special.items[ offer.id ].UpdateCount( offer )
end )

function onPlayerSyncOffers_handler( list, segments, newest_segment )
    if list then
        CURRENT_SEGMENT = newest_segment or 4

        DISCOUNT_OFFERS_LIST = list
        OFFERS_LIST = table.copy( list )

        SEGMENTS_DATA = segments
        -- SEGMENT_SORTING_ORDER_CURRENT = SEGMENT_SORTING_ORDER_REVERSE[ newest_segment ]
        -- table.sort( OFFERS_LIST, SortBySegments )
        
        OFFERS_ARRAY = {
            discounts = { },
            special   = { },
        }
    else
        OFFERS_LIST = table.copy( DISCOUNT_OFFERS_LIST )
    end

    -- Если с веба ещё не пришли данные о спешелухе
    if not SPECIAL_OFFERS then
        return
    end

    SPECIAL_OFFERS_LIST = FilterOffersBySegment( SPECIAL_OFFERS, SEGMENTS_DATA, true )
    for i, v in pairs( SPECIAL_OFFERS_LIST ) do
        v.type = "special"
        table.insert( OFFERS_LIST, v )
    end

    for i, v in pairs( OFFERS_LIST ) do
        OFFERS_ARRAY[ v.type ][ v.model ] = v
    end

    -- for i, v in pairs( OFFERS_LIST ) do
    --     iprint( i, v.name, v.model, "segment", v.segment )
    -- end

    print( "Synced offers and discounts", #OFFERS_LIST )
    
    WAS_OFFERS_SYNCED = true
    triggerEvent( "onClientPlayerSyncOffersFinish", localPlayer )

    UpdateLimitedSpecialOffersSoldCount( )
    GenerateSlidersForSpecials( )
end
addEvent( "onPlayerSyncOffers", true )
addEventHandler( "onPlayerSyncOffers", root, onPlayerSyncOffers_handler )

function LoadSpecialOffers( )
    local server = localPlayer:getData( "_srv" )[ 1 ]
    fetchRemote( CONST_GET_SPECIAL_OFFERS_URL .. server,
        {
            queueName = "special_offers",
            connectionAttempts = 10,
            connectTimeout = 15000,
            method = "GET",
        },
        function( data, err )
            -- Если ошибка чтения, но раньше уже читались special_offers
            if ( not err.success or err.statusCode ~= 200 ) then
                -- TODO: подгружать с сервера?
                print( "failed to load special offers",  err.statusCode)
                return
            end

            onSpecialOffersLoaded( fromJSON( data ) )
        end
    )
end

function onSpecialOffersLoaded( data )
    -- Если уже была первичная загрузка офферов и данные спешелухи не поменялись
    if WAS_OFFERS_SYNCED and table.compare( OLD_SPECIAL_OFFERS, data ) then
        return
    end

    OLD_SPECIAL_OFFERS = data
    SPECIAL_OFFERS = table.copy( FixTableKeys( data, true ) ) -- table.copy, т.к. меняются segment и sold_count
    for i, offer in pairs( SPECIAL_OFFERS ) do
        offer.type = "special"
        offer.model = tonumber( offer.model ) or offer.model

        if offer.data then
            for k, v in pairs( offer.data ) do
                offer[ k ] = type( v ) == "table" and FixTableKeys( v, true ) or v
            end
        end
    end
    
    -- Если с сервера уже пришли данные о сегментах
    if SEGMENTS_DATA then
        onPlayerSyncOffers_handler( )
    end
end

addEvent( "LoadSpecialOffers", true )
addEventHandler( "LoadSpecialOffers", root, function( url )
    if CONST_GET_SPECIAL_OFFERS_URL then return end
    CONST_GET_SPECIAL_OFFERS_URL = url
    setTimer( LoadSpecialOffers, CONST_UPDATE_SPECIAL_OFFERS_INTERVAL, 0 )
    LoadSpecialOffers( url )
end )

addEvent( "onClientPlayerSyncOffersFinish", true )

-- Синхронизация офферов после рестарта (ресурс на клиенте чаще всего запускается позже, чем на сервере)
addEventHandler( "onClientResourceStop", resourceRoot, function( )
    root:setData( "_was_f4_stopped", true, false )
end )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    if root:getData( "_was_f4_stopped" ) and not next( OFFERS_ARRAY ) then
        setTimer( function( )
            triggerServerEvent( "onPlayerLoadPaymentDetails", localPlayer )
        end, 1000, 1 )
    end
end )