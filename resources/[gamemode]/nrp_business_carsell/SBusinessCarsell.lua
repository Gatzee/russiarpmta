loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SInterior" )
Extend( "SBusiness" )
Extend( "ShClans" )

CARSELLS = {}

function onResourceStart()
	for i, data in pairs(BUSINESS_ELEMENTS) do
		if data.business_id == 4 then
			if data.building_type == "pay" then
				Carsell_create(data)
			elseif data.building_type == "outside_vehicle" then
				Carsell_create_vehicles(data)
			end
		end
	end
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart,true,"high-1")

addEvent("onCarsellVehiclePurchase", true)
function onCarsellVehiclePurchase(model, variant, color, spawn_pos)
	local player = client or source
	if not player then return end

	local vehicle_data = VEHICLE_CONFIG[model]
	if not vehicle_data then
		player:ShowError("Данный транспорт не найден в ассортименте")
		return
	end

	local variant_data = vehicle_data.variants[variant]
	if not variant_data then
		player:ShowError("Данный вариант транспорта не найден в ассортименте")
		return
	end

	if not variant_data.cost then
		player:ShowError("Не найдена цена для данного транспорта")
		return
	end

	if not vehicle_data.sell or not vehicle_data.marketlist then
		WriteLog("auto_shop_bug", "%s попытался купить непродаваемый транспорт: %s (вариант %s) за %s, скидка: %s", player, vehicle_data.model.."(ID:"..model..")", variant, variant_data.cost, discount or false)
		return
	end

	local discounted_f4_price = exports.nrp_shop:GetOfferDiscountPriceForModel( "discounts", player, model, variant )
	if discounted_f4_price then
		variant_data = table.copy( variant_data )
		variant_data.cost = discounted_f4_price
	end

	if vehicle_data.blocked then
		if vehicle_data.blocked.fServerCheck and not vehicle_data.blocked.fServerCheck( player ) then
			player:ShowError("Данный автомобиль недоступен для покупки")
			return
		end
	end

	if vehicle_data.premium and not player:IsPremiumActive( ) then
		player:ShowError("Данный автомобиль доступен только с премиумом")
		return
	end

	-- Поддержка квеста для сегмента юзеров
	local quests = player:getData( "quests" ) or { }
	local is_quest = quests and quests.start == "alexander_get_vehicle"

	if not vehicle_data.is_moto and not is_quest and not player:HasFreeVehicleSlot( ) then
		player:ShowError("У вас нет свободных слотов под новый транспорт")
		return
	end

	local discount = not vehicle_data.is_moto and player:GetAllVehiclesDiscount( )
	local cost = discount and variant_data.cost * ( 1 - discount.percentage / 100 ) or variant_data.cost
	local pTempDiscount = player:GetPermanentData( "temp_vehicle_discount" )

	if pTempDiscount and pTempDiscount.timestamp > getRealTimestamp( )
	and model == pTempDiscount.model and variant == ( pTempDiscount.variant or 1 ) then
		cost = cost * ( 1 - pTempDiscount.percent / 100 )
	end

	local pSales = GetActualSales()
	local veh_sale = pSales[model]
	if veh_sale and veh_sale.timestamp >= getRealTimestamp( ) then
		cost = cost - cost * veh_sale.percent
	end

	if vehicle_data.is_moto then
		cost = cost * ( 1 - player:GetClanBuffValue( CLAN_UPGRADE_MOTO_DISCOUNT ) / 100 )
	end

	cost = math.ceil( cost - 0.5 )

	if is_quest and model == 517 then cost = 0 end
	
	local carname = vehicle_data.model.."(ID:"..model..")"
	-- Можно покупать на любом уровне
	local is_soft_purchase = true or not variant_data.level or player:GetLevel() >= variant_data.level

	if is_soft_purchase then
		if player:TakeMoney(cost, "vehicle_purchase") then
			WriteLog("money/purchase", "[Покупка автомобиля] %s приобрёл автомобиль %s (вариант %s) за %s, скидка: %s", player, carname, variant, cost, discount or false)
		else
			player:EnoughMoneyOffer( "Vehicle purchase", cost, "onCarsellVehiclePurchase", player, model, variant, color, spawn_pos )
			return
		end
	else
		cost = math.floor( cost / 1000 * CONST_COST_DONATE_MUL )

		if player:TakeDonate(cost, "vehicle_purchase") then
			WriteLog("money/purchase", "[Открытие автомобиля] %s приобрёл автомобиль %s (вариант %s) за %s, скидка: %s", player, carname, variant, cost, discount or false)
		else
			player:ErrorWindow( "Недостаточно средств для покупки транспорта" )
			return
		end
	end
	triggerClientEvent(player, "Carsell_ShowUI", resourceRoot, nil)
	--player:SetFirstCar( false )

	player:ParkedVehicles()

	player:SetPermanentData( "apartments_info", true )

	spawnVehicle(player, {model = model, variant = variant, color = color, position = spawn_pos, cost = cost, is_soft_purchase = is_soft_purchase, is_quest = is_quest})
