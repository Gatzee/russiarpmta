local SPECIAL_VEHICLES = {}

local MAX_INACTIVITY_TIME = 1 * 60 * 1000

local SPECIAL_VEHICLE_SPAWNS = -- TODO ( Другой формат )
{
	["airplane"] = 
	{
		-- Горки
		{ x = 2340.924, y = -2484.64, z = 21, rz = 245 },
		{ x = 2364.635, y = -2457.952, z = 21, rz = 245 },
		{ x = 2376.716, y = -2432.843, z = 21, rz = 245 },
		{ x = 2390.541, y = -2405.824, z = 21, rz = 245 },

		-- Кантри-сайд
		{ x = -2698.095, y = 376.614, z = 16, rz = 330 },
		{ x = -2657.634, y = 359.336, z = 16, rz = 330 },
		{ x = -2663.038, y = 467.9, z = 16, rz = 130 },
		{ x = -2634.951, y = 447.663, z = 16, rz = 130 },
	},

	["helicopter"] = 
	{
		-- Горки
		{ x = 2312.242, y = -2454.204, z = 21.5, rz = 245 },
		{ x = 2326.845, y = -2433.065, z = 21.5, rz = 245 },
		{ x = 2341.406, y = -2415.339, z = 21.5, rz = 245 },
		{ x = 2354.319, y = -2381.831, z = 21.5, rz = 245 },

		-- Кантри-сайд
		{ x = -2518.581, y = 534.943, z = 16, rz = 145 },
		{ x = -2501.483, y = 524.469, z = 16, rz = 145 },
		{ x = -2479.783, y = 512.668, z = 16, rz = 145 },
		{ x = -2477.431, y = 481.469, z = 16, rz = 55 },

		-- Вилла ОКО
		{ x = 1274.415, y = -812.49, z = 16.5, rz = 270,
			f_condition = function( player )
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 1 then
						return true
					end
				end
			end 
		},

		-- Вилла 4
		{ x = -29.48, y = -511.672, z = 21.5, rz = 180,
			f_condition = function( player ) 
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 11 then
						return true
					end
				end
			end 
		},

		-- Вилла 5
		{ x = -14.431, y = -588.423, z = 21.5, rz = 200,
			f_condition = function( player ) 
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 12 then
						return true
					end
				end
			end 
		},

		-- Вилла 11
		{ x = 95.054, y = -711.022, z = 21.5, rz = 250,
			f_condition = function( player ) 
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 18 then
						return true
					end
				end
			end 
		},

		-- Вилла 12
		{ x = 180.549, y = -719.211, z = 21.5, rz = 270,
			f_condition = function( player ) 
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 19 then
						return true
					end
				end
			end 
		},

		-- Вилла 13
		{ x = 239.662, y = -717.343, z = 21.5, rz = 270,
			f_condition = function( player ) 
				for i, id in ipairs( player:getData( "viphouse" ) or {} )do
					if id == 20 then
						return true
					end
				end
			end 
		},
	},

	["boat"] = {
		{ x = 1480.277, y = -2536.081, z = 0, rz = 143 },
		{ x = 1493.64, y = -2546.151, z = 0, rz = 143 },
		{ x = -811.655, y = -2089.029, z = 0, rz = 180 },
		{ x = -795.107, y = -2089.34, z = 0, rz = 180 },
		{ x = 1155.978, y = -649.188, z = 0, rz = 90 },
		{ x = 1156.646, y = -665.276, z = 0, rz = 90 },
		{ x = -383.502, y = -1202.261, z = 0, rz = 59 },
		{ x = -374.954, y = -1187.898, z = 0, rz = 59 },
		{ x = -1773.786, y = 842.937, z = 0, rz = 339 },
		{ x = -1789.088, y = 847.552, z = 0, rz = 339 },
		{ x = -2917.23, y = -2080.996, z = 0, rz = 124 },
		{ x = -2908.024, y = -2094.443, z = 0, rz = 124 },

		-- Подмосковье
		{ x = 186.35, y = 545.218, z = 0, rz = 313 },
		{ x = 176.045, y = 557.897, z = 0, rz = 313 },
		{ x = -1743.417, y = 1169.839, z = 0, rz = 45 },
		{ x = -1753.726, y = 1157.747, z = 0, rz = 45 },
		{ x = -406.043, y = 125.77, z = 0, rz = 180 },
		{ x = -389.85, y = 126.037, z = 0, rz = 180 },
		{ x = -121.198, y = -357.729, z = 0, rz = 80 },
		{ x = -122.544, y = -373.931, z = 0, rz = 80 },
		{ x = -91.073, y = -760.473, z = 0, rz = 130 },
		{ x = -78.238, y = -771.499, z = 0, rz = 130 },
		{ x = 595.311, y = -827.525, z = 0, rz = 170 },
		{ x = 611.938, y = -828.231, z = 0, rz = 170 },
		{ x = 900.53, y = -304.323, z = 0, rz = 270 },
		{ x = 897.919, y = -288.358, z = 0, rz = 270 },

		-- МСК
		{ x = 1957.703, y = 2648.127, z = 0, rz = 180 },
		{ x = 1957.703, y = 2742.127, z = 0, rz = 180 },
		{ x = 312.239, y = 1938.031, z = 0, rz = 90 },
		{ x = -35.834, y = 1915.295, z = 0, rz = 90 },
		{ x = -508.850, y = 1754.857, z = 0, rz = 290 },
		{ x = -947.342, y = 1753.934, z = 0, rz = 230 },
		{ x = -1269.286, y = 2000.428, z = 0, rz = 230 },
	},
}

