-- ShVehicle
Import( "ShElement" )

function IsSpecialVehicle( iModel )
	if not VEHICLE_CONFIG then
		iprint( "NO CONFIG RESOURCE", getResourceName( getThisResource( ) ) )
	end

	local pConfig = VEHICLE_CONFIG[ iModel ]

	if pConfig then
		return pConfig.special_type
	end
end

Vehicle.GetSpecialType = function( self )
	return IsSpecialVehicle( self.model )
end

Vehicle.GetFreeSeat = function( self, iStartFrom )
	local iStartFrom = iStartFrom or 1
	local pOccupants = getVehicleOccupants( self )

	for seat = iStartFrom, 3  do
		if not pOccupants[seat] then
			return seat
		end
	end

	return 1
end

Vehicle.tostring = function( self )
    local vehicle_name = VEHICLE_CONFIG and VEHICLE_CONFIG[ self.model ] and VEHICLE_CONFIG[ self.model ].model or getVehicleNameFromModel( self.model )
	return table.concat( { vehicle_name, " (ID:", self:GetID(), ")" }, '' )
end

Vehicle.GetFaction = function( self )
	return getElementData(self, "faction_id") or 0
end

Vehicle.IsInFaction = function( self )
	return self:GetFaction() > 0
end

Vehicle.GetTempOwnersPID = function( self )
	return getElementData( self, "_tempowners" ) or {}
end

VEHICLE_REPAIR_PARTS = {
	lights = 0.15,
	engine = 0.4,
	wheels = 0.15,
	panels = 0.13,
	doors = 0.17,
}

VEHICLE_REPAIR_COEFF = {
	[1] = 1.8,
	[2] = 1.1,
	[3] = 0.76,
	[4] = 0.66,
	[5] = 0.5,
	[6] = 0.4,
	[7] = 0.28,
	[8] = 0.20,
	[9] = 0.10,
	[10] = 0.05,
}

VEHICLE_REPAIR_RANGE = {
	[1] = 579000,
	[2] = 1250000,
	[3] = 2000000,
	[4] = 5000000,
	[5] = 6000000,
	[6] = 1000000,
	[7] = 1500000,
	[8] = 50000000,
	[9] = 100000000,
	[10] = math.huge,
}

Vehicle.IsOwnedBy = function( self, mUser, bHasOwner )
	local iUID = tonumber(mUser)
	if getElementType(mUser) == "player" then
		if mUser:IsAdmin() then
			return true
		end
		iUID = mUser:GetUserID()

		if self:IsInFaction() and mUser:GetFaction() == self:GetFaction() then
			return true
		end
	end

	local iOwnerID = self:GetOwnerID()
	if iOwnerID then
		local pOwners = self:GetTempOwnersPID()
		pOwners[iOwnerID] = true
		if pOwners[iUID] then
			return true
		else
			return false
		end
	end

	return not bHasOwner
end

function GetVehicleNameFromModel( sModel, variant )
	local iModel = tonumber(sModel)
	if iModel then
		local pData = VEHICLE_CONFIG[iModel]
		if pData then
			return pData.model .. ( variant and " " .. pData.variants[ variant or 1 ].mod or "" )
		else
			return "Неизвестный ("..iModel..")"
		end
	end
end

function getTuningPartByID( id, tier )
	return exports.nrp_tuning_internal_parts:getInternalTuningPartByID( id, tier )
end

Vehicle.GetCondition = function( self )
	local pCondition = getElementData( self, "condition" )
	if not pCondition or not next(pCondition) then
		pCondition =
		{
			panels = {},
			doors = {},
			lights = {},
			engine = 0,
		}

		for i=0,6 do
			pCondition.panels[tostring(i)] = 0
		end

		for i=0,5 do
			pCondition.doors[tostring(i)] = 0
		end

		for i=0,3 do
			pCondition.lights[tostring(i)] = 0
		end

		setElementData( self, "condition", pCondition, false )
	end

	return pCondition
end

Vehicle.GetFuel = function(self)
	return getElementData( self,"fFuel") or 100
end

