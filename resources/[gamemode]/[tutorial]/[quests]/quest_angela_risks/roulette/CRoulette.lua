loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CUI")
Extend("ib")

local CASINO_VOLUME_MUL = 1

local pRouletteData = {}
local pAmbientSound = nil

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

function OnRouletteGameStart( data )
	ToggleRouletteModelsReplace(true)

	for k,v in pairs(data) do
		pRouletteData[k] = v
	end

	pRouletteData.playing = true

	for k,v in pairs(blocked_controls) do
		toggleControl( v, false )
	end

	ShowRouletteUI( true, data )
	CreateGun()

	addEventHandler("onClientKey", root, OnClientKey_rouletteHandler)

	setPedWeaponSlot(localPlayer, 0)
end

function OnRouletteGameFinished( is_forced )
	ToggleRouletteModelsReplace(false)

	pRouletteData = {}

	localPlayer.frozen = false

	for k,v in pairs(blocked_controls) do
		toggleControl( v, true )
	end

	ShowRouletteUI( false )
	DestroyGun()

	setCameraTarget(localPlayer)

	removeEventHandler("onClientKey", root, OnClientKey_rouletteHandler)

	if not is_forced then
		fadeCamera( false, 0 )
		setTimer(function()
			fadeCamera(true, 1)
			setCameraTarget(localPlayer)
		end, 500, 1)
	end
end

function OnRouletteTurnStarted( player, time_left )
	pRouletteData.turn_player = player
	pRouletteData.turn_started = getTickCount()

	UpdateRouletteTurnPlayer( player )
	
	if player == localPlayer then
		-- Показать элементы управления
		pRouletteData.my_turn = true
		pRouletteData.turn_made = false

		ShowRouletteHint( "Сейчас твоя очередь" )
		ShowShootHint( true )

		local sound = playSound(":nrp_casino_game_roulette/sfx/bell"..math.random(1,3)..".wav")
		setSoundVolume( sound, CASINO_VOLUME_MUL )
	end
end

function OnRouletteTurnFinished( data )
	if data.player == localPlayer then
		ShowShootHint( false )
	end

	StartShot( data )

	if data.result then
		setTimer(function( data )
			UpdateRouletteScores( data )
		end, 4000, 1, data)
	end
end

local locked_keys = 
{
	['tab'] = true,
	['q'] = true,
}

addEvent( "OnCasinoGameRouletteFakeTurnMade" )
function OnClientKey_rouletteHandler( key, state )
	if locked_keys[key] then 
		cancelEvent()
		return
	end

	if key == "mouse1" and state and not isCursorShowing() then
		cancelEvent()
		if pRouletteData.my_turn and not pRouletteData.turn_made then
			if getTickCount() - pRouletteData.turn_started <= 1500 then return end

			pRouletteData.turn_made = true
			triggerEvent( "OnCasinoGameRouletteFakeTurnMade", localPlayer )
			--triggerServerEvent("OnCasinoGameRouletteTurnMade", localPlayer)

		end
	elseif key == "escape" and state then
		cancelEvent()
		localPlayer:ShowError( "Трус не стреляет в бошку!" )
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	if pRouletteData.playing then
		OnRouletteGameFinished( true )
	end
end)