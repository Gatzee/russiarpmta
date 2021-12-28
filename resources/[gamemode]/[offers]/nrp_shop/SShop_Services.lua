-- Покупка военника
function onBuyMilitaryTicketRequest_handler( )
	local player = client
	local price, coupon_discount_value = player:GetCostService( 3 )

	if player:HasMilitaryTicket( ) then
		return
	end

	if player:GetDonate( ) >= price then
		local is_on_military = player:IsOnUrgentMilitary( )

		player:EndUrgentMilitary( )
		player:TakeDonate( price, "f4_service", "military_ticket" )
		if coupon_discount_value then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", player, "services" )
		end

		player:InfoWindow( "Военный билет приобретен!" )
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

		triggerEvent( "onPlayerPremium_military", player, price, is_on_military )
		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "military_document" } )
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Military ticket" )
	end
end
addEvent( "onBuyMilitaryTicketRequest", true )
addEventHandler( "onBuyMilitaryTicketRequest", root, onBuyMilitaryTicketRequest_handler )

function onBuyChangeSexRequest_handler( data )
	local player = client
	local price, coupon_discount_value = player:GetCostService( 3 )

	if player:GetPermanentData( "wedding_at_id" ) or player:GetPermanentData( "engaged_at_id" ) then
		return player:InfoWindow( "Нельзя сменить пол если вы женаты/помолвлены." )
	end

	if player:GetDonate( ) >= price then
		local skin_list = SERVICE_SKIN_LIST

		local gender = data[ 1 ]
		local skin = data[ 2 ]

		local new_skin = skin_list[ gender ][ skin ]

		player:GiveSkin( new_skin )

		local skins_list = player:GetSkins( )		
		for sid, model in pairs( skins_list ) do
			if model == new_skin then
				local current_skin = skins_list[ "s1" ]
				skins_list[ "s1" ] = new_skin
				skins_list[ sid ] = current_skin
				break
			end
		end		
		player:SetPermanentData( "skins", skins_list )

		player.model = new_skin

		player:SetDefaultSkin( new_skin )
		player:SetGender( gender )

		player:TakeDonate( price, "f4_service", "gender" )
		if coupon_discount_value then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", player, "services" )
		end

		player:InfoWindow( "Пол успешно изменен!" )
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
		triggerEvent( "onPlayerPremium_sex", player, price )
		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "change_gender" } )
		return true
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Gender" )
	end
end
addEvent( "onBuyChangeSexRequest", true )
addEventHandler( "onBuyChangeSexRequest", root, onBuyChangeSexRequest_handler )

function onBuyNicknameRequest_handler( nickname )
	local player = client
	local price, coupon_discount_value = player:GetCostService( 2 )

	if player:GetDonate() >= price then
		nickname = utf8.gsub(nickname, "Ё", "Е")
		nickname = utf8.gsub(nickname, "ё", "е")
		local success, error = VerifyPlayerName( nickname )
		if not success then
			if error then player:ShowOverlay( OVERLAY_ERROR, { text = error } ) end
			return
		end
		local oldName = player:GetNickName()
		if nickname == oldName then
			player:ShowOverlay( OVERLAY_ERROR, { text = "Имя персонажа уже занято!" } )
			return
		end
		DB:queryAsync(
			function( query, player, nickname )
				local result = query:poll( -1 )
				if #result >= 1 then
					player:ShowOverlay( OVERLAY_ERROR, { text = "Имя персонажа уже занято!" } )
					return
				end
				player:SetNickName( nickname )
				player:SetPermanentData( "nickname", nickname )
				player:UpdateOfflineData( "nickname", nickname )

				player:TakeDonate( price, "f4_service", "nickname" )
				if coupon_discount_value then 
					player:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
					triggerEvent( "onPlayerRequestDonateMenu", player, "services" )
				end

				player:InfoWindow( "Никнейм успешно изменен!" )
				player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
				triggerEvent( "onPlayerPremium_nickname", player, price )
				SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "change_nickname" } )
			end, { player, nickname },
			"SELECT id FROM nrp_players WHERE nickname=?", nickname
		)
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Nickname" )
	end
end
addEvent( "onBuyNicknameRequest", true )
addEventHandler( "onBuyNicknameRequest", root, onBuyNicknameRequest_handler )

