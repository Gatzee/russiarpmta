function ibCreateDropdown( conf )
    local self = conf

    self.parent = self.parent
    self.priority = self.priority or 1
    self.px, self.py = self.px or 30, self.py or 0
    self.sx, self.sy = self.sx or 200, self.sy or 200
    self.item_sy = self.item_sy or 45
    self.triangle_px = self.triangle_px or ( self.sx - 4 - 10 )
    self.triangle_py = self.triangle_py or 0
    self.font = self.font or ibFonts.bold_14

    self.items = self.items or { }
    -- self.fn_OnSwitch = self.fn_OnSwitch

	self.elements = { }
	self.elements.items = { }

    self.elements.area = ibCreateArea( self.px, self.py, self.sx, #self.items * self.item_sy, self.parent )
        :ibBatchData( {
            alpha = 0,
            visible = false,
            disabled = true,
            priority = self.priority,
        } )
    ibCreateImage( self.triangle_px, self.triangle_py, 10, 5, ":nrp_shared/img/icon_triangle.png", self.elements.area )

    -- self:SetVisible( false )

    local npx, npy = 15, 5

    for i, item_name in ipairs( self.items ) do
        local bg = ibCreateImage( 0, npy, self.sx, self.item_sy, _, self.elements.area, 0xff66809d )
            --:ibData( "blend_mode", "modulate_add" ):ibData( "blend_mode_after", "blend" )
        local bg_hover = ibCreateImage( 0, npy, self.sx, self.item_sy, _, self.elements.area, 0xff768da7 )
            :ibBatchData( { 
                alpha = 0, 
                disabled = true, 
                blend_mode = modulate_add,
                blend_mode_after = blend,
            } )

        bg
            :ibData( "priority", -1 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                if self.fn_click then
                    self:fn_click( i )
                end
                self:SetVisible( false )
            end )
            :ibOnHover( function( )
                bg_hover:ibAlphaTo( 255, 150 )
            end )
            :ibOnLeave( function( )
                bg_hover:ibAlphaTo( 0, 150 )
            end )

        local lbl_name = ibCreateLabel( npx, npy, 0, self.item_sy, item_name, self.elements.area, 0xffffffff, _, _, "left", "center", self.font )
            :ibData( "disabled", true )
        
        -- Не нужна линия у последнего элемента списка
        if i ~= #self.items then
            ibCreateImage( 0, npy + self.item_sy - 1, self.sx, 1, _, self.elements.area, 0x30000000 ):ibData( "priority", 2 )
        end

        table.insert( self.elements.items, { lbl = lbl_name, bg = bg, bg_hover = bg_hover } )
        npy = npy + self.item_sy
    end

    self.elements.area:ibOnAnyClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        if not self:GetState( ) then return end
        self.elements.area:ibAlphaTo( 0, 100 ):ibTimer( function( ) self:SetVisible( false ) end, 100, 1 )
    end )

    self.SetVisible = function( self, state )
        if not isElement( self.elements.area ) then return end

        self.elements.area:ibData( "visible", state ):ibAlphaTo( 255, 150 )
    end

    self.GetState = function( self )
        if not isElement( self.elements.area ) then return end

        return self.elements.area:ibData( "visible" )
    end

    self.destroy = function( self )
        DestroyTableElements( self.elements )
    end

    return self
end