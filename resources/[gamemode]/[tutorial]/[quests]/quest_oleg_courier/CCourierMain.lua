
function ShowJobUI( state )
    if state then
        ShowJobUI( false )
        
        UI_elements = {}

        UI_elements.black_bg = ibCreateBackground( _, nil, 0xAA000000, true )
        UI_elements.bg = ibCreateImage( 0, 0, 800, 580, ":nrp_job_controller/img/courier/bg_main.png", UI_elements.black_bg ):center()
        
        ibCreateButton( 748, 25, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                localPlayer:ErrorWindow( "Начни смену чтобы продолжить!" )
            end )

        ibCreateImage( 30, 126, 36, 30, ":nrp_job_controller/img/soft_icon.png", UI_elements.bg )
		ibCreateLabel( 76, 123, 0, 0, format_price( 0 ), UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.oxaniumbold_21 )

        UI_elements.remaining_time = ibCreateLabel( 713, 98, 0, 0, "", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )

        UI_elements.bg_shift = ibCreateArea( 443, 103, 500, 50, UI_elements.bg )
        ibCreateImage( 143, 0, 18, 18, ":nrp_job_controller/img/shift_available_icon.png", UI_elements.bg_shift ):ibData( "alpha", 191 )
        ibCreateLabel( 171, 0, 0, 18, "Доступна новая смена", UI_elements.bg_shift, 0xFFFFD892, nil, nil, "left", "center", ibFonts.semibold_14 ):ibData( "alpha", 191 )

        UI_elements.btn_shift = ibCreateButton( 587, 131, 192, 58, UI_elements.bg, ":nrp_job_controller/img/btn_start_shift.png", ":nrp_job_controller/img/btn_start_shift_h.png", ":nrp_job_controller/img/btn_start_shift_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick( )

                triggerServerEvent( "oleg_courier_step_2", localPlayer )
            end )  

        ibCreateButton( 587, 186, 192, 58, UI_elements.bg, ":nrp_job_controller/img/btn_fines.png", ":nrp_job_controller/img/btn_fines_h.png", ":nrp_job_controller/img/btn_fines_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                localPlayer:ErrorWindow( "Начни смену чтобы продолжить!" )
            end )

        -- Levels
        local px = 30
        
        local count_company = 4
        local curret_compnany_id = 1

        count_company = (count_company >= 4 and curret_compnany_id < 2) and 3 or count_company

        local min_visible_company_id = 1 + (curret_compnany_id and math.max( 0, curret_compnany_id - 3 ) or 0)

        local conf = {
            { 
                name = "Подработка",
                condition_text = "Доступно со 2 уровня",
            },
            {
                name = "В Компании I",
                condition_text = "Доступно с 4 уровня",
            },
            {
                name = "В компании II",
                condition_text = "Доступно с 7 уровня",
            },
            {
                name = "В Компании III",
                condition_text = "Доступно с 10 уровня",
            },
        }

        local roman_numerals = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }
        for company_id, company_data in ipairs( conf ) do
            if company_id >= min_visible_company_id and company_id <= count_company then 
                local is_cur_company = company_id == curret_compnany_id
                local is_passed_company = curret_compnany_id > company_id
                local company_state = is_cur_company and "current" or is_passed_company and "passed" or "blocked"
                local company_next = (company_id == count_company) and "last" or "next"
                local level_value = company_state .. "_" .. company_next
                local img = ibCreateImage( px, 258, 0, 0, ":nrp_job_controller/img/levels/" .. level_value .. ".png", UI_elements.bg ):ibSetRealSize()
                ibCreateLabel( 0, 0, 50, 50, roman_numerals[ company_id ], img, is_passed_company and 0xFF47AFFF or is_cur_company and 0xFFFFFFFF or 0xFF748191, 1, 1, "center", "center", ibFonts.bold_20 ):ibData( "disabled", true )
                ibCreateLabel( 59, 18, 0, 0, company_data.name, img, is_cur_company and 0xFFFFFFFF or 0xFFB0BCC9, 1, 1, "left", "center", ibFonts.bold_14 ):ibData( "disabled", true )
                ibCreateLabel( 59, 34, 0, 0, is_cur_company and "Текущий" or is_passed_company and "Пройдена" or company_data.condition_text, img, is_cur_company and 0xAAFFFFFF or 0xAAB1BCC9, 1, 1, "left", "center", ibFonts.regular_12 ):ibData( "disabled", true )

                local offsets = {
                    blocked_next = 23,
                }
                px = px + img:ibData( "sx" ) - (offsets[ level_value ] or 34)
            end
        end

        -- Daily tasks
        local px = 141
        local tasks = { "Начни смену", "Доставь 2 посылки\nдо адресатов", "Заверши смену", }
        for k, v in ipairs( tasks ) do
            local circle = ibCreateImage( px, 520, 30, 30, ":nrp_job_controller/img/circle_progress.png", UI_elements.bg )
            local lbl_text = ibCreateLabel( px + 40, 522, 0, 26, v, UI_elements.bg, 0xFFA5B2BD, nil, nil, "left", "center", ibFonts.regular_14 )
                
            if tasks[ k + 1 ] then
                local line_px = lbl_text:ibGetAfterX() + 20
                ibCreateImage( line_px, 520, 1, 30, nil, UI_elements.bg, 0x19FFFFFF )
                px = line_px + 21
            end
        end
        
        local py = UI_elements.bg:ibData( "py" ) 
        UI_elements.bg:ibBatchData( { alpha = 0, py = py - 100 } ):ibMoveTo( nil, py, 500, "OutElastic" ):ibAlphaTo( 255, 1000 )

        ibInterfaceSound()
        showCursor( true )

        CEs.job_ui = UI_elements
    elseif isElement( UI_elements and UI_elements.black_bg ) then 
        destroyElement( UI_elements.black_bg )
        UI_elements = nil
		showCursor( false )
    end
end