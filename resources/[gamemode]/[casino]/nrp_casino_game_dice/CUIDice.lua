--[[ TODO LIST
- Отрисовка таблицы
- Отрисовка таймера хода
- Отрисовка элементов управления( бросить кости, выйти из игры )
- Обработчик полёта и выпадения костей + камеры
]]

local scx, scy = guiGetScreenSize()
local ui = {}

local iTurnEnds, iTurnDuration
local bBigScoreShown = false
local pAmbientSound

local temp_scores = {}

local COLUMNS_CONFIG = 
{
	{
		title = "Имя игрока",
		width = 180,
		align = "left",
		get_text = function( row )
			return temp_scores[row].name
		end
	},

	{
		title = "Раунд 1",
		width = 100,
		align = "center",
		get_text = function( row )
			return temp_scores[row].scores[1] or "-"
		end
	},

	{
		title = "Раунд 2",
		width = 100,
		align = "center",
		get_text = function( row )
			return temp_scores[row].scores[2] or "-"
		end
	},

	{
		title = "Раунд 3",
		width = 100,
		align = "center",
		get_text = function( row )
			return temp_scores[row].scores[3] or "-"
		end
	},

	{
		title = "Итого",
		width = 100,
		align = "center",
		get_text = function( row )
			local iTotalScore = 0

			for k,v in ipairs( temp_scores[row].scores ) do
				iTotalScore = iTotalScore + v
			end

			return iTotalScore
		end
	},
}

