loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )

function SendQuest24Invite( player )
	player:SituationalPhoneNotification(
		{ title = "Александр", msg = "Здравствуй Старина, я жду тебя на Яхте. Есть что обсудить." },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "the_inevitable_path" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		}
	)

	player:SetPermanentData( "quest_2_3episode_ivnite", true )
end


function onPlayerCompleteLogin_rateHandler( )
	local quests_data = source:GetQuestsData()
	local completed = quests_data.completed or { }
	if completed[ "crazy_vacation" ] and not source:GetPermanentData( "quest_2_3episode_ivnite" ) then
        SendQuest24Invite( source )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_rateHandler )