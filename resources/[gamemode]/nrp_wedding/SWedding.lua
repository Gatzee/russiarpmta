Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )

MARRY_STAGE_WEDDING = 1
MARRY_STAGE_ENGAGE = 2
MARRY_WEDDED_LIST = {}
MARRY_WEDDED_LIST_NOTIFIED = {}

function SWeddingStart_handler()
	for i, player in pairs( getElementsByType( "player" ) ) do
		player:PreparePlayerInfo()
		checkEngagementTime( player )
	end
end
addEventHandler( "onResourceStart", resourceRoot, SWeddingStart_handler )

addEvent( "onPlayerCompleteLogin" )
addEventHandler( "onPlayerCompleteLogin", root, function()
	source:PreparePlayerInfo()
end )

function onPlayerReadyToPlay_handler()
	checkEngagementTime( source )
end
addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function onPlayerClearCall( player )
	local function clear( player )
		if not isElement( player ) then return end
		if not player:getData( "wedding_in_process" ) then return end
		triggerClientEvent( player, "OnWeddingForceClear", player )
		player:ApplySkins( false, true )
		player:ClearTempData( MARRY_STAGE_WEDDING )
		player:ClearTempData( MARRY_STAGE_ENGAGE )
	end
	if not player or not isElement( player ) then return end
	clear( player )
	clear( player:GetPossiblePartner() )
end

function onPlayerPreLogout_handler()
	onPlayerClearCall( source )
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onWeddingUpdateApartList_handler( player )
	player = isElement( player ) and player or source

	if not player then return outputDebugString( "nrp_wedding: onWeddingUpdateApartList - player is nil", 1 ) end

	local partner_id = player:GetPermanentData( "wedding_at_id" )
	if partner_id then
		local partner = GetPlayer( partner_id )
		if isElement( partner ) and partner:IsInGame( ) then
			local wedded_apartments = player:getData( "apartments" )
			if wedded_apartments then
				partner:SetPrivateData( "wedding_at_apartments_data", wedded_apartments )
			end
		end
	end
end
addEvent( "onWeddingUpdateApartList", true )
addEventHandler( "onWeddingUpdateApartList", root, onWeddingUpdateApartList_handler )

function onWeddingUpdateVipHouseData_handler( player )
	player = isElement( player ) and player or source

	if not player then return outputDebugString( "nrp_wedding: onWeddingUpdateVipHouseData_handler - player is nil", 1 ) end

	local partner_id = player:GetPermanentData( "wedding_at_id" )
	if partner_id then
		local partner = GetPlayer( partner_id )
		if isElement( partner ) and partner:IsInGame( ) then
			local wedded_viphouse_ids = player:getData( "viphouse" )
			if wedded_viphouse_ids then
				local wedding_at_viphouse_data = {}
				for i, hid in ipairs( wedded_viphouse_ids ) do
					table.insert( wedding_at_viphouse_data, { id = hid } )
				end
				partner:SetPrivateData( "wedding_at_viphouse_data", wedding_at_viphouse_data )
			end
		end
	end
end
addEvent( "onWeddingUpdateVipHouseData", true )
addEventHandler( "onWeddingUpdateVipHouseData", root, onWeddingUpdateVipHouseData_handler )

