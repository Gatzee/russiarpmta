Import( "ib/navbar" )

function ibCreateTabPanel( conf )
    local self = conf

    self.parent = self.parent
    self.px, self.py = self.px or 0, self.py or 0
    self.sx, self.sy = self.sx or self.parent:ibData( "sx" ), self.sy or ( self.parent:ibData( "sy" ) - self.py )

    self.tabs = self.tabs or { }
    self.tabs_conf = self.tabs_conf or { }
    self.current = self.current or 1
    self.precreate_all_tabs_content = self.precreate_all_tabs_content or false
    self.create_tab_area_under_navbar = self.create_tab_area_under_navbar or false
    self.tab_switch_anim_duration = self.tab_switch_anim_duration or 200
    -- self.fn_OnTabSwitch = self.fn_OnTabSwitch
    
	self.elements = { }
	self.elements.rt = ibCreateRenderTarget( self.px, self.py, self.sx, self.sy, self.parent )
        -- :ibData( "modify_content_alpha", true )

    self.navbar_conf = self.navbar_conf or { }
    self.navbar_conf.px = self.navbar_conf.px or 30
    self.navbar_conf.py = self.navbar_conf.py or 0
    self.navbar_conf.parent = self.elements.rt
    self.navbar_conf.tabs = self.tabs
    self.navbar_conf.current = self.current
    self.navbar = ibCreateNavbar( self.navbar_conf )

    self.tab_area_px = self.tab_area_px or 0
    self.tab_area_py = self.tab_area_py or self.create_tab_area_under_navbar and ( self.navbar.sy + 1 ) or 0
    self.tab_area_sx = self.tab_area_sx or self.sx - self.tab_area_px
    self.tab_area_sy = self.tab_area_sy or self.sy - self.tab_area_py
    self.elements.tabs = { }

    if self.precreate_all_tabs_content then
        for i, v in pairs( self.tabs ) do
            local tab_conf = self.tabs_conf[ v.key ]
            if tab_conf and ( not v.fn_check or v:fn_check( ) ) then
                local tab_area = ibCreateArea( self.tab_area_px, self.tab_area_py, self.tab_area_sx, self.tab_area_sy, self.elements.rt )
                    :ibBatchData( { visible = false, alpha = 0, priority = -10 } )

                if tab_conf.fn_create then
                    tab_conf:fn_create( tab_area )
                end

                self.elements.tabs[ i ] = { area = tab_area }
            end
        end
    end
    
    self.navbar.fn_OnSwitch = function( tab_num )
        local new_tab_area

        local old_tab_num = self.current
        local old_tab_area = self.elements.tabs[ old_tab_num ].area

        old_tab_area:ibData( "priority", -10 )
        
        local animation_duration = self.tab_switch_anim_duration
        local tab_conf = self.tabs_conf[ self.tabs[ tab_num ].key ]

        if self.precreate_all_tabs_content then
            new_tab_area = self.elements.tabs[ tab_num ].area
                :ibKillTimer( )
                :ibData( "priority", 0 )
                :ibAlphaTo( 255, animation_duration )
                :ibData( "visible", true )
        else
            new_tab_area = ibCreateArea( self.tab_area_px, self.tab_area_py, self.tab_area_sx, self.tab_area_sy, self.elements.rt )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, animation_duration )
            self.elements.tabs[ tab_num ] = { area = tab_area }

            if tab_conf.fn_create then
                tab_conf:fn_create( new_tab_area )
            end
        end

        if old_tab_num and isElement( old_tab_area ) then
            -- Анимация появления с правой стороны
            if tab_num > old_tab_num then
                old_tab_area:ibMoveTo( self.tab_area_px - 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
                new_tab_area:ibData( "px", self.tab_area_px + 100 ):ibMoveTo( self.tab_area_px, _, animation_duration )
            -- Анимация появления с левой стороны
            elseif tab_num < old_tab_num then
                old_tab_area:ibMoveTo( self.tab_area_px + 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
                new_tab_area:ibData( "px", self.tab_area_px - 100 ):ibMoveTo( self.tab_area_px, _, animation_duration )
            end

            if tab_num ~= old_tab_num then
                old_tab_area:ibTimer( function( )
                    if self.precreate_all_tabs_content then
                        old_tab_area:ibData( "visible", false )
                    else
                        old_tab_area:destroy( )
                    end
                end, animation_duration, 1 )
            end
        end

        self.current = tab_num
        self.elements.current_area = new_tab_area

        if tab_conf.fn_open then
            tab_conf:fn_open( self.elements.current_area, old_tab_num == tab_num )
        end

        if self.fn_OnTabSwitch then
            self:fn_OnTabSwitch( tab_num, old_tab_num )
        end
    end

    self.GetCurrentTabArea = function( )
        return self.elements.current_area
    end
    self.GetCurrentContentArea = self.GetCurrentTabArea

    self.SetTabNew = self.navbar.SetTabNew

    self.SwitchTab = function( self, tab_num )
        self.navbar:Switch( tab_num )
    end

    self.destroy = function( self )
        DestroyTableElements( self.elements )
    end

    self:SwitchTab( self.current )

    return self
end