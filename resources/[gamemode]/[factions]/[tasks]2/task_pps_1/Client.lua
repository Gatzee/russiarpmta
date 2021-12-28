loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CVehicle" )
Extend( "CQuest" )
Extend( "ShFactionsInteriors" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )