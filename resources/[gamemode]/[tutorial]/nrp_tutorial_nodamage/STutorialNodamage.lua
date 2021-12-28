loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function onPlayerCompleteTutorial_handler( )
    local finish = getRealTime( ).timestamp + 60 * 60

    client:SetPermanentData( "nodamage_timeout", finish )
    triggerClientEvent( client, "onClientPlayerEnableNodamage", resourceRoot, finish )
end
addEvent( "onPlayerCompleteTutorial", true )
addEventHandler( "onPlayerCompleteTutorial", root, onPlayerCompleteTutorial_handler )

function onPlayerCompleteLogin_handler( )
    local nodamage_timeout = source:GetPermanentData( "nodamage_timeout" )
    if nodamage_timeout then
        if getRealTime( ).timestamp <= nodamage_timeout then
            triggerClientEvent( source, "onClientPlayerEnableNodamage", resourceRoot, nodamage_timeout )
        else
            source:SetPermanentData( "nodamage_timeout", nil )
        end
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )