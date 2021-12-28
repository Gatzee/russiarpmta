loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

ibUseRealFonts( true )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

AREAS = {
	{ start = Vector3( 2272.6687, 1191.5803, 16.1585 ), center = Vector3( 2274.5288, 2071.4448 - 860, 16.3296 ), area_size = 22 },
}


function SetStateCanEnterExitVehicle( state )
	toggleControl( "enter_exit", state )
	toggleControl( "enter_passenger", state )
end