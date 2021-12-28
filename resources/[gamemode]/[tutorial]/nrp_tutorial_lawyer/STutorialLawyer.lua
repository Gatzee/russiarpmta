loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function StartPlayerLawyer( )
    if not CheckPlayerLawyer( source ) then return end
    triggerClientEvent( source, "onClientPlayerRequestLawyerStart", resourceRoot )
end
addEvent( "onPlayerReadJailInfo", true )
addEventHandler( "onPlayerReadJailInfo", root, StartPlayerLawyer )

function CheckPlayerLawyer( player )
    return not player:GetPermanentData( "lawyer_shown" ) and player:GetPermanentData( "reg_date" ) >= NEW_TUTORIAL_RELEASE_DATE
end

function OnPlayerReleasedFromJail_handler( )
    triggerClientEvent( source, "onClientPlayerRequestLawyerStop", resourceRoot )
end
addEvent( "OnPlayerReleasedFromJail", true )
addEventHandler( "OnPlayerReleasedFromJail", root, OnPlayerReleasedFromJail_handler )

function onPlayerRequestLawyerStop_handler( )
    local player = client or source
    if player:GetPermanentData( "lawyer_shown" ) then return end
    
    player:SetPermanentData( "lawyer_shown", true )

    player:Release( _, _, true )
    setCameraTarget( player, player )
end
addEvent( "onPlayerRequestLawyerStop", true )
addEventHandler( "onPlayerRequestLawyerStop", root, onPlayerRequestLawyerStop_handler )