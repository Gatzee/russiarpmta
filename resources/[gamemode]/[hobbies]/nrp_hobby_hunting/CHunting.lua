Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CInterior")
Extend("CUI")
Extend("ib")

scx, scy = guiGetScreenSize()

pAmbientSound = false

HUNTING_DATA = {}
HUNTING_ZONES = {}

local iCurrentZone = 1
local pNextAnimalTimer
local pConfirmation = nil

function OnClientResourceStart()
	for k,v in pairs( STORE_MARKERS ) do
		CreateHuntingStore( v )
	end

	for k,v in pairs( HUNTING_ZONES_LIST ) do
		v.element = CreateHuntingZone( v, k ).col
	end

	addEventHandler("onClientElementColShapeHit", localPlayer, OnPlayerHuntingZoneHit)
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateHuntingStore( config )
	config.text = "ALT Взаимодействие"
	config.keypress = "lalt"
	config.radius = config.radius or 2
	config.marker_text = "Охотничий магазин"

	local store = TeleportPoint(config)
	store.marker:setColor(255, 121, 38, 50)
	store:SetImage( "files/img/marker_hunting.png" )
	store.element:setData( "material", true, false )
    store:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

	store.PreJoin = function( store, player )
		return true
	end
	store.PostJoin = function(store) 
		triggerServerEvent( "OnPlayerRequestHobbyStoreUI", localPlayer, HOBBY_HUNTING )   
	end
	store.PostLeave = function(store) 
		triggerEvent( "HobbyStore_ShowUI", localPlayer, false )
	end

	store.elements = {}
	store.elements.blip = Blip( config.x, config.y, config.z, 59, 2, 255, 0, 0, 255, 0, 300 )
end
 
function CreateHuntingZone( config, id )
	local pZone = {}
	pZone.dimension = 0
	pZone.col = createColPolygon( unpack(config.zone) )
	pZone.blip = Blip( config.position, 59, 2, 255, 0, 0, 255, 0, 300 )
	pZone.id = id
	HUNTING_ZONES[pZone.col] = pZone

	return pZone
end

function OnPlayerHuntingZoneHit( zone, dim )
	if dim and HUNTING_ZONES[zone] then
		iCurrentZone = HUNTING_ZONES[zone].id
		addEventHandler("onClientKey", root, HuntingZoneKeyHandler)
		addEventHandler("onClientElementColShapeLeave", localPlayer, OnPlayerLeaveHuntingZone)
		addEventHandler("onClientVehicleStartEnter", root, OnVehicleStartEnter)

		if not isPedInVehicle(localPlayer) then
			localPlayer:ShowInfo( "Ты вошёл в охотничьи угодья" )
		end

		--pAmbientSound = playSound( "files/sounds/ambient_waves.mp3", true )
		--setSoundVolume(pAmbientSound, 0.05)
		triggerEvent("ShowHobbiesInfo", localPlayer, "hunting")
	end
end

function OnPlayerLeaveHuntingZone( zone, dim )
	if HUNTING_ZONES[zone] then
		if HUNTING_DATA.hunting then
			if HUNTING_DATA.client_animal_data and HUNTING_DATA.client_animal_data.bDead then
				return
			else
				localPlayer:ShowInfo( "Ты покинул охотничьи угодья" )
				triggerServerEvent("OnPlayerEndHunting", localPlayer, localPlayer)
			end
		end

		removeEventHandler("onClientKey", root, HuntingZoneKeyHandler)
		removeEventHandler("onClientElementColShapeLeave", localPlayer, OnPlayerLeaveHuntingZone)
		removeEventHandler("onClientVehicleStartEnter", root, OnVehicleStartEnter)
		triggerEvent("HideHobbiesInfo", localPlayer)

		if isElement(pAmbientSound) then destroyElement( pAmbientSound ) end
		if isElement(HUNTING_DATA.sfx) then destroyElement( HUNTING_DATA.sfx ) end

		if pConfirmation then
			showCursor( false )
			pConfirmation:destroy( )
		end
	end
end

function HuntingZoneKeyHandler( key, state )
	if key == "h" and state then
		if not HUNTING_DATA.hunting and localPlayer.dimension ~= 0 then return end
		if isCursorShowing() then return end
		if isChatBoxInputActive() then return end

		if HUNTING_DATA.is_harvesting then return end
		if HUNTING_DATA.last_rifle_request and getTickCount() - HUNTING_DATA.last_rifle_request <= 3000 then return end

		if isPedInVehicle(localPlayer) then
			localPlayer:ShowError("Нужно выйти из машины")
			return false
		end

		if not HUNTING_DATA.hunting then
			local pItems = localPlayer:GetHobbyItems()
			local fBackpackSize = localPlayer:GetHobbyBackpackSize()

			local fUsedBackpackSpace = 0
			for k,v in pairs( pItems[HOBBY_HUNTING] or {} ) do
				fUsedBackpackSpace = fUsedBackpackSpace + v.weight
			end

			if fBackpackSize <= fUsedBackpackSpace then
				localPlayer:ShowError("Сначала продай добычу, твой рюкзак переполнен")
				return false
			end

			if HUNTING_DATA.zone_left and getTickCount() - HUNTING_DATA.zone_left <= 60000 then
				local iTimeLeft = 60 - math.floor( (getTickCount() - HUNTING_DATA.zone_left) / 1000 )
				localPlayer:ShowError("Ты ведь только вышел из угодий, отдохни ("..iTimeLeft.."с.)")
				return false
			end
		end

		if pConfirmation then pConfirmation:destroy( ) end

		showCursor( true )
		pConfirmation = ibConfirm(
				{
					title = "ОХОТНИЧЬИ УГОДЬЯ",
					text = HUNTING_DATA.hunting and "Ты хочешь покинуть охотничьи угодья?" or "Ты хочешь войти в охотничьи угодья?",
					fn = function( self )
						self:destroy()
						showCursor( false )
						pConfirmation = nil
						if ( not HUNTING_DATA.hunting and localPlayer.dimension == 0 ) or HUNTING_DATA.hunting then
							triggerServerEvent("OnPlayerHitHuntingMarker", localPlayer, iCurrentZone)
						end
					end,
					fn_cancel = function( self )
						self:destroy( )
						pConfirmation = nil
						showCursor( false )
					end,
				    escape_close = true,
				}
		)

		triggerEvent("ShowPhoneUI", localPlayer, false)

		--triggerServerEvent("OnPlayerHitHuntingMarker", localPlayer, iCurrentZone)
		HUNTING_DATA.last_rifle_request = getTickCount()
	end
end

function OnVehicleStartEnter( pPlayer )
	if pPlayer == localPlayer then
		HUNTING_DATA.last_rifle_request = getTickCount( )

		if pConfirmation then
			showCursor( false )
			pConfirmation:destroy( )
		end
	end
end

local disabled_controls = 
{
	--"aim_weapon",
	--"fire",
	"action",
	"enter_exit",
	--"jump",
	--"sprint",
	"enter_passenger",
	"next_weapon",
	"previous_weapon",
}

local disabled_keys = 
{
	["1"] = true,
	["tab"] = true,
	["p"] = true,
}

function OnPlayerStartHunting( data )
	for k,v in pairs(data) do
		HUNTING_DATA[k] = v
	end

	HUNTING_DATA.hunting = true
	HUNTING_DATA.is_harvesting = false

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end

	ToggleHuntingHUD( true )

	CreateAnimal(HUNTING_DATA.animal_data, HUNTING_DATA.zone_id)

	addEventHandler("onClientKey", root, HuntingKeyHandler)
	addEventHandler("onClientPlayerWeaponFire", localPlayer, OnClientRifleFire)
	addEventHandler("onClientElementColShapeHit", localPlayer, OnPlayerCorpseColHit)

	triggerEvent("ShowPhoneUI", localPlayer, false)
	triggerEvent( "ShowUIInventory", root, false )
end
addEvent("OnPlayerStartHunting", true)
addEventHandler("OnPlayerStartHunting", root, OnPlayerStartHunting)

function OnPlayerStopHunting()
	HUNTING_DATA.hunting = false
	HUNTING_DATA.is_harvesting = false
	HUNTING_DATA.zone_left = getTickCount()

	if isElement(HUNTING_DATA.sound) then destroyElement( HUNTING_DATA.sound ) end

	removeEventHandler("onClientKey", root, HuntingKeyHandler)
	removeEventHandler("onClientPlayerWeaponFire", localPlayer, OnClientRifleFire)
	removeEventHandler("onClientElementColShapeHit", localPlayer, OnPlayerCorpseColHit)

	if isTimer(pNextAnimalTimer) then killTimer(pNextAnimalTimer) end

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end
	
	ToggleHuntingHUD( false )

	DestroyAnimal()
