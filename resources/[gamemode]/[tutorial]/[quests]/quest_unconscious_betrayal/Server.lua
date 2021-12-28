loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )

function SendQuest23Invite( player )
	player:SituationalPhoneNotification(
		{ title = "Неизвестный номер", msg = "Здравствуй, это Роман. Александр приглашает тебя в офис." },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "beginning_proceedings" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		}
	)

	player:SetPermanentData( "quest_23_ivnite", true )
end

function onPlayerCompleteLogin_rateHandler( )
	local quests_data = source:GetQuestsData()
	local completed = quests_data.completed or { }
	if completed[ "unconscious_betrayal" ] and not source:GetPermanentData( "quest_23_ivnite" ) then
        SendQuest23Invite( source )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_rateHandler )