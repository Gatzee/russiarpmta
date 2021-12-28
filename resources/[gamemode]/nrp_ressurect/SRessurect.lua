loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "Globals" )

function onPlayerReadyToPlay_handler( )
    local player = source

    if not player:GetPermanentData( "got_ressurect_bonus" ) then
        player:SetPermanentData( "got_ressurect_bonus", true )

        player:ResetAllVehiclesDiscount( )
        player:GiveAllVehiclesDiscount( 24 * 60 * 60, 40 )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )