loadstring( exports.interfacer:extend( "Interfacer" ) )( )

function setSignals_handler( vehicle, state )
    if isElement( vehicle ) then
        local dimension = getElementDimension( vehicle )
        local px, py, pz = getElementPosition( vehicle )

        Async:foreach( getElementsByType( "player" ), function( v )
            if isElement( v ) then
                local vx, vy, vz = getElementPosition( v )
                local vdimension = getElementDimension( v )
                if getDistanceBetweenPoints3D( px, py, pz, vx, vy, vz ) <= 200 and dimension == vdimension then
                    triggerClientEvent( v, "setSignalsRemote", resourceRoot, vehicle, state )
                end
            end
        end )

    end
end
addEvent( "setSignals", true )
addEventHandler( "setSignals", root, setSignals_handler )