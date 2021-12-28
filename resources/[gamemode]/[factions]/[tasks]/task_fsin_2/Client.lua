loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

--ID КПЗ, откуда забирать игроков
TARGET_GET_JAIL_ID = 1
--ID тюрьмы, куда перевозить игроков
TARGET_TO_JAIL_ID = 1

--таймер ожидания погрузки игроков из КПЗ в тачку ФСИН
WAIT_GET_PLAYERS_TIMER = nil

--Текущие игроки ФСИН, участвующие в квесте
CURRENT_FSIN_PLAYERS = nil
--Текущие заключенные игроки, которые участвуют в квесте
CURRENT_JAILED_PLAYERS = nil


addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)



addEvent( "onClientQuestFsin_1TargetJail", true )
addEventHandler( "onClientQuestFsin_1TargetJail", root, function( f_target_jail_id )
	TARGET_GET_JAIL_ID = f_target_jail_id
	triggerServerEvent( "task_fsin_2_end_step_2", localPlayer )
end )

addEvent( "onClientQuestFsin_1TargetJailPlayers", true )
addEventHandler( "onClientQuestFsin_1TargetJailPlayers", root, function( f_target_to_jail_id, f_target_players, f_current_fsin_players )
	
	removeEventHandler( "onClientPlayerWasted", source, onSourcePlayerLeaved )
	removeEventHandler( "onClientPlayerQuit", source, onSourcePlayerLeaved )
	
	addEventHandler( "onClientPlayerWasted", source, onSourcePlayerLeaved )
	addEventHandler( "onClientPlayerQuit", source, onSourcePlayerLeaved )
	
	CURRENT_JAILED_PLAYERS = f_target_players
	TARGET_TO_JAIL_ID 	  = f_target_to_jail_id
	CURRENT_FSIN_PLAYERS  = f_current_fsin_players
end )

addEvent( "onPlayerWarpIntoFsinVehicle", true )
addEventHandler( "onPlayerWarpIntoFsinVehicle", root, function()
	localPlayer:setDimension( 0 )
	localPlayer:setInterior( 0 )
end )


function onSourcePlayerLeaved()
	removeEventHandler( "onClientPlayerWasted", source, onSourcePlayerLeaved )
	removeEventHandler( "onClientPlayerQuit", source, onSourcePlayerLeaved )
	
	triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Один из участников завершил квест досрочно" } )
end

function onJailedPlayerLeaved()
	for k, v in pairs( CURRENT_JAILED_PLAYERS ) do
		if source == v.player then
			if isPedDead( source ) then
				triggerServerEvent( "onJailedPlayerWastedWithDelivered", localPlayer, source )
			end
			table.remove( CURRENT_JAILED_PLAYERS, k )
			if #CURRENT_JAILED_PLAYERS == 0 then
				triggerServerEvent( "task_fsin_2_end_step_5", localPlayer )
			end
		end
	end
end

function checkPlayerFactionVehicle()

	local playersInVehicle = getVehicleOccupants( localPlayer.vehicle )
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:getData( "faction_id" ) ~= F_FSIN then
		localPlayer:ShowError( "Ты не в автомобиле ФСИН" )
		return false
	elseif localPlayer.vehicle.model ~= 416 then
		localPlayer:ShowError( "Перевозить заключенных можно только в микроавтобусе ФСИН" )
		return false
	elseif #playersInVehicle > 2 then
		localPlayer:ShowError( "В этой машине уже 2 работника ФСИН" )
		return false
	end

	return true

end

function checkPlayerFactionVehicleWithoutCount()

	local playersInVehicle = getVehicleOccupants( localPlayer.vehicle )
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:getData( "faction_id" ) ~= F_FSIN then
		localPlayer:ShowError( "Ты не в автомобиле ФСИН" )
		return false
	elseif localPlayer.vehicle.model ~= 416 then
		localPlayer:ShowError( "Перевозить заключенных можно только в микроавтобусе ФСИН" )
		return false
	end

	return true

end
