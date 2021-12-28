local QUEST_ITEM_PICKUPS = { }
local ATTACHED_ITEMS = { }
local LAST_ITEM_ACTION = 0

local running_minigame = false
local minigame_tid

function CreateQuestItemPickup( x, y, z, tid, is_minigame )
	if QUEST_ITEM_PICKUPS[ tid ] then
		DestroyQuestItemPickup( tid )
	end

    local item_point = TeleportPoint(
    {
        x = x, y = y, z = z,
		radius = 3,
		gps = true,
		dimension = localPlayer.dimension,
    } )

    item_point.keypress = "lalt"
    item_point.text = "ALT Взаимодействие"
    item_point.tid = tid
    item_point.minigame = is_minigame
    item_point.accepted_elements = { player = true }
    item_point.marker:setColor( 0, 235, 10, 20 )
    item_point.object = createObject( 711, x, y, z-1 )
    item_point.object.dimension = localPlayer.dimension
    setElementCollisionsEnabled( item_point.object, false )
    item_point:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 235, 10, 255, 2.3 } )

    if not is_minigame then
    	item_point.elements = {}
		item_point.elements.blip = createBlipAttachedTo(item_point.marker, 41, 5, 250, 100, 100)
		item_point.elements.blip.position = item_point.marker.position
	end

	item_point.PostJoin = function( self, player )
		if player ~= localPlayer then return end
		if isPedDead( player ) then return end
		if isPedInVehicle( player ) then return end
		if ATTACHED_ITEMS[ player ] then return end
		if getTickCount() - LAST_ITEM_ACTION < 500 then return end
		LAST_ITEM_ACTION = getTickCount()

		if self.minigame then
			StartItemMinigame( self.tid )
		else
        	triggerServerEvent( "OnPlayerTryPickupQuestItem", resourceRoot, self.tid )
        end
    end

    QUEST_ITEM_PICKUPS[ tid ] = item_point

    return item_point
end
addEvent( "CreateQuestItemPickup", true )
addEventHandler( "CreateQuestItemPickup", resourceRoot, CreateQuestItemPickup )

function DestroyQuestItemPickup( tid )
	if QUEST_ITEM_PICKUPS[ tid ] then
		if isElement( QUEST_ITEM_PICKUPS[ tid ].object ) then
			destroyElement( QUEST_ITEM_PICKUPS[ tid ].object )
		end

		QUEST_ITEM_PICKUPS[ tid ]:destroy( )
		QUEST_ITEM_PICKUPS[ tid ] = nil

		if minigame_tid == tid then
			StopItemMinigame( )
		end
	end
end

function OnPlayerPickupQuestItem( player, tid )
	DestroyQuestItemPickup( tid )

	local object = createObject( 711, player.position )
	ATTACHED_ITEMS[ player ] = object
	object.dimension = localPlayer.dimension
	exports.bone_attach:attachElementToBone( object, player, 12, 0, -0.077, 0.3774, 7.951, 181.741, 0 )
	setPedWeaponSlot( player, 0 )

	if player == localPlayer then
		toggleControl( "aim_weapon", false )
		toggleControl( "fire", false )
		addEventHandler( "onClientKey", root, DropItemKeyHandler )
		addEventHandler( "onClientPlayerWeaponSwitch", root, OnClientPlayerWeaponSwitch )

		localPlayer:ShowInfo( "Нажмите Alt чтобы выбросить мешок на землю." )
	end

	removeEventHandler( "onClientPreRender", root, PreRenderHoldedItems )
	addEventHandler( "onClientPreRender", root, PreRenderHoldedItems )
end
addEvent( "OnPlayerPickupQuestItem", true )
addEventHandler( "OnPlayerPickupQuestItem", resourceRoot, OnPlayerPickupQuestItem )

function OnPlayerDropQuestItem( player, tid )
	local x, y, z = getElementPosition( player )
	CreateQuestItemPickup( x, y, z, tid )

	if isElement( ATTACHED_ITEMS[ player ] ) then
		exports.bone_attach:detachElementFromBone( ATTACHED_ITEMS[ player ] )
		destroyElement( ATTACHED_ITEMS[ player ] )
		ATTACHED_ITEMS[ player ] = nil
	end

	if player == localPlayer then
		toggleControl( "aim_weapon", true )
		toggleControl( "fire", true )
		removeEventHandler( "onClientKey", root, DropItemKeyHandler )
		removeEventHandler( "onClientPlayerWeaponSwitch", root, OnClientPlayerWeaponSwitch )
	end
end
addEvent( "OnPlayerDropQuestItem", true )
addEventHandler( "OnPlayerDropQuestItem", resourceRoot, OnPlayerDropQuestItem )

function DropItemKeyHandler( key, state )
	if key == "mouse1" or key == "mouse2" then 
		cancelEvent()
		return 
	end

	if key ~= "lalt" or not state then return end
	if isPedInVehicle( localPlayer ) then return end
	if isPedDead( localPlayer ) then return end
	if getTickCount() - LAST_ITEM_ACTION < 500 then return end
	LAST_ITEM_ACTION = getTickCount()

	triggerServerEvent( "OnPlayerTryDropQuestItem", resourceRoot )
end

function OnClientPlayerWeaponSwitch( )
	toggleControl( "aim_weapon", false )
	toggleControl( "fire", false )
	cancelEvent()
end

function CleanUpQuestItemPickups( )
	for k,v in pairs( QUEST_ITEM_PICKUPS ) do
		DestroyQuestItemPickup( k )
	end

	QUEST_ITEM_PICKUPS = { }

	removeEventHandler( "onClientPreRender", root, PreRenderHoldedItems )
	
	for k,v in pairs( ATTACHED_ITEMS ) do
		if isElement( v ) then
			destroyElement( v )
		end
	end

	ATTACHED_ITEMS = { }
end

function StartItemMinigame( tid )
	StopItemMinigame( )

	toggleAllControls( false )

	minigame_tid = tid

	running_minigame = ibInfoPressKeyProgress( {
	    do_text = "Нажимай",
	    text = "чтобы забрать груз",
	    key = "mouse1",
	    click_count = 10,
	    black_bg = 0x80495f76,
	    end_handler = OnItemMinigameFinished,
	} )

	addEventHandler( "onClientPlayerWasted", localPlayer, StopItemMinigame )
end

function StopItemMinigame( )
	if running_minigame and running_minigame.destroy then
		running_minigame:destroy( )
	end

	minigame_tid = false

	removeEventHandler( "onClientPlayerWasted", localPlayer, StopItemMinigame )
	removeEventHandler( "onClientKey", root, DropItemKeyHandler )
	removeEventHandler( "onClientPlayerWeaponSwitch", root, OnClientPlayerWeaponSwitch )

	toggleAllControls( true )
end

function OnItemMinigameFinished( )
	triggerServerEvent( "OnPlayerTryPickupQuestItem", resourceRoot, minigame_tid )
	StopItemMinigame( )
end

function PreRenderHoldedItems( )
	for player, item in pairs( ATTACHED_ITEMS ) do
		if isElement( player ) and isElement( item ) then
			if isPedInVehicle( player ) then
				setElementAlpha( item, 0 )
			else
				setElementAlpha( item, 255 )
			end
		end
	end
end