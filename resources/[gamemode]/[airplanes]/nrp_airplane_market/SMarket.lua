loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "SVehicle" )

function onPlayerAirplaneMarketOpen( market_id )
	source:CompleteDailyQuest( "np_visit_airshow" )
end
addEvent( "onPlayerAirplaneMarketOpen", true )
addEventHandler( "onPlayerAirplaneMarketOpen", root, onPlayerAirplaneMarketOpen )

function OnPlayerTryBuySpecialVehicle( data )
	local pPlayer = client or source

	local pVehicleConf = VEHICLE_CONFIG[data.model]
	data.variant = data.variant or 1

	local pVariantConf = pVehicleConf.variants[data.variant]

	if pPlayer:TakeMoney( pVariantConf.cost, "aircraft_purchase" ) then
		local pMarketData = MARKETS_LIST[ data.market_id ]

		spawnVehicle( pPlayer, { color = data.color, model = data.model, variant = data.variant, cost = pVariantConf.cost } )

		triggerEvent( "onPlayerSomeDo", pPlayer, "add_plane" ) -- achievements
	else
		pPlayer:EnoughMoneyOffer( "Airplane market", pVariantConf.cost, "OnPlayerTryBuySpecialVehicle", pPlayer, data )
	end
end
addEvent("OnPlayerTryBuySpecialVehicle", true)
addEventHandler("OnPlayerTryBuySpecialVehicle", root, OnPlayerTryBuySpecialVehicle)

function spawnVehicle(player, data)
	local vecRotation	= Vector3(0, 0, 0)
	local aColor		= data.color
	local sOwnerPID		= "p:" .. player:GetUserID()
	local pRow	= {
		model 		= data.model;
		variant		= data.variant;
		x			= 0;
		y			= 0;
		z			= 0;
		rx			= 0;
		ry			= 0;
		rz			= 0;
		owner_pid	= sOwnerPID;
		color		= aColor;
	}

	exports.nrp_vehicle:AddVehicle( pRow, true, "OnAirplaneMarketVehicleAdded", { player = player, cost = data.cost } )

	return true
end

function OnAirplaneMarketVehicleAdded( vehicle, data )
	--iprint("RESULT", vehicle, data)

	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" ..data.player:GetUserID()

		vehicle.locked = true
		vehicle.engineState = true
		vehicle:SetFuel("full")
		vehicle:SetPermanentData("showroom_cost", data.cost)
		vehicle:SetPermanentData("showroom_date", getRealTime().timestamp)
		vehicle:SetPermanentData("first_owner", sOwnerPID)

		data.player:AddVehicleToList( vehicle )

		triggerEvent( "onPlayerBuyAircraft", data.player, vehicle, data.cost or 0, true )
		triggerClientEvent( data.player, "ShowUI_SpecialMarket", resourceRoot, false )
		data.player:ShowSuccess("Транспорт успешно приобретён")
		triggerEvent("OnSpecialVehicleBought", vehicle)
	end
end
addEvent("OnAirplaneMarketVehicleAdded", true)
addEventHandler( "OnAirplaneMarketVehicleAdded", resourceRoot, OnAirplaneMarketVehicleAdded )