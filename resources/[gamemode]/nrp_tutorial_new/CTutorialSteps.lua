loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ib" )

addEvent( "OnPlayerEndStepTutorialBy_ShowF1", true )
addEventHandler( "OnPlayerEndStepTutorialBy_ShowF1", root, function( )
	Timer( function()
		ibInfoPressKey( {
			text = "чтобы найти автошколу";
			key = "f1";
		} )
	end, 3500, 1 )
end )

addEvent( "OnPlayerEndStepTutorialBy_ShowF4", true )
addEventHandler( "OnPlayerEndStepTutorialBy_ShowF4", root, function( )
	Timer( function()
		ibInfoPressKey( {
			text = "чтобы конвертировать валюту";
			key = "f4";
		} )
		Timer( function()
			localPlayer:PhoneNotification( {
				title = "Анжела";
				msg = "У меня есть для тебя задание! Нажми F2 чтобы открыть журнал квестов.";
			} )
		end, 10000, 1 )
	end, 3500, 1 )
end )

addEvent( "OnPlayerEndStepTutorialBy_ShowPhone", true )
addEventHandler( "OnPlayerEndStepTutorialBy_ShowPhone", root, function( title )
	localPlayer:PhoneNotification( {
		title = title or "Сообщение";
		msg = "У меня есть для тебя задание! Нажми F2 чтобы открыть журнал квестов.";
	} )

	ibInfoPressKey( {
		text = "чтобы прочитать уведомление";
		key = "p";

		key_handler = function( )
			Timer( function( )
				local current_quest = localPlayer:getData( "current_quest" )
				if not current_quest then
					ibInfoPressKey( {
						text = "чтобы открыть журнал квестов";
						key = "f2";
					} )
				end
			end, 30000, 1 )
		end;
	} )
end )