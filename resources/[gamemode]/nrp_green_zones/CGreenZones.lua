loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")
Extend("Globals")
Extend("CVehicle")
Extend("ShVehicleConfig")
Extend("ShUtils")
Extend("ShVipHouses")

local player_current_zone = nil

local loaded_zones = {}
local loaded_zones_reverse = {}

local pWeaponsAllowedByDefault = { 
	[23] = true, 
	[41] = true,
}

local pFactionsAllowedByDefault = 
{
	[F_POLICE_PPS_NSK] = true,
	[F_POLICE_DPS_NSK] = true,
	[F_POLICE_PPS_GORKI] = true,
	[F_POLICE_DPS_GORKI] = true,
	[F_ARMY] = true,
	[F_FSIN] = true,
}
-- addCommandHandler("checking5", function(thePlayer)
-- 	local x, y, z = getElementPosition(localPlayer)
-- 	local tNeededCoordinates = {
-- 		x, y;
-- 		x + 50, y;
-- 		x + 50, y + 20;
-- 		x, y + 20;
-- 		x - 50, y + 20;
-- 		x - 50, y;
-- 		x - 50, y - 20;
-- 		x, y - 20;
-- 		x + 50, y - 20;
-- 	}
-- 	for i = 1, 9 do
-- 		outputChatBox(tostring(tNeededCoordinates[2*i - 1]) .. ", " .. tostring(tNeededCoordinates[2*i]) .. ";")
-- 	end
-- end )
function OnClientResourceStart()

	local tPeds = getElementsByType("ped")
	for _, ped in pairs( tPeds ) do
		if getElementInterior( ped ) == 0 then 

		local x, y, z = getElementPosition( ped )

		local tNeededCoordinates = {
			x, y;
			x + 10, y;
			x + 10, y + 10;
			x, y + 10;
			x - 10, y + 10;
			x - 10, y;
			x - 10, y - 10;
			x, y - 10;
		}
		table.insert( GREEN_ZONES, tNeededCoordinates )
		end
	end

	for _, v in pairs( VIP_HOUSES_LIST ) do -- экстерьеры
		local tInfo = v.relative_center
		if tInfo and v.class == "Вилла" then
			local x, y, z = tInfo.x, tInfo.y, tInfo.z

			y = y - 7
			local tNeededCoordinates = {
				x, y;
				x + 20, y;
				x, y + 20;
				x - 20, y;
				x, y - 20;
			}
			table.insert(GREEN_ZONES, tNeededCoordinates)
		end
	end

	for _, info in ipairs(GREEN_ZONES) do
		local polygon = createColPolygon( unpack( type( info.positions ) == "table" and info.positions or info ) )
		polygon.dimension = info.dimension or 0
		polygon.interior = info.interior or 0
		
		table.insert(loaded_zones, polygon)
		loaded_zones_reverse[ polygon ] = info

		addEventHandler("onClientColShapeHit", polygon, OnElementGreenZoneEnter)
		addEventHandler("onClientColShapeLeave", polygon, OnElementGreenZoneExit)

		toggleControl("action", false)
	end
	
	setTimer( CheckCurrentZone, 1000, 0 )
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateSphericalGreenZone( data )
	local sphere = createColSphere( data.position, data.size )
	sphere.dimension = data.dimension or 0
	sphere.interior = data.interior or 0

	table.insert(loaded_zones, sphere)
	loaded_zones_reverse[ sphere ] = data

	addEventHandler("onClientColShapeHit", sphere, OnElementGreenZoneEnter)
	addEventHandler("onClientColShapeLeave", sphere, OnElementGreenZoneExit)
end
addEvent("CreateSphericalGreenZone", true)
addEventHandler("CreateSphericalGreenZone", root, CreateSphericalGreenZone)

