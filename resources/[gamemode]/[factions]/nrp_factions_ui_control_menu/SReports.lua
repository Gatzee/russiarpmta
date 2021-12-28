local REPORT_DELAY = 15*60
local REPORT_STORE_DURATION = 24*60*60
local LAST_REPORT_SENT = {}

local LAST_REPORTS_CACHE = {}

function OnPlayerTrySendFactionReport( data )
	local pSource = client or source

	if not pSource then return end

	if LAST_REPORT_SENT[pSource:GetID()] then
		pSource:ShowError("Нельзя отправлять жалобы так часто")
		return false
	end

	local pFoundPlayer = false
	for k,v in pairs( getElementsByType( "player" ) ) do
		if v:GetNickName() == data.name then
			if v:GetFaction() ~= data.faction then
				break
			end

			pFoundPlayer = v
			break
		end
	end

	if not pFoundPlayer then
		pSource:ShowError( "Сотрудник не найден" )
		return false
	end

	local pCurrentReports = pFoundPlayer:GetPermanentData( "faction_reports" ) or {}
	local pNewReport = 
	{
		name = pSource:GetNickName(),
		desc = data.reason,
		created = getRealTime().timestamp,
		watched = false,
	}

	table.insert( pCurrentReports, pNewReport )

	if #pCurrentReports > 20 then
		repeat 
			table.remove( pCurrentReports, 1 )
		until
			#pCurrentReports <= 20
	end

	local pAdminReport = 
	{
		source_name = pNewReport.name,
		target_name = pFoundPlayer:GetNickName(),
		source = pSource,
		target = pFoundPlayer,
		desc = pNewReport.desc,
		created = pNewReport.created,
	}

	table.insert( LAST_REPORTS_CACHE, pAdminReport )

	if #LAST_REPORTS_CACHE > 50 then
		repeat 
			table.remove( LAST_REPORTS_CACHE, 1 )
		until
			#LAST_REPORTS_CACHE <= 50
	end

	pFoundPlayer:SetPermanentData( "faction_reports", pCurrentReports )

	pSource:ShowSuccess( "Жалоба успешно отправлена" )
	LAST_REPORT_SENT[pSource:GetID()] = true

	setTimer( function( uid )
		LAST_REPORT_SENT[uid] = nil 
	end, REPORT_DELAY*1000, 1, pSource:GetID())

	return true
end
addEvent("OnPlayerTrySendFactionReport", true)
addEventHandler("OnPlayerTrySendFactionReport", root, OnPlayerTrySendFactionReport)

function OnPlayerWatchReports( iTargetID )
	local pTarget = GetPlayer( iTargetID )
	if not isElement(pTarget) then return end
	local pReportsList = pTarget:GetPermanentData( "faction_reports" ) or {}

	for k,v in pairs(pReportsList) do
		v.watched = true
	end

	pTarget:SetPermanentData( "faction_reports", pReportsList )
end
addEvent("OnPlayerWatchReports", true)
addEventHandler("OnPlayerWatchReports", root, OnPlayerWatchReports)


function OnPlayerReadyToPlay( pPlayer )
	local pPlayer = pPlayer or source
	local pReportsList = pPlayer:GetPermanentData( "faction_reports" ) or {}

	local iCurrentTime = getRealTime().timestamp

	while true do
		local bFound = false

		for k,v in pairs(pReportsList) do
			local iTimePassed = iCurrentTime - ( v.created or 0 )
			if iTimePassed > REPORT_STORE_DURATION then
				table.remove(pReportsList, k)
				bFound = true
			end
		end

		if not bFound then
			break
		end
	end
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerReadyToPlay, true, "low-1000")

function OnResourceStart()
	for k,v in pairs( getElementsByType("player") ) do
		OnPlayerReadyToPlay( v )
	end
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function OnAdminRequestDeleteFactionReport( pTarget, iID, pReportData )
	if not isElement(pTarget) then return end

	local pCurrentReports = pTarget:GetPermanentData( "faction_reports" )

	for k,v in pairs(pCurrentReports) do
		if v.created == pReportData.created then
			table.remove(pCurrentReports, k)
			break
		end
	end

	pTarget:SetPermanentData( "faction_reports", pCurrentReports )

	for k,v in pairs(LAST_REPORTS_CACHE) do
		if k == tonumber(iID) then
			table.remove( LAST_REPORTS_CACHE, k )
			break
		end
	end

	OnAdminRequestFactionReportsList( client )
end
addEvent("AP:OnAdminRequestDeleteFactionReport", true)
addEventHandler("AP:OnAdminRequestDeleteFactionReport", root, OnAdminRequestDeleteFactionReport)

function OnAdminRequestFactionReportsList( pAdmin )
	local pAdmin = client or pAdmin

	local pReportsToSend = {}

	for k,v in pairs( LAST_REPORTS_CACHE ) do
		if isElement(v.target) then
			table.insert(pReportsToSend, v)
		end
	end

	triggerClientEvent( pAdmin, "AP:ReceiveFactionReportsList", pAdmin, pReportsToSend )
end
addEvent("AP:OnAdminRequestFactionReportsList", true)
addEventHandler("AP:OnAdminRequestFactionReportsList", root, OnAdminRequestFactionReportsList)