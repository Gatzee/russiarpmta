loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )

STINGERS = { }
STINGERS_POSITIONS = { }

function onStingerCommand( )
    local vehicle = localPlayer.vehicle
    if not vehicle or vehicle.occupants[ 0 ] ~= localPlayer then return end

    if not FACTION_RIGHTS.STINGER[ localPlayer:GetFaction( ) ] then return end
    if not localPlayer:IsOnFactionDuty() then return end

    --if vehicle.velocity:getLength() > 0.2 then return end -- только стоячему автомобилю
    if LAST_STINGER_TIME and getTickCount() - LAST_STINGER_TIME <= STINGER_TIMEOUT then return end
    LAST_STINGER_TIME = getTickCount()

    local _, _, _, _, y_distance = getElementBoundingBox( vehicle )
    local x, y, z = getPositionFromElementAtOffset( vehicle, 0, STINGER_DISTANCE - y_distance, 0 )
    local z = getGroundPosition( x, y, z )
    z = z + STINGER_GROUND_DISTANCE
    local rx, ry, rz = getElementRotation( vehicle )
    triggerServerEvent( "OnCreateStingerRequest", localPlayer, x, y, z, rx, ry, rz + 90 )
end
bindKey( "x", "down", onStingerCommand )

function OnStingerCreate_handler( element )
    if not isElement( element ) then return end
    if source == localPlayer then
        playSoundFrontEnd( 40 ) 
    end


    STINGERS[ element ] = source
    local offset_positions = { 
        { 0, -2.5 + STINGER_SENSIVITY, 0 },
        { 0, 0, 0 },
        { 0, 2.5 - STINGER_SENSIVITY , 0 },
     }
    STINGERS_POSITIONS[ element ] = { }
    for i, v in pairs( offset_positions ) do
        STINGERS_POSITIONS[ element ][ i ] = { getPositionFromElementAtOffset( element, unpack( v ) ) }
    end

    removeEventHandler( "onClientPreRender", root, CheckStingers )
    addEventHandler( "onClientPreRender", root, CheckStingers )
end
addEvent( "OnStingerCreate", true )
addEventHandler( "OnStingerCreate", root, OnStingerCreate_handler )

function CheckStingers( )
    local vehicle = localPlayer.vehicle
    if not vehicle or vehicle.occupants[ 0 ] ~= localPlayer then return end
    local wheel_positions = { }
    for i = 1, 4 do
        table.insert( wheel_positions, { getVehicleWheelPosition( vehicle, i ) } )
    end
    for stinger, player in pairs( STINGERS ) do
        if not isElement( stinger ) or not isElement( player ) then
            if isElement( stinger ) then
                destroyElement( stinger )
                STINGERS[ stinger ] = nil
            end
            STINGERS_POSITIONS[ stinger ] = nil
            if not next( STINGERS ) then
                removeEventHandler( "onClientPreRender", root, CheckStingers )
            end
        else
            --iprint( STINGER_SIZE )
            local wheel_states = { getVehicleWheelStates( vehicle ) }
            local positions = STINGERS_POSITIONS[ stinger ]
            for i, wheel_pos in pairs( wheel_positions ) do
                for _, position in pairs( positions ) do
                    if getDistanceBetweenPoints3D( position[ 1 ], position[ 2 ], position[ 3 ], unpack( wheel_pos ) ) <= STINGER_SENSIVITY then
                        --iprint( "flat", i )
                        wheel_states[ i ] = 1
                        --iprint( wheel_states )
                    end
                end
            end
            setVehicleWheelStates( vehicle, unpack( wheel_states ) )
        end
    end
end
-- Timer( CheckStingers, 50, 0 )

function getPositionFromElementAtOffset( element, x, y, z )
	if not x or not y or not z then      
		return x, y, z   
	end        
	local matrix = getElementMatrix ( element )
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end

function getVehicleWheelPosition( vehicle, wheel )
	local x, y, z = 0, 0, 0
	local minX, _, minZ, maxX, maxY = getElementBoundingBox( vehicle )
	if wheel == 1 then
		x, y, z = getPositionFromElementAtOffset( vehicle, minX, maxY, minZ )
	elseif wheel == 2 then
		x, y, z = getPositionFromElementAtOffset( vehicle, minX, -maxY, minZ )		
	elseif wheel == 3 then
		x, y, z = getPositionFromElementAtOffset( vehicle, maxX, maxY, minZ )
	elseif wheel == 4 then
		x, y, z = getPositionFromElementAtOffset( vehicle, maxX, -maxY, minZ )
	end	 
	return x, y, z
end