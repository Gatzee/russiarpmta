local map = xmlLoadFile( "clans_base2.map" )

function RollChildren( node )
    local children = xmlNodeGetChildren( node )
    for i, v in pairs( children ) do
        local name = xmlNodeGetName( v )
        local attrs = xmlNodeGetAttributes( v )
        if name == "object" then
            local object = createObject( attrs.model, attrs.posX, attrs.posY, attrs.posZ, attrs.rotX, attrs.rotY, attrs.rotZ, false )
            setElementDimension( object, -1 )
            setObjectBreakable( object, false )
        end
    end
end

RollChildren( map )