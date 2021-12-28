Extend( "SPlayer" )
Extend( "SVehicle" )

FACTION_VEHICLES_LIST_REVERSE = { }

function onFactionVehicleSpawnRequest_handler( conf )
	for i, v in pairs( FACTION_VEHICLES_LIST_REVERSE ) do
		if v.owner == client then
			i:destroy()
		end
	end

	local faction = client:GetFaction()
	local faction_level = client:GetFactionLevel()
	if faction ~= conf.faction or faction_level < conf.level then
		return
	end

	local result, msg = CheckVehicleLicense( client, conf.model )
	if not result then
		client:ShowError( msg )
		return
	end

	local possible_vehicles = { }
	for i, v in pairs( FACTION_VEHICLES_LIST ) do
		if v.iFaction == conf.faction and v.iMinLevel == conf.level and v.iModel == conf.model and v.city == conf.city then
			table.insert( possible_vehicles, v )
		end
	end
	if #possible_vehicles <= 0 then
		client:ShowError( "Ошибка поиска выбранного автомобиля" )
		return
	end

	local random_point, n = nil, 0
	while not random_point do
		n = n + 1
		if n > #possible_vehicles then
			break
		end
		random_point = possible_vehicles[ n ]
		if isAnythingWithinRange( Vector3( random_point.x, random_point.y, random_point.z ), 3 ) then random_point = nil end
	end

	if random_point then
		local vehicle = CreateFactionVehicle( client, random_point )
		if vehicle then

			if random_point.iPaintjob then
				vehicle:setColor( 255, 255, 255 )
				vehicle.paintjob = random_point.iPaintjob
			end

			if random_point.tuning_external then
				--iprint( random_point.tuning_external )
				for i, v in pairs( random_point.tuning_external ) do
					vehicle:SetExternalTuningValue( i, v )
				end
			end

			setTimer( 
				function( client, vehicle )
					if not isElement( client ) or not isElement( vehicle ) then return end
					warpPedIntoVehicle( client, vehicle )
					setCameraTarget( client, client )
				end
			, 250, 1, client, vehicle )
		else
			client:ShowError( "Ошибка создания транспорта" )
		end
	else
		client:ShowError( "Все места на парковке заняты. Освободите территорию чтобы получить транспорт" )
	end
end
addEvent( "onFactionVehicleSpawnRequest", true )
addEventHandler( "onFactionVehicleSpawnRequest", root, onFactionVehicleSpawnRequest_handler )

VEHICLE_EXIT_TIMERS = { }
function CreateFactionVehicle( player, conf )
	local conf = table.copy( conf )
	local vehicle = Vehicle.CreateTemporary( conf.iModel,  conf.x, conf.y, conf.z, 0, 0, conf.rz or 0 )

	if vehicle then
		vehicle:SetFaction( conf.iFaction )
		vehicle:SetVariant( conf.iVariant or 1 )
		if conf.sNumber then
			vehicle:SetNumberPlate( conf.sNumber )
		else
			if FACTIONS_BY_CITYHALL[ conf.iFaction ] == conf.iFaction then
				local regions = {
					[0] = 97;
					[1] = 98;
					[2] = 99,
				}
				vehicle:SetNumberPlate( "1:а".. math.random( 0, 9 ) .. math.random( 0, 9 ) .. math.random( 1, 9 ) .."мр".. regions[ conf.city ] )

				if FACTIONS_VEHICLE_SIREN_OFFSET_POSITIONS[ conf.iModel ] then
					local siren_object = createObject( 1455, 0, 0, 0 )
					siren_object.collisions = false
					attachElements( siren_object, vehicle, unpack( FACTIONS_VEHICLE_SIREN_OFFSET_POSITIONS[ conf.iModel ] ) )

					addEventHandler( "onElementDestroy", vehicle, function( )
						if isElement( siren_object ) then
							destroyElement( siren_object )
						end
					end )
				end
			else
				vehicle:SetNumberPlate( GenerateRandomNumber( FACTION_NUMBER_TYPES[ conf.iFaction ] ) )
			end
		end
		vehicle:SetColor(unpack(conf.pColor or {255,255,255}))
		vehicle:SetFuel( "full" )
		vehicle:setData( "ignore_removal", true, false )

		if conf.windows_color then
			vehicle:SetWindowsColor( unpack( conf.windows_color ) )
		end

		local allowFactions = {
			[F_ARMY] = true,
			[F_POLICE_PPS_NSK] = true,
			[F_POLICE_DPS_NSK] = true,
			[F_POLICE_PPS_GORKI] = true,
			[F_POLICE_DPS_GORKI] = true,
			[F_POLICE_PPS_MSK] = true,
			[F_POLICE_DPS_MSK] = true,
		}
		
		if allowFactions[ conf.iFaction ] and conf.iMinLevel >= 1 then
			local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { category = 5, subtype = 1 } )

			for _, id in pairs( parts ) do
				vehicle:ApplyPermanentPart( id )
			end
		end

		triggerEvent( "SetupVehicleSirens", vehicle, vehicle )
		conf.element = vehicle
		conf.owner = player
		FACTION_VEHICLES_LIST_REVERSE[ vehicle ] = conf

		local function onVehicleDestroy()
			FACTION_VEHICLES_LIST_REVERSE[ vehicle ] = nil
			if isTimer( VEHICLE_EXIT_TIMERS[ vehicle ] ) then killTimer( VEHICLE_EXIT_TIMERS[ vehicle ] ) end
			VEHICLE_EXIT_TIMERS[ vehicle ] = nil
		end
		addEventHandler( "onElementDestroy" , vehicle, onVehicleDestroy )

		local function destroyThisVehicle( )
			if isElement( vehicle ) then vehicle:destroy() end
		end
		addEventHandler( "onPlayerQuit" , player, destroyThisVehicle )
		addEventHandler( "onPlayerFactionChange" , player, destroyThisVehicle )
		addEventHandler( "OnPlayerFactionDutyEnd" , player, destroyThisVehicle )

		local function onVehicleEnter( player, seat )
			if seat ~= 0 then return end
			if isTimer( VEHICLE_EXIT_TIMERS[ vehicle ] ) then killTimer( VEHICLE_EXIT_TIMERS[ vehicle ] ) end
		end
		addEventHandler( "onVehicleEnter", vehicle, onVehicleEnter )

		local function onVehicleStartEnter( player, seat )
			if seat == 0 then
				if player:GetFaction() ~= vehicle:GetFaction() then
					player:ShowError( "Данный транспорт принадлежит чужой фракции" )
					cancelEvent()
				elseif player:GetFactionLevel() < conf.iMinLevel then
					player:ShowError( "Ваше звание слишком низкое для этого транспорта" )
					cancelEvent()
				elseif player:getData( "jailed" ) then
					player:ShowError( "Вы находитель в заключении" )
					cancelEvent()
				elseif not player:IsOnFactionDuty( ) then
					player:ShowError( "Ты должен быть на смене чтоб пользоваться фракционным транспортом" )
					cancelEvent()
				end
			end
		end
		addEventHandler( "onVehicleStartEnter", vehicle, onVehicleStartEnter )

		local function onVehicleExit( player, seat )
			if seat ~= 0 then return end
			VEHICLE_EXIT_TIMERS[ vehicle ] = Timer( 
				function( player, vehicle )
					if isElement( vehicle ) then
						local fucking_homeless_shit = false
						local pOccupants = getVehicleOccupants( vehicle )

						for k, v in pairs( pOccupants ) do
							if isElement(v) and getElementType(v) == "ped" then
								if isElement( player ) then
									triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Бездомный сбежал из вашей машины, задача провалена!" } )
									fucking_homeless_shit = true
									break
								end
							end
						end

						vehicle:destroy( )
					end

					if isElement( player ) and not fucking_homeless_shit then player:ShowError( "Ваш транспорт был возвращен на стоянку" ) end
				end
			, 30 * 60 * 1000, 1, player, vehicle )
			player:ShowInfo( "Транспорт будет возвращен на стоянку через 30 минут" )
		end
		addEventHandler( "onVehicleExit", vehicle, onVehicleExit )

		return vehicle
	end
end

function DestroyVehiclesOnStop()
	for vehicle, data in pairs(FACTION_VEHICLES_LIST_REVERSE) do
		if isElement(vehicle) then
			vehicle:DestroyTemporary()
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, DestroyVehiclesOnStop)

function GetVehicleOwner( vehicle )
	if FACTION_VEHICLES_LIST_REVERSE[ vehicle ] then
		return FACTION_VEHICLES_LIST_REVERSE[ vehicle ].owner
	end
	return false
end

function CheckVehicleLicense( player, model_id )
	if VEHICLE_CONFIG[ model_id ].special_type == "helicopter" and not player:HasLicense( LICENSE_TYPE_HELICOPTER ) then
		return false, "Необходимо иметь права для управления вертолётом!"
	end
	return true
end

--[[
function CreateVehiclesOnStart()
	for i, conf in pairs(FACTION_VEHICLES_LIST) do
		local vehicle = Vehicle.CreateTemporary( conf.iModel,  conf.x, conf.y, conf.z, 0, 0, conf.rz or 0 )
		if vehicle then
			vehicle:SetFaction( conf.iFaction )
			vehicle:SetVariant( conf.iVariant or 1 )

			if conf.sNumber then
				vehicle:SetNumberPlate( conf.sNumber )
			else
				vehicle:SetNumberPlate( GenerateRandomNumber( CATEGORY_REGULAR, FACTION_NUMBER_TYPES[ conf.iFaction ] ) )
			end

			vehicle:SetColor(unpack(conf.pColor or {255,255,255}))

			triggerEvent( "SetuvehicleSirens", vehicle, vehicle )

			setVehicleRespawnDelay( vehicle, 300000 )
			setVehicleRespawnPosition( vehicle, conf.x, conf.y, conf.z, 0, 0, conf.rz or 0 )

			conf.element = vehicle
			FACTION_VEHICLES_LIST_REVERSE[vehicle] = conf
		end
	end
end
addEventHandler( "onResourceStart", resourceRoot, CreateVehiclesOnStart)



function OnVehicleStartEnter_handler( pPlayer, iSeat )
	if iSeat == 0 then
		local pData = FACTION_VEHICLES_LIST_REVERSE[source]
		if pData then
			local iFaction = pPlayer:GetFaction()
			local iLevel = pPlayer:GetFactionLevel()

			if pData.iFaction ~= iFaction then
				pPlayer:ShowError("Вы не можете использовать этот транспорт")
				cancelEvent()
				return false
			end

			if pData.iMinLevel > iLevel then
				pPlayer:ShowError("Ваш ранг не позволяет использовать это транспортное средство")
				cancelEvent()
				return false
			end
		end
	end
end
addEventHandler( "onVehicleStartEnter", root, OnVehicleStartEnter_handler )]]