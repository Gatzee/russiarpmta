loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

PRICE_MULTIPLIER = { -- TODO: move to DB
    [ 1 ] = 1,
    [ 2 ] = 2.58692862079179,
    [ 3 ] = 3.07380073800738,
    [ 4 ] = 3.89115411195577,
    [ 5 ] = 11.1374271892586,
    [ 6 ] = 3.07380073800738,
}

function getInternalTuningPartByID( id, tier )
    local part = tuning_parts[ id ]

    if part and tonumber( tier ) and PRICE_MULTIPLIER[ tier ] then
        part = table.copy( part )
        part.name = part.names[ tier ] or "NO NAME"
        part.price = math.floor( part.price * PRICE_MULTIPLIER[ tier ] )
        part.tier = tier

        if tier == 6 then
            part.is_moto = true
        end
    end

    return part
end

function getTuningPartsIDByParams( params )
    local parts = { }

    local function is( tableToSearch, value )
        for _, v in pairs( tableToSearch ) do if v == value then return true end end
    end

    for _, part in pairs( tuning_parts ) do
        local suit = true

        for parameter, value in pairs( params ) do
            if ( type( value ) ~= "table" and part[ parameter ] ~= value )
            or ( type( value ) == "table" and not is( value, part[ parameter ] ) ) then
                suit = false
                break
            end
        end

        if suit then
            table.insert( parts, part.id )
        end
    end

    return parts
end