loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CVehicle")
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

local agitation_speech_sound = nil

addEvent( "onStartPlayAgitationSpeech", true )
addEventHandler( "onStartPlayAgitationSpeech", resourceRoot, function( vehicle, sound_index )
	if isElement( agitation_speech_sound ) then return end

	agitation_speech_sound = playSound3D( "files/sound_".. sound_index ..".mp3", vehicle.position )
	attachElements( agitation_speech_sound, vehicle )

	agitation_speech_sound.volume = 0.5
	agitation_speech_sound.minDistance = 20
	agitation_speech_sound.maxDistance = 50
end )