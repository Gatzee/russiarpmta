
JAIL_QUESTS =
{
	[ "task_jail_1" ] = true,
	[ "task_jail_2" ] = true,
	[ "task_jail_3" ] = true,
}

--Игрок успешно завершил квест, сбрасываем ему 10% срока
function onPlayerCompleteJailQuest_handler()

	local pJailData = JAILED_PLAYERS_LIST[ client ]
    if pJailData then
        local remove_time = math.floor( pJailData.time_left * 0.1 )
		local time_left = math.floor( pJailData.time_left * 0.9 )
		if time_left <= 0 then
			ReleasePlayer( nil, client, "Срок истёк", true )
		else
			JAILED_PLAYERS_LIST[ client ].time_left = time_left
			local pDataToSave =
			{
				time_left = time_left,
				jail_id = pJailData.jail_id,
				reason = pJailData.reason,
				admin = pJailData.admin,
			}
			client:SetPermanentData( "prison_data", pDataToSave )
			triggerClientEvent( client, "prison:OnClientRefreshJailTime", client, time_left )
        end

        local ticks = getTickCount() + remove_time * 1000
        local iTimeLeft = math.max( ( ticks - getTickCount() ) / 1000, 0 )
        local iHours    = math.floor( iTimeLeft / 3600 )
        local iMinutes  = math.ceil( iTimeLeft / 60 ) - iHours * 60
        client:ShowInfo( "Время срока сокращено на " .. ( iHours > 0 and iHours .. plural( iHours, " час ", " часа ", " часов " ) or "" ) .. iMinutes .. plural( iMinutes, " минуту", " минуты", " минут" ) )

		client:ChangeSocialRating( SOCIAL_RATING_RULES.jail_work.rating )
	end

end
addEvent( "onPlayerCompleteJailQuest", true )
addEventHandler( "onPlayerCompleteJailQuest", root, onPlayerCompleteJailQuest_handler )


--Игрок провалил квест, блокируем ему работы на 15 минут
CONST_BLOCK_QUEST_TIME = 15 * 60
function onPlayerFailJailQuest_handler( quest_id )

	local pJailData = JAILED_PLAYERS_LIST[ client ]
	if pJailData then
		JAILED_PLAYERS_LIST[ client ][ quest_id ] = CONST_BLOCK_QUEST_TIME
		triggerClientEvent( client, "prison:OnPlayerFailQuest", client, quest_id, CONST_BLOCK_QUEST_TIME )
	end

end
addEvent( "onPlayerFailJailQuest", true )
addEventHandler( "onPlayerFailJailQuest", root, onPlayerFailJailQuest_handler )

function SwitchPosition_handler( )
	client:TakeWeapon( 41 )
end
addEvent( "SwitchPosition", true )
addEventHandler( "SwitchPosition", resourceRoot, SwitchPosition_handler )

--Сбросить текущий квест
function DropJailQuests( player, text )
	local quest_data = player:getData("current_quest")
	if quest_data and JAIL_QUESTS[ quest_data.id ] then
		triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = text } )
	end
end