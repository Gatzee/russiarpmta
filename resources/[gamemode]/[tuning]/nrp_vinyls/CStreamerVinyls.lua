loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShVehicleConfig" )
Extend( "ib" )
Extend( "CVehicle" )
Extend( "CPlayer" )

MAX_VEHICLE_WITH_VINYLS = 40
VEHICLES_WITH_VINYLS = {}
TEXTURE_LIST = {}

function onClientElementStreamOut_handler( vehicle )
    local vehicle = vehicle or source
    if getElementType( vehicle ) ~= "vehicle" or not vehicle:DoesVehicleHaveVinyls() or isElementLocal( vehicle ) then
        return
    end
    
    for _, vehicle_data in pairs( VEHICLES_WITH_VINYLS ) do
        if vehicle_data[ 1 ] == vehicle then
            vehicle_data[ 2 ] = {} 
            break
        end
    end
end
addEventHandler( "onClientElementDestroy", root, onClientElementStreamOut_handler )
addEventHandler( "onClientElementStreamOut", root, onClientElementStreamOut_handler )

function onClientElementStreamIn_handler( vehicle )
    local vehicle = vehicle or source
    if getElementType( vehicle ) ~= "vehicle" or isElementLocal( vehicle ) then
        return
    end
    
    local vinyls_data = vehicle:getData( "vehicle_vinyl_data" )
    if vinyls_data and next( vinyls_data.vinyls ) then
        local c_veh_data = { vehicle, vinyls_data.vinyls, vinyls_data.color }

        local vehicle_exist = false
        for _, vehicle_data in pairs( VEHICLES_WITH_VINYLS ) do
            if vehicle_data[ 1 ] == vehicle then
                vehicle_data = c_veh_data
                vehicle_exist = true
                break
            end
        end

        if not vehicle_exist then
            table.insert( VEHICLES_WITH_VINYLS, c_veh_data )
        elseif vehicle:DoesVehicleHaveVinyls() then
            vehicle:ApplyVinyls( c_veh_data[ 2 ], c_veh_data[ 3 ] )
        end
    elseif vehicle:DoesVehicleHaveVinyls() then
        onClientElementStreamOut_handler( vehicle )
    end
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientElementDataChange_handler( key, old_value, new_value )
    if key ~= "vehicle_vinyl_data" then return end
    if isElementStreamedIn( source ) then
        onClientElementStreamIn_handler( source )
    end
end
addEventHandler( "onClientElementDataChange", root, onClientElementDataChange_handler )

setTimer( function()
    if not next( VEHICLES_WITH_VINYLS ) then return end

    -- Сортируем авто по удаленности от игрока
    table.sort( VEHICLES_WITH_VINYLS, function( a, b ) 
        if not a or not isElement( a[ 1 ] ) then
            return false
        elseif a and isElement( a[ 1 ] ) and ( not b or not isElement( b[ 1 ] ) ) then
            return true
        elseif a and isElement( a[ 1 ] ) and b and isElement( b[ 1 ] ) then
            if a[ 1 ]:IsOwnedBy( localPlayer, true ) and not b[ 1 ]:IsOwnedBy( localPlayer, true )  then
                return true
            elseif b[ 1 ]:IsOwnedBy( localPlayer, true ) and not a[ 1 ]:IsOwnedBy( localPlayer, true ) then
                return false
            else
                return (localPlayer.position - a[ 1 ].position).length < (localPlayer.position - b[ 1 ].position).length
            end
        end
        return false
    end )

    local count = 0
    local loaded_vehicles = { }
    for i = 1, math.min( #VEHICLES_WITH_VINYLS, MAX_VEHICLE_WITH_VINYLS ) do
        if not VEHICLES_WITH_VINYLS[ i ] then break end
        local vehicle = VEHICLES_WITH_VINYLS[ i ][ 1 ] 
        if isElement( vehicle ) then
            -- Отмечаем что машина еще нужна
            loaded_vehicles[ vehicle ] = true
            count = count + 1
            -- Пытаемся подгрузить если не подгружена
            local vinyls_data = vehicle:getData( "vehicle_vinyl_data" )
            if not vehicle:DoesVehicleHaveVinyls() and vinyls_data then
                vehicle:ApplyVinyls( vinyls_data.vinyls, vinyls_data.color )
            elseif not next( VEHICLES_WITH_VINYLS[ i ][ 2 ] ) then
                loaded_vehicles[ vehicle ] = false
                VEHICLES_WITH_VINYLS[ i ] = nil
            end
        else
            loaded_vehicles[ vehicle ] = false
            VEHICLES_WITH_VINYLS[ i ] = nil
        end
    end

    
    -- Если есть список прошлых машин
    if PREVIOUS_LOADED_VEHICLES then
        -- Ищем те, которым не нужно подгружать винилы в этот раз -> можно их выгружать
        for i, v in pairs( PREVIOUS_LOADED_VEHICLES ) do
            if not loaded_vehicles[ i ] and isElement( i ) then
                i:ResetVinyls()
            end
        end
    end
    PREVIOUS_LOADED_VEHICLES = loaded_vehicles

end, 1000, 0 )


addEventHandler( "onClientRestore", root, function( didClearRenderTargets  )
    if not didClearRenderTargets then return end
    for k, v in pairs( VEHICLES_WITH_VINYLS ) do
        v[ 1 ]:ResetVinyls()
    end
end )

addEventHandler( "onClientResourceStop", resourceRoot, function()
    for k, v in pairs( getElementsByType( "vehicle" ) ) do
        if v:DoesVehicleHaveVinyls() then
            v:ResetVinyls()
        end
    end
end )

function onSettingsChange_handler( changed, values )
    if changed.count_show_vinyls then
        MAX_VEHICLE_WITH_VINYLS = values.count_show_vinyls
    elseif changed.quality_show_vinyls and MAX_VINYL_SIZE ~= values.quality_show_vinyls then
        MAX_VINYL_SIZE = values.quality_show_vinyls
        for k, v in pairs( VEHICLES_WITH_VINYLS ) do
            v[ 1 ]:ResetVinyls()
            local vinyls_data = v[ 1 ]:getData( "vehicle_vinyl_data" )
            if vinyls_data then
                v[ 1 ]:ApplyVinyls( vinyls_data.vinyls, vinyls_data.color )
            end
        end
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )