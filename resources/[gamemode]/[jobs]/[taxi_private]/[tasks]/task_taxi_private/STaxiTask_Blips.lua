DRIVER_BLIPS = { }

function CreateDriverBlip( driver )
    DestroyDriverBlip( driver )
    DRIVER_BLIPS[ driver ] = createBlipAttachedTo( driver, 0, 2, 255, 255, 0, 255, 0, 200, root )
    setElementVisibleTo( DRIVER_BLIPS[ driver ], driver, false )
end

function DestroyDriverBlip( driver )
    if isElement( DRIVER_BLIPS[ driver ] ) then
        destroyElement( DRIVER_BLIPS[ driver ] )
    end
    DRIVER_BLIPS[ driver ] = nil
end