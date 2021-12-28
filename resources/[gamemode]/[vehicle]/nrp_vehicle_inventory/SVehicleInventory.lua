loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )

addEvent( "onPlayerWantShowVehicleInventory", true )
addEventHandler( "onPlayerWantShowVehicleInventory", root, function()
    local player = client
    local vehicle = source

    if vehicle:GetOwnerID() ~= player:GetID() then return end

    triggerEvent( "InventoryShow", player, vehicle )
end )
