-- sell from inventory
addEvent( "onPartSellConfirm", true )
addEventHandler( "onPartSellConfirm", resourceRoot, function ( tier, partID )
    if not isElement( client ) or not client.vehicle or client.vehicle ~= client:getData( "tuning_vehicle" ) then
        return
    end

    if type( tier ) ~= "number" or type( partID ) ~= "number" then
        return
    end

    local idx = client:FindPart( tier, partID )
    if idx and client:TakeTuningPartByPosition( tier, idx ) then
        local part = getTuningPartByID( partID, tier )
        local price = getSellPriceOfPart( part )

        client:RefreshPartsInventory( )
        client:PlaySound( SOUND_TYPE_2D, "sfx/sell1.mp3" )
        client:GiveMoney( price, "tuning", "tuning_detail" )
        client:InfoWindow( "Деталь успешно продана за " .. format_price( price ) .. " рублей!" )

        -- analytics / sell tuning part
        triggerEvent( "onTuningPartSell", client, part.id, part.name, INTERNAL_PARTS_NAMES_TYPES[ part.subtype ],
                VEHICLE_CLASSES_NAMES[ tier ], part.category, price )
    end
end )

-- check sell from vehicle
addEvent( "onPartSellFromVehicleAttempt", true )
addEventHandler( "onPartSellFromVehicleAttempt", resourceRoot, function ( partID )
    if not isElement( client ) or not client.vehicle then return end

    local part = getTuningPartByID( partID, client.vehicle:GetTier( ) )
    local partData = client.vehicle:GetPartDataByID( partID )

    if not part or not partData then return end

    local damaged = ( partData.damaged or 0 ) > 0

    triggerClientEvent( client, "onPartSellFromVehicleAttemptCallback", resourceRoot, part.id, getSellPriceOfPart( part, damaged ) )
end )

-- sell from vehicle
addEvent( "onPartSellFromVehicleConfirm", true )
addEventHandler( "onPartSellFromVehicleConfirm", resourceRoot, function ( partID )
    if not isElement( client ) or not client.vehicle or client.vehicle ~= client:getData( "tuning_vehicle" ) then return end

    local vehicle = client.vehicle
    local tier = vehicle:GetTier( )
    local part = getTuningPartByID( partID, tier )
    local partData = client.vehicle:GetPartDataByID( partID )

    if part and partData and vehicle:RemovePermanentPart( part.id ) then
        local damaged = ( partData.damaged or 0 ) > 0
        local price = getSellPriceOfPart( part, damaged )

        client:RefreshInstalledParts( )
        client:PlaySound( SOUND_TYPE_2D, "sfx/remove1.mp3" )
        client:GiveMoney( price, "tuning", "tuning_detail" )
        client:InfoWindow( "Деталь успешно снята с машины и продана\nза " .. format_price( price ) .. " рублей!" )

        vehicle:UpdateSpedometerMaxSpeed( )
        -- analytics / sell tuning part
        triggerEvent( "onTuningPartSell", client, part.id, part.name, INTERNAL_PARTS_NAMES_TYPES[ part.subtype ],
            VEHICLE_CLASSES_NAMES[ tier ], part.category, price )
    end
end )

-- install part from inventory
addEvent( "onPartInstallAttempt", true )
addEventHandler( "onPartInstallAttempt", resourceRoot, function ( partsIDs )
    if not isElement( client ) or not client.vehicle or client.vehicle ~= client:getData( "tuning_vehicle" ) then return end

    local vehicle = client.vehicle
    local tier = vehicle:GetTier( )
    local parts = vehicle:GetParts( )
    local result = false

    for _, id in pairs( partsIDs ) do
        local part = getTuningPartByID( id, tier )

        if part and not parts[ part.type ] and client:TakeTuningPart( tier, id ) then -- valid partID & empty slot & player has part
            vehicle:ApplyPermanentPart( id )
            result = true

            -- analytics / install tuning part
            triggerEvent( "onTuningPartInstall", client, part.id, part.name, INTERNAL_PARTS_NAMES_TYPES[ part.subtype ],
                PARTS_IMAGE_NAMES[ part.type ], part.category, vehicle )
        end
    end

    if result then
        client:RefreshPartsInventory( )
        client:RefreshInstalledParts( )
        client:CompleteDailyQuest( "install_inner_vehicle_detail" )
        client:PlaySound( SOUND_TYPE_2D, "sfx/install1.mp3" )
        client:InfoWindow( "Детали успешно установлены!", "УСТАНОВКА ДЕТАЛЕЙ" )
        
        vehicle:UpdateSpedometerMaxSpeed( )
    end
end )

-- use for others resources
addEvent( "onPlayerTuningInventoryRefresh" )
addEventHandler( "onPlayerTuningInventoryRefresh", root, function ( )
    source:RefreshPartsInventory( )
end )

addEvent( "onPlayerAddTuningPartInInventory" )
addEventHandler( "onPlayerAddTuningPartInInventory", root, function ( id, tier )
    local vehicle = source.vehicle

    if not vehicle or vehicle ~= source:getData( "tuning_vehicle" ) or tier ~= vehicle:GetTier( ) then return end

    triggerClientEvent( source, "onPlayerAddTuningPartInInventory", resourceRoot, id, tier )
end )