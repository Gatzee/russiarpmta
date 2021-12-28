function ParseSpecialPackItems( pack_id )
    local file_path =  "csv/pack/" .. pack_id .. ".csv"
    if not fileExists( file_path ) then
        error( file_path .. " not exist" )
    end

    local file = fileOpen( file_path )
    local data = fileRead( file, fileGetSize( file ) )
    fileClose( file )

    local csv_reader = csv.openstring( data , { separator = ",", header =false } )
    local csv_table = { }
    for fields in csv_reader:lines() do
        table.insert( csv_table, fields )
    end

    local items = { }

    TYPE_CONVERSION = {
        [ "транспорт" ] = "vehicle",
        [ "скин" ] = "skin",
        -- [ "аксессуар" ] = "accessory",
        -- [ "номер" ] = "numberplate",
        -- [ "номера" ] = "numberplate",
        -- [ "винил" ] = "vinyl",
        -- [ "неон" ] = "neon",
        -- [ "пак" ] = "pack",
        -- [ "пак_лимит" ] = "pack_limit",
        [ "тюнинг кейс" ] = "tuning_case",
        [ "тюнинг-кейс" ] = "tuning_case",
    }
    TYPE_CONVERSION_REVERSE = { }
    for k,v in pairs( TYPE_CONVERSION ) do TYPE_CONVERSION_REVERSE[v] = true end

    VEHICLE_CLASSES_NAMES_REVERSE = { }
    for class, name in pairs( VEHICLE_CLASSES_NAMES ) do
        VEHICLE_CLASSES_NAMES_REVERSE[ name ] = class
    end

    local items_by_type = { }
    local csv_item_data_by_type = { }

    local function ParseItemData( line_i )
        local item_type, id, name, cost, cost_original, count, comment = unpack( csv_table[ line_i ] )

        local item_type = TYPE_CONVERSION_REVERSE[ item_type ] and item_type or TYPE_CONVERSION[ item_type ]
        id = tonumber( id )
        if not id and item_type ~= 'tuning_case' then
            iprint( csv_table[ line_i ] )
            error( file_path .. ":" .. line_i .. ": no id" )
        end

        cost = tonumber( cost:gsub( "[^%d]+", "" ), 10 )
        if not cost then
            iprint( csv_table[ line_i ] )
            error( file_path .. ":" .. line_i .. ": no cost" )
        end
        cost_original = tonumber( cost_original:gsub( "[^%d]+", "" ), 10 )

        local item = {
            [ "id"            ] = item_type    ,
            [ "cost"          ] = cost         ,
            [ "cost_original" ] = cost_original,
            [ "params"        ] = { }          ,
        }

        if item_type == 'vehicle' then
            item.params.model = id
        elseif item_type == 'skin' then
            item.params.model = id
        elseif item_type == 'tuning_case' then
            item.params.id = 3
            item.params.class = utf8.match( utf8.lower( name ), "класс (.)" ):upper( )
            if item.params.class == "с" then -- русская раскладка
                item.params.class = "C"
            end
            if item.params.class == "м" then -- русская раскладка
                item.params.class = "M"
            end
            if not VEHICLE_CLASSES_NAMES_REVERSE[ item.params.class ] then
                iprint( csv_table[ line_i ] )
                error( file_path .. ":" .. line_i .. ": failed to parse tuning_case class" )
            end
            item.params.subtype = _G[ "INTERNAL_PART_TYPE_" ..( utf8.match( comment, "type (.)" ) or ""):upper( ) ]
            if not item.params.subtype then
                iprint( csv_table[ line_i ] )
                error( file_path .. ":" .. line_i .. ": failed to parse tuning_case subtype" )
            end
            item.params.count = tonumber( count:gsub( "[^%d]+", "" ), 10 )
        end

        local items_order = {
            skin = 1,
            vehicle = 2,
            tuning_case = 3,
        }
        items[ items_order[ item_type ] ] = item

        items_by_type[ item_type ] = item
        csv_item_data_by_type[ item_type ] = csv_table[ line_i ]

        return item
    end

    local function ParseDataFromCSVLine( line_i )
        local item_type, id, name, cost, cost_original, count, comment = unpack( csv_table[ line_i ] )

        if TYPE_CONVERSION_REVERSE[ item_type ] or TYPE_CONVERSION[ item_type ] then
            ParseItemData( line_i )


        elseif item_type == "внешние настройки" and comment:sub( 1, 1 ) == "{" then
            if comment == "{" then
                local line_i = line_i
                while true do
                    line_i = line_i + 1
                    local item_type, id, name, cost, cost_original, count, _comment = unpack( csv_table[ line_i ] or { } )
                    if item_type == "" then
                        comment = comment .. "\n" .. _comment
                    else
                        break
                    end
                end
            end
            items_by_type.vehicle.params.tuning = loadstring( "return " .. comment )( )
            -- конверт старых названий полей, чтобы напрямую инсертить в бд
            for k, v in pairs( items_by_type.vehicle.params.tuning ) do
                if k == "vinyls" then
                    items_by_type.vehicle.params.tuning[ "installed_vinyls" ] = v
                    items_by_type.vehicle.params.tuning[ "vinyls" ] = nil
                elseif k == "neon" then
                    items_by_type.vehicle.params.tuning[ "neon_data" ] = v
                    items_by_type.vehicle.params.tuning[ "neon" ] = nil
                elseif k == "hydraulics" then
                    items_by_type.vehicle.params.tuning[ "hydraulics" ] = v and "yes" or nil
                end
            end

        elseif item_type == "характеристики ТС" and comment ~= "" and comment ~= "используем стандартные" then
            local veh_config = VEHICLE_CONFIG[ items_by_type[ "vehicle" ].params.model ]
            -- если вариант уже добавлен
            local item_type, id, name, cost, cost_original, count, _comment = unpack( csv_item_data_by_type[ "vehicle" ] )
            local last_variant_mod = veh_config.variants[ #veh_config.variants ].mod
            if last_variant_mod ~= "" and utf8.find( name, last_variant_mod ) then
                items_by_type.vehicle.params.variant = #veh_config.variants
                print( file_path .. ": проверить вариант", id, csv_item_data_by_type[ "vehicle" ].name, "найденный вариант ", #veh_config.variants, last_variant_mod )
            else
                items_by_type.vehicle.params.variant = #veh_config.variants + 1
                print( file_path .. ": нужно добавить новый вариант в ShVehicleConfig.lua для", id )
            end
        end
    end

    local analytics_name

    for line_i, fields in pairs( csv_table ) do
        if line_i == 1 then
            analytics_name = csv_table[ 1 ][ 2 ]
        elseif line_i > 2 then
            if ParseDataFromCSVLine( line_i, fields ) == "break" then
                break
            end
        end
    end
    
    return { items = items, analytics_name = analytics_name }
end