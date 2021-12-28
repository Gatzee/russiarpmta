Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "ShBusiness" )
Extend( "SDB" )

local specialVehiclesClasses = {
    ["airplane"] = "Самолёт",
    ["helicopter"] = "Вертолёт",
    ["boat"] = "Лодка",
};

function onPlayerGovsellListRequest_handler( special_types, update_only, player )
    local player = isElement( player ) and player or client

    if player:GetLevel( ) < 2 then
        client:ErrorWindow( "Продавать транспорт можно только со 2-го уровня" )
        return
    end

    local list = GenerateVehiclesList( player, special_types )

    if #list <= 0 and not update_only then
        player:ErrorWindow( "У тебя нет транспорта на продажу!" )
        return
    else
        triggerClientEvent( player, "ShowGovsell", resourceRoot, list, update_only )
    end
end
addEvent( "onPlayerGovsellListRequest", true )
addEventHandler( "onPlayerGovsellListRequest", root, onPlayerGovsellListRequest_handler )

function GetVehicleConf( vehicle, client )
    local conf = { }

    conf.model = vehicle.model
    conf.id    = vehicle:GetID( )
    conf.variant = vehicle:GetVariant( )
    conf.cost = vehicle:GetPermanentData( "showroom_cost" )
    if not conf.cost then
        conf.cost = VEHICLE_CONFIG[ vehicle.model ].variants[ conf.variant ] and VEHICLE_CONFIG[ vehicle.model ].variants[ conf.variant ].cost or VEHICLE_CONFIG[ vehicle.model ].variants[ 1 ].cost
    end
    conf.cost = math.floor ( conf.cost / 2 + 0.5 )
    conf.color = vehicle:GetColor()
    conf.class = VEHICLE_CLASSES_NAMES[ vehicle:GetTier( ) ]

    -- Комплектация
    if conf.variant == 1 then conf.variant = nil end

    --[[ local is_tradable, time_left = vehicle:IsTradeAvailable( )  -- Ограничение на продажу 48ч
    if not is_tradable then conf.trade_time_left = math.ceil( time_left / 60 / 60 ) end]]

    -- Нельзя продавать
    local temp_timeout = vehicle:GetPermanentData( "temp_timeout" ) or 0
    conf.is_untradable = vehicle:GetPermanentData( "govuntradable" ) or temp_timeout > 0 or conf.id < 0

    -- Не владелец
    conf.is_not_owned = not client:OwnsVehicle( vehicle )

    -- В такси и на смене
    conf.is_on_taxi = client:GetJobClass( ) == JOB_CLASS_TAXI_PRIVATE and client:GetOnShift( )

    -- Нужно ли подтверждение сброса инвентаря
    conf.is_inventory_empty = not next( vehicle:GetPermanentData( "inventory_data" ) or {} )

    return conf
end

function GetSpecVehicleConf( vehicle, client )
    local conf = { }

    conf.model         = vehicle.model
    conf.id            = vehicle.id
    conf.cost          = math.floor ( VEHICLE_CONFIG[ vehicle.model ].variants[ 1 ].cost / 2 + 0.5 )
    conf.is_untradable = conf.id < 0
    conf.color = { 200, 200, 200 }
    conf.class = specialVehiclesClasses[VEHICLE_CONFIG[ vehicle.model ].special_type] or "НЕТ" 
    return conf
end

function GenerateVehiclesList( client, special_types )
    local list = { }

    if not special_types then
        local vehicles = client:GetVehicles( _, true )
        for i, vehicle in pairs( vehicles ) do
            local conf = GetVehicleConf( vehicle, client )
            if conf then table.insert( list, conf ) end
        end
    else
        local vehicles = client:GetSpecialVehicles( )
        for i, v in pairs( vehicles ) do
            --iprint( "Spec", i, v )
            if special_types[ IsSpecialVehicle( v[ 2 ] ) ] then
                local conf = GetSpecVehicleConf( { id = v[ 1 ], model = v[ 2 ] }, client )
                table.insert( list, conf )
            end
        end
    end

    return list
