
CURRENT_PLAYER_SELECTED = 0
LAST_CACHED = 0
CACHE_MEMBER_LIST = { }
CACHE_MEMBER_LIST_FACTION = 0

TAB_MENU = 
{
	{
		id = "members";
        name = "Список состава";
        
        content = function( parent, px )
            local content_area = ibCreateArea( px, 133, 800, 447, parent )

            ibCreateLabel( 5,  0, 0, 0, "Ник", content_area, 0xFFC2C8CE, 1, 1, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( 235, 0, 0, 0, "Звание", content_area, 0xFFC2C8CE, 1, 1, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( 350, 0, 0, 0, "Выговоры", content_area, 0xFFC2C8CE, 1, 1, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( 470, 0, 0, 0, "Статус", content_area, 0xFFC2C8CE, 1, 1, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( 575, 0, 0, 0, "Последний вход", content_area, 0xFFC2C8CE, 1, 1, "left", "top", ibFonts.regular_12 )
            
            local CONST_STATUS_NAME  = { [ 1 ] = "Онлайн",   [ 2 ] = "Оффлайн",  [ 3 ] = "Забанен", }
            local CONST_STATUS_COLOR = { [ 1 ] = 0xFFAEFFA1, [ 2 ] = 0x80FFFFFF, [ 3 ] = 0xFFFFA1A1, }

            local scroll_pane, scroll_bar = ibCreateScrollpane( 0, 24, 800, 300, content_area, { scroll_px = -20 } )
            scroll_bar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99FFFFFF } )

            local py = 0
            for k, v in pairs( CACHE_MEMBER_LIST ) do
                local index = k - 1
                local size_y = 34 + ( index % 2 ) * 6
                local color = ( index % 2) * 0x5A000000 + 0x000000
                
                local item_container = ibCreateImage( 0, py, 800, size_y, false, scroll_pane, ibApplyAlpha( color, 35 ) )
                ibCreateLabel( 5, 0, 0, size_y, v.name, item_container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
                
                local rank_img = ":nrp_factions_ui_info/images/ranks/".. FACTIONS_LEVEL_ICONS[ localPlayer:GetFaction() ] .."/".. v.level ..".png"
                ibCreateImage( 235, math.ceil( ( size_y - 23 + ( index % 2 ) * - 3 ) / 2 ), 19, 23, rank_img, item_container )

                if FACTION_EXPERIENCE[ v.level ] then
                    local member_exp_proc = math.floor( v.exp / FACTION_EXPERIENCE[ v.level ] * 100 )
                    ibCreateLabel( 267, ( k % 2 ) * - 3, 0, size_y, member_exp_proc .."%", item_container, member_exp_proc >= 100 and 0xFFAEFFA1 or 0x80FFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
                end

                ibCreateLabel( 350, ( k % 2 ) * - 3, 0, size_y, v.warnings .." / 3", item_container, 0x80FFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )

                ibCreateLabel( 470, ( k % 2 ) * - 3, 0, size_y, CONST_STATUS_NAME[ v.status ], item_container, CONST_STATUS_COLOR[ v.status ], 1, 1, "left", "center", ibFonts.regular_14 )

                local last_text
		        local last_text_color = 0x80FFFFFF
		        if v.status == 1 then
		        	last_text = v.last and HOMETOWNS[ v.last ] or "Не на смене"
		        	last_text_color = v.last and 0xFFAEFFA1 or 0xFFFFA1A1
		        else
		        	last_text = formatTimestamp( v.last )
                end
                ibCreateLabel( 575, ( k % 2 ) * - 3, 0, size_y, last_text, item_container, last_text_color, 1, 1, "left", "center", ibFonts.regular_14 )

                if localPlayer:IsHasFactionControlRights() and v.level <= localPlayer:GetFactionLevel() then --Убарть <=

                    local CONTROL_LIST = {
                        [1] = "levelup";
                        [2] = "leveldown";
                        [3] = "thanks";
                        [4] = "warning";
                        [5] = "set_deputy";
                        [6] = "kick";
                    }

                    local name_len = dxGetTextWidth( v.name, 1, ibFonts.regular_12 )
                    local button_control = ibCreateButton(	31 + name_len + 15, ( size_y - 13) / 2 - ( k % 2 ) * 3, 13, 13, item_container, "images/list/icon_control.png", _, _, 0x50FFFFFF, 0xA0FFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick()
                        CURRENT_PLAYER_SELECTED = v.id
                        if isElement( UI_elements.popup ) then 
                            UI_elements.popup:destroy()
                            if CURRENT_PLAYER_SELECTED == v.id then
                                CURRENT_PLAYER_SELECTED = nil
                                return 
                            end
                        end
                        
                        local off_pos_x = 0
                        local x = math.ceil( source:ibGetBeforeX( source:ibData( "sy" ) * 0.5 - 20 ) )
                        local y = math.ceil( item_container:ibGetBeforeY( ) + source:ibGetAfterY( 10 ) )                        
                        UI_elements.popup = ibCreateArea( x, y, 504, 38, scroll_pane )
						scroll_pane:AdaptHeightToContents()

                        local player_faction = localPlayer:GetFaction()
                        local mayor_factions = { [ F_GOVERNMENT_GORKI ] = true, [ F_GOVERNMENT_NSK ] = true, [ F_GOVERNMENT_MSK ] = true }
                        local player_faction_is_mayor = mayor_factions[ player_faction ]
                        for i = 1, #CONTROL_LIST do
                            if i ~= 5 or ( i == 5 and player_faction_is_mayor) then
                                local button = ibCreateButton(	off_pos_x, 0, 0, 0, UI_elements.popup, "images/list/control/".. i ..".png", _, _, 0xC0FFFFFF, 0xFFFFFFFF, 0xB0FFFFFF)
                                :ibSetRealSize( )
                                :ibOnClick( function( button, state )
                                    if button ~= "left" or state ~= "up" then return end
                                    ibClick()
                                    if CONTROL_LIST[ i ] then
                                        DestroyUIControlMenu()
							            if i == 6 then
							            	UIEditReasonPopup( 6, "Введите причину увольнения " .. v.name, v.id )
                                        else
							            	triggerServerEvent( "PlayerFactionMenuControl_" .. CONTROL_LIST[ i ], resourceRoot, v.id )
							            end
                                    end
                                end )
                            
                                off_pos_x = off_pos_x + button:ibData( "sx" ) + 1
                            end
                        end

                    end )
                end

                py = py + size_y

            end

            scroll_pane:AdaptHeightToContents()
    	    scroll_bar:UpdateScrollbarVisibility( scroll_pane )

            --Инвайт нового игрока
            ibCreateLabel( 10, 323, 0, 0, "Пригласить игрока во фракцию", content_area, 0xFF7E8C9C, 1, 1, "left", "top", ibFonts.regular_12 )
            local invite_bg = ibCreateImage( 10, 352, 574, 68, "images/list/form_invite_bg.png", content_area )
            local invite_input = ibCreateEdit( 15, 28, 557, 31, "", invite_bg, 0xffffffff, 0x00000000, 0xffffffff )
            :ibData( "font", ibFonts.regular_16 )

            local invite_btn = ibCreateButton( 605, 366, 140, 40, content_area, "images/list/btn_invite.png", "images/list/btn_invite_hovered.png", "images/list/btn_invite_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF  )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick()
                if localPlayer:IsHasFactionControlRights() then
                    local username = invite_input:ibData( "text" )
                    if not VerifyPlayerName( username ) then
                        localPlayer:ShowError( "Неверный формат никнейма" )
                        return
                    end
                    triggerServerEvent( "PlayerFactionMenuControl_invite", resourceRoot, username )
			        DestroyUIControlMenu()
                end
            end )
            

            return content_area
        end,

        condition = function()
            return true
        end;
    };
    
	--[[{
		id = "wanted";
		name = "Розыск";

        content = function( parent )
            local content_area = ibCreateArea( 0, 137, 800, 443, parent )

            return content_area
        end,

        condition = function()
            return true
        end;
    };

    {
		id = "teachings";
		name = "Учения";

        content = function( parent )
            local content_area = ibCreateArea( 0, 137, 800, 443, parent )

            return content_area
        end,

        condition = function()
            return true
        end;
    };]]

    {
        id = "megaphone",
        name = "Мегафон",

        content = function( parent, px )
            local content_area = ibCreateArea( px, 137, 800, 443, parent )

            ibCreateImage( 30, 0, 302, 18, "images/list/megaphone_help_msg.png", content_area )

            local bg_message = ibCreateImage( 30, 39, 738, 298, "images/list/bg_megaphone_msg.png", content_area )

            local edit_message = ibCreateWebMemo( 30, 17, 678, 238, "", bg_message, 0xFFFFFFFF, 0 )
            :ibData( "max_length", 200 )
            :ibData( "focusable", true )
            :ibData( "focused", true )

            if fileExists( "megaphone" ) then
                local file = fileOpen( "megaphone" )
                local text = fileRead( file, fileGetSize(file)  )
                text = utf8.sub( text, 1, 200 )
                edit_message:ibData( "text", text )
                fileClose( file )
            end
            
            function check_time_left()
                local time_left = localPlayer:getData( "megaphone_time_left" )
                if time_left and time_left > getRealTimestamp() then
                    if not UI_elements.time_lbl then
                        ibCreateImage( 29, 252, 18, 18, "images/list/red_info.png", bg_message )
                        UI_elements.time_lbl = ibCreateLabel( 55, 252, 0, 0, "", bg_message, 0xFFCD4E53, 1, 1, "left", "top", ibFonts.regular_14 )
                        :ibOnRender( function()
                            local time_diff = time_left - getRealTimestamp()
                            local text = "Сообщение можно будет отправить через - " .. GetStringDataFromUNIX( time_diff )
                            UI_elements.time_lbl:ibData( "text", text )
                        end )
                    end
                    return false
                end
                return true
            end
            check_time_left()

            ibCreateButton( 330, 368, 140, 45, content_area, "images/list/btn_send.png", "images/list/btn_send_hovered.png", "images/list/btn_send_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF  )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick()
                local time_left = localPlayer:getData( "megaphone_time_left" )
                if not check_time_left() then return end
                local message = edit_message:ibData( "text" )
                local message_len =  utf8.len( message )
                if message_len == 0 then
                    localPlayer:ShowError( "Введите сообщение" )
                    return
                elseif message_len > 350 then
                    localPlayer:ShowError( "Максимальная длина сообщения 350 символов" )
                    return
                elseif #split( message, " " ) < message_len / 20 then
                    localPlayer:ShowError( "Некорретный текст" )
                    return
                end
                if fileExists( "megaphone" ) then
                    fileDelete( "megaphone" )
                end
                local file = fileCreate( "megaphone" )
                fileWrite( file, message )
                fileClose( file )
                triggerServerEvent( "onServerPlayerUseMegaphone", localPlayer, message, time_left )
            end )
            
            return content_area
        end,

        condition = function()
            if localPlayer:IsHasFactionControlRights( ) then
                return true
            end
            return false
        end;
    },

    {
        id = "reports";
        name = "Список жалоб";

        content = function( parent )
            local content_area = ibCreateArea( 0, 137, 800, 443, parent )

            local popup_bg

            local function ShowReportsPopup( state, player, id )
                if state then
                    popup_bg = ibCreateImage( 0, 0, 800, 443, nil, content_area, 0xff1f2934 )
                    :ibData("alpha", 0):ibAlphaTo( 255*0.95, 500 )

                    local lbl_title = ibCreateLabel( 30, 34, 0, 0, "Жалобы на "..FACTIONS_LEVEL_NAMES[ localPlayer:GetFaction() ][ player.level ].." "..player.name, popup_bg, 0xffffffff, _, _, _, _, ibFonts.bold_16 ):ibData("priority", 1)

                    local scroll_pane, scroll_bar = ibCreateScrollpane( 0, 64, 800, 300, popup_bg, { scroll_px = -20 } )
                    scroll_bar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99FFFFFF } )
                    
                    local iTotalReports, iWatchedReports = 0, 0

                    local py = 0
                    for k,v in pairs(player.reports) do
                        ibCreateLabel( 30, py, 0, 76, k, scroll_pane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 )

                        local lbl_desc = ibCreateLabel( 55, py+22, 0, 38, "Описание:", scroll_pane, 0x80ffffff, _, _, "left", "top", ibFonts.regular_14 )
                        ibCreateLabel( lbl_desc:ibGetAfterX(5), py+22, 0, 38, v.desc, scroll_pane, 0xffffffff, _, _, "left", "top", ibFonts.regular_14 )

                        local lbl_name = ibCreateLabel( 55, py+47, 0, 38, "Подал жалобу:", scroll_pane, 0x80ffffff, _, _, "left", "top", ibFonts.regular_12 )
                        ibCreateLabel( lbl_name:ibGetAfterX(5), py+47, 0, 38, v.name, scroll_pane, 0xffffffff, _, _, "left", "top", ibFonts.regular_12 )

                        if next(player.reports, k) then
                            ibCreateImage( 30, py+76, 740, 1, _, scroll_pane, 0xffffffff ):ibData("alpha", 25)
                        end

                        py = py + 76

                        iTotalReports = iTotalReports + 1
                        if v.watched then
                            iWatchedReports = iWatchedReports + 1
                        end
                    end

                    scroll_pane:AdaptHeightToContents()
                    scroll_bar:UpdateScrollbarVisibility( scroll_pane )

                    if iWatchedReports == iTotalReports then
                        ibCreateLabel( lbl_title:ibGetAfterX(10), 34, 0, 0, "(Просмотрено)", popup_bg, 0xff47ff58, _, _, _, _, ibFonts.regular_14 ):ibData("priority", 1)
                    end

                    triggerServerEvent( "OnPlayerWatchReports", localPlayer, id )

                    ibCreateButton( 400-54, 443-72, 108, 42, popup_bg, "images/reports/btn_hide.png", "images/reports/btn_hide_h.png", "images/reports/btn_hide_h.png" )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick()
                        ShowReportsPopup( false )
                    end )
                else
                    if isElement( popup_bg ) then
                        popup_bg:ibAlphaTo(0, 500)
                        :ibTimer( function()
                            if isElement(popup_bg) then
                                destroyElement( popup_bg )
                            end
                        end, 500, 1)
                    end
                end
            end

            local scroll_pane, scroll_bar = ibCreateScrollpane( 0, 24, 800, 400, content_area, { scroll_px = -20 } )
            scroll_bar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99FFFFFF } )

            local py = 0
            for k, v in pairs( CACHE_MEMBER_LIST ) do
                if v.reports and #v.reports > 0 then
                    local member_bg = ibCreateButton( 30, py, 740, 54, scroll_pane, "images/reports/bg.png", "images/reports/bg_h.png", "images/reports/bg_h.png" )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick()
                        ShowReportsPopup( true, v, k )
                    end )

                    local indicator = ibCreateImage( 20, 22, 10, 10, "images/reports/circle.png", member_bg, v.status == 1 and 0xff47ff58 or 0xffffffff  ):ibData("disabled", true)
                    ibCreateLabel( 40, 0, 0, 54, v.name, member_bg, 0xffffffff, _, _, "left", "center", ibFonts.regular_14 )
                    ibCreateImage( 740-28, 21, 8, 12, "images/reports/arrow_right.png", member_bg ):ibData("disabled", true)

                    py = py + 64
                end
            end

            scroll_pane:AdaptHeightToContents()
            scroll_bar:UpdateScrollbarVisibility( scroll_pane )

            return content_area
        end,

        condition = function()
            if localPlayer:IsHasFactionControlRights( ) then
                return true
            end
            return false
        end;
    },

    {
		id = "shift_plan";
		name = "План на смену";

        content = function( parent )
            local content_area = ibCreateArea( 0, 133, 800, 508, parent )
            
            local shift_details_area = nil
            local scroll_pane, scroll_bar = ibCreateScrollpane( 30, 10, 800, 508, content_area, { scroll_px = -20 } )
            scroll_bar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99FFFFFF } )

            local py = 0
            local player_faction = localPlayer:GetFaction()
            local shift_plan = exports.nrp_faction_shift_plan:GetShiftPlanList()
            
            for k, v in pairs( shift_plan ) do
                if v.factions[ player_faction ] then
                    local item_container = ibCreateButton( 0, py, 740, 54, scroll_pane, "images/shift_plan/bg_item.png", "images/shift_plan/bg_item_hovered.png", "images/shift_plan/bg_item_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF  )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick()
                        CreatePopUpDescription( v )
                    end )
                    ibCreateImage( 20, 22, 10, 10, "images/shift_plan/circle.png", item_container, localPlayer:IsOnFactionDuty() and 0xFF47FF58 or 0xFFFFCD47 ):ibData( "disabled", true )
                    ibCreateLabel( 40, 10, 0, 0, v.text, item_container, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_14 ):ibData( "disabled", true )
                    ibCreateLabel( 310, 29, 0, 0, (PLAYER_SHIFT_PLAN_DATA[ v.id ] and PLAYER_SHIFT_PLAN_DATA[ v.id ].execution or 0 ).. "/" .. v.need_number_exec, item_container, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_12 ):ibData( "disabled", true )

                    if PLAYER_SHIFT_PLAN_DATA[ v.id ] and PLAYER_SHIFT_PLAN_DATA[ v.id ].execution then
                        local fProgress = PLAYER_SHIFT_PLAN_DATA[ v.id ].execution / v.need_number_exec
                        ibCreateImage( 30, 24, 280 * fProgress, 28, "images/shift_plan/progress_active.png", item_container ):ibData( "disabled", true )
                        :ibBatchData( { u = 0, v = 0, u_size = 280 * fProgress } )
                    end

                    ibCreateImage( 529, 19, 82, 16, "images/shift_plan/reward_text.png", item_container ):ibData( "disabled", true )
                    ibCreateLabel( 670, 16, 0, 0, format_price( v.reward ), item_container, 0xFFFFFFFF, _, _, "right", _, ibFonts.bold_16 ):ibData( "disabled", true )
                    ibCreateImage( 676, 19, 18, 15, "images/shift_plan/soft_icon.png", item_container ):ibData( "disabled", true )
                
                    py = py + 64
                end
            end

            scroll_pane:AdaptHeightToContents()
    	    scroll_bar:UpdateScrollbarVisibility( scroll_pane )

            function CreatePopUpDescription( shift_data )
                if isElement( shift_details_area ) then return end

                ibOverlaySound()
                shift_details_area  = ibCreateRenderTarget( 0, -16, 800, 463, content_area ):ibData( "priority", 1 )
                local shift_bg = ibCreateImage( 0, 463, 800, 463, _, shift_details_area, ibApplyAlpha( 0xFF1F2934, 95 ) )

                ibCreateLabel( 29, 31, 0, 0, shift_data.text, shift_bg, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_16 ):ibData( "disabled", true )
                ibCreateLabel( 29, 77, 0, 0, shift_data.description or "Выполни задание за смену и получи награду!", shift_bg, 0xAAFFFFFF, _, _, _, _, ibFonts.regular_14 ):ibData( "disabled", true )

                ibCreateImage( 29, 345, 275, 24, "images/shift_plan/desc_reward_text.png", shift_bg ):ibData( "disabled", true )
                ibCreateLabel( 359, 345, 0, 0, format_price( shift_data.reward ), shift_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.bold_16 ):ibData( "disabled", true )
                ibCreateImage( 366, 347, 20, 17, "images/shift_plan/soft_icon.png", shift_bg ):ibData( "disabled", true )

                ibCreateButton(	346, 400, 108, 42, shift_bg, "images/shift_plan/btn_hide.png", "images/shift_plan/btn_hide_hovered.png", "images/shift_plan/btn_hide_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    shift_bg:ibMoveTo( 0, 463, 250 )
                    shift_bg:ibTimer( function()
                        if isElement( shift_details_area ) then
                            shift_details_area:destroy()
                            content_area:ibBatchData( { disabled = false, priority = 0 } )
                        end
                    end, 250, 1 )
                end, false )
                shift_bg:ibMoveTo( 0, 0, 250 )
            end

            return content_area
        end,

        condition = function()
            local player_faction = localPlayer:GetFaction()
            local shift_plan = exports.nrp_faction_shift_plan:GetShiftPlanList()

            local exist_shift_plan = false
            for k, v in pairs( shift_plan ) do
                if v.factions[ player_faction ] then
                    exist_shift_plan = true
                    break
                end
            end

            return exist_shift_plan
        end;
    },

    {
		id = "rules_faction";
		name = "Правила фракции";

        content = function( parent )
            local content_area = ibCreateArea( 0, 133, 800, 508, parent )
            
            local shift_details_area = nil
            local scroll_pane, scroll_bar = ibCreateScrollpane( 30, 10, 750, 440, content_area, { scroll_px = -10 } )
            scroll_bar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99FFFFFF } )

            local faction = FACTIONS_RULES_BY_FACTION[ localPlayer:GetFaction( ) ]

            local py = 0
            for k, v in ipairs( RULES_LIST[ faction ] ) do
                ibCreateLabel( 0, py, 0, v[ 2 ] * 26, v[ 1 ], scroll_pane ):ibBatchData( { font = ibFonts.bold_14, colored = true } )
				py = py + v[ 2 ] * 26
			end

            scroll_pane:AdaptHeightToContents( )
            scroll_bar:UpdateScrollbarVisibility( scroll_pane )
            
            return content_area
        end,

        condition = function()
            local faction = localPlayer:GetFaction( )
            if not faction or not FACTIONS_RULES_BY_FACTION[ faction ] then return false end
            return true
        end;
    },
}