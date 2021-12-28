RACESAPP = nil

APPLICATIONS.races = {
    id = "races",
    icon = "img/apps/races.png",
    name = "Гонки",
    elements = { },
    create = function( self, parent, conf )
        triggerEvent( "onClientRaceWindowShow", resourceRoot )
        triggerServerEvent( "RC:OnPlayerWantRaceMenu", root )
        triggerEvent( "HideUIGarage", root )
        ShowPhoneUI( false )
        RACESAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        RACESAPP = nil
    end,
}