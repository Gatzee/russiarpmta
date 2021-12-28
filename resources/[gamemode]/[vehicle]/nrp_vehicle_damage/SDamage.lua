local PASSENGER_DAMAGE_MULTIPLIER = 0.1
local MIN_PLAYER_HEALTH = 25

function onVehicleDamage( vehicle, fLoss )
    if not isElement( vehicle ) then return end
    
    for _, player in pairs( vehicle.occupants ) do
        local health = player.health
	    if health > MIN_PLAYER_HEALTH then
            local coefficient = ( vehicle.vehicleType == "Bike" and player:HasHelmet( ) ) and HELMET_DEF_COEFFICIENT or 1
            local fPlayerLoss = math.min( health - MIN_PLAYER_HEALTH, fLoss * coefficient * PASSENGER_DAMAGE_MULTIPLIER )

            player.health = health - fPlayerLoss
        end
    end
end
addEvent( "onVehicleDamageByCollision", true )
addEventHandler( "onVehicleDamageByCollision", resourceRoot, onVehicleDamage )