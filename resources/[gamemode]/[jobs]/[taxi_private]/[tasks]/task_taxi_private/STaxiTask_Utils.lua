function Player.GetCurrentClass( self )
    local vehicle = self:GetSelectedTaxiVehicle( )
    return vehicle and vehicle:GetTier( )
end

function Player.GetSelectedTaxiVehicle( self )
    local selected_vehicle_id = self:GetPermanentData( "taxi_selected_vehicle" )
    local vehicle = GetVehicle( selected_vehicle_id )
    if not vehicle then return end

    return vehicle and vehicle:GetOwnerID( ) == self:GetUserID( ) and vehicle
end

function Player.GetSelectedTaxiVehicleID( self )
    local selected_vehicle_id = self:GetPermanentData( "taxi_selected_vehicle" )
    local vehicle = GetVehicle( selected_vehicle_id )
    if not vehicle then return end

    return vehicle and vehicle:GetOwnerID( ) == self:GetUserID( ) and vehicle:GetID( )
end

function Player.RemoveBlips( self )
    triggerClientEvent( self, "RemoveAllTaxiBlips", self )
end

function GetFreeDriversForClass( tier )
    local drivers = { }
    for i, v in pairs( TAXI_DRIVERS ) do
        if v.class == tier and not v.target then
            if isElement( v.player ) then
                table.insert( drivers, v )
            end
        end
    end
    return drivers
end

function Player.GetDriveTarget( self )
    return TAXI_DRIVERS[ self ] and TAXI_DRIVERS[ self ].target
end
Player.IsBusy = Player.GetDriveTarget

function Player.StartDriving( self )
    triggerClientEvent( self, "onTaxiStartDriving", self )
end

function Vehicle.GetTaxiDriver( self )
    local driver = self.occupants[ 0 ]
    if driver then
        if driver:GetSelectedTaxiVehicle( ) == self then
            return driver
        end
    end
end

function Player.CheckForTaxiVehicle( self, vehicle, seat )
    local driver = vehicle:GetTaxiDriver( )
    
    -- Попытка высадить водителя
    if seat == 0 then
        return false, "Можно сесть только пассажиром"
    end

    -- Нет водителя под этот класс машины
    if not driver then
        return false, "Водитель не на месте"
    end
    
    -- Заказал другой игрок
    if self ~= driver:GetDriveTarget( ) then
        return false, "Такси заказано другим игроком"
    end

    return true
end

function Player.EndShift( self, reason )
    local target = self:GetDriveTarget( )
    if target then
        triggerEvent("onTaxiPrivateEndShiftRequest_DriverExit", self)
        target:StopCounting( )
    else
        triggerEvent( "onTaxiPrivateEndShiftRequest_CustomReason", self, reason )
    end
end

function Player.increment( self, key, value )
    self:SetPermanentData( key, ( self:GetPermanentData( key ) or 0 ) + ( value or 1 ) )
end

function Player.KickFromVehicle( self )
    local vehicle = getPedOccupiedVehicle( self )
    if isElement( vehicle ) then
        local ox, oy, oz = getPositionFromElementAtOffset( vehicle, 2.5, 0, 0.3 )
        removePedFromVehicle( self )
        setElementPosition( self, ox, oy, oz )
    end
end