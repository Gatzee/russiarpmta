loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "SDB" )

local VEHICLE_PARTS_STATE = {}

function OnPlayerHitSpecialBoatWorkshopMarker( workshop_id )
	local pVehicle = client.vehicle

	if not isElement(pVehicle) then
		local function GetVehiclesFromDatabase( query, pPlayer )
			if not isElement( pPlayer ) then return end
			if not query then return end
			local data = dbPoll(query, 0)
			if type(data) ~= "table" then return end

			local pSpecialVehicles = {}

			for k,v in pairs(data) do
				if IsSpecialVehicle( v.model ) == "boat" then
					local pRow = { id = v.id, model = v.model, health = v.health, fuel = v.fuel }

					local pElement = GetVehicle( v.id )
					if pElement then
						pRow.fuel = pElement:GetFuel()
						pRow.health = pElement.health
					end

					table.insert( pSpecialVehicles, pRow )
				end
			end

			triggerClientEvent( pPlayer, "ShowUI_SpecialBoatWorkshop", pPlayer, true, { vehicles = pSpecialVehicles, on_foot = true } )
		end

		if #client:GetSpecialVehicles() > 0 then
			DB:queryAsync(GetVehiclesFromDatabase, { client }, "SELECT id, model, health, fuel FROM nrp_vehicles WHERE owner_pid = ?", "p:"..client:GetUserID())
		else
			client:ShowError("У тебя нет подходящего транспорта")
		end
		return 
	end

	local sType = pVehicle:GetSpecialType()
	if not sType then
		client:ShowError("Здесь не обслуживают такой транспорт")
		return false
	end

	local pDataToSend = 
	{
		vehicle = pVehicle,
		details = GetSpecialVehiclePartsState( pVehicle ),
		percent_cost = GetVehiclePercentCost( pVehicle ),
		workshop_id = workshop_id or 1,
	}

	triggerClientEvent( client, "ShowUI_SpecialBoatWorkshop", client, true, pDataToSend )
end
addEvent("OnPlayerHitSpecialBoatWorkshopMarker", true)
addEventHandler("OnPlayerHitSpecialBoatWorkshopMarker", root, OnPlayerHitSpecialBoatWorkshopMarker)

function OnPlayerTryRepairSpecialBoatVehicle( data )
	local pPlayer = client

	if data.on_foot then
		local iTotalCost = 0

		for operation, values in pairs( data.operations ) do
			iTotalCost = iTotalCost + values.cost
		end

		if pPlayer:TakeMoney( iTotalCost, "boat_repair" ) then

			for operation, values in pairs( data.operations ) do
				local pVehicle = GetVehicle( values.id )
				if isElement(pVehicle) then
					if values.action == "repair" then
						fixVehicle( pVehicle )
					elseif values.action == "refill" then
						pVehicle:SetFuel( "full" )
					end
				else
					if values.action == "repair" then
						DB:exec( "UPDATE nrp_vehicles SET health = 1000 WHERE id = ? LIMIT 1", values.id )
					end
				end
			end

			pPlayer:ShowSuccess( "Твой транспорт успешно обслужен" )
			triggerClientEvent( pPlayer, "ShowUI_SpecialBoatWorkshop", pPlayer, false, { on_foot = true } )
		else
			pPlayer:ShowError("Недостаточно денег")
		end
	end

	local pVehicle = data.vehicle
	if not isElement(pPlayer) or not isElement(pVehicle) then return end

	local fOldHealth = pVehicle.health
	local bRefill = false

	local fPercentCost = GetVehiclePercentCost( pVehicle )
	local iCost = 0

	local iTotalPercent = 0

	for k, part in pairs( data.parts ) do
		if part == "refill" then
			local iSpaceLeft = pVehicle:GetMaxFuel() - pVehicle:GetFuel()
			local iPartCost = math.floor( iSpaceLeft * FUEL_COST )
			iCost = iCost + iPartCost
			bRefill = true
		else
			local iPartCost = math.floor( VEHICLE_PARTS_STATE[pVehicle][part] * fPercentCost )
			iCost = iCost + iPartCost
			iTotalPercent = iTotalPercent + VEHICLE_PARTS_STATE[pVehicle][part]
		end
	end

	if pPlayer:TakeMoney( iCost, "boat_repair" ) then
		iTotalPercent = iTotalPercent / 100
		pVehicle.health = fOldHealth + (1000-fOldHealth) * iTotalPercent

		if pVehicle.health >= 950 then
			fixVehicle( pVehicle )
		end

		if bRefill then
			pVehicle:SetFuel("full")
		end

		pPlayer:ShowSuccess("Транспорт успешно обслужен")

		triggerClientEvent( pPlayer, "ShowUI_SpecialBoatWorkshop", pPlayer, false )

		for i, part in pairs( data.parts ) do
			if part ~= "refill" then
				VEHICLE_PARTS_STATE[pVehicle][part] = nil
			end
		end

		UpdateSpecialVehiclePartsState( pVehicle )
	else
		pPlayer:ShowError("Недостаточно денег")
	end
end
addEvent( "OnPlayerTryRepairSpecialBoatVehicle", true )
addEventHandler( "OnPlayerTryRepairSpecialBoatVehicle", root, OnPlayerTryRepairSpecialBoatVehicle )

function GetSpecialVehiclePartsState( pVehicle, force_update )
	local sType = pVehicle:GetSpecialType()
	local pPartsConf = PARTS_LIST[sType]
	local fHealth = pVehicle.health
	local fTotalDamage = math.floor( 1000 - fHealth )

	if VEHICLE_PARTS_STATE[ pVehicle ] and #VEHICLE_PARTS_STATE[ pVehicle ] >= 1 then
		if not force_update then
			return VEHICLE_PARTS_STATE[ pVehicle ]
		end
	else
		addEventHandler("onElementDestroy", pVehicle, OnVehicleDestroy)
	end

	local pOutput = {}


	local iPieces =  math.floor( fTotalDamage /  20 )
	local fMinPiece =  100 / iPieces

	for i = 1, iPieces do
		local rand_part_id = math.random( 1, #pPartsConf )
		pOutput[ rand_part_id ] = ( pOutput[ rand_part_id ] or 0 ) + fMinPiece
	end

	VEHICLE_PARTS_STATE[ pVehicle ] = pOutput
	return pOutput
end

function UpdateSpecialVehiclePartsState( pVehicle )
	local pParts = VEHICLE_PARTS_STATE[ pVehicle ]

	if #pParts <= 1 then
		VEHICLE_PARTS_STATE[ pVehicle ] = nil
		removeEventHandler("onElementDestroy", pVehicle, OnVehicleDestroy)
	end

	local iTotalPercent = 0

	for k,v in pairs(pParts) do
		iTotalPercent = iTotalPercent + v
	end

	local fMultiplier = 100/iTotalPercent

	for k,v in pairs(pParts) do
		v = v*fMultiplier
	end

	VEHICLE_PARTS_STATE[ pVehicle ] = pParts

	return pParts
end

function GetVehiclePercentCost( pVehicle )
	local iTotalCost = VEHICLE_CONFIG[ pVehicle.model ].variants[ pVehicle:GetVariant() ].cost * REPAIR_COST_MUL

	local fDamagePercent = 1 - math.floor(pVehicle.health) / 1000

	return fDamagePercent*iTotalCost/100
end

function OnVehicleDestroy()
	if VEHICLE_PARTS_STATE[source] then
		VEHICLE_PARTS_STATE[source] = nil
	end
end