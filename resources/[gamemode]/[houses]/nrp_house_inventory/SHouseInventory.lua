loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )

addEvent( "onPlayerWantShowHouseInventory", true )
addEventHandler( "onPlayerWantShowHouseInventory", resourceRoot, function( id, number )
    local player = client

    if not player:HasAccessToHouse( id, number ) then
        player:ShowError( "Это не твой дом!" )
        return
    end

    if player:HasHouseRentalDebt( id, number ) then
        player:ShowError( "Оплати долг за дом!" )
        return
    end

    triggerEvent( "InventoryShow", player, id .. "_" .. number )
end )