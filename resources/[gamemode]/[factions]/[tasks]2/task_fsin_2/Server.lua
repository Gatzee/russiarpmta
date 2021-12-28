loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SQuest")

--Таблица ID тюрем, откуда забираются игроки
-- для синхронизации между игроками и выполнения
-- следующих шагов квеста
TARGET_GET_JAIL_ID = {}

--Таблица ID тюрем, куда доставляются игроки
-- для синхронизации между игроками и выполнения
-- следующих шагов квеста
TARGET_TO_PLAYERS_JAIL_ID = {}

--Таблица ФСИН игроков, которые вместе участвуют в квесте
FSIN_QUEST_PLAYERS = {}

--Таблица заключенных игроков, которые участвуют в квесте
FSIN_JAILED_PLAYERS = {}

--Таблица с таймерами запросов в КПЗ
-- на поиск заключенных в камерах
TIMER_REQUEST_JAIL = {}

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

function onPlayerVehicleEnter_handler( vehicle )
	local result = onFsinPlayerEnterInVehicle( source, vehicle )
end

--Получение игроков, которых можно перевести в тюрьму
function getAvailableJailedPlayersToPrison( jail_id )
	local result_data = { }
	local result_players = { }
	local jailed = exports.nrp_jail:GetJailedPlayers( jail_id )

	for _, v in pairs( jailed ) do
		if v.data.time_left * 1000 > PRISON_TIME and v.data.jail_id == jail_id then
			if not exports.nrp_tutorial_lawyer:CheckPlayerLawyer( v.player ) then
				table.insert( result_players, v.player )
				table.insert( result_data, v )

				if #result_data == 2 then
					break
				end
			end
        end
	end

	return result_data, result_players
end

function onFsinPlayerEnterInVehicle( player, vehicle )

	if checkPlayerFactionVehicle( player, vehicle ) then
		
		local targetPlayers = {}
		for _, v in pairs( getVehicleOccupants( vehicle ) ) do
			if v:IsOnFactionDuty() and v:GetFaction() == F_FSIN then
				table.insert( targetPlayers, v )
			end
		end

		for _, v in pairs( targetPlayers ) do
			if not TARGET_GET_JAIL_ID[ player ] and v ~= player and TARGET_GET_JAIL_ID[ v ] then
				TARGET_GET_JAIL_ID[ player ] = TARGET_GET_JAIL_ID[ v ]
			end
			FSIN_QUEST_PLAYERS[ v ] = targetPlayers	
		end

		if not TARGET_GET_JAIL_ID[ player ] then

			--Определяем куда будем перевозить заключенных
			local finded = { prison_id = 1, value = 0 }
			local jailed = {
				#getAvailableJailedPlayersToPrison( 1 ),
				#getAvailableJailedPlayersToPrison( 2 ),
				#getAvailableJailedPlayersToPrison( 3 ),
			}

			for idx, counter in pairs( jailed ) do
				if counter > finded.value then
					finded = { prison_id = idx, value = counter }
				end
			end

			TARGET_GET_JAIL_ID[ player ] = finded.prison_id
			FSIN_QUEST_PLAYERS[ player ] = { player }
		end

		triggerClientEvent( player, "onClientQuestFsin_1TargetJail", player, TARGET_GET_JAIL_ID[ player ] )
		removeEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_handler )

		return true
	end
	return false

end

function OnPlayerFailedQuest_handler()
	local current_quest = source:getData( "current_quest" )
	if current_quest and current_quest.id == QUEST_DATA.id then
		for k, v in pairs( FSIN_QUEST_PLAYERS ) do
			for key, player in ipairs( v ) do
				if player == source then
					FSIN_QUEST_PLAYERS[ k ][ key ] = nil
					return
				end
			end
		end
	end
end
addEventHandler( "OnPlayerFailedQuest", root, OnPlayerFailedQuest_handler )


function onBasedPlayerLeaveQuest( player )
	local player = source or player
	if FSIN_QUEST_PLAYERS[ player ] then
		for k, v in pairs( FSIN_QUEST_PLAYERS[ player ] ) do
			local current_quest = v:getData( "current_quest" )
			if current_quest and current_quest.id == QUEST_DATA.id then
				triggerEvent( "PlayerFailStopQuest", v, { type = "quest_fail", fail_text = "Участник квеста покинул игру" } )
			end
		end
	end
end

function checkPlayerFactionVehicle( player, vehicle )

	local playersInVehicle = getVehicleOccupants( vehicle )
	if not isElement( vehicle ) or vehicle:getData( "faction_id" ) ~= F_FSIN then
		player:ShowError( "Ты не в автомобиле ФСИН" )
		return false
	elseif vehicle.model ~= 416 then
		player:ShowError( "Перевозить заключенных можно только в микроавтобусе ФСИН" )
		return false
	elseif #playersInVehicle > 2 then
		player:ShowError( "В этой машине уже 2 работника ФСИН" )
		return false
	end

	return true

end