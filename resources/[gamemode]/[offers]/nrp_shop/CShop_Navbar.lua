local NAVIGATION = { }
local NAVBAR_PRIORITY = 2

function CreateNavbar( parent )
    NAVIGATION.area
        = ibCreateArea( 0, 0, 1, 1, parent )
        :ibData( "priority", NAVBAR_PRIORITY )
        :ibOnDestroy( function( ) NAVIGATION = { } end )

    NAVIGATION.data = { }

    local npx = 30
    for i, v in pairs( ACTIVE_TABS ) do
        local width = dxGetTextWidth( v.name, 1, ibFonts.bold_14 )

        -- Генерация выпадающего списка
        if npx + width >= 740 then
            local amount = #ACTIVE_TABS - i

            if amount > 0 then
                local height_active = 20
                local btn = ibCreateArea( 752, 95 - height_active / 2, 18, 6 + height_active, NAVIGATION.area )

                local nsx, nsy = 200, 45
                local npx, npy = 15, 5
                local y_offset = 27

                NAVIGATION.dropdown_px, NAVIGATION.dropdown_py = math.floor( 770 - nsx ), math.floor( btn:ibData( "py" ) + y_offset )

                local dropdown_bg
                    = ibCreateArea( NAVIGATION.dropdown_px, NAVIGATION.dropdown_py, nsx, amount * nsy, NAVIGATION.area )
                    :ibData( "alpha", 0 )
                    :ibData( "disabled", true )
                ibCreateImage( nsx - 4 - 10, 0, 10, 5, "img/icon_triangle.png", dropdown_bg )

                NAVIGATION.dropdown_bg = dropdown_bg

                SetDropdownState( false )

                btn
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        dropdown_bg:ibAlphaTo( 255, 150 )
                        SetDropdownState( true )
						
						SendElasticGameEvent( "f4r_f4_3points_click" )
                    end )
                    :ibData( "alpha", 200 )

                ibCreateImage( 0, height_active / 2, 18, 6, "img/bg_dropdown.png", btn ):ibData( "disabled", true )

                for n = i, #ACTIVE_TABS do
                    local v = ACTIVE_TABS[ n ]

                    local name = v.name

                    local bg = ibCreateImage( 0, npy, nsx, nsy, _, dropdown_bg, 0xff58819f )--:ibData( "blend_mode", "modulate_add" ):ibData( "blend_mode_after", "blend" )
                    local bg_hover

                    -- Если это первый элемент, у него нет линии сверху, поэтому сдвиг не нужен
                    if i == 1 then
                        bg_hover = ibCreateImage( 0, npy, nsx, nsy, _, dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )

                    else
                        bg_hover = ibCreateImage( 0, npy - 1, nsx, nsy + 1, _, dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )

                    end

                    bg_hover
                        :ibData( "blend_mode", "modulate_add" )
                        :ibData( "blend_mode_after", "blend" )

                    --[[if item_num == current_tab then
                        ibCreateImage( nsx - 3, npy + nsy / 2 - 13 / 2, 3, 13, _, dropdown_bg, 0xfffb9769 ):ibData( "priority", 5 )
                    end]]

                    bg
                        :ibData( "priority", -1 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            triggerEvent( "SwitchNavbar", resourceRoot, n )
                            SetDropdownState( false )

							SendElasticGameEvent( "f4r_f4_3points_menu_click", { menu = v.key } )
                        end )
                        :ibOnHover( function( )
                            bg_hover:ibAlphaTo( 255, 150 )
                        end )
                        :ibOnLeave( function( )
                            bg_hover:ibAlphaTo( 0, 150 )
                        end )

                    local lbl_name = ibCreateLabel( npx, npy, 0, nsy, name, dropdown_bg, 0xffffffff, _, _, "left", "center", ibFonts.bold_12 ):ibData( "disabled", true )
                    
                    -- Не нужна линия у последнего элемента списка
                    if n ~= #ACTIVE_TABS then
                        ibCreateImage( 0, npy + nsy - 1, nsx, 1, _, dropdown_bg, 0x30000000 ):ibData( "priority", 2 )
                    end

                    table.insert( NAVIGATION.data, { label = lbl_name, area = bg, conf = v, is_in_dropdown = true } )
                    npy = npy + nsy
                end

                local function HandleClickAnywhere( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if isElement( dropdown_bg ) and GetDropdownState( ) then
                        dropdown_bg:ibAlphaTo( 0, 100 )
                        dropdown_bg:ibTimer( function( self ) SetDropdownState( false ) end, 100, 1 )
                    end
                end
                addEventHandler( "onClientClick", root, HandleClickAnywhere, true, "low-1000000" )

                dropdown_bg:ibOnDestroy( function( )
                    removeEventHandler( "onClientClick", root, HandleClickAnywhere )
                end )

            end
            break

        -- Обычный список
        else
            local lbl_name
                = ibCreateLabel( npx, 89, 0, 0, v.name, NAVIGATION.area, 0xffffffff, _, _, "left", "top", ibFonts.bold_14 )
                :ibData( "alpha", ibGetAlpha( 75 ) )
            
            local icon_new = ibCreateImage( lbl_name:ibGetAfterX( -3 ), lbl_name:ibGetCenterY( -20 ), 0, 0, "img/icon_indicator_new.png", NAVIGATION.area ):ibSetRealSize( )
            if not v.update_count or v.update_count <= ( UPDATE_COUNTERS[ v.key ] or 0 ) then
                icon_new:ibData( "alpha", 0 )
            end

            local area
                = ibCreateArea( npx, 89 - 5, lbl_name:width( ), lbl_name:height( ) + 10, NAVIGATION.area )
                :ibOnHover( function( )
                    for i, v in pairs( NAVIGATION.data ) do
                        v.label:ibAlphaTo( ( v.label == lbl_name or NAVIGATION.current == i ) and 255 or 200 )
                    end
                end )
                :ibOnLeave( function( )
                    if i ~= NAVIGATION.current then
                        lbl_name:ibAlphaTo( 200 )
                    end
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if icon_new:ibData( "alpha" ) > 0 then
                        icon_new:ibData( "alpha", 0 )
                        UPDATE_COUNTERS[ v.key ] = v.update_count
                        SaveUpdateCounters( )
                    end
                    triggerEvent( "SwitchNavbar", resourceRoot, i )

					SendElasticGameEvent( "f4r_f4_tab_click", { tab = v.key } )
                end )

            table.insert( NAVIGATION.data, { label = lbl_name, icon_new = icon_new, area = area, conf = v } )

            npx = npx + lbl_name:width( ) + 30
        end
    end

    ibCreateLine( 30, 117, 770, _, ibApplyAlpha( 0xffffffff, 10 ), 1, NAVIGATION.area )
end

function SetNavbarTabNew( tab_key, new_update_count )
    if not NAVIGATION.data or not isElement( NAVIGATION.area ) then return end
    
    local tab_num
    for i, v in pairs( ACTIVE_TABS ) do
        if v.key == tab_key then
            tab_num = i
            break
        end
    end

    if new_update_count then
        ACTIVE_TABS[ tab_num ].update_count = new_update_count
        if UPDATE_COUNTERS[ tab_key ] == new_update_count then return end
    end

    local menu_data = NAVIGATION.data[ tab_num ]
    if not menu_data or not isElement( menu_data.icon_new ) then return end

    menu_data.icon_new:ibAlphaTo( 255, 500 )
end

function SetDropdownState( state )
    if not isElement( NAVIGATION.dropdown_bg ) then return end

    if state then
        NAVIGATION.dropdown_bg:ibBatchData( { px = NAVIGATION.dropdown_px, py = NAVIGATION.dropdown_py } )
    else
        NAVIGATION.dropdown_bg:ibBatchData( { px = -2048, -2048 } )
    end
end

function GetDropdownState( )
    if not isElement( NAVIGATION.dropdown_bg ) then return end

    local px, py = NAVIGATION.dropdown_bg:ibData( "px" ), NAVIGATION.dropdown_bg:ibData( "py" )
    return px == NAVIGATION.dropdown_px and py == NAVIGATION.dropdown_py
end

function SwitchNavbar( tab_num, from_info )
    if not NAVIGATION.data then return end
    
    if type( tab_num ) == "string" then
        for i, v in pairs( ACTIVE_TABS ) do
            if v.key == tab_num then
                tab_num = i
                break
            end
        end
    end

    local menu_data = NAVIGATION.data[ tab_num ]
    if not menu_data then return end

    for i, v in pairs( NAVIGATION.data ) do
        v.label:ibAlphaTo( i == tab_num and 255 or 200, 50 )
    end

	--Очистка оверлеев
	for i,v in pairs( getElementChildren( UI.bg ) ) do 
		if v:ibData("overlay") then destroyElement(v) end
	end
	

    NAVIGATION.current = tab_num

    -- Если меняем локацию хендла, то удаляеям с анимацией предварительно
    if NAVIGATION.is_in_dropdown ~= menu_data.is_in_dropdown then
        if isElement( NAVIGATION.handle ) then
            NAVIGATION.handle:ibAlphaTo( 0, 50 ):ibTimer( function( self ) self:destroy( ) end, 50, 1 )
            NAVIGATION.handle = nil
        end
    end

    if menu_data.is_in_dropdown then
        local py = menu_data.area:ibData( "py" ) + 45 / 2 - 13 / 2
        if isElement( NAVIGATION.handle ) then
            NAVIGATION.handle:ibMoveTo( _, py, 200 )
        else
            NAVIGATION.handle
                = ibCreateImage( 197, py, 3, 13, _, NAVIGATION.dropdown_bg, 0xfffb9769 )
                :ibBatchData( { priority = 5, alpha = 0 } )
                :ibAlphaTo( 255, 200 )
        end

    else
        local px, sx = menu_data.label:ibData( "px" ), menu_data.label:width( )
        if isElement( NAVIGATION.handle ) then
            NAVIGATION.handle:ibMoveTo( px, _, 200 ):ibResizeTo( sx, _, 200 )
        else
            NAVIGATION.handle
                = ibCreateImage( px, 114, sx, 3, _, NAVIGATION.area, 0xffff9759 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 200 )
        end
    end

    NAVIGATION.is_in_dropdown = menu_data.is_in_dropdown
    triggerEvent( "SwitchContent", resourceRoot, tab_num )

    SendElasticGameEvent( "f4_window_navigate", { window_tab_name = ACTIVE_TABS[ tab_num ].name } )

	if from_info then
		if from_info == "slider" then
			SendElasticGameEvent( "f4r_f4_main_slider_click", { main_slider = ACTIVE_TABS[ tab_num ].name } )
		end
	end
end
addEvent( "SwitchNavbar", true )
addEventHandler( "SwitchNavbar", root, SwitchNavbar )