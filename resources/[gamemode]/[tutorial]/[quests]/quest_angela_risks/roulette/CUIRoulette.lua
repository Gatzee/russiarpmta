local scx, scy = guiGetScreenSize()
local ui = {}

local temp_scores = {}

function ShowRouletteUI( state, data )
	if state then
		ibUseRealFonts( true )

		fadeCamera( false, 0 )
		setTimer(function()
			fadeCamera(true, 2)
			setCameraTarget(localPlayer)
		end, 200, 1)

		ShowRouletteUI( false )
		triggerEvent("ShowPhoneUI", localPlayer, false)
		triggerEvent( "ShowInventoryHotbar", localPlayer, false )

		temp_scores = {}
		if data.players then
			for k,v in pairs(data.players) do
				local name = v:GetNickName()
				local visible_name = utf8.len(name) <= 13 and name or utf8.sub(name, 1, 12).."..."
				table.insert( temp_scores, { player = v, name = visible_name, state = 0, is_dead = 0 } )
			end
		end

		pAmbientSound = playSound( ":nrp_casino_game_roulette/sfx/bg1.ogg",true )
		setSoundVolume(pAmbientSound, 0.3)

		--showPlayerHudComponent( "radar", false )

		-- Таблица игроков
		ui.scores_bg = ibCreateImage( scx-200, scy/2-150, 200, 300, nil, false, 0x00000000 ):ibData("alpha", 0):ibAlphaTo(255, 1000)

		local px, py = 10, 0
		for i, v in pairs(temp_scores) do
			ui["player_bg"..i] = ibCreateImage( px, py, 180, 50, ":nrp_casino_game_roulette/img/bg_user.png", ui.scores_bg)
			ui["player_name"..i] = ibCreateLabel( 50, 0, 130, 28, v.name, ui["player_bg"..i], 0xFFFFFFFF, 1, 1, "center", "center"):ibData("font", ibFonts.bold_12)
			ui["player_state"..i] = ibCreateLabel( 50, 25, 130, 22, v.state == 0 and "Ожидает хода" or "Делает ход", ui["player_bg"..i], 0xFFFFFFFF, 1, 1, "center", "center"):ibData("font", ibFonts.regular_12)
			py = py + 60
		end

		-- Подсказки
		ui.shoot_hint = ibCreateImage( scx/2-396/2, scy-300, 396, 34, ":nrp_casino_game_roulette/img/shoot_hint.png", false ):ibData("alpha", 0)

		-- Угловые подсказки
		ui.corner_hints = ibCreateImage( 10, scy-30, 94, 18, ":nrp_casino_game_roulette/img/corner_hints.png", false ):ibData("alpha", 0):ibAlphaTo(255, 1000)

		-- Оповещения в центре
		ui.notification_bg = ibCreateImage( scx/2-602/2, scy/4, 602, 68, ":nrp_casino_game_roulette/img/notification_bg.png", false ):ibData("alpha", 0)
		ui.notification_text = ibCreateLabel( 0, 0, 602, 60, "", ui.notification_bg, 0xFFFFFFFF, 1, 1, "center", "center"):ibData("font", ibFonts.regular_24)
	else
		DestroyTableElements( ui )
		--showPlayerHudComponent( "radar", true )
		DestroyGun()

		triggerEvent( "ShowInventoryHotbar", localPlayer, true )

		if isElement(pAmbientSound) then destroyElement( pAmbientSound ) end
	end
end

function UpdateRouletteScores( data )
	if not isElement(ui.scores_bg) then return end

	for k,v in pairs(temp_scores) do
		if v.player == data.player then
			v.is_dead = 1
			ui["player_state"..k]:ibData("text", "МЁРТВ"):ibData("color", 0xFFAA2222)
		end
	end

	local sorted_scores = table.copy(temp_scores)

	table.sort(sorted_scores, function( a, b ) return a.is_dead < b.is_dead end )

	for i,v in pairs(sorted_scores) do
		for key, val in pairs(temp_scores) do
			if v.player == val.player then
				ui["player_bg"..key]:ibMoveTo(10, 60*i-60, 1000)
			end
		end
	end
end

function UpdateRouletteTurnPlayer( turn_player )
	for k,v in pairs(temp_scores) do
		if v.player == turn_player then
			ui["player_state"..k]:ibData("text", "Делает ход")
		else
			if v.is_dead == 0 then
				ui["player_state"..k]:ibData("text", "Ожидает хода")
			else
				ui["player_state"..k]:ibData("text", "МЁРТВ")
			end
		end
	end
end

local pHintTimer

function ShowRouletteHint( text )
	if isTimer(pHintTimer) then killTimer( pHintTimer ) end

	ui.notification_text:ibData("text", text)
	ui.notification_bg:ibAlphaTo( 255, 800 )

	pHintTimer = setTimer(function()
		if isElement(ui.notification_bg) then
			ui.notification_bg:ibAlphaTo( 0, 600 )
		end
	end, 2000, 1)
end

function ShowShootHint( state )
	if state then
		ui.shoot_hint:ibAlphaTo( 255, 1000 )
	else
		ui.shoot_hint:ibAlphaTo( 0, 300 )
	end
end

function OnPlayerLeftRouletteTable()
	UpdateRouletteScores( { player = source } )
end
--addEvent("OnPlayerLeftRouletteTable", true)
--addEventHandler("OnPlayerLeftRouletteTable", root, OnPlayerLeftRouletteTable)

--ShowRouletteUI( true, {} )