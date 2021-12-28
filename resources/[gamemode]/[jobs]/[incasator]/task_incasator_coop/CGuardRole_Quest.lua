
local PLAYER_BAGS = {}

local CARRYING_TMR = nil
local CARRYING_CONTROLS = { "jump", "sprint" }

function CreateLoadingPoint( job_vehicle )
	local loading_pos = GetForwardBackwardElementPosition( job_vehicle, 1, 3.5 )
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
		triggerServerEvent( "onServerIncasatorTryPlaceBagInVehicle", resourceRoot )
    end
end
addEvent( "onClientCreateLoadingPoint", true )
addEventHandler( "onClientCreateLoadingPoint", resourceRoot, CreateLoadingPoint )

function CreateTakeBussinessPoint( bank_point_id, job_vehicle )
    if CEs.quest_point_take then
        CEs.quest_point_take:destroy()
        CEs.quest_point_take = nil
    end
    
	local take_pos = BANK_LOAD_POINT[ bank_point_id ].collect
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
        triggerServerEvent( "onServerIncasatorTryTakeBagFromBusiness", resourceRoot )
    end
end
addEvent( "onClientCreateTakeNextPoint", true )
addEventHandler( "onClientCreateTakeNextPoint", resourceRoot, CreateTakeBussinessPoint )

function CreateTakeVehiclePoint( job_vehicle )
	local loading_pos = GetForwardBackwardElementPosition( job_vehicle, 1, 3.8 )
    CEs.quest_point_take = TeleportPoint(
    {
        x = loading_pos.x, y = loading_pos.y, z = loading_pos.z - 0.05,
		radius = 3,
		gps = true,
        quest_state = false,
    } )
    CEs.quest_point_take.keypress = "lalt"
    CEs.quest_point_take.text = "ALT Взаимодействие"
    
    CEs.quest_point_take.marker:setColor( 255, 255, 0, 20 )
	CEs.quest_point_take:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 0, 255, 2.3 } )
	
	CEs.quest_point_take.PostJoin = function( self, player )
        CEs.quest_point_take:destroy()
        CreateUnloadPoint()
		triggerServerEvent( "onServerIncasatorTryTakeBagFromVehicle", resourceRoot )
    end
end
addEvent( "onClientCreateTakeVehicleNextPoint", true )
addEventHandler( "onClientCreateTakeVehicleNextPoint", resourceRoot, CreateTakeVehiclePoint )

function CreateUnloadPoint()
    CEs.quest_point_unload = TeleportPoint(
    {
        x = BANK_UNLOAD_POINT_PED.x, y = BANK_UNLOAD_POINT_PED.y, z = BANK_UNLOAD_POINT_PED.z,
		radius = 3,
		gps = true,
        quest_state = false,
    } )
    CEs.quest_point_unload.keypress = "lalt"
    CEs.quest_point_unload.text = "ALT Взаимодействие"
    
    CEs.quest_point_unload.marker:setColor( 255, 255, 0, 20 )
	CEs.quest_point_unload:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 0, 255, 2.3 } )
	
	CEs.quest_point_unload.PostJoin = function( self, player )
		CEs.quest_point_unload:destroy()
		triggerServerEvent( "onServerIncasatorTryPlaceBagInUnloadPoint", resourceRoot )
    end
end

function onClientDestroyGuardPoints_handler()
    if CEs.quest_point_take then CEs.quest_point_take:destroy() end
end
addEvent( "onClientDestroyGuardPoints", true )
addEventHandler( "onClientDestroyGuardPoints", resourceRoot, onClientDestroyGuardPoints_handler )

function onClientPlayerTakeBagMoney_handler( player, job_vehicle )
    CreateBagAttachedPlayer( player )
end
addEvent( "onClientPlayerTakeBagMoney", true )
addEventHandler( "onClientPlayerTakeBagMoney", resourceRoot, onClientPlayerTakeBagMoney_handler )


function onClientPlayerPlaceBagMoney_handler( player )
	DestroyBag( player )
end
addEvent( "onClientPlayerPlaceBagMoney", true )
addEventHandler( "onClientPlayerPlaceBagMoney", resourceRoot, onClientPlayerPlaceBagMoney_handler )

function onClientDestroyBags_handler( participants )
    for k, v in pairs( participants ) do
        if v.role == JOB_ROLE_GUARD then
            DestroyBag( v.player )
        end
    end
end
addEvent( "onClientDestroyBags", true )
addEventHandler( "onClientDestroyBags", resourceRoot, onClientDestroyBags_handler )

function CreateBagAttachedPlayer( player )
	DestroyBag( player )

    if player == localPlayer then SetCarrying( true ) end
    
	PLAYER_BAGS[ player ] = createObject( BAG_MODEL_ID, player.position )
	exports.bone_attach:attachElementToBone( PLAYER_BAGS[ player ], player, 3, 0, -0.13, 0.1, -5, 0, 0 )
end


function DestroyBag( player )
    if player == localPlayer then SetCarrying( false ) end

	if isElement( PLAYER_BAGS[ player ] ) then
        destroyElement( PLAYER_BAGS[ player ] )
        PLAYER_BAGS[ player ] = nil
    end
end

function onClientElementStreamOut_handler()
    if getElementType( source ) ~= "player" or not PLAYER_BAGS[ source ] then return end
    DestroyBag( source )
end
addEventHandler( "onClientElementStreamOut", root, onClientElementStreamOut_handler )

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
end

function onReturnVehicleGuard( player )
    if player ~= localPlayer then return end
    removeEventHandler( "onClientVehicleEnter", source, onReturnVehicleGuard )

    if isElement( CEs.vehicle_blip ) then
        destroyElement( CEs.vehicle_blip )
    end
end