loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

ibUseRealFonts( true )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

local UI = nil

function CreateEvacuationHint()
	triggerEvent( "EnablePhoneHintAnimation", root, "towtruck", true )

	UI = {}
	UI.onClientKey_handler = function( key, state )
		if key == "p" and state and UI.info_key then
			removeEventHandler( "onClientKey", root, UI.onClientKey_handler )
			DestroyTableElements( UI )
			UI = nil

			triggerEvent( "EnablePhoneHintAnimation", root, "towtruck", true )
			triggerEvent( "ShowPhoneUI", root, true)

			cancelEvent()
		end
	end

	UI.info_key = ibInfoPressKey( {
		text = "чтобы открыть телефон и эвакуировать транспорт";
		key = "p";
	} )
	addEventHandler( "onClientKey", root, UI.onClientKey_handler )

	triggerEvent( "ShowPhoneUI", root, false )
end