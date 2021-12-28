Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CInterior")
Extend("CUI")
Extend("ib")

scx, scy = guiGetScreenSize()

DIGGING_DATA = {}

function OnClientResourceStart()
	for k,v in pairs( STORE_MARKERS ) do
		CreateDiggingStore( v )
	end
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateDiggingStore( config )
	config.text = "ALT Взаимодействие"
	config.keypress = "lalt"
	config.radius = config.radius or 2
	config.marker_text = "Лавка кладоискателя"

	local store = TeleportPoint(config)
	store.marker:setColor(0,100,100,50)
	store:SetImage( "files/img/marker_digging.png" )
	store.element:setData( "material", true, false )
    store:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

	store.PreJoin = function( store, player )
		return true
	end
	store.PostJoin = function(store) 
		triggerServerEvent( "OnPlayerRequestHobbyStoreUI", localPlayer, HOBBY_DIGGING )  
	end
	store.PostLeave = function(store) 
		triggerEvent( "HobbyStore_ShowUI", localPlayer, false )
	end

	store.elements = {}
	store.elements.blip = Blip( config.x, config.y, config.z, 60, 2, 255, 0, 0, 255, 0, 300 )
end
    
function OnDiggingLocationReceived( location_id )
	local location_id = tonumber(location_id) or 1
	local pData = TREASURE_LOCATIONS_LIST[ location_id ]
	local vecCenterBias = Vector3( pData.x, pData.y, pData.z ):AddRandomRange( 30 )

	DIGGING_DATA.location_id = location_id

	DIGGING_DATA.t_col = createColSphere( pData.x, pData.y, pData.z, pData.size or 4 )
	DIGGING_DATA.zone_col = createColSphere( vecCenterBias, 60 )
	if getDistanceBetweenPoints3D( localPlayer.position, vecCenterBias ) > 8 then
		DIGGING_DATA.zone_pre_enter = createColSphere( vecCenterBias, 6 )
		DIGGING_DATA.vecCenterBias = vecCenterBias
	else
		vecCenterBias.z = localPlayer.position.z
	end
	triggerEvent( "ToggleGPS", localPlayer, vecCenterBias )
	DIGGING_DATA.zone_blip = createBlip( vecCenterBias, 38 )
	setBlipSize( DIGGING_DATA.zone_blip, 5 )

	addEventHandler( "onClientColShapeHit", DIGGING_DATA.zone_pre_enter, onClientLocationPreEnter )
	addEventHandler( "onClientColShapeHit", DIGGING_DATA.zone_col, OnClientLocationSphereHit )
	addEventHandler( "onClientColShapeLeave", DIGGING_DATA.zone_col, OnClientLocationSphereLeave )
	addEventHandler( "onClientElementDestroy", DIGGING_DATA.zone_col, OnDiggingZoneDestroy )
end
addEvent( "OnDiggingLocationReceived", true )
addEventHandler( "OnDiggingLocationReceived", resourceRoot, OnDiggingLocationReceived )

function onClientLocationPreEnter( pPlayer, dim )
	if pPlayer ~= localPlayer or not dim then return end

	destroyElement( source )
	local vecCenterBias = DIGGING_DATA.vecCenterBias
	vecCenterBias.z = localPlayer.position.z
	triggerEvent( "ToggleGPS", localPlayer, vecCenterBias )
end

function OnClientLocationSphereHit( pPlayer, dim )
	if pPlayer ~= localPlayer then return end
	if not dim then return end


	triggerEvent("ShowHobbiesInfo", localPlayer, "digging")
	addEventHandler("onClientKey", root, DiggingZoneKeyHandler)
end

function OnClientLocationSphereLeave( pPlayer, dim )
	if pPlayer ~= localPlayer then return end

	triggerEvent("HideHobbiesInfo", localPlayer)
	if DIGGING_DATA.shovel then
		localPlayer:ShowInfo( "Ты покинул зону поисков" )
		triggerServerEvent("OnPlayerEndDigging", localPlayer, localPlayer)
	end

	removeEventHandler("onClientKey", root, DiggingZoneKeyHandler)
end

function OnDiggingZoneDestroy()
	triggerEvent("HideHobbiesInfo", localPlayer)
	removeEventHandler("onClientKey", root, DiggingZoneKeyHandler)
end

function DiggingZoneKeyHandler( key, state )
	if key == "h" and state then
		if isCursorShowing() then return end
		if isChatBoxInputActive() then return end

		if DIGGING_DATA.last_shovel_request and getTickCount() - DIGGING_DATA.last_shovel_request <= 3000 then return end

		if isPedInVehicle(localPlayer) then
			localPlayer:ShowError("Нужно выйти из машины")
			return false
		end

		if getControlState( "aim_weapon" ) then
			return false
		end

		if not DIGGING_DATA.digging then
			triggerServerEvent("OnPlayerHitDiggingMarker", localPlayer)
		end

		DIGGING_DATA.last_shovel_request = getTickCount()
	end
end

function DiggingKeyHandler( key, state )
	if state and key == "mouse1" then
		cancelEvent()

		if not DIGGING_DATA.digging then
			if isCursorShowing() then return end
			if isChatBoxInputActive() then return end

			local fBackpackSize = localPlayer:GetHobbyBackpackSize()
			local pItems = localPlayer:GetHobbyItems()

			local fUsedBackpackSpace = 0
			for k,v in pairs( pItems[HOBBY_DIGGING] or {} ) do
				fUsedBackpackSpace = fUsedBackpackSpace + v.weight
			end

			if fUsedBackpackSpace >= fBackpackSize then
				localPlayer:ShowError("Твой рюкзак переполнен!")
				return
			end

			StartDiggingMinigame()
		end
	end

	if key == "mouse2" then
		if isCursorShowing() then return end
		if isChatBoxInputActive() then return end

		cancelEvent()
		if state then
			if not DIGGING_DATA.digging then
				ShowUI_Map( true, { map_id = DIGGING_DATA.location_id, no_cursor = true } )
			end
		else
			ShowUI_Map( false )
		end
	end
end

local disabled_controls = 
{
	"aim_weapon",
	"fire",
	"action",
	"enter_exit",
	"jump",
	"sprint",
	"enter_passenger",
}

function OnPlayerStartDigging( data )
	for k,v in pairs(data) do
		DIGGING_DATA[k] = v
	end

	DIGGING_DATA.shovel = true
	DIGGING_DATA.digging = false

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end

	addEventHandler("onClientKey", root, DiggingKeyHandler)

	setPedWeaponSlot( localPlayer, 0 )
	ToggleDiggingHUD( true )
end
addEvent("OnPlayerStartDigging", true)
addEventHandler("OnPlayerStartDigging", resourceRoot, OnPlayerStartDigging)

function OnPlayerStopDigging( bFinished )
	setPedAnimation(localPlayer, nil)

	if DIGGING_DATA.digging then
		StopDiggingMinigame()
	end

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end
	
	ToggleDiggingHUD( false )
	ShowUI_Map( false )

	removeEventHandler("onClientKey", root, DiggingKeyHandler)

	if bFinished then
		for k,v in pairs(DIGGING_DATA) do
			if isElement(v) then
				destroyElement( v )
			end
		end
	end

	DIGGING_DATA.shovel = false
	DIGGING_DATA.digging = false
end
addEvent("OnPlayerStopDigging", true)
addEventHandler("OnPlayerStopDigging", resourceRoot, OnPlayerStopDigging)