end

function onVehicleSellRequest_handler( data, special_types )
    local vehicle = GetVehicle( data.id )

    if not vehicle and not special_types then
        client:ErrorWindow( "Транспорта больше не существует" )
        return
    end

    local conf = special_types and GetSpecVehicleConf( data, client ) or GetVehicleConf( vehicle, client )
    if conf.is_untradable then
        client:ErrorWindow( ERR_UNTRADABLE )
        return
    end

    if conf.is_not_owned then
        client:ErrorWindow( ERR_NOT_OWNED )
        return
    end

    if conf.is_on_taxi then
        client:ErrorWindow( ERR_IS_ON_TAXI )
        return
    end

    local vehicle_info = VEHICLE_CONFIG[ data.model ]
    if not vehicle_info then
        client:ErrorWindow( ERR_UNTRADABLE )
        return
	end

	local variant       = vehicle and vehicle:GetVariant( ) or 1
	local variant_info  = vehicle_info.variants[ variant ]
	local variant_name  = variant_info.mod
	local vehicle_name  = vehicle_info.model .. " (" .. variant_name .. ")"
	local vehicle_model = data.model
	local cost          = math.floor( ( vehicle and vehicle:GetPermanentData( "showroom_cost" ) or ( VEHICLE_CONFIG[ vehicle_model ].variants[ variant ] or VEHICLE_CONFIG[ vehicle_model ].variants[ 1 ] ).cost or 0 ) / 2 + 0.5 )
	local vehicle_id    = data.id

	WriteLog( "money/special", "[Car:ГосПродажа] %s продал машину %s (VEH:%s) за %s государству", client, vehicle_name, vehicle_id, cost )
    local client = client

    local function GiveSoldMoney( )
        if special_types then
            client:RemoveSpecialVehicleFromList( vehicle_id )
        else
            client:RemoveVehicleFromList( vehicle )
        end
        client:GiveMoney( cost, "govsell", vehicle_model )
        client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy_product.wav" )

        iprint( "GOVSELL!" )

        onPlayerGovsellListRequest_handler( special_types, true, client )

        client:InfoWindow( "Ты успешно продал " .. GetVehicleNameFromModel( vehicle_model ) .. "\nза "..format_price( cost ).." р." )
        triggerEvent( "CheckPlayerVehiclesSlots", client )

        local special_type = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].special_type or "car"
        triggerEvent( "onPlayerSellVehicleToGovernment", client, vehicle, cost, GetVehicleNameFromModel( vehicle_model ), special_type, vehicle_model )
    end

    if not GetVehicle( vehicle_id ) then
        -- Если машина не существует в игре, пытаемся удалить ее в базе и защититься от перепродажи
        DB:queryAsync( function( query, player, player_id )
            if not isElement( player ) then dbFree( query ) return end
            local result = query:poll( -1 )
            local vehicle_data = result[ 1 ]

            if vehicle_data.owner_pid ~= "p:" .. player_id then
                player:ErrorWindow( "Ошибка продажи" )
                return
            end

            if ( vehicle_data.deleted or 0 ) <= 0 then
                GiveSoldMoney( )
                DB:exec( "UPDATE nrp_vehicles SET deleted=?, owner_pid=? WHERE id=? LIMIT 1", getRealTime( ).timestamp, -player_id, vehicle_id )
            else
                player:ErrorWindow( "Машина уже удалена!" )
            end

        end, { client, client:GetID( ) }, "SELECT id, owner_pid, deleted FROM nrp_vehicles WHERE id=?", vehicle_id )
    else
        GiveSoldMoney( )
        exports.nrp_vehicle:DestroyForever( vehicle_id )
    end
end
addEvent( "onVehicleSellRequest", true )
addEventHandler( "onVehicleSellRequest", root, onVehicleSellRequest_handler )