loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SQuest" )

addEventHandler( "onResourceStart", resourceRoot, function ( )
	SQuest( QUEST_DATA )
end )