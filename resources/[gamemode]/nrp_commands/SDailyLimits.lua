CONST_DB_FIELD_NAME = "admin_limits_default_new" -- "admin_limits_default"

DEFAULT_LIMITS = 
{
	[ACCESS_LEVEL_MODERATOR] = 
	{
		ban = { value = 5, targets = 5 },
		donate = { value = 0, targets = 0 },
		money = { value = 0, targets = 0 },
	},
	[ACCESS_LEVEL_SENIOR_MODERATOR] = 
	{
		ban = { value = 10, targets = 10 },
		donate = { value = 0, targets = 0 },
		money = { value = 0, targets = 0 },
	},
	[ACCESS_LEVEL_ADMIN] = 
	{
		ban = { value = 15, targets = 15 },
		donate = { value = 0, targets = 0 },
		money = { value = 0, targets = 0 },
	},
	[ACCESS_LEVEL_SENIOR_ADMIN] = 
	{
		ban = { value = 15, targets = 15 },
		donate = { value = 0, targets = 0 },
		money = { value = 0, targets = 0 },
	},
	[ACCESS_LEVEL_SUPERVISOR] = 
	{
		donate = { 
			monthly = { value = 2500, targets = 9999 }, 
		},
		money = { value = 500000, targets = 9999 },
		ban = { value = 15, targets = 15 },
	},
}

CUSTOM_LIMITS = 
{
	marketing = 
	{
		donate = { value = 50000, targets = 10},
		money = { value = 50000000, targets = 10 },
		ban = { value = 10, targets = 10 },
	},
	unlimited = {
		donate = { value = 2^63, targets = 2^63 },
		money = { value = 2^63, targets = 2^63 },
		ban = { value = 10, targets = 10 },
	}
}

TRACKED_DATA = { last_update = getRealTime().timestamp }
REPORT_DATA = {}

function AdminTryGiveSomething( pAdmin, pTarget, item_type, value )
	local current_timestamp = getRealTime().timestamp
	if current_timestamp - (TRACKED_DATA.last_update or 0) >= 60*60*24 then
	--	SendReport()

		TRACKED_DATA = { last_update = current_timestamp }
		REPORT_DATA = {}
	end

	local iAdminID = pAdmin:GetUserID()
	local iTargetID = pTarget:GetUserID()

	local iAccessLevel = pAdmin:GetAccessLevel()
	local bIsDeveloper = iAccessLevel >= ACCESS_LEVEL_DEVELOPER

	local pDefLimits = GetDefaultLimits()

	pDefLimits = pDefLimits[ iAccessLevel ] or pDefLimits[ ACCESS_LEVEL_ADMIN ]

	local sClientID = pAdmin:GetClientID()
	local pCustomLimitUsers = GetCustomLimits()
	if pCustomLimitUsers and pCustomLimitUsers[sClientID] then
		pDefLimits = CUSTOM_LIMITS[ pCustomLimitUsers[sClientID] ]
	end
	
	local item_limits = {value = 100000000}

	if item_limits.daily or item_limits.value then
		local tracked_data = TRACKED_DATA[ iAdminID ] or {}
		local item = tracked_data[ item_type ] or { value = 0, targets = { } }
		local limit = item_limits.daily or item_limits

		if not CheckItemLimits( item, limit, value, iTargetID, bIsDeveloper ) then return end
		tracked_data[ item_type ] = item
		TRACKED_DATA[ iAdminID ] = tracked_data
	end

	if item_limits.monthly then
		local tracked_data = pAdmin:GetPermanentData( "admin_tracked_data" ) or { }
		local item = tracked_data[ item_type ]
		if not item or current_timestamp - ( item.last_update or 0 ) >= 30 * 24 * 60 * 60 then
			item = { value = 0, targets = { }, last_update = current_timestamp }
		end
		local limit = item_limits.monthly

		if not CheckItemLimits( item, limit, value, iTargetID, bIsDeveloper ) then return end
		tracked_data[ item_type ] = item
		pAdmin:SetPermanentData( "admin_tracked_data", tracked_data )
	end

	-- UPDATING REPORT DATA
	local pReport = REPORT_DATA[iAdminID] or { name = pAdmin:GetNickName() }
	local pReportTarget = pReport[iTargetID] or { name = pTarget:GetNickName() }
	pReportTarget[ item_type ] = (pReportTarget[ item_type ] or 0) + value
	pReport[iTargetID] = pReportTarget
	REPORT_DATA[iAdminID] = pReport

	return true
end

function CheckItemLimits( item, limit, value, iTargetID, bIsDeveloper )
	if not bIsDeveloper and item.value + value >= limit.value then
		return false
	end

	local bSameTarget = false
	for k,v in pairs( item.targets ) do
		if v == iTargetID then
			bSameTarget = true
			break
		end
	end

	if not bSameTarget then
		if not bIsDeveloper and #item.targets >= limit.targets then
			return false
		else
			table.insert( item.targets, iTargetID )
		end
	end

	item.value = item.value + value

	return true
end

function GetDefaultLimits()
	local data = MariaGet( CONST_DB_FIELD_NAME )
	data = data and fromJSON( data ) or {}

	local output = {}

	for k,v in pairs(data) do
		output[tonumber(k)] = v
	end

	return output
end

function GetCustomLimits()
	local data = MariaGet("admin_limits")

	return data and fromJSON( data ) or {}
end

function SaveLimits()
	setElementData(root, "admin_limits", TRACKED_DATA, false)
	setElementData(root, "admin_daily_report", REPORT_DATA, false)

--	SendReport()
end
addEventHandler("onResourceStop", resourceRoot, SaveLimits)

function LoadLimits()
	TRACKED_DATA = getElementData(root, "admin_limits") or { last_update = getRealTime().timestamp }
	REPORT_DATA = getElementData(root, "admin_daily_report") or { }
end
addEventHandler("onResourceStart", resourceRoot, LoadLimits)

--[[function SendReport()
	-- DAILY REPORT
	local str = "[DAILY REPORT] ( "..formatTimestamp(TRACKED_DATA.last_update).." - "..formatTimestamp( getRealTime().timestamp ).." )\n"
	for k,v in pairs(REPORT_DATA) do
		str = str.."[ *"..v.name.." (UID:"..k..")* ".."]\n"

		for target, items in pairs(v) do
			if type(items) == "table" then
				str = str.."> *"..items.name.." (ID:"..target..")* - "

				for item, amount in pairs(items) do
					if item ~= "name" then
						str = str..item.." "..amount..", "
					end
				end

				str = str.."\n"
			end
		end
	end
	triggerEvent( "onSlackAlertRequest", root, 4, "Выдача имущества (SRV-"..get( "server.number" )..")", { text = str, color = "#ff7700", attachment_type = "default" } )
end]]