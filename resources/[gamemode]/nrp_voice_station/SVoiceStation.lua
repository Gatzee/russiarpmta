loadstring( exports.interfacer:extend("Interfacer") )()
Extend("SPlayer")

function onRemoveStationSubscriber_handler( station_id )
	VSController:RemoveSubscriber( source, station_id )
end
addEvent( "onRemoveStationSubscriber" )
addEventHandler( "onRemoveStationSubscriber", root, onRemoveStationSubscriber_handler )

function onTryCreateStation_handler( station_id, owner, channel_name, subscribers, ignore_distance )
	VSController:CreateStation( station_id, owner, channel_name, subscribers, ignore_distance )
end
addEvent( "onTryCreateStation" )
addEventHandler( "onTryCreateStation", root, onTryCreateStation_handler )

function onTryRemoveStation_handler( station_id )
	VSController:DestroyStation( station_id )
end
addEvent( "onTryRemoveStation" )
addEventHandler( "onTryRemoveStation", root, onTryRemoveStation_handler )
