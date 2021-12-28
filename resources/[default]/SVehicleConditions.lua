Extend( "SVehicle" )
Extend( "Globals" )
Extend( "SDB" )

--addEventHandler ( "onResourceStart", resourceRoot, function() -- обнуление пробега при старте ресурса
--     local sQuery = "UPDATE nrp_vehicles SET mileage = 0"
--     DB:exec( sQuery )
-- end )

function GetVehicleTuningLevels( vehicle )
    local tParts = vehicle:GetParts( )
    local sum = 0

    for _, part in pairs( tParts ) do
        local partConf = getTuningPartByID( part.id )
        sum = sum + ( partConf and partConf.category or 0 )
    end

    if sum ~= 0 then
        sum = sum - 1
    end
    return ( sum - sum % 5 )
end

function GetDamageCoeff( vehicle )
    if not isElement( vehicle ) then return false end

    local currentStatus = vehicle:GetProperty( "statusNumber" )

    if not currentStatus then return 0.5 end

    local tuningDetails = GetVehicleTuningLevels( vehicle )
    local vehClass = vehicle:GetTier( )

    return STATUSES_DATA.damage[ vehClass ][ currentStatus ] * TUNING_EFFECT_WEAR.damage[ tuningDetails ]
end

--[[function updateSpeedLimitByStatus( vehicle, value )
    local parts = vehicle:GetParts( )
    local maxspeed, acceleration, controllability, clutch, slip = vehicle:GetStats( parts, true )

    if value == STATUS_TYPE_HARD or value == STATUS_TYPE_CRIT then
        local minus = value == STATUS_TYPE_HARD and 10 or 20
        setVehicleParameters( vehicle, maxspeed - minus, acceleration, controllability, clutch, slip )
    else
        setVehicleParameters( vehicle, maxspeed, acceleration, controllability, clutch, slip )
    end
--]]end

function OnDetailsChangeLevel()
    local vehicle = getPedOccupiedVehicle( source )
    if vehicle:GetNotSuitableType() then return end

    local tuningDetails = GetVehicleTuningLevels( vehicle )
    local currentMileage = vehicle:GetMileage()
    local vehClass = vehicle:GetTier()

    local neededStatus = 0
    for i = 3, 1 do -- находим тот статус, который нужен после изменения детали
        if currentMileage >= STATUSES_DATA.mileage[ vehClass ][ i ] * TUNING_EFFECT_WEAR.status[ tuningDetails ] then
            neededStatus = i
            break
        end
    end

    neededStatus = neededStatus + 1 -- из-за разницы в индексах таблицы и значений классов

	local currentStatus = vehicle:GetProperty( "statusNumber" )
	if currentStatus ~= neededStatus then
		vehicle:SetProperty( "statusNumber", neededStatus )
	end
end
addEventHandler( "onTuningPartInstall", root, OnDetailsChangeLevel )
addEventHandler( "onTuningPartSell", root, OnDetailsChangeLevel )

function OnMileageChange_handler( mileage )
    local carStatus = source:GetProperty( "statusNumber" ) -- получаем статус авто в виде цифры
    if not carStatus then return end

    local carClass = source:GetTier( ) -- получаем класс авто в цифре

    local countTuningLevels = GetVehicleTuningLevels( source )
    local coeffTuningEffect = TUNING_EFFECT_WEAR.status[ countTuningLevels ]

    local defaultMileances = STATUSES_DATA.mileage[ carClass ]
    local newStatus = 1

    for status, value in ipairs( defaultMileances ) do
        if mileage >= value * coeffTuningEffect then
            newStatus = status + 1
        end
    end

	local currentStatus = source:GetProperty( "statusNumber" )
	if currentStatus ~= newStatus then
		source:SetProperty( "statusNumber", newStatus )

        updateSpeedLimitByStatus( source, newStatus )
        triggerEvent( "onVehicleChangeStatus", source, newStatus )
	end
end
addEvent( "onVehicleMileageChanged", true )
addEventHandler( "onVehicleMileageChanged", root, OnMileageChange_handler )

function onChangingVehicleHealth( vehicle, loss ) 
    local damCoeff = GetDamageCoeff( vehicle )
    if not damCoeff then return end

    vehicle.health = vehicle.health - loss * damCoeff
end
addEvent( "changeCarHealthOnDamage", true )
addEventHandler( "changeCarHealthOnDamage", resourceRoot, onChangingVehicleHealth )

function SettingNewStatusForCar()
    if not isElement( source ) or source:GetNotSuitableType() then return end

    local currentStatus = source:GetProperty( "statusNumber" )

    if currentStatus then
        updateSpeedLimitByStatus( source, currentStatus )
        return
    end

    source:SetProperty( "statusNumber", STATUS_TYPE_EASY )
end
addEvent( "onVehiclePostLoad" )
addEventHandler( "onVehiclePostLoad", root, SettingNewStatusForCar )