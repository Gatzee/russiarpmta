ADMIN_REPORTS_ACCEPTED = { }

function onPlayerCompleteLogin_reportsHandler( player )
    local player = isElement( player ) and player or source
    if not player:IsAdmin( ) then return end
	
    local reports_accepted = player:GetAdminData( "reports_accepted" )
    if reports_accepted then
        for period, data in pairs( reports_accepted ) do
            if period ~= "session" then
                if data.reset_date and NEXT_RESET_DATES[ period ] > data.reset_date then
                    data.count = 0
                    data.reset_date = NEXT_RESET_DATES[ period ]
                else
                    data.count = data.count + reports_accepted.session
                end
            end
        end
        reports_accepted.session = 0
    else
        reports_accepted = {
            total = { count = 0 },
            month = { count = 0, reset_date = NEXT_RESET_DATES.month },
            week = { count = 0, reset_date = NEXT_RESET_DATES.week },
            day = { count = 0, reset_date = NEXT_RESET_DATES.day },
            session = 0,
        }
    end
    player:SetAdminData( "reports_accepted", reports_accepted )

    ADMIN_REPORTS_ACCEPTED[ player ] = reports_accepted
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_reportsHandler, true, "high" )

function onResourceStart_reportsHandler()
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_reportsHandler( v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_reportsHandler, true, "high" )

function onAdminAcceptReport_reportsHandler()
    local reports_accepted = ADMIN_REPORTS_ACCEPTED[ source ]
    if reports_accepted then
        reports_accepted.session = reports_accepted.session + 1
    end
    source:SetAdminData( "reports_accepted", reports_accepted )

    triggerClientEvent( source, "AP:NewReportAccepted", source )
end
addEvent( "onAdminAcceptReport" )
addEventHandler( "onAdminAcceptReport", root, onAdminAcceptReport_reportsHandler, true, "high" )

function ResetOnlineAdminsReportsAccepted( reset_period, new_reset_date )
    for player, reports_accepted in pairs( ADMIN_REPORTS_ACCEPTED ) do
        for period, data in pairs( reports_accepted ) do
            if period ~= "session" then
                data.count = data.count + reports_accepted.session
            end
        end
        reports_accepted.session = 0
        reports_accepted[ reset_period ].count = 0
        reports_accepted[ reset_period ].reset_date = new_reset_date
        player:SetAdminData( "reports_accepted", reports_accepted )
    end
end

function onPlayerPreLogout_reportsHandler( player )
    local player = isElement( player ) and player or source

	ADMIN_REPORTS_ACCEPTED[ player ] = nil
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_reportsHandler )

addEvent( "onPlayerAccessLevelChange" )
addEventHandler( "onPlayerAccessLevelChange", root, function( old_access_level, new_access_level )
    if old_access_level == 0 and new_access_level > 0 then
        onPlayerCompleteLogin_reportsHandler( source )
    elseif old_access_level > 0 and new_access_level == 0 then
        onPlayerPreLogout_reportsHandler( source )
    end
end )