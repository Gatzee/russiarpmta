loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )

function SendQuest2Invite( player )
	player:SituationalPhoneNotification(
		{ title = "Неизвестный номер", msg = "Здравствуй, это помощник Александра. У меня есть новости" },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "return_of_history" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		}
	)

	player:SetPermanentData( "quest_2_ivnite", true )
end


function onPlayerCompleteLogin_rateHandler( )
	local quests_data = source:GetQuestsData()
	local completed = quests_data.completed or { }
	if completed[ "angela_dance_school" ] and not source:GetPermanentData( "quest_2_ivnite" ) then
        SendQuest2Invite( source )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_rateHandler )