function ShowUI_Game( state, data )
	if state then
		ibUseRealFonts( true )

		triggerEvent("ShowPhoneUI", localPlayer, false)

		fadeCamera( false, 0 )
		setTimer(function()
			fadeCamera(true, 1)
			setCameraTarget(localPlayer)
		end, 200, 1)

		setTimer(function()
			local cx,cy,cz, tx,ty,tz = getCameraMatrix()
			pGameData.camera_default_position = { cx,cy,cz, tx,ty,tz }
		end, 300, 1)

		ShowUI_Game( false )
		temp_scores = {}
		if data.players then
			for k,v in pairs(data.players) do
				table.insert( temp_scores, { player = v, name = v:GetNickName(), scores = {} } )
			end
		end

		pAmbientSound = playSound( "sfx/bg1.ogg",true )
		setSoundVolume(pAmbientSound, 0.3)

		--showPlayerHudComponent( "radar", false )
		bBigScoreShown = false

		-- Таблица со счётом
		ui.scores_bg = ibCreateImage( scx-300, scy-230, 290, 220, nil, false, 0x80506c8b ):ibData("alpha", 0):ibAlphaTo(255, 1000)

		ui.key_action_close = ibAddKeyAction( _, _, ui.scores_bg , function()
			OnTryLeftGame()
		end )

		local px = 10
		for k,v in pairs( COLUMNS_CONFIG ) do
			if k == 1 or k == 5 then
				local py = 10

				local column_title = ibCreateLabel( px, py, v.width, 30, v.title, ui.scores_bg, 0xFFAAAAAA, 1, 1, v.align, "center" ):ibData("font", ibFonts.regular_12)
				py = py + 50
				for i, player_data in pairs( temp_scores ) do
					if i/2 ~= math.floor(i/2) and not isElement( ui["dark_line"..i] ) then
						ui["dark_line"..i] = ibCreateImage( 0, py, 290, 30, nil, ui.scores_bg, 0x40000000 ):ibData("priority", -1)
					end

					if not isElement( ui["line_bg"..i] ) then
						ui["line_bg"..i] = ibCreateImage( 0, py, 290, 30, nil, ui.scores_bg, 0x00000000 )
					end

					ui["index"..k..i] = ibCreateLabel( px, 0, v.width, 30, v.get_text( i ), ui["line_bg"..i], 0xFFFFFFFF, 1, 1, v.align, "center" ):ibData("font", ibFonts.bold_14 ):ibData("priority", 1)
					py = py + 30
				end

				px = px + v.width
			end
		end

		-- Таблица со счётом(развёрнутая)
		ui.big_scores_bg = ibCreateImage( scx-620, scy-270, 610, 260, nil, false, 0x80506c8b ):ibData("alpha", 0)

		local px = 30
		for k,v in pairs( COLUMNS_CONFIG ) do
			local py = 10
			
			local column_title = ibCreateLabel( px, py, v.width, 40, v.title, ui.big_scores_bg, 0xFFAAAAAA, 1, 1, v.align, "center" ):ibData("font", ibFonts.regular_14)
			py = py + 50

			for i, player_data in pairs( temp_scores ) do
				if i/2 ~= math.floor(i/2) and not isElement( ui["big_dark_line"..i] ) then
					ui["big_dark_line"..i] = ibCreateImage( 0, py, 610, 40, nil, ui.big_scores_bg, 0x40000000 ):ibData("priority", -1)
				end

				if not isElement( ui["big_line_bg"..i] ) then
					ui["big_line_bg"..i] = ibCreateImage( 0, py, 610, 40, nil, ui.big_scores_bg, 0x00000000 )
				end

				ui["big_index"..k..i] = ibCreateLabel( px, 0, v.width, 40, v.get_text( i ), ui["big_line_bg"..i], 0xFFFFFFFF, 1, 1, v.align, "center" ):ibData("font", ibFonts.bold_16 ):ibData("priority", 1)
				py = py + 40
			end

			px = px + v.width
		end

		-- Состояние хода
		ui.turn_bg = ibCreateImage( scx/2-250, scy-170, 400, 100, nil, false, 0x80222222 ):ibData("alpha", 0):ibAlphaTo(255, 1000)
		local title = ibCreateLabel( 30, 0, 400, 50, "Сейчас ходит:", ui.turn_bg, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.turn_player_name = ibCreateLabel( 160, 0, 400, 50, "", ui.turn_bg, 0xFF22FF22, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
		
		local time_left = ibCreateLabel( 30, 50, 400, 40, "Время хода:", ui.turn_bg, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.time_left_bg = ibCreateImage( 140, 64, 200, 15, nil, ui.turn_bg, 0xFF000000 )
		ui.time_left_body = ibCreateImage( 140, 64, 0, 15, nil, ui.turn_bg, 0xFF22aa22 )


		-- Подсказки
		ui.throw_hint = ibCreateImage( scx/2-396/2, scy-300, 396, 34, "img/throw_hint.png", false ):ibData("alpha", 0)

		-- Угловые подсказки
		ui.corner_hints = ibCreateImage( 10, scy-30, 279, 18, "img/corner_hints.png", false ):ibData("alpha", 0):ibAlphaTo(255, 1000)

		-- Оповещения в центре
		ui.notification_bg = ibCreateImage( scx/2-602/2, scy/4, 602, 68, "img/notification_bg.png", false ):ibData("alpha", 0)
		ui.notification_text = ibCreateLabel( 0, 0, 602, 60, "", ui.notification_bg, 0xFFFFFFFF, 1, 1, "center", "center"):ibData("font", ibFonts.regular_24)
	else
		DestroyTableElements( ui )
		--showPlayerHudComponent( "radar", true )
		removeEventHandler("onClientPreRender", root, PreRenderTime)
		DestroyDices()

		if isElement(pAmbientSound) then destroyElement( pAmbientSound ) end
	end
end

function UpdateGameUI( data )
	removeEventHandler("onClientPreRender", root, PreRenderTime)

	iTurnDuration = data.time_left*1000
	iTurnEnds = getTickCount() + iTurnDuration

	addEventHandler("onClientPreRender", root, PreRenderTime)

	if data.turn_player and isElement(ui.turn_player_name) then
		ui.turn_player_name:ibData("text", data.turn_player:GetNickName())
	end
end

function UpdateScores()
	if not isElement(ui.scores_bg) then return end

	for k,v in pairs( COLUMNS_CONFIG ) do
		for i, player_data in pairs( temp_scores ) do
			if k == 1 or k == 5 then
				ui["index"..k..i]:ibData("text", v.get_text( i ))
			end
			ui["big_index"..k..i]:ibData("text", v.get_text( i ))
		end
	end
end

function UpdatePlayerScore( pPlayer, stage, score )
	for k,v in pairs(temp_scores) do
		if v.player == pPlayer then
			v.scores[stage] = score
			
			local iTotalScore = 0
			for i, value in ipairs(v.scores) do
				iTotalScore = iTotalScore + value
			end

			v.scores.total = iTotalScore

			if not isElement(pPlayer) then
				if pPlayer == localPlayer then return end
				v.scores = { total = 0 }
				v.name = "ИГРОК ВЫШЕЛ"
				ui["line_bg"..k]:ibData("color", 0x80AA2222)
				ui["big_line_bg"..k]:ibData("color", 0x80AA2222)
			end
			break
		end
	end

	local sorted_scores = table.copy(temp_scores)
	table.sort( sorted_scores, function( a, b )  return  (b.scores.total or 0) <  (a.scores.total or 0) end)

	for i, v in pairs(sorted_scores) do
		for key, val in pairs(temp_scores) do
			if v.player == val.player then
				ui["line_bg"..key]:ibMoveTo( 0, 60+30*i-30, 500 )
				ui["big_line_bg"..key]:ibMoveTo( 0, 60+40*i-40, 500 )
			end
		end
	end

	UpdateScores()
end

function PreRenderTime()
	local fProgress = ( iTurnEnds - getTickCount() ) / iTurnDuration

	if fProgress >= 0 then
		ui.time_left_body:ibData("sx", 200*fProgress)
	else
		removeEventHandler("onClientPreRender", root, PreRenderTime)
	end
end

local pHintTimer

function ShowHint( text )
	if isTimer(pHintTimer) then killTimer( pHintTimer ) end

	ui.notification_text:ibData("text", text)
	ui.notification_bg:ibAlphaTo( 255, 800 )

	pHintTimer = setTimer(function()
		if isElement(ui.notification_bg) then
			ui.notification_bg:ibAlphaTo( 0, 600 )
		end
	end, 2000, 1)
end

function ShowThrowHint( state )
	if state then
		ui.throw_hint:ibAlphaTo( 255, 1000 )
	else
		ui.throw_hint:ibAlphaTo( 0, 300 )
	end
end

function SwitchScoreTable()
	bBigScoreShown = not bBigScoreShown

	if bBigScoreShown then
		ui.scores_bg:ibAlphaTo( 0, 300 )
		ui.big_scores_bg:ibAlphaTo( 255, 500 )
	else
		ui.scores_bg:ibAlphaTo( 255, 500 )
		ui.big_scores_bg:ibAlphaTo( 0, 300 )
	end
end

function OnPlayerLeftDiceTable()
	if source == localPlayer then return end

	for k,v in pairs(temp_scores) do
		if v.player == source then
			v.scores = {}
			v.name = "ИГРОК ВЫШЕЛ"
			ui["line_bg"..k]:ibData("color", 0x80AA2222)
			ui["big_line_bg"..k]:ibData("color", 0x80AA2222)
			UpdateScores()
			break
		end
	end
end
addEvent("OnPlayerLeftDiceTable", true)
addEventHandler("OnPlayerLeftDiceTable", root, OnPlayerLeftDiceTable)