FORBIDDEN_VEHICLES = {
    [ 468 ] = true, -- Мопед
    [ 471 ] = true, -- Квадрик
    [ 520 ] = true, -- Гидра
    [ 571 ] = true, -- Картинг
    [ 424 ] = true, -- Багги
}

ALLOWED_TYPES = {
    Automobile = true,
}

function Player.GetAvailableVehicleIDs( self )
    local vehicle_ids = { }
    
    for i, v in pairs( self:GetVehicles( true ) ) do
        if ALLOWED_TYPES[ v.vehicleType ] and not v:GetBlocked( ) and not FORBIDDEN_VEHICLES[ v.model ] and ( v:GetPermanentData( "temp_timeout" ) or 0 ) <= 0 and not v:GetSpecialType( ) then
            table.insert( vehicle_ids, { v:GetID( ), v:GetTier( ), v } )
        end
    end

    return vehicle_ids
end

function GetVehicleIDsByTier( list, tier )
    local vehicle_ids = { }

    for i, v in pairs( list ) do
        local vehicle_id, vehicle_tier = v[ 1 ], v[ 2 ]
        local vehicle = GetVehicle( vehicle_id )
        if isElement( vehicle ) and vehicle_tier == tier then
            table.insert( vehicle_ids, v )
        end
    end

    return vehicle_ids
end

function Player.GetSelectedTaxiVehicleID( self )
    local selected_vehicle_id = self:GetPermanentData( "taxi_selected_vehicle" )
    local vehicle = GetVehicle( selected_vehicle_id )
    if not vehicle then return end

    return vehicle and vehicle:GetOwnerID( ) == self:GetUserID( ) and vehicle:GetID( )
end

function Player.GetSelectedTaxiVehicle( self )
    local selected_vehicle_id = self:GetPermanentData( "taxi_selected_vehicle" )
    local vehicle = GetVehicle( selected_vehicle_id )
    if not vehicle then return end

    return vehicle and vehicle:GetOwnerID( ) == self:GetUserID( ) and vehicle
end

function Player.SetSelectedTaxiVehicle( self, vehicle )
    local id = tonumber( vehicle ) and vehicle or vehicle and vehicle:GetID( )
    if not id then id = nil end
    self:SetPermanentData( "taxi_selected_vehicle", id )
end

function Player.GetCurrentClass( self )
    local vehicle = self:GetSelectedTaxiVehicle( )
    return vehicle and vehicle:GetTier( )
end

function onServerTaxiPrivateVehicleSelectRequest_handler( selected_vehicle_id, city )
    local vehicle = GetVehicle( selected_vehicle_id )
    if not isElement( client ) or not isElement( vehicle ) or not tonumber( city ) or vehicle:GetOwnerID( ) ~= client:GetUserID( ) or FORBIDDEN_VEHICLES[ vehicle.model ] then return end

    if not client:HasLicense( LICENSE_TYPE_AUTO ) then
        client:ErrorWindow( "Требуются права категории \"B\"" )
        return false
    end

    local vehicle_tier = vehicle:GetTier()
    local current_license_state = client:HasTaxiLicense( vehicle_tier )
    if current_license_state == TAXI_LICENSE_NOT_PURCHASED or current_license_state == TAXI_LICENSE_EXPIRED then
        client:ErrorWindow( "У тебя нет лицензии на " .. VEHICLE_CLASSES_NAMES[ vehicle_tier ] .. " класс!" )
        return
    end


    client:SetSelectedTaxiVehicle( selected_vehicle_id )
    triggerEvent( "onTaxiPrivateVehicleChange", client, selected_vehicle_id, vehicle_tier ) 
    
    triggerEvent( "onJobStartShiftRequest", client, JOB_CLASS_TAXI_PRIVATE, city )
end
addEvent( "onServerTaxiPrivateVehicleSelectRequest", true )
addEventHandler( "onServerTaxiPrivateVehicleSelectRequest", resourceRoot, onServerTaxiPrivateVehicleSelectRequest_handler )