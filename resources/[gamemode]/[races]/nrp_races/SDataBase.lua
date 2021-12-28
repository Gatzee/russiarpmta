
RECORDS_CACHE = {}

RECORDS_DATA = {}
COUNT_LEADER_BOARD_ROWS = 10

function LoadRecordsData()
    RECORDS_CACHE = {}
    
    DB:queryAsync( function( qh )
        local result = dbPoll( qh, -1 )
        if type( result ) ~= "table" then return end
        
        for k, v in pairs( result ) do
            if utf8.sub( v.nickname, 1, 1 ) ~= "-" then
                table.insert( RECORDS_CACHE, CreateRecordModel( v ) )
            end
        end
        RefreshRecordsData()
    end, {}, 
        [[SELECT V.id, V.model, V.variant, V.race_circle_count, V.race_circle_points, V.race_drift_count, V.race_drift_points, V.race_drag_count, V.race_drag_points, P.client_id, P.nickname, P.clan_id
        FROM nrp_vehicles AS V
        LEFT JOIN nrp_players AS P
        ON V.owner_pid = CONCAT( "p:",P.id )
        WHERE P.client_id IS NOT NULL AND (V.race_circle_count > 0 OR V.race_drift_count > 0 OR V.race_drag_count > 0)]] )
end

function SetNewPointsValue( player, vehicle, race_type, value )
    local client_id = player:GetClientID()
    local vehicle_variant = vehicle:GetVariant()

    local race_points_id = "race_" .. RACE_TYPES_DATA[ race_type ].type .. "_points"
    local race_count_id  = "race_" .. RACE_TYPES_DATA[ race_type ].type .. "_count"
    
    local row_records = GetVehicleDataRow( client_id, vehicle.model, vehicle_variant )
    if row_records then
        local result_compare = CompareRaceRecord( race_type, value, RECORDS_CACHE[ row_records ][ race_points_id ] )
        local is_circle_zero = race_type == RACE_TYPE_CIRCLE_TIME and RECORDS_CACHE[ row_records ][ race_points_id ] == 0
        if result_compare or is_circle_zero then
            RECORDS_CACHE[ row_records ][ race_points_id ] = value
            RECORDS_CACHE[ row_records ][ race_count_id ] = RECORDS_CACHE[ row_records ][ race_count_id ] + 1
            vehicle:SetPermanentData( race_points_id, value )
        end
    elseif not row_records then
        table.insert( RECORDS_CACHE, CreateRecordModel( {
            [ "id" ] = vehicle:GetPermanentData( "id" ),
            [ "client_id" ] = client_id,
            [ "model" ] = vehicle.model,
            [ "variant" ] = vehicle_variant,
            [ race_points_id ] = value,
            [ race_count_id ] = 1,
        } ) )
        vehicle:SetPermanentData( race_points_id, value )
    end

    vehicle:SetPermanentData( race_count_id, (vehicle:GetPermanentData( race_count_id ) or 0) + 1 )
    RefreshRecordsData()
end

function RemoveRecordsByClientID( client_id )
    for k, v in ripairs( RECORDS_CACHE ) do
        if client_id == v.client_id then
            table.remove( RECORDS_CACHE, k )
        end
    end
    RefreshRecordsData()
end

function GetVehicleDataRow( client_id, model, variant )
    for k, v in pairs( RECORDS_CACHE ) do
        if client_id == v.client_id and model == v.model and variant == v.variant then
            return k
        end
    end
    return false
end

function CreateRecordModel( data )
    return {
        id = data.id,
        clan_id = data.clan_id and GetClanData( data.clan_id, "clan_tag" ) or false,
        client_id = data.client_id,
        nickname = data.client_id:GetNickName(),

        model = data.model,
        class = tostring( data.model ):GetTier( data.variant ),
        variant = data.variant,

        race_circle_count  = data.race_circle_count  or 0,
        race_circle_points = data.race_circle_points or 0,

        race_drift_count  = data.race_drift_count  or 0,
        race_drift_points = data.race_drift_points or 0,

        race_drag_count  = data.race_drag_count  or 0,
        race_drag_points = data.race_drag_points or 0,
    }
