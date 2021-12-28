loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
MARIADB_INCLUDE = {
	APIDB = true,
}
Extend( "SDB" )
Extend( "SWebshop" )

addEvent( "onPlayerDonate", true )

TRANSACTIONS_CACHE = { }

-- Приём доната
function CheckClientID( client_id )
	if GetPlayerFromClientID( client_id ) then return true end
	
	local result = dbPoll( DB:query( "SELECT id FROM nrp_players WHERE client_id=? LIMIT 1", client_id ), -1 )
	return result and result[ 1 ] and result[ 1 ].id and true
end

function onDonateRecieve( client_id, sum, transaction, profit, is_game_purchase )
-- transaction.client_id, transaction.amount, transaction.id, transaction.paramsparams
--function onDonateRecieve( client_id, sum, transaction, params, details )
	if TRANSACTIONS_CACHE[ transaction ] then
		WriteLog( "donate", "TRANSACTION_DUPLICATE: Ошибка принятия доната %s р., client_id: %s, transaction: %s", tostring( sum ), tostring( client_id ), tostring( transaction ) )
		return true
	end

	if not client_id or not tonumber( sum ) or tonumber( sum ) <= 0 then
		WriteLog( "donate", "ERROR: Ошибка принятия доната %s р., client_id: %s, transaction: %s", tostring( sum ), tostring( client_id ), tostring( transaction ) )
		outputDebugString( string.format( "ERROR: Ошибка принятия доната %s р., client_id: %s", tostring( sum ), tostring( client_id ) ), 2 )
		return false 
	end

	--iprint( "RCV", client_id, sum )

	local level, uid, nickname
	local player = GetPlayerFromClientID( client_id )

	-- Игрок онлайн
	if isElement( player ) and player:IsInGame() then
		player:GiveDonate( sum, "real_payment" )
		player:ShowSuccess( "Спасибо за покупку!\nВаш счёт успешно пополнен на " .. sum .. " р.!" )
		level, uid, nickname = player:GetLevel(), player:GetUserID( ), player:GetNickName( )
		WriteLog( "donate", "[%s] %s донат %s р., client_id: %s", tostring( transaction ), player, sum, client_id )
		player:SetPermanentData( "donate_total", ( player:GetPermanentData( "donate_total" ) or 0 ) + sum )
		player:SetPermanentData( "donate_transactions", ( player:GetPermanentData( "donate_transactions" ) or 0 ) + 1 )
		player:SetPermanentData( "donate_last_date", getRealTime().timestamp )

		TRANSACTIONS_CACHE[ transaction ] = true
		triggerEvent( "onPlayerDonate", root, client_id, sum, transaction, level, is_game_purchase )
		triggerEvent( "onPlayerPayment", root, client_id, level, sum, transaction, uid, nickname, "soft_purchase_" .. ( tonumber( is_game_purchase ) == 1 and "web" or "game" ) )
		
		triggerClientEvent( player, "onDonatePaymentSuccess", player, sum )
	-- Игрок оффлайн
	else
		DB:queryAsync( 
			function( query, client_id, sum, transaction, is_game_purchase ) 
				local result = dbPoll( query, -1 )
				if not result[ 1 ] then
					WriteLog( "donate", "ERROR: Нет игрока, донат %s р., client_id: %s", sum, client_id )
					outputDebugString( string.format( "ERROR: Нет игрока, донат %s р., client_id: %s", sum, client_id ), 2 )

				else
					client_id:GiveDonate( sum, "real_payment" )
					level, uid, nickname = tonumber( result[ 1 ].level ), tonumber( result[ 1 ].id ), result[ 1 ].nickname
					WriteLog( "donate", "OFFLINE: [%s] %s донат на %s р., client_id: %s", tostring( transaction ), result[ 1 ].nickname, sum, client_id )
					DB:exec( "UPDATE nrp_players SET donate_total=`donate_total`+?, donate_last_date=?, donate_transactions=`donate_transactions`+1 WHERE client_id=?", sum, getRealTime().timestamp, client_id )
					
					TRANSACTIONS_CACHE[ transaction ] = true
					triggerEvent( "onPlayerDonate", root, client_id, sum, transaction, level, is_game_purchase )
					triggerEvent( "onPlayerPayment", root, client_id, level, sum, transaction, uid, nickname, "soft_purchase_" .. ( tonumber( is_game_purchase ) == 1 and "web" or "game" ) )
				
				end
			end, { client_id, sum, transaction, is_game_purchase },
		"SELECT id, nickname, level, donate_total FROM nrp_players WHERE client_id=? LIMIT 1", client_id )
	
	end

	return true
