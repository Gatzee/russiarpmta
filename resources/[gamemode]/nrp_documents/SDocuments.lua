loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

function isPlayerCanLookAtDocuments( player )
    if not isElement( player ) then return end
    if player:IsOnUrgentMilitary( ) and not player:IsUrgentMilitaryVacation( ) then return end
    if player:getData( "is_fishing" ) then return end
    if player:IsInEventLobby( ) then return end
    
    return true
end

function ShowNotificationShowDocuments_handler( is_timeout )
    if is_timeout then
        source:ShowError( "Игрок не посмотрел твой документ" )
    else
        source:ShowError( "Игрок уже смотрит документы" )
    end
end
addEvent( "ShowNotificationShowDocuments", true )
addEventHandler( "ShowNotificationShowDocuments", root, ShowNotificationShowDocuments_handler )