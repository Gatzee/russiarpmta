local coordinator_keys = { "m", "k", "arrow_u", "arrow_d", }

function CreateCoordinatorActionController( sonar_depth )
    if GEs.action_controller then 
        return GEs.action_controller, false
    end

    GEs.action_controller = {
        is_show_sonar = false,
        init = function( self, sonar_depth )
            DisableJobKeys( true )

            triggerEvent( "onClientUpdateSonar", localPlayer, { sonar_depth = FISH_DEPTHS[ sonar_depth ] } )
        end,
        toggle_controls = function( self, state )
            if state then ChangeBindsState( coordinator_keys, false, CoordinatorKeyHandler ) end
            ChangeBindsState( coordinator_keys, state, CoordinatorKeyHandler )
            ShowInfoControls( state )
        end,
        destroy = function( self )
            ChangeBindsState( coordinator_keys, false, CoordinatorKeyHandler )
            DisableJobKeys( false )

            triggerEvent( "SetHUDSonarState", localPlayer, false, true )

            setmetatable( self, nil )
        end,
    }

    GEs.action_controller:init( sonar_depth )

    return GEs.action_controller, true
end

function CoordinatorKeyHandler( key, state )
    if key == "k" and state == "down" then
        GEs.action_controller.is_show_sonar = not GEs.action_controller.is_show_sonar
        triggerEvent( "ToggleSonarMap", localPlayer )
    elseif (key == "arrow_u" or key == "arrow_d") and state == "down" and GEs.action_controller.is_show_sonar then
        local direction = key == "arrow_d"
        GEs.sonar_depth = direction and math.min( 10, GEs.sonar_depth + 1 ) or math.max( 1, GEs.sonar_depth - 1 )
        triggerEvent( "onClientUpdateSonar", localPlayer, { sonar_depth = FISH_DEPTHS[ GEs.sonar_depth ], direction = direction, }, true )
    end
end

function CreateFishingArea( lobby_data )
    DestroyFishingArea()

    local area_position = FISHING_ROUTES[ lobby_data.route_id ][ lobby_data.current_fishing_area_id ]
    if not area_position then return end

    GEs.shape_area = createColSphere( area_position, FISHING_AREA_RADIUS )
    
    GEs.blip_area = createBlip( area_position, 0, 5, 255, 255, 255, 255, 0, 150 )
    setElementData( GEs.blip_area, "extra_blip", 75, false )

    GEs.func_colshape_hit = function( element, dimension )
        if element ~= localPlayer then return end
        
        removeEventHandler( "onClientColShapeHit", GEs.shape_area, GEs.func_colshape_hit )
        triggerServerEvent( lobby_data.end_step, localPlayer )
    end
    addEventHandler( "onClientColShapeHit", GEs.shape_area, GEs.func_colshape_hit )
end

function DestroyFishingArea()
    if isElement( GEs.shape_area ) then
        destroyElement( GEs.shape_area )
        destroyElement( GEs.blip_area )
    end
end

function CreateFishPoints( lobby_data )
    CEs.finish_sides = {}
    CEs.side_fish_loaded = {}

    local points_depth_index = math.random( 1, #FISH_DEPTHS )
    iprint("depth_fish: ", FISH_DEPTHS[ points_depth_index ] )
    
    CEs.fish_points = {}
    local area_position = FISHING_ROUTES[ lobby_data.route_id ][ lobby_data.current_fishing_area_id ]
    for point_index = 1, COUNT_FISH_IN_ZONE do
        local point_position = area_position:AddRandomRange( FISHING_FISH_RANDOM_RADIUS ) + Vector3( 0, 0, GetPositionByDepthIndex( points_depth_index ) - 2 )
        
        local point_shape = createColTube( point_position, FISHING_FISH_RADIUS, 2 )
        addEventHandler( "onClientColShapeHit", point_shape, function( element, dimension )
            if not isElement( element ) or getElementType( element ) ~= "object" then return end

            local side = element:getData( "boat_side" )
            if not side or CEs.finish_sides[ side ] then return end
            
            CEs.finish_sides[ side ] = true
            point_shape:destroy()

            if CEs.side_fish_loaded[ LEFT_BOAT_SIDE ] and CEs.side_fish_loaded[ RIGHT_BOAT_SIDE ] then
                localPlayer:ShowInfo( "Вся рыба в области собрана" )
                triggerEvent( "onClientUpdateSonar", localPlayer, { fishes = nil } )
            end
            
            CEs.side_fish_loaded[ side ] = true
            triggerServerEvent( "onServerIndustrialFishingTakeFish", resourceRoot, side )
        end )

        table.insert( CEs.fish_points, { point_shape = point_shape } )
    end

    triggerEvent( "onClientUpdateSonar", localPlayer, 
    { 
        fishes = CEs.fish_points, 
        fish_depth = FISH_DEPTHS[ points_depth_index ] 
    } )
end

function SetDepthHud( z )
	MANIPULATION_DEPTH_INDEX = GetDepthIndexByPosition( z )
	triggerEvent( "UpdateIndustrialFishingProgress", localPlayer, {
		[ FISHERMAN ] = {
			index = "depth",
			value = MANIPULATION_DEPTH_INDEX / #FISH_DEPTHS,
			depth = FISH_DEPTHS[ MANIPULATION_DEPTH_INDEX ] or 0,
		}
	} )
end