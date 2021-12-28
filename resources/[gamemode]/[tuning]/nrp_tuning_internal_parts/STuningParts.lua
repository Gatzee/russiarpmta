Extend( "SDB" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

tuning_parts = { }
sorted_tuning_parts = { }

function getTuningPartsForPurchase( class )
    return sorted_tuning_parts[ class ] or { }
end

function getAnalogTuningPart( type, category )
    for _, part in pairs( tuning_parts ) do
        if part.subtype == INTERNAL_PART_TYPE_R and part.type == type and part.category == category then
            return part
        end
    end
end

-- DEV CONVERTER FROM OLD FORMAT

function getAnalogTuningPart2( type, category )
    local parts = { }

    for _, part in pairs( tuning_parts ) do
        if part.type == type and part.category == category then
            parts[ part.subtype ] = part
        end
    end

    return parts
end

setTimer( function ( )
    local db_result = MariaGet( "tuning_cases_info" )
    local cases_info = db_result and fromJSON( db_result ) or { }
    local cases = { }

    for _, v in pairs( cases_info.active_cases ) do
        if string.sub( v.id, 1, 6 ) == "tuning" then
            local id = string.match( v.id, "%d+" )

            if not cases[ id ] then
                cases[ id ] = { }
            end

            table.insert( cases[ id ], v )
        end
    end

    for id, case in pairs( cases ) do
        local caseNewFormat = { }

        for class, content in pairs( case ) do
            caseNewFormat[ VEHICLE_CLASSES_NAMES[ class ] ] = { }

            for _, item in pairs( content.items ) do
                local parts = getAnalogTuningPart2( item.params[ tostring( 1 ) ], item.params[ tostring( 2 ) ] )
                local object = { chance = item.chance }

                for subtype, part in pairs( parts ) do
                    object[ INTERNAL_PARTS_NAMES_TYPES[ subtype ] ] = part.id
                end

                table.insert(  caseNewFormat[ VEHICLE_CLASSES_NAMES[ class ] ], object )
            end
        end

        local file = fileCreate( "output/case-" .. tonumber( id ) .. ".json" )
        fileWrite( file, toJSON( caseNewFormat ):gsub( " ", "" ) )
        fileClose( file )
    end
end, 1000, 1 )


-- DEV CONVERTER

--[[CommonDB:createTable( "tuning_internal_parts_converter_test", {
    { Field = "id",                 Type = "int(11) unsigned",  Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment"    };
    { Field = "r",		            Type = "varchar(64)",		Null = "NO",	Key = "",       Default = ""                                    };
    { Field = "x",		            Type = "varchar(64)",	    Null = "NO",    Key = "",       Default = ""	                                };
    { Field = "f",		            Type = "varchar(64)",	    Null = "NO",    Key = "",       Default = ""	                                };
    { Field = "chance",		        Type = "float(11)",	        Null = "NO",    Key = "",       Default = 1	                                    };
    { Field = "case_id",		    Type = "int(3) unsigned",	Null = "NO",    Key = "",       Default = 1	                                    };
} )

local function callback( query )
    if not query then return end
    local data = dbPoll( query, 0 )
    dbFree( query )
    if type( data ) ~= "table" then return end

    local function findPartByName( n )
        for _, part in pairs( tuning_parts ) do
            for class, name in pairs( part.names ) do
                if name == n then
                    return part, class
                end
            end
        end
    end

    local case_id = 4
    local converted = { }
    for _, charOfClass in pairs( VEHICLE_CLASSES_NAMES ) do
        converted[ charOfClass ] = { }
    end

    for idx, d in pairs( data ) do
        if d.case_id == case_id then
            local r, class = findPartByName( d.r )
            local x, class2 = findPartByName( d.x )
            local f, class3 = findPartByName( d.f )

            if not class or class ~= class2 or class2 ~= class3 or r.category ~= x.category or x.category ~= f.category then
                iprint( idx, "Error of convertation" )
                return
            end

            table.insert( converted[ VEHICLE_CLASSES_NAMES[ class ] ], {
                R = r.id,
                X = x.id,
                F = f.id,
                chance = d.chance
            } )
        end
    end

    local file = fileCreate( "output/" .. case_id .. ".json" )
    fileWrite( file, toJSON( converted ):gsub( " ", "" ) )
    fileClose( file )

    iprint( "finished" )
end

setTimer( function( )
    CommonDB:queryAsync( callback, { }, "SELECT * FROM tuning_internal_parts_converter_test" )
end, 2000, 1 )]]
