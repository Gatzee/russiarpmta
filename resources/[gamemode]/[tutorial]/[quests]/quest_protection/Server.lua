loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

local WEST_ZONE = {
	-1934.9600, 629.5781,
	-2009.5699, 616.1198,
	-2021.6296, 685.0377,
	-1947.2146, 698.2191,
	-1934.9600, 629.5781,
}

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
	WEST_CARTEL_ZONE = createColPolygon( unpack( WEST_ZONE ) )
end )