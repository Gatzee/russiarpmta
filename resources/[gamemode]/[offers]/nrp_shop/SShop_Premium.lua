PREMIUM_DISCOUNTS = {
    {
        id = "segmented_premium",
        include_prolonging = false,
        include_gift = false,
		array = {
            [ 3 ] = 199,
            [ 7 ] = 599,
            [ 14 ] = 499,
            [ 30 ] = 799,
		},
		condition = function( self, player )
			local ts = getRealTimestamp()
            local finish_time = tonumber( player:getData( "segmented_premium" ) ) -- 48 часов с помента получения према
            return finish_time and ts <= finish_time, finish_time
        end,
        on_purchase = function( self, player )
            player:setData( "segmented_premium", false, false )
            player:SetCommonData( { segmentedpremium_group = "group_A_finished" } )
            SyncPlayerPremiumDiscounts( player )
        end,
    },
    
    {
        id = "premium_discount",

        include_prolonging = false, -- запрет продления по скике
        include_gift = false, -- запрет подарка по скидке

        -- Глобальное начало и финиш
        time_start = getTimestampFromString( "30 ноября 2020 00:00" ),
        time_finish = getTimestampFromString( "1 декабря 2020 00:00" ),

		array = {
            [ 3 ] = 199,
            [ 7 ] = 399,
            [ 14 ] = 499,
            [ 30 ] = 799,
        },

		condition = function( self, player )
            local ts = getRealTimestamp()
            -- Не даём скидку, если игрок имеет премиум по момент начала акции
            return ( player:GetPermanentData( "premium_time_left" ) or 0 ) <= self.time_start
        end,

        on_purchase = function( self, player )
            SyncPlayerPremiumDiscounts( player )
        end,
	},
}

function IsDiscountAvailableForPlayer( player, discount )
    local ts = getRealTimestamp()
    if discount.time_start and ts <= discount.time_start then return end
    if discount.time_finish and ts >= discount.time_finish then return end

    local result, finish_time = false, discount.time_finish

    if discount.condition then
        local final_result, final_finish_time = discount:condition( player )

        if type( result ) == "table" then
            discount = table.copy( v )
            discount.array = result
        end

        result = final_result and discount
        finish_time = finish_time or final_finish_time
    end

    return result, finish_time
end

function GetPlayerPremiumDiscounts( player )
	for i, v in pairs( PREMIUM_DISCOUNTS ) do
        local result, finish_time = IsDiscountAvailableForPlayer( player, v )
        if result then
            return result, finish_time
        end
	end
end

function SyncPlayerPremiumDiscounts( player )
    local discounts, finish_time = GetPlayerPremiumDiscounts( player )
    triggerClientEvent( player, "onPremiumDiscountsSync", resourceRoot, discounts, finish_time )
end

function onPremiumDiscountsRefreshRequest_handler( )
	SyncPlayerPremiumDiscounts( source )
end
addEvent( "onPremiumDiscountsRefreshRequest", true )
addEventHandler( "onPremiumDiscountsRefreshRequest", root, onPremiumDiscountsRefreshRequest_handler )

function onPlayerCompleteLogin_premiumHandler( player )
    local player = isElement( player ) and player or source
    
	local discount, discount_time_finish = GetPlayerPremiumDiscounts( player )
	if discount and next( discount ) then
        SyncPlayerPremiumDiscounts( player )
        
        local premium_discounts_data = player:GetPermanentData( "premium_discounts_data" ) or { }
        if not premium_discounts_data[ discount.id ] then
            premium_discounts_data[ discount.id ] = { }
        end

        if not premium_discounts_data[ discount.id ][ "finish_" .. discount_time_finish ] then
            premium_discounts_data[ discount.id ][ "finish_" .. discount_time_finish ] = true
            triggerEvent( "onPlayerFirstPremiumDiscount", player, discount, discount_time_finish )
        end
    end

    local premium_time_left = player:GetPermanentData( "premium_time_left" ) or 0
    if premium_time_left > getRealTimestamp( ) then
        setElementData( player, "premium_time_left", premium_time_left )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_premiumHandler )

function CreateRefreshTimer( )
	setTimer( function( )
		for i, v in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_premiumHandler( v )
		end
	end, 2000, 1 )
end
function onResourceStart_handler( )
	triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "premium_discount" )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function getPremiumTime( premium_time_left, duration )
    local timestamp = getRealTimestamp()
    if premium_time_left < timestamp then
        premium_time_left = timestamp + duration * 24 * 60 * 60
    else
        premium_time_left = premium_time_left + duration * 24 * 60 * 60
    end
    return premium_time_left
end

function IsPlayerProlongingPremium( player )
    return ( player:GetPermanentData( "premium_time_left" ) or 0 ) > getRealTimestamp( )
end

