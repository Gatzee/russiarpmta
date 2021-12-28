loadstring( exports.interfacer:extend("Interfacer") )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CChat" )

ibUseRealFonts( true )

scX, scY = guiGetScreenSize()

UI_elements = {}
SELECTED_TAB = 1
REQUEST_TIMEOUT = 0
PLAYER_SHIFT_PLAN_DATA = {}

function UIControlMenu( member_list, not_sorted, shift_plan )

    if isElement( UI_elements.black_bg ) then return end

    ibAutoclose( )
    ibWindowSound()

    CACHE_MEMBER_LIST = member_list
    PLAYER_SHIFT_PLAN_DATA = shift_plan

    if not_sorted then
		CACHE_MEMBER_LIST = { }

		for id, member in pairs( member_list ) do
			member.id = id
			table.insert( CACHE_MEMBER_LIST, member )
		end

		table.sort( CACHE_MEMBER_LIST, function (a, b) return (a.level > b.level) end )

		LAST_CACHED = getRealTime().timestamp + 10
    end
    
    UI_elements.black_bg = ibCreateBackground( 0xCC212B36, DestroyUIControlMenu, true, true ):ibData( "alpha", 0 )
    :ibBatchData( { priority = 999, alpha = 0 } )
    
    UI_elements.bg_img = ibCreateImage( 0, 0, 800, 580, "images/bg.png", UI_elements.black_bg )
    :center()
    UI_elements.rt_bg = ibCreateRenderTarget( 0, 0, 800, 580, UI_elements.bg_img )
    
    UI_elements.button_close = ibCreateButton( 751, 25, 24, 24, UI_elements.bg_img, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF  )
    :ibOnClick( function( button, state )
		if button ~= "left" or state ~= "up" then return end

		DestroyUIControlMenu()
	end )

    local px = 0
    local player_faction = localPlayer:GetFaction()
    for k, v in pairs( TAB_MENU ) do
        if ( not v.factions or v.factions[ player_faction ] ) and v.condition() then
            local text_len = dxGetTextWidth( v.name, 1, ibFonts.bold_14 )
            UI_elements[ "menu_tab_button_" .. k ] = ibCreateArea( px + 31, 91, text_len, 71, UI_elements.bg_img )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick()
                if SELECTED_TAB == k then return end
                SwitchTabMenu( k )
            end )
            UI_elements[ "menu_tab_name_" .. k ] = ibCreateLabel( 0, -4, text_len, 0, v.name, UI_elements[ "menu_tab_button_" .. k ], 0xFFC2C8CE, 1, 1, "center", "top", ibFonts.bold_14 )
            :ibData( "disabled", true )
            
            if not isElement( UI_elements.tab_line_img ) then
                UI_elements.tab_line_img = ibCreateImage( 31, 114, text_len, 3, false, UI_elements.bg_img, 0xFFFF965D )
                SwitchTabMenu( k )
			end
            
            px = px + text_len + 28
        end
    end

    UI_elements.black_bg:ibAlphaTo( 255, 250 )
    showCursor( true )

end
addEvent( "UIControlMenu", true )
addEventHandler( "UIControlMenu", resourceRoot, UIControlMenu )

function SwitchTabMenu( tab_id )

    if isElement( UI_elements.popup ) then 
        UI_elements.popup:destroy()
    end

    if SELECTED_TAB and UI_elements[ "menu_tab_name_" .. SELECTED_TAB ] then
        UI_elements[ "menu_tab_name_" .. SELECTED_TAB ]:ibData( "color", 0xFFC2C8CE )
    end
    
    local animation_duration = 200
    local new_content_area = TAB_MENU[ tab_id ].content( UI_elements.rt_bg, SELECTED_TAB > tab_id and 100 or -100  )
    if isElement( UI_elements.current_tab ) then

        new_content_area
        :ibData( "priority", 0 )
        :ibData("alpha", 0)
        :ibAlphaTo( 255, animation_duration )

        -- Анимация появления с правой стороны
        if tab_id > SELECTED_TAB then
            UI_elements.current_tab:ibMoveTo( -100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            new_content_area:ibMoveTo( 0, _, animation_duration )
        -- Анимация появления с левой стороны
        elseif tab_id < SELECTED_TAB then
            UI_elements.current_tab:ibMoveTo( 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            new_content_area:ibMoveTo( tab_id == 1 and 30 or 0, _, animation_duration )
        end

        UI_elements.current_tab:ibTimer( function( self, old_area )
            if isElement( old_area ) then
                old_area:destroy()
            end
        end, animation_duration, 1, UI_elements.current_tab )

        UI_elements.current_tab = new_content_area
    else
        UI_elements.current_tab = new_content_area
        UI_elements.current_tab:ibData( "px", 30 )
    end

    SELECTED_TAB = tab_id

    UI_elements[ "menu_tab_name_" .. SELECTED_TAB ]:ibData( "color", 0xFFFFFFFF )

    local px = UI_elements[ "menu_tab_button_" .. SELECTED_TAB ]:ibData( "px" )
    local sx = UI_elements[ "menu_tab_button_" .. SELECTED_TAB ]:ibData( "sx" )
    UI_elements.tab_line_img:ibMoveTo( px, _, 250, "Linear" )
    UI_elements.tab_line_img:ibResizeTo( sx, _, 250, "Linear" )

end

function DestroyUIControlMenu()
    DestroyTableElements( UI_elements )
    UI_elements = {}
	showCursor( false )
end

ibAttachAutoclose( function( ) DestroyUIControlMenu( ) end )


function UIApplyInvitePopup( faction_id )
    
    if isElement( UI_elements.black_bg ) then return end
	
    UI_elements.black_bg = ibCreateBackground( 0xCC212B36, _, true ):ibData( "alpha", 0 )
    :ibBatchData( { priority = -1, alpha = 0 } )

	UI_elements.bg_img = ibCreateImage( 0, 0, scX, scY, false, UI_elements.black_bg, 0xFA45596E )

    local message = "Тебя приглашают присоединиться\nво фракцию “".. FACTIONS_NAMES[ faction_id ] .."“. Принять приглашение?"
    ibCreateLabel( scX / 2, scY / 2 - 50, 0, 0, message, UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_20 )

    --Костыль, нужен дизайн
    local apply_button = ibCreateImage( scX / 2 - 125, scY / 2 + 20, 105, 65, false, UI_elements.bg_img, 0xFF558C5E )
    ibCreateLabel( 0, 0, 105, 65, "Да", apply_button, 0xFFC2C8CE, 1, 1, "center", "center", ibFonts.bold_14 )
    :ibData( "disabled", true )

    apply_button
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "up" then return end
        ibClick()
        DestroyUIApplyInvitePopup()
        triggerServerEvent( "PlayerFactionMenuControl_apply_invite", resourceRoot )
    end )

    --Костыль, нужен дизайн
    local cancel_button = ibCreateImage( scX / 2, scY / 2 + 20, 145, 65, false, UI_elements.bg_img, 0xFF764949 )
    ibCreateLabel( 0, 0, 145, 65, "Отмена", cancel_button, 0xFFC2C8CE, 1, 1, "center", "center", ibFonts.bold_14 )
    :ibData( "disabled", true )

    cancel_button
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "up" then return end
        ibClick()
        DestroyUIApplyInvitePopup()
    end )

    UI_elements.black_bg:ibAlphaTo( 255, 250, "InQuad" )
    showCursor( true )

