loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CUI" )
Extend( "CActionTasksUtils" )
Extend ("CQuest" )

addEventHandler("onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )