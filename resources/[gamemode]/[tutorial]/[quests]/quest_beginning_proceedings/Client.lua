loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

ibUseRealFonts( true )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )