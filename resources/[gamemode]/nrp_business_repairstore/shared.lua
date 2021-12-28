loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

function GetEngineRepairCost( vehicle, repair_price )
	return math.floor( ( 1 - vehicle.health / 1000 ) * repair_price * VEHICLE_REPAIR_PARTS.engine )
end

function GetWheelsRepairCost( vehicle, repair_price )
	local wheel_states = { vehicle:getWheelStates( ) }
	local cost_coef = 0
	for k, v in pairs( wheel_states ) do
		if v > 0 then cost_coef = cost_coef + 0.25 end
	end

	if cost_coef == 0 then return 0 end
	return math.floor( repair_price * VEHICLE_REPAIR_PARTS.wheels * cost_coef )
end

function GetRepairPrice( vehicle )
	local variant = variant or vehicle:GetVariant( ) or 1
	local variant_data = VEHICLE_CONFIG[ vehicle.model ].variants[ variant ] or VEHICLE_CONFIG[ vehicle.model ].variants[ 1 ]
	local vehicle_price = variant_data.cost or 0

	local repair_coeff = 0
	for i = 1, #VEHICLE_REPAIR_COEFF do
		local threshold = VEHICLE_REPAIR_RANGE[ i ]
		if vehicle_price < threshold then
			repair_coeff = VEHICLE_REPAIR_COEFF[ i ] / 100
			break
		end
	end

	return vehicle_price * repair_coeff * 1.05
end