function onPremiumPurchaseRequest_handler( duration, is_auto_prolong )
    local player = client or source

    local discount = GetPlayerPremiumDiscounts( player )
    if discount and not discount.include_prolonging and IsPlayerProlongingPremium( player ) then
        discount = nil
    end

    local duration_discount = discount and discount.array[ duration ]
    local cost = duration_discount or PREMIUM_SETTINGS.cost_by_duration[ duration ]

    --iprint( "cost", duration, cost )

    if player:GetDonate( ) < cost then
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Premium" )

        if is_auto_prolong then
            player:CleanPremiumStuff()
            player:PhoneNotification( {
                title = "Продление премиума",
                msg = "Премиум не был продлен, так как на балансе нет средств.",
            } )

            player:SetPermanentData( "prolong_last_duration", false )
        end

        return
    end

    if duration_discount then
        triggerEvent( "onPlayerPreDiscountPremium", player, cost, duration, discount )
        if discount.on_pre_purchase then discount:on_pre_purchase( player ) end
    end

    local premium_time_left = getPremiumTime( player:GetPermanentData( "premium_time_left" ) or 0, duration )

    player:TakeDonate( cost, "f4_premium", duration )

    player:SetPremiumExpirationTime( premium_time_left )

    player:SetPermanentData( "premium_total", ( player:GetPermanentData( "premium_total" ) or 0 ) + duration )
	player:SetPermanentData( "premium_transactions", ( player:GetPermanentData( "premium_transactions" ) or 0 ) + 1 )
    player:SetPermanentData( "premium_last_date", getRealTimestamp( ) )
    player:SetPermanentData( "premium_last_duration", duration )
    player:SetPermanentData( "prolong_last_duration", duration )
    player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
    player:InfoWindow( "Премиум успешно приобретен!" )

    triggerEvent( "onPlayerPremium", player, duration, cost, nil, is_auto_prolong )

	SendElasticGameEvent( player:GetClientID( ), "f4r_f4_premium_purchase" )

    if duration_discount then
        triggerEvent( "onPlayerDiscountPremium", player, cost, duration, discount )
        if discount.on_purchase then discount:on_purchase( player ) end
    end

    if is_auto_prolong then
        player:PhoneNotification( {
            title = "Продление премиума",
            msg = "Премиум автоматически продлён на "..duration.." дней.",
        } )
    end
end
addEvent( "onPremiumPurchaseRequest", true )
addEventHandler( "onPremiumPurchaseRequest", root, onPremiumPurchaseRequest_handler )

function onPremiumGiftRequest_handler( duration, target_name )
    local player = client

    local discount = GetPlayerPremiumDiscounts( player )
    if discount and not discount.include_gift then discount = nil end

    local duration_discount = discount and discount.array[ duration ]
    local cost = duration_discount or PREMIUM_SETTINGS.cost_by_duration[ duration ]

    if player:GetDonate( ) < cost then
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Premium gift" )
        return false
    end

    DB:queryAsync(function( queryHandler, player, duration, cost )
        local result = dbPoll(queryHandler,0)
        if type ( result ) ~= "table" or #result == 0 then
            player:ShowOverlay( OVERLAY_ERROR, { text = "Игрок с таким именем не найден!" } )
            return
        end

        result = result[ 1 ]

        local pTarget = GetPlayer( result.id, true )

        if pTarget and pTarget:IsInGame( ) then
            local premium_time_left = getPremiumTime( pTarget:GetPermanentData( "premium_time_left" ) or 0, duration )

            pTarget:SetPremiumExpirationTime( premium_time_left )
            pTarget:SetPermanentData( "premium_total", ( pTarget:GetPermanentData( "premium_total" ) or 0 ) + duration )
        else
            local premium_time_left = getPremiumTime( result.premium_time_left or 0, duration )

            DB:exec("UPDATE nrp_players SET premium_time_left=?, premium_total=`premium_total`+? WHERE id=? LIMIT 1",
            premium_time_left, duration, result.id ) 
        end

        triggerEvent( "onPlayerPremium", player, duration, cost, result.client_id )

        player:SetPermanentData( "premium_transactions", ( player:GetPermanentData( "premium_transactions" ) or 0 ) + 1 )
        player:SetPermanentData( "premium_last_date", getRealTimestamp( ) )
        player:TakeDonate( cost, "f4_premium_gift", duration )
        player:InfoWindow( "Ты успешно подарил игроку "..result.nickname.." "..duration.." д. премиума! ")
        player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

    end, { player, duration, cost }, "SELECT id, nickname, premium_time_left, premium_total, client_id FROM nrp_players WHERE nickname = ? LIMIT 1", target_name)
end
addEvent( "onPremiumGiftRequest", true )
addEventHandler( "onPremiumGiftRequest", root, onPremiumGiftRequest_handler )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "premium_discount" then return end

	for i,v in pairs( PREMIUM_DISCOUNTS ) do
		if v.id == key then
			if not value or next( value ) == nil then
				PREMIUM_DISCOUNTS[ i ].time_start = 0
				PREMIUM_DISCOUNTS[ i ].time_finish = 0
			else
				PREMIUM_DISCOUNTS[ i ].include_prolonging = value[ 1 ].include_prolonging or false -- запрет продления по скике
				PREMIUM_DISCOUNTS[ i ].include_gift = value[ 1 ].include_gift or false -- запрет подарка по скидке

				PREMIUM_DISCOUNTS[ i ].time_start = getTimestampFromString( value[ 1 ].time_start )
				PREMIUM_DISCOUNTS[ i ].time_finish = getTimestampFromString( value[ 1 ].time_finish )

				--Числовые ключи приходят строкой, конвертим
				local converted = { }
				for days,price in pairs( value[ 1 ].array ) do 
					converted[ tonumber( days ) ] = price
				end
                PREMIUM_DISCOUNTS[ i ].array = converted
			end
		end
    end
    
	CreateRefreshTimer( )
end )

function OnPlayerChangeAutoProlong( state )
    if not isElement( client ) then return end
    client:SetPermanentData( "premium_renewal_enabled", state )
    client:ShowNotification( "Авто-продление премиума "..( state and "включено" or "выключено" ) )
end
addEvent( "OnPlayerChangeAutoProlong", true )
addEventHandler( "OnPlayerChangeAutoProlong", resourceRoot, OnPlayerChangeAutoProlong )

--[[function OnPremiumWindowShown()
    if isElement(client) then
        if not client:GetPermanentData("new_premium_shown") then
            triggerEvent("onPlayerDiscountPremiumShown", client)
            client:SetPermanentData("new_premium_shown", true)
        end
    end
end
addEvent("OnPremiumWindowShown", true)
addEventHandler("OnPremiumWindowShown", resourceRoot, OnPremiumWindowShown)]]