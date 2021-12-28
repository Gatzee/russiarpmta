local ELEMENTS = { }

function CreateMap( )
    DestroyMap( )
    local objects = {
        { model = 17629 },
        { model = 17631 },
        { model = 17630 },
    }
    for i, v in pairs( objects ) do
        local object = createObject( v.model, DATA.position )
        if object then
            table.insert( ELEMENTS, object )
            table.insert( UI_elements, object )
            --setElementInterior( object, 1 )
            setElementDimension( object, 1 )
        end
    end
end

function DestroyMap( )
    for i, v in pairs( ELEMENTS ) do
        if isElement( v ) then destroyElement( v ) end
    end
    ELEMENTS = { }
end