function onWeddingPlayerWeddingShopBuyItem_handler( key, isF4 )
	if not client then return end
	if not WEDDING_SHOP_PARTS[key] or ( not WEDDING_SHOP_PARTS[key].hard_cost and not WEDDING_SHOP_PARTS[key].soft_cost ) then return end
	if WEDDING_SHOP_PARTS[key].level then
		if WEDDING_SHOP_PARTS[key].level > client:GetLevel() then
			return client:ShowInfo( "Требуется уровень: " .. WEDDING_SHOP_PARTS[key].level )
		end
	end
	if key == "wedding" or key == "divorce" then
		if key == "divorce" then
			if not client:GetPermanentData( "wedding_at_id" ) or client:GetPermanentData( "wedding_at_id" ) == "" then
				return client:ShowInfo( "Вы не в браке" )
			end
		end
		if key == "wedding" then
			if client:GetPermanentData( "wedding_at_id" ) then
				return client:ShowInfo( "Вы уже в браке" )
			end
			if client:GetPermanentData( "engaged_at_id" ) then
				return client:ShowInfo( "Вы уже помолвлены" )
			end
			if client:getData( "engage_item_applyed" ) then
				return client:ShowInfo( "Нельзя купить пока активна Свадебная коробка" )
			end
		end
		local reg_date = client:GetPermanentData( "reg_date" ) or getRealTime().timestamp
		local spend = getRealTime().timestamp - reg_date
		triggerEvent( "onWeddingDev2dev_item_buying", client, key, spend )
	end
	if WEDDING_SHOP_PARTS[key].max then
		if client:InventoryGetItemCount( WEDDING_SHOP_PARTS[key].node ) >= WEDDING_SHOP_PARTS[key].max then
			return client:ShowError( "Нельзя купить \"" .. WEDDING_SHOP_PARTS[key].name .. "\" больше " .. WEDDING_SHOP_PARTS[key].max .. " ед." )
		end
	end
	local dev2dev_cost, dev2dev_currency
	if WEDDING_SHOP_PARTS[key].hard_cost then
		if client:GetDonate( ) < WEDDING_SHOP_PARTS[key].hard_cost then
    	    client:ShowInfo( "Недостаточно донат валюты" )
    	    return
		end

		local cost, coupon_discount_value = WEDDING_SHOP_PARTS[key].hard_cost, false
		if key == "wedding" then
			cost, coupon_discount_value = client:GetCostService( 10 )
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		elseif key == "divorce" then
			cost, coupon_discount_value = client:GetCostService( 11 )
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		end

		if client:TakeDonate( cost, "wedding_shop", key ) then
			if coupon_discount_value then client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) end

			client:InventoryAddItem( WEDDING_SHOP_PARTS[key].node, nil, WEDDING_SHOP_PARTS[key].buy_count or 1 )
			client:ShowInfo( "Вы купили " .. WEDDING_SHOP_PARTS[key].name )
			dev2dev_cost, dev2dev_currency = WEDDING_SHOP_PARTS[key].hard_cost, "hard"
		end
	elseif WEDDING_SHOP_PARTS[key].soft_cost then
		if client:GetMoney( ) < WEDDING_SHOP_PARTS[key].soft_cost then
    	    client:ShowInfo( "Недостаточно денег" )
    	    return
		end
		if client:TakeMoney( WEDDING_SHOP_PARTS[key].soft_cost, "wedding_shop_" .. key ) then
			client:InventoryAddItem( WEDDING_SHOP_PARTS[key].node, nil, WEDDING_SHOP_PARTS[key].buy_count or 1 )
			client:ShowInfo( "Вы купили " .. WEDDING_SHOP_PARTS[key].name )
			dev2dev_cost, dev2dev_currency = WEDDING_SHOP_PARTS[key].soft_cost, "soft"
		end
	end
	if key ~= "wedding" and key ~= "divorce" then
		triggerEvent( "onWeddingDev2dev_gift_purchase", client, WEDDING_SHOP_PARTS[key].id, WEDDING_SHOP_PARTS[key].name, dev2dev_cost, dev2dev_currency )
	end

	if key == "wedding" then
		SendElasticGameEvent( client:GetClientID( ), "f4r_f4_services_purchase", { service = "wedding_box" } )
	elseif key == "divorce" then
		SendElasticGameEvent( client:GetClientID( ), "f4r_f4_services_purchase", { service = "divorce_papers" } )
	end
end
addEvent( "onWeddingPlayerWeddingShopBuyItem", true )
addEventHandler( "onWeddingPlayerWeddingShopBuyItem", resourceRoot, onWeddingPlayerWeddingShopBuyItem_handler )

function onPlayerWeddingDivorceCall_handler()
	--Запрос на развод
	triggerClientEvent( source, "OnWeddingDivorceApply", source )
end
addEvent( "onPlayerWeddingDivorceCall", true )
addEventHandler( "onPlayerWeddingDivorceCall", root, onPlayerWeddingDivorceCall_handler )

function onPlayerWeddingEngageCall_handler()
	--Запись в базу, на случай, если игрок вылетел, что бы при входе в игру была возможность начать помолвку
	source:OnApplyStartEngage()
end
addEvent( "onPlayerWeddingEngageCall", true )
addEventHandler( "onPlayerWeddingEngageCall", root, onPlayerWeddingEngageCall_handler )

function onWeddingPlayerWannaDivorce_handler()
	client:OnDivorceSuccess()

	local dcount = client:GetPermanentData( "divorce_count" ) or 0
	dcount = dcount + 1
	client:SetPermanentData( "wedding_count", dcount )

	triggerEvent( "onWeddingDev2dev_divorce_make", client, dcount )
end
addEvent( "onWeddingPlayerWannaDivorce", true )
addEventHandler( "onWeddingPlayerWannaDivorce", resourceRoot, onWeddingPlayerWannaDivorce_handler )

function onWeddingPlayerDivorceCanceled_handler()
	client:InventoryAddItem( WEDDING_SHOP_PARTS["divorce"].node, nil, 1 )
end
addEvent( "onWeddingPlayerDivorceCanceled", true )
addEventHandler( "onWeddingPlayerDivorceCanceled", resourceRoot, onWeddingPlayerDivorceCanceled_handler )

function onWeddingPlayerWantToTransferItemTo_handler( target, item )
	if target:GetPermanentData( "wedding_at_id" ) then
		if source.dimension ~= 1 or source.interior ~= 1 then
			source:ShowError( "Нужно быть в церкви." )
			return
		end
		if not WEDDING_SHOP_ITEM_NAMES_BY_NODES[item] then
			source:ShowError( "Этот итем не в списке доступных для передачи." )
			return
		end
		if item == IN_WEDDING_CHOCO then

			source:InventoryRemoveItem( item, 1 )
			target:InventoryAddItem( item, nil, 1 )
			source:ShowInfo( "Вы подарили " .. WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].name .. " игроку " .. target:GetNickName() )
			target:ShowInfo( source:GetNickName() .. " подарил вам " .. WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].name .. "." )

		else
			if target:IsOwnedAccessory( WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].id ) then
				source:ShowError( "У " ..target:GetNickName() .. " уже есть этот аксессуар." )
				return
			end
	
			source:InventoryRemoveItem( item, 1 )
			source:ShowInfo( "Вы подарили " .. WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].name .. " игроку " .. target:GetNickName() )

			target:ShowInfo( source:GetNickName() .. " подарил вам " .. WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].name .. ".\nДобавлен в гардероб." )
			target:AddOwnedAccessory( WEDDING_SHOP_ITEM_NAMES_BY_NODES[item].id )
		end
	else
		source:ShowInfo( target:GetNickName() .. " ещё не состоит в браке" )
	end
end
addEvent( "onWeddingPlayerWantToTransferItemTo", true )
addEventHandler( "onWeddingPlayerWantToTransferItemTo", root, onWeddingPlayerWantToTransferItemTo_handler )


------------------
--Часть помолвки--
------------------

--Могут ли инициатор и предполагаемый партнёр начать помолвку
function IsPlayerReadyToStartEngage_handler( partner )
	if partner and isElement( partner ) then
		
		if not source:GetPermanentData( "engage_item_applyed" ) then
			source:ShowInfo( "Сначала вам нужно купить услугу в магазине." )
			return
		end

		local wedding_at_id = partner:GetPermanentData( "wedding_at_id" )
		local engaged_at_id = partner:GetPermanentData( "engaged_at_id" )
		if wedding_at_id or engaged_at_id then
			partner:ShowInfo( "Вы не можете начать помолвку т.к. партнёр уже\n " .. ( partner:GetGender() == 0 and "женат" or "замужем" ) ..  " или начал помолвку." )
			return false
		end
	
		if partner:getData( "jailed" ) then
			partner:ShowInfo( "Вы не можете начать помолвку, т.к. партнёр в тюрьме." )
			return false
		end
	
		if partner:isDead() then
			partner:ShowInfo( "Вы не можете начать помолвку, т.к. партнёр на том свете." )
			return false
		end
	
		if partner:IsOnFactionDuty() then
			partner:ShowInfo( "Вы не можете начать помолвку, т.к. партнёр на смене фракции." )
			return false
		end

		--Отправляем подтверждение помолвки для инициатора
		triggerClientEvent( source, "OnWeddingIsPlayerReadyToStartEngage", source, true, true, partner )
	end
end
addEvent( "OnWeddingIsPlayerReadyToStartEngage", true )
addEventHandler( "OnWeddingIsPlayerReadyToStartEngage", root, IsPlayerReadyToStartEngage_handler )

--Инициатор готов начать помолвку, запрашиваем согласие у предполагаемого партнёра
function OnRootReadyToStartEngage_handler( possible_partner )
	if not possible_partner or not isElement( possible_partner ) then
		onPlayerClearCall( client )
		client:ShowInfo( "Не найден партнёр" )
		return
	end

	if not client:IsOnSkin() then
		client:ShowInfo( "Вы должны быть в свадебном костюме" )
		return
	end

	--Анимация предложения
	triggerClientEvent( getElementsWithinRange( client:getPosition(), 30, "player" ), "OnWeddingPlayerCallSeatAnimation", resourceRoot, client, true )
	local x,y = getElementPosition( client )
	local tx,ty = getElementPosition( possible_partner )
	client:setRotation( 0, 0, FindRotation( x, y, tx, ty ) )

	setTimer( function( client )
		if not isElement( client ) then return end
		triggerClientEvent( possible_partner, "OnWeddingIsPlayerReadyToStartEngage", possible_partner, true, false, client )
	end, 2000, 1, client )

	triggerEvent( "onWeddingDev2dev_marry_offer", client, 0, client:GetPermanentData( "wedding_count" ) or 0 )
	triggerEvent( "onWeddingDev2dev_marry_offer", possible_partner, 0, possible_partner:GetPermanentData( "wedding_count" ) or 0 )
end
addEvent( "OnWeddingRootReadyToStartEngage", true )
addEventHandler( "OnWeddingRootReadyToStartEngage", resourceRoot, OnRootReadyToStartEngage_handler )

--Игрок отказался помолвки
function OnPlayerCancelStartEngage_handler( possible_partner )
	if possible_partner then --Отказался возможный партнёр
		possible_partner:ShowInfo( client:GetNickName() .. " отказался от предложения" )
		triggerClientEvent( getElementsWithinRange( possible_partner:getPosition(), 30, "player" ), "OnWeddingPlayerCallSeatAnimation", resourceRoot, possible_partner, false )
	else
		triggerClientEvent( getElementsWithinRange( client:getPosition(), 30, "player" ), "OnWeddingPlayerCallSeatAnimation", resourceRoot, client, false )
	end
end
addEvent( "OnWeddingPlayerCancelStartEngage", true )
addEventHandler( "OnWeddingPlayerCancelStartEngage", resourceRoot, OnPlayerCancelStartEngage_handler )

--ПОМОЛВКА
function OnPlayerReadyStartEngage_handler( possible_partner )
	if possible_partner and isElement( possible_partner ) then
		local client_id, possible_partner_id = client:GetID(), possible_partner:GetID()

		triggerClientEvent( getElementsWithinRange( possible_partner:getPosition(), 30, "player" ), "OnWeddingPlayerCallSeatAnimation", resourceRoot, possible_partner, true, 3 )

		for i, v in pairs( { client, possible_partner } ) do
			v:ShowInfo( "Вы обручены, для завершения бракосочетания, вам необходимо пройти свадебный обряд.\nДля этого посетите церковь." )
			triggerClientEvent( v, "CWeddingCongratSetState", v, true )
		end
		client:ApplySkins( true )
		client:WriteDataOnEngageSuccess( possible_partner )
		--TODO: не возвращает верный value если ресурс был перезапущен, заменить SetPrivateData
		client:SetPrivateData( "engage_possible_partner", possible_partner )
		possible_partner:WriteDataOnEngageSuccess( client )
		possible_partner:SetPrivateData( "engage_possible_partner", client )

		local timestamp = getRealTime().timestamp
		client:SetPermanentData( "engaged_timestamp", timestamp )
		possible_partner:SetPermanentData( "engaged_timestamp", timestamp )
	else
		onPlayerClearCall( client )
	end
end
addEvent( "OnWeddingPlayerReadyStartEngage", true )
addEventHandler( "OnWeddingPlayerReadyStartEngage", resourceRoot, OnPlayerReadyStartEngage_handler )


-----------------
--Часть свадьбы--
-----------------

--Запрос на начало диалога у батюшки
function onPlayerWantStartWedding_handler()
	client:CloseInfo( )

	triggerEvent( "onPlayerSomeDo", client, "church_wedding" ) -- achievements

	local engaged_at_id = client:GetPermanentData( "engaged_at_id" )
	if engaged_at_id then
		local partner, success = client:IsPlayerCanStartWedding( engaged_at_id )
		if partner then
			if success then
				--Запуск диалогов свадьбы
				for i, v in pairs( { client, partner } ) do
					triggerClientEvent( v, "OnWeddingPlayerStartWedding", v, i )
					triggerEvent( "onWeddingDev2dev_marry_offer", v, 1, v:GetPermanentData( "wedding_count" ) or 0 )
					v:SetPrivateData( "wedding_in_process", true )
				end
			else
				triggerClientEvent( client, "CWeddingShopSetState", client, true )
			end
		else
			onPlayerClearCall( client )
		end
	else
		triggerClientEvent( client, "CWeddingShopSetState", client, true )
	end
end
addEvent( "OnWeddingPlayerWantStartWedding", true )
addEventHandler( "OnWeddingPlayerWantStartWedding", resourceRoot, onPlayerWantStartWedding_handler )

--Окончание первой части диалога
function OnWeddingPlayerDialogStartPartEnds_handler()
	local partner = client:IsPlayerPartnerFinishStartScene()
	if client:getData( "wedding_finish_start_scene" ) then return false; end
	client:setData( "wedding_finish_start_scene", true, false )
	if partner and isElement( partner ) then
		triggerClientEvent( client, "OnWeddingshowPlayerAcceptWindow", client, true, { client:GetGender(), client:GetNickName() }, { partner:GetGender(), partner:GetNickName() } )
		triggerClientEvent( partner, "OnWeddingshowPlayerAcceptWindow", partner, true, { partner:GetGender(), partner:GetNickName() }, { client:GetGender(), client:GetNickName() } )
	end
end
addEvent( "OnWeddingPlayerDialogStartPartEnds", true )
addEventHandler( "OnWeddingPlayerDialogStartPartEnds", resourceRoot, OnWeddingPlayerDialogStartPartEnds_handler )

--Результат из окна согласия в диалоге с батюшкой
function onPlayerAcceptWindowResult_handler( result )
	local partner, accepted = client:IsPlayerPartnerAcceptEndWeddingOffer()
	if not partner and not isElement( partner ) then
		onPlayerClearCall( client )
		return client:ShowInfo( "Партнёр не найден." )
	end
	if not partner and not accepted then return end

	client:SetPrivateData( "wedding_accept_finish", result )
	if result then

		if accepted then
			client:WriteDataOnWeddingSuccess( partner )
			partner:WriteDataOnWeddingSuccess( client )
			for i, v in pairs( { client, partner } ) do
				triggerClientEvent( v, "OnWeddingPlayerWeddingSuccess", v )

				local vcount = v:GetPermanentData( "wedding_count" ) or 0
				vcount = vcount + 1
				v:SetPermanentData( "wedding_count", vcount )

				triggerEvent( "onWeddingDev2dev_marry_offer", v, 1, vcount )
				v:ClearTempData( MARRY_STAGE_WEDDING )

				--Сброс engage_item_applyed для игрока, который применил, только если свадьба завершена, иначе не удалять применённый итем свадьбы, cuz игроки долбаёбы
				if v:GetPermanentData( "engage_item_applyed" ) then
					v:SetPermanentData( "engage_item_applyed", false )
					v:SetPrivateData( "engage_item_applyed", nil )
				end
				v:SetPermanentData( "wedding_last_tick", getRealTime().timestamp )

				v:SetPrivateData( "wedding_in_process", false )

				triggerEvent( "onWeddingDev2dev_marry_offer", v, 2, v:GetPermanentData( "wedding_count" ) or 0 )
			end

			MARRY_WEDDED_LIST[client] = partner
			MARRY_WEDDED_LIST_NOTIFIED[partner] = nil
			MARRY_WEDDED_LIST_NOTIFIED[client] = nil
		end

	else --Отказ игрока

		for i, v in pairs( { client, partner } ) do
			triggerClientEvent( v, "OnWeddingPlayerWeddingOfferCanceled", v )
			v:RestoreDataOnWeddingFault()
			v:ClearTempData( MARRY_STAGE_WEDDING )
			if not v:getData( "engage_item_applyed" ) then
				v:ApplySkins( false, true )
				v:SetPrivateData( "wedding_in_process", false )
			end
		end
		client:ShowInfo( "Вы отказались." )
		partner:ShowInfo( "Партнёр отказался." )

	end
end
addEvent( "OnWeddingPlayerAcceptWindowResult", true )
addEventHandler( "OnWeddingPlayerAcceptWindowResult", resourceRoot, onPlayerAcceptWindowResult_handler )

function OnWeddingPlayerWantToKiss_handler( target )
	if not target or not isElement( target ) then return end
	if source:getData( "wedding_at_player" ) == target then
		if not source:getData( "wedding_last_kiss" ) or getRealTimestamp() - source:getData( "wedding_last_kiss" ) >= 8 then
			if getDistanceBetweenPoints3D( source:getPosition(), target:getPosition() ) < 0.8 then
				source:setData( "wedding_last_kiss", getRealTimestamp( ), false )

				--Поворот к партнёру
				local source_pos = source.position
				local target_pos = target.position
				local x,y = getElementPosition( source )
				local tx,ty = getElementPosition( target )
				local rotz = FindRotation( x, y, tx, ty )
				source:setRotation( 0, 0, rotz )
				target:setRotation( 0, 0, rotz - 180 )
				source:setPosition( target.position + target.matrix.forward * 0.85 )

				triggerClientEvent( getElementsWithinRange( source:getPosition(), 30, "player" ), "OnWeddingPlayerCallKissAnimation", resourceRoot, { male = source, female = target } )


				setTimer(function( source, target, source_pos, target_pos )
					if isElement( source ) then
						source.position = source_pos
					end

					if isElement( target ) then
						target.position = target_pos
					end
				end, 6000, 1, source, target, source_pos, target_pos)
			end
		end
	end
end
addEvent( "OnWeddingPlayerWantToKiss", false )
addEventHandler( "OnWeddingPlayerWantToKiss", root, OnWeddingPlayerWantToKiss_handler )

function weddingCheckDistToExp( player, partner )
	if not isElement( player ) then
		MARRY_WEDDED_LIST[player] = nil
		MARRY_WEDDED_LIST_NOTIFIED[player] = nil
		return
	end
	if not isElement( partner ) then
		MARRY_WEDDED_LIST[partner] = nil
		MARRY_WEDDED_LIST[player] = nil
		MARRY_WEDDED_LIST_NOTIFIED[partner] = nil
		MARRY_WEDDED_LIST_NOTIFIED[player] = nil
		return
	end
	if MARRY_WEDDED_LIST_NOTIFIED[player] and not MARRY_WEDDED_LIST_NOTIFIED[player].state and getDistanceBetweenPoints3D( partner.position, player.position ) <= WEDDING_EXP_BOOST_DISTANCE and partner.dimension == player.dimension and partner.interior == player.interior then
		MARRY_WEDDED_LIST_NOTIFIED[player].state = true
		MARRY_WEDDED_LIST_NOTIFIED[partner].state = true

		player:ShowInfo( "Ваш партнер рядом вы получаете на\n" .. WEDDING_EXP_BOOST .. "% опыта больше.")
		partner:ShowInfo( "Ваш партнер рядом вы получаете на\n" .. WEDDING_EXP_BOOST .. "% опыта больше.")
	elseif MARRY_WEDDED_LIST_NOTIFIED[player] and MARRY_WEDDED_LIST_NOTIFIED[player].state and (getDistanceBetweenPoints3D( partner.position, player.position ) > WEDDING_EXP_BOOST_DISTANCE or partner.dimension ~= player.dimension or partner.interior ~= player.interior) then
		MARRY_WEDDED_LIST_NOTIFIED[player].state = false
		MARRY_WEDDED_LIST_NOTIFIED[partner].state = false

		player:ShowInfo( "Вы слишком далеко от партнера, получение опыта снижено на " .. WEDDING_EXP_BOOST .. "%")
		partner:ShowInfo( "Вы слишком далеко от партнера, получение опыта снижено на " .. WEDDING_EXP_BOOST .. "%")
	end
