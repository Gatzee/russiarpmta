loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

function onVehiclePreLoad_handler( data )
    local vehicle = source

    -- Если нет владельца, не восстанавливаем деньги
    local player = GetPlayer( vehicle:GetOwnerID(), true )
    if not isElement( player ) then return end

    if vehicle:GetPermanentData( "converted" ) then return end

    -- Нужно разделять внутренний и внешний тюнинг.
    -- За внутренний выдавать бабло, внешний конвертить в новый формат и сохранять его

    -- Конвертация цвета фар
    local color = data.color
    if type( color ) == "table" then
        local r, g, b = color[ 4 ], color[ 5 ], color[ 6 ]
        if r and g and b then
            vehicle:SetHeadlightsColor( r, g, b )
            
            color[ 4 ], color[ 5 ], color[ 6 ] = nil, nil, nil
            vehicle:SetPermanentData( "color", color )
        end
    end

    -- Разбор старого тюнинга
    local tuning = data.tuning or { }

    local internal_tuning = { }
    local external_tuning = { }

    for i, v in pairs( tuning ) do
        local is_external = TUNING_IDS[ i ] or TUNING_IDS_REVERSE[ i ]
        table.insert( is_external and external_tuning or internal_tuning, { i, v } )
    end

    if #internal_tuning > 0 or #external_tuning > 0 then
        local price = CalculateInternalPricing( vehicle, internal_tuning )

        -- Конвертация внешнего тюнинга
        local converted_external_tuning = { }

        for i, conf in pairs( external_tuning ) do
            local component, component_value = unpack( conf )

            -- Конвертация компонента и поиск текущего уровня
            local component_id = tonumber( component ) and component or TUNING_IDS[ component ]
            local component_key = TUNING_IDS_REVERSE[ component_id ]
            local component = TUNING_IDS[ component_key ]

            local component_level = GetComponentLevel( vehicle, component, component_value )

            -- Обработка только существующих компонентов
            if component_id and component_level then
                converted_external_tuning[ component_id ] = component_level
            end
        end

        -- После успешной конвертации всех данных, вычищаем и ставим новые
        if price then
            local result = player:GiveMoney( price )
            if result then
                vehicle:SetPermanentData( "tuning", { } )
            end
            --iprint( player, "получил компенсацию", price, "за машину", vehicle, vehicle:GetID( ) )
        end

        -- Устанавливаем значение после конвертации, ждем реакции обработчика машин на новые данные
        vehicle:SetPermanentData( "tuning_external", converted_external_tuning )

        vehicle:SetPermanentData( "converted", true )
    end

end
addEvent( "onVehiclePreLoad", true )
addEventHandler( "onVehiclePreLoad", root, onVehiclePreLoad_handler )

function CalculateInternalPricing( vehicle, list )
    local total_price = 0

    -- Константные цены на всякого рода говнотюнинг
    local cost_from_vehicle = {
        --[ "Hydraulics" ] = 0.3,
        [ "Lights" ] = 0.1,
    }

    local custom_parsing = {
        [ "Hydraulics" ] = function( vehicle, value )
            local value = tonumber( value )
            if value and value > 0 then
                vehicle:SetHydraulics( value )
            end
        end,
        [ "Wheels" ] = function( vehicle, value )
            local value = tonumber( value )
            if value and value > 0 then
                vehicle:SetWheels( value )
            end
        end,
    }

    for i, conf in pairs( list ) do
        local component, component_value = unpack( conf )

        -- Если это компонентный тюнинг
		if TUNING_IDS[ component ] then
            local price = CalculateComponentPrice( vehicle, component, component_value )
            if price then total_price = total_price + price end

        -- Кастомная конвертация
        elseif custom_parsing[ component ] then
            local fn = custom_parsing[ component ]
            fn( vehicle, component_value )

        -- Если это иной тюнинг по отношению к цене машины
        elseif cost_from_vehicle[ component ] then
            local percent = cost_from_vehicle[ component ]
            local price = math.floor( vehicle:GetPrice() * percent )

            total_price = total_price + price

        -- Если это внутренний тюнинг, считающийся по формуле
        elseif TUNING_PARAMS[ component ] then
            local price = CalculateInternalComponentPrice( vehicle, component, component_value )
            if price then total_price = total_price + price end
        end

	end

    return total_price
end

function CalculateComponentPrice( vehicle, component, component_value )
    local component_tuning = GetVehicleComponentData( vehicle, component )
    if not component_tuning then return end

    for i, v in pairs( component_tuning ) do
        if v.component == component_value then
            return v.cost
        end
    end
end

function GetComponentLevel( vehicle, component, component_value )
    local component_tuning = GetVehicleComponentData( vehicle, component )
    if not component_tuning then return end

    for i, v in pairs( component_tuning ) do
        if v.component == component_value or i == component_value then
            return i
        end
    end
end

function CalculateInternalComponentPrice( vehicle, component, component_value )
    local component_tuning = TUNING_PARAMS[ component ]
    if not component_tuning then return end

    for i, v in pairs( component_tuning ) do
        if v.Level == component_value then
            return vehicle:CalcComponentPrice( vehicle:GetVariant(), v.Percent, v.Price, v.Markup ) or 0
        end
    end
end

function GetVehicleComponentData( vehicle, component )
    local config = VEHICLE_CONFIG[ vehicle.model ]
    if not config then return end

    local custom_tuning = config.custom_tuning
    if not custom_tuning then return end

    return custom_tuning[ component ] or custom_tuning[ TUNING_IDS_REVERSE[ component ] ]
end

Vehicle.CalcComponentPrice = function(self, variant, iPercent, iPrice, fMarkup )
	local data = VEHICLE_CONFIG[self.model]
	if not data then
		outputDebugString( "Модели " .. tostring( self.model ) .. " нет в базе", 2 )
		return false
	end

	local variant = variant or self:GetVariant() or 1

	local variantData = data.variants[ variant ]
	if not variantData then
		outputDebugString( "Варианта " .. tostring( variant ) .. " для " .. tostring( self.model ) .. " нет в базе", 2 )
		return false
	end

	local sMark	= data.mark
	local iMarkCost
	if sMark and VEHICLE_CONFIG_MARKS[sMark] then
		iMarkCost = VEHICLE_CONFIG_MARKS[sMark].percent
	else
		iMarkCost = VEHICLE_CONFIG_MARKS.Default.percent
	end
	local iCarPrice = variantData.cost
	local iSum = (iCarPrice * (iPercent or 0))/100 * iMarkCost

	return iSum * (fMarkup or 0) + (iPrice or 0)
end
