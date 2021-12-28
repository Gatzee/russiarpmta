loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")
Extend("SQuest")

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuest( QUEST_DATA )
end )

addEventHandler( "onResourceStop", resourceRoot, function()
	local target_players = {}
	for k, v in pairs( getElementsByType( "player" ) ) do
		if v:GetJobClass( ) == JOB_CLASS_HCS then
			table.insert( target_players, v )
		end
	end

	for k, v in pairs( target_players ) do
		v:TakeWeapon( 15 )
	end
end )