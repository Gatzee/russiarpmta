loadstring( exports.interfacer:extend( "Interfacer") )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "CVehicle" )

-- Обрботка коллизий
local setElementCollidableWith 	= setElementCollidableWith
local getElementsByType	= getElementsByType
local getElementType = getElementType

local TP_COLSHAPES = { }
local STREAMED_PLAYERS = { }

function onClientElementStreamIn_handler( element )
	local element = element or source
	local element_type = getElementType( element )
	if element_type == "colshape" then
		local parent = getElementParent( element )
		if not parent or getElementType( parent ) ~= "teleport_points" then return end

		if TP_COLSHAPES[ element ] then return end

		addEventHandler( "onClientColShapeHit", element, onClientElementColShapeHit_handler )
		addEventHandler( "onClientColShapeLeave", element, onClientElementColShapeLeave_handler )
		addEventHandler( "onClientElementStreamOut", element, onClientElementStreamOut_colshapeHandler )
		addEventHandler( "onClientElementDestroy", element, onClientElementStreamOut_colshapeHandler )
		TP_COLSHAPES[ element ] = true
	end
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientElementStreamIn_playerHandler( element )
	local element = element or source
	if getElementType( element ) ~= "player" then return end
	if STREAMED_PLAYERS[ element ] then return end
	for v, _ in pairs( TP_COLSHAPES ) do
		if isElementWithinColShape( element, v ) then
			element:setData( "_nocolplayers", true, false )
			break
		end
	end
	STREAMED_PLAYERS[ element ] = true
	addEventHandler( "onClientElementStreamOut", element, onClientElementStreamOut_playerHandler )
	addEventHandler( "onClientPlayerQuit", element, onClientElementStreamOut_playerHandler )
	addEventHandler( "onClientElementDataChange", element, onClientElementDataChange_handler )
	RefreshCollidableWithPlayers( localPlayer )
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_playerHandler )

function onClientResourceStart_handler( )
	for i, v in pairs( getElementsByType( "colshape", root, true ) ) do
		onClientElementStreamIn_handler( v )
	end
	for i, v in pairs( getElementsByType( "player", root, true ) ) do
		onClientElementStreamIn_playerHandler( v )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )

function onClientElementStreamOut_colshapeHandler( )
	removeEventHandler( "onClientColShapeHit", source, onClientElementColShapeHit_handler )
	removeEventHandler( "onClientColShapeLeave", source, onClientElementColShapeLeave_handler )
	removeEventHandler( "onClientElementStreamOut", source, onClientElementColShapeHit_handler )
	removeEventHandler( "onClientElementDestroy", source, onClientElementColShapeHit_handler )
	TP_COLSHAPES[ source ] = nil
end

function onClientElementStreamOut_playerHandler( )
	source:setData( "_nocolplayers", false, false )
	removeEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_playerHandler )
	removeEventHandler( "onClientPlayerQuit", source, onClientElementStreamOut_playerHandler )
	removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	STREAMED_PLAYERS[ source ] = nil
end

function onClientElementColShapeHit_handler( element, matching_dimension )
	if isElement( element ) then
		element:setData( "_nocolplayers", true, false )
	end
end

function onClientElementColShapeLeave_handler( element )
	if not isElement( element ) then return end
	element:setData( "_nocolplayers", false, false )
end

function onClientElementDataChange_handler( key )
	if key == "_nocolplayers" then
		RefreshCollidableWithPlayers( localPlayer )
	end
end

function onClientPlayerSpawn_handler()
	for k,v in pairs(TP_COLSHAPES) do
		if isElementWithinColShape( source, k ) then
			source:setData( "_nocolplayers", true, false )
			RefreshCollidableWithPlayers( source )
			break
		end
	end
end
addEventHandler ( "onClientPlayerSpawn", root, onClientPlayerSpawn_handler )

function RefreshCollidableWithPlayers( player )
	local player_nocollisionstate = getElementData( player, "_nocolplayers" )
	for v, _ in pairs( STREAMED_PLAYERS ) do
		local NoCollisionState = getElementData( v, "_nocolplayers" )
		local NewState = not ( player_nocollisionstate or NoCollisionState )
		setElementCollidableWith( player, v, NewState )
		setElementCollidableWith( v, player, NewState )
	end
end