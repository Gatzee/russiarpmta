loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SQuest" )

addEventHandler( "onResourceStart", resourceRoot, function ( )
	SQuest( QUEST_DATA )
end )

addEvent( "onPlayerGotPointInMedicTask5", true )
addEventHandler( "onPlayerGotPointInMedicTask5", resourceRoot, function ( occupant, point_num )
	local timer = nil

	local function clearTimer( )
		if isTimer( timer ) then
			killTimer( timer )
		end
	end

	local function sendData( )
		triggerClientEvent( occupant, "onPlayerGotPointInMedicTask5", resourceRoot, point_num )
	end

	local function generateWait( )
		if not isElement( occupant ) then
			clearTimer( )
			return
		end

		local current_quest = occupant:getData( "current_quest" ) or { }
		if current_quest.id ~= "task_medic_5" then
			clearTimer( )
			return
		end

		if current_quest.task == 4 then
			sendData( )
			clearTimer( )
		end
	end

	timer = Timer( generateWait, 250, 5 ) -- try 5 times
end )