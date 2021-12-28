--[[
    Конвертация в валюту:
    +++ Бизнесы
    +++ Квартиры
    - Товары бизнесменов
    +++ Випдома
    +++ Телефонные номера
    +++ Лицензии таксиста частника
    - Заказ на голову
]]

--[[
    Перенос:
    +++ Софт
    +++ Хард
    +++ Синие монеты
    +++ Машины
    +++ Мотоциклы
    +++ Авиатехника
    +++ Права на транспорт
    +++ Скины
    +++ Инвентарь
    +++ Оружие с рук
    +++ Фоны телефона
    +++ Аксессуары
    +++ Анимации
    +++ Бустеры гонок
    +++ Бустеры КБ
    +++ Билеты в КБ
    +++ Никнейм
    +++ Премиум
    +++ Жетоны рулеток
    +++ Купленные кейсы
]]

-- Информация по бизнесам
function Player:GetOwnedBusinesses( )
    local currency = { soft = 0 }
    local logdata, info = { }, { }

    for i, v in pairs( exports.nrp_businesses:GetOwnedBusinesses( self ) ) do
        local cost = exports.nrp_businesses:GetBusinessConfig( v, "cost" ) or 0
        local balance = exports.nrp_businesses:GetBusinessData( v, "balance" ) or 0

        currency.soft = currency.soft + cost + balance

        table.insert( logdata, "Возврат бизнеса: " .. v .. ", стоимость бизнеса: " .. cost .. ", баланс: " .. balance )
        table.insert( info, { text = 'Бизнес "' .. exports.nrp_businesses:GetBusinessConfig( v, "name" ) .. '"', cost = cost, type = "soft" } )
        if balance > 0 then
            table.insert( info, { text = "+ Баланс бизнеса", cost = balance, type = "soft" } )
        end
    end

    return currency, logdata, info
end


function Player:GetOwnedTaxiLicenses( )
    local currency = { soft = 0, hard = 0 }
    local logdata, info = { }, { }

    for i, v in pairs( TAXI_LICENSES ) do
        local license = self:HasTaxiLicense( i )

        if license == TAXI_LICENSE_ENDLESS then
            local hard = TAXI_LICENSES[ i ][ 3 ]
            currency = table.add( currency, { hard = hard } )
            table.insert( logdata, "Возврат бесконечной лицензии таксиста: " .. i .. ", стоимость: " .. hard )
            table.insert( info, { text = "Лицензия таксиста, класс " .. VEHICLE_CLASSES_NAMES[ i ], cost = hard, type = "hard" } )

        elseif license ~= TAXI_LICENSE_NOT_PURCHASED then
            local soft = TAXI_LICENSES[ i ][ 2 ]
            currency = table.add( currency, { soft = soft } )
            table.insert( logdata, "Возврат временной лицензии таксиста: " .. i .. ", стоимость: " .. soft )
            table.insert( info, { text = "Лицензия таксиста, класс " .. VEHICLE_CLASSES_NAMES[ i ], cost = soft, type = "soft" } )

        end
    end

    return currency, logdata, info
end

function Player:GetOwnedApartments( )
    local currency = { soft = 0 }
    local logdata, info = { }, { }

    local viphouse_list = exports.nrp_vip_house:GetPlayerVipHouseList( self ) or {}
    if #viphouse_list > 0 then

        local function GetViphouseConfig( viphouse )
            for i, v in pairs( VIP_HOUSES_LIST ) do
                if v.hid == viphouse.hid then
                    return v
                end
            end
        end

        for i, viphouse in ipairs( viphouse_list ) do

            local config = GetViphouseConfig( viphouse )

            local cost = config.cost
            local days_cost = viphouse.paid_days * viphouse.daily_cost
            currency = table.add( currency, { soft = cost + days_cost } )
            table.insert( logdata, "Возврат випдома: " .. viphouse.hid .. ", стоимость: " .. cost .. ", оплачено на " .. viphouse.paid_days .. " д., стоимость: " .. days_cost )

            table.insert( info, { text = "Недвижимость", cost = cost, type = "soft" } )
            if viphouse.paid_days > 0 then
                table.insert( info, { text = "+ Оплата на " .. viphouse.paid_days .. " д.", cost = days_cost, type = "soft" } )
            end

            if config.services then
                for i, v in pairs( viphouse.purchased_services ) do
                    currency = table.add( currency, { soft = config.services[ i ].cost } )
                    table.insert( logdata, "Возврат снижения стоимости випдома: " .. viphouse.hid .. ", стоимость: " .. config.services[ i ].cost )

                    table.insert( info, { text = '+ ' .. config.services[ i ].name, cost = config.services[ i ].cost, type = "soft" } )
                end
            end
        end
    end

    local apartments_data_list = exports.nrp_apartment:GetPlayerApartmentsData( self ) or {}
    if #apartments_data_list > 0 then
        for i, apart_data in ipairs( apartments_data_list ) do
            local id, number, apartments_info, data = unpack( apart_data )
            local class = apartments_info.class
            local class_data = APARTMENTS_CLASSES[ class ]
            local cost = class_data.cost

            local days_cost = data.paid_days * class_data.cost_day
            currency = table.add( currency, { soft = cost + days_cost } )

            table.insert( logdata, "Возврат квартиры класса: " .. class .. ", стоимость: " .. cost .. ", оплачено на " .. data.paid_days .. " д., стоимость: " .. days_cost )

            table.insert( info, { text = "Недвижимость", cost = cost, type = "soft" } )
            if data.paid_days > 0 then
                table.insert( info, { text = "+ Оплата на " .. data.paid_days .. " д.", cost = days_cost, type = "soft" } )
            end

            if data.paid_upgrade > 0 then
                for i = 1, data.paid_upgrade do
                    local cost = class_data.upgrades[ i ].cost
                    currency = table.add( currency, { soft = cost } )
                    table.insert( logdata, "Возврат снижения стоимости квартиры: " .. class .. ", ур: " .. i .. ", стоимость: " .. cost )

                    table.insert( info, { text = '+ Услуга по снижению стоимости', cost = cost, type = "soft" } )
                end
            end
        end
    end

    return currency, logdata, info
end

function Player:GetOwnedPhoneNumber( )
    local currency = { soft = 0 }
    local logdata, info = { }, { }

    local numbers = exports.nrp_sim_shop
    local number_types = {
        unique   = { cost = 3000000, check = function( number ) return exports.nrp_sim_shop:IsPhoneNumberIsUnique( number ) end },
        premium  = { cost = 2500000, check = function( number ) return exports.nrp_sim_shop:IsPhoneNumberIsPremium( number ) end },
        luxury   = { cost = 1500000, check = function( number ) return exports.nrp_sim_shop:IsPhoneNumberIsLux( number ) end },
        standard = { cost = 1000000, check = function( number ) return exports.nrp_sim_shop:IsPhoneNumberIsStandard( number ) end },
        ordinary = { cost = 1000, check = function( number ) return exports.nrp_sim_shop:IsPhoneNumberIsOrdinary( number ) end },
    }

    local number = self:GetPhoneNumber( )

    if number then
        for i, v in pairs( number_types ) do
            if v.check( number ) then
                currency = table.add( currency, { soft = v.cost } )
                table.insert( logdata, "Номер телефона, категория: " .. i .. ", стоимость: " .. v.cost )

                table.insert( info, { text = "Телефонный номер " .. format_price( number ), cost = v.cost, type = "soft" } )
                break
            end
        end
    end

    return currency, logdata, info
end

function table.add( a, b )
    local n = { }
    for i, v in pairs( a ) do
        n[ i ] = v + ( b[ i ] or 0 )
    end
    return n
end

function table.merge( a, b )
    local n = { }
    for i, v in pairs( a ) do
        table.insert( n, v )
    end
    for i, v in pairs( b ) do
        table.insert( n, v )
    end
    return n
end