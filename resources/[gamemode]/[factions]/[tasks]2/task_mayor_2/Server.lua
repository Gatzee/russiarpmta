loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

addEvent( "onRequestStartPlayAgitationSpeech", true )
addEventHandler( "onRequestStartPlayAgitationSpeech", resourceRoot, function( vehicle )
	if not client then return end

	triggerClientEvent( getElementsWithinRange( vehicle.position, 500, "player" ), "onStartPlayAgitationSpeech", resourceRoot, vehicle, math.random( 1, 2 ) )
end )