loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShTimelib" )
Extend( "ShVehicleConfig" )

TIMEOUTS = { }

function onPlayerRequestTeleport_handler( data )
    do return end
    
    local function check( )
        if client:getData( "jailed" ) then
            return "Нельзя принять участие находясь в тюрьме"
        end

        if client.health < 50 or client:getData( "_healing" ) then
            return "Для начала подлечись на более, чем 50%"
        end

        if client:IsOnFactionDuty( ) then
            return "Ты на смене во фракции!"
        end

        if client:GetOnShift( ) then
            return "Закончи смену на работе!"
        end

        if client:IsOnUrgentMilitary( ) then
            return "Ты на срочной службе!"
        end

        if client:getData( "current_quest" ) then
            return "Закончи текущую задачу!"
        end

        if client:getData( "isWithinTuning" ) then
            return "Нельзя телепортироваться из тюнинга!"
        end

        if client:getData( "in_casino" ) then
            return "Нельзя телепортироваться из казино!"
        end

        if getCameraTarget( client ) ~= client then
            return "Нельзя телепортироваться!"
        end

        if client.dimension > 0 then
            return "Нельзя телепортироваться из интерьера!"
        end

        if client:getData( "in_race" ) then
            return "Нельзя телепортироваться из гонки!"
        end

        if client:getData( "is_hunting" ) then
            return "Нельзя телепортироваться из охоты!"
        end

        if client:getData( "is_handcuffed" ) then
            return "Ты в наручниках"
        end

        if client:getData( "current_event" ) then
            return "Ты на эвенте"
        end

        if client.dimension ~= 0 or client.interior ~= 0 then
            return "Ты не можешь телепортироваться отсюда!"
        end

        if client.vehicle then
            return "Ты не можешь телепортироваься на машине!"
        end

        if getCameraTarget( client ) ~= client then
            return "Нельзя телепортироваться отсюда!"
        end

        local vehicles = client:GetVehicles( )
        for i, v in pairs( vehicles ) do
            if v.model ~= 468 then
                return "У тебя уже есть транспорт, доберись на нем!"
            end
        end

        if TIMEOUTS[ client:GetUserID( ) ] then
            return "Ты уже телепортировался сегодня!"
        end

        return true
    end

    local availability = check( )
    if type( availability ) == "string" then
        client:ErrorWindow( availability )
        return
    end

    local point = Vector3( data.x, data.y, data.z )
    if data.range then
        point:AddRandomRange( data.range )
    end
    client.position = point

    setElementDimension( client, data.dimension or 0 )
    setElementInterior( client, data.interior or 0 )

    TIMEOUTS[ client:GetUserID( ) ] = true
end
addEvent( "onPlayerRequestTeleport", true )
addEventHandler( "onPlayerRequestTeleport", root, onPlayerRequestTeleport_handler )

function CleanTimeouts( )
    TIMEOUTS = { }
    CLEAN_TIMER = setTimer( CleanTimeouts, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "02:00", CleanTimeouts )