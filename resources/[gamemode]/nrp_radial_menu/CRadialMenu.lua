Extend( "CVehicle" )
Extend( "CPlayer" )
Extend( "CUI" )
Extend( "ShUtils" )

local scx,scy = guiGetScreenSize()
local sizeX, sizeY = 580, 580
local posX, posY = scx/2-sizeX/2, scy/2-sizeY/2
local c_x, c_y = scx/2, scy/2

local font = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 13, false);
local font2 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 10, false);

local iX2	= posX + ( sizeX / 2 )
local iY2	= posY + ( sizeY / 2 )

local iLastTick = getTickCount()
local iTempRadialBlock = 0
local pItems = {}
local pFoundItem = nil
local iRadialMode = 1
local bRadialShown = false
local iSection = 1

local MAX_ITEMS_COUNT = 8

local fSectionSize = 360/8
local fBiasMultiplier = 600*0.35
local pUserPreset = {}

function DrawRadialMenu()
	if localPlayer.dead then return end

	local iTick	= getTickCount()
	local fCurX, fCurY = getCursorPosition()
	pFoundItem = nil

	fCurX = ( fCurX or 0.5 ) * scx
	fCurY = ( fCurY or 1.0 ) * scy

	fCurX = Clamp( posX, fCurX, posX + sizeX )
	fCurY = Clamp( posY, fCurY, posY + sizeY )

	local fCurRotation = ( 360 - math.deg( math.atan2( fCurX - iX2, fCurY - iY2 ) ) ) % 360
	local fProgress	= Clamp( 0.0, ( iTick - iLastTick ) / 300, 1.0 )
	fProgress = getEasingValue( fProgress, "InOutQuad" )
	local pColor = tocolor(255,255,255,fProgress*255)

	if fProgress >= 1 then
		setCursorPosition( fCurX, fCurY )
	end

	dxDrawRectangle( 0, 0, scx, scy, tocolor( 24, 31, 39, fProgress*210 ) )
	if iRadialMode == 1 then

		dxDrawImage( posX, posY, sizeX, sizeY, "files/img/Circle1.png", 0, 0, 0, pColor)
		dxDrawImage( posX, posY, sizeX, sizeY, "files/img/Circle.png", fCurRotation, 0, 0, pColor)

		for i, item in pairs(pItems) do
			local fAngle = ( ( i - 1 ) * 45 ) % 360
			
			local fX = iX2 + ( ( math.cos( math.rad( fAngle + 90 ) ) ) * ( ( sizeX * 0.5 - 171 ) * fProgress ) )
			local fY = iY2 + ( ( math.sin( math.rad( fAngle + 90 ) ) ) * ( ( sizeX * 0.5 - 171 ) * fProgress ) )

			local iSize = 32*fProgress

			if fProgress >= 1 then
				if ( fAngle - ( fCurRotation - 22.5 ) ) % 360 < 45 then
					pFoundItem = item;
				end
			end

			local iAlpha = pFoundItem == item and 255 or 100

			dxDrawImage( math.floor(fX - ( iSize / 2 )), math.floor(fY - ( iSize / 2 )), iSize, iSize, "files/img/icons/"..item.sIcon..".png", 0, 0, 0, tocolor(255,255,255,iAlpha), true );
		end

		dxDrawText( pFoundItem and pFoundItem.sText or "", iX2, iY2, iX2, iY2, pColor, 1, font, "center", "center" )

		if not localPlayer:getData( "tutorial" ) then
			dxDrawImage( posX+420, posY+420, 180, 52, "files/img/hint_1.png", 0, 0, 0, pColor )
		end

	elseif iRadialMode == 2 then
		dxDrawImage( posX, posY, sizeX, sizeY, "files/img/bg.png", 0, 0, 0,pColor)
		local angle = math.atan2( posX+sizeX/2 - fCurX, posY+sizeY/2 - fCurY )
		angle = (-math.deg(angle)+20) % 360
		iSection = math.ceil( angle / fSectionSize )

		dxDrawImage( posX, posY, sizeX, sizeY, "files/img/sections/"..iSection..".png", 0, 0, 0,pColor)
		for i = 1, 8 do
			local fAngle = math.rad( fSectionSize*i - 135 * fProgress )

			local fX = c_x + math.cos( fAngle ) * fBiasMultiplier * fProgress
			local fY = c_y + math.sin( fAngle ) * fBiasMultiplier * fProgress
			if pUserPreset[i] then
				local pDance = DANCES_LIST[ pUserPreset[i] ]
				if pDance then
					dxDrawImage( math.floor(fX-50), math.floor(fY-50), 100, 100, ":nrp_dancing_school/files/img/icons/"..pDance.icon..".png", 0, 0, 0, tocolor(255,255,255,fGAlpha) )
					dxDrawText(pDance.name,fX, fY+50, fX, fY+50, pColor, 1, font2, "center", "center")
				end
			end
		end
		dxDrawImage( posX+sizeX/2-60, posY+sizeY/2-60, 120, 120, "files/img/radial_core.png", 0, 0, 0,pColor)

		dxDrawImage( posX+700, posY+620, 209, 52, "files/img/hint_2.png", 0, 0, 0,pColor )
	end
end

function CollectPossibleActions()
	local pElements = GetNearestInteractiveElements( localPlayer )
	local pOutput = {}
	for i, action in pairs(RADIAL_ACTIONS) do
		if pElements[action.sTargetType] then
			if action:fClientCheck( pElements[action.sTargetType] ) then
				action:fPrepareClientData( pElements[action.sTargetType] )
				if action.child_items then
					for i, item in pairs( action.child_items ) do
						table.insert(pOutput, item)
						if #pOutput >= MAX_ITEMS_COUNT then
							return pOutput
						end
					end
				else
					table.insert(pOutput, action)
					if #pOutput >= MAX_ITEMS_COUNT then
						return pOutput
					end
				end
			end
		end
	end

	return pOutput
end

function ToggleRadialMenu( key, press, bForced )
	if press == "down" then
		if localPlayer.dead then return end
		
		if getElementData(localPlayer, "radial_disabled") then return end
		if isCursorShowing() and not localPlayer:getData( "bFirstPerson" ) then return end
		if getTickCount() - iTempRadialBlock <= 1500 then return end

		-- Блокировка в неарендованной машине
		local pVehicle = getPedOccupiedVehicle( localPlayer )
		if pVehicle and pVehicle.controller == localPlayer then
			if getElementData(pVehicle,"rentable") then
				if pVehicle:GetOwnerID() ~= localPlayer:GetUserID() then
					localPlayer:ShowError("Сначала оплати, потом трогай")
					return false
				end
			end

			-- Блокировка чужой машины
			local owner_id = pVehicle:GetOwnerID()
			if owner_id then
				local wedded = false
				local player_id = localPlayer:GetUserID()
				local pOwners = pVehicle:GetTempOwnersPID()
				pOwners[owner_id] = true
				
				if localPlayer:getData( "wedding_at_id" ) then
					if localPlayer:getData( "wedding_at_id" ) == owner_id then
						wedded = true
					end
				end

				if not pOwners[player_id] and not wedded then
					localPlayer:ShowError("Это не Ваш автомобиль")
					return false
				end
			end
		end

		triggerEvent( "onClientChangeInterfaceState", root, true, { radial_menu = true } )
		pItems = CollectPossibleActions()
		showCursor(true, false )
		setCursorAlpha( 0 )
		iLastTick = getTickCount()
		addEventHandler("onClientRender", root, DrawRadialMenu)
		setCursorPosition( scx/2, scy/2+sizeY/4 )
		bRadialShown = true
		SwitchRadialMode( 1 )
	elseif bRadialShown then
		showCursor(false, false )
		setCursorAlpha( 255 )
		removeEventHandler("onClientRender", root, DrawRadialMenu)
		triggerEvent( "onClientChangeInterfaceState", root, false, { radial_menu = true } )
		if localPlayer.dead then return end

		if iRadialMode == 1 then
			if pFoundItem and not bForced then
				if LAST_ACTION_DONE > getTickCount() then return end
				if pFoundItem:fClientCheck( ) then
					if pFoundItem.fClientApply then pFoundItem:fClientApply( ) end
					if not pFoundItem.client_only then
						triggerServerEvent( "OnRadialMenuActionApply", localPlayer, pFoundItem.id, localPlayer, pFoundItem.target, pFoundItem.args )
					end
					LAST_ACTION_DONE = getTickCount() + 500
				end
			end
		elseif iRadialMode == 2 then
			if iSection then
				local pUserPreset = localPlayer:getData("animations_preset") or {}
				if pUserPreset[iSection] then
					local is_in_story_quest = false
					local current_quest = localPlayer:getData( "current_quest" )
					if current_quest then
						for i, v in pairs( REGISTERED_QUESTS ) do
							if v == current_quest.id then
								is_in_story_quest = true
								break
							end
						end
					end
					if current_quest and not is_in_story_quest then
						localPlayer:ShowError( "Нельзя совершить это действие во время выполнения задачи" )
						return
					end
					triggerServerEvent("OnPlayerStartDancing", localPlayer, pUserPreset[iSection])
				end
			end
		end

		pFoundItem = nil
		bRadialShown = false
		iRadialMode = 1
	end
end
bindKey("tab", "both", ToggleRadialMenu)

bindKey("e", "down", function()
	if bRadialShown then
		if iRadialMode == 1 then
			SwitchRadialMode( 2 )
		elseif iRadialMode == 2 then
			SwitchRadialMode( 1 )
		end
	end
end)


function SwitchRadialMode( iMode )
	iLastTick = getTickCount()
	if iMode == 1 then
		sizeX, sizeY = 580, 580
		posX, posY = scx/2-sizeX/2, scy/2-sizeY/2
	elseif iMode == 2 then
		if not DANCES_LIST or not next(DANCES_LIST) then
			DANCES_LIST = exports.nrp_dancing_school:GetDancesList() or {}
		end
		pUserPreset = localPlayer:getData("animations_preset") or {}
		sizeX, sizeY = 977, 720
		posX, posY = scx/2-sizeX/2, scy/2-sizeY/2
	end

	iRadialMode = iMode
end

addEventHandler("onClientVehicleStartExit", root, function( player )
	if player == localPlayer then
		ToggleRadialMenu(_, false, true)
		iTempRadialBlock = getTickCount()
	end
end)

addEventHandler("onClientVehicleStartEnter", root, function( player )
	if player == localPlayer then
		ToggleRadialMenu(_, false, true)
		iTempRadialBlock = getTickCount()
	end
end)

addEventHandler("onClientVehicleExit", root, function( player )
	if player == localPlayer then
		ToggleRadialMenu(_, false, true)
		iTempRadialBlock = 0
	end
end)

addEventHandler("onClientVehicleEnter", root, function( player )
	if player == localPlayer then
		ToggleRadialMenu(_, false, true)
		iTempRadialBlock = 0
	end
end)

addEvent( "OnClientRadialMenuActionApply" )