end
addEvent( "UIApplyInvitePopup", true )
addEventHandler( "UIApplyInvitePopup", resourceRoot, UIApplyInvitePopup )

function DestroyUIApplyInvitePopup()

	if isElement( UI_elements.black_bg ) then destroyElement( UI_elements.black_bg ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
	end

    UI_elements = {}
    showCursor( false )
    
end

function UIEditReasonPopup( iAction, text, target_id )
    
    local CONTROL_LIST = { [1] = "levelup"; [2] = "leveldown"; [3] = "thanks"; [4] = "warning"; [5] = "set_deputy"; [6] = "kick"; }

    UI_elements.black_bg = ibCreateBackground( 0xCC212B36, _, true ):ibData( "alpha", 0 )
    :ibBatchData( { priority = -1, alpha = 0 } )

	UI_elements.bg_img = ibCreateImage( 0, 0, scX, scY, false, UI_elements.black_bg, 0xFA45596E )

	ibCreateLabel( scX / 2, scY / 2 - 50, 0, 0, text, UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_20 )

    local reason_input = ibCreateEdit( scX / 2 - 155, scY / 2 - 25, 310, 35, "", UI_elements.bg_img, 0xffffffff, 0x99000000, 0xffffffff )
    :ibData( "font", ibFonts.regular_15 )

    --Костыль, нужен дизайн
    local apply_button = ibCreateImage( scX / 2 - 125, scY / 2 + 20, 105, 65, false, UI_elements.bg_img, 0xFF558C5E )
    ibCreateLabel( 0, 0, 105, 65, "Готово", apply_button, 0xFFC2C8CE, 1, 1, "center", "center", ibFonts.bold_14 )
    :ibData( "disabled", true )

    apply_button
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "up" then return end
        local sReason = reason_input:ibData( "text" )

        ibClick()
        DestroyUIApplyInvitePopup()
        
        triggerServerEvent( "PlayerFactionMenuControl_".. CONTROL_LIST[ iAction ], resourceRoot, target_id, sReason )
    end )
    
    --Костыль, нужен дизайн
    local cancel_button = ibCreateImage( scX / 2, scY / 2 + 20, 145, 65, false, UI_elements.bg_img, 0xFF764949 )
    ibCreateLabel( 0, 0, 145, 65, "Отмена", cancel_button, 0xFFC2C8CE, 1, 1, "center", "center", ibFonts.bold_14 )
    :ibData( "disabled", true )

    cancel_button
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "up" then return end
        ibClick()
        DestroyUIApplyInvitePopup()
    end )

    UI_elements.black_bg:ibAlphaTo( 255, 250, "InQuad" )
    showCursor( true )

end

function DestroyUIEditReasonPopup()
    
    if isElement( UI_elements.black_bg ) then destroyElement( UI_elements.black_bg ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
    end
    
    UI_elements = {}
    showCursor( false )
    
end

bindKey( "F3", "up", function()

    if isElement( UI_elements.black_bg ) then
        DestroyUIControlMenu()
        return
    end

    if isElement( UI_elements.black_bg ) then
        DestroyUIControlMenu()
        return
    end

    if REQUEST_TIMEOUT < getRealTime().timestamp then
		if not localPlayer:IsInFaction() then return end

		if LAST_CACHED < getRealTime().timestamp or CACHE_MEMBER_LIST_FACTION ~= localPlayer:GetFaction() then
			REQUEST_TIMEOUT = getRealTime().timestamp + 1

			triggerServerEvent( "ClientRequestFactiobMemberList", resourceRoot )
		else
			UIControlMenu( CACHE_MEMBER_LIST )
		end
	end

end )

function GetStringDataFromUNIX( unix_time )
    local hours, minutes, seconds = math.floor( unix_time / 3600 % 24 ), math.floor( unix_time / 60 % 60 ), math.floor( unix_time % 60 )
    return string.format( "%02d ч %02d мин.", hours, minutes, seconds )
end