Vehicle.ForceSyncVehicleStats = function( self )
	local occupant = getVehicleOccupant( self, 0 )
	if occupant then
		triggerClientEvent( occupant, "ForceSyncVehicleStats", occupant, self, self:GetFuel(), self:GetMileage() )
	end
end

Vehicle.GiveFuel = function(self, fuel)
	local old_fuel = self:GetFuel()
	self:SetFuel(math.min(old_fuel + fuel, self:GetMaxFuel()))
end

Vehicle.GetMaxFuel = function(self)
	local pConfigData = VEHICLE_CONFIG[self.model]
	if pConfigData and pConfigData.fuel then
		return tonumber(pConfigData.fuel)
	end
	return 100
end

Vehicle.GetFuelPrice = function(self, level, player)
	-- START: Тест экономики
	if player and self.model == 468 and player:getData( "economy_test" ) then
		return math.floor( level * 57 * 0.3 )
	end
	-- END: Тест экономики
	return level * 57
end

Vehicle.GetRepairCostMultiplier = function( self, player )
	-- START: Тест экономики
	if player and self.model == 468 and player:getData( "economy_test" ) then
		return 0.5
	end
	-- END: Тест экономики
	return 1
end

Vehicle.GetMileage = function ( self )
	return getElementData( self,"fMileage") or 0.0
end

Vehicle.GetBlocked = function ( self )
	return getElementData( self,"bBlocked")
end

Vehicle.GetParked = function ( self )
	return not getElementCollisionsEnabled( self ) and getElementDimension( self ) == 6666
end

--[[Vehicle.GetNumberPlate = function(self, short, within_hex)
	local text = getElementData( self, "_numplate" ) or ""
	if short then
		return utf8.sub(text, 7, utf8.len(text))
	end
	if within_hex then
		return text
	end
	return text:RemoveHex( ):gsub( "^:*(.-):*$", "%1" )
end]]

Vehicle.GetNumberPlate = function( self, short, within_hex )
	local text = getElementData( self, "_numplate" ) or ""

	local function InnerClearShit( value )
		local value = utf8.gsub( value, "^:*(.-):*$", "%1" )

		local matches
		repeat 
			value, matches = utf8.gsub( value, "::", ":" )
		until
			matches <= 0

		return value
	end

	text = InnerClearShit( text )

	local function InnerGetNumberPlate( )
		if short then
			return utf8.sub(text, 7, utf8.len(text))
		end

		if within_hex then
			return text
		end
		
		return text:RemoveHex( )
	end

	return InnerClearShit( InnerGetNumberPlate( ) )
end

Vehicle.GetNumberPlateHR = function(self, within_reg)
	local sNumbers = getElementData( self, "_numplate" ) or ""
	sNumbers = sNumbers:RemoveHex()
	local pNumbers = split(sNumbers, ":")

	if pNumbers and pNumbers[2] then
		if tonumber(pNumbers[1]) == PLATE_TYPE_AUTO then
			return utf8.sub(pNumbers[2], 1, within_reg and 9 or 6)
		elseif tonumber(pNumbers[1]) == PLATE_TYPE_MOTO then
			return utf8.sub(pNumbers[2], 1, 4) .." ".. utf8.sub(pNumbers[2], 5, 6)
		elseif tonumber(pNumbers[1]) == PLATE_TYPE_SPECIAL then
			return utf8.sub(pNumbers[2], 1, within_reg and utf8.len(pNumbers[2]) or -3)
		end
	end
	return sNumbers
end

Vehicle.GetVariant = function(self)
	return 1
	--return ( getVehicleModelVariant( self ) or 0 ) + 1
end

Vehicle.GetFuelLoss = function(self)
	return getElementData( self,"_fuelloss") or 5.0
end

Vehicle.IsBroken = function(self)
	return self.health <= VEHICLE_HEALTH_BROKEN
end

Vehicle.IsStatic = function(self)
	return getElementData( self,"bStatic")
end

Vehicle.GetOwnerPID = function(self)
	return getElementData( self,"_ownerpid")
end

Vehicle.GetOwnerID = function(self)
	local owner_id = tonumber( string.match( self:GetOwnerPID() or "", "p:(%d+)" ) )
	return owner_id ~= 0 and owner_id
