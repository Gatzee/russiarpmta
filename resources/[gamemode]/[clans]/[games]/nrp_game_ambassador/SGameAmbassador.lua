loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SClans" )

OBJECT_MODEL = 2973

function CreateAmbassador_handler( self )
    self = table.copy( self )

    self.destroy = function( )
        if isElement( self.elements.vehicle ) then
			Vehicle.DestroyTemporary( self.elements.vehicle )
        end
        
        for i, v in pairs( self.elements ) do
            if isElement( v ) then destroyElement( v ) end
        end

        if isTimer( self.destroy_timer ) then killTimer( self.destroy_timer ) end
    end

    self.duration   = self.duration or 5 * 60
    self.points     = self.points or 10

    self.elements           = { }

    local vehicle = Vehicle.CreateTemporary( self.model or 445, self.position_x, self.position_y, self.position_z, self.rotation_x, self.rotation_y, self.rotation_z )
    vehicle:SetFuel("full")
    vehicle.health = self.health
    vehicle:setWheelStates( unpack( self.wheel_states ) )
    vehicle:SetWindowsColor(0, 0, 0, 230)
    vehicle:SetColor(0, 3, 0, 0)
    vehicle:SetNumberPlate( self.number_plate or "6:а900099" )
    
    addVehicleSirens( vehicle, 2, 4, false, true, true, true )
    setVehicleSirens( vehicle, 1, -0.3, 2.7, 0, 255, 0, 0 )
    setVehicleSirens( vehicle, 2, 0.3, 2.7, 0, 0, 0, 255 )
    setVehicleSirensOn( vehicle, true )

    self.elements.vehicle = vehicle

    addEventHandler("onVehicleStartEnter", vehicle, function( enter_player, seat )
        if seat == 3 then
            cancelEvent()
        end
    end)

    addEventHandler("onVehicleEnter", vehicle, function( enter_player, seat )
        if seat == 0 then
            enter_player:ShowInfo( "Доставь автомобиль с послом к восточному ангару" )
        end
    end)
    

    local ped = createPed( 194, 503.346, -2365.329, 21.326 )
    ped:warpIntoVehicle( vehicle, 3 )

    self.elements.ped = ped

    addEventHandler( "onPedWasted", ped, function()
        self.destroy()
    end )

    self.elements.gameshape = createColSphere( 1338.489, -2022.697, 20.587 , 50 )

    addEventHandler("onColShapeHit", self.elements.gameshape, function( vehicle, dim )
        if not dim then return end
        if vehicle ~= self.elements.vehicle then return end

        for seat, player in pairs( vehicle:getOccupants() ) do
            local clan_id = player:GetClanID( )
            if seat ~= 3 and clan_id then
                player:GiveMoney( self.money, "band_game_ambassador_reward" )
                player:GiveClanEXP( self.points )
                GiveClanHonor( clan_id, self.points, "ambassador", player, self.points )
                player:ShowSuccess( "Ты доставил автомобиль с послом! +".. self.points .." XP и " .. self.money .. " р." )
            end
        end

        self.destroy()
    end)

    self.destroy_timer = setTimer( self.destroy, self.duration * 1000, 1 )
    
    return self
end
addEvent( "CreateAmbassador", true )
addEventHandler( "CreateAmbassador", root, CreateAmbassador_handler )