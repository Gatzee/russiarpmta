TRANSFERAPP = nil

APPLICATIONS.transfer = {
    id = "transfer",
    icon = "img/apps/transfer.png",
    name = "Перевод денег",
    elements = { },
    create = function( self, parent, conf )
        self.elements.header_texture = dxCreateTexture( "img/elements/app_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local tex_list = { "btn_cancel", "btn_ok", "btn_transfer", "edit_field", "transfer_popup_bg", "transfer_error_bg" }
        for k,v in pairs(tex_list) do
            self.elements["tex_"..v] = dxCreateTexture( "img/elements/"..v..".png" )
        end

        local size_y = hsy * conf.sx / hsx
        self.elements.header      = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent )
        self.elements.header_text = ibCreateLabel( 15, 25, 0, 0, "Перевод средств", parent, 0xFFFFFFFF ):ibData( "font", ibFonts.bold_12 )

        self.elements.label_nickname = ibCreateLabel( 0, 80, conf.sx, 0, "Имя получателя", parent, 0xFFFFFFFF - 0x55AA0000 ):ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center" } )
        self.elements.edit_name      = ibCreateEdit( (conf.sx-176)/2, 100, 176, 38, "", parent, 0xFFFFFFFF - 0x55AA0000, 0xFFFFFFFF - 0xF0000000, 0xFFFFFFFF ):ibData( "font", ibFonts.bold_12 )
        self.elements.label_amount   = ibCreateLabel( 0, 165, conf.sx, 0, "Сумма перевода", parent, 0xFFFFFFFF - 0x00AA0000 ):ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center" } )
        self.elements.edit_sum       = ibCreateEdit( (conf.sx-176)/2, 185, 176, 38, "", parent, 0xFFFFFFFF - 0x55AA0000, 0xFFFFFFFF - 0xF0000000, 0xFFFFFFFF ):ibData( "font", ibFonts.bold_12 )
        self.elements.label_hint     = ibCreateLabel( 0, 240, conf.sx, 0, "Макс. сумма - 150.000 в сутки", parent, 0xFFFFFFFF - 0x55AA0000 ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", align_y = "center" } )
        self.elements.btn_transfer   = ibCreateButton(  (conf.sx-130)/2, 300, 130, 30, parent,
                                                        self.elements.tex_btn_transfer, self.elements.tex_btn_transfer, self.elements.tex_btn_transfer, 
                                                        0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            local name = self.elements.edit_name:ibData( "text" )
            local sum  = math.abs( math.floor( tonumber( self.elements.edit_sum:ibData( "text" ) ) ) )

            if not name or utf8.len( name ) <= 4 then
                localPlayer:ShowError( "Некорректное имя получателя" )
                return false
            end

            if not sum or sum <= 0 then
                localPlayer:ShowError( "Некорректная сумма" )
                return false
            end

            self.name = name
            self.amount = sum

            self.elements.black_bg = ibCreateImage( 0, 0, conf.sx, conf.sy, _, parent, 0xDD000000 )
            self.elements.popup_bg = ibCreateImage( (conf.sx-176)/2, (conf.sy-246)/2, 176, 246, self.elements.tex_transfer_popup_bg, self.elements.black_bg )

            local parent = self.elements.popup_bg
            self.elements.label_popup  = ibCreateLabel( 0, 40, 176, 0, "Подтверждение", parent, _, _, _, "center", "center", ibFonts.bold_12 )
            self.elements.label_name   = ibCreateLabel( 0, 80, 176, 0, "Кому:", parent, 0xAAAAAAAA, _, _, "center", "center", ibFonts.regular_10 )
            self.elements.label_name_2 = ibCreateLabel( 0, 100, 176, 10, self.name, parent, _, _, _, "center", "center", ibFonts.regular_10 ):ibData( "wordbreak", true )
            self.elements.label_sum    = ibCreateLabel( 0, 140, 176, 0, "Сумма перевода:", parent, 0xAAAAAAAA, _, _, "center", "center", ibFonts.regular_10 )
            self.elements.label_sum_2  = ibCreateLabel( 0, 160, 176, 0, format_price( self.amount ), parent, _, _, _, "center", "center", ibFonts.regular_10 )
            self.elements.btn_ok       = ibCreateButton(    16, 190, 60, 30, parent,
                                                            self.elements.tex_btn_ok, self.elements.tex_btn_ok, self.elements.tex_btn_ok, 
                                                            0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if not self.amount or self.amount <= 0 then return end
                triggerServerEvent( "onPhoneTransferRequest", localPlayer, self.name, self.amount )

                destroyElement( self.elements.black_bg )
            end, false )

            self.elements.btn_cancel = ibCreateButton(  82, 190, 80, 30, parent,
                                                        self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, 
                                                        0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                destroyElement( self.elements.black_bg )
            end, false )
        end, false )

        TRANSFERAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        TRANSFERAPP = nil
    end,
}