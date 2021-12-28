local ignored_vehicles_list = 
{
	[ 468 ] = true, -- Железный конь
	[ 471 ] = true, -- Квадрацикл
	[ 520 ] = true, -- Гидра
}

local PREVIEW_DATA = {}
function OnPlayerStartVehiclePreview( pPlayer, race_type )
	removePedFromVehicle( pPlayer )
	PREVIEW_DATA[ pPlayer ] = GetPlayerAvailableVehicles( pPlayer, race_type )
	return PREVIEW_DATA[ pPlayer ]
end

function IsVehicleCanRace( vehicle )
	return isElement(vehicle) 
		   and VEHICLE_CONFIG[ vehicle.model ]
		   and not vehicle:GetBlocked() 
		   and not ignored_vehicles_list[ vehicle.model ]
		   and not vehicle:getData( "tow_evac_added" )
		   and not vehicle:getData( "tow_evacuated_real" )
		   and not vehicle:getData( "work_lobby_id" )
end

function GetPlayerAvailableVehicles( pPlayer, race_type )
	local pVehicles = pPlayer:GetVehicles()
	local pAvailableVehicles = {}
	for k, vehicle in pairs( pVehicles ) do
		local iVehStats = vehicle:GetStatsSum()

		if IsVehicleCanRace( vehicle ) then
			-- Нет пассажиров
			local pOccupants = getVehicleOccupants( vehicle )
			local iOccupants = 0

			for i, player in pairs( pOccupants ) do
				if player ~= pPlayer then
					iOccupants = iOccupants + 1
				end
			end

			local veh_variant = vehicle:GetVariant()
			local is_drift_vehicle = VEHICLE_CONFIG[ vehicle.model ].variants[ veh_variant ].handling.driveType ~= "fwd"

			if iOccupants == 0 and not vehicle:getData( "being_confiscated" ) and (race_type ~= RACE_TYPE_DRIFT or is_drift_vehicle) then
				local iSpeed, iAcceleration, iHandling = vehicle:GetStats( vehicle:GetParts() )
				local pVehicleData = 
				{
					element = vehicle, 
					stats = { iSpeed, iAcceleration, iHandling }, 
					state = GetVehicleState( vehicle ),
					client_data = 
					{
						color = { getVehicleColor( vehicle, true ) },
						headlight_color = { getVehicleHeadLightColor( vehicle ) },
						windows_color = vehicle:GetWindowsColor(),
						external_tuning = vehicle:GetExternalTuning(),
						number_plate = vehicle:GetNumberPlate( false, true ),
						upgrades =  getVehicleUpgrades( vehicle ),
						vinyls = vehicle:GetVinyls(),
					},
				}
				table.insert( pAvailableVehicles, pVehicleData )
			end
		end
	end
	return pAvailableVehicles
end

function OnPlayerStopVehiclePreview( pPlayer, pVehicle )
	PREVIEW_DATA[ pPlayer ] = nil
end
addEvent( "RC:OnPlayerStopVehiclePreview", true )
addEventHandler( "RC:OnPlayerStopVehiclePreview", resourceRoot, OnPlayerStopVehiclePreview )

local function OnPlayerQuit( pPlayer )
	local pPlayer = isElement( pPlayer ) and pPlayer or source
	if PREVIEW_DATA[ pPlayer ] then
		OnPlayerStopVehiclePreview( pPlayer )
		pPlayer.dimension = 0
	end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999" )