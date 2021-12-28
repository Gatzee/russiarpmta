local scx, scy = guiGetScreenSize()

local sizeX, sizeY = 800, 580
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local ui = {}
local dialog = {}

function ShowUI_Event( state, data )
	if state then
		ShowUI_Event(false)
		showCursor( true )

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png" )
		ui.timer = ibCreateLabel( 680, 96, 0, 0, getHumanTimeString( EVENT_ENDS, true ), ui.main, 0xFFffde96, _, _, "left", "center", ibFonts.bold_18 )
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			ShowUI_Event( false )
			ibClick()
		end)

		local px, py = 30, 308
		for k,v in pairs( EVENT_TASKS ) do
			local fProgress = data[k] / v.progress_max

			local label = ibCreateLabel( px, py, 0, 0, v.visible_name, ui.main, 0xffffffff, _, _, "left", "bottom", ibFonts.regular_16 )
			local bg = ibCreateImage( px, py+6, 280, 14, "files/img/bar_bg.png", ui.main )
			local body = ibCreateImage( px-18, py+6 + 7-25, 316*fProgress, 50, "files/img/bar_body.png", ui.main )
			:ibBatchData( { u = 0, v = 0, u_size = 316*fProgress } )

			local counter = ibCreateLabel( px+290, py+6, 0, 14, data[k].."/"..v.progress_max.." "..(v.progress_value or ""), ui.main, 0xffffffff, _, _, "left", "center", ibFonts.regular_12 )

			py = py + 50
		end
	else
		showCursor( false )
		for k, v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end
	end
end
addEvent("ShowUI_Event", true)
addEventHandler("ShowUI_Event", resourceRoot, ShowUI_Event)

function ShowUI_Rewards( state )
	if state then
		showCursor(true)

		ui.rewards_bg = ibCreateImage( 0, 0, scx, scy, "files/img/rewards_bg.png" ):ibData("alpha", 0)
		:ibAlphaTo(255, 500)
		ui.rewards = ibCreateImage( scx/2-369/2, scy/2-75/2, 369, 75, "files/img/rewards.png", ui.rewards_bg )
		ui.title = ibCreateLabel( 0, 0, scx, scy-scy/3, "Поздравляем!\nВы выполнили условия акции, заберите награду", ui.rewards_bg, 0xffffffff, _, _, "center", "center", ibFonts.bold_18 )
	
		ibCreateButton( scx/2-70, scy-scy/4, 140, 54, ui.rewards_bg, "files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			triggerServerEvent( "OnPlayerTookReward", resourceRoot )
			ShowUI_Rewards( false )
			ibClick()
		end)

		local sfx = playSound( ":nrp_shop/sfx/reward_small.mp3" )
		setSoundVolume( sfx, 0.75 )
	else
		showCursor( false )
		for k, v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end
	end
end
addEvent("ShowUI_Rewards", true)
addEventHandler("ShowUI_Rewards", resourceRoot, ShowUI_Rewards)

local dialogues_list = 
{
	["start"] = 
	{
		messages = { 
		[[Приветствую тебя, я работаю учителем в этом городе. 
		И в честь дня знаний хочу сделать для тебя подарок в размере 100 000 рублей. 
		Но для этого тебе необходимо, найти и собрать 7 роз, сделать из них букет и привезти его мне.]],
		},
		font = ibFonts.regular_14,

		camera_matrix = { x = -101.284, y = -1127.595, z = 21.302, tx = -101.259, ty = -1128.895, tz = 21.302 },

		on_finished = function()
			triggerServerEvent( "OnPlayerFirstDialogFinished", resourceRoot )
		end
	},

	["finish"] = 
	{
		messages = { 
		[[Благодарю тебя за букет роз. Взамен получи свои 100 000 рублей.]] 
		},
		font = ibFonts.regular_14,

		camera_matrix = { x = -101.284, y = -1127.595, z = 21.302, tx = -101.259, ty = -1128.895, tz = 21.302 },
		--color = 0xff22dd22,

		on_finished = function()
			triggerServerEvent( "OnPlayerTookReward", resourceRoot )
			ShowUI_Rewards( true )
		end
	},
}

