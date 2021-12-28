-- SVehicle.lua - Расширение класса автомобиля
Import( "ShVehicle" )

Vehicle.SetCruiseEnabled = function( self, state )
	local pController = self.controller
	self:SetPermanentData("cruise_state", state)

	if isElement(pController) and getElementType(pController) == "player" then
        pController:ShowInfo("Ограничитель скорости "..( state and "включен" or "выключен" ))
        triggerClientEvent( pController, "OnClientSpeedLimiterSwitched", pController, state )
    end

    --setVehicleUseSpeedLimit( self, state )
end

Vehicle.IsCruiseEnabled = function( self )
	return false
--	return isVehicleUseSpeedLimit( self )
end

Vehicle.SetConfiscated = function( self, state )
	if self:GetID() < 0 then return end

	local iOwnerID = self:GetOwnerID()
	if not iOwnerID then return end

	local pOwner = GetPlayer(iOwnerID)
	if pOwner then
		if state then
			pOwner:ShowInfo("Твой автомобиль попал на штраф-стоянку")
		else
			pOwner:ShowInfo("Ты вернул автомобиль со штраф-стоянки")
		end
	end

	self:SetBlocked(state)
	return self:SetPermanentData("confiscated", state)
end

Vehicle.IsConfiscated = function( self )
	return self:GetPermanentData("confiscated")
end

Vehicle.GetProperties = function( self )
	return self:GetPermanentData("properties") or {}
end

Vehicle.GetProperty = function( self, key )
	return self:GetProperties()[key]
end

Vehicle.SetProperty = function( self, key, value )
	local pProperties = self:GetProperties()
	pProperties[key] = value

	self:SetPermanentData("properties", pProperties)

	triggerEvent("OnVehiclePropertiesChanged", self, key, value)
	return true
end

Vehicle.SetFuel = function(self, fuel, sync, ignore_force_sync)
	local new_fuel = fuel == "full" and ( self:GetMaxFuel() or 100 ) or fuel
	setElementData( self,"fFuel", new_fuel, not not sync)
	self:SetPermanentData("fuel", new_fuel)

	if not ignore_force_sync then
		self:ForceSyncVehicleStats()
	end

	return true
end

Vehicle.ApplyNumberPlateColor = function( self, hex )
	local numplate = self:GetNumberPlate( ):gsub( "#%x%x%x%x%x%x:", "" )
	local numplate_new = utf8.len( hex ) >= 6 and ( "#" .. hex:gsub( "#", "" ) .. ":" .. numplate ) or numplate
	setElementData( self, "_numplate", numplate_new )
end

Vehicle.SetNumberPlate = function(self, text)
	setElementData( self, "_numplate", text )
	self:SetPermanentData( "number_plate", text )
end

Vehicle.SetMileage = function (self, mileage, sync, ignore_force_sync)
	local old_mileage = self:GetMileage( )
	setElementData( self,"fMileage", mileage, not not sync)
	
	self:SetPermanentData( "mileage", mileage )

	if mileage > old_mileage then
		self:SetPermanentData( "mileage_total", ( self:GetPermanentData( "mileage_total" ) or 0 ) + ( mileage - old_mileage ) )
		self:SetPermanentData( "mileage_since_lp", ( self:GetPermanentData( "mileage_since_lp" ) or 0 ) + ( mileage - old_mileage ) )
	end

	if not ignore_force_sync then
		self:ForceSyncVehicleStats()
	end

	return true
end

Vehicle.SetColor = function( self, r, g, b )
	self:SetPermanentData( "color", { r, g, b } )
	setVehicleColor( self, r, g, b )
end

Vehicle.GetColor = function( self )
	return self:GetPermanentData( "color" ) or { getVehicleColor( self, true ) }
end

Vehicle.SetWindowsColor = function(self, r, g, b, a)
	local r, g, b, a = r or 0, g or 0, b or 0, a or 120
	local sync = not ( r == 0 and g == 0 and b == 0 and a == 120 )
	local color = { r, g, b, a }

	local edata = sync and color
	if edata then
		setElementData( self, "_wincolor", sync and color )
	else
		removeElementData( self, "_wincolor" )
	end
	self:SetPermanentData( "windows_color", color )
