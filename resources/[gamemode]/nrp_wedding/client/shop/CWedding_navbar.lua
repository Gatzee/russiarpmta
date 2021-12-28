local NAVIGATION = { }
NAVBAR_TABS = {
	{
		name = "Товары",
		key  = "gifts",
	},
	{
		name = "Услуги",
		key  = "offers",
	},
}
TABS_CONF = {}

function SUBM_Navbar( parent )
	NAVIGATION.area = ibCreateArea( 0, 0, 1, 1, parent )
	:ibData( "priority", 2 )
	:ibOnDestroy( function( ) NAVIGATION = { } end )

	NAVIGATION.data = { }

	local npx = 30
	for i, v in pairs( NAVBAR_TABS ) do
		local width = dxGetTextWidth( v.name, 1, ibFonts.bold_14 )
		local lbl_name = ibCreateLabel( npx, 89, 0, 0, v.name, NAVIGATION.area, 0xffffffff, _, _, "left", "top", ibFonts.regular_12 )
		:ibData( "alpha", ibGetAlpha( 75 ) )

		local area = ibCreateArea( npx, 89 - 5, lbl_name:width( ), lbl_name:height( ) + 10, NAVIGATION.area )
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
			SUBM_SwitchNavbar( i )
		end )
		table.insert( NAVIGATION.data, { label = lbl_name, area = area, conf = v } )
		npx = npx + lbl_name:width( ) + 30
	end

	ibCreateLine( 30, 117, 770, _, ibApplyAlpha( 0xffffffff, 10 ), 1, NAVIGATION.area )
end

function SUBM_SwitchNavbar( tab_num )
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

	NAVIGATION.current = tab_num

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
			NAVIGATION.handle = ibCreateImage( 197, py, 3, 13, _, NAVIGATION.dropdown_bg, 0xfffb9769 )
			:ibBatchData( { priority = 5, alpha = 0 } )
			:ibAlphaTo( 255, 200 )
		end

	else
		local px, sx = menu_data.label:ibData( "px" ), menu_data.label:width( )
		if isElement( NAVIGATION.handle ) then
			NAVIGATION.handle:ibMoveTo( px, _, 200 ):ibResizeTo( sx, _, 200 )
		else
			NAVIGATION.handle = ibCreateImage( px, 114, sx, 3, _, NAVIGATION.area, 0xffff9759 )
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 200 )
		end
	end

	NAVIGATION.is_in_dropdown = menu_data.is_in_dropdown
	SUBM_SwitchContent( tab_num )
end

function SUBM_SwitchContent( tab_num )
    if not CONTENT.data then return end

    local content_data = CONTENT.data[ tab_num ]
    if not content_data then return end

    for i, v in pairs( CONTENT.data ) do
        if i ~= tab_num then
            v.area:ibData( "priority", -10 )
        end
    end
    
    local animation_duration = 200

    content_data.area
        :ibKillTimer( )
        :ibData( "priority", 0 )
        :ibAlphaTo( 255, animation_duration )
        :ibData( "visible", true )

    if CONTENT.current and isElement( CONTENT.current_area ) then
        -- Анимация появления с правой стороны
        if tab_num > CONTENT.current then
            CONTENT.current_area:ibMoveTo( -100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            content_data.area:ibData( "px", 100 ):ibMoveTo( 0, _, animation_duration )
        -- Анимация появления с левой стороны
        elseif tab_num < CONTENT.current then
            CONTENT.current_area:ibMoveTo( 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            content_data.area:ibData( "px", -100 ):ibMoveTo( 0, _, animation_duration )
        end

        if tab_num ~= CONTENT.current then
            CONTENT.current_area:ibTimer( function( self )
                self:ibData( "visible", false )
            end, animation_duration, 1 )
        end
    end

    CONTENT.current = tab_num
    CONTENT.current_area = content_data.area

    if TABS_CONF[ NAVBAR_TABS[ tab_num ].key ].fn_open then
        TABS_CONF[ NAVBAR_TABS[ tab_num ].key ]:fn_open( CONTENT.current_area )
    end
end