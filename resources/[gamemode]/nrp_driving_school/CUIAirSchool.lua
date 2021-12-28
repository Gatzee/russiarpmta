local size_x, size_y = 550, 330
local pos_x, pos_y = ( _SCREEN_X - size_x ) / 2, ( _SCREEN_Y - size_y ) / 2
local ui = { }
local current_school = 1

AIR_SCHOOL_LICENSES_LIST =
{
	[ LICENSE_TYPE_AIRPLANE ] =
	{
		title = "Самолёты",
		cost = 48750,
		icon = "img/air/icon_airplane.png",
		theory = "img/air/bg_theory_airplane.png",
	},

	[ LICENSE_TYPE_HELICOPTER ] =
	{
		title = "Вертолёты",
		cost = 48750,
		icon = "img/air/icon_helicopter.png",
		theory = "img/air/bg_theory_helicopter.png",
	},
}

function OnShowUIAirSchool_handler( state, school_id )
	if state then
		ibInterfaceSound( )
		OnShowUIAirSchool_handler( false )
		showCursor( true )

		current_school = school_id
		ui.bg = ibCreateBackground( 0x90495f76, OnShowUIAirSchool_handler, true, true )
		ui.texture = {}
		ui.main = ibCreateImage( pos_x, pos_y, size_x, size_y, "img/air/bg.png", ui.bg )
		ui.close = ibCreateButton( size_x - 50, 25, 24, 24, ui.main, "img/air/btn_close.png", "img/air/btn_close.png", "img/air/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				OnShowUIAirSchool_handler( false )
				ibClick( )
			end
		end)

		local px, py = 40, 100
		for k, v in pairs( AIR_SCHOOL_LICENSES_LIST ) do
			if not ui.texture[ k ] then
				local texture = dxCreateTexture( v.icon )
				local sx, sy = dxGetMaterialSize( texture )
				ui.texture[ k ] = { texture, sx, sy }
			end

			local box = ibCreateButton( px, py, 230, 200, ui.main, "img/air/box.png", "img/air/box_hovered.png", "img/air/box_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( button, state )
				if button == "left" and state == "down" then
					local license_state = localPlayer:GetLicenseState( k )

					if ui.confirm then
						ui.confirm:destroy( )
					end

					if license_state == LICENSE_STATE_TYPE_BOUGHT then
						ui.confirm = ibConfirm( {
							title = "НАЧАЛО ОБУЧЕНИЯ",
							text = "Ты хочешь начать обучение?",
							fn = function( self )
								OnShowUIAirSchool_handler( false )
								ShowUITheoryAirSchool( true, k )
								self:destroy( )
							end,
							escape_close = true,
						} )
					elseif license_state < LICENSE_STATE_TYPE_BOUGHT then
						ui.confirm = ibConfirm( {
							title = "ОПЛАТА ОБУЧЕНИЯ",
							text = "Ты хочешь оплатить обучение за " .. format_price( v.cost ) .. "р. ?",
							fn = function( self )
								triggerServerEvent( "OnTryPayLicense", resourceRoot, k, current_school, "air" )
								self:destroy( )
							end,
							escape_close = true,
						} )
					elseif license_state == LICENSE_STATE_TYPE_PASSED then
						localPlayer:ShowError( "У тебя уже есть права этой категории" )
					end
				end
			end)
			ibCreateImage( 230 / 2 - ui.texture[ k ][ 2 ] / 2, 20, ui.texture[ k ][ 2 ], ui.texture[ k ][ 3 ], ui.texture[ k ][ 1 ], box ):ibData( "disabled", true )
			ibCreateLabel( 0, 130, 230, 0, v.title, box, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_21 )
			
			local license_state = localPlayer:GetLicenseState( k )

			if license_state < LICENSE_STATE_TYPE_BOUGHT then
				local cost = ibCreateLabel( 0, 160, 210, 0, format_price( v.cost ), box, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_18 )
				ibCreateImage( 230 / 2 + cost:width( ) / 2, 148, 28, 23, "img/air/icon_money.png", box ):ibData( "disabled", true )
			elseif license_state == LICENSE_STATE_TYPE_BOUGHT then
				ibCreateLabel( 0, 160, 230, 0, "Начать экзамен", box, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData(" font", ibFonts.regular_18 )
			elseif license_state == LICENSE_STATE_TYPE_PASSED then
				ibCreateLabel( 0, 160, 230, 0, "Получено", box, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_18 )
			end

			px = px + 250
		end
	else
		if isElement( ui.bg ) then destroyElement( ui.bg ) end
		if isElement( ui.texture ) then destroyElement( ui.texture ) end
		if ui.confirm then ui.confirm:destroy( ) end

		showCursor( false )
	end
end
addEvent( "OnShowUIAirSchool", true )
addEventHandler( "OnShowUIAirSchool", resourceRoot, OnShowUIAirSchool_handler )

function ShowUITheoryAirSchool( state, license )
	if state then
		if isTimer( ui.timer ) then
			killTimer( ui.timer )
		end

		ShowUITheoryAirSchool( false )
		showCursor( true )

		ui.bg = ibCreateBackground( 0x90495f76, ShowUITheoryAirSchool, true, true )		
		ui.main = ibCreateImage( 0, 0, 789, 561, AIR_SCHOOL_LICENSES_LIST[ license ].theory, ui.bg ):center( )

		ui.close = ibCreateButton( 789 - 50, 25, 24, 24, ui.main, "img/air/btn_close.png", "img/air/btn_close.png", "img/air/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				ShowUITheoryAirSchool( false )
			end
		end)

		ui.start_exam = ibCreateButton( 789 / 2 - 359 / 2, 480, 359, 46, ui.main, "img/air/btn_start_exam.png", "img/air/btn_start_exam_hovered.png", "img/air/btn_start_exam_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				triggerServerEvent( "OnTryStartExam", resourceRoot, license, current_school, "air" )
				ShowUITheoryAirSchool( false )
			end
		end)
		:ibData( "alpha", 100 )
		:ibData( "disabled", true )

		ui.timer_text = ibCreateLabel( 215, 545, 359, 0, "0:15", ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_22 )

		ui.timer = setTimer( function( )
			local _, count = getTimerDetails( sourceTimer )
			count = count - 1
			if isElement( ui.start_exam ) then
				if count == 0 then
					ui.start_exam:ibAlphaTo( 255, 1000 )
					ui.start_exam:ibData( "disabled", false )
					destroyElement( ui.timer_text )
				else
					ui.timer_text:ibData( "text", "0:".. ( count > 9 and count or ( "0" ..count ) ) )
				end
			end
		end, 1000, 15 )
	else
		if isElement( ui.bg ) then destroyElement( ui.bg ) end
		showCursor( false )
	end
end