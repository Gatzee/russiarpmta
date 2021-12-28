Extend( "CVehicle" )

local sumOfLoss = 0
local timer = nil

function onClientVehicleDamage_handler( _, weapon, loss )
	if localPlayer.vehicle ~= source then return end
	if not source:GetProperty( "statusNumber" ) then return end
	if source:GetNotSuitableType( ) then return end

    if not weapon then
        cancelEvent( ) -- cancel of damage, for all passengers

        if localPlayer.vehicleSeat ~= 0 then return end

        sumOfLoss = sumOfLoss + loss -- calculate all loss

        if isTimer( timer ) then killTimer( timer ) end
        timer = setTimer( function ( source )
            -- send sum of loss
            if isElement( source ) then
                triggerServerEvent( "changeCarHealthOnDamage", resourceRoot, source, sumOfLoss )
            end
            
            -- reset loss
            sumOfLoss = 0
        end, 150, 1, source )
    end
end
addEventHandler( "onClientVehicleDamage", root, onClientVehicleDamage_handler )