end

Vehicle.GetTempOwnersPID = function(self)
	return getElementData( self,"_tempowners") or {}
end

Vehicle.GetWindowsColor = function(self)
	return getElementData( self,"_wincolor") or { 0, 0, 0, 120 }
end

Vehicle.GetPrice = function(self, variant)
	local variant = variant or self:GetVariant() or 1
	return ( VEHICLE_CONFIG[self.model].variants[variant] or VEHICLE_CONFIG[self.model].variants[1] ).cost or 0
end

-- TODO учёт тюнинга?
Vehicle.GetTotalPrice = function( self)
	return self:GetPrice()
end


---------------------------
---- Внутренний тюнинг ----
---------------------------

Vehicle.GetTier = function( self )
	local tier_preset = tonumber( self:GetConfigData( "tier" ) )
	if tier_preset then return tier_preset end

	local tiers = {
		[ 1 ] = 0,
		[ 2 ] = 184,
		[ 3 ] = 219,
		[ 4 ] = 249,
		[ 5 ] = 279,
	}

	local tier = 1

	local max_speed = tonumber( self:GetConfigData( "max_speed" ) ) or 0

	while true do
		if tiers[ tier + 1 ] and tiers[ tier + 1 ] < max_speed then
			tier = tier + 1
		else
			break
		end
	end

	return tier
end

-- Оригинальный конфиг из Globals или хендлинг
Vehicle.GetOriginalConfig = function( self, conf_name )
	local variant = self:GetVariant( )
	local model = self.model
	local conf = variant and VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].variants and ( VEHICLE_CONFIG[ model ].variants[ variant ] or VEHICLE_CONFIG[ model ].variants[ 1 ] ) or { }
	return conf and conf.handling and conf.handling[ conf_name ] or getVehicleHandling( self )[ conf_name ]
end

-- Взятие инфы из машины
Vehicle.GetConfigData = function( self, conf_name )
	if not VEHICLE_CONFIG[ self.model ] then return end
	local variant = self:GetVariant( )
	local conf = variant and VEHICLE_CONFIG[ self.model ].variants[ variant ] or VEHICLE_CONFIG[ self.model ].variants[ 1 ]
	return conf and conf[ conf_name ]
end

-- Кастомные множители деталей для машин
Vehicle.GetPartsMultiplier = function( self, conf_name )
	local conf = self:GetConfigData( "parts" )
	return conf and conf[ conf_name ]
end

-- Взятие статы машины
Vehicle.GetStats = function( self, parts, only_parts )
	local maxspeed 		= self:GetConfigData( "stats_speed" ) or 0
	local acceleration 	= self:GetConfigData( "stats_acceleration" ) or 0
	local vehStatus     = self:GetProperty( "statusNumber" ) or 0
	local controllability, clutch, slip = 0, 0, 0 -- TODO: add

	if vehStatus == STATUS_TYPE_HARD then
		maxspeed = maxspeed - 10
	elseif vehStatus == STATUS_TYPE_CRIT then
		maxspeed = maxspeed - 20
	end

	if only_parts then
		maxspeed = 0
		acceleration = 0
		controllability = 0
		clutch = 0
		slip = 0
	end

	if parts then
		for _, v in pairs( parts ) do
			local dataType = type( v )
			local part = getTuningPartByID( dataType == "table" and v.id or v )

			if ( dataType == "table" and ( v.damaged or 0 ) <= 0 ) or dataType ~= "table" then
				maxspeed 		= maxspeed + part.speed
				acceleration 	= acceleration + part.acceleration
				controllability = controllability + part.controllability
				clutch 			= clutch + part.clutch
				slip 			= slip + part.slip
			end
		end
	end

	return math.floor( maxspeed ), math.floor( acceleration ), math.floor( controllability ),
		math.floor( clutch ), math.floor( slip )
end

Vehicle.GetStatsSum = function( self )
	local maxspeed, acceleration, handling = self:GetStats( self:GetParts() )

	return ( maxspeed + acceleration + handling ) or 0
end

