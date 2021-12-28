loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SActionTasks" )
Extend( "SPlayer" )
Extend( "ShUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
    LoadAction( ACTION_ARRAY )
end )