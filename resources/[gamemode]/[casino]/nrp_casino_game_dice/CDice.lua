loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CUI")
Extend("ib")

pGameData = {}

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

	if pGameData.turn_player then
		UpdateGameUI( { turn_player = pGameData.turn_player, time_left = 15 } )
	end

	addEventHandler("onClientKey", root, OnClientKey_handler)
	addEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)
end
addEvent("OnCasinoGameDiceStarted", true)
addEventHandler("OnCasinoGameDiceStarted", root, OnGameStarted)

function OnGameFinished( is_forced )
	ToggleModelsReplace(false)

	pGameData = {}

	localPlayer.frozen = false

	for k,v in pairs(blocked_controls) do
		toggleControl( v, true )
	end

	ShowUI_Game( false )

	setCameraTarget(localPlayer)

	removeEventHandler("onClientKey", root, OnClientKey_handler)
	removeEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)

	if not is_forced then
		fadeCamera( false, 0 )
		setTimer(function()
			fadeCamera(true, 1)
			setCameraTarget(localPlayer)
		end, 300, 1)
	end
end
addEvent("OnCasinoGameDiceFinished", true)
addEventHandler("OnCasinoGameDiceFinished", root, OnGameFinished)

function OnTurnStarted( player, time_left )
	pGameData.turn_player = player
	pGameData.turn_started = getTickCount()
	
	if player == localPlayer then
		-- Показать элементы управления
		pGameData.my_turn = true
		pGameData.turn_made = false

		ShowHint( "Сейчас твой ход" )
		ShowThrowHint( true )

		playSound("sfx/yourturn.ogg")
	end

	UpdateGameUI( { turn_player = player, time_left = 15 } )
end
addEvent("OnCasinoGameDiceTurnStarted", true)
addEventHandler("OnCasinoGameDiceTurnStarted", root, OnTurnStarted)

function OnTurnFinished( data )
	if data.player == localPlayer then
		ShowThrowHint( false )
		pGameData.my_turn = false
	end

	ThrowDices( data )

	setTimer(function( data )
		UpdatePlayerScore( data.player, data.round, data.result[1]+data.result[2] )
	end, 4000, 1, data)
end
addEvent("OnCasinoGameDiceTurnFinished", true)
addEventHandler("OnCasinoGameDiceTurnFinished", root, OnTurnFinished)

function OnRoundStarted( round )
	ShowHint( "Начался раунд "..round )
end
addEvent("OnCasinoGameDiceRoundStarted", true)
addEventHandler("OnCasinoGameDiceRoundStarted", root, OnRoundStarted)

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

	if key == "space" and state then
		cancelEvent()
		if pGameData.my_turn and not pGameData.turn_made then
			if getTickCount() - pGameData.turn_started <= 1800 then return end

			pGameData.turn_made = true
			pGameData.my_turn = false
			triggerServerEvent("OnCasinoGameDiceTurnMade", localPlayer)
		end
	elseif key == "lctrl" then
		cancelEvent()
		SwitchScoreTable()
	elseif key == "escape" and state then
		cancelEvent()
		OnTryLeftGame()
	end
end

function OnTryLeftGame()
	if confirmation then confirmation:destroy() end
	
	showCursor(true)
	confirmation = ibConfirm({
		title = "ВЫХОД ИЗ ИГРЫ", 
		text = "Ты точно хочешь выйти из игры?\nТвоя ставка будет утеряна!",
		fn = function( self ) 
			self:destroy()
			triggerServerEvent( "onDiceTableLeaveRequest", localPlayer, _, _, true, "exit" )
			showCursor(false)
		end,

		fn_cancel = function( self ) 
			showCursor( false ) 
		end,
	})
end

function OnClientPlayerWasted_handler()
	if source == localPlayer then
		triggerServerEvent( "onDiceTableLeaveRequest", localPlayer, _, _, true, "wasted" )
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	if pGameData.playing then
		OnGameFinished( true )
	end
end)

function OnClientDicesWon_handler()
	playSound( ":nrp_shop/sfx/reward_small.mp3" )
end
addEvent("OnClientDicesWon", true)
addEventHandler("OnClientDicesWon", root, OnClientDicesWon_handler)