end

Vehicle.SetFaction = function( self, faction_id )
	return setElementData( self, "faction_id", faction_id )
end

GenerateRandomNumber = function( ... )
	return exports.nrp_vehicle_numberplates:GenerateRandomNumberPlate(...)
end
GenerateRandomNumberInCategory = function( ... )
	return exports.nrp_vehicle_numberplates:GenerateNumberPlateByCategory( ... )
end

Vehicle.HasBlackTuning = function( self )
	local sNumber = self:GetNumberPlate(false, true)
	if sNumber ~= self:GetNumberPlate() then
		return true
	end

	local pWindowsColor = self:GetWindowsColor()
	if pWindowsColor[1] ~= 0 or pWindowsColor[2] ~= 0 or pWindowsColor[3] ~= 0 then
		return true
	end

	return false
end

Vehicle.ResetBlackTuning = function( self, alpha )
	self:SetWindowsColor( 0, 0, 0, alpha )
	self:SetPermanentData( "black_platecolor", "" )
	self:SetNumberPlate( self:GetNumberPlate( ) )
end

Vehicle.SetTempOwnerPID = function( self, id, state )
	local temp_owners = self:GetTempOwnersPID()
	temp_owners[ id ] = state
	return setElementData( self, "_tempowners", temp_owners )
end

Vehicle.RemoveTempOwners = function( self )
	return setElementData( self, "_tempowners", false )
end

Vehicle.SetPermanentData = function(self, sKey, sValue)
	triggerEvent( "VSetPermanentData", self, sKey, sValue )
end

Vehicle.GetPermanentData = function(self, sKey)
	return exports.nrp_vehicle:VGetPermanentData( self, sKey )
end

Vehicle.ReducePartCondition = function( self, sPart, iIndex )
	local pCurrentCondition = self:GetCondition()
	local sIndex = tostring(iIndex)
	if sPart == "engine" then
		pCurrentCondition.engine = pCurrentCondition.engine + 1

		if pCurrentCondition.engine > 4 then
			pCurrentCondition.engine = 0
		end
	else
		pCurrentCondition[sPart][sIndex] = pCurrentCondition[sPart][sIndex] + 1

		if pCurrentCondition[sPart][sIndex] > 4 then
			pCurrentCondition[sPart][sIndex] = 0
		end
	end

	setElementData( self, "condition", pCurrentCondition, false )
	self:SetPermanentData("condition", pCurrentCondition)
end

Vehicle.SetStatic = function( self, bState )
	setVehicleDamageProof( self, bState )
	setElementFrozen( self, bState )
	setElementData( self, "bStatic", bState )
end

Vehicle.SetVariant = function( self, iValue )
	--setVehicleModelVariant( self, iValue - 1 )
end

Vehicle.GetFirstCost = function( self )
	return self:GetPermanentData("showroom_cost") or VEHICLE_CONFIG[self.model] and VEHICLE_CONFIG[self.model].variants[self:GetVariant()].cost or 0
end

Vehicle.IsTradeAvailable = function( self )
	local iBlockDelay = 48*60*60 -- 48 hours

	local trade_date = self:GetPermanentData("last_trade_date") or 0
	local showroom_date = self:GetPermanentData("showroom_date") or 0

	local iLastAction = math.max(trade_date, showroom_date)
	local iPassed = getRealTime().timestamp - iLastAction

	if iPassed <= iBlockDelay then
		return false, iBlockDelay-iPassed
	end

	return true
end

Vehicle.CreateTemporary = function(...)
	return exports.nrp_vehicle:CreateVehicle( _, ...)
end

Vehicle.AsyncCreate = function(callbackEvent, args, ...)
	local resource = getResourceFromName( "nrp_vehicle" )
	local resource_root = getResourceRootElement( resource )

	triggerEvent("OnVehicleAsyncCreateRequest", resource_root, callbackEvent, args, ... )
end

Vehicle.DestroyTemporary = function(self)
	return exports.nrp_vehicle:DestroyVehicle( self:GetID() )
end

Vehicle.GiveFuel = function(self, fuel)
	local old_fuel = self:GetFuel()
	return self:SetFuel(old_fuel + fuel)
end

Vehicle.Fix = function(self)
	for i = 0, 5 do
		setVehicleDoorOpenRatio( self, i, 0)
	end
	self:fix()
end

Vehicle.SetOwnerPID = function(self, pid)
	self:SetPermanentData("owner_pid", pid)
	return setElementData( self,"_ownerpid", pid)
end

Vehicle.SetHandling = function(self, handling, value)
	return setVehicleHandling(self, handling, value)
end

Vehicle.IsEngineEnabled = function(self, player)

	-- Проверяем топливо
	if self:GetFuel() <= 0 then
		player:ShowError("Не заводится! Пора за канистрой" )
		return false
	end
	
	-- Проверяем права
	local is_quest_vehicle = self == player:getData( "quest_vehicle" ) or self == player:getData( "temp_vehicle" )
	if not getElementData( self, "tutorial" ) and not is_quest_vehicle then
		if not VEHICLE_ALLOWED_NOLICENSE[ self.model ] then
			if not player:HasLicense(self:GetLicenseType()) then
				player:ShowInfo( "У тебя нет прав на этот вид транспорта!" )
				return false
			end
		end
	end

	-- Проверяем ключи
	if self:GetOwnerID() then
		local owner_id = self:GetOwnerID()
		local player_id = source:GetUserID()
		local pOwners = self:GetTempOwnersPID()
		pOwners[owner_id] = true
		if not pOwners[player_id] and not player:IsAdmin() then
			player:ShowError("У вас нет ключей от данного транспорта")
			return false
		end
	end

	return true
end

Vehicle.GetLicenseType = function(self)
	local trucks = {
		[ 455 ] = true,
		[ 515 ] = true,
	}
	
	local license = LICENSE_TYPE_AUTO
	local iModel = self.model

	local sSpecialType = self:GetSpecialType()

	if self.model == 437 then
		license = LICENSE_TYPE_BUS
	elseif VEHICLE_CONFIG[ iModel ].is_moto or VEHICLE_TYPE_QUAD[iModel] then
		license = LICENSE_TYPE_MOTO
	elseif sSpecialType and sSpecialType == "airplane" then
		license = LICENSE_TYPE_AIRPLANE
	elseif sSpecialType and sSpecialType == "helicopter" then
		license = LICENSE_TYPE_HELICOPTER
	elseif sSpecialType and sSpecialType == "boat" then
		license = LICENSE_TYPE_BOAT
	elseif trucks[ iModel ] then
		license = LICENSE_TYPE_TRUCK
	end

	return license
end

Vehicle.TeleportToColshape = function(self,colshape)
	local players = getVehicleOccupants(self)
	for i,player in pairs(players) do
		player:fadeCamera(false,0)
		player.interior = colshape.interior
		player.dimension = colshape.dimension
	end
	self.turnVelocity = Vector3(0,0,0)
	self.velocity = Vector3(0,0,0)
	self.frozen = true
	self.position = colshape.position
	self.interior = colshape.interior
	self.dimension = colshape.dimension
	Timer(function()
		local players = getVehicleOccupants(self)
		for i,player in pairs(players) do
			player:fadeCamera(true,1)
		end
	end,500,1)
	Timer(function()
		self.turnVelocity = Vector3(0,0,0)
		self.velocity = Vector3(0,0,0)
		self.position = colshape.position
		self.frozen = false
	end,2000,1)
end

Vehicle.SetFuelLoss = function( self, loss )
	--return setElementData( self, "_fuelloss", loss )
	return false
end

Vehicle.SetParked = function( self, state, position, rotation )
	if self:GetSpecialType() then return end

	if state then
		for seat, player in pairs ( getVehicleOccupants( self ) ) do
			removePedFromVehicle ( player )
		end
		self:detach()
		setElementCollisionsEnabled( self, false )
		setElementFrozen( self, true )
		setElementPosition( self, 0, 0, 0 )
		setElementDimension( self, 6666 )
		self:setData( 'tow_evacuating', false, false )
		--setElementData( self, "bParked", state )
		setVehicleEngineState( self, false )
		setElementSyncer( self, false )
	else
		setElementCollisionsEnabled(self, true)
		setElementPosition(self, position)
		setElementRotation(self, rotation)
		setElementDimension(self, 0)
		setElementFrozen(self, false)
		setElementSyncer( self, true )
		--self:removeData( "bParked" )
	end

	return true
