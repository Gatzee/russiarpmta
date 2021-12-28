loadstring( exports.interfacer:extend("Interfacer") )()
Extend("Globals")
Extend("ShUtils")
Extend("SPlayer")


VOICE_RANGE = 30

local pairs                      = pairs
local getElementsByType          = getElementsByType
local setPlayerVoiceBroadcastTo  = setPlayerVoiceBroadcastTo
local getDistanceBetweenPoints3D = getDistanceBetweenPoints3D
local getElementPosition         = getElementPosition
local getElementDimension        = getElementDimension
local getElementData             = getElementData

function getPlayersInRange( player )
	local list = { }

	if player:getData( "phone.call" ) then
		local abonent = exports.nrp_sim_shop:GetAbonentByPlayer( player )
		if isElement( abonent ) then
			table.insert( list, abonent )
		end
	elseif player:getData( "use_sputnik" ) then
		local clanID = player:GetClanID( ) or 0
		local factionID = player:GetFaction( ) or 0

		for _, v in pairs( GetPlayersInGame( ) ) do
			if ( clanID > 0 and clanID == v:GetClanID( ) ) or ( factionID > 0 and factionID == v:GetFaction( ) ) then
				table.insert( list, v )
			end
		end
	else
		local x, y, z = getElementPosition( player )
		local dimension = getElementDimension( player )
		local voice_channel = getElementData( player, "_voicech" )

		for _, v in pairs( GetPlayersInGame( ) ) do
			local vx, vy, vz = getElementPosition( v )
			local vdimension = getElementDimension( v )
			local channel = voice_channel and getElementData( v, "_voicech" )

			if ( channel and voice_channel == channel ) or ( dimension == vdimension and getDistanceBetweenPoints3D( x, y, z, vx, vy, vz ) <= VOICE_RANGE ) then
				table.insert( list, v )
			end
		end
	end
	return list
end

function onVoiceStart( )
	if not source:IsInGame( ) or isPlayerMuted( source ) or source:getData( "cr_big_room" ) or source:getData( "mute_voice" ) then cancelEvent( ) return end	
	setPlayerVoiceBroadcastTo( source, getPlayersInRange( source ) )

	local count_speak = source:getData( "count_speak" )
	if count_speak then
		source:setData( "count_speak", count_speak + 1, false )
	end
end
addEventHandler( "onPlayerVoiceStart", root, onVoiceStart )
addEventHandler( "onFactionVoiceChannelChange", root, onVoiceStart )