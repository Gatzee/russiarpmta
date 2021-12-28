loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SVehicle" )

function onServerApplyVinylSetting_handler( vinyl_list  )
    if not isElement( client ) then return end
    
    local vehicle = client.vehicle
    if vehicle ~= client:getData( "tuning_vehicle" ) and client:getData( "tuning_vehicle" ) or not isElement( vehicle ) then
        WriteLog( "tuning_gandon", "%s попытался перенести винил на другую машину %s вместо %s", client, vehicle or "НЕТ МАШИНЫ", client:getData( "tuning_vehicle" ) or "ИГНОРИРУЙТЕ" )
        return false
	end

    local exist_vinyl_list = vehicle:GetVinyls( vehicle:GetTier() )
    for _, vinyl in pairs( vinyl_list ) do
        local vinyl_find = false
        
        for _, exist_vinyl in pairs( exist_vinyl_list ) do
            if vinyl[ P_NAME ] == exist_vinyl[ P_NAME ] then
                vinyl_find = true
                break
            end
        end

        if not vinyl_find then 
            WriteLog( "tuning_gandon", "%s попытался установить несуществующий винил на машину %s", client, vehicle or "НЕТ МАШИНЫ" )
            return false
        end
    end

    vehicle:SetVinyls( vinyl_list )
    client:RefreshInstalledVinyls()
end
addEvent( "onServerApplyVinylSetting", true )
addEventHandler( "onServerApplyVinylSetting", resourceRoot, onServerApplyVinylSetting_handler )

function onServerCompleteApplyVinyls_hander( vinyl_list, player )
    local player = player or client
    
    local vehicle = player.vehicle 
    if not vehicle or not isElement( vehicle ) then
        return false
    end
    
    if next( vinyl_list ) then
        setElementData( vehicle, "vehicle_vinyl_data", { vinyls = vinyl_list, color = { vehicle:getColor( true ) } } )
    elseif getElementData( vehicle, "vehicle_vinyl_data" ) ~= nil then 
        removeElementData( vehicle, "vehicle_vinyl_data" )
    end
end
addEvent( "onServerCompleteApplyVinyls", true )
addEventHandler( "onServerCompleteApplyVinyls", resourceRoot, onServerCompleteApplyVinyls_hander )