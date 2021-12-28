loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "ShUtils" )

PLAYER_REPORTS = {}

local iLastReset = getRealTime().timestamp

function OnCasinoDonateGameFinished( sGame, iBet, iParticipants, pWinners, sReason, pLeavers )
	local iTimeStamp = getRealTime().timestamp

	if iTimeStamp - iLastReset >= 24*60*60 then
		iLastReset = iTimeStamp
		PLAYER_REPORTS = {}
	end

	local sSlackStr = "\nСтавка: *"..iBet.."*\nПобедители:\n"

	for k,v in pairs( pWinners ) do
		local uid = v:GetID()

		if PLAYER_REPORTS[uid] then
			PLAYER_REPORTS[uid].wins = PLAYER_REPORTS[uid].wins + 1
		else
			PLAYER_REPORTS[uid] = { wins = 1, loses = 0 }
		end

		sSlackStr = sSlackStr.."> *"..v:GetNickName().."(ID:"..uid..")* - "..PLAYER_REPORTS[uid].wins.." побед за последние сутки\n"
	end

	sSlackStr = sSlackStr.."\nПроигравшие:\n"
	for k,v in pairs( pLeavers ) do
		if PLAYER_REPORTS[v.uid] then
			PLAYER_REPORTS[v.uid].loses = PLAYER_REPORTS[v.uid].loses + 1
		else
			PLAYER_REPORTS[v.uid] = { wins = 0, loses = 1 }
		end
		sSlackStr = sSlackStr.."> *"..v.name.."(ID:"..v.uid..")* - ".. (v.is_leave and "*Вышел*" or "Проиграл") .." - "..PLAYER_REPORTS[v.uid].loses.." поражений за последние сутки\n"
	end

	triggerEvent( "onSlackAlertRequest", root, 5, "["..sGame.."] "..formatTimestamp( getRealTime().timestamp ), { text = sSlackStr, color = "#ff7700", attachment_type = "default" } )
end
addEvent("OnCasinoDonateGameFinished", true)
addEventHandler("OnCasinoDonateGameFinished", root, OnCasinoDonateGameFinished)

function SaveReports()
	setElementData(root, "casino_reports", PLAYER_REPORTS, false)
	setElementData(root, "casino_reports_reset", iLastReset, false)
end
addEventHandler("onResourceStop", resourceRoot, SaveReports)

function LoadReports()
	PLAYER_REPORTS = getElementData(root, "casino_reports") or {}
	iLastReset = getElementData(root, "casino_reports_reset") or getRealTime().timestamp
end
addEventHandler("onResourceStart", resourceRoot, LoadReports)