loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )

local screenSize = Vector2( guiGetScreenSize() )

local precision = 100000
local prev_x, prev_y, prev_z

local FREQ = 75

local STREAMED_PLAYERS = { }

setTimer(
	function()
		if localPlayer.dead then return end
		if not localPlayer:IsInGame() then return end

		local px, py, pz = getWorldFromScreenPosition( screenSize.x/2, screenSize.y/2, 15 )

		if prev_x == px and prev_y == py and prev_z == pz then return end

		setPedLookAt( localPlayer, px, py, pz, -1, FREQ )

		prev_x, prev_y, prev_z = px, py, pz

		local diff_x, diff_y, diff_z = px, py, pz

		local players_in_range = 0
		for v, _ in pairs( STREAMED_PLAYERS ) do
			if getDistanceBetweenPoints3D( localPlayer.position, v.position ) <= 40 and localPlayer.interior == v.interior and localPlayer.dimension == v.dimension then
				players_in_range = players_in_range + 1
			end
		end

		local info = { math.floor( diff_x * precision )/precision, math.floor( diff_y * precision )/precision, math.floor( diff_z * precision )/precision }
		--iprint( info )
		if players_in_range > 0 then
			triggerServerEvent( "head", localPlayer, info )
		end
	end
, FREQ, 0)

function head_c_handler( data )
	if not isElement( source ) then return end
	local new_lookat = Vector3( unpack( data ) )
	setPedAimTarget( source, new_lookat )
	setPedLookAt( source, new_lookat, -1, FREQ )
end
addEvent( "head_c", true )
addEventHandler( "head_c", root, head_c_handler )

function onStreamIn( player )
	local player = player or source
	if getElementType( player ) ~= "player" then return end
	if STREAMED_PLAYERS[ player ] then return end
	STREAMED_PLAYERS[ player ] = true
	addEventHandler( "onClientElementStreamOut", player, onStreamOut )
	addEventHandler( "onClientElementDestroy", player, onStreamOut )
	addEventHandler( "onClientPlayerQuit", player, onStreamOut )
end
addEventHandler( "onClientElementStreamIn", root, onStreamIn )

function onStreamOut( )
	STREAMED_PLAYERS[ source ] = nil
	setPedAimTarget( source, 0, 0, 0 )
	setPedLookAt( source, 0, 0, 0, 0 )
	removeEventHandler( "onClientElementStreamOut", source, onStreamOut )
	removeEventHandler( "onClientElementDestroy", source, onStreamOut )
	removeEventHandler( "onClientPlayerQuit", source, onStreamOut )
end

function onClientResourceStart_handler( )
	for i, v in pairs( getElementsByType( "player" ) ) do
		if v ~= localPlayer then
			onStreamIn( v )
		end
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )

function onClientResourceStop_handler( )
	for v, _ in pairs( STREAMED_PLAYERS ) do
		setPedAimTarget( v, 0, 0, 0 )
		setPedLookAt( v, 0, 0, 0, 0 )
	end
	setPedLookAt( localPlayer, 0, 0, 0, 0 )
end
addEventHandler( "onClientResourceStop", resourceRoot, onClientResourceStop_handler )