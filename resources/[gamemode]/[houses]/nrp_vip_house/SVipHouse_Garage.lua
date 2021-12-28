function ShowUIGarageToPlayer( player, house_id )
    local vehicles_list = { }
    local vehicles = player:GetVehicles( true )
    for i, vehicle in pairs( vehicles ) do
        table.insert( vehicles_list,
        {
            name = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].model or ( "No name. ID:".. vehicle.model ),
            parked = vehicle:GetParked(),
            confiscated = vehicle:IsConfiscated();
            price = 3000,
            numberplate = vehicle:GetNumberPlateHR( ); 
        } )
    end
    local slots, bought_slots = exports.nrp_apartment:GetPlayerHaveVehiclesSlots( player, true )
    triggerClientEvent( player, "ShowUIGarage", player, house_id, slots, bought_slots, vehicles_list )
end

function PlayerEnterParkingMarker_handler( house_id )
    if PlayerHasAccesToVipHouse( client, house_id ) then
        local paid_days = VIP_HOUSES[ house_id ][ "paid_days" ]
        if paid_days < 0 then
            return client:ShowInfo( "Оплати долг за дом!" )
        end
        local vehicle = client.vehicle
        if vehicle then
            if vehicle:GetOwnerID( ) == client:GetUserID( ) or vehicle:GetOwnerID( ) == client:GetPermanentData( "wedding_at_id" ) then
                vehicle:SetParked( true )
                client:InfoWindow( "Ты успешно припарковал машину!" )      
            else
                client:ErrorWindow( "Ты не владеешь этой машиной" )
            end    
        else
            ShowUIGarageToPlayer( client, house_id )
        end
    end
end
addEvent( "PlayerEnterParkingMarker", true )
addEventHandler( "PlayerEnterParkingMarker", root, PlayerEnterParkingMarker_handler )

function PlayerWantTeleportParkedVehicleByHouseName_handler( id, i )
    local house = VIP_HOUSES[ id ]
    if not house then return end
  
    local vehicles = client:GetVehicles( true )
    local vehicle = vehicles[ i ]
    if not vehicle then return end
  
    local position = house.config.parking_marker_position
    local price = 3000
    if ( Vector3( position.x, position.y, position.z ) - vehicle.position ).length < 10 then
        price = 500
        end
        
        if client:TakeMoney( price, "apartments_parking_vehicle_teleport", "viphouse" ) then
        if vehicle:getHealth( ) <= 350.0 then
          vehicle:setHealth( 350.0 )
        end
        vehicle:SetParked( true )
        client:ShowSuccess( "Ты успешно эвакуировал транспорт на парковку" )
    end
    
    ShowUIGarageToPlayer( client, house.hid )
end
addEvent( "PlayerWantTeleportParkedVehicleByHouseName", true )
addEventHandler( "PlayerWantTeleportParkedVehicleByHouseName", root, PlayerWantTeleportParkedVehicleByHouseName_handler )

function PlayerWantTakeParkedVehicleByHouseName_handler( id, i )
    local house = VIP_HOUSES[ id ]
    if not house then return end

    local vehicles = client:GetVehicles( true )
    local vehicle = vehicles[ i ]
    if not vehicle then return end

    local position = house.config.parking_marker_position
    vehicle:SetParked( false, Vector3( position.x, position.y, position.z ), Vector3( 0, 0, position.rot or 90 ) )
    client:warpIntoVehicle( vehicle )
end
addEvent( "PlayerWantTakeParkedVehicleByHouseName", true )
addEventHandler( "PlayerWantTakeParkedVehicleByHouseName", root, PlayerWantTakeParkedVehicleByHouseName_handler )