loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

function OnServerPlayerOpenPhotoMode_handler()
    SendElasticGameEvent( client:GetClientID( ), "camera_open", {} )
end
addEvent( "OnServerPlayerOpenPhotoMode", true )
addEventHandler( "OnServerPlayerOpenPhotoMode", root, OnServerPlayerOpenPhotoMode_handler )


function OnServerPlayerTookPhoto_handler()
    SendElasticGameEvent( client:GetClientID( ), "camera_shoot", {} )
end
addEvent( "OnServerPlayerTookPhoto", true )
addEventHandler( "OnServerPlayerTookPhoto", root, OnServerPlayerTookPhoto_handler )