end
addEventHandler("onCarsellVehiclePurchase", resourceRoot, onCarsellVehiclePurchase)

function spawnVehicle(player, data)
	local rows, attempts_real, max_rows, max_attempts = 0, 0, 30, 30*5
	-- Начальная точка спавна. Поменять на принадлежащие автосалону
	local spawn_position = Vector3(unpack(data.position))
	while isAnythingWithinRange(spawn_position, 4) do
		rows, attempts_real = rows + 1, attempts_real + 1
		spawn_position.x = spawn_position.x - 2
		if rows > max_rows then
			spawn_position.x = -340.432
			spawn_position.z = spawn_position.z + 2
			rows = 0
		end
		if attempts_real > max_attempts then
			break
		end
	end
	local vecRotation	= Vector3(0, 0, 0)
	local aColor		= {hex2rgb(data.color)}
	local sOwnerPID		= "p:" .. player:GetUserID()
	local pRow	= {
		model 		= data.model;
		variant		= data.variant;
		x			= spawn_position.x;
		y			= spawn_position.y + 860;
		z			= spawn_position.z;
		rx			= vecRotation.x;
		ry			= vecRotation.y;
		rz			= vecRotation.z;
		owner_pid	= sOwnerPID;
		color		= aColor;
	}

	if data.is_quest then
		pRow.x, pRow.y, pRow.z = 1801.338, 236.817 + 860, 61.213
		pRow.rx, pRow.ry, pRow.rz = 0, 0, 0
	end

	exports.nrp_vehicle:AddVehicle( pRow, true, "OnCarsellVehicleAdded", { player = player, cost = data.cost, is_soft_purchase = is_soft_purchase, is_quest = data.is_quest } ) --Vehicle(data.model, spawn_position, vecRotation) --call --TODO g_pGame:GetVehicleManager():Create( pRow );
end

function OnVehicleAdded_handler( vehicle, data )
	local player = data.player
	if isElement( vehicle ) and isElement( player ) then
		local sOwnerPID		= "p:" .. data.player:GetUserID()

		vehicle.locked = true
		vehicle.engineState = true
		vehicle:SetFuel("full")
		setTimer(
			function( )
				data.player:warpIntoVehicle(vehicle, 0)
				data.player.cameraTarget = player
			end,
		750, 1 )

		if data.is_quest then
			player.cameraTarget = player
			vehicle.dimension = player.dimension
			--vehicle:FixWheels( )
			triggerClientEvent( player, "onClientPlayerBuyQuestVehicle", player, vehicle )
		else
			setTimer( function( )
				player:warpIntoVehicle(vehicle, 0)
				player.cameraTarget = player
				--vehicle:FixWheels( )
			end, 750, 1 )
		end

		vehicle:SetPermanentData("showroom_cost", data.cost)
		vehicle:SetPermanentData("showroom_date", getRealTime().timestamp)
		vehicle:SetPermanentData("first_owner", sOwnerPID)

		triggerEvent( "onPlayerBuyCar", player, vehicle, data.cost, data.is_soft_purchase )

		if not VEHICLE_CONFIG[ vehicle.model ].is_moto then
			player:ResetAllVehiclesDiscount( )
		end
	end
