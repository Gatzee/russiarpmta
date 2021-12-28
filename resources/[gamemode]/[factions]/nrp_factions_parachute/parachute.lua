
local function onResourceStart ( resource )
	local players = getElementsByType ( "player" )
	for k, v in pairs ( players ) do
		setElementData ( v, "parachuting", false )
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )

function requestAddParachute ()
	local plrs = getElementsByType( "player" )
	local dimension = getElementDimension( client )
	for key,player in pairs( plrs ) do
		if dimension ~= getElementDimension( player ) or player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doAddParachuteToPlayer", client)
end
addEvent ( "requestAddParachute", true )
addEventHandler ( "requestAddParachute", resourceRoot, requestAddParachute )

function requestRemoveParachute ()
	exports.nrp_handler_weapons:TakeWeapon( client, 46 )
	local plrs = getElementsByType("player")
	for key,player in pairs(plrs) do
		if player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doRemoveParachuteFromPlayer", client)
end
addEvent ( "requestRemoveParachute", true )
addEventHandler ( "requestRemoveParachute", resourceRoot, requestRemoveParachute )