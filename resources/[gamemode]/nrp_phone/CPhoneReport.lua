REPORTAPP = nil

ADMIN_INFO_TO_RATE = false

addEvent( "onClientReportClosed", true )
addEventHandler( "onClientReportClosed", root, function( admin_info_to_rate )
    ADMIN_INFO_TO_RATE = admin_info_to_rate
end )

APPLICATIONS.report = {
    id = "report",
    icon = "img/apps/report.png",
    name = "Репорты",
    elements = { },
    create = function( self, parent, conf )
        if ADMIN_INFO_TO_RATE then
            triggerEvent( "onClientOpenRateReportWindow", localPlayer, ADMIN_INFO_TO_RATE )
            ADMIN_INFO_TO_RATE = nil
        else
            triggerEvent( "onClientOpenReportWindow", localPlayer )
        end
        ShowPhoneUI(false)
    end,
    destroy = function( self, parent, conf )
        REPORTAPP = nil
    end,
}