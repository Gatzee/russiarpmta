loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CActionTasks" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    LoadAction( ACTION_ARRAY )
end )