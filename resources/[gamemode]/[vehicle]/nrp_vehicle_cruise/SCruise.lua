loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )

function SwitchSpeedLimiter( pVehicle, state )
    if not isElement(pVehicle) then return end
    pVehicle:SetCruiseEnabled( state )
end
addEvent("SwitchSpeedLimiter", true)
addEventHandler("SwitchSpeedLimiter", root, SwitchSpeedLimiter)

function OnPlayerVehicleEnter( pVehicle, iSeat )
    if iSeat ~= 0 then return end

    local model = pVehicle.model
    if IsSpecialVehicle(model) or VEHICLE_TYPE_BIKE[ model ] or VEHICLE_TYPE_QUAD[ model ] or model == 468 or model == 530 then
        if pVehicle:IsCruiseEnabled() then
            pVehicle:SetCruiseEnabled( false )
        end
    end

    triggerClientEvent( source, "OnClientSpeedLimiterSwitched", source, pVehicle:IsCruiseEnabled() )
end
addEventHandler("onPlayerVehicleEnter", root, OnPlayerVehicleEnter)