end

function RefreshRecordsData()
    local temp = {}
    for class_id, class_name in pairs( RACE_VEHICLE_CLASSES_NAMES ) do
        temp[ class_id ] = {}
        for k, v in pairs( RECORDS_CACHE ) do
            if v.class == class_id then
                table.insert( temp[ class_id ], v )
            end
        end
    end

    RECORDS_DATA = {}
    for race_type, race_data in pairs( RACE_TYPES_DATA ) do
        RECORDS_DATA[ race_type ] = {}
        local race_points_name = "race_" .. race_data.type .. "_points"
        for class_id, class_name in pairs( RACE_VEHICLE_CLASSES_NAMES ) do
            RECORDS_DATA[ race_type ][ class_id ] = {}
            table.sort( temp[ class_id ], function( a, b )
                return CompareRaceRecord( race_type, a[ race_points_name ], b[ race_points_name ] )
            end )

            for i = 1, COUNT_LEADER_BOARD_ROWS do
                if temp[ class_id ][ i ] and temp[ class_id ][ i ][ race_points_name ] > 0 then
                    table.insert( RECORDS_DATA[ race_type ][ class_id ], temp[ class_id ][ i ] )
                elseif not temp[ class_id ][ i ] then
                    break
                end
            end

        end
    end
end

function CompareRaceRecord( race_id, value1, value2 )
    -- Сортировка в обратную сторону, с уччетом нулевого значения
    if race_id == RACE_TYPE_CIRCLE_TIME or race_id == RACE_TYPE_DRAG then
        if value1 == 0 then
            return false
        end
        if value2 == 0 then
            return true
        end
        return value1 < value2
    elseif race_id == RACE_TYPE_DRIFT then
        return value1 > value2
    end
end

function GetPlayerRecords( player )
    local client_id = player:GetClientID()
    local temp = {}
    for class_id, class_name in pairs( RACE_VEHICLE_CLASSES_NAMES ) do
        temp[ class_id ] = {}
        for k, v in pairs( RECORDS_CACHE ) do
            if v.class == class_id then
                table.insert( temp[ class_id ], v )
            end
        end
    end

    local result = {}
    for race_type, race_data in pairs( RACE_TYPES_DATA ) do
        result[ race_type ] = {}
        local race_points_name = "race_" .. race_data.type .. "_points"
        for class_id, class_name in pairs( RACE_VEHICLE_CLASSES_NAMES ) do
            result[ race_type ][ class_id ] = {}
            table.sort( temp[ class_id ], function( a, b )
                return CompareRaceRecord( race_type, a[ race_points_name ], b[ race_points_name ] )
            end )

            for k, v in ipairs( temp[ class_id ] ) do
                if v.client_id == client_id and v.class == class_id and v[ race_points_name ] > 0 then
                    table.insert( result[ race_type ][ class_id ], {
                        place   = k,
                        model   = v.model,
                        variant = v.variant,
                        points  = v[ race_points_name ]
                    } )
                end
            end
        end
    end

    return result
end

function GetPlayerGlobalBestStats( client_id, race_type, vehicle_class )
    local temp = {}
    local records_race_type = table.copy( RECORDS_CACHE )
    local race_points_count = "race_" .. RACE_TYPES_DATA[ race_type ].type .. "_points"
    for k, v in pairs( records_race_type ) do
        if v[ race_points_count ] > 0 and v.class == vehicle_class then
            table.insert( temp, v )
        end
    end
    
    if #temp > 1 then
        table.sort( temp, function( a, b )
            return CompareRaceRecord( race_type, a[ race_points_count ], b[ race_points_count ])
        end )
    end

    for k, v in ipairs( temp ) do
        if v.client_id == client_id then
            return k, v[ race_points_count ]
        end
    end
end

function onResourceStart()
    InitWinners()
    LoadRecordsData()
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )