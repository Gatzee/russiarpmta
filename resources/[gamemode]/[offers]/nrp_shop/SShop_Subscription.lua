-- Покупка/подарок подписки
--[[
function onSubscriptionBuyRequest_handler( days, nickname )
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

			iprint( nickname, player )

			player:GiveSubscription( days_info[ days ].days )

			if days_info[ days ].money_reward then
				player:GiveMoney( days_info[ days ].money_reward, "BuySubscription" )
			end

            client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
            client:InfoWindow( "Ты успешно подарил подписку на " ..  days_info[ days ].days .." д.!" )

            player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
            player:InfoWindow( client:GetNickName( ) .. " подарил тебе подписку на " ..  days_info[ days ].days .." д.!" )

			triggerEvent( "onPlayerBuySubscription", client, days_info[ days ].cost, days_info[ days ].months, player:GetClientID() )
		else
            DB:queryAsync(
                function( query, client, days )
                    local result = query:poll( -1 )
                    local player_info = result[ 1 ]
                    if not player_info or not player_info.id then
                        client:ShowOverlay( OVERLAY_ERROR, { text = "Игрок с таким именем не найден" } )
                        return
                    end

                    client:TakeDonate( days_info[ days ].cost, "SUBSCRIPTION_" .. days_info[ days ].days, "NRPDszx5x" )

                    local current_timestamp = getRealTime().timestamp
                    local current_expiration_time = math.max( current_timestamp, player_info.subscription_time_left or 0 )
                    current_expiration_time = current_expiration_time + 86400 * days_info[ days ].days
                    local updated_money = player_info.money + ( days_info[ days ].money_reward or 0 )

                    DB:queryAsync( function( query ) dbFree( query ) end, { }, "UPDATE nrp_players SET subscription_time_left=?, money=? WHERE id=?", current_expiration_time, updated_money, player_info.id )
                    
                    client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
                    client:InfoWindow( "Ты успешно подарил подписку на " ..  days_info[ days ].days .." д.!" )

                    triggerEvent( "onPlayerBuySubscription", client, days_info[ days ].cost, days_info[ days ].months, player_info.client_id )
                end, { client, days },
                "SELECT id, subscription_time_left, money, client_id FROM nrp_players WHERE nickname=? LIMIT 1",
                nickname
            )
		end
		--triggerClientEvent( client, "ShowUIDonate", resourceRoot, 4 )
		--triggerClientEvent( client, "CDonate::RecieveNotification", resourceRoot, { "Вы успешно подарили ".. nickname, "подписку на ".. days_info[ days ].days .." дней" } )
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

            triggerClientEvent( client, "onSubscriptionBuyRequest_Success", resourceRoot )
            triggerEvent( "onPlayerBuySubscription", client, cost, days_info[ days ].months, nil, was_active, discount_active )
            client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
            client:InfoWindow( "Ты успешно приобрел подписку на " ..  days_info[ days ].days .." д.!" )
		end
	end
end
addEvent( "onSubscriptionBuyRequest", true )
addEventHandler( "onSubscriptionBuyRequest", root, onSubscriptionBuyRequest_handler )
]]--
-- Ежеденевные бонусы
function onSubscriptionTakeRewardsRequest_handler( )
	if not client:IsPremiumActive( ) then return end

	if client:GiveSubscriptionRewards( true ) then
        client:InfoWindow( "Ты успешно получил ежедневные бонусы!" )
	else
        client:ShowError(  )
        client:ShowOverlay( OVERLAY_ERROR, { text = "Ты уже получал ежедневные бонусы сегодня!" } )
	end
end
addEvent( "onSubscriptionTakeRewardsRequest", true )
addEventHandler( "onSubscriptionTakeRewardsRequest", root, onSubscriptionTakeRewardsRequest_handler )

-- Смена цвета ника
function onSubscriptionChangeNicknameColorRequest_handler( color_index )
	if not client:IsPremiumActive( ) then return end
	if not PLAYER_NAMETAG_COLORS[ color_index ] then return end

	if client:SetNicknameColor( color_index, false, true ) then
        client:ShowSuccess( "Цвет ника успешно изменен!" )
	else
		local text = getHumanTimeString( client:getData("nickname_color_timeout") or 0 ) or ""
        client:ShowOverlay( OVERLAY_ERROR, { text = "Цвет ника можно менять раз в 7 дней! Осталось ".. text } )
	end
end
addEvent( "onSubscriptionChangeNicknameColorRequest", true )
addEventHandler( "onSubscriptionChangeNicknameColorRequest", root, onSubscriptionChangeNicknameColorRequest_handler )

function onPlayerCompleteLogin_donate_handler( )
	if source:IsPremiumActive( ) then
		local nickname_color = source:GetPermanentData( "nickname_color" )
		if nickname_color and nickname_color > 1 then 
			source:setData( "nickname_color", nickname_color )
		end
	end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_donate_handler )