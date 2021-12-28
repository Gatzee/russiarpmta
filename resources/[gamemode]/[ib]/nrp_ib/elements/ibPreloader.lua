local E_CLASS = "ibPreloader"

function ibCreatePreloader( self )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibPreloader[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )

    for i, v in pairs( self ) do
        self[ "ibPreloader_" .. v ] = ConvertToForeignFile( element, texture_name )
    end

    addEventHandler( "ibOnElementDataChange", element, function( key, value )
        if string.sub( key, 1, 12 ) ~= "ibPreloader_" then
            self[ "ibPreloader_" .. value ] = ConvertToForeignFile( element, value )
        end
    end )

    return element
end