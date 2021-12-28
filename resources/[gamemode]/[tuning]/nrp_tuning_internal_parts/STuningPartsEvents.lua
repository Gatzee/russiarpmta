addEventHandler( "onResourceStart", resourceRoot, function ( )
    CommonDB:createTable( "nrp_tuning_internal_parts", {
        { Field = "id",                 Type = "int(11) unsigned",  Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment"    };
        { Field = "names",		        Type = "text",				Null = "NO",	Key = "",                                   };
        { Field = "type",		        Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 1	                                    };
        { Field = "subtype",		    Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 1	                                    };
        { Field = "category",		    Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 1	                                    };
        { Field = "speed",		        Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 0	                                    };
        { Field = "acceleration",	    Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 0	                                    };
        { Field = "controllability",    Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 0	                                    };
        { Field = "clutch",		        Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 0	                                    };
        { Field = "slip",		        Type = "smallint(3)",	    Null = "NO",    Key = "",       Default = 0	                                    };
        { Field = "price",		        Type = "int(11)",	        Null = "NO",    Key = "",       Default = 0	                                    };
    } )

    local function callback( query )
        if not query then return end
        local data = dbPoll( query, 0 )
        dbFree( query )
        if type( data ) ~= "table" then return end

        local function sort( d )
            local sortedTable = { }
            local result = { }

            for _, value in pairs( d ) do
                if not sortedTable[ value.type ] then
                    sortedTable[ value.type ] = { }
                end

                if not sortedTable[ value.type ][ value.category ] then
                    sortedTable[ value.type ][ value.category ] = { }
                end

                table.insert( sortedTable[ value.type ][ value.category ], value )
            end

            for _, t in pairs( sortedTable ) do
                for _, t2 in pairs( t ) do
                    table.sort( t2, function ( a, b ) return a.subtype < b.subtype end )
                    for _, value in pairs( t2 ) do
                        table.insert( result, value )
                    end
                end
            end

            return result
        end

        local sortedData = sort( data )

        for class = 1, #VEHICLE_CLASSES_NAMES do
            local parts = table.copy( sortedData )

            for _, part in pairs( parts ) do
                part.name = ( fromJSON( part.names ) or { } )[ class ] or "NO NAME"
                part.price = math.floor( part.price * ( PRICE_MULTIPLIER[ class ] or 1 ) )
            end

            sorted_tuning_parts[ class ] = parts -- save sorted & filtered parts
        end

        for _, part in pairs( data ) do
            part.names = ( fromJSON( part.names ) or { } )
            tuning_parts[ part.id ] = part -- save all parts
        end
    end

    CommonDB:queryAsync( callback, { }, "SELECT * FROM nrp_tuning_internal_parts" )
end )

addEvent( "onVehiclePreLoad" )
addEventHandler( "onVehiclePreLoad", root, function ( data )
    -- convert old tuning system to new
    local tuning_parts = { }

    for _, value in pairs( data.tuning_internal ) do
        if type( value ) == "table" then
            if value.id then -- not need convertation
                source:ParseHandling( ) -- apply tuning effect
                return
            end

            local analogPart = getAnalogTuningPart( value[ tostring( P_TYPE ) ], value[ tostring( P_TIER ) ] )
            if analogPart then
                tuning_parts[ analogPart.type ] = { id = analogPart.id, damaged = value[ tostring( P_WEAROFF ) ] }
            end
        end
    end

    if next( tuning_parts ) then
        source:SetPermanentData( "tuning_internal", tuning_parts )
    end

    source:ParseHandling( ) -- apply tuning effect
    -- {{damaged=1,id=5},{id=18},{id=35},{id=49},{id=73},{id=89},{id=103}}
end )

addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, function ( )
    -- convert old tuning system to new
    local tuning_parts = { }
    local old_tuning_parts = source:GetPermanentData( "tuning_internal" ) or { }

    for _, value in pairs( old_tuning_parts ) do
        if type( value[ tostring( P_NAME ) ] ) ~= "string" then return end -- not need convertation

        local analogPart = getAnalogTuningPart( value[ tostring( P_TYPE ) ], value[ tostring( P_TIER ) ] )
        if analogPart then
            local tier = value[ tostring( P_CLASS ) ]
            if not tuning_parts[ tier ] then
                tuning_parts[ tier ] = { }
            end
            table.insert( tuning_parts[ tier ], analogPart.id )
        end
    end

    if next( tuning_parts ) then
        source:SetPermanentData( "tuning_internal", tuning_parts )
    end
end )

addEvent( "onTuningPartsListRequest", true )
addEventHandler( "onTuningPartsListRequest", resourceRoot, function ( )
    triggerClientEvent( client, "onTuningPartsListResponse", resourceRoot, tuning_parts )
end )