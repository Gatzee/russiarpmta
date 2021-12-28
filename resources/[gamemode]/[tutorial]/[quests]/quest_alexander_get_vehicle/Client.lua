loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )