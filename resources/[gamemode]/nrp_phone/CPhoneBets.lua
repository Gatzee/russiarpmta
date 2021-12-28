--[[
BETSAPP = nil

APPLICATIONS.bets = {
    id = "bets",
    icon = "img/apps/bets.png",
    name = "Бойцовский клуб",
    elements = { },
    create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf
        self.elements.header_texture = dxCreateTexture( "img/elements/bets/header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local tex_list = { "arrow", "btn_bet", "btn_cancel", "edit_field", "header" }
        for k,v in pairs(tex_list) do
            self.elements["tex_"..v] = dxCreateTexture( "img/elements/bets/"..v..".png" )
        end

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent, 0xFFFFFFFF )

        self.elements.bold_line = ibCreateImage( 0, 60, conf.sx, 18, _, parent, 0xA0000000 )
        self.elements.l_list = ibCreateLabel( 0, 60, conf.sx, 18, "СПИСОК УЧАСТНИКОВ", parent, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 )

        triggerServerEvent("FC:OnPlayerRequestAppData", localPlayer)

        BETSAPP = self
        return self
    end,

    create_confirmation = function( self, parent, conf )
        self.elements.header_texture = dxCreateTexture( "img/elements/bets/header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )
        local size_y = hsy * conf.sx / hsx

        local tex_list = { "arrow", "btn_bet", "btn_cancel", "edit_field", "header" }
        for k,v in pairs(tex_list) do
            self.elements["tex_"..v] = dxCreateTexture( "img/elements/bets/"..v..".png" )
        end

        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent, 0xFFFFFFFF )

        self.elements.bold_line = ibCreateImage( 0, 60, conf.sx, 3, nil, parent, 0xA0000000 )
        self.elements.l_list = ibCreateLabel( 0, 60, conf.sx, 18, "СДЕЛАТЬ СТАВКУ", parent, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 )

        self.elements.l_selection = ibCreateLabel( 0, 90, conf.sx, 18, "Выбранный боец:", parent, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 )

        self.elements.l_list = ibCreateLabel( 0, 110, conf.sx, 18, self.data.fighters[ self.selection ].name, parent, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

        self.elements.edit_sum = ibCreateEdit( (conf.sx-176)/2, 150, 176, 38, "Размер ставки", parent, 0xFFFFFFFF, 0x55000000, 0xFFFFFFFF )

        self.elements.btn_bet = ibCreateButton( (conf.sx-100)/2, 210, 100, 30, parent,
                                                self.elements.tex_btn_bet, self.elements.tex_btn_bet, self.elements.tex_btn_bet, 
                                                0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            local edit_sum = self.elements.edit_sum:ibData( "text" )
            if edit_sum then
                ibClick( )

                local pFighterData = self.data.fighters[ self.selection ]
                triggerServerEvent( "FC:OnPlayerTryPlaceBet", localPlayer, localPlayer, edit_sum, pFighterData.uid, pFighterData.name )
                ShowPhoneUI(false)
            end
        end )
        
        self.elements.btn_cancel = ibCreateButton(  (conf.sx-100)/2, 250, 100, 30, parent,
                                                    self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, 
                                                    0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowPhoneUI(false)
        end )
    end,

    updateList = function( self, parent, conf, data )
        local data = data or self.data
        if isElement( self.elements.scrollpane ) then destroyElement( self.elements.scrollpane ) end

        self.elements.scrollpane, self.elements.scrollbar = ibCreateScrollpane( 0, 85, 204, self.parent:ibData( "sy" ) - 85, parent, { scroll_px = -10 } )
        self.elements.scrollbar:ibSetStyle( "slim_small_nobg" ) 

        local py = 0
        for k, v in pairs( data.fighters ) do
            self.elements["button"..k] = ibCreateButton( 0, py, conf.sx, 40, self.elements.scrollpane, nil, nil, nil, 0x502b3745, 0x503f5166, 0x503f5166 )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    self.selection = k
                    self:destroy()
                    self:create_confirmation( parent, conf )
                end )

            self.elements["arrow"..k] = ibCreateImage( conf.sx-20, 15, 6, 10, self.elements["tex_arrow"], self.elements["button"..k] ):ibData( "disabled", true )
            self.elements["name"..k] = ibCreateLabel( 20, 0, conf.sx, 40, v.name, self.elements["button"..k], _, _, _, _, "center", ibFonts.regular_10 ):ibData( "disabled", true )
            
            py = py + 40
        end

        self.elements.scrollpane:AdaptHeightToContents( )
		self.elements.scrollpane:UpdateScrollbarVisibility( self.elements.scrollbar )
    end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        BETSAPP = nil
    end,
}

function OnFightersDataReceived( data )
    if BETSAPP then
        BETSAPP.data = data
        BETSAPP:updateList( BETSAPP.parent, BETSAPP.conf, data )
    end
end
addEvent("FC:OnAppDataReceived", true)
addEventHandler("FC:OnAppDataReceived", root, OnFightersDataReceived)
]]