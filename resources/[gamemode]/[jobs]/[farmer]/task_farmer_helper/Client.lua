loadstring( exports.interfacer:extend( "Interfacer" ) ) ( )
Extend( "CQuest" )

IGNORE_GPS_ROUTE = true

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	CQuest( QUEST_DATA )
end )