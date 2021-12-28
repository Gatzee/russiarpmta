addEventHandler( "onClientResourceStart", resourceRoot, function ( )
    for i, v in pairs( GATES ) do
        local colshape = createColSphere( v.x, v.y, v.z, 20 )

        addEventHandler( "onClientColShapeHit", colshape, function( element )
            if element ~= localPlayer then return end

            for idx, object in pairs( getElementsByType( "object", resourceRoot, true ) ) do
                if object.model == v.model and getDistanceBetweenPoints3D( object.position, v.x, v.y, v.z ) < 0.01 then
                    object.dimension = 0 -- fix dimension of gates
                    object.alpha = localPlayer.dimension == 0 and 255 or 0 -- if set dimension does not affect
                    object.collisions = localPlayer.dimension == 0 -- if set dimension does not affect

                    break
                end
            end
        end )
    end
end )