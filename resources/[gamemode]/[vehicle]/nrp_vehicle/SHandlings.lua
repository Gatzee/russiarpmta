VEHICLES_HANDLING = {}
VARIANT_HANDLING = {}

function onResourceStart()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend("ShUtils")
	Extend("SVehicle")

	VEHICLES_HANDLING = GET("vehicles_handling") or {}
end
addEventHandler("onResourceStart", resourceRoot ,onResourceStart, true, "high-1")

function onResourceStop()
	SET("vehicles_handling", VEHICLES_HANDLING)
end
addEventHandler("onResourceStop", resourceRoot, onResourceStop)

function GetVariantHandling( vehicle )
	return VARIANT_HANDLING[vehicle] or VEHICLES_HANDLING[vehicle]
end

function SetVariantHandlingValue(vehicle, handling, value)
	if not VARIANT_HANDLING[vehicle] then VARIANT_HANDLING[vehicle] = {} end
	VARIANT_HANDLING[vehicle][handling] = value
	return true
end

function SetVariantHandling(vehicle, handling)
	VARIANT_HANDLING[vehicle] = handling
	return true
end

function GetSavedHandlingValue(vehicle, handling)
	if not VEHICLES_HANDLING[vehicle] then return false end
	return VEHICLES_HANDLING[vehicle][handling]
end

function SetSavedHandlingValue(vehicle, handling, value)
	if not VEHICLES_HANDLING[vehicle] then VEHICLES_HANDLING[vehicle] = {} end
	VEHICLES_HANDLING[vehicle][handling] = value
	return true
end