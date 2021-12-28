Import( "ib/dropdown" )

function ibCreateNavbar( conf )
    local self = conf

    self.parent = self.parent
    self.px, self.py = self.px or 30, self.py or 0
    self.sx, self.sy = self.sx or self.parent:ibData( "sx" ) - 60, self.sy or 46
    self.priority = self.priority or 2
    self.label_py = self.label_py or math.floor( self.sy - self.sy * ( 29 / 46 ) )
    self.gap = self.gap or 30
    self.font = self.font or ibFonts.bold_14

    self.tabs = self.tabs or { }
    self.current = self.current or 1
    -- self.fn_OnSwitch = self.fn_OnSwitch

	self.elements = { }
	self.elements.tabs = { }
    
    self.elements.area = ibCreateArea( self.px, self.py, self.sx, self.sy, self.parent )
        :ibData( "priority", self.priority )

    local npx = 0
    for i, v in pairs( self.tabs ) do
        if not v.fn_check or v:fn_check( ) then
            local width = dxGetTextWidth( v.name, 1, self.font )

            -- Генерация выпадающего списка
            if npx + width > self.sx - ( i == #self.tabs and 0 or 30 ) then
                local height_active = 20
                self.elements.btn_dropdown = ibCreateArea( self.sx - 19, ( self.sy - height_active ) / 2, 18, 6 + height_active, self.elements.area )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 150, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        self.dropdown:SetVisible( true )
                    end )
                    :ibData( "alpha", 150 )
            
                ibCreateImage( 0, height_active / 2, 18, 6, ":nrp_shared/img/btn_dropdown.png", self.elements.btn_dropdown )
                    :ibData( "disabled", true )

                local start_tab_id = i
                local items = { }
                for i = start_tab_id, #self.tabs do
                    table.insert( items, self.tabs[ i ].name )
                end

                self.dropdown = ibCreateDropdown( {
                    parent = self.elements.area,
                    px = self.sx - 200,
                    py = self.elements.btn_dropdown:ibData( "py" ) + 27,
                    items = items,
                    fn_click = function( self_dropdown, selected_item_id )
                        self:Switch( start_tab_id - 1 + selected_item_id )
                    end,
                } )
                
                for i = 1, #items do
                    local item_elements = self.dropdown.elements.items[ i ]
                    table.insert( self.elements.tabs, { lbl = item_elements.lbl, area = item_elements.bg, is_in_dropdown = true } )
                end

                break

            -- Обычный список
            else
                local lbl_name = ibCreateLabel( npx, self.label_py, 0, 0, v.name, self.elements.area, 0xffffffff, _, _, "left", "top", self.font )
                    :ibData( "alpha", 150 )
                
                local icon_new = ibCreateImage( lbl_name:ibGetAfterX( -3 ), lbl_name:ibGetCenterY( -20 ), 0, 0, ":nrp_shared/img/icon_indicator_new.png", self.elements.area ):ibSetRealSize( )
                if not v.update_count or v.update_count <= ( UPDATE_COUNTERS[ v.key ] or 0 ) then
                    icon_new:ibData( "alpha", 0 )
                end

                local area = ibCreateArea( npx, self.label_py - 5, lbl_name:width( ), lbl_name:height( ) + 10, self.elements.area )
                    :ibOnHover( function( )
                        for i, v in pairs( self.elements.tabs ) do
                            v.lbl:ibAlphaTo( ( v.lbl == lbl_name or self.current == i ) and 255 or 150 )
                        end
                    end )
                    :ibOnLeave( function( )
                        if i ~= self.current then
                            lbl_name:ibAlphaTo( 150 )
                        end
                    end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        if self.current == i then return end
                        ibClick( )
                        if icon_new:ibData( "alpha" ) > 0 then
                            icon_new:ibData( "alpha", 0 )
                            UPDATE_COUNTERS[ v.key ] = v.update_count
                        end
                        self:Switch( i )
                    end )

                self.elements.tabs[ i ] = { lbl = lbl_name, icon_new = icon_new, area = area }

                npx = npx + lbl_name:width( ) + self.gap
            end
        end
    end

    self.elements.area:ibData( "sx", self.elements.dropdown and self.sx or npx )

    ibCreateLine( 0, self.sy, self.sx, _, ibApplyAlpha( 0xffffffff, 10 ), 1, self.elements.area )

    -- self.SetDropdownState = function( self, state )
    --     if not isElement( self.elements.dropdown_bg ) then return end

    --     self.elements.dropdown_bg:ibData( "visible", state )
    -- end

    -- self.GetDropdownState = function( self )
    --     if not isElement( self.elements.dropdown_bg ) then return end

    --     return self.elements.dropdown_bg:ibData( "visible" )
    -- end

    self.SetTabNew = function( self, tab_key )
        if not self.elements.tabs or not isElement( self.elements.area ) then return end
        
        local tab_num
        for i, v in pairs( self.tabs ) do
            if v.key == tab_key then
                tab_num = i
                break
            end
        end

        local menu_data = self.elements.tabs[ tab_num ]
        if not menu_data or not isElement( menu_data.icon_new ) then return end

        menu_data.icon_new:ibAlphaTo( 255, 500 )
    end

    self.Switch = function( self, tab_num )
        if not self.elements.tabs then return end
        
        if type( tab_num ) == "string" then
            for i, v in pairs( self.tabs ) do
                if v.key == tab_num then
                    tab_num = i
                    break
                end
            end
        end

        local menu_data = self.elements.tabs[ tab_num ]
        if not menu_data then return end

        for i, v in pairs( self.elements.tabs ) do
            v.lbl:ibAlphaTo( i == tab_num and 255 or 150, 50 )
        end

        self.current = tab_num

        -- Если меняем локацию хендла, то удаляем с анимацией предварительно
        if self.is_in_dropdown ~= menu_data.is_in_dropdown then
            if isElement( self.elements.handle ) then
                self.elements.handle:ibAlphaTo( 0, 50 ):ibTimer( destroyElement, 50, 1 )
                self.elements.handle = nil
            end
        end

        if menu_data.is_in_dropdown then
            local py = menu_data.area:ibData( "py" ) + 45 / 2 - 13 / 2
            if isElement( self.elements.handle ) then
                self.elements.handle:ibMoveTo( _, py, 200 )
            else
                self.elements.handle = ibCreateImage( 197, py, 3, 13, _, self.dropdown.elements.area, 0xfffb9769 )
                    :ibBatchData( { priority = 5, alpha = 0 } )
                    :ibAlphaTo( 255, 200 )
            end

        else
            local px, sx = menu_data.lbl:ibData( "px" ), menu_data.lbl:width( )
            if isElement( self.elements.handle ) then
                self.elements.handle:ibMoveTo( px, _, 200 ):ibResizeTo( sx, _, 200 )
            else
                self.elements.handle = ibCreateImage( px, self.sy - 3, sx, 3, _, self.elements.area, 0xffff9759 )
                    :ibData( "alpha", 0 )
                    :ibAlphaTo( 255, 200 )
            end
        end

        self.is_in_dropdown = menu_data.is_in_dropdown

        if self.fn_OnSwitch then
            self.fn_OnSwitch( tab_num )
        end
    end

    self.destroy = function( self )
        DestroyTableElements( self.elements )
    end

    self:Switch( self.current )

    return self
end