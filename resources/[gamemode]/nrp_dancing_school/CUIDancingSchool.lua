scx, scy = guiGetScreenSize()
local sizeX, sizeY = 340, scy-200
local posX, posY = scx-sizeX-20, scy-sizeY-20

local is_low_rez = scx <= 1024
local bar_size_x = is_low_rez and 400 or 700

local pInteriorData = 
{
	vecCamera = Vector3( -232.2134552002, -388.12292480469, 1339.2507324219 ),
	vecCameraTarget = Vector3( -163.00503540039, -317.24063110352, 1325.6163330078 ),
	vecPedPosition = Vector3( -228.360, -384.129, 1338.620 ),
	fPedRotation = 135,
}

ui = {}
local tex = {}
local fonts
local iAnimation = 1
local iSection = 1
local pUserPreset = {}
local pPed

function InitDancingSchool()
	if not _DANCING_SCHOOL_INIT then
		fonts = 
		{
			Regular10  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 10 );
			Regular12  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 12 );
			Regular14  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 14 );
			Regular16  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 16 );

			Bold10  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Bold.ttf", 11, true );
			Bold12  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Bold.ttf", 12, true );
			Bold14  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Bold.ttf", 14, true );
			Bold16  = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Bold.ttf", 16, true );
		}
		_DANCING_SCHOOL_INIT = true
	end
end

function onClientPlayerWasted_handler( )
	ShowUI( false )
end

function IsDanceSchoolQuest( )
	local quest_data = localPlayer:getData( "current_quest" )
	return quest_data and quest_data.id == "angela_dance_school"
end

