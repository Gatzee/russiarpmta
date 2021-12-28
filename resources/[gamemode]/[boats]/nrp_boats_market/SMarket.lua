loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "SVehicle" )

function onPlayerBoatMarketOpen( market_id )
	source:CompleteDailyQuest( "np_visit_shipyard" )
end
addEvent( "onPlayerBoatMarketOpen", true )
addEventHandler( "onPlayerBoatMarketOpen", root, onPlayerBoatMarketOpen )

function OnPlayerTryBuySpecialBoatVehicle( data )
	local pPlayer = client or source

	local pVehicleConf = VEHICLE_CONFIG[data.model]
	data.variant = data.variant or 1

	local pVariantConf = pVehicleConf.variants[data.variant]

	if pPlayer:TakeMoney( pVariantConf.cost, "boat_purchase" ) then
		spawnVehicle( pPlayer, { color = data.color, model = data.model, variant = data.variant, cost = pVariantConf.cost } )

		triggerEvent( "onPlayerSomeDo", pPlayer, "add_boat" ) -- achievements
	else
		pPlayer:EnoughMoneyOffer( "Boat purchase", pVariantConf.cost, "OnPlayerTryBuySpecialBoatVehicle", pPlayer, data )
	end
end
addEvent("OnPlayerTryBuySpecialBoatVehicle", true)
addEventHandler("OnPlayerTryBuySpecialBoatVehicle", root, OnPlayerTryBuySpecialBoatVehicle)

function spawnVehicle(player, data)
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

	exports.nrp_vehicle:AddVehicle( pRow, true, "OnBoatMarketVehicleAdded", { player = player, cost = data.cost } )

	return true
end

function OnBoatMarketVehicleAdded( vehicle, data )
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

		triggerEvent( "onPlayerBuyBoat", data.player, vehicle, data.cost or 0, true )
		triggerClientEvent( data.player, "ShowUI_SpecialBoatMarket", resourceRoot, false )
		data.player:ShowSuccess("Транспорт успешно приобретён")
		triggerEvent("OnSpecialVehicleBought", vehicle)
	end
end
addEvent("OnBoatMarketVehicleAdded", true)
addEventHandler( "OnBoatMarketVehicleAdded", resourceRoot, OnBoatMarketVehicleAdded )