
CONTAINER_PORT_POSITION = {
	{ position =  Vector3( -20, -15, -3.9 ) },
	{ position =  Vector3( 20, -15, -3.9 ) },
}

CONTAINER_ATTACH = {
	{
		position = Vector3( 0, -3, -4.3 ),
		rotation = Vector3( 0, 0, 0 ),
	},
	{
		position = Vector3( 0, -3, -4.3 ),
		rotation = Vector3( 0, 0, 0 ),
	}	
}


function CreateFishermanActionController( side_index, vehicle )
    if GEs.action_controller then 
        return GEs.action_controller, false
    end

    GEs.action_controller = {
        init = function( self, side_index )
            MANIPULATOR_SIDE = side_index
						
			DisableJobKeys( true )

			MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_ROTATE ].min = side_index == RIGHT_BOAT_SIDE and -120  or -25
			MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_ROTATE ].max = side_index == RIGHT_BOAT_SIDE and 25 or 120
        end,
        toggle_controls = function( self, state, vehicle )
            if state then SetManipulatorActionsState( false, vehicle ) end
            MANIPULATOR_DATA.state = false
            SetManipulatorActionsState( state, vehicle )
            ShowInfoControls( state )
        end,
        destroy = function( self )
            DisableJobKeys( false )
            SetManipulatorActionsState( false, vehicle )
            setmetatable( self, nil )
        end,
    }

    GEs.action_controller:init( side_index )

    return GEs.action_controller, true
end

function OnStartFisherManGame( lobby_data )
    local count_loaded_container = 0

    CEs.onPlayerLoadContainer = function( element, dimension )
        local fisherman_index = localPlayer:getData( "fisherman_index" )
        if getElementType( element ) ~= "object" or getElementData( element, "boat_side" ) ~= fisherman_index then return end

        CEs.load_point_shape:destroy( )
        CEs.load_point_marker:destroy( )

        count_loaded_container = count_loaded_container + 1
        if count_loaded_container ~= CONTAINER_UNLOAD_COUNT then 
            CEs.CreateContainer()
        end

        triggerServerEvent( "onServerFisherManManipulatorObject", resourceRoot, MANIPULATION_CONTAINER_LOADED, fisherman_index, count_loaded_container == CONTAINER_UNLOAD_COUNT )
    end

    CEs.onPlayerTakeContainer = function( element, dimension )
        local fisherman_index = localPlayer:getData( "fisherman_index" )
        if getElementType( element ) ~= "object" or getElementData( element, "boat_side" ) ~= fisherman_index then return end

        CEs.container_marker:destroy( )
        CEs.container_shape:destroy( )
        CEs.container_obj:destroy( )

        local load_radius = 5

        local container_position = lobby_data.job_vehicle.position + CONTAINER_PORT_POSITION[ fisherman_index ].position + Vector3( 0, count_loaded_container * 5, 0 )
        CEs.load_point_shape = createColSphere( container_position, load_radius )
        
        CEs.load_point_marker = createMarker( CEs.load_point_shape.position, "cylinder", load_radius - 0.1, 100, 250, 100, 150 )
        CEs.load_point_marker:attach( CEs.load_point_shape )
        CEs.load_point_marker:setAttachedOffsets( Vector3( 0, 0, 2.5 ), 0, 0, 0 )
        
        addEventHandler( "onClientColShapeHit", CEs.load_point_shape, CEs.onPlayerLoadContainer )
        localPlayer:ShowInfo( "Поставь контейнер на пристань" )

        triggerServerEvent( "onServerFisherManManipulatorObject", resourceRoot, MANIPULATION_CONTAINER_CREATE, fisherman_index )
    end

    CEs.CreateContainer = function( )
        local fisherman_index = localPlayer:getData( "fisherman_index" )
        
        CEs.container_obj = Object( CONTAINER_ID, lobby_data.job_vehicle.position, lobby_data.job_vehicle.rotation )
        CEs.container_obj:setCollisionsEnabled( false )
        CEs.container_obj:attach( lobby_data.job_vehicle, CONTAINER_ATTACH[ fisherman_index ].position, CONTAINER_ATTACH[ fisherman_index ].rotation )

        CEs.container_shape = createColSphere( CEs.container_obj.position, CONTAINER_SHAPE_RADIUS )
        CEs.container_shape:attach( CEs.container_obj )
        
        CEs.container_marker = createMarker( CEs.container_obj.position, "cylinder", 3, 100, 250, 100, 150 )
        CEs.container_marker:attach( CEs.container_shape )
        CEs.container_marker:setAttachedOffsets( Vector3( 0, 0, 3 ), 0, 0, 0 )

        addEventHandler( "onClientColShapeHit", CEs.container_shape, CEs.onPlayerTakeContainer )
    end

    localPlayer:ShowInfo( "Разгрузи 3 контейнера с рыбой" )
    CEs.CreateContainer( )
end