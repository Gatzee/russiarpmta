function onSVehiclesListRequest_handler()
    local player = client or source

    local vehicles = player:GetSpecialVehicles( )

	local vehicles_list = {}
	
	local only_special_type = {
		airplane = true;
		helicopter = true;
        boat = true;
	}

	for i, v in pairs( vehicles ) do
		if only_special_type[ IsSpecialVehicle( v[ 2 ] ) ] then
			local name = VEHICLE_CONFIG[ v[2] ].model or "Неизвестный"
			local element = GetVehicle( v[1] )
			local distance = element and math.floor( ( player.position - element.position ):getLength() ) or false
			local changed = false
			while utf8.len( name ) > 14 do
				name = utf8.sub( name, 1, -2 )
				changed = true
			end
			if changed then name = name .. "..." end
			table.insert( vehicles_list, { element, name, v[2], distance, 3000, v[1] } )
		end
    end

    triggerClientEvent( { source }, "onSVehiclesListRequestCallback", resourceRoot, vehicles_list )
end
addEvent( "onSVehiclesListRequest", true )
addEventHandler( "onSVehiclesListRequest", root, onSVehiclesListRequest_handler )

function onSVehicleRequest_handler( vehicle_id )
    local player = client

    if isPedDead( player ) then
        player:ShowError( "Зачем мёртвому транспорт?" )
        return
    end

    if player:getData("jailed") then
        player:ShowError( "Заключённым услуги не оказываем!" )
        return
    end

    local price = 3000

    local money = player:GetMoney()

    if price > money then
        player:ErrorWindow( "Недостаточно средств!" )
        return
    end

    triggerEvent("CreateSpecialVehicle", player, vehicle_id)

    triggerClientEvent( player, "ShowPhoneUI", resourceRoot, false )
end
addEvent( "onSVehicleRequest", true )
addEventHandler( "onSVehicleRequest", root, onSVehicleRequest_handler )