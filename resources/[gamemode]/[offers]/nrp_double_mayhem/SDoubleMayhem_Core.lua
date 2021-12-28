Extend( "SPlayer" )
Extend( "SVehicle" )

OFFER_START_DATE = 0
OFFER_FINISH_DATE = 0

function IsOfferActive()
	local ts = getRealTimestamp()
	return ts >= OFFER_START_DATE and ts <= OFFER_FINISH_DATE
end

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "double_mayhem_universal" then return end

	if not value or next( value ) == nil then
		OFFER_START_DATE = 0
		OFFER_FINISH_DATE = 0
	else
		OFFER_START_DATE = getTimestampFromString( value[ 1 ].start_date )
		OFFER_FINISH_DATE = getTimestampFromString( value[ 1 ].finish_date )
	end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "double_mayhem_universal" )

function onPlayerReadyToPlay_handler( player )
	local player = source or player
	if not player:HasFinishedTutorial() then return end

	-- Если получает подарок за купленные товары, то оффер уже завершен
	if TryTakeGift( player ) then return end

	if not IsOfferActive() then
		--Если оффер закончен и игрок не забрал свою награду по какой-то причине
		for k, v in pairs( player:GetPackData() ) do
			if v == PACK_STATE_PURCHASED then
				triggerClientEvent( player, "onClientShowRewardDoubleMayhem", resourceRoot, k )
				return
			end
		end

		return 
	end

	-- Если новый оффер, чистим данные
	if player:GetLastDoubleMayhemId() ~= OFFER_START_DATE then
		player:ResetOffer()
		player:SetLastDoubleMayhemId( OFFER_START_DATE )
	end

	-- Если уже получил награду
	if player:IsOpenGift() then return end

	local is_show_first = not player:IsShowFirst()
	if is_show_first then player:SetShowFirstState( true ) end

	player:SetPrivateData( "double_mayhem_offer_finish", OFFER_FINISH_DATE )
	onServerRequestDoubleMayhemOffer_handler( player, is_show_first )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "high+9999999" )

function onServerRequestDoubleMayhemOffer_handler( player, is_show_first )
	local player = client or player
	triggerClientEvent( player, "onClientShowDoubleMayhemOffer", resourceRoot, {
		pack_data = player:GetPackData(),
		is_show_first = is_show_first,
		offer_finish_date = OFFER_FINISH_DATE,
	} )
end
addEvent( "onServerRequestDoubleMayhemOffer", true )
addEventHandler( "onServerRequestDoubleMayhemOffer", resourceRoot, onServerRequestDoubleMayhemOffer_handler )

function onServerPlayerTryPurchaseDoubleMayhemPack_handler( pack_id )
	local player = client
	if not OFFER_CONFIG.packs[ pack_id ] or not IsOfferActive() or player:GetPackState( pack_id ) or player:IsOpenGift() then return end
	
	if player:TakeDonate( OFFER_CONFIG.packs[ pack_id ].cost, "sale", "double_mayhem" ) then
		onServerPlayerPurchasedDoubleMayhem_handler( OFFER_CONFIG.packs[ pack_id ].cost )
	else
		triggerClientEvent( player, "onClientSelectMayhemDoublePackInBrowser", resourceRoot, OFFER_CONFIG.packs[ pack_id ].cost )
	end
end
addEvent( "onServerPlayerTryPurchaseDoubleMayhemPack", true )
addEventHandler( "onServerPlayerTryPurchaseDoubleMayhemPack", resourceRoot, onServerPlayerTryPurchaseDoubleMayhemPack_handler )

function onServerPlayerPurchasedDoubleMayhem_handler( sum )
	local player = client or source

	local pack_id = nil
	for k, v in pairs( OFFER_CONFIG.packs ) do
		if v.cost == sum then
			pack_id = k
			break
		end
	end

	if not pack_id then return end
	player:SetPackState( pack_id, PACK_STATE_PURCHASED )

	local is_all_packs_purchased = player:IsAllPackPurchased()
	if is_all_packs_purchased then
		player:SetOpenGiftState( true )
		player:SetCurrentGiftReward( OFFER_CONFIG.gift )
	end
	
	triggerClientEvent( player, "onClientShowRewardDoubleMayhem", resourceRoot, pack_id, {
		pack_data = player:GetPackData(),
	} )

	-- Аналитика :-
	onDoubleMayhemPurchased( player, pack_id, is_all_packs_purchased )
end
addEvent( "onServerPlayerPurchasedDoubleMayhem" )
addEventHandler( "onServerPlayerPurchasedDoubleMayhem", root, onServerPlayerPurchasedDoubleMayhem_handler )

function onServerPlayerTakeReward_handler( pack_id, data )
	local player = client
	local is_gift_reward = pack_id == "gift"
	if not is_gift_reward and not OFFER_CONFIG.packs[ pack_id ] then return end

	-- Небольшой костыль, для получения наград. Нужен для последовательного получения наград. 1. Пак; 2. Подарок.
	if is_gift_reward and not player:GetCurrentGiftReward() then
		return
	elseif OFFER_CONFIG.packs[ pack_id ] and player:GetPackState( pack_id ) ~= PACK_STATE_PURCHASED then
		return
	end

	for k, v in pairs( is_gift_reward and { OFFER_CONFIG.gift } or OFFER_CONFIG.packs[ pack_id ].items ) do
		if v.type == "vinyl" then
			REGISTERED_ITEMS[ v.type ].rewardPlayer_func( player, v.params, v.cost, data )
		else
			REGISTERED_ITEMS[ v.type ].rewardPlayer_func( player, v.params )
		end
	end

	-- Получали подарок, зануляем
	if is_gift_reward then
		player:SetCurrentGiftReward( false )
	else
		player:SetPackState( pack_id, PACK_STATE_TAKE )
		TryTakeGift( player, {
			pack_data = player:GetPackData(),
		} )
	end
end
addEvent( "onServerPlayerTakeReward", true )
addEventHandler( "onServerPlayerTakeReward", resourceRoot, onServerPlayerTakeReward_handler )

function TryTakeGift( player, data )
	if player:GetCurrentGiftReward() then
		triggerClientEvent( player, "onClientShowRewardDoubleMayhem", resourceRoot, "gift", data )
		return true
	end
	return false
end

-- Тестирование
if SERVER_NUMBER > 100 then
	addCommandHandler( "dm_show", function( player )
		onPlayerReadyToPlay_handler( player )
	end )

	addCommandHandler( "dm_test", function( player )
		local cost = 1
		for k, v in pairs( OFFER_CONFIG.packs ) do
			v.cost = cost
			cost = cost + 1
		end
	end )

    addCommandHandler( "dm_reset", function( player )
		player:ResetOffer()
		player:SetCurrentGiftReward( false )
		player:ShowInfo( "Оффер сброшен" )
	end )
end