Vehicle.ApplyHeadlightsColor = function( self, r, g, b )
	setVehicleHeadLightColor( self, r, g, b )
end

Vehicle.ApplyHydraulics = function( self, state )
	
	local current_state = getVehicleUpgradeOnSlot( self, 9 )

	if state then
		if current_state then removeVehicleUpgrade( self, 1087 ) end
		addVehicleUpgrade( self, 1087 )
	
	elseif not current_state then
		addVehicleUpgrade( self, 1087 )
		removeVehicleUpgrade( self, 1087 )

	else
		removeVehicleUpgrade( self, 1087 )

	end
end

Vehicle.ApplyWheels = function( self, value )
	if value == nil then value = false end
	if value then
		addVehicleUpgrade( self, value )
	else
		local wheels_installed = getVehicleUpgradeOnSlot( self, 12 )
		if wheels_installed and wheels_installed > 0 then
			removeVehicleUpgrade( self, wheels_installed )
		end
	end
	return value
end

Vehicle.ApplyHeightLevel = function( self, level )
	local offsets = {
		[ 1 ] = self:GetOriginalConfig( "height_level_1" ) or 0.1,
		[ 2 ] = self:GetOriginalConfig( "height_level_2" ) or -0.07,
		[ 3 ] = self:GetOriginalConfig( "height_level_3" ) or -0.11,
	}

	local upper_limits = {
		[ 1 ] = self:GetOriginalConfig( "upper_limit_1" ) or 0.05,
	}

	local level = level and offsets[ level ] and level or 0

	local default_value = self:GetOriginalConfig( "suspensionLowerLimit" )
	setVehicleHeightLevel( self, ( offsets[ level ] and ( default_value + offsets[ level ] ) or 0 ), upper_limits[ level ] or 0 )

	return level
end

Vehicle.ReapplyHeightLevel = function( self )
	self:ApplyHeightLevel( self:GetHeightLevel( ) )
end

Vehicle.FixHydraulics = function( self )
	self:ApplyHydraulics( not self:GetHydraulics( ) )
	self:ApplyHydraulics( self:GetHydraulics( ) )
end

function CompareVinyl( v1, v2 )
	if not v1 or not v2 then return end

	local v1 = table.copy( FixTuningPart( v1 ) )
	local v2 = table.copy( FixTuningPart( v2 ) )

	v1[ P_COEFFICIENT ], v2[ P_COEFFICIENT ] = nil, nil
	v2[ P_LAYER ] = v1[ P_LAYER ]

	return table.compare( v1, v2 )
end

function FixTuningPart( part )
	local part_new = { }
	for i, v in pairs( part ) do
		part_new[ tonumber( i ) or i ] = tonumber( v ) or v
	end

	if type( part_new[ P_PRICE ] ) == "string" then 
		local n = string.gsub( part_new[ P_PRICE ], "%s+", "" ):gsub( " ", "" )
		part_new[ P_PRICE ] = tonumber( n )
	end

	return part_new
end

-------------------------------------------
---- Внутренний тюнинг фффлайн функции ----
-------------------------------------------

string.GetTier = function( self, variant )
	local tier_preset = tonumber( self:GetVehicleConfigData( "tier", variant ) )
	if tier_preset then return tier_preset end

	local tier = 1
	local tiers = {
		[ 1 ] = 0,
		[ 2 ] = 184,
		[ 3 ] = 219,
		[ 4 ] = 249,
		[ 5 ] = 279,
	}

	local max_speed = tonumber( self:GetVehicleConfigData( "max_speed", variant ) ) or 0
	while true do
		if tiers[ tier + 1 ] and tiers[ tier + 1 ] < max_speed then
			tier = tier + 1
		else
			break
		end
	end

	return tier
end

string.GetVehicleConfigData = function( self, conf_name, variant )
	local vehicle_model = tonumber( self )
	if not VEHICLE_CONFIG[ vehicle_model ] then return end
	local conf = variant and VEHICLE_CONFIG[ vehicle_model ].variants[ variant ] or VEHICLE_CONFIG[ vehicle_model ].variants[ 1 ]
	return conf and conf[ conf_name ]
end