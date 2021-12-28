ibUseRealFonts( true )
local ui = { }
local resolved_questions = { }
local theory_ticket = nil
local current_license_type = 2
local awaiting_for_next_question = false
local update_timer = nil
local theory_time_left = 300

local assoc_image_folders =
{
	[ 0 ] = "all",
	[ LICENSE_TYPE_MOTO ] = "moto",
	[ LICENSE_TYPE_AUTO ] = "auto",
	[ LICENSE_TYPE_TRUCK ] = "truck",
	[ LICENSE_TYPE_BUS ] = "bus",
}

local included_categories =
{
	[ LICENSE_TYPE_MOTO ] = true,
	[ LICENSE_TYPE_AUTO ] = true,
	[ LICENSE_TYPE_TRUCK ] = true,
	[ LICENSE_TYPE_BUS ] = true,
}

function OnShowUIAutoSchool_handler( state, name )
    if state then
        OnShowUIAutoSchool_handler( false )
        localPlayer.frozen = true
        showCursor( true )

		ui.bg = ibCreateBackground( 0xAA000000, OnShowUIAutoSchool_handler, true, true )

        if name == "main" then
            local pos_x, pos_y = ( _SCREEN_X - 550 ) / 2, ( _SCREEN_Y - 480 ) / 2
            local size_x, size_y = 550, 480
            local sx, sy = 40, 60

			resolved_questions = { }
			theory_ticket = 1

            ibInterfaceSound( )

			ui.window = ibCreateImage( pos_x, pos_y, size_x, size_y, "img/auto/items/categories_bg.png", ui.bg )
			ui.btn_close = ibCreateButton( pos_x + size_x - 30, pos_y - 30, 25, 25, ui.bg, "img/auto/close.png", "img/auto/close.png", "img/auto/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )

            for k, v in pairs( LICENSES_DATA ) do
                if included_categories[ k ] then
                    ui[ "license_btn" .. k ] = ibCreateButton( sx, sy, 230, 180, ui.window, "img/auto/items/" .. k .. ".png", "img/auto/items/" .. k .. "_h.png", "img/auto/items/" .. k .. "_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                        if not v.bEnabled then localPlayer:ShowInfo( "Права этой категории ещё в разработке" ) return false	end

                        current_license_type = k

                        if localPlayer:GetLicenseState( k ) and localPlayer:GetLicenseState( k ) >= LICENSE_STATE_TYPE_BOUGHT then
                            OnShowUIAutoSchool_handler( true, "stages" )
                        else
                            if ui.confirmation then DestroyTableElements( ui.confirmation ) end

                            ui.confirmation = ibConfirm(
                                {
                                    title = "ОПЛАТА ОБУЧЕНИЯ",
                                    text = "Вы подтверждаете оплату обучения на категорию " .. LICENSES_DATA[ k ].sName .. "?\nСтоимость: " .. format_price( LICENSES_DATA[ k ].iPrice ) .. " руб",
                                    fn = function( self )
                                        triggerServerEvent( "OnTryPayLicense", localPlayer, k, false, "auto" )
                                        self:destroy( )
									end,
									escape_close = true,
                                }
                            )
                        end
                    end)


                    ibCreateLabel( 110, 138, 230, 30, v.iPrice, ui[ "license_btn" .. k ], 0xffffffff, _, _, _, _, ibFonts.regular_16 ):ibData( "disabled", true )

                    sx = sx + 250
					if sx >= 300 then sx, sy = 40, 260 end
                end
			end
        elseif name == "pay" then
            local pos_x, pos_y = ( _SCREEN_X - 550 ) / 2, ( _SCREEN_Y - 480 ) / 2
            local size_x, size_y = 550, 480
            local sx, sy = 40, 60

			ui.window = ibCreateImage( pos_x, pos_y, size_x, size_y, "img/auto/items/categories_bg.png", ui.bg )
			ui.btn_close = ibCreateButton( pos_x + size_x - 30, pos_y - 30, 25, 25, ui.bg,
				"img/auto/close.png", "img/auto/close.png", "img/auto/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )

			for k, v in pairs( LICENSES_DATA ) do
                ui[ "license_btn" .. k ] = ibCreateButton( sx, sy, 230, 180, ui.window,
                    "img/auto/items/" .. k .. ".png", "img/auto/items/" .. k .. "_h.png", "img/auto/items/" .. k .. "_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

                ibCreateLabel( 110, 138, 230, 30, v.iPrice, ui[ "license_btn" .. k ], 0xffffffff, _, _, _, _, ibFonts.regular_16 ):ibData( "disabled", true )

                sx = sx + 250
                if sx >= 300 then sx, sy = 40, 260 end
			end
        elseif name == "stages" then
            local size_x, size_y = 550, 350
            local pos_x, pos_y = ( _SCREEN_X - size_x ) / 2, ( _SCREEN_Y - size_y ) / 2

			ui.window = ibCreateImage( pos_x, pos_y, size_x, size_y, "img/auto/stages/bg.png", ui.bg )
			ui.btn_close = ibCreateButton( pos_x + size_x - 30, pos_y - 30, 25, 25, ui.bg,
				"img/auto/close.png", "img/auto/close.png", "img/auto/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )

			local visible_stages = 
			{
				{
					sName = "stages/info",
					px = 40,
					py = 250,
					sx = 478,
					sy = 65,
					OnClick = function( )
						OnShowUIAutoSchool_handler( true, "theory" )
					end,
					IsAvailable = function( )
						return true, "not_passed"
					end,
				},
				{
					sName = "stages/theory",
					px = 40,
					py = 40,
					sx = 230,
					sy = 180,
					OnClick = function( )
						OnShowUIAutoSchool_handler( false )
						ShowPopup( true, "exam_theory" )
					end,
					IsAvailable = function()
						local state = localPlayer:GetLicenseState( current_license_type ) or 0
						if state < LICENSE_STATE_TYPE_CUSTOM1 then
							return true, "not_passed"
						end

						return false, "passed"
					end,
				},
				{
					sName = "stages/driving",
					px = 280,
					py = 40,
					sx = 230,
					sy = 180,
					OnClick = function( )
						OnShowUIAutoSchool_handler( false )
						local school = getElementData( localPlayer, "iDrivingSchool" )
						triggerServerEvent( "OnTryStartExam", localPlayer, current_license_type, school, "auto" )
					end,
					IsAvailable = function()
						local state = localPlayer:GetLicenseState( current_license_type ) or 0
						if state == LICENSE_STATE_TYPE_CUSTOM1 then
							return true, "not_passed"
						elseif state < LICENSE_STATE_TYPE_CUSTOM1 then
							return false, "not_passed"
						elseif state >= LICENSE_STATE_TYPE_PASSED then
							return false, "passed"
						end

						return false, "not_passed"
					end,
				},
			}

			for k, v in pairs( visible_stages ) do
				if v.IsAvailable( ) then
					ui[ "bStage" .. k ] = ibCreateButton( v.px, v.py, v.sx, v.sy, ui.window, "img/auto/" .. v.sName .. ".png", "img/auto/" .. v.sName .. "_h.png", "img/auto/" .. v.sName .. "_h.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF )
					:ibOnClick( function( button, state )
						if button ~= "left" or state ~= "down" then return end
						v.OnClick( )
					end)

				else
					ui[ "bStage" .. k ] = ibCreateButton( v.px, v.py, v.sx, v.sy, ui.window, "img/auto/" .. v.sName .. ".png", "img/auto/" .. v.sName .. "_h.png", "img/auto/" .. v.sName .. "_h.png", 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF ):ibData( "disabled", true )
				end
				if k ~= 1 then
					local _, reason = v.IsAvailable( )
					ui[ "bStagePassed" .. k ] = ibCreateImage( 60, 145, 110, 18, "img/auto/stages/" .. reason .. ".png", ui[ "bStage" .. k ] ):ibData( "disabled", true )
				end
			end
		elseif name == "theory" then
			local size_x, size_y = 800, 600
            local pos_x, pos_y = ( _SCREEN_X - size_x ) / 2, ( _SCREEN_Y - size_y ) / 2
			local btn_last_question = theory_ticket >= #AUTO_SCHOOL_QUESTIONS[ current_license_type ]
			
			ui.window = ibCreateImage( pos_x, pos_y, size_x, size_y, nil, ui.bg, 0xff485b70 )
			ui.btn_close = ibCreateButton( size_x - 50, 22, 24, 24, ui.window,
				"img/auto/btn_close.png", "img/auto/btn_close.png", "img/auto/btn_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )

			ibCreateLabel( 30, 0, 0, 70, "Подготовка к теории", ui.window, 0xffffffff, _, _, "left", "center", ibFonts.bold_18 )
			ibCreateLabel( size_x - 200, 0, 0, 70, "Вопрос", ui.window, 0xffffffff, _, _, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( size_x - 130, 0, 0, 70, theory_ticket .. "/" .. #AUTO_SCHOOL_QUESTIONS[ current_license_type ], ui.window, 0x80ffffff, _, _, "left", "center", ibFonts.bold_16 )
			ibCreateImage( 0, 70, size_x, 250, "img/auto/exam/" .. assoc_image_folders[ current_license_type ] .. "/" .. theory_ticket .. ".png", ui.window )

			local btn_prev = ibCreateButton( size_x/2-170, 526, 160, 44, ui.window,
				"img/auto/theory/btn_navigate.png", "img/auto/theory/btn_navigate.png", "img/auto/theory/btn_navigate.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF)
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				local next_ticket = theory_ticket - 1
				if AUTO_SCHOOL_QUESTIONS[ current_license_type ][ next_ticket ] then
					theory_ticket = theory_ticket - 1
					OnShowUIAutoSchool_handler( true, "theory" )
				end
			end)

			ibCreateLabel( 0, 0, 160, 44, "ПРЕДЫДУЩИЙ", btn_prev, 0xffffffff, _, _, "center", "center", ibFonts.bold_16 ):ibData( "disabled", true )
			
			local btn_next = ibCreateButton( size_x / 2 + 10, 526, 160, 44, ui.window,
				"img/auto/theory/btn_navigate.png", "img/auto/theory/btn_navigate.png", "img/auto/theory/btn_navigate.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF)
			:ibOnClick( function(button, state) 
				if button ~= "left" or state ~= "down" then return end
				if btn_last_question then
					OnShowUIAutoSchool_handler( true, "stages" )
					return
				end

				local next_ticket = theory_ticket + 1
				if AUTO_SCHOOL_QUESTIONS[ current_license_type ][ next_ticket ] then
					theory_ticket = theory_ticket + 1
					OnShowUIAutoSchool_handler( true, "theory" )
				end
			end)

			ibCreateLabel( 0, 0, 160, 44, btn_last_question and "ЗАКОНЧИТЬ" or "СЛЕДУЮЩИЙ", btn_next, 0xffffffff, _, _, "center", "center", ibFonts.bold_16 ):ibData( "disabled", true )
			
			-- Q
			ibCreateLabel( 0, 350, size_x, 0, AUTO_SCHOOL_QUESTIONS[ current_license_type ][ theory_ticket ].text, ui.window, 0xffffffff, _, _, "center", "top", ibFonts.regular_20 )

			-- A
			ibCreateLabel( 0, 414, size_x, 0, "Ответ:", ui.window, 0x80ffffff, _, _, "center", "top", ibFonts.regular_14 )
			ibCreateLabel( 0, 440, size_x, 0, AUTO_SCHOOL_QUESTIONS[ current_license_type ][ theory_ticket ].list[ AUTO_SCHOOL_QUESTIONS[ current_license_type ][ theory_ticket ].correct], ui.window, 0xffffffff, _, _, "center", "top", ibFonts.bold_24 )
		elseif name == "theory_exam" then
			awaiting_for_next_question = false

			local random_question = GetRandomQuestion( current_license_type, resolved_questions )
			local question = random_question[ 1 ]
			local category = random_question[ 2 ] and 0 or current_license_type

			local size_x, size_y = 800, 600
			local pos_x, pos_y = ( _SCREEN_X - size_x ) / 2, ( _SCREEN_Y - size_y ) / 2
			
			ui.window = ibCreateImage( pos_x, pos_y, size_x, size_y, nil, ui.bg, 0xff485b70 )
			ui.btn_close = ibCreateButton( size_x - 50, 22, 24, 24, ui.window,
				"img/auto/btn_close.png", "img/auto/btn_close.png", "img/auto/btn_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )

			ibCreateLabel( 30, 0, 0, 70, "Теория", ui.window, 0xffffffff, _, _, "left", "center", ibFonts.bold_18 )
			ibCreateLabel( size_x - 200, 0, 0, 70, "Вопрос", ui.window, 0xffffffff, _, _, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( size_x - 130, 0, 0, 70, #resolved_questions + 1  .. " / 5", ui.window, 0x80ffffff, _, _, "left", "center", ibFonts.bold_16 )
			ibCreateImage( 0, 70, size_x, 250, "img/auto/exam/" .. assoc_image_folders[ current_license_type ] .. "/" .. question .. ".png", ui.window )

			-- Timer
			ibCreateImage( size_x - 360, 26, 18, 20, "img/auto/exam/icon_timer.png", ui.window )
			ui.timer = ibCreateLabel( size_x - 330, 0, 0, 70, "5:00", ui.window, 0xffffde96, _, _, "left", "center", ibFonts.bold_16 )

			-- Q
			ibCreateLabel( 30, 350, size_x, 0, AUTO_SCHOOL_QUESTIONS[ category ][ question ].text, ui.window, 0xffffffff, _, _, "left", "top", ibFonts.regular_20 )

			local function timer( )
				theory_time_left = theory_time_left - 1
				if isElement( ui.timer ) and theory_time_left > 0 then
					local iMinutes = string.format( "%02d", math.floor( theory_time_left / 60 ) )
					local iSeconds = string.format( "%02d", theory_time_left - iMinutes*60 )

					ui.timer:ibData( "text", iMinutes .. ":" .. iSeconds )
				else
					if isTimer( update_timer ) then killTimer( update_timer ) end
					OnShowUIAutoSchool_handler( false )
				end
			end
			if isTimer( update_timer ) then killTimer( update_timer ) end
			timer( )
			update_timer = setTimer( timer, 1000, 0 )

			local sy = 390
			for k, v in pairs( AUTO_SCHOOL_QUESTIONS[ category ][ question ].list ) do
				local btn = ibCreateButton( 30, sy, 740, 54, ui.window, "img/auto/exam/answer.png", "img/auto/exam/answer_h.png", "img/auto/exam/answer_h.png" )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					if awaiting_for_next_question then return end

					local correct = AUTO_SCHOOL_QUESTIONS[ category ][ question ].correct == k
					table.insert( resolved_questions, { id = random_question[ 1 ], general = random_question[ 2 ], is_correct = correct } )

					if correct then
						local bg = ibCreateImage( 0, 0, 740, 54, "img/auto/exam/answer_h.png", source ):ibData( "priority", -1 )
						ibCreateImage( 740-63, 17, 43, 20, "img/auto/exam/icon_flags.png", bg )
					else
						local bg = ibCreateImage( 0, 0, 740, 54, "img/auto/exam/answer_h.png", source, 0xffaa2222 ):ibData( "priority", -1 )
					end

					awaiting_for_next_question = true
					setTimer( function( )
						if #resolved_questions < 5 then
							OnShowUIAutoSchool_handler( true, "theory_exam" )
						else
							if isTimer( update_timer ) then killTimer( update_timer ) end
							OnShowUIAutoSchool_handler( false )

							local mistakes = 0
							for k, v in pairs( resolved_questions ) do
								if not v.is_correct then
									mistakes = mistakes + 1
								end
							end

							local passed = mistakes <= 1

							if passed then
								triggerServerEvent( "OnPassedExamAuto", localPlayer, current_license_type, "theory", true )
								setTimer( ShowPopup, 50, 1, true, "theory_passed" )
							else
								triggerServerEvent( "OnPassedExamAuto", localPlayer, current_license_type, "theory", false )
								ShowPopup( true, "theory_failed" )
							end
						end
					end, 150, 1 )
				end)


				ibCreateLabel( 20, 0, 720, 54, k .. ". " .. v, btn, 0xffffffff, _, _, "left", "center", ibFonts.regular_18 ):ibData( "disabled", true )

				sy = sy + 64
			end
		end

		ui.btn_close:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			OnShowUIAutoSchool_handler( false )
        end)
	else
		if isElement( ui.bg ) then destroyElement( ui.bg ) end
		localPlayer.frozen = false
		showCursor( false )
	end
end
addEvent( "OnShowUIAutoSchool", true )
addEventHandler( "OnShowUIAutoSchool", root, OnShowUIAutoSchool_handler )

local popups_data =
{
	driving_passed =
	{
		title = "Экзамен сдан!",
		body = function( )
			local category_name = LICENSES_DATA[ current_license_type ].sName
			return "Поздравляем! Вы успешно преодолели все чекпоинты.\nВы получаете права категории " .. category_name
		end,
		btns =
		{
			{ "Спасибо", 120 }
		}
	},

	theory_passed =
	{
		title = "Поздравляем",
		body = function( )
			local mistakes = 0
			for k, v in pairs( resolved_questions ) do
				if not v.is_correct then
					mistakes = mistakes + 1
				end
			end
			return "Вы успешно сдали теорию. Ошибки: " .. mistakes .. "\nПереходите к следующему этапу"
		end,
		btns =
		{
			{ "Закрыть", 120 },
			{
				"Следующий этап",
				200,
				function( )
					local school = getElementData( localPlayer, "iDrivingSchool" )
					triggerServerEvent( "OnTryStartExam", localPlayer, current_license_type, school, "auto" )
				end
			},
		}
	},

	theory_failed =
	{
		title = "Экзамен провален",
		body = function( )
			local mistakes = 0
			for k, v in pairs( resolved_questions ) do
				if not v.is_correct then
					mistakes = mistakes + 1
				end
			end
			return "Вы допустили " .. mistakes .. " ошибки и провалили экзамен.\nВ следующий раз подготовьтесь лучше!"
		end,
		btns =
		{
			{ "Закрыть", 120 },
			{
				"Учить теорию",
				200,
				function( )
					OnShowUIAutoSchool_handler( true, "theory" )
				end,
			},
		}
	},

	error_passed =
	{
		title = "Ошибка",
		body = "У вас уже есть права этой категории!",
		btns =
		{
			{ "Закрыть", 120 },
		}
	},

	exam_theory =
	{
		title = "Экзамен теория",
		body = "Внимание! На все вопросы Вам дается 5 минут.\nРазрешается допустить 1 ошибку",
		btns =
		{
			{
				"Приступить",
				120,
				function( )
					theory_time_left = 300
					resolved_questions = { }
					OnShowUIAutoSchool_handler( true, "theory_exam" )
				end,
			},
			{ "Отмена", 120 },
		},
	},

	not_enought_money =
	{
		title = "Ошибка",
		body = "У Вас недостаточно средств. Пополнить счёт\nможно в личном кабинете(F4)",
		btns =
		{
			{ "Закрыть", 120 },
		}
	},
}

local popup = { }

function ShowPopup( state, id )
	if state then
		if isElement( popup.black_bg ) then ShowPopup( false ) end

		local size_x, size_y = 550, 292
		local pos_x, pos_y = ( _SCREEN_X - size_x ) / 2, ( _SCREEN_Y - size_y ) / 2
		local data = popups_data[ id ]

		showCursor(true)

		popup.black_bg = ibCreateBackground( 0x00000000, ShowPopup, true, true )
		popup.bg = ibCreateImage( pos_x, pos_y, size_x, size_y, "img/auto/popup/bg.png", popup.black_bg )
		popup.title = ibCreateLabel( 0, 0, size_x, 100, data.title, popup.bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_16 )
		popup.body = ibCreateLabel( 0, 80, size_x, 80, type( data.body ) == "function" and data.body( ) or data.body, popup.bg, 0xFFAAAAAA, _, _, "center", "center", ibFonts.regular_14 )

		local btn_size = #data.btns * 10 - 10
		for k, v in pairs( data.btns ) do
			btn_size = btn_size + v[ 2 ]
		end

		local btn_pos_x = ( size_x - btn_size ) / 2

		for k, v in pairs( data.btns ) do
			popup[ "btn" .. k ] = ibCreateButton( btn_pos_x, 180, v[ 2 ], 46, popup.bg, "img/auto/popup/btn.png", "img/auto/popup/btn.png", "img/auto/popup/btn.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick(function( button, state )
				if button ~= "left" or state ~= "down" then return end
				ShowPopup( false )
				if v[ 3 ] then v[ 3 ]( ) end
			end)

			ibCreateLabel( 0, 0, v[ 2 ], 46, v[ 1 ], popup[ "btn" .. k ], 0xffffffff, _, _, "center", "center", ibFonts.regular_12 ):ibData( "disabled", true )

			btn_pos_x = btn_pos_x + v[ 2 ] + 10
		end
	else
		if isElement( popup.black_bg ) then
			destroyElement( popup.black_bg )
		end
		showCursor( false )
	end
end

local hint = {}

function ShowHint( state, text )
	if state then
		if isElement( hint.bg ) then ShowHint( false ) end

		hint.bg = ibCreateImage( 0, _SCREEN_Y - 200, _SCREEN_X, 200, nil, nil, 0xDD000000 )
		ibCreateLabel( 0, 0, _SCREEN_X, 200, text, hint.bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_12 ):ibData( "wordbreak", true )
	else
		destroyElement( hint.bg )
	end
end