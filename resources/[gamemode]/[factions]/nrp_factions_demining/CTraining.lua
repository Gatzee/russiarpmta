loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CInterior" )

function onClientResourceStart_handler()
	local vehicle = createVehicle( 516, -2557.517, -207.695, 21.4, 359.787, -10.004, 142.556 )
	vehicle.frozen = true
	vehicle:setDoorState( 2, 4 )
	vehicle:setDoorState( 3, 4 )
	vehicle:setDoorState( 5, 4 )

	addEventHandler("onClientVehicleDamage", vehicle, cancelEvent)
	addEventHandler("onClientVehicleStartEnter", vehicle, cancelEvent)

	local marker = TeleportPoint( { x = -2556.441, y = -208.639, z = 21.170, radius = 2, keypress = "lalt" } )
	marker.text = "ALT Взаимодействие"
	marker.marker:setColor( 245, 128, 128, 100 )
	marker.PostJoin = function()
		if localPlayer:GetFaction() ~= F_ARMY then
			localPlayer:ShowInfo( "Доступно только для Армии" )
			return
		end

		if localPlayer:GetFactionLevel() < 3 then
			localPlayer:ShowInfo( "Доступно только для 3-го ранга и выше" )
			return
		end

		triggerEvent( "StartPlayerDemining", resourceRoot, "SuccessTrainingDemining", "FailTrainingDemining" )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )


function SuccessTrainingDemining_handler()
	localPlayer:ShowSuccess( "Вы успешно деактивировали учебную бомбу" )
	triggerServerEvent( "SWAction", localPlayer, "Бомба деактивирована" )
end
addEvent( "SuccessTrainingDemining" )
addEventHandler( "SuccessTrainingDemining", resourceRoot, SuccessTrainingDemining_handler )


function FailTrainingDemining_handler( text )
	localPlayer:ShowError( text )
	triggerServerEvent( "SWAction", localPlayer, text )
end
addEvent( "FailTrainingDemining" )
addEventHandler( "FailTrainingDemining", resourceRoot, FailTrainingDemining_handler )