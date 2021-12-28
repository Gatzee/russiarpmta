CARSELLS_GOVERNMENT = {}

local pUnsellableVehicles =
{
--[[
	-- Вертолёты
	[548] = true,
	[425] = true,
	[417] = true,
	[487] = true,
	[488] = true,
	[497] = true,
	[563] = true,
	[447] = true,
	[469] = true,

	-- Гидра
	[520] = true,
]]
	-- ГАЗ Тигр
	[495] = true,

	-- FORD MONSTER
	[559] = true,
}

function GetFinalCost( vehicle )
	local full_cost_models = {
		[ 498 ] = true,
		[ 499 ] = true,
		[ 508 ] = true,
		[ 482 ] = true,
	}

	-- Полная стоимость в течение недели на эти машины
	if full_cost_models[ vehicle.model ] and getRealTime().timestamp <= 1553343786 then 
		return vehicle:GetFirstCost( ) 

	-- Для всех остальных машин, дефолтно пополам
	else
		return vehicle:GetFirstCost( ) / 2
	end 
end

function onResourceStart()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend( "ShUtils" )
	Extend( "SPlayer" )
	Extend( "SVehicle" )
	Extend( "ShVehicleConfig" )
	Extend( "SInterior" )
	Extend( "SDB" )
	Extend( "SBusiness" )

	--[[for i, data in pairs(BUSINESS_ELEMENTS) do
		if data.business_id == 4 then
			if data.building_type == "sell" then
				CarsellToGovernment_create(data)
			end
		end
	end]]
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart,true,"high-1")

function CarsellToGovernment_create(config)
	config.accepted_elements = { vehicle = true }
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"
	config.radius = config.radius or 2
	--config.marker_image = "img/red.png"
	config.marker_text = config.marker_text or "Продажа\n транспорта"
	local carsell = TeleportPoint(config)
	carsell.element:setData( "material", true, false )
    carsell:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.5 } )
	carsell.elements = { }
	carsell.elements.blip = Blip( config.x, config.y, config.z, config.blip or 29, 4, 255, 255, 0, 255, 0, 200)
	carsell.element:setData("ignore_dist", true)
	carsell.marker:setColor(255, 0, 0, 50)
	carsell.PreJoin = function(carsell, player)
		local vehicle = player.vehicle
		
		local sType = vehicle:GetSpecialType()

		if carsell.accepted_special_types then
			if not sType or not carsell.accepted_special_types[sType] then
				player:ShowError("Здесь нельзя продать такое транспортное средство")
				return
			end
		end

		local bTradable, iTimeLeft = vehicle:IsTradeAvailable()
		if not bTradable then
			player:ShowWarning("Этот транспорт можно будет продать через ".. math.floor( iTimeLeft/60/60 ).."ч" )
			return
		end
		if vehicle:GetPermanentData( "govuntradable" ) then
			player:ShowError( "Этот транспорт нельзя продать" )
			return
		end
		if not player:OwnsVehicle(vehicle) then
			player:ShowError( "Вы не можете продать чужой транспорт" )
			return
		end
		local temp_timeout = vehicle:GetPermanentData( "temp_timeout" ) or 0
		if pUnsellableVehicles[vehicle.model] or vehicle:GetID() < 0 or temp_timeout > 0 then
			player:ShowError( "Данный транспорт нельзя продать" )
			return
		end
		if player:GetLevel() < 2 then
			player:ShowError( "Продавать транспорт можно только со 2-го уровня" )
			return
		end
		if player:GetJobClass( ) == JOB_CLASS_TAXI_PRIVATE and player:GetOnShift( ) then
			player:ShowError( "Закончи смену в такси чтобы продать транспорт!" )
			return
		end
		return true
	end
	carsell.PostJoin = function(carsell, player)
		local iCost = GetFinalCost( player.vehicle )
		if not iCost then return end

		triggerClientEvent( player, "CarsellToGovernment_ShowUI", resourceRoot, true, {
			vehicle = player.vehicle, 
			cost = math.floor(iCost), 
			variant = player.vehicle:GetVariant(),
    		is_inventory_empty = not next( player.vehicle:GetPermanentData( "inventory_data" ) or {} )
		} )
	end
	carsell.PostLeave = function(carsell, player)
		triggerClientEvent( player, "CarsellToGovernment_ShowUI", resourceRoot, nil )
	end

	table.insert(CARSELLS_GOVERNMENT, carsell)
end

addEvent("onCarsellToGovernmentVehicleSell", true)
function onCarsellToGovernmentVehicleSell(vehicle)
	local player = client or source
	if player.vehicle ~= vehicle then return end
	local vehicle_info = VEHICLE_CONFIG[vehicle.model]
	if not vehicle_info then return end
	
	local variant = vehicle:GetVariant()
	local variant_info = vehicle_info.variants[variant]
	local variant_name = variant_info.mod
	local vehicle_name = vehicle_info.model .. " (" .. variant_name .. ")"
	local price = GetFinalCost( player.vehicle )
	local vehicle_id = vehicle:GetID()

	WriteLog("money/special", "[Car:ГосПродажа] %s продал транспорт %s (VEH:%s) за %s государству", player, vehicle_name, vehicle:GetID(), price)

	triggerEvent( "onPlayerSellVehicleToGovernment", player, vehicle, price )

	player:ShowInfo("Вы успешно продали ваше транспортное средство \nза "..format_price(price).." р.")
	triggerClientEvent( player, "CarsellToGovernment_ShowUI", resourceRoot, nil )
	player.vehicle = nil
	player:RemoveVehicleFromList( vehicle )
	exports.nrp_vehicle:DestroyForever(vehicle:GetID())
	player:GiveMoney(price, "Server.Carsell.SellToGovernment")
	player.cameraTarget = player

	triggerEvent( "CheckPlayerVehiclesSlots", player )
end
addEventHandler("onCarsellToGovernmentVehicleSell", root, onCarsellToGovernmentVehicleSell)