function CheckCurrentZone()
	local matched_zone = false
	local playerInterior = getElementInterior( localPlayer )

	if playerInterior ~= 0 then
		matched_zone = playerInterior
	else
		for i, v in pairs( loaded_zones ) do
			if isElementWithinColShape( localPlayer, v ) then
				if type( loaded_zones_reverse[ v ].custom_check ) == "function" then
					if loaded_zones_reverse[ v ].custom_check( v, localPlayer ) then
						matched_zone = v
						break
					end
				else
					local matches_dimension = localPlayer.dimension == v.dimension or v.dimension == 1337
					--local matches_interior = localPlayer.interior == v.interior
					if matches_dimension then
						matched_zone = v
						break
					end
				end
			end
		end
	end

	if matched_zone then
		if player_current_zone ~= matched_zone then
			OnElementGreenZoneExit( localPlayer, nil, player_current_zone )
		end
		OnElementGreenZoneEnter( localPlayer, true, matched_zone )
	else
		if player_current_zone then
			OnElementGreenZoneExit( localPlayer, nil, player_current_zone )
		end
	end
end

function OnElementGreenZoneEnter(element, dim, zone)
	local zone = zone or source
	if not dim or not isElement( element ) then return end	

	if getElementType(element) == "vehicle" and element:GetSpecialType() then
		setVehicleDamageProof( element, true )
	end

	if element ~= localPlayer then return end
	if localPlayer:getData("fc_fighting") then return end
	if localPlayer:getData("in_clan_event_lobby") then return end
	if localPlayer:getData("in_hash_lab") then return end

	local current_quest = localPlayer:getData( "current_quest" )
	if current_quest and current_quest.id == "return_of_property" then return end
	
	if not player_current_zone then
		addEventHandler( "onClientPlayerDamage", localPlayer, cancelEvent )
		element:setData( "_greenzone", true, false )
		player_current_zone = zone
	end

	StartRenderFixSafeZones()
	triggerEvent("OnElementGreenZoneEnter", localPlayer)
end

-- Рендер блокировки оружия для фракций

function StartRenderFixSafeZones()
	StopRenderFixSafeZones()
	addEventHandler( "onClientPreRender", root, RenderFixSafeZones )
end

function StopRenderFixSafeZones()
	removeEventHandler( "onClientPreRender", root, RenderFixSafeZones )
end

function RenderFixSafeZones()
	if localPlayer:getData("fc_fighting") then return end
	if localPlayer:getData("in_clan_event_lobby") then return end

	local weapon = localPlayer:getWeapon()
	local faction = localPlayer:GetFaction()
	local zone
	if type( player_current_zone ) == "number" then
		zone = {}
	else
		zone = loaded_zones_reverse[player_current_zone]
	end

	local allowed_weapons = zone.weapons or pWeaponsAllowedByDefault
	local allowed_factions = zone.factions or pFactionsAllowedByDefault
	
	local is_fire_allowed = ( allowed_weapons[ weapon ] or allowed_factions[ faction ] ) 
							and not localPlayer:getData( "jailed" ) 
							and not localPlayer:IsHandcuffed( ) 
							and not localPlayer:getData( "photo_mode" ) 
							and not localPlayer:getData( "in_casino" ) 

	if is_fire_allowed then
		if weapon ~= 23 then
			toggleControl( "fire", true )
		end
		toggleControl( "aim_weapon", true )
	else
		toggleControl( "fire", false )
		toggleControl( "aim_weapon", false )
	end

	local allow_weapon_switch = not localPlayer:getData("in_casino")

	toggleControl( "next_weapon", allow_weapon_switch )
	toggleControl( "previous_weapon", allow_weapon_switch )
end


function OnElementGreenZoneExit( element, dim, zone )
	if getElementType(element) == "vehicle" and element:GetSpecialType() then
		setVehicleDamageProof( element, false )
	end

	if element ~= localPlayer then return end
	if localPlayer:getData("fc_fighting") then return end
	local weapon = localPlayer:getWeapon()

	StopRenderFixSafeZones()
	removeEventHandler("onClientPlayerDamage", localPlayer, cancelEvent)
	player_current_zone = nil
	element:setData( "_greenzone", false, false )
	if weapon ~= 23 then
		toggleControl("fire", true)
	end
	--toggleControl("action", true)
	toggleControl("aim_weapon", true)
	toggleControl("next_weapon", true)
	toggleControl("previous_weapon", true)
	triggerEvent("OnElementGreenZoneExit", localPlayer)
