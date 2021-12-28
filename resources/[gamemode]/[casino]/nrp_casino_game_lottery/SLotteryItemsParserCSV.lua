if SERVER_NUMBER < 100 or SERVER_NUMBER > 200 then
    CalculateLotteryItemChances( )
    return
end

Extend( "csv" )

function ParseCaseDataFromCSV( file_name, file_path )
    local file = fileOpen( file_path )
    local data = fileRead( file, fileGetSize( file ) )
    fileClose( file )

    local csv_reader = csv.openstring( data , { separator = ",", header =false } )
    local csv_table = { }
    for fields in csv_reader:lines() do
        table.insert( csv_table, fields )
    end

    local lottery_id = file_name
    local variants = { }
    local progression_prizes = {}
    local chance_coef = { 1, 2, 2.5, 3, 3.5 }

    local case_data
    local case_id
    local case_cost
    local new_case_info

    local vehicle_tuning
    for col = 11, 15 do
        if not csv_table[ 2 ][ col ] then
            break
        end
        if utf8.find( csv_table[ 2 ][ col ], "тюнинг" ) then
            vehicle_tuning = loadstring( "return " .. csv_table[ 3 ][ col ] )( )
            if type( vehicle_tuning ) ~= "table" then
                error( file_name .. ": криво прописан тюнинг" )
            end
        end
    end

    local function ParseDataFromCSVLine( line_i, progression_season_type )
        local required_fields = { "name", "type", "cost", }
        local prize_id, rareness, id, anal_name, cost, chance_correction, name, Type 
        if progression_season_type then
            prize_id, id, anal_name, cost, name, Type = unpack( csv_table[ line_i ] )
        else
            rareness, id, anal_name, cost, chance_correction, name, Type = unpack( csv_table[ line_i ] )
            for k, v in pairs( { "rare" } ) do
                table.insert( required_fields, v )
            end
        end

        if not progression_season_type and rareness == "" and id == "Постоянные предметы" then
            return
        end

        if not progression_season_type and rareness == "" and id == "" then
            return "break"
        end

        cost = cost:gsub( "[^%d]+", "" )
        cost = tonumber( cost )

        local name_ingame = name
        name = utf8.lower( name )

        TYPE_CONVERSION = {
            [ "car" ] = "vehicle",
            [ "vehicle" ] = "vehicle",
            [ "soft" ] = "soft",
            [ "exp" ] = "exp",
            [ "money" ] = "soft",
            [ "skin" ] = "skin",
            [ "acces" ] = "accessory",
            [ "accessory" ] = "accessory",
            [ "anim" ] = "dance",
            [ "weapon" ] = "weapon",
            [ "ammo" ] = "weapon",
            [ "vinyl" ] = "vinyl",
            [ "vynil" ] = "vinyl",
            [ "neon" ] = "neon",
            -- [ "Other" ] = PART_T5, -- и жетон, и прем, и ещё какая-то залупа
            -- [ "wof" ] = PART_T5, -- жетон
        }
        
        local item_type = TYPE_CONVERSION[ Type and Type:lower( ) ]
        local func_cor_item_lottery = function()
            chance_correction = chance_correction:gsub( "[^%d]+", "" )
            chance_correction = tonumber( chance_correction )

            return {
                name = anal_name:lower( ):gsub( " ", "_" ),
                type = item_type,
                cost = tonumber( cost ),
                chance_cost = chance_correction ~= cost and chance_correction or nil,
                rare = tonumber( rareness ),
                params = { },
            }
        end

        local func_cor_item_progression_prize = function()
            return {
                name = anal_name:lower( ):gsub( " ", "_" ),
                type = item_type,
                cost = tonumber( cost ),
                params = { },
            }
        end

        
        local item = progression_season_type and func_cor_item_progression_prize() or func_cor_item_lottery()
        if progression_season_type then
            table.insert( new_case_info.items[ progression_season_type ], item )
        else
            table.insert( new_case_info.items, item )
        end

        if item.type then
            if item.type == "vehicle" then
                item.params.model = tonumber( id )
                if not VEHICLE_CONFIG[ item.params.model ] then
                    print( file_name, line_i, "no conf", name, "id", item.params.model )
                    return 
                end
                if VEHICLE_CONFIG[ item.params.model ].variants[ 2 ] then
                    if tonumber( number ) then
                        item.params.variant = tonumber( number )
                    else
                        print( file_name, line_i, "need variant", name, item.params.model )
                    end
                end
                if not progression_season_type and vehicle_tuning and (new_case_info and #new_case_info.items == 1) then
                    item.params.tuning = vehicle_tuning
                    item.params.color = LOTTERIES_INFO[ lottery_id ].analytics_name
                end
            elseif item.type == "skin" then
                item.params.model = tonumber( id )
            elseif item.type == "accessory" then
                item.params.id = id
            elseif item.type == "soft" then
                item.name = cost >= 1000000 and string.format( "%.3f_mln", cost / 1000000 ):gsub( "%.", "_" ):gsub( "0+_mln", "_mln" ):gsub( "__mln", "_mln" )
                                             or string.format( "%.3fk", cost / 1000 ):gsub( "%.", "_" ):gsub( "0+k", "k" ):gsub( "_k", "k" )
                item.params.count = tonumber( cost )
            elseif item.type == "exp" then
                item.name = cost >= 1000000 and string.format( "%.3f_mln", cost / 1000000 ):gsub( "%.", "_" ):gsub( "0+_mln", "_mln" ):gsub( "__mln", "_mln" )
                                             or string.format( "%.3fk", cost / 1000 ):gsub( "%.", "_" ):gsub( "0+k", "k" ):gsub( "_k", "k" )
                item.name = item.name .. "_exp"
                item.params.count = tonumber( cost )
            elseif item.type == "dance" then
                item.params.id = tonumber( id )
            elseif item.type == "weapon" then
                item.params.id = tonumber( id )
                item.params.ammo = tonumber( number ) or 30
            elseif item.type == "vinyl" then
                item.params.id = id
                if VINYL_NAMES[ id ] ~= name_ingame then
                    print( file_name, line_i, "id не совпадает с названием" )
                end
            elseif item.type == "neon" then
                item.params.id = tonumber( id:match( "neon_([%d]+)" ) )
            end
        else
            if utf8.find( name, "пакет" ) and utf8.find( name, "новичка" ) then
                item.type = "box"
                item.params = fromJSON( [[
                    {
                        "number": 1,
                        "items": {
                            "repairbox": {
                                "count": 2
                            },
                            "firstaid": {
                                "count": 2
                            },
                            "car_evac": {
                                "count": 2
                            },
                            "jailkeys": {
                                "count": 2
                            }
                        }
                    }
                ]] )

            elseif utf8.find( name, "пакет" ) and utf8.find( name, "старт" ) then
                item.type = "box"
                item.params = fromJSON( [[
                    {
                        "number": 2,
                        "items": {
                            "premium": {
                                "days": 1
                            },
                            "repairbox": {
                                "count": 2
                            },
                            "firstaid": {
                                "count": 2
                            },
                            "car_evac": {
                                "count": 2
                            },
                            "jailkeys": {
                                "count": 3
                            }
                        }
                    }
                ]] )

            elseif utf8.find( name, "жетон" ) then
                item.type = "wof_coin"
                item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] or 1 ) or 1
                item.params.type = utf8.find( name, "vip" ) and "gold" or "default"
                item.name = item.params.count .. "_wof_coin" .. ( utf8.find( name, "vip" ) and "_vip" or "" )

            elseif utf8.find( name, "тема в телефон" ) then
                item.type = "phone_img"
                item.params.id = id

            elseif utf8.find( name, "прем" ) then
                item.type = "premium"
                item.params.days = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
                item.name = "prem_" .. ( item.params.days or "" ) .."d"

            elseif utf8.find( name, "рем" ) and utf8.find( name, "комплект" ) then
                item.type = "repairbox"
                item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] or 1 ) or 1
                item.name = item.type

            elseif utf8.find( name, "кейс" ) then
                item.type = "case"
                item.params.name = name_ingame
                item.params.id = utf8.find( name, "бронз" )     and "bronze" 
                                 or utf8.find( name, "серебр" ) and "silver"
                item.name = "case_" .. ( item.params.id or "" )

            elseif utf8.find( id, "assembl_detail" ) then
                item.type = "assembl_detail"
                item.params.id = tonumber( ({ id:gsub( "[^%d]+", "" ) })[ 1 ] or 1 )
                item.name = id
            
            else
                print( file_name, "unknown", line_i, inspect( name ) )
            end
        end

        if item.type then
            local k, v = next( item.params )
            if not v then print( file_name, "no params", line_i, name ) end
        end

        for i, k in pairs( required_fields ) do
            if not item[ k ] or item[ k ] == "" then
                iprint( csv_table[ line_i ] )
                error( file_name .. ": no item." .. k .. ", line " .. line_i )
            end
        end
    end

    local progression_rewards_start_line = nil
    for k, v in pairs( csv_table ) do
        if v[ 1 ]:find( "Progression rewards" ) then
            progression_rewards_start_line = k
            break
        end
    end

    local line_i = 0
    local variant_end_index = progression_rewards_start_line or #csv_table
    for variant = 1, 5 do
        repeat
            line_i = line_i + 1
            case_data = csv_table[ line_i ]
        until( case_data[ 2 ] ~= "" and case_data[ 8 ]  ~= "" )

        case_id = case_data[ 2 ]:lower( ):gsub( " ", "_" )
        case_cost = case_data[ 8 ]:gsub( "[\.,]00$", "" ):gsub( "[^%d]+", "" )
        case_cost = tonumber( case_cost )

        new_case_info = { }
        table.insert( variants, new_case_info )

        new_case_info.name = case_id
        new_case_info.cost = LOTTERIES_INFO[ file_name ].cost_is_hard and case_cost / 1000 or case_cost
        new_case_info.chance_coef = chance_coef[ #variants ]
        new_case_info.items = { }

        for i = line_i + 2, variant_end_index do
            if ParseDataFromCSVLine( i ) == "break" then
                line_i = i
                break
            end
        end
    end
    
    if progression_rewards_start_line then
        for i = progression_rewards_start_line + 2, #csv_table, 13 do
            new_case_info = {
                items = {
                    Common = {},
                    Premium = {},
                },
            }

            if csv_table[ i ][ 1 ] ~= "" and csv_table[ i ][ 2 ] ~= "" then
                new_case_info.start_ts = getTimestampFromString( csv_table[ i ][ 1 ] )
                new_case_info.end_ts = getTimestampFromString( csv_table[ i ][ 2 ] )
            end

            for j = i + 2, i + 6 do
                ParseDataFromCSVLine( j, "Common" )
                ParseDataFromCSVLine( j + 6, "Premium" )
            end
            table.insert( progression_prizes, new_case_info )
        end
    end
    
    return variants, progression_prizes
end

---------------------------------------------------------------


addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        local lotteries_to_parse = { 
            --"classic",
            --"gold",
            --"theme_20",
            --"theme_23",
            --"theme_24",
            --"theme_25",
            --"theme_26",
            --"theme_27",
            --"theme_28",
        }
        if #lotteries_to_parse > 0 then
            local file_path = "ShLotteryItems_new.lua" 
            local file = fileExists( file_path ) and fileOpen( file_path ) or fileCreate( file_path )
            fileFlush( file )

            for i, lottery_id in pairs( lotteries_to_parse ) do
                local lottery_info = LOTTERIES_INFO[ lottery_id ]
                if fileExists( "csv/" .. lottery_id .. ".csv" ) then
                    lottery_info.variants, lottery_info.progression_prizes = ParseCaseDataFromCSV( lottery_id, "csv/" .. lottery_id .. ".csv" )
                end

                fileWrite( file, "LOTTERIES_INFO." .. lottery_id .. ".variants = {\n" )
                for vari, data in pairs( lottery_info.variants or { } ) do
                    fileWrite( file, "    " .. inspect( data, { newline = '\n    ', indent = "    " } ) .. ",\n" )
                end

                fileWrite( file, "}\n\n" )

                if next( lottery_info.progression_prizes ) then
                    fileWrite( file, "\nLOTTERIES_INFO." .. lottery_id .. ".progression_prizes = {\n" )
                    for vari, data in pairs( lottery_info.progression_prizes ) do
                        fileWrite( file, "    " .. inspect( data, { newline = '\n    ', indent = "    " } ) .. ",\n" )
                    end
                    fileWrite( file, "}\n" )
                end
            end

            fileClose( file )

            print"SUCCES"
        end

        CalculateLotteryItemChances( )
    end, 1000, 1 )
end ) 