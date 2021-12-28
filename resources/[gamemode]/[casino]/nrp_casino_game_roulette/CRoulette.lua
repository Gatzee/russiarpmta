loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CUI")
Extend("ib")

CASINO_VOLUME_MUL = 1

pGameData = {}
pAmbientSound = nil

scx, scy = guiGetScreenSize()

local confirmation

local blocked_controls = 
{
	"forwards",
	"backwards",
	"right",
	"left",
	"jump",
	"fire",
	"crouch",
}

function OnGameStarted( data )
	ToggleModelsReplace(true)

	for k,v in pairs(data) do
		pGameData[k] = v
	end

	pGameData.playing = true
	pGameData.casino_id = data.casino_id

	for k,v in pairs(blocked_controls) do
		toggleControl( v, false )
	end

	ShowUI_Game( true, data )
	CreateGun()

	addEventHandler("onClientKey", root, OnClientKey_handler)
	addEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)

	setPedWeaponSlot(localPlayer, 0)
end
addEvent("OnCasinoGameRouletteStarted", true)
addEventHandler("OnCasinoGameRouletteStarted", root, OnGameStarted)

function OnGameFinished( is_forced )
	ToggleModelsReplace(false)

	pGameData = {}

	localPlayer.frozen = false

	for k,v in pairs(blocked_controls) do
		toggleControl( v, true )
	end

	ShowUI_Game( false )
	DestroyGun()

	setCameraTarget(localPlayer)

	removeEventHandler("onClientKey", root, OnClientKey_handler)
	removeEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)

	if not is_forced then
		fadeCamera( false, 0 )
		setTimer(function()
			fadeCamera(true, 1)
			setCameraTarget(localPlayer)
		end, 500, 1)
	end
end
addEvent("OnCasinoGameRouletteFinished", true)
addEventHandler("OnCasinoGameRouletteFinished", root, OnGameFinished)

function OnTurnStarted( player, time_left )
	pGameData.turn_player = player
	pGameData.turn_started = getTickCount()

	UpdateTurnPlayer( player )
	
	if player == localPlayer then
		-- Показать элементы управления
		pGameData.my_turn = true
		pGameData.turn_made = false

		ShowHint( "Сейчас твоя очередь" )
		ShowShootHint( true )

		local sound = playSound("sfx/bell"..math.random(1,3)..".wav")
		setSoundVolume( sound, CASINO_VOLUME_MUL )
	end
end
addEvent("OnCasinoGameRouletteTurnStarted", true)
addEventHandler("OnCasinoGameRouletteTurnStarted", root, OnTurnStarted)

function OnTurnFinished( data )
	if data.player == localPlayer then
		ShowShootHint( false )
	end

	StartShot( data )

	if data.result then
		setTimer(function( data )
			UpdateScores( data )
		end, 4000, 1, data)
	end
end
addEvent("OnCasinoGameRouletteTurnFinished", true)
addEventHandler("OnCasinoGameRouletteTurnFinished", root, OnTurnFinished)

local locked_keys = 
{
	['tab'] = true,
	['q'] = true,
}

function OnClientKey_handler( key, state )
	if locked_keys[key] then 
		cancelEvent()
		return
	end

	if key == "mouse1" and state and not isCursorShowing() then
		cancelEvent()
		if pGameData.my_turn and not pGameData.turn_made then
			if getTickCount() - pGameData.turn_started <= 1500 then return end

			pGameData.turn_made = true
			triggerServerEvent("OnCasinoGameRouletteTurnMade", localPlayer)
		end
	elseif key == "escape" and state then
		cancelEvent()
		OnTryLeftGame()
	end
end

function OnTryLeftGame()
	if confirmation then confirmation:destroy() end
	showCursor( true )
	confirmation = ibConfirm({
		title = "ВЫХОД ИЗ ИГРЫ", 
		text = "Ты точно хочешь выйти из игры?\nТвоя ставка будет утеряна!",
		
		fn = function( self ) 
			self:destroy()
			triggerServerEvent( "onRouletteTableLeaveRequest", localPlayer, false, false, "exit" )
			showCursor(false)
		end,

		fn_cancel = function( self ) 
			showCursor( false ) 
		end,
	})
end

function OnClientPlayerWasted_handler()
	if source == localPlayer then
		triggerServerEvent( "onRouletteTableLeaveRequest", localPlayer, false, false, "wasted" )
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	if pGameData.playing then
		OnGameFinished( true )
	end
end)

function onSettingsChange_handler( changed, values )
	if changed.casinovolume then
		if values.casinovolume then
            CASINO_VOLUME_MUL = values.casinovolume
            if isElement(pAmbientSound) then
            	setSoundVolume(pAmbientSound, 0.3*CASINO_VOLUME_MUL)
            end
        end
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )
triggerEvent( "onSettingsUpdateRequest", localPlayer, "casinovolume" )