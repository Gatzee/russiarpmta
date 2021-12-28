function onTowtruckListRequest_handler()
    --iprint( "requested", source )
    local player = client or source

    local vehicles = player:GetVehicles( _, true )
    local vehicles_list = {}

    local quest_evacuation = player:getData( "quest_evacuation" )

    for i, v in pairs( vehicles ) do
        if isElement(v) then
            --if not v:GetBlocked() then
                local distance = math.floor( ( player.position - v.position ):getLength() )
                local available = v:GetEvacuationAvailable( ) and not v:GetBlocked( ) and player.interior == 0
                if not quest_evacuation then
                    available = available and player.dimension == 0
                end
                local sVisibleNumber = v:GetNumberPlateHR()
                local name = v:GetShortName()
                local changed = false
                while utf8.len( name ) > 14 do
                    name = utf8.sub( name, 1, -2 )
                    changed = true
                end
                if changed then name = name .. "..." end
                table.insert( vehicles_list, { v, name, sVisibleNumber, available and distance, available and GetEvacuationPrice( player, v, distance ), v:GetParked(), v:IsConfiscated() } )
            --end
        end
    end

    local free_evacuations = player:GetAllFreeEvacuations( )

    triggerClientEvent( { source }, "onTowtruckListRequestCallback", resourceRoot, vehicles_list, free_evacuations )
end
addEvent( "onTowtruckListRequest", true )
addEventHandler( "onTowtruckListRequest", root, onTowtruckListRequest_handler )

function onTowtruckRequest_handler( element )
	if client and client ~= source then
		triggerEvent( "DetectPlayerAC", client, "98" )
		return
	end

    local player = client or source
    if isPedDead( player ) then
        player:ShowError( "Зачем мёртвому автомобиль?" )
        return
    end
    if player:getData("jailed") then
        player:ShowError( "Заключённым услуги не оказываем!" )
        return
    end

    local quest_evacuation = player:getData( "quest_evacuation" )

    if player.dimension ~= 0 and not quest_evacuation or player.interior ~= 0 then
        player:ShowError( "Выйдите на улицу и завершите текущую задачу для эвакуации транспорта" )
        return
    end
    if not element:GetEvacuationAvailable() then
        player:ShowError( "Нельзя эвакуировать этот автомобиль!" )
        return false
    end
    if getElementData( element, 'tow_evac_added' ) then
        player:ShowError( "Авто ожидает эвакуации\nили уже эвакуируется!" )
        return false
    end
    if getElementData( player, "no_evacuation" ) or (player:GetJobClass() == JOB_CLASS_INDUSTRIAL_FISHING and player:GetOnShift()) then
        player:ShowError( "Нельзя эвакуировать в данном месте!" )
        return false
    end
	if element:GetParked() then
        if player:GetCountVehiclesNotParked() >= 2 then
            local vehicles_ = player:GetVehicles( _, true )
            for i, vehicle in pairs( vehicles_ ) do
                if isElement( vehicle ) and not vehicle:GetParked( ) then
                    vehicle:SetParked( true )
                    vehicle:SetPermanentData( "police_evac_added", nil )
                    vehicle:setData( "police_evac_added", false )
                    break
                end
            end
		end
    end

    local distance = ( player.position - element.position ):getLength()
    local vehicle_id = element:GetID( )
    local free_evacuation = player:HasFreeEvacuation( vehicle_id ) or player:HasFreeEvacuation( 0 )
    local price = free_evacuation and 0 or GetEvacuationPrice( player, element, distance )

    local money = player:GetMoney()

    if price > money then
        player:EnoughMoneyOffer( "Towtruck", price, "onTowtruckRequest", player, element )
        return
    end

    player:TakeMoney( price, "vehicle_evacuation" )
    if free_evacuation then
        player:TakeFreeEvacuation( vehicle_id )
    end
    
    local _, _, rotation = getElementRotation( player )
    rotation = rotation - 90

    local distance = 3
    local offx, offy = -math.cos( math.rad( rotation ) ) * distance, -math.sin( math.rad( rotation ) ) * distance
    
    element:SetParked( false, element.position, element.rotation )

    element.dimension = quest_evacuation and player.dimension or 0
    element.interior = 0

    local offset = ( VEHICLE_CONFIG[ element.model ] and VEHICLE_CONFIG[ element.model ].is_moto ) and 0.3 or 0.8
    element.position = player.position + Vector3( offx, offy, offset )

    element.turnVelocity = Vector3( 0, 0, 0 )
    element.velocity = Vector3( 0, 0, 0 )
    element.rotation = Vector3( 0, 0, rotation )

    local prev_health = element.health
    if element.blown then fixVehicle( element ) end
    element.health = math.max( prev_health, VEHICLE_HEALTH_CRASHED )

    element.velocity = Vector3( 0, 0, 0.005 )

    triggerClientEvent( player, "ShowPhoneUI", resourceRoot, false )

    if quest_evacuation then
        element:setData( "at_is_teleported", true, false )
    end

    triggerEvent( "onPlayerEvacuateVehicle", player, element, price )
    triggerClientEvent( player, "onClientResetVehicleLastPosition", root, element )
end
addEvent( "onTowtruckRequest", true )
addEventHandler( "onTowtruckRequest", root, onTowtruckRequest_handler )

local TOWTRUCK_PRICES = {
    [ 468 ] = 250,

    default = 3000,
}

function GetEvacuationPrice( player, vehicle, distance )
    -- START: Тест экономики
    if vehicle.model == 468 and player:getData( "economy_test" ) then
        return 150
    end
    -- END: Тест экономики

    return TOWTRUCK_PRICES[ vehicle.model ] or TOWTRUCK_PRICES.default
end