function OnSpecialVehicleDestroyed( pVehicle )
	local pVehicle = pVehicle or source
	SPECIAL_VEHICLES[pVehicle] = nil
end

function CreateSpecialVehicle( iVehicleID, position )
	local pPlayer = source and getElementType(source) == "player" and source
	local pVehicle

	if pPlayer then
		for k,v in pairs(pPlayer:GetSpecialVehicles()) do
			local vehicle = GetVehicle( v[1] )
			if isElement(vehicle) then
				DestroyVehicle( v[1] )
			end
		end

		LoadVehicle( iVehicleID, true, "CreateSpecialVehicleSuccess", { player = pPlayer }, "nrp_vehicle" )
	end
end
addEvent("CreateSpecialVehicle")
addEventHandler("CreateSpecialVehicle", root, CreateSpecialVehicle)

function CreateSpecialVehicleSuccess_handler( pVehicle, args, error_reason )
	local pPlayer = args.player

	if not isElement( pVehicle ) then
		if isElement( pPlayer ) and error_reason then
			pPlayer:ShowError( error_reason )
		end

		return
	end

	--проверка на то достаточно ли средств идет в SPhoneSVehicles.lua : ~51(в конце файла)
	pPlayer:TakeMoney( 3000, "special_transport_evacuation" )

	local position = position or GetNearestVehicleSpawnPosition( pPlayer or pVehicle, pVehicle.model )
	
	setElementPosition( pVehicle, position.x, position.y, position.z )
	setElementRotation( pVehicle, 0, 0, position.rz )
	setElementCollisionsEnabled(pVehicle, true)

	local fOldHealth = pVehicle.health
	fixVehicle(pVehicle)
	setElementFrozen(pVehicle, true)

	pVehicle.health = fOldHealth

	pVehicle.dimension = 0
	pVehicle.interior = 0

	if IsSpecialVehicle( pVehicle.model ) ~= "boat" then
		SPECIAL_VEHICLES[pVehicle] = 
		{
			inactive = true,
			created_in = getTickCount(),
		}

		addEventHandler("onVehicleEnter", pVehicle, OnSpecialVehicleEnter)
		addEventHandler("onVehicleExplode", pVehicle, OnSpecialVehicleBlown)

		setTimer(function( vehicle )
			if not isElement(vehicle) then return end
			if not SPECIAL_VEHICLES[vehicle] then return end

			if SPECIAL_VEHICLES[vehicle].inactive then
				local pOwner = GetPlayer( vehicle:GetOwnerID() )

				if pOwner then
					pOwner:ShowError("Ваш транспорт был убран с территории аэропорта за продолжительное ожидание")
				end

				DestroyVehicle( vehicle:GetID() )
			end

		end, MAX_INACTIVITY_TIME, 1, pVehicle)
	end

	if pPlayer then
		triggerClientEvent( pPlayer, "OnClientSpecialVehicleCreated", pPlayer, pVehicle )
	end
end
addEvent( "CreateSpecialVehicleSuccess" )
addEventHandler( "CreateSpecialVehicleSuccess", resourceRoot, CreateSpecialVehicleSuccess_handler )

function OnSpecialVehicleEnter( player, seat )
	if seat == 0 and player:GetUserID() == source:GetOwnerID() then
		player:GiveWeapon( 46, 1, true, true )
		SPECIAL_VEHICLES[source].inactive = false
		removeEventHandler("onVehicleEnter", source, OnSpecialVehicleEnter)
		setElementFrozen(source, false)
	end
end

function OnSpecialVehicleBlown()
	removeEventHandler("onVehicleExplode", source, OnSpecialVehicleBlown)
	source.health = 200
	DestroyVehicle( source:GetID() )
end

function GetNearestVehicleSpawnPosition( pPlayer, iModel )
	local sVehicleType = IsSpecialVehicle( iModel )
	local vecPosition = pPlayer.position

	if sVehicleType then
		local fMinDistance = math.huge
		local pZone = false
		for k,v in pairs( SPECIAL_VEHICLE_SPAWNS[sVehicleType] or {} ) do
			if not isAnythingWithinRange( Vector3( v.x, v.y, v.z ), 5 ) then
				if not v.f_condition or v.f_condition( pPlayer ) then
					local distance = ( Vector3( v.x, v.y, v.z ) - vecPosition ).length

					if distance <= fMinDistance then
						fMinDistance = distance
						pZone = v
					end
				end
			end
		end

		if not pZone then
			pZone = SPECIAL_VEHICLE_SPAWNS[sVehicleType][ math.random( 1, #SPECIAL_VEHICLE_SPAWNS[sVehicleType] ) ]
		end

		return pZone
	end
end

function OnSpecialVehicleBought()
	if isElement(source) then
		DestroyVehicle( source:GetID() )
	end
end
addEvent("OnSpecialVehicleBought", true)
addEventHandler("OnSpecialVehicleBought", root, OnSpecialVehicleBought)