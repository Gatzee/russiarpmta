scx, scy = guiGetScreenSize()

local ui = {}
local tex = {}

local iCurrentSchool = 1

function ShowUI_School( state, school_id )
	if state then
		local k, v = LICENSE_TYPE_BOAT, SPECIAL_LICENSES_LIST[ LICENSE_TYPE_BOAT ]
		local iLicenseState = localPlayer:GetLicenseState( k )

		if iLicenseState == LICENSE_STATE_TYPE_PASSED then
			localPlayer:ShowError("У тебя уже есть права этой категории")
			return
		end

		ShowUI_School( false )
		showCursor( true )

		iCurrentSchool = school_id

		if iLicenseState == LICENSE_STATE_TYPE_BOUGHT then
			ui.confirm = ibConfirm(
				{
					title = "НАЧАЛО ОБУЧЕНИЯ", 
					text = "Ты хочешь начать обучение?" ,
					fn = function( self )
						ShowUI_School( false )
						ShowUI_Theory( true, k )
						self:destroy()
					end,
					fn_cancel = function( )
						ShowUI_School( false )
					end,
					escape_close = true,
				}
			)
		elseif iLicenseState < LICENSE_STATE_TYPE_BOUGHT then
			ui.confirm = ibConfirm(
				{
					title = "ОПЛАТА ОБУЧЕНИЯ", 
					text = "Ты хочешь оплатить обучение за " .. format_price(v.cost) .. "р. ?" ,
					fn = function( self )
						ShowUI_School( false )
						triggerServerEvent("OnPlayerTryBuySpecialLicense", resourceRoot, k, iCurrentSchool)
						self:destroy()
					end,
					fn_cancel = function( )
						ShowUI_School( false )
					end,
					escape_close = true,
				}
			)
		end
	else
		if ui.confirm then
			ui.confirm:destroy( )
		end

		DestroyTableElements( ui )
		DestroyTableElements( tex )
		showCursor(false)
	end
end
addEvent("ShowUI_School", true)
addEventHandler("ShowUI_School", resourceRoot, ShowUI_School)

function ShowUI_Theory( state, iLicense )
	if state then
		ShowUI_Theory( false )
		showCursor( true )

		ui.bg = ibCreateImage( 0, 0, scx, scy, nil, false, 0x90495f76 )
		ui.main = ibCreateImage( 0, 0, 789, 541, "files/img/bg.png", ui.bg ):center()

		ui.close = ibCreateButton( 789-50, 25, 24, 24, ui.main, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				ShowUI_Theory(false)
			end
		end)

		ui.start_exam = ibCreateButton( 215, 440, 359, 46, ui.main, "files/img/btn_start_exam.png", "files/img/btn_start_exam_hovered.png", "files/img/btn_start_exam_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				triggerServerEvent("OnPlayerTryStartSpecialExam", resourceRoot, iLicense, iCurrentSchool)
				ShowUI_Theory(false)
			end
		end)
		:ibData("alpha", 100)
		:ibData("disabled", true)

		ui.timer_text = ibCreateLabel( 215, 510, 359, 0, "0:15", ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_22 )

		ui.timer = setTimer( function( )
			local _, count = getTimerDetails( sourceTimer )
			count = count - 1
			if isElement(ui.start_exam) then
				if count == 0 then
					ui.start_exam:ibAlphaTo( 255, 1000 )
					ui.start_exam:ibData("disabled", false)
					destroyElement( ui.timer_text )
				else
					ui.timer_text:ibData( "text", "0:".. ( count > 9 and count or ( "0" ..count ) ) )
				end
			end
		end, 1000, 15 )

	else
		if isTimer( ui.timer ) then
			killTimer( ui.timer )
		end
		DestroyTableElements( ui )
		showCursor( false )
	end
end

--ShowUI_School( true, 1 )