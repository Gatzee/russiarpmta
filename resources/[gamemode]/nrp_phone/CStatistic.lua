STATISTICAPP = nil

APPLICATIONS.statistic = {
    id = "statistic",
    icon = "img/apps/statistic.png",
    name = "Статистика",
    elements = { },
    create = function( self, parent, conf )
        triggerEvent( "socialInteractionShowMenu", localPlayer )
        ShowPhoneUI( false )
        STATISTICAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        STATISTICAPP = nil
    end,
}