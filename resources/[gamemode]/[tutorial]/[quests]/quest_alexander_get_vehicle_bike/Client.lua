loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

local UI = nil

function CreateEvacuationHintColshape( )
	UI = {}
	UI.onClientKey_handler = function( key, state )
		if key == "p" and state then
			if UI.info_key then
				UI.info_key:destroy( )
				UI.info_key = nil

				triggerEvent( "EnablePhoneHintAnimation", root, "towtruck", true )
				triggerEvent( "EnablePhoneTowtruckerHintSearch", root, true )

				triggerEvent( "ShowPhoneUI", root, true )
				localPlayer:ShowInfo( 'Выберите приложение "Эвакуация транспорта"' )
			end

			cancelEvent( )
		end
	end
	
	UI.colshape = createColSphere( Vector3( 1789.9833, -626.3525, 60.7885 ), 3 )
	addEventHandler( "onClientColShapeLeave", UI.colshape, function( element )
		if element ~= localPlayer then return end
		destroyElement( UI.colshape )

		localPlayer.frozen = true
		localPlayer.position = localPlayer.position
		toggleAllControls( false )

		addEventHandler( "onClientKey", root, UI.onClientKey_handler )
		
		UI.info_key = ibInfoPressKey( {
			text = "чтобы открыть телефон";
			key = "p";
		} )
	end )
end

function onClientHideTowtruckerHintSearch_handler( )
	localPlayer.frozen = false
	localPlayer.position = localPlayer.position
	toggleAllControls( true )

	removeEventHandler( "onClientKey", root, UI.onClientKey_handler )
    DestroyTableElements( UI )
	UI = nil
end
addEvent( "onClientHideTowtruckerHintSearch", true )
addEventHandler( "onClientHideTowtruckerHintSearch", root, onClientHideTowtruckerHintSearch_handler )


addEvent( "onClientPlayerUseQuestCanister" )