end
addEvent("OnCarsellVehicleAdded", true)
addEventHandler("OnCarsellVehicleAdded", resourceRoot, OnVehicleAdded_handler)

function Carsell_create(config)
	config.accepted_elements = { player = true }
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"
	config.radius = 2
	config.marker_text = config.marker_text or "Автосалон"
	config.y = config.y + 860
	local carsell = TeleportPoint(config)
	if config.marker_image ~= false then
		carsell:SetImage( { config.marker_image or "img/green.png", 255, 255, 255, 255, 1.5 } )
	end
	carsell.element:setData( "material", true, false )
    carsell:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )
	carsell.element:setData("ignore_dist", true)
	carsell.element:setData("assortment_id",config.data.assortment, false)
	carsell.element:setData("veh_spot",config.data.veh_spot or {-379.001, -892.832 + 860, 20.623, 0}, false)
	carsell.element:setData("veh_spawn",config.data.veh_spawn, false)
	carsell.marker:setColor( 0, 255, 0, 40 )

	if config.blip then
		carsell.elements = {}
		carsell.elements.blip = createBlipAttachedTo( carsell.marker, config.blip, 2, 255, 0, 0, 255, 0, 300 )
	end

	carsell.PreJoin = function( self, player )
		if player:GetBlockInteriorInteraction() then
			player:ShowInfo( "Вы не можете войти во время задания" )
			return false
		end
		return true
	end

	carsell.PostJoin = function(carsell, player)
		local assortment_id = carsell.element:getData( "assortment_id" )
		local have_slots = exports.nrp_apartment:GetPlayerHaveVehiclesSlots( player )		
		local cars_count = #player:GetVehicles( )

		triggerClientEvent(
			player, "Carsell_ShowUI", resourceRoot,
			true,
			{
				temp_discount   = player:GetPermanentData( "temp_vehicle_discount" ),
				sales           = GetActualSales( ),
				veh_spawn       = carsell.element:getData( "veh_spawn" ),
				discount        = assortment_id < 5 and player:GetAllVehiclesDiscount( ),
				assortment_id   = assortment_id,
				veh_spot        = carsell.element:getData( "veh_spot" ),
				apartments_info = player:GetPermanentData( "apartments_info" ),
				have_slots      = have_slots,
				free_slots      = have_slots - cars_count,
			}
		)
		player:CompleteDailyQuest( "np_visit_car_showroom" )

		triggerEvent( "onPlayerCarsellOpen", player, assortment_id )
	end
	carsell.PostLeave = function(carsell, player) triggerClientEvent(player, "Carsell_ShowUI", resourceRoot, nil) end

	table.insert(CARSELLS, carsell)
end

function GetActualSales()
	local db_result = MariaGet("vehicle_sales")
	local result = db_result and fromJSON( db_result ) or {}

	local output = {}

	for k,v in pairs(result) do
		if tonumber(k) then
			if v.timestamp > getRealTime().timestamp then
				v.percent = v.percent/100
				output[tonumber(k)] = v
			end
		end
	end

	return output
end

--Offers analytics
function onSlotOfferShow_handler( )
	local player = client or source

	SendElasticGameEvent( player:GetClientID( ), "show_offer_slot", 
				{ 
					name 		= tostring( player:GetNickName( ) ),
				} )
end
addEvent( "onSlotOfferShow", true )
addEventHandler( "onSlotOfferShow", resourceRoot, onSlotOfferShow_handler )

function onCarSellSlotBuy_handler( )
	local player = client or source
	triggerEvent( "onPlayerRequestDonateMenu", player, "services" )

	SendElasticGameEvent( player:GetClientID( ), "click_slot_purchase", 
				{ 
					name 		= tostring( player:GetNickName( ) ),
				} )
end
addEvent( "onCarSellSlotBuy", true )
addEventHandler( "onCarSellSlotBuy", resourceRoot, onCarSellSlotBuy_handler )