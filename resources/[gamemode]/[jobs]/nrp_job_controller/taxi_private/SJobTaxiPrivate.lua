
-- Автоувольнение при входе в игру, при завершении любой поездки
function CheckPlayerTaxiFire( )
    if source:GetJobClass() ~= JOB_CLASS_TAXI_PRIVATE then return end
        
    source:CheckFireFromTaxi( )
end
addEventHandler( "onPlayerCompleteLogin", root, CheckPlayerTaxiFire )
addEventHandler( "TaxiPrivateDaily_AddDelivery", root, CheckPlayerTaxiFire )

function Player.CheckFireFromTaxi( self, simulate )
    local should_fire = false

    if not self:HasAnyTaxiLicense( ) then
        should_fire = { "У тебя истекли все лицензии на работу Таксистом Частником и ты был уволен!", "ОПОВЕЩЕНИЕ ОБ УВОЛЬНЕНИИ", "Нет ни одной лицензии" }
    else
        local vehicle_id = self:GetSelectedTaxiVehicleID( )
        if vehicle_id then
            local vehicle = GetVehicle( vehicle_id )
            if not vehicle or vehicle:GetOwnerID( ) ~= self:GetUserID( ) then
                should_fire = { "Ты больше не являешься владельцем выбранной машины для работы Таксистом Частником!", "ОПОВЕЩЕНИЕ ОБ УВОЛЬНЕНИИ", "Подходящая машина не найдена" }
            end
        end
    end

    if should_fire then
        if self:GetShiftActive( ) then 
            self:EndShift( )
            triggerEvent( "PlayerFailStopQuest", self, { type = "quest_fail" } )
        end
        self:ErrorWindow( should_fire[ 1 ], should_fire[ 2 ] )
        return should_fire[ 3 ]
    end

    return false
end

function onTaxiPrivateEndShiftRequest_CustomReason_handler( reason )
    source:EndShift( )
    source:MissionFailed( reason )
end
addEvent( "onTaxiPrivateEndShiftRequest_CustomReason" )
addEventHandler( "onTaxiPrivateEndShiftRequest_CustomReason", root, onTaxiPrivateEndShiftRequest_CustomReason_handler )

function onTaxiPrivateEndShiftRequest_DriverExit_handler()
    local failed = false, false
    local fails = ( source:GetPermanentData( "txp_fails" ) or 0 ) + 1

    if fails >= 5 then
        source:SetPermanentData( "txp_fails", nil )
        source:SetPermanentData( "txp_locked", getRealTimestamp( ) )
        failed = true
    else
        source:SetPermanentData( "txp_fails", fails )
    end

    if failed then
        source:MissionFailed( "Ты покинул машину во время вызова!\nЗа частые срывы поездок ты отстранён на 1 неделю" )
    else
        source:MissionFailed( "Ты покинул машину во время вызова!\nЗа частые срывы поездок ты будешь отстранён на 1 неделю" )
    end
    
    source:EndShift( )
end
addEvent( "onTaxiPrivateEndShiftRequest_DriverExit" )
addEventHandler( "onTaxiPrivateEndShiftRequest_DriverExit", root, onTaxiPrivateEndShiftRequest_DriverExit_handler )


-- Обновление экономики в лайве
function UpdateTaxiEconomy( )
    local new_tbl, is_updated = { }, false
    for class, v in pairs( VEHICLE_CLASSES_NAMES ) do
        new_tbl[ class ] = exports.nrp_handler_economy:GetEconomyJobData( "taxi_private_" .. class )
        if not LAST_ECONOMY or new_tbl[ class ] ~= LAST_ECONOMY[ class ] then is_updated = true end
    end

    if is_updated then
        LAST_ECONOMY = new_tbl
        setElementData( root, "taxi_private_economy", new_tbl )
    end
end
UpdateTaxiEconomy( )
ECONOMY_UPDATE_TIMER = setTimer( UpdateTaxiEconomy, 10000, 0 )