function ShowUI( state, ignore_trigger_server )
	if not ignore_trigger_server and not IsDanceSchoolQuest( ) then
		triggerServerEvent( "DS:onPlayerShowUI", localPlayer, state )
	end
	if state then
		if isElement(ui.black_bg) then return end
		InitDancingSchool()
		ShowUI( false, true )

		if not IsDanceSchoolQuest( ) then
			SAVED_DATA = { localPlayer.dimension, localPlayer.interior, localPlayer.position }
			localPlayer.interior = 1
			localPlayer.dimension = 6
		end

		localPlayer.position = localPlayer.position + Vector3( 0, 0, 300 )
		localPlayer.frozen = true
		localPlayer.alpha = 0
		localPlayer.collisions = false

		setCameraMatrix(pInteriorData.vecCamera, pInteriorData.vecCameraTarget)
		pPed = createPed( localPlayer.model, pInteriorData.vecPedPosition )

		pPed.interior = localPlayer.interior
		pPed.dimension = localPlayer.dimension

		setElementRotation(pPed, 0, 0, pInteriorData.fPedRotation)

		addEventHandler( "onClientElementStreamIn", pPed, function()
			pPed:setCollidableWith( localPlayer, false )
		end)

		showCursor(true)
		iAnimation = 1
		iSection = 1
		pUserPreset = localPlayer:getData("animations_preset") or {}
		--setPlayerHudComponentVisible( "radar", false )

		ui.black_bg   = ibCreateBackground( 0x00000000, ShowUI, true, true )
		ui.back_dummy = ibCreateArea( 0, 0, scx, scy, ui.black_bg )
		:ibOnClick( function( button, state )
			if button == "left" and state == "up" and GetFloatingItemDragType() == DRAG_TYPE_FROM_RADIAL then
				pUserPreset[ iSection ] = nil
				localPlayer:setData( "animations_preset", pUserPreset, false )
				SaveUserPreset()
				FillRadial()
			end
		end )

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, nil, ui.black_bg, 0xEF43586f )
		ui.header = ibCreateImage( 0, 0, sizeX, 56, "files/img/header.png", ui.main, 0xFFFFFFFF)

		ui.scrollpane = ibCreateScrollpane( 0, 60, sizeX, sizeY-180, ui.main, { scroll_px = -20 } )
		local px, py = 25, 20
		for k,v in pairs(DANCES_LIST) do
			if ( v.is_hidden and localPlayer:HasDance( k ) ) or not v.is_hidden then
				ui["dance"..k] = ibCreateButton( px, py, 90, 110, ui.scrollpane, "files/img/rectangle.png", "files/img/rectangle_hovered.png", "files/img/rectangle_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				ui["icon"..k] = ibCreateContentImage( 0, 10, 90, 90, "animation", k, ui["dance"..k] ):center():ibData("disabled", true)

				
				if localPlayer:HasDance(k) then
					ui["tick"..k] = ibCreateImage( 54, 8, 18, 15, "files/img/tick.png", ui["dance"..k]  )
				end

				if v.time_new and v.time_new > getRealTimestamp() then
					ui["new"..k] = ibCreateImage( 8, 8, 11, 11, "files/img/new_indicator.png", ui["dance"..k] )
				end

				addEventHandler( "ibOnElementMouseClick", ui["dance"..k], function( key, state )
					if key == "left" and state == "down" then
						v.item_table_index = k
						CreateFloatingItem( k, v, localPlayer:HasDance(k) and DRAG_TYPE_FROM_SHOP_BOUGHT or DRAG_TYPE_FROM_SHOP )
					elseif key == "left" and state == "up" then
						SwitchAnimation( k )
					end					
				end, false)

				px = px + 100
				if px >= 240 then
					px = 25
					py = py + 120
				end
			end
		end
		ui.scrollpane:AdaptHeightToContents()

		ui.btn_close = ibCreateButton( 50, sizeY-70, 111, 45, ui.main, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		ui.btn_buy = ibCreateButton( 170, sizeY-87, 144, 80, ui.main, "files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		
		addEventHandler( "ibOnElementMouseClick", ui.btn_close, function( key, state )
			if key ~= "left" or state ~= "up" then return end			
			ShowUI(false)
		end, false)

		addEventHandler( "ibOnElementMouseClick", ui.btn_buy, function( key, state )
			if key ~= "left" or state ~= "up" then return end

			local current_quest = localPlayer:getData( "current_quest" )
			if current_quest and current_quest.id == "angela_dance_school" then
				localPlayer:ShowError( "Вы уже изучили новое движение!" )
				return
			end

			triggerServerEvent( "OnPlayerTryBuyDance", resourceRoot, localPlayer, iAnimation )
		end, false)

		-- BOTTOM BAR
		ui.bottom = ibCreateImage( (scx-bar_size_x)/2 - (is_low_rez and 200 or 0), scy-90, bar_size_x, 70, "files/img/bg_selector.png" ):ibData("disabled", is_low_rez)
		if not is_low_rez then
			ui.btn_left = ibCreateButton( 170, 20, 30, 30, ui.bottom, "files/img/btn_arrow.png", "files/img/btn_arrow_hovered.png", "files/img/btn_arrow_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("rotation", 180)
			ui.btn_right = ibCreateButton( 700-200, 20, 30, 30, ui.bottom, "files/img/btn_arrow.png", "files/img/btn_arrow_hovered.png", "files/img/btn_arrow_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

			addEventHandler( "ibOnElementMouseClick", ui.btn_left, function( key, state )
				if key ~= "left" or state ~= "up" then return end
				SwitchAnimation(iAnimation - 1)
			end, false)

			addEventHandler( "ibOnElementMouseClick", ui.btn_right, function( key, state )
				if key ~= "left" or state ~= "up" then return end
				SwitchAnimation(iAnimation + 1)
			end, false)
		end

		ui.cost = ibCreateLabel( 0, 20, bar_size_x, 50, DANCES_LIST[1].cost, ui.bottom, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", fonts.Bold16):ibData("disabled", true)
		ui.name = ibCreateLabel( 0, 0, bar_size_x, 30, DANCES_LIST[1].name, ui.bottom, 0xFFAAAAAA, 1, 1, "center", "center" ):ibData("font", fonts.Bold12):ibData("disabled", true)

		local iCostWidth = dxGetTextWidth( DANCES_LIST[1].cost, 1, fonts.Bold16 )
		ui.icon_money = ibCreateImage( 700/2-34-iCostWidth/2, 35, 24, 20, "files/img/icon_money.png", ui.bottom )

		local iNameWidth = dxGetTextWidth( DANCES_LIST[1].name, 1, fonts.Bold12 )
		ui.icon_lock = ibCreateImage( 700/2-24-iNameWidth/2, 5, 14, 16, "files/img/lock.png", ui.bottom, 0x00000000 )

		-- RADIAL
		local bias_y = is_low_rez and 30 or 0
		ui.radial = ibCreateImage( 20, (scy-320)/2-bias_y, 320, 320, "files/img/bg_radial.png" )
		ui.selector = ibCreateImage( 0, 0, 320, 320, "files/img/sections/1.png", ui.radial ):ibData( "disabled", true )
		ui.core = ibCreateImage( 128, 128, 64, 64, "files/img/radial_core.png", ui.radial ):ibData( "disabled", true )

		FillRadial()

		ui.radial_px, ui.radial_py = ui.radial:ibData("px") + ui.radial:ibData("sx") / 2, ui.radial:ibData("py") + ui.radial:ibData("sy") / 2
		ui.radial_enter = false
		ui.radial
		:ibOnRender( function()
			if ui.radial_enter then
				local cx, cy = getCursorPosition()
				cx = cx * scx
				cy = cy * scy

				local angle = math.atan2( ui.radial_px - cx, ui.radial_py - cy )
				angle = (-math.deg(angle)+20) % 360

				iSection = math.ceil( angle / (360/8) )
				ui.selector:ibData("texture", "files/img/sections/"..iSection..".png")
			end
		end)
		:ibOnHover( function( )
			ui.radial_enter = true
		end )
		:ibOnLeave( function( )
			ui.radial_enter = false
		end )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" and not is_quest then
				local iDance = pUserPreset[ iSection ]
				sSection = iSection
				CreateFloatingItem( iDance, DANCES_LIST[ iDance ], DRAG_TYPE_FROM_RADIAL )
			elseif button == "left" and state == "up" and GetFloatingItemDragType() == DRAG_TYPE_FROM_RADIAL then
				if sSection == iSection then return end
				pUserPreset[ sSection ], pUserPreset[ iSection ] = pUserPreset[ iSection ], pUserPreset[ sSection ]
				localPlayer:setData( "animations_preset", pUserPreset, false )
				SaveUserPreset()
				FillRadial()
			elseif button == "left" and state == "up" and GetFloatingItemDragType() == DRAG_TYPE_FROM_SHOP then
				localPlayer:ShowError( "Купить обучение по движению, чтобы поместить в слот!" )
			elseif button == "left" and state == "up" and GetFloatingItemDragType() == DRAG_TYPE_FROM_SHOP_BOUGHT and not is_quest then
				local iDance = pUserPreset[ iSection ]
				if iDance then
					localPlayer:ShowError( "Освободите слот, чтобы выучить движение")
					return
				end

				local item = GetFloatingItem()
				local dance_id = -1
				for k, v in pairs( DANCES_LIST ) do
					--[[if v.name == item.name then
						dance_id = k
						break
					end]]
					if k == item.item_table_index then
						dance_id = k
						break
					end
				end
				if dance_id == -1 then return end 

				for k, v in pairs( pUserPreset ) do
					if v == dance_id then
						localPlayer:ShowError( "У вас уже добавлено данное движение" )
						return
					end
				end

				pUserPreset[ iSection ] = dance_id
				localPlayer:setData( "animations_preset", pUserPreset, false )
				SaveUserPreset()
				FillRadial()
			end
		end )

		if IsDanceSchoolQuest( ) then
			local dance_id = -1
			for k, v in pairs( DANCES_LIST ) do
				if v.name == "Танец 4" then
					dance_id = k
					break
				end
			end
			
			setTimer( function()
				iSection = 1
				local exist = false
				for k, v in pairs( pUserPreset ) do
					if v == dance_id then
						exist = true
						break
					end
				end
				if not exist then
					pUserPreset[ 1 ] = dance_id
				end
				localPlayer:setData( "animations_preset", pUserPreset, false )
				SaveUserPreset()
				iprint( "User preset", pUserPreset )

				FillRadial()
				if isElement( ui.selector ) then
					ui.selector:ibData( "texture", "files/img/sections/" .. iSection .. ".png" )
					SwitchAnimation( dance_id )
				end
				localPlayer:ShowInfo( "Поздравляем, ты изучил новый танец! Привет Анжеле" )

				triggerServerEvent( "angela_dance_school_step_3", localPlayer )
			end, 500, 1 )
		end

		addEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
	else
		if not isElement(ui.black_bg) then return end
		
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end
		if isElement(pPed) then destroyElement( pPed ) end

		--setPlayerHudComponentVisible( "radar", true )

		if SAVED_DATA then
			localPlayer:Teleport( SAVED_DATA[ 3 ], SAVED_DATA[ 1 ], SAVED_DATA[ 2 ] )
		end

		SAVED_DATA = nil

		setCameraTarget( localPlayer )

		localPlayer.frozen = false
		localPlayer.alpha = 255
		localPlayer.collisions = true

		showCursor(false)

		removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
	end
end
addEvent("DS:ShowUI", true)
addEventHandler("DS:ShowUI", root, ShowUI)

function UpdateScrollpaneBody( conf )
	if not isElement(ui.black_bg) then return end
	for k,v in pairs(DANCES_LIST) do
		if localPlayer:HasDance(k) then
			ui["tick"..k] = ibCreateImage( 54, 8, 18, 15, "files/img/tick.png", ui["dance"..k]  )
		end
	end
	ui.scrollpane:AdaptHeightToContents()

	if conf and conf.dance then
		local preset = localPlayer:getData( "animations_preset" ) or { }
		local changed = false
		for i = 1, 7 do
			if not preset[ i ] then
				preset[ i ] = conf.dance
				changed = true
				break
			end
		end
		if changed and not PlayerHasInList( conf.dance ) then
			localPlayer:setData( "animations_preset", preset, false )
			pUserPreset = preset
			FillRadial( )
		end
	end
end
addEvent("DS:UpdateUI", true)
addEventHandler("DS:UpdateUI", resourceRoot, UpdateScrollpaneBody)

function PlayerHasInList( dance )
	local preset = localPlayer:getData( "animations_preset" ) or { }
	local changed = false
	for i = 1, 7 do
		if preset[ i ] == dance then
			return true
		end
	end
end

function FillRadial()
	for i = 1, 8 do
		if isElement(ui["rad"..i]) then destroyElement( ui["rad"..i] ) end

		local fAngle = (360/8)*i
	
		local fX = 315/2 + ( ( math.cos( math.rad( fAngle - 135 ) ) ) * ( ( 315 * 0.35 ) ) )
		local fY = 315/2 + ( ( math.sin( math.rad( fAngle - 135 ) ) ) * ( ( 315 * 0.35 ) ) )

		local iDance = pUserPreset[i]
		if iDance then
			ui["rad"..i] = ibCreateContentImage( math.floor(fX -  25), math.floor(fY -  25), 50, 50, "animation", iDance, ui.radial )
			:ibData( "disabled", true )
		end
	end
end

function SwitchAnimation( iID )
	if not DANCES_LIST[iID] then return end

	ui["dance"..iAnimation]:ibData("texture", "files/img/rectangle.png")
	iAnimation = iID
	ui["dance"..iAnimation]:ibData("texture", "files/img/rectangle_hovered.png")

	ui.name:ibData("text", DANCES_LIST[iID].name)
	ui.cost:ibData("text", DANCES_LIST[iID].cost)

	local iCostWidth = dxGetTextWidth( DANCES_LIST[iID].cost, 1, fonts.Bold16 )
	ui.icon_money:ibData("px", bar_size_x/2-34-iCostWidth/2)

	ui.icon_lock:ibData("color", 0x00000000)

	local pDanceData = DANCES_LIST[iID]
	setElementRotation( pPed, 0, 0, pInteriorData.fPedRotation + (pDanceData.rz or 0) )
	setPedAnimation( pPed, nil )
	setPedAnimation( pPed, pDanceData.anim_data[1], pDanceData.anim_data[2], -1, pDanceData.is_looped or false, pDanceData.updatePosition or false, false, pDanceData.freeze_lf or false)
end