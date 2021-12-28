Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CInterior")
Extend("CUI")
Extend("ib")

FISHING_DATA = {}
FISHING_ZONES = {}

scx, scy = guiGetScreenSize()

local pAmbientSound

function OnClientResourceStart()
	for k,v in pairs( STORE_MARKERS ) do
		CreateFishingStore( v )
	end

	for k,v in pairs( COAST_ZONES ) do
		CreateFishingZone( v )
	end

	addEventHandler("onClientElementColShapeHit", localPlayer, OnPlayerFishingZoneHit)
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateFishingStore( config )
	config.text = "ALT Взаимодействие"
	config.keypress = "lalt"
	config.radius = config.radius or 2
	config.marker_text = "Рыболовный магазин"

	local store = TeleportPoint(config)
	store.marker:setColor(0,100,100,50)
	store:SetImage( "files/img/marker_fishing.png" )
	store.element:setData( "material", true, false )
    store:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

	store.PreJoin = function( store, player )
		return true
	end
	store.PostJoin = function(store) 
		triggerServerEvent( "OnPlayerRequestHobbyStoreUI", localPlayer, HOBBY_FISHING )  
	end
	store.PostLeave = function(store) 
		triggerEvent( "HobbyStore_ShowUI", localPlayer, false )
	end

	store.elements = {}
	store.elements.blip = Blip( config.x, config.y, config.z, 61, 2, 255, 0, 0, 255, 0, 300 )
end
 
function CreateFishingZone( config )
	local pZone = {}
	pZone.col = createColPolygon( unpack(config.zone) )
	pZone.blip = Blip( config.position, 61, 2, 255, 0, 0, 255, 0, 300 )
	FISHING_ZONES[pZone.col] = pZone
end

function OnPlayerFishingZoneHit( zone, dim )
	if FISHING_ZONES[zone] and dim then
		addEventHandler("onClientKey", root, FishingZoneKeyHandler)
		addEventHandler("onClientElementColShapeLeave", localPlayer, OnPlayerLeaveFishingZone)
		addEventHandler("onClientVehicleStartEnter", root, OnVehicleStartEnter)

		if not isPedInVehicle(localPlayer) then
			localPlayer:ShowInfo( "Ты вошёл в зону рыбалки" )
		end

		pAmbientSound = playSound( "files/sounds/ambient_waves.mp3", true )
		setSoundVolume(pAmbientSound, 0.05)
		triggerEvent("ShowHobbiesInfo", localPlayer, "fishing")
	end
end

function OnPlayerLeaveFishingZone( zone )
	if FISHING_ZONES[zone] then
		if FISHING_DATA.rod then
			localPlayer:ShowInfo( "Ты ушёл далеко от берега" )
			triggerServerEvent("OnPlayerEndFishing", localPlayer, localPlayer)
		end

		removeEventHandler("onClientKey", root, FishingZoneKeyHandler)
		removeEventHandler("onClientElementColShapeLeave", localPlayer, OnPlayerLeaveFishingZone)
		removeEventHandler("onClientVehicleStartEnter", root, OnVehicleStartEnter)
		triggerEvent("HideHobbiesInfo", localPlayer)

		if isElement(pAmbientSound) then destroyElement( pAmbientSound ) end
		if isElement(FISHING_DATA.sfx) then destroyElement( FISHING_DATA.sfx ) end
	end
end

local disabled_controls = 
{
	"next_weapon", -- doest not work
	"previous_weapon", -- does not work
	"aim_weapon",
	"fire",
	"action",
	"enter_exit",
	"jump",
	"sprint",
	"enter_passenger",
}

local disabled_keys = 
{
	["1"] = true,
	["tab"] = true,
	["p"] = true,
}

function OnPlayerStartFishing( data )
	playSound( "files/sounds/rod_take.wav" )
	for k,v in pairs(data) do
		FISHING_DATA[k] = v
	end

	FISHING_DATA.rod = true
	FISHING_DATA.fishing = false

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end

	addEventHandler("onClientKey", root, FishingKeyHandler)
	addEventHandler( "onClientPlayerWeaponSwitch", localPlayer, disableWeaponSwitch )

	setPedWeaponSlot( localPlayer, 0 )
	ToggleFishingHUD( true )
	triggerEvent( "ShowUIInventory", root, false )
end
addEvent("OnPlayerStartFishing", true)
addEventHandler("OnPlayerStartFishing", resourceRoot, OnPlayerStartFishing)

function OnPlayerUpdateFishing( item_uid )
	FISHING_DATA.item_uid = item_uid
end
addEvent("OnPlayerUpdateFishing", true)
addEventHandler("OnPlayerUpdateFishing", resourceRoot, OnPlayerUpdateFishing)