--покупка слотов
function onBuySlotRequest_handler()
	local player = client
	
	local car_slot_cost = CalculateSlotCost( player, player:GetPermanentData( "car_slots" ) )
	local cost, coupon_discount_value = player:GetCostWithCouponDiscount( "special_services", car_slot_cost )
	if player:GetDonate( ) >= cost then
		local bought_slots = player:GetPermanentData( "car_slots" )
		bought_slots = bought_slots + 1
		player:SetPermanentData( "car_slots", bought_slots )
		
		player:TakeDonate( cost, "f4_service", "vehicle_slot" )
		if coupon_discount_value then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		end

		player:InfoWindow( "Слот успешно куплен!" )
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
		triggerEvent( "onCarSlotPurchaseSlot", player, cost, bought_slots )

		triggerEvent( "CheckPlayerVehiclesSlots", player )
		player:triggerEvent( "onClientPlayerBuySlot", resourceRoot )
		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "auto_slot" } )

		triggerEvent( "onPlayerSomeDo", player, "bought_garage_slot" ) -- achievements
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Car slot" )
	end
end
addEvent( "onBuySlotRequest", true )
addEventHandler( "onBuySlotRequest", root, onBuySlotRequest_handler )

function onServerBuyJailkeys_handler()
	if not isElement( client ) then return end

	local player = client
	local cost, coupon_discount_value = player:GetCostService( 12 )

	if player:GetDonate( ) >= cost then
		player:TakeDonate( cost, "f4_service", "prison_end" )
		if coupon_discount_value then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		end

		player:InventoryAddItem( IN_JAILKEYS, nil, 1 )

		player:InfoWindow( "Карточка выхода из тюрьмы приобретена!" )
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "prison_end" } )
		triggerEvent( "onServerSericeJailKeysPurchase", player, cost )
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Gender" )
	end
end
addEvent( "onServerBuyJailkeys", true )
addEventHandler( "onServerBuyJailkeys", root, onServerBuyJailkeys_handler )

-- сброс рейтинга
function onBuyRatingResetRequest_handler( )
	local player = client
	local cost, coupon_discount_value = player:GetCostService( 13 )
    
	if player:GetDonate( ) >= cost then
		if player:IsInClan(  ) or player:IsInFaction( ) then
			player:ShowError( "Во время обнуления ты не можешь быть в клане или фракции, выйди из них!" )
			return
		end

		local last_reset = player:GetPermanentData( "last_rating_reset" )
		if last_reset then
			local diff = getRealTimestamp( ) - last_reset
			local three_days = 60 * 60 * 24 * 3
			if diff <= three_days then

				local diff = three_days - diff
				local hours = math.floor( diff / 60 / 60 )
				local minutes = math.floor( diff / 60 - hours * 60 )

				player:ShowError( "Следующее обнуление станет доступным через "..hours..":"..minutes )
				return
			end
		end

		if coupon_discount_value then 
			player:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", player, "services" )
		end

		player:SetSocialRating( 0 )
		player:SetSocialRatingAnchor( 0 )
		player:SetPermanentData( "last_rating_reset", getRealTimestamp( ) )
		player:TakeDonate( cost, "f4_service", "rating_reset" )
		player:InfoWindow( "Рейтинг успешно сброшен!" )
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )
		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = "rating_reset" } )
		triggerEvent( "onSocialRatingResetPurchase", player, cost )
	else
		player:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( player, "onShopNotEnoughHard", player, "Rating reset" )
	end
end
addEvent( "onBuyRatingResetRequest", true )
addEventHandler( "onBuyRatingResetRequest", root, onBuyRatingResetRequest_handler )

function onPlayerTryBuyRemoveDiseases_handler( )
	if not client then
		return
	end

	local cost, coupon_discount_value = client:GetCostService( 14 )
	if client:GetDonate( ) >= cost then
		if coupon_discount_value then
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" )
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		end

		triggerEvent( "onPlayerTreatCompleteViaService", client )

		client:TakeDonate( cost, "f4_service", "disease_treatment" )
		client:InfoWindow( "Вы были полностью вылечены!" )
		client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

		-- analytics
		SendElasticGameEvent( client:GetClientID( ), "f4r_f4_services_purchase", { service = "disease_treatment" } )
		triggerEvent( "onPlayerRemoveDiseasesPurchase", client, cost )
	else
		client:ShowOverlay( OVERLAY_ERROR, { text = "Недостаточно средств!" } )
		triggerClientEvent( client, "onShopNotEnoughHard", client, "Diseases remove" )
	end
end
addEvent( "onPlayerTryBuyRemoveDiseases", true )
addEventHandler( "onPlayerTryBuyRemoveDiseases", resourceRoot, onPlayerTryBuyRemoveDiseases_handler )