end
addEvent("OnPlayerStopHunting", true)
addEventHandler("OnPlayerStopHunting", root, OnPlayerStopHunting)

function HuntingKeyHandler( key, state )
	if disabled_keys[key] then
		cancelEvent()
		return
	end
end

function OnClientRifleFire()
	local hit = RifleShoot()

	if hit then
		DamageAnimal( hit )
	end

	local fDistance = ( localPlayer.position - HUNTING_DATA.animal.position ).length
	if fDistance <= 80 then
		SetAnimalScared( true )
	end
end

function OnAnimalDamage()
	cancelEvent()
end

function DamageAnimal( sBodypart )
	if sBodypart == "head" then -- Headshot
		UpdateAnimalAction( 1, true )
	else
		local pEquipment = localPlayer:GetHobbyEquipment()
		local pFoundAmmo
		for k,v in pairs(pEquipment) do
			if v.class == "hunting:ammo" and v.amount >= 1 then
				if pFoundAmmo then
					if pFoundAmmo.id < v.id then
						pFoundAmmo = v
					end
				else
					pFoundAmmo = v
				end
			end
		end

		local fMultiplier = pFoundAmmo and pFoundAmmo.id*10 or 10

		local rand = math.random(0, 100)
		if rand <= fMultiplier or HUNTING_DATA.animal.health <= 51 then
			UpdateAnimalAction( 1, true )
		else
			HUNTING_DATA.animal.health = HUNTING_DATA.animal.health - 50
			localPlayer:ShowInfo("Ты ранил животное")

			SetAnimalScared( true )
		end
	end
end


function OnPlayerCorpseColHit( col )
	if isElement(HUNTING_DATA.corpse_col) and col == HUNTING_DATA.corpse_col then
		setElementFrozen(localPlayer, true)
		ibInfoPressKey( {
			text = "чтобы освежевать добычу";
			key = "f";

			key_handler = function( )
				StartHarvesting()
			end;
		} )
	end
end

function StartHarvesting()
	setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, true, false )
	HUNTING_DATA.is_harvesting = true

	HUNTING_DATA.sound = playSound( "files/sounds/slicing.ogg" )

	ShowHarvestProgress( 8000 )
end

function FinishHarvesting()
	triggerServerEvent("OnPlayerHarvested", resourceRoot, HUNTING_DATA.item_uid )

	setPedAnimation( localPlayer, nil )
	setElementFrozen( localPlayer, false )

	if isElement(HUNTING_DATA.sound) then destroyElement( HUNTING_DATA.sound ) end

	if not isElementWithinColShape( localPlayer, HUNTING_ZONES_LIST[ HUNTING_DATA.zone_id ].element ) then
		localPlayer:ShowInfo( "Ты покинул охотничьи угодья" )
		triggerServerEvent("OnPlayerEndHunting", localPlayer, localPlayer)

		removeEventHandler("onClientKey", root, HuntingZoneKeyHandler)
		removeEventHandler("onClientElementColShapeLeave", localPlayer, OnPlayerLeaveHuntingZone)
		removeEventHandler("onClientVehicleStartEnter", root, OnVehicleStartEnter)
		triggerEvent("HideHobbiesInfo", localPlayer)

		if isElement(pAmbientSound) then destroyElement( pAmbientSound ) end
		if isElement(HUNTING_DATA.sfx) then destroyElement( HUNTING_DATA.sfx ) end

		if pConfirmation then
			showCursor( false )
			pConfirmation:destroy( )
		end
	end
end

function OnNextAnimalRequested( pAnimal, item_uid )
	HUNTING_DATA.animal_data = pAnimal
	HUNTING_DATA.item_uid = item_uid
	DestroyAnimal()

	HUNTING_DATA.is_harvesting = false

	pNextAnimalTimer = setTimer(function()
		CreateAnimal( HUNTING_DATA.animal_data, iCurrentZone )
	end, math.random(3000, 6000), 1 )
end
addEvent("OnNextAnimalRequested", true)
addEventHandler("OnNextAnimalRequested", root, OnNextAnimalRequested)

function onClientRaceWindowShow_handler( )
	if pConfirmation then
		showCursor( false )
		pConfirmation:destroy( )
	end
end
addEvent( "onClientRaceWindowShow", true )
addEventHandler( "onClientRaceWindowShow", root, onClientRaceWindowShow_handler )