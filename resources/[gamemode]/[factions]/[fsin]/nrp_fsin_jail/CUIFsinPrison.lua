Extend( "ib" )

ibUseRealFonts( true )

scX, scY = guiGetScreenSize()
posX, posY = 120, scY / 2 - 120

UI_Elements = {}

-- Информация о заключении
function CreateDescriptionJail()

    if isElement( UI_Elements.bg ) then
        UI_Elements.bg:destroy()
    end

    UI_Elements.bg = ibCreateArea( 0, 0, scX, scY )
    :ibData("priority", -100)

    UI_Elements.jailLabel = ibCreateLabel( posX, posY, posX, posY, "Вы в заключении!", UI_Elements.bg, 0xFFFFE2A7, 1, 1, "left", "top", ibFonts.bold_20 )
    :ibData( "outline", 1)

    local jail_reason = ""

	local pWantedData = getElementData( localPlayer, "wanted_data" ) or {}
	if #pWantedData > 1 then
		jail_reason = "А так же: "
		for k,v in pairs( pWantedData ) do
			jail_reason = jail_reason .. v[ 1 ] .. (next(pWantedData, k) and "," or "")
		end
	end

    local reason = "Причина - " .. CURRENT_JAIL_DATA.reason .. "\n" .. jail_reason
    UI_Elements.jailReason = ibCreateLabel( posX, posY + 35, posX, posY, reason, UI_Elements.bg, 0xDDFFFFFF, 1, 1, "left", "top", ibFonts.bold_16 )
    :ibData( "outline", 1)

    UI_Elements.jailTime = ibCreateLabel( posX, posY + 75, posX, posY, time_left, UI_Elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_20 )
    :ibData( "outline", 1)

    SetJailTime( UI_Elements.jailTime, "на ", CURRENT_JAIL_DATA.end_tick )

    UI_Elements.jailTime:ibTimer( function()
        SetJailTime( UI_Elements.jailTime, "на ", CURRENT_JAIL_DATA.end_tick )
    end, 5000, 0 )

end

-- Информация о побеге
function CreateDescriptionLeavePrsion()

    if isElement( UI_Elements.bg ) then
        UI_Elements.bg:destroy()
    end

    UI_Elements.bg = ibCreateArea( 0, 0, scX, scY )
    :ibData("priority", -100)

    UI_Elements.jailLabel = ibCreateLabel( posX, posY, posX, posY, "Вы сбежали из тюрьмы", UI_Elements.bg, 0xFFFFE2A7, 1, 1, "left", "top", ibFonts.bold_20 )
    :ibData( "outline", 1)

    UI_Elements.jailTime = ibCreateLabel( posX, posY + 35, posX, posY, "", UI_Elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_20 )
    :ibData( "outline", 1)

    SetJailTime( UI_Elements.jailTime, "Розыск закончится через ", LEAVE_END_TICKS )

    UI_Elements.jailTime:ibTimer( function()
        SetJailTime( UI_Elements.jailTime, "Розыск закончится через ", LEAVE_END_TICKS )
    end, 5000, 0 )

end

function SetJailTime( element, text, ticks )

    local iTimeLeft = math.max( ( ticks - getTickCount() ) / 1000, 0 )
    local iHours    = math.floor( iTimeLeft / 3600 )
    local iMinutes  = math.ceil( iTimeLeft / 60 ) - iHours * 60

    local time_left = text .. ( iHours > 0 and iHours .. plural( iHours, " час ", " часа ", " часов " ) or "" ) .. iMinutes .. plural( iMinutes, " минуту", " минуты", " минут" )
    element:ibData( "text", time_left )

end

-- Обновление время заключения
function OnRefreshJailTime( time )

    CURRENT_JAIL_DATA.end_tick = getTickCount() + time * 1000

    if not UI_Elements.bg then
        CreateDescriptionJail()
    else
        SetJailTime( UI_Elements.jailTime, "на ", CURRENT_JAIL_DATA.end_tick )
    end

end
addEvent( "prison:OnClientRefreshJailTime", true )
addEventHandler( "prison:OnClientRefreshJailTime", root, OnRefreshJailTime )