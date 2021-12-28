loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")

local LEVELUP_NEW_QUESTS_INFO = {
	--[3] = true;
	--[4] = true;
	--[5] = true;
}

local LEVELUP_NEW_WORKS = {
	[2] = "помощник грузчика и помощник курьера";
	[3] = "помощник фермера";
	[4] = "курьер в компании 1 ур. и сотрудник парка 1 ур";
	[5] = "грузчик в компании 1 ур";
	[6] = "автомеханик 1 ур., фермер в компании 1 ур. и таксист частник";
	[7] = "курьер в компании 2 ур. и сотрудник парка 2 ур";
	[8] = "автомеханик 2 ур. и грузчик в компании 2 ур";
	[9] = "фермер в компании 2 ур. и сотрудник парка 3 ур";
	[10] = "курьер в компании 3 ур., грузчик в компании 3 ур. и дальнобойщик 1 ур";
	[11] = "автомеханик 3 ур. и фермер в компании 3 ур";
	[12] = "водитель такси 1 ур. и сотрудник ЖКХ 1 ур";
	[13] = "водитель автобуса 1 ур. и эвакуаторщик 1 ур";
	[14] = "водитель такси 2 ур. и сотрудник ЖКХ 2 ур";
	[15] = "водитель автобуса 2 ур. и эвакуаторщик 2 ур";
	[16] = "водитель автобуса 3 ур. и дальнобойщик 2 ур";
	[17] = "водитель такси 3 ур. и сотрудник ЖКХ 3 ур";
	[18] = "лётчик 1 ур. и эвакуаторщик 3 ур";
	[19] = "дровосек  1 ур";
	[20] = "лётчик 2 ур";
	[21] = "дровосек 2 ур";
	[22] = "лётчик 3 ур";
	[23] = "дровосек 3 ур";
	[24] = "дальнобойщик 3 ур";
}

function OnPlayerLevelUp( new_level )
	if LEVELUP_NEW_QUESTS_INFO[ new_level ] then
		Timer( function( player )
			if isElement( player ) then
				player:PhoneNotification( {
					title = "Квесты";
					msg = "Вам доступны новые квесты, подробнее на F2 в журнале.";
				} )
			end
		end, 30000, 1, source )
	end

	if LEVELUP_NEW_WORKS[ new_level ] then
		Timer( function( player )
			if isElement( player ) then
				player:PhoneNotification( {
					title = "Новые работы";
					msg = "Вам доступны новые работы: ".. LEVELUP_NEW_WORKS[ new_level ] ..". Подробнее на F1 в меню навигации.";
				} )
			end
		end, LEVELUP_NEW_QUESTS_INFO[ new_level ] and 60000 or 30000, 1, source )
	end
	
	triggerClientEvent( source, "PlayerLevelUp", resourceRoot, new_level )

	if new_level == 2 then
		source:AddDailyQuest( "get_phone_number", true )
	end

	if new_level == 5 then
		source:AddDailyQuest( "start_shift", true )
	end

	if new_level == 6 then
		source:AddDailyQuest( "np_join_clan", true )
		source:AddDailyQuest( "np_get_b_rights", true )
	end
end
addEvent("OnPlayerLevelUp")
addEventHandler("OnPlayerLevelUp", root, OnPlayerLevelUp)

do
	local TIME_PASSIVE_GIVE_EXP = 30*60
	Timer(function()
		local players = getElementsByType("player")
		for _, player in ipairs(players) do
			if player:IsInGame() then
				local total_time_play = player:GetTotalPlayingTime() or 0
				local timestamp = getRealTime().timestamp

				local next_give_exp = player:getData("NextPassiveGiveExp")

				if not next_give_exp or player:GetAFKTime( ) >= 5*60*1000 then
					next_give_exp = timestamp + TIME_PASSIVE_GIVE_EXP - total_time_play % TIME_PASSIVE_GIVE_EXP
					player:setData("NextPassiveGiveExp", next_give_exp, false)

				elseif timestamp > next_give_exp then
					next_give_exp = timestamp + TIME_PASSIVE_GIVE_EXP
					player:setData("NextPassiveGiveExp", next_give_exp, false)

					local exp = LEVELS_PASSIVE_EXPERIENCE[player:GetLevel()] or LEVELS_PASSIVE_EXPERIENCE[#LEVELS_PASSIVE_EXPERIENCE]
					player:GiveExp(exp)
				end
			end
		end
	end, 30000, 0)
end

function onPlayerCompleteLogin_level_handler( )
	local level = source:GetPermanentData( "level" )
	if not source:GetPermanentData( "updated_level" ) then
		source:SetPermanentData( "updated_level", true )
		
		if level > 1 then
			level = level * 2
			source:SetLevel( level )
			source:GiveExp( 0 )
			return
		end
	end
	source:setData( "level", level )
	source:SetPrivateData( "exp", level )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_level_handler )