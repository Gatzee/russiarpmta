--[[local getElementType = getElementType
local triggerEvent = triggerEvent

local EVENTS = {
    player = "onClientPlayerStreamIn",
    vehicle = "onClientVehicleStreamIn",
}
for i, v in pairs( EVENTS ) do
    addEvent( v, true )
end

local function onClientElementStreamIn( )
    local event = EVENTS[ getElementType( source ) ]
    if event then triggerEvent( event, source ) end
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn )]]