FARMS = { 
    [ 0 ] = {
        map = "map/markers_0.map",
        lines = "json/lines_0.json",

        employment = { },
        shit = { },
        base = { },

        lines_list = { },
    },
    [ 1 ] = {
        map = "map/markers_1.map",
        lines = "json/lines_1.json",

        employment = { },
        shit = { },
        base = { },

        lines_list = { },
    },
    LAST_UPDATED = 0,
}

EMPLOYMENT_COLOR = "#DB1CE22F"
SHIT_COLOR       = "#DDFD003C"
BASE_COLOR       = "#E1951D3C"

function LoadMarkers( )
    for farm_num, farm_conf in pairs( FARMS ) do
        if type( farm_conf ) == "table" then
            farm_conf.employment, farm_conf.shit, farm_conf.base = LoadMarkers_Map( farm_conf.map )
            outputConsole( "FARM_" .. farm_num )

            -- Employment
            outputConsole( "MARKERS_POSITIONS = {")
            for i, v in pairs( farm_conf.employment ) do
                outputConsole( "    { x = " .. v.x .. ", y = " .. v.y .. ", z = " .. v.z .. ", city = " .. farm_num .. " }" )
            end
            outputConsole( "}")

            outputConsole( "SHIT_POSITIONS = {")
            for i, v in pairs( farm_conf.shit ) do
                outputConsole( "    { x = " .. v.x .. ", y = " .. v.y .. ", z = " .. v.z .. ", city = " .. farm_num .. " }" )
            end
            outputConsole( "}")

            outputConsole( "BASE_POSITIONS = {")
            for i, v in pairs( farm_conf.base ) do
                outputConsole( "    { x = " .. v.x .. ", y = " .. v.y .. ", z = " .. v.z .. ", city = " .. farm_num .. " }" )
            end
            outputConsole( "}")






            local file = fileCreate( "farm_" .. farm_num .. ".json" )
            fileWrite( file, toJSON( farm_conf, true ) )
            fileClose( file )

            farm_conf.lines_list = LoadMarkers_Lines( farm_conf.lines )
            --iprint( "Farm", farm_num, "Employment", #farm_conf.employment, "shit", #farm_conf.shit, "base", #farm_conf.base, "lines", #farm_conf.lines_list )
        end
    end
end

function LoadMarkers_Map( map )
    local file = xmlLoadFile( map )
    local children = xmlNodeGetChildren( file )
    
    local employment, shit, base = { }, { }, { }

    for i, v in pairs( children ) do
        local attrs = xmlNodeGetAttributes( v )
        local x, y, z, size = tonumber( attrs.posX ), tonumber( attrs.posY ), tonumber( attrs.posZ ), tonumber( attrs.size )

        local conf = { x = x, y = y, z = z, radius = size }

        if attrs.color == EMPLOYMENT_COLOR then
            table.insert( employment, conf )

        elseif attrs.color == SHIT_COLOR then
            table.insert( shit, conf )

        elseif attrs.color == BASE_COLOR then
            table.insert( base, conf )

        end
    end

    xmlUnloadFile( file )

    return employment, shit, base

end

function LoadMarkers_Lines( lines )
    local file = fileOpen( lines )
    local json = fileRead( file, fileGetSize( file ) )
    local tbl = fromJSON( json )
    fileClose( file )
    return tbl
end

LoadMarkers( )