end

function onSubscriptionBuy_handler( days, nickname )
	if not client then return end

	local subscription_discount_buy_count = client:GetPermanentData( "subscription_discount_buy_count" ) or 0
	local discount_active = getRealTime().timestamp < CONST_SUBSCRIPTION_DISCOUNT_END_TIMESTAMP and subscription_discount_buy_count < 2

	local days_info = {
		[1] = {
			days = 30;
			cost = 999;
			discount_cost = 699;
			months = 1;
		};
		[2] = {
			days = 90;
			cost = 2997;
			discount_cost = 1599;
			months = 3;

			money_reward = 300000;
		};
	}

	if not days_info[ days ] then return end

	if nickname then
		if client:GetDonate() < days_info[ days ].cost then return end

		local player = nil

		local getPlayerNametagText = getPlayerNametagText
		for _, p in pairs( getElementsByType( "player" ) ) do
			if getPlayerNametagText( p ) == nickname then
				player = p
			end
		end

		if player then
			client:TakeDonate( days_info[ days ].cost, "SUBSCRIPTION_" .. days_info[ days ].days, "NRPDszx5x" )

			--iprint( nickname, player )

			player:GiveSubscription( days_info[ days ].days )

			if days_info[ days ].money_reward then
				player:GiveMoney( days_info[ days ].money_reward, "BuySubscription" )
			end

			player:ShowSuccess( "Вам подарили подписку на ".. days_info[ days ].days .." дней" )

			triggerEvent( "onPlayerBuySubscription", client, days_info[ days ].cost, days_info[ days ].months, player:GetClientID() )
		else
			local result = dbPoll( DB:query( "SELECT id, subscription_time_left, money, client_id FROM nrp_players WHERE nickname=? LIMIT 1", nickname ), -1 )
			
			local player_info = result[ 1 ]
			if not player_info or not player_info.id then
				triggerClientEvent( client, "ShowUIDonate", resourceRoot, 4 )
				triggerClientEvent( client, "CDonate::RecieveNotification", client, { "Ошибка покупки:", "Игрок с таким именем не найден", true } )

				return
			end

			client:TakeDonate( days_info[ days ].cost, "SUBSCRIPTION_" .. days_info[ days ].days, "NRPDszx5x" )

			local current_timestamp = getRealTime().timestamp
			local current_expiration_time = math.max( current_timestamp, player_info.subscription_time_left or 0 )
			current_expiration_time = current_expiration_time + 86400 * days_info[ days ].days
			local updated_money = player_info.money + ( days_info[ days ].money_reward or 0 )

			DB:queryAsync( function( query ) dbFree( query ) end, { }, "UPDATE nrp_players SET subscription_time_left=?, money=? WHERE id=?", current_expiration_time, updated_money, player_info.id )

			triggerEvent( "onPlayerBuySubscription", client, days_info[ days ].cost, days_info[ days ].months, player_info.client_id )
		end

		triggerClientEvent( client, "ShowUIDonate", resourceRoot, 4 )
		triggerClientEvent( client, "CDonate::RecieveNotification", resourceRoot, { "Вы успешно подарили ".. nickname, "подписку на ".. days_info[ days ].days .." дней" } )
	else
		local cost = discount_active and days_info[ days ].discount_cost or days_info[ days ].cost
		if client:TakeDonate( cost, "SUBSCRIPTION_" .. days_info[ days ].days, "NRPDszx5x" ) then
			local was_active = client:IsSubscriptionActive()

			client:GiveSubscription( days_info[ days ].days )

			if discount_active then
				client:SetPrivateData( "subscription_discount_buy_count", subscription_discount_buy_count + 1 )
				client:SetPermanentData( "subscription_discount_buy_count", subscription_discount_buy_count + 1 )
			end

			if days_info[ days ].money_reward then
				client:GiveMoney( days_info[ days ].money_reward, "BuySubscription" )
			end

			triggerClientEvent( client, "ShowUIDonate", resourceRoot, 4 )
			triggerClientEvent( client, "CDonate::RecieveNotification", resourceRoot, { "Вы успешно ".. ( was_active and "продлили" or "купили" ), "подписку на ".. days_info[ days ].days .." дней" } )

			triggerEvent( "onPlayerBuySubscription", client, cost, days_info[ days ].months, nil, was_active, discount_active )
		end
	end
end
addEvent( "onSubscriptionBuy", true )
addEventHandler( "onSubscriptionBuy", root, onSubscriptionBuy_handler )