end

function OnClientVehicleDamage()
	local sType = source:GetSpecialType()
	if sType ~= "airplane" and sType ~= "helicopter" then
		local count = 0
		for i, v in pairs( getVehicleOccupants( source ) ) do
			count = count + 1
		end
		if count <= 0 then
			cancelEvent()
		else
			local fault = true
			if source:GetID() and source:GetID() < 0 then
				fault = false
			end
			if fault then
				for s, player in pairs( getVehicleOccupants( source ) ) do
					if source:IsOwnedBy( player, true ) then
						fault = false
						break
					end
				end
			end
            if fault then cancelEvent(); end
		end
		for _, polygon in pairs( loaded_zones ) do
			if source:isWithinColShape( polygon ) and source.dimension <= 2 then
				cancelEvent()
				return
			end
		end
	else
		local is_in_colshape = false
		for _, polygon in pairs( loaded_zones ) do
			if source:isWithinColShape( polygon ) and source.dimension <= 2 then
				is_in_colshape = true
				break
			end
		end
		-- Если игрок не в зеленой зоне
		if not is_in_colshape then
		if source:GetProperty("br_vehicle") then return end

			if weapon == 0 then
				cancelEvent()
			end
			local owner_id = source:GetOwnerID()
			if sType then
				if sType == "airplane" or sType == "helicopter" then
					if owner_id then
						local pContoller = source.controller
						if isElement(pContoller) then
							if not source:IsOwnedBy( pContoller, true ) then 
								cancelEvent()
							end
						else
							if isVehicleOnGround( source ) then
								cancelEvent()
							end
						end
					end
					return
				end
			end

			if owner_id then
				local pPlayer = source.controller
				if pPlayer then
					if not source:IsOwnedBy( pPlayer, true ) then
						cancelEvent()
					end
				else
					cancelEvent()
				end
			else
				if not getVehicleController( source ) then
					cancelEvent()
				end
			end
		end
	end
end
addEventHandler("onClientVehicleDamage", root, OnClientVehicleDamage, true, "high+1000")

function OnResourceStop()
	if player_current_zone then 
		OnElementGreenZoneExit( localPlayer, nil, player_current_zone )
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, OnResourceStop )

-- addCommandHandler("checking_3", function(thePlayer)
-- 	local tmp = math.random(1,3)
-- 	setElementPosition(localPlayer, 469.38028, -1471.987061, 23.5)
-- 	setElementHealth(localPlayer,100)
-- 	setElementInterior(localPlayer,0)
-- 	setElementDimension(localPlayer,0)
-- 	for i, v in pairs(getElementsByType("ped")) do
-- 		local x, y, z = getElementPosition(v)
-- 		local pol = createColPolygon(x, y, x + 10, y, x, y + 10, x - 10, y, x, y - 10 )
-- 		iprint(pol)
-- 		-- if i == tmp then
-- 		-- 	local x, y, z = getElementPosition(v)
-- 		-- 	local interior = getElementInterior(v)
-- 		-- 	local dimension = getElementDimension(v)
-- 		-- 	setElementInterior(localPlayer,interior)
-- 		-- 	setElementDimension(localPlayer,dimension)
-- 		-- 	setElementPosition(localPlayer, x, y, z)
-- 		-- 	break
-- 		-- end
-- 	end
-- 	addEventHandler("onClientColShapeHit", resourceRoot, function()
-- 		iprint("Zashel")
	
-- 	end )
-- 	addEventHandler("onClientColShapeLeave", resourceRoot, function()
-- 		iprint("Ushel")
	
-- 	end )
-- end )