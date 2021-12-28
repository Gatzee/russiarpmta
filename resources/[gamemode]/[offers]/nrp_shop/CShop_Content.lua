local CONTENT = { }

function CreateAllContent( parent )
    CONTENT.data = { }

    for i, v in pairs( ACTIVE_TABS ) do
        local tab = TABS_CONF[ v.key ]
        if tab then
            local tab_area
                = ibCreateArea( 0, 72, 800, 580 - 72, parent )
                :ibBatchData( { alpha = 0, priority = -10 } )
                :ibOnDestroy( function( ) tab.parent = nil end )

            if type( tab.fn_create ) == "function" then
                tab.parent = tab_area
                tab:fn_create( tab_area )
            end

            table.insert( CONTENT.data, { area = tab_area } )
        end
    end
end

function SwitchContent( tab_num )
    local active_tab = ACTIVE_TABS[ tab_num ]
    if active_tab and active_tab.event then
        ShowDonateUI( false )
        triggerServerEvent( "InitRouletteWindow", localPlayer )
        return
    end

    if not CONTENT.data then return end

    local content_data = CONTENT.data[ tab_num ]
    if not content_data then return end

    local old_tab_num = CONTENT.current

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

    if old_tab_num and isElement( CONTENT.current_area ) then
        -- Анимация появления с правой стороны
        if tab_num > old_tab_num then
            CONTENT.current_area:ibMoveTo( -100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            content_data.area:ibData( "px", 100 ):ibMoveTo( 0, _, animation_duration )
        -- Анимация появления с левой стороны
        elseif tab_num < old_tab_num then
            CONTENT.current_area:ibMoveTo( 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            content_data.area:ibData( "px", -100 ):ibMoveTo( 0, _, animation_duration )
        end

        if tab_num ~= old_tab_num then
            CONTENT.current_area:ibTimer( function( self )
                self:ibData( "visible", false )
            end, animation_duration, 1 )
        end
    end

    CONTENT.current = tab_num
    CONTENT.current_area = content_data.area

    if TABS_CONF[ ACTIVE_TABS[ tab_num ].key ].fn_open then
        TABS_CONF[ ACTIVE_TABS[ tab_num ].key ]:fn_open( CONTENT.current_area, old_tab_num == tab_num )
    end
end
addEvent( "SwitchContent", true )
addEventHandler( "SwitchContent", root, SwitchContent )

function GetCurrentContentArea( )
    return CONTENT.current_area
end