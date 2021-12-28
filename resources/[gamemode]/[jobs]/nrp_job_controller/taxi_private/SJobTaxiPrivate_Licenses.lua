function Player.RefreshLicenses( self )
    triggerClientEvent( self, "onClientPrivateTaxiSetLicenses", resourceRoot, self:GetTaxiLicensesInfo( ) )
end

function onServerTaxiPrivateBuyLicense_handler( license, duration )
    if not client:HasLicense( LICENSE_TYPE_AUTO ) then
        client:ErrorWindow( "Требуются права категории \"B\"" )
        return false
    end

    local current_license_state = client:HasTaxiLicense( license )
    if client:HasTaxiLicense( license ) == TAXI_LICENSE_ENDLESS then
        client:ErrorWindow( "Ты уже приобрел бессрочную лицензию на развозку!" )
        return
    end

    if #GetVehicleIDsByTier( client:GetAvailableVehicleIDs( ), license ) <= 0 then
        client:ErrorWindow( "Ты не можете купить данную лицензию.\nУ тебя нет автомобиля нужного класса." )
        return
    end

    local tbl_costs = TAXI_LICENSES[ license ]

    if TAXI_LICENSES_DURATIONS[ duration ] == TAXI_LICENSE_ENDLESS then
        local cost = tbl_costs[ 3 ]
        if not client:HasDonate( cost ) then
            triggerClientEvent( client, "onShopNotEnoughHard", client, "private taxi license", "onPlayerRequestDonateMenu", "donate" )
            return
        end
        client:TakeDonate( cost, "taxi_license_purchase", license )

        client:SetTaxiLicense( license, TAXI_LICENSE_ENDLESS )
        client:InfoWindow( "Бессрочная лицензия успешно приобретена!" )

        -- Аналитика покупки за хард
        local license_readable_name = "Класс " .. VEHICLE_CLASSES_NAMES[ license ] .. " - Навсегда"
        triggerEvent( "onJobLicensePurchase", client, JOB_CLASS_TAXI_PRIVATE, license_readable_name, cost, true )
    else
        local cost = tbl_costs[ duration ]
        if not client:HasMoney( cost ) then
            client:ErrorWindow( "Недостаточно средств для покупки лицензии!" )
            return
        end
        client:TakeMoney( cost, "taxi_license_purchase", license )

        local duration_converted = TAXI_LICENSES_DURATIONS[ duration ] * 24 * 60 * 60
        local current_timestamp = client:HasTaxiLicense( license )
        
        local timestamp = getRealTimestamp()
        local is_prolonging = current_timestamp >= timestamp

        -- ставим новую длительность или добавляем к текущей на продление
        client:SetTaxiLicense( license,  not is_prolonging and ( getRealTimestamp() + duration_converted ) or current_timestamp + duration_converted )
        
        client:InfoWindow( is_prolonging and "Лицензия успешно продлена на " .. TAXI_LICENSES_DURATIONS[ duration ] .. "д. !" or "Лицензия успешно приобретена!" )

        -- Аналитика покупки за софт
        local license_readable_name = "Класс " .. VEHICLE_CLASSES_NAMES[ license ] .. " - " .. TAXI_LICENSES_DURATIONS[ duration ] .. " дней"
        triggerEvent( "onJobLicensePurchase", client, JOB_CLASS_TAXI_PRIVATE, license_readable_name, cost, false )
    end

    client:RefreshLicenses( )
end
addEvent( "onServerTaxiPrivateBuyLicense", true )
addEventHandler( "onServerTaxiPrivateBuyLicense", resourceRoot, onServerTaxiPrivateBuyLicense_handler )