function OnPlayerStopFishing()
	playSound( "files/sounds/rod_hide.wav" )

	setPedAnimation(localPlayer, nil)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end
	
	ToggleFishingHUD( false )

	removeEventHandler("onClientKey", root, FishingKeyHandler)
	removeEventHandler("onClientRender", root, RenderThrowZone)
	removeEventHandler( "onClientPlayerWeaponSwitch", localPlayer, disableWeaponSwitch )

	if isElement(pAmbientSound) then
		destroyElement( pAmbientSound )
	end

	if isElement(FISHING_DATA.sfx) then 
		destroyElement( FISHING_DATA.sfx ) 
	end

	FISHING_DATA.rod = false
	FISHING_DATA.fishing = false
end
addEvent("OnPlayerStopFishing", true)
addEventHandler("OnPlayerStopFishing", resourceRoot, OnPlayerStopFishing)

function OnVehicleStartEnter( pPlayer )
	if pPlayer == localPlayer then
		FISHING_DATA.last_rod_request = getTickCount()
	end
end

function FishingKeyHandler( key, state )
	if disabled_keys[key] then
		cancelEvent()
		return
	end

	if not FISHING_DATA.fishing then
		if key == "mouse2" and not isCursorShowing() then
			ToggleRenderThrowZone( state )
		elseif key == "mouse1" and state then
			if getKeyState("mouse2") then
				if FISHING_DATA.last_rod_request and getTickCount() - FISHING_DATA.last_rod_request <= 3000 then return end

				local px, py, pz = getElementPosition(localPlayer)
				local iWaterLevel = getWaterLevel( px, py, pz ) or 0

				if isElementInWater( localPlayer ) or not isPedOnGround( localPlayer ) or pz - iWaterLevel <= 1 then
					localPlayer:ShowError("Выйди из воды")
					return false
				end

				ThrowFishingRod()
			end
		end
	end
end

function FishingZoneKeyHandler( key, state )
	if key == "lalt" and state then
		if isCursorShowing() then return end
		if isChatBoxInputActive() then return end

		if FISHING_DATA.last_rod_request and getTickCount() - FISHING_DATA.last_rod_request <= 3000 then return end

		if isPedInVehicle(localPlayer) then
			localPlayer:ShowError("Нужно выйти из машины")
			return false
		end

		if getControlState( "aim_weapon" ) then
			return false
		end

		if isElementInWater( localPlayer ) then
			localPlayer:ShowError("Выйди из воды")
			return false
		end

		if not FISHING_DATA.fishing then
			triggerServerEvent("OnPlayerHitFishingMarker", localPlayer)
		end

		FISHING_DATA.last_rod_request = getTickCount()
	end
end

function ThrowFishingRod()
	local tx, ty, tz = GetAimTargetPosition()
	local hit, _, _, z = processLineOfSight( tx, ty, tz + 50, tx, ty, tz - 10 )

	if not tz or not hit then return end

	if z >= tz then
		localPlayer:ShowError("Закидывать нужно в воду")
		return false
	end

	FISHING_DATA.last_rod_request = getTickCount()

	FISHING_DATA.sfx = playSound( "files/sounds/sfx_throw.wav" )
	setSoundVolume( FISHING_DATA.sfx, 1 )

	removeEventHandler("onClientRender", root, RenderThrowZone)
	setPedAnimation( localPlayer, "chainsaw", "csaw_1", -1, false, false, false, false )
	setTimer(function()
		SwitchFishingMinigame( true )
		FISHING_DATA.floater = createObject( 755, tx, ty, tz )
		FISHING_DATA.floater_z = tz

		local px, py = getElementPosition(localPlayer)
		local rz = -math.deg( math.atan2( tx - px, ty - py ) )
		setElementRotation(localPlayer, 0, 0, rz)
	end, 1000, 1)
end

function SwitchFishingMinigame( state, is_win )
	if state then
		local pEquipment = localPlayer:GetHobbyEquipment()
		local pFoundBait
		for k,v in pairs(pEquipment) do
			if v.class == "fishing:bait" and v.amount >= 1 then
				if pFoundBait then
					if pFoundBait.id < v.id then
						pFoundBait = v
					end
				else
					pFoundBait = v
				end
			end
		end

		FISHING_DATA.fishing = true
		FISHING_DATA.used_bait = pFoundBait

		local controls = { "forwards", "backwards", "left", "right" }
		for k,v in pairs(controls) do
			setPedControlState( localPlayer, v, false )
		end

		StartMinigame()
		setPedAnimation( localPlayer, "sword", "sword_idle", -1, false, true, false, true )
	else
		FISHING_DATA.fishing = false
		StopMinigame( is_win )
	end
end

function disableWeaponSwitch( _, slot )
	if slot ~= 0 then
		cancelEvent( )
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	OnPlayerStopFishing()
end)