local scx, scy = guiGetScreenSize()

local posX, posY = 20, 110
local sizeX, sizeY = 248, 301

ibUseRealFonts( true )

local ui = {}

local pScreenSource = dxCreateScreenSource( scx, scy )
local pData

function CreateFinePhoto( data )
	pData = data
	dxUpdateScreenSource( pScreenSource )
end

function ShowFinePhoto( state )
	if state then
		ShowFinePhoto( false )

		if not pData then return end

		local sound = playSound( "files/sounds/photo.mp3" )

		local screen_x, screen_y = getScreenFromWorldPosition( localPlayer.vehicle.position )

		if screen_x and screen_y then
			ui.bg = ibCreateImage( posX, scy, sizeX, sizeY, nil, false, 0xbe212b36 )

			local px, py = screen_x-scy/2, 0

			ui.shot = ibCreateImage( 2, 2, 244, 244, pScreenSource, ui.bg )
			:ibBatchData( { u = px, v = py, u_size = scy, v_size = scy } )
		else
			-- Показываем без фотки
			ui.bg = ibCreateImage( posX, scy, sizeX, sizeY, "files/img/no_photo.png" )
		end

		ui.bg:ibMoveTo( posX, posY, 1000 )
		:ibTimer( function()

			ui.bg:ibAlphaTo(0, 3000)
			ui.bg:ibMoveTo( posX, -sizeY, 3000 )
			:ibTimer(function()
				ShowFinePhoto( false )
			end, 3000, 1)

		end, 5000, 1)

		local l_plate = ibCreateLabel( 8, 250, 0, 0, "Гос.номер:", ui.bg, 0x98ffffff, _, _, _, _, ibFonts.regular_12 )
		ibCreateLabel( l_plate:ibGetAfterX(5), 250, 0, 0, pData.number_plate, ui.bg, 0xffffffff, _, _, _, _, ibFonts.regular_12 )

		local l_speed = ibCreateLabel( 8, 265, 0, 0, "Скорость:", ui.bg, 0x98ffffff, _, _, _, _, ibFonts.regular_12 )
		ibCreateLabel( l_speed:ibGetAfterX(5), 265, 0, 0, pData.speed.." км/ч", ui.bg, 0xffffffff, _, _, _, _, ibFonts.regular_12 )

		local l_speed_limit = ibCreateLabel( 8, 280, 0, 0, "Разрешенная скорость:", ui.bg, 0x98ffffff, _, _, _, _, ibFonts.regular_12 )
		ibCreateLabel( l_speed_limit:ibGetAfterX(5), 280, 0, 0, pData.speed_limit.." км/ч", ui.bg, 0xffffffff, _, _, _, _, ibFonts.regular_12 )

		local l_fine_sum = ibCreateLabel( sizeX-8, 250, 0, 0, pData.fine.."р", ui.bg, 0xffffffff, _, _, "right", "top", ibFonts.bold_12 )
		local l_fine = ibCreateLabel( l_fine_sum:ibGetBeforeX(-5), 250, 0, 0, "Штраф:", ui.bg, 0xffe34c4c, _, _, "right", "top", ibFonts.bold_12 )
	else
		for k,v in pairs( ui ) do
			if isElement( v ) then
				destroyElement( v )
			end
		end
	end
end

function OnClientReceiveSpeedRadarFine()
	ShowFinePhoto( true )
end
addEvent("OnClientReceiveSpeedRadarFine", true)
addEventHandler("OnClientReceiveSpeedRadarFine", root, OnClientReceiveSpeedRadarFine)