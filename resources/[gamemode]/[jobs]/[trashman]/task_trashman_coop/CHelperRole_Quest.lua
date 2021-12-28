
local PLAYER_BAGS = {}

local CARRYING_TMR = nil
local CARRYING_CONTROLS = { "jump", "sprint" }

function CreateTrashPickupPoint( trash_point_id, job_vehicle )
    if CEs.quest_point_take then
        CEs.quest_point_take:destroy()
        CEs.quest_point_take = nil
    end

	local take_pos = TRASH_POINTS[ trash_point_id ].collect
    CEs.quest_point_take = TeleportPoint(
    {
        x = take_pos.x, y = take_pos.y, z = take_pos.z + 1,
		radius = 3,
		gps = true,
        quest_state = false,
    } )
    CEs.quest_point_take.keypress = "lalt"
    CEs.quest_point_take.text = "ALT Взаимодействие"

    CEs.quest_point_take.marker:setColor( 0, 235, 10, 20 )
    CEs.quest_point_take:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 235, 10, 255, 2.3 } )

	CEs.quest_point_take.PostJoin = function( self, player )
        CEs.quest_point_take:destroy()
        CreateLoadingPoint( job_vehicle )
        triggerServerEvent( "onTrashmanTryPickup", resourceRoot )
    end
end
addEvent( "onClientCreateNextPickupPoint", true )
addEventHandler( "onClientCreateNextPickupPoint", resourceRoot, CreateTrashPickupPoint )

function CreateLoadingPoint( job_vehicle )
	local loading_pos = job_vehicle.position - job_vehicle.matrix.forward * 5
    CEs.quest_point_load = TeleportPoint(
    {
        x = loading_pos.x, y = loading_pos.y, z = loading_pos.z - 0.05,
		radius = 3,
		gps = true,
        quest_state = false,
    } )
    CEs.quest_point_load.keypress = "lalt"
    CEs.quest_point_load.text = "ALT Взаимодействие"

    CEs.quest_point_load.marker:setColor( 255, 255, 0, 20 )
	CEs.quest_point_load:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 0, 255, 2.3 } )

	CEs.quest_point_load.PostJoin = function( self, player )
		CEs.quest_point_load:destroy()
		triggerServerEvent( "onTrashmanTryPutInVehicle", resourceRoot )
    end
end

function onClientDestroyPickupPoints_handler()
    if CEs.quest_point_take then CEs.quest_point_take:destroy() end
end
addEvent( "onClientDestroyPickupPoints", true )
addEventHandler( "onClientDestroyPickupPoints", resourceRoot, onClientDestroyPickupPoints_handler )

function onClientPlayerTakeTrashBag_handler( player, job_vehicle )
	DestroyBag( player )
    if not isElement( job_vehicle ) then return end

    if player == localPlayer then SetCarrying( true ) end

	PLAYER_BAGS[ player ] = createObject( TRASH_BAG_MODEL_ID, player.position )
	PLAYER_BAGS[ player ].parent = job_vehicle
	exports.bone_attach:attachElementToBone( PLAYER_BAGS[ player ], player, 12, 0, -0.077, 0.3774, 7.951, 181.741, 0 )
end
addEvent( "onClientPlayerTakeTrashBag", true )
addEventHandler( "onClientPlayerTakeTrashBag", resourceRoot, onClientPlayerTakeTrashBag_handler )

function onClientPlayerPlaceTrashBag_handler( player, job_vehicle )
    if player == localPlayer then SetCarrying( false ) end

    local object = PLAYER_BAGS[ player ]
    PLAYER_BAGS[ player ] = nil
	if isElement( object ) and isElement( job_vehicle ) then
        exports.bone_attach:detachElementFromBone( object )

        attachTrashBagObjectToTruck( object, job_vehicle )
    end
end
addEvent( "onClientPlayerPlaceTrashBag", true )
addEventHandler( "onClientPlayerPlaceTrashBag", resourceRoot, onClientPlayerPlaceTrashBag_handler )

function onClientDestroyBags_handler( player )
    DestroyBag( player )
end
addEvent( "onClientDestroyBags", true )
addEventHandler( "onClientDestroyBags", resourceRoot, onClientDestroyBags_handler )

function DestroyBag( player )
    if player == localPlayer then SetCarrying( false ) end

	if isElement( PLAYER_BAGS[ player ] ) then
        destroyElement( PLAYER_BAGS[ player ] )
    end
    PLAYER_BAGS[ player ] = nil
end

function SetCarrying( state )
    if isTimer( CARRYING_TMR ) then
        killTimer( CARRYING_TMR )
    end
    SetCarryingState( state )
    triggerEvent( "onClientUpdateDiseasesMoveHandler", root, not state )

    if state then
        CARRYING_TMR = setTimer( SetCarryingState, 1000, 1, state )
    end
end

function SetCarryingState( state )
    for k, v in pairs( CARRYING_CONTROLS ) do
        toggleControl( v, not state )
    end
    if state and ( isPedDoingTask( localPlayer, "TASK_COMPLEX_JUMP" ) or localPlayer:getMoveState( ) == "sprint" ) then
        localPlayer.position = localPlayer.position
    end
end