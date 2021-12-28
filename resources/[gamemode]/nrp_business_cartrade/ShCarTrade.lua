
CAR_TRADE_NAMES = 
{
	carsale_gorki = "эконом-класса",
	carsale_mo 	  = "среднего и люкс класса",
}

CAR_TRADE_CLASSES =
{
	carsale_gorki = 
	{
		[ 1 ] = true,
		[ 2 ] = true,
		[ 3 ] = true,
		[ 4 ] = true,
		[ 5 ] = true,
		[ 6 ] = true,
	},
	carsale_mo = 
	{
		[ 3 ] = true,
		[ 4 ] = true,
		[ 5 ] = true,
	}
}

function getCarTradeNameByVehicleClass( target_class )
	local result = ""
	for trade_id, trade_classes in pairs( CAR_TRADE_CLASSES ) do
		for class in pairs( trade_classes ) do
			if class == target_class then
				result = CAR_TRADE_NAMES[ trade_id ]
				break
			end
		end
	end
	return result
end

-- Подготавливаем данные, отображаемые при продаже
function formatVehicleDescriptionData( veh, trade_data )
	if not isElement( veh ) then return end

	local data = {}
	data.veh = veh

	local model = veh.model
	local conf = VEHICLE_CONFIG[ model ]
	if not conf then return end
	data.name = conf.model
	
	local variant = trade_data.variant
	local conf_variant = conf.variants[ variant ]
	if not conf_variant then return end

	for k, v in pairs( conf_variant ) do
		if type( v ) ~= "table" then
			data[ k ] = v
		end
	end
	
	local assoc = { rwd = "Задний", fwd = "Передний", }
	data.drivetype = assoc[ veh.handling.driveType ] or "Полный"

	data.tuninglist = {}

	return data
end