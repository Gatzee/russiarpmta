----------------------
-- Useful functions --
----------------------

-- Merges all lists into one (key=value arrays are NOT supported)
function table.imerge_all( ... )
    local global_table = { }
    for _, v in pairs( { ... } ) do
        for _, value in pairs( v ) do
            table.insert( global_table, value )
        end
    end
    return global_table
end

-- Merges all key=value arrays into one (lists are NOT supported)
function table.merge_all( ... )
    local global_table = { }
    for _, tbl in pairs( { ... } ) do
        for key, value in pairs( tbl ) do
            global_table[ key ] = value
        end
    end
    return global_table
end