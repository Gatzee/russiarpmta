loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("SPlayer")

addCommandHandler("teditor", function( ply, cmd, ... )
	if ply:GetAccessLevel() >= ACCESS_LEVEL_DEVELOPER then
		triggerClientEvent(ply, "TC:ShowUI", ply, true)
	end
end)

function OnPlayerTrySaveTrack( data )
	-- SAVE AS FILE
	local str = "TRACKS[ " .. data.name .. " ] = "..inspect(data)

	if fileExists(data.name..".lua") then
		fileDelete(data.name..".lua")
	end

	local file = fileCreate( data.name..".lua" )
	fileWrite( file, str )
	fileClose( file )

	client:ShowSuccess("Трек успешно сохранён")
end
addEvent("OnPlayerTrySaveTrack", true)
addEventHandler("OnPlayerTrySaveTrack", root, OnPlayerTrySaveTrack)

function OnPlayerTryLoadTrack( name )
	-- LOAD FILE
	local file = fileExists( name..".lua" ) and fileOpen( name..".lua" )
	if file then
		local contents = fileRead(file, fileGetSize(file))
		fileClose(file)
		loadstring( contents )()
		local output = table.copy(track)
		track = nil

		triggerClientEvent(client, "TC:OnTrackDataReceived", client, output)

		client:ShowSuccess("Трек найден и загружен")
	else
		client:ShowError("Трек с таким названием не найден")
	end
end
addEvent("OnPlayerTryLoadTrack", true)
addEventHandler("OnPlayerTryLoadTrack", root, OnPlayerTryLoadTrack)