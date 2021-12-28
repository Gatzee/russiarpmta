local pDefaultGunPosition = 
{ 
	[ CASINO_THREE_AXE ] = { -87.002, -470.934, 913.92, 90, 90, 0 },
	[ CASINO_MOSCOW ] = { 2399.100, -1285.747, 2794.659, 90, 90, 0 },
}

local pLastGunPosition = {}

local iAnimationStage = 0
local iStageStarted = 0

local pData = {}
local pGun

function StartShot( data )
	pData = data

	iAnimationStage = 0
	iStageStarted = getTickCount()

	setPedAnimation( data.player, "BAR", "Barcustom_get", -1 , false, false, false, false )

	addEventHandler("onClientPreRender", root, PreRenderShot )
end

function CreateGun()
	pGun = createObject( 1339, unpack(pDefaultGunPosition[ pGameData.casino_id ]) )
	pGun.interior = localPlayer.interior
	pGun.dimension = localPlayer.dimension
	pGun.scale = 1.6
	pGun.collisions = false
end

function DestroyGun()
	pData = {}
	if isElement(pGun) then destroyElement( pGun ) end
	removeEventHandler("onClientPreRender", root, PreRenderShot)
end

function PreRenderShot()
	if iAnimationStage == 0 then -- Взятие револьвера со стола
		local fProgress = (getTickCount() - iStageStarted) / 1500

		if fProgress >= 1 then
			exports.bone_attach:attachElementToBone( pGun, pData.player, 12, 0, 0, -0.04, 0, -90, 0 )
			NextAnimationStage()
		end
	elseif iAnimationStage == 1 then -- Задежка анимации взятия
		local fProgress = (getTickCount() - iStageStarted) / 1000

		if fProgress >= 1 then
			NextAnimationStage()

			setPedAnimation( pData.player, "CASINO_ROULETTE", pData.result and "suicid2" or "suicid1", -1, false, false, false, true )
		end
	elseif iAnimationStage == 2 then -- Поднесение к виску
		local fProgress = (getTickCount() - iStageStarted) / 1000

		if fProgress >= 1 then
			NextAnimationStage()
		end
	elseif iAnimationStage == 3 then -- Выстрел
		local fProgress = (getTickCount() - iStageStarted) / 100

		if fProgress >= 1 then
			local x, y, z = getElementPosition( pGun )
			local hx, hy, hz = getPedBonePosition( pData.player, 8 )

			if pData.result then
				fxAddBlood( hx, hy, hz, 0, 0, 0, math.random(1,3), 1 )
				playSound( "sfx/shot"..math.random(1,2)..".wav" )

				if pData.player == localPlayer then
					YouDied()
				end
			else
				playSound( "sfx/click"..math.random(1,3)..".wav" )
			end

			pLastGunPosition = { x, y, pDefaultGunPosition[ pGameData.casino_id ][3] + 0.2, 85, 0, 0 }

			local def_data = pDefaultGunPosition[ pGameData.casino_id ]
			pTargetGunPosition = { def_data[1] +math.random(-2, 2)/10, def_data[2]+math.random(-2, 2)/10, def_data[3], 90, 360+math.random(0,180), 0 }

			NextAnimationStage()
		end
	elseif iAnimationStage == 4 then -- Возврат револьвера
		local fProgress = (getTickCount() - iStageStarted) / 800

		if pData.result then
			exports.bone_attach:detachElementFromBone( pGun )

			local x, y, z = interpolateBetween( pLastGunPosition[1], pLastGunPosition[2], pLastGunPosition[3], pTargetGunPosition[1], pTargetGunPosition[2], pTargetGunPosition[3], fProgress, "Linear" )
			local rx, ry, rz = interpolateBetween( pLastGunPosition[4], pLastGunPosition[5], pLastGunPosition[6], pTargetGunPosition[4], pTargetGunPosition[5], pTargetGunPosition[6], fProgress, "OutBounce" )

			setElementPosition(pGun, x, y, z)
			setElementRotation(pGun, rx, ry, rz)
		end

		if fProgress >= 1 then
			if not pData.result then
				--setPedAnimation(pData.player, "CLOTHES", "CLO_Pose_Shoes", -1, false, false, true, false)
				setPedAnimation(pData.player, "GRENADE", "WEAPON_throwu", -1, false, false, true, false)
			end

			NextAnimationStage()
		end
	elseif iAnimationStage == 5 then
		local fProgress = (getTickCount() - iStageStarted) / 800

		if pData.result then
			removeEventHandler("onClientPreRender", root, PreRenderShot )
		else
			exports.bone_attach:detachElementFromBone( pGun )

			local x, y, z = interpolateBetween( pLastGunPosition[1], pLastGunPosition[2], pLastGunPosition[3], pTargetGunPosition[1], pTargetGunPosition[2], pTargetGunPosition[3], fProgress, "Linear" )
			local rx, ry, rz = interpolateBetween( pLastGunPosition[4], pLastGunPosition[5], pLastGunPosition[6], pTargetGunPosition[4], pTargetGunPosition[5], pTargetGunPosition[6], fProgress, "OutBounce" )

			setElementPosition(pGun, x, y, z)
			setElementRotation(pGun, rx, ry, rz)
		end

		if fProgress >= 1 then
			removeEventHandler("onClientPreRender", root, PreRenderShot )
		end
	end
end

function NextAnimationStage()
	iAnimationStage = iAnimationStage + 1
	iStageStarted = getTickCount()
end

local pMemeFont
local iMemeStarted = 0

function YouDied()
	playSound( "sfx/youdied.wav" )
	pMemeFont = dxCreateFont("img/font.ttf", 69)
	iMemeStarted = getTickCount()

	addEventHandler("onClientRender", root, RenderYouDied)
end

function RenderYouDied()
	local fProgress = (getTickCount() - iMemeStarted)/5000

	dxDrawRectangle( 0, 0, scx, scy, 0xFF000000 )
	dxDrawText( "YOU DIED", 0, 0, scx, scy, 0xFFAA0000, 0.8+0.2*fProgress, pMemeFont, "center", "center" )

	if fProgress >= 1 then
		removeEventHandler("onClientRender", root, RenderYouDied)
		destroyElement( pMemeFont )
	end
end