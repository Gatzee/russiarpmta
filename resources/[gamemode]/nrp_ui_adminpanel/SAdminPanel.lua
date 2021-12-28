loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

DATA = {}

function OpenAdminPanel( player )
	local allowed = player:IsAdmin() or player:GetPermanentData( "camhack" )
	if not allowed then return end
	player:SetPrivateData( APData, not player:getData( APData ))
end
addCommandHandler( "apanel", OpenAdminPanel )

function OpenAdminMode( player )
	if not player:IsAdmin() then return end
	player:SetPrivateData( "_amode", not player:getData( "_amode" ))
end
addCommandHandler( "adminmode", OpenAdminMode )

function BindAPKeys( )
	for i, v in pairs( getElementsByType( "player" ) ) do
		bindKey( v, "F5", "down", OpenAdminPanel ) 
	end
end
addEventHandler( "onResourceStart", resourceRoot, BindAPKeys )
addEventHandler( "onPlayerJoin", root, function() bindKey( source, "F5", "down", OpenAdminPanel ) end)

addEvent("onAdminPanelDataSwitch",true)
function onAdminPanelDataSwitch(data)
	local player = client or source
	if data.interior then player.interior = 0; player.interior = data.interior end
	if data.dimension then player.dimension = 0; player.dimension = data.dimension end
end
addEventHandler("onAdminPanelDataSwitch",root,onAdminPanelDataSwitch)

addEvent("onAdminPanelDefaultSwitch", true)
function onAdminPanelDefaultSwitch(data)
	DATA[source] = data
end
addEventHandler("onAdminPanelDefaultSwitch", root, onAdminPanelDefaultSwitch)

addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, function()
	local save = DATA[source]
	if type(save) ~= "table" then return end
	local position, interior, dimension = unpack(save)
	source.position = Vector3(unpack(position))
	source.interior = interior
	source.dimension = dimension
	DATA[source] = nil
end, true, "high+100000000")

function OnSpectateRequest( pTarget )
	if isElement(pTarget) then
		if not client:getData(APData) then 
			OpenAdminPanel(client) 
		end

		triggerClientEvent( client, "AP:OnSpectateRequest", client, pTarget )
	end
end
addEvent("AP:OnSpectateRequest", true)
addEventHandler("AP:OnSpectateRequest", root, OnSpectateRequest)