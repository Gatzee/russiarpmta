Extend("CInterior")
Extend("CPlayer")
Extend("ib")
Extend("ShUtils")

--local scx, scy = guiGetScreenSize()
local DANCING_PLAYERS = {}

function InteriorMarkersCreate()
	for _, config in pairs(LOCATIONS_LIST) do
		config.accepted_elements = { player = true }
		config.keypress = "lalt"
		config.radius = 2
		config.marker_text = "Изучить танцы"
		config.text = "ALT Взаимодействие"
		local school = TeleportPoint(config)
		school.element:setData("ignore_dist", true)
		school.marker:setColor(0,255,0,50)
		school.PostJoin = OnMarkerHit

		school.marker:setColor( 245, 128, 245, 10 )
		school.text = "ALT Взаимодействие"
		school:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.5 } )
	end
end

function OnMarkerHit( pMarker )
	triggerEvent( "DS:ShowUI", resourceRoot, true )
end

function DrawHint()
	--dxDrawRectangle( scx/2-200, scy-150, 400, 100, tocolor( 0, 0, 0, 160 ) )
	--dxDrawText( "Нажмите 'Пробел' чтобы прервать анимацию", scx/2-200, scy-150, scx/2+200, scy-50, 0xFFFFFFFF, 1, "default-bold", "center", "center" )
	if not getPedAnimation( localPlayer ) or isPedInVehicle( localPlayer ) then
		StopDancing()
	end
end

function StopDancing()
	removeEventHandler("onClientKey", root, KeyHandler)
	removeEventHandler("onClientRender", root, DrawHint)
	removeEventHandler("onClientPlayerDamage", localPlayer, StopDancing)
	toggleControl( "next_weapon", true )
	toggleControl( "previous_weapon", true )
	setPedAnimation( localPlayer, nil )

	triggerServerEvent( "OnPlayerStopDancing", resourceRoot, localPlayer )
end

function OnPlayerStartDancing( pPlayer, iDance )
	local pDanceData = DANCES_LIST[iDance]
	if pDanceData.rz then
		local rx, ry, rz = getElementRotation( pPlayer )
		setElementRotation( pPlayer, 0, 0, rz+pDanceData.rz)
	end
	setPedAnimation( pPlayer, nil )
	setPedAnimation( pPlayer, pDanceData.anim_data[1], pDanceData.anim_data[2], -1, pDanceData.is_looped or false, pDanceData.updatePosition or false, false, pDanceData.freeze_lf or false)
	setPedWeaponSlot( pPlayer, 0 )

	if pPlayer == localPlayer then
		if not DANCING_PLAYERS[pPlayer] then
			addEventHandler("onClientKey", root, KeyHandler)
			addEventHandler("onClientRender", root, DrawHint)
			addEventHandler("onClientPlayerDamage", localPlayer, StopDancing)
			toggleControl( "next_weapon", false )
			toggleControl( "previous_weapon", false )
		end
	else
		if not DANCING_PLAYERS[pPlayer] then
			addEventHandler("onClientPlayerQuit", pPlayer, OnPlayerStopDancing_handler)
			addEventHandler("onClientElementStreamOut", pPlayer, OnPlayerStopDancing_handler)
		end
	end

	local quest_data = localPlayer:getData( "is_dance_school_quest" )
	if quest_data and type( quest_data ) == "string" and pDanceData.name == "Танец 4" then
		triggerServerEvent( quest_data, localPlayer )
	end

	DANCING_PLAYERS[ pPlayer ] = true
end
addEvent("OnPlayerStartDancing", true)
addEventHandler("OnPlayerStartDancing", resourceRoot, OnPlayerStartDancing)

function KeyHandler( key, state )
	if isChatBoxInputActive() then return end

	local accepted_keys = 
	{
		w = true,
		s = true,
		a = true,
		d = true,
		space = true,
		lshift = true,
	}

	if state and accepted_keys[key] then
		StopDancing()
	end
end

function OnPlayerStopDancing_handler()
	OnPlayerStopDancing(source)
end

function OnPlayerStopDancing( pPlayer )
	if isElement(pPlayer) then
		setPedAnimation( pPlayer, nil )
	end
	removeEventHandler("onClientPlayerQuit", pPlayer, OnPlayerStopDancing_handler)
	removeEventHandler("onClientElementStreamOut", pPlayer, OnPlayerStopDancing_handler)
	DANCING_PLAYERS[ pPlayer ] = nil
end
addEvent("OnPlayerStopDancing", true)
addEventHandler("OnPlayerStopDancing", resourceRoot, OnPlayerStopDancing)

function LoadAnimations()
	engineLoadIFP("files/ifp/crack.ifp", "CUSTOM_BLOCK_1")
	engineLoadIFP("files/ifp/dancing.ifp", "CUSTOM_BLOCK_2")
	engineLoadIFP("files/ifp/fortnite.ifp", "CUSTOM_BLOCK_3")
	engineLoadIFP("files/ifp/parkour.ifp", "PARKOUR")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	LoadAnimations()
	InteriorMarkersCreate()
end)


addEventHandler("onClientResourceStop", resourceRoot, function()
	for k,v in pairs(DANCING_PLAYERS) do
		OnPlayerStopDancing(k)
	end
end)

function SaveUserPreset()
	local pUserPreset = localPlayer:getData("animations_preset") or {}

	local file = fileExists( PRESET_FILE_NAME ) and fileOpen( PRESET_FILE_NAME ) or fileCreate( PRESET_FILE_NAME )
	fileWrite(file, toJSON( pUserPreset ))
	fileClose(file)
end

function LoadUserPreset()
	PRESET_FILE_NAME = "preset" .. ( localPlayer:getData( "_srv" ) or { 1 } )[ 1 ] .. ".ini"
	if fileExists( "preset.ini" ) then
		fileRename( "preset.ini", PRESET_FILE_NAME )
	end

	local file = fileExists( PRESET_FILE_NAME ) and fileOpen( PRESET_FILE_NAME )
	if file then
		local sData = fileRead( file, file.size )
		local pData = FixTableKeys( fromJSON( sData ) )
		localPlayer:setData("animations_preset", pData, false)

		fileClose(file)
	end
end
addEvent( "onPlayerVerifyReadyToSpawn", true )
addEventHandler( "onPlayerVerifyReadyToSpawn", root, LoadUserPreset )