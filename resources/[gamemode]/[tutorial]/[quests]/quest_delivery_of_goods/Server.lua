loadstring( exports.interfacer:extend("Interfacer") )( )
Extend( "SActionTasksUtils" )
Extend( "SQuest" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )