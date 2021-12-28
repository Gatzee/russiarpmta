EVENT_STARTS = "12 декабря 2019 00:00"
EVENT_ENDS = "15 декабря 2019 23:59"

EVENT_NAME = "project_birthday_19"
EVENT_PED_POSITION = { x = -101.3342, y = -1129.5708, z = 20.8015 }

function IsEventActive()
	local iTime = getRealTime().timestamp
	return iTime > EVENT_STARTS and iTime < EVENT_ENDS
end