function ShowUI_Dialog( state, id )
	if state then
		local data = table.copy( dialogues_list[id] )
		ShowUI_Dialog( false )
		if not data then return end

		dialog.messages = {}
		
		local message_shown = false

		local function NextMessage()
			local _, sMsg = next( data.messages )
			if sMsg then
				local str, sx, sy = CustomWordBreak(sMsg, data.font, 600)
				sx = sx + 20
				sy = sy + 20

				local px, py = scx/2-sx/2, scy - scy/3

				for k,v in pairs( dialog.messages ) do
					local msg_px, msg_py = v:ibData("px"), v:ibData("py")
					local msg_sy = v:ibData("sy")
					local new_py = msg_py-sy-10

					local f_alpha_progress = (new_py+msg_sy/2) / (scy/3)
					local alpha = interpolateBetween( 0, 0, 0, 255, 0, 0, f_alpha_progress, "Linear" )

					v:ibMoveTo( msg_px, new_py, 600 )
					v:ibAlphaTo(alpha, 600)
				end

				local msg_bg = ibCreateImage( px, py+sy, sx, sy, "files/img/msg_bg.png", false ):ibData("alpha", 0)
				:ibAlphaTo( 255, 600 ):ibMoveTo( px, py, 600 )
				ibCreateLabel( 0, 0, sx, sy-20, str, msg_bg, data.color or 0xffffffff, _, _, "center", "center", data.font )

				table.insert( dialog.messages, msg_bg )
				table.remove( data.messages, 1 )

				if not message_shown then
					setTimer(function()
						if not next(dialog) then return end

						message_shown = true
					end, 1200, 1)
				end

				if next( data.messages ) then
					local function DialogKeyHandler( key, state )
						if not state then return end
						if not message_shown then return end

						if key == "space" or key == "mouse1" then
							message_shown = false
							NextMessage()

							removeEventHandler("onClientKey", root, DialogKeyHandler)
						end
					end
					addEventHandler("onClientKey", root, DialogKeyHandler)
				else
					setTimer( NextMessage, 1200, 1 )
				end
			else
				local msg_py = dialog.messages[#dialog.messages]:ibData("py")
				local msg_sy = dialog.messages[#dialog.messages]:ibData("sy")

				dialog.btn_finish = ibCreateButton( scx/2-56, msg_py+msg_sy+10, 110, 44, false, 
					"files/img/btn_finish_dialog.png", "files/img/btn_finish_dialog.png", "files/img/btn_finish_dialog.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick( function(key, state) 
					if key ~= "left" or state ~= "up" then return end
					ShowUI_Dialog( false )
					ibClick()

					if data.on_finished then
						data:on_finished()
					end
				end)
			end
		end

		if data.camera_matrix then
			local iStarted = getTickCount()
			local sx, sy, sz = getElementPosition( getCamera() )

			local function PreRenderCamera()
				local fProgress = (getTickCount() - iStarted) / 1000

				local cx, cy, cz = interpolateBetween( sx, sy, sz, data.camera_matrix.x, data.camera_matrix.y, data.camera_matrix.z, fProgress, "Linear" )
				setCameraMatrix( cx, cy, cz, data.camera_matrix.tx, data.camera_matrix.ty, data.camera_matrix.tz )
			
				if fProgress >= 1 then
					removeEventHandler("onClientPreRender", root, PreRenderCamera)
				end
			end
			addEventHandler("onClientPreRender", root, PreRenderCamera)
		end

		setTimer(NextMessage, 1000, 1)

		showCursor(true)
	else
		for k,v in pairs(dialog) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		for k,v in pairs(dialog.messages or {}) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		setCameraTarget( localPlayer )

		showCursor(false)
	end
end
addEvent("ShowUI_Dialog", true)
addEventHandler("ShowUI_Dialog", resourceRoot, ShowUI_Dialog)

-- Utils
function CustomWordBreak( text, font, width )
	local text = string.gsub( text, "\n", "" )
	local pWords = split( text, " " )
	local pLines = {}
	local iWidthMax = 0

	local iLine = 1

	for k,v in pairs( pWords ) do
		local line_width = dxGetTextWidth( (pLines[iLine] or "").." "..v, 1, font )

		if line_width > iWidthMax then
			iWidthMax = line_width
		end

		if line_width >= width then
			iLine = iLine + 1
			pLines[iLine] = (pLines[iLine] or "").." "..v
		else
			pLines[iLine] = (pLines[iLine] or "").." "..v
		end
	end

	local sOutput = ""

	for k,v in pairs(pLines) do
		sOutput = sOutput.."\n"..v
	end

	local iHeight = dxGetFontHeight( 1, font ) * ( #pLines+2 )

	return sOutput, math.floor(iWidthMax), math.floor(iHeight)
end