end

setTimer( function( )
	if not WEDDING_EXP_BOOST_ENABLED then return end
	for player, partner in pairs( MARRY_WEDDED_LIST ) do
		weddingCheckDistToExp( player, partner )
	end
end, 10*1000, 0 )

function checkEngagementTime( player, secondCall ) 
	local engaged_timestamp = player:GetPermanentData( "engaged_timestamp" ) or 0
	local isWedded = player:GetPermanentData( "wedding_at_id" )
	if isWedded == 0 then isWedded = nil end
	if isWedded then return end
	--172800 это 48 часов
	if engaged_timestamp + 172800 < getRealTime().timestamp and player:GetPermanentData( "engaged_at_id" ) then 
		local partner = GetPlayer( player:GetPermanentData( "engaged_at_id" ) )
		player:ShowInfo( "За 2 дня с момента помолвки, вы не смогли пройти свадебный обряд, теперь вы свободны." )
		
		if partner and not secondCall then 
			checkEngagementTime( partner, true ) 
		end
		
		player:ApplySkins( false, true )
		weddingClear( player )
	else
		local engaged_at_id = player:GetPermanentData( "engaged_at_id" )
		local engage_item_applyed = player:GetPermanentData( "engage_item_applyed" )
		if engaged_at_id then
			local engaged_at_player = GetPlayer( engaged_at_id )
			if isElement( engaged_at_player ) then
				player:SetPrivateData( "engaged_at_player", engaged_at_player )
				player:SetPrivateData( "engaged_at_id", engaged_at_id )
				player:SetPrivateData( "engage_possible_partner", engaged_at_player )
				player:ApplySkins( true )
				player:ShowInfo( "Вы обручены, для завершения бракосочетания, вам необходимо пройти свадебный обряд.\nДля этого посетите церковь." )

				engaged_at_player:SetPrivateData( "engaged_at_player", player )
				engaged_at_player:SetPrivateData( "engaged_at_id", player:GetID() )
				engaged_at_player:SetPrivateData( "engage_possible_partner", player )
				engaged_at_player:ApplySkins( true )
				engaged_at_player:ShowInfo( "Вы обручены, для завершения бракосочетания, вам необходимо пройти свадебный обряд.\nДля этого посетите церковь." )
			end
		elseif engage_item_applyed then
			-- Не сбрасывать итем помолвки при возможном краше клиента
			setTimer( function( player )
				if not isElement( player ) then return end
				player:OnApplyStartEngage()
			end, 3000, 1, player )
		end
	end
end

function weddingClear( player )
	onPlayerClearCall( player )

	local removeData = { 
		"engaged_at_player",
		"engaged_at_id",
		"engaged_timestamp",
		"engage_item_applyed",
		"engage_possible_partner",

		"wedding_at_player",
		"wedding_at_id",
		"wedding_last_tick",
		"wedding_at_apartments_data",
		"wedding_at_viphouse_data",
		"wedding_in_process",
		"wedding_accept_finish",
		"wedding_at_apart_slots",

	}
	for i,v in pairs( removeData ) do 
		player:SetPrivateData( v, nil )
		player:SetPermanentData( v, nil )
	end
end

function UpdateParkingGarageMarkerWeddingPartner( player )
	player:PreparePlayerInfo( )
	triggerEvent( "UpdateParkingMarkerWeddingPartner", player )
	triggerEvent( "UpdateGarageMarkerWeddingPartner", player )
end

function onWeddingEndSuccessDialog_handler( )
	UpdateParkingGarageMarkerWeddingPartner( client )
end
addEvent( "onWeddingEndSuccessDialog", true )
addEventHandler( "onWeddingEndSuccessDialog", resourceRoot, onWeddingEndSuccessDialog_handler )