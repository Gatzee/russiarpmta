Extend( "CInterior" )

DEALERS_LIST = {}

DEALERS_DATA = 
{
    base_assortment = {
        { id = 22, name = "Glock", cost = 1000 },
    },

    dealers_config = 
    {
        [1] = 
        {
            pPosition = {1321.9,-1202.4,20.5},
            fRotation = 90,
            sZone = "gorki_war",
            iModel = 227,
        },

        [2] = 
        {
            pPosition = {-1361.5,1092,19.6-0.7},
            fRotation = 0,
            sZone = "countryside_war",
            iModel = 227,
        }
    }
}

function GunDealer( config )
    local self = table.copy(config)

    self.marker = {}
    self.marker.x = self.pPosition[1]
    self.marker.y = self.pPosition[2]
    self.marker.z = self.pPosition[3]
    self.marker.radius = 3
    self.marker.keypress = "lalt"
    self.tpoint = TeleportPoint( self.marker )
    self.tpoint.clan = self
    self.tpoint.text = "ALT Взаимодействие"
    self.tpoint.elements = { }
    self.tpoint.elements.blip = Blip( self.marker.x, self.marker.y, self.marker.z, 0, 3, 0, 255, 0, 255, 1, 500 )
    self.tpoint.elements.blip:setData( "extra_blip", 70, false )
    setMarkerColor( self.tpoint.marker, 120, 0, 0, 0 )

    self.tpoint.PostJoin = function( self, player )
        local clan_id = player:GetClanID( )
        if not clan_id then
            player:ErrorWindow( "Ты не состоишь в клане" )
            return false
        end

        triggerServerEvent( "onPlayerWantShowGundealerUI", localPlayer )
    end

    self.destroy = function( self )
        self.tpoint:destroy()

        for k,v in pairs(self) do
            if isElement(v) then
                destroyElement( v )
            end
        end
    end

    DEALERS_LIST[self.id] = self

    return self
end

for i, conf in pairs(DEALERS_DATA.dealers_config) do
    conf.id = i
    conf.pAssortment = table.copy( DEALERS_DATA.base_assortment )
    GunDealer( conf )
end

-- Vehicles
pVehicles = 
{
    { 445, 1325.6556396484,-1199.6770019531,20.6,40},
    { 560, 1317.6253662109,-1200.3229980469,20.2,329},
    { 555, -1366.0694580078, 1092.2572021484, 19.4-0.65, 300},
    { 426, -1358.4140625,1095.2132568359,19.477022171021-0.7,64},
}
addEventHandler("onClientResourceStart", resourceRoot, function()
	for k,v in pairs(pVehicles) do
		local vehicle = createVehicle( v[1], v[2], v[3], v[4], 0, 0, v[5] )
		setVehicleColor(vehicle, 0,0,0)
		vehicle.locked = true
		vehicle.frozen = true
		vehicle.engineState = false
		vehicle:SetWindowsColor( 0, 0, 0, 240 )
	end
end)