end

Vehicle.SetTowEvacuatedState = function( self, state )
	local enum = state and 'yes' or 'no'
	self:SetPermanentData( 'evacuated', enum )
	return true
end

Vehicle.GetTowEvacuatedState = function( self, state )
	local enum = self:GetPermanentData( 'evacuated' )
	return enum == 'yes' and true or false
end

Vehicle.SetBlocked = function( self, state )
	if self:GetSpecialType() then return end

	if state then
		self:SetParked(true)
		setElementData( self, "bBlocked", state )
	else
		self:removeData( "bBlocked" )
	end
	triggerEvent( "onVehicleChangeBlockState", self, state )
	return true
end

Vehicle.GetEvacuationAvailable = function( self )
	-- Проверить не выключена ли она квартирами

	-- Не на штраф-стоянке
	if self:IsConfiscated() then
		return false
	end
	
	-- Нет пассажиров
	local pOccupants = getVehicleOccupants( self )
	local iOccupants = 0

	for k,v in pairs(pOccupants) do
		iOccupants = iOccupants + 1
	end

	if iOccupants >= 1 then
		return false
	end

	return true
end

Vehicle.GetShortName = function( self )
	local pData = VEHICLE_CONFIG[self.model]
	if pData then
		--local sModel = pData.model
		--local pModel = split(sModel, " ")
		--return pModel[1].." "..( pModel[2] or "" )
		local veh_variant = self:GetVariant()
		local veh_mod = (pData.variants[ veh_variant ].mod and pData.variants[ veh_variant ].mod ~= "") and (" " .. pData.variants[ veh_variant ].mod) or ""
		return pData.model .. veh_mod
	else
		return "Неизвестный"
	end
end

function GetRandomizeNumberPlate()
	local pCharString = {
		"а";
		"в";
		"е";
		"к";
		"м";
		"н";
		"о";
		"р";
		"с";
		"т";
		"у";
		"х";
	}
	local pNumberString = {
		"0";
		"9";
		"8";
		"7";
		"6";
		"5";
		"4";
		"3";
		"2";
		"1";
	};

	local sText = "10:99:"
	for i = 1, 2 do
		sText = sText .. pCharString[ math.random( #pCharString ) ]
	end
	for i = 1, 3 do
		sText = sText .. pNumberString[ math.random( #pNumberString ) ]
	end
	sText = sText .. pCharString[ math.random( #pCharString ) ]
	return sText
end

-- Просто из хендлинга, игнорируя Globals
Vehicle.GetCurrentConfig = function( self, conf_name )
	return getVehicleHandling( self )[ conf_name ]
end

-- Взятие деталей
Vehicle.GetParts = function( self )
	return self:GetPermanentData( "tuning_internal" ) or { }
end

-- Get tuning part data from slot of vehicle
Vehicle.GetPartDataByID = function( self, id )
	local current_parts = self:GetParts( )

	for _, data in pairs( current_parts ) do
		if data.id == id then
			return data
		end
	end
end

-- Добавление на постоянку
Vehicle.ApplyPermanentPart = function( self, id, force )
	local current_parts = self:GetParts( )
	local part = getTuningPartByID( id )

	if not part or ( current_parts[ part.type ] and not force ) then return end

	current_parts[ part.type ] = { id = id }
	self:SetPermanentData( "tuning_internal", current_parts )
	setVehicleParameters( self, self:GetStats( current_parts, true ) )

	return true
end

-- Set damage of part
Vehicle.SetDamagePart = function ( self, id, state )
	local current_parts = self:GetParts( )

	for idx, part in pairs( current_parts ) do
		if part.id == id then
			current_parts[ idx ].damaged = state and 1 or 0
			self:SetPermanentData( "tuning_internal", current_parts )
			return true
		end
	end
end

-- Удаление характеристик и с самой машины
Vehicle.RemovePermanentPart = function( self, id )
	local current_parts = self:GetParts( )
	local part = getTuningPartByID( id )

	if not part or not current_parts[ part.type ] or current_parts[ part.type ].id ~= id then return end

	current_parts[ part.type ] = nil
	self:SetPermanentData( "tuning_internal", current_parts )
	setVehicleParameters( self, self:GetStats( current_parts, true ) )

	return true
end

-- Внешний тюнинг - компоненты
Vehicle.SetExternalTuning = function( self, list )
	self:SetPermanentData( "tuning_external", list or { } )
	setElementData( self, "tuning_external", list )
end

Vehicle.GetExternalTuning = function( self )
	return self:GetPermanentData( "tuning_external" ) or { }
end

Vehicle.SetExternalTuningValue = function( self, key, value )
	local tuning = self:GetExternalTuning( )
	tuning[ key ] = value
	self:SetExternalTuning( tuning )
end

Vehicle.SetExternalTuningValues = function( self, values )
	local tuning = self:GetExternalTuning( )
	for key, value in pairs( values ) do
		tuning[ key ] = value
	end
	self:SetExternalTuning( tuning )
end

Vehicle.GetExternalTuningValue = function( self, key )
	return self:GetExternalTuning( )[ key ]
end

-- Установка фар
Vehicle.SetHeadlightsColor = function( self, r, g, b )
	self:SetPermanentData( "headlights_color", { r, g, b } )
	self:ApplyHeadlightsColor( r, g, b )
end

Vehicle.GetHeadlightsColor = function( self )
	return unpack( self:GetPermanentData( "headlights_color" ) or { } )
end

-- Установка гидравлики
Vehicle.SetHydraulics = function( self, state )
	self:SetPermanentData( "hydraulics", state and "yes" or "no" )
	self:ApplyHydraulics( state )
end

Vehicle.GetHydraulics = function( self )
	return self:GetPermanentData( "hydraulics" ) == "yes"
end

-- Установка колёс
Vehicle.SetWheels = function( self, value )
	local value = tonumber( value ) or false
	self:SetPermanentData( "wheels", value )
	self:ApplyWheels( value )
end

Vehicle.GetWheels = function( self )
	return self:GetPermanentData( "wheels" )
end

-- Расширение колёс
Vehicle.SetWheelsWidth = function( self, front, rear )
	front = front and math.ceil( front )
	rear = rear and math.ceil( rear )
	self:SetPermanentData( "wheels_width", { front, rear } )
	
	if ( front or 0 ) == 0 and ( rear or 0 ) == 0 then
		self:removeData( "_wheels_w" )
	else
		self:setData( "_wheels_w", { front, rear } )
	end
end

Vehicle.GetWheelsWidth = function( self )
	local values = self:GetPermanentData( "wheels_width" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

-- Вылет (смещение от центра) колёс
Vehicle.SetWheelsOffset = function( self, front, rear )
	front = front and math.ceil( front )
	rear = rear and math.ceil( rear )
	self:SetPermanentData( "wheels_offset", { front, rear } )
	
	if ( front or 0 ) == 0 and ( rear or 0 ) == 0 then
		self:removeData( "_wheels_o" )
	else
		self:setData( "_wheels_o", { front, rear } )
	end
end

Vehicle.GetWheelsOffset = function( self )
	local values = self:GetPermanentData( "wheels_offset" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

-- Развал колёс
Vehicle.SetWheelsCamber = function( self, front, rear )
	front = front and math.ceil( front )
	rear = rear and math.ceil( rear )
	self:SetPermanentData( "wheels_camber", { front, rear } )
	
	if ( front or 0 ) == 0 and ( rear or 0 ) == 0 then
		self:removeData( "_wheels_c" )
	else
		self:setData( "_wheels_c", { front, rear } )
	end
end

Vehicle.GetWheelsCamber = function( self )
	local values = self:GetPermanentData( "wheels_camber" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

-- Занижение машины
Vehicle.SetHeightLevel = function( self, level )
	self:SetPermanentData( "height_level", level )
	self:ApplyHeightLevel( level )
end

Vehicle.GetHeightLevel = function( self )
	return self:GetPermanentData( "height_level" ) or 0
end

Vehicle.GetWheelsColor = function( self )
	return unpack( self:GetPermanentData( "wheels_color" ) or { 255, 255, 255 } )
end

Vehicle.SetWheelsColor = function( self, r, g, b )
	local r, g, b = r or 255, g or 255, b or 255
	self:SetPermanentData( "wheels_color", { r, g, b } )
	self:setData( "_wheels_color", { r, g, b } )
end

Vehicle.ParseHandling = function( self )
	if self:GetSpecialType( ) then return end

	setVehicleParameters( self, self:GetStats( self:GetParts( ), true ) )
end

Vehicle.SetHandling = function( self, handling )
	if self:GetSpecialType() then return end

	for i, v in pairs( handling ) do
		setVehicleHandling( self, i, v )
	end
end

-----------------------------
--			ВИНИЛЫ 		   --
-----------------------------

-- Полуение списка винилов
Vehicle.GetVinyls = function( self )
	local vinyls = {}
	local vinyls_data = self:GetPermanentData( "installed_vinyls" ) or { }
	for _, vinyl in pairs( vinyls_data ) do
		local new_vinyl_data = { }
        for i, v in pairs( vinyl ) do
            new_vinyl_data[ tonumber( i ) or i ] = tonumber( v ) or v
		end
        table.insert( vinyls, new_vinyl_data[ P_LAYER ], new_vinyl_data )
	end
	return vinyls
end

Vehicle.SetVinyls = function( self, vinyl_list )
	self:SetPermanentData( "installed_vinyls", vinyl_list )
end

-- Добавление винила на постоянку
Vehicle.ApplyPermanentVinyl = function( self, vinyl )
	local vinyl = table.copy( vinyl )
	local current_vinyls = self:GetVinyls()
	local vinyl_position = vinyl[ P_LAYER ]
	current_vinyls[ vinyl_position ] = vinyl
	self:SetPermanentData( "installed_vinyls", current_vinyls )
	return true, vinyl_position
end

-- Удаление винила с машины
Vehicle.RemovePermanentVinyl = function( self, vinyl )
	local current_vinyls = self:GetVinyls( )
	local vinyl_position = type( vinyl ) == "table" and vinyl[ P_LAYER ] or vinyl
	if vinyl_position and current_vinyls[ vinyl_position ] then
		current_vinyls[ vinyl_position ] = nil
		self:SetPermanentData( "installed_vinyls", current_vinyls )
		return true, vinyl_position
	else
		return false, "vinyl doesn't exist"
	end
end

Vehicle.IsRemoveAbilityPermanentVinyl = function( self, vinyl )
	local current_vinyls = self:GetVinyls( )
	local vinyl_position = type( vinyl ) == "table" and vinyl[ P_LAYER ] or vinyl
	if vinyl_position and current_vinyls[ vinyl_position ] then
		return true, vinyl_position
	else
		return false, "vinyl doesn't exist"
	end
end

function CancelTireDamage()
	setVehicleWheelStates( source, 0, 0, 0, 0 )
end

Vehicle.SetTireDamageEnabled = function( self, state )
	if state then
		removeEventHandler( "onVehicleDamage", self, CancelTireDamage )
	else
		removeEventHandler( "onVehicleDamage", self, CancelTireDamage )
		addEventHandler( "onVehicleDamage", self, CancelTireDamage )
	end
end

Vehicle.GetNeon = function( self )
	return self:GetPermanentData( "neon_data" ) or { }
end

Vehicle.SetNeon = function( self, neon_data )
	if neon_data then
		self:setData( "ne_i", neon_data.neon_image )
		self:SetPermanentData( "neon_data", neon_data )
	else
		self:removeData( "ne_i" )
		self:SetPermanentData( "neon_data", false )
	end
end

Vehicle.UpdateSpedometerMaxSpeed = function( self )
    local driver = self.controller
	local config = VEHICLE_CONFIG[ self.model ]

	if driver and config then
		if config.is_boat or config.is_airplane then return end

		local parts = self:GetParts( )
		local maxspeed = self:GetStats( parts, true )
		local veh_conf_speed = config.variants[ self:GetVariant( ) ].max_speed
		local velocity_coef = 1 + ( maxspeed / 400 ) * 2
		local vehicle_max_speed = veh_conf_speed * velocity_coef

		triggerEvent( "SetPrivateData", driver, "vehicle_max_speed", vehicle_max_speed )
	end
end