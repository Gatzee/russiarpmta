loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ib" )

local DEFAULT_SPEED_LIMIT = 100

SPEED_RADARS = {}

function OnClientResourceStart()
	for i, conf in pairs( SPEED_RADAR_CONFIG ) do
		SpeedRadar( conf )
	end

	ReplaceModel()
	CreateRadarObjects()
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

SpeedRadar = function( conf )
	local self = conf
	self.x = self.x or 0
	self.y = self.y or 0
	self.z = self.z or 0
	self.radius = self.radius or 20
	self.detect_radius = self.detect_radius or self.radius+180
	self.last_fine = getTickCount()
	self.timeout_time = 5000

	self.speed_limit = (self.speed_limit or DEFAULT_SPEED_LIMIT) + 20
	self.velocity_limit = self.speed_limit / 180

	self.OnHit = function( self, element )
		local ticks = getTickCount()
		if ticks < self.last_fine then return end
		self.last_fine = ticks + self.timeout_time

		local fVelocity = element.velocity.length

		if fVelocity > self.velocity_limit then
			local data = 
			{
				speed = math.floor( fVelocity*180 ),
				speed_limit = self.speed_limit - 20,
				number_plate = element:GetNumberPlateHR( true ) or "НЕОПОЗНАН",
				fine = FINES_LIST[9].cost,
			}

			CreateFinePhoto( data )

			triggerServerEvent( "OnPlayerReceiveSpeedRadarFine", resourceRoot, element )
			return true
		end

		return false
	end

	self.colsphere = createColSphere( self.x, self.y, self.z, self.radius )
	self.detect_colsphere = createColSphere( self.x, self.y, self.z, self.detect_radius )

	addEventHandler("onClientColShapeHit", self.colsphere, function( element, dim )
		if not dim then return end
		
		local pVehicle = localPlayer.vehicle
		if not pVehicle then return end

		if element ~= pVehicle then return end
		if pVehicle.controller ~= localPlayer then return end
		if IsSpecialVehicle( pVehicle.model ) then return end

		self:OnHit( element )
	end)

	addEventHandler("onClientColShapeHit", self.detect_colsphere, function( element, dim )
		if not dim then return end
		
		local pVehicle = localPlayer.vehicle
		if not pVehicle then return end

		if element ~= pVehicle then return end
		if pVehicle.controller ~= localPlayer then return end
		if IsSpecialVehicle( pVehicle.model ) then return end
		if not pVehicle:GetOwnerID() then return end

		OnPlayerDetectZoneEnter( { vec_position = source.position, radius = self.radius, limit = self.velocity_limit } )
	end)

	addEventHandler("onClientColShapeLeave", self.detect_colsphere, function( element, dim )
		if not dim then return end
		
		local pVehicle = localPlayer.vehicle
		if not pVehicle then return end

		if element ~= pVehicle then return end
		if pVehicle.controller ~= localPlayer then return end
		if IsSpecialVehicle( pVehicle.model ) then return end
		if not pVehicle:GetOwnerID() then return end

		OnPlayerDetectZoneLeave()
	end)

	table.insert( SPEED_RADARS, self )

	self.id = #SPEED_RADARS

	return self
end

--[[
addEventHandler("onClientRender", root, function()
	for k,v in pairs(SPEED_RADAR_CONFIG) do
		local sx, sy = getScreenFromWorldPosition( v.x, v.y, v.z )
		if sx and sy then
			dxDrawRectangle( sx-2, sy-2, 4, 4, tocolor( 200, 50, 50 ) )
			dxDrawText( k, sx+4, sy)
		end
	end
end)
]]