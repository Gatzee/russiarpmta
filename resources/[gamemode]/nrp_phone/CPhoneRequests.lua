REQUESTSAPP = nil

APPLICATIONS.requests = {
    id = "requests",
    icon = "img/elements/phone.png",
    bg = "img/elements/bg_white.png",
    name = "Вызов спецслужб",
    elements = { },
    create = function( self, parent, conf )
        self.elements.header_texture = dxCreateTexture( "img/elements/app_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local numbers = {
            [ "02" ] = "Полиция",
            [ "03" ] = "Медики",
            [ "112" ] = "ДПС",
        }

        local tex_list = { "btn_cancel", "btn_ok", "btn_call", "edit_field", "transfer_popup_bg", "transfer_error_bg" }
        for k,v in pairs(tex_list) do
            self.elements["tex_"..v] = dxCreateTexture( "img/elements/"..v..".png" )
        end

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent )

        self.elements.header_text = ibCreateLabel( 15, 25, 0, 0, "Вызов гос. структуры", parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_12 )

        self.elements.label_nickname = ibCreateLabel( 0, 80, conf.sx, 0, "Введите номер", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.bold_12 )
        self.elements.edit_name = ibCreateEdit( (conf.sx-176)/2, 100, 176, 38, "", parent, 0xFFFFFFFF - 0x55AA0000, 0xFFFFFFFF - 0xF0000000, 0xFFFFFFFF ):ibData( "font", ibFonts.bold_12 )
        self.elements.label_amount = ibCreateLabel( 0, 165, conf.sx, 0, "Причина", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.bold_12 )
        self.elements.edit_reason = ibCreateEdit( (conf.sx-176)/2, 185, 176, 38, "", parent, 0xFFFFFFFF - 0x55AA0000, 0xFFFFFFFF - 0xF0000000, 0xFFFFFFFF ):ibData( "font", ibFonts.bold_12 )
        self.elements.label_hint = ibCreateLabel( 0, 250, conf.sx, 0, "02 - ППС, 03 - Медики\n112 - ДПС", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.regular_10 )

        self.elements.btn_call = ibCreateButton(    (conf.sx-48)/2, 290, 48, 48, parent,
                                                    self.elements.tex_btn_call, self.elements.tex_btn_call, self.elements.tex_btn_call, 
                                                    0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            local edit_name = self.elements.edit_name:ibData( "text" )
            local edit_reason = self.elements.edit_reason:ibData( "text" )

            if not edit_name or not numbers[ edit_name ] then
                localPlayer:ShowError( "Некорректный номер службы" )
                return false
            end

            if not edit_reason or utf8.len( edit_reason ) <= 5 then
                localPlayer:ShowError( "Некорректная причина" )
                return false
            end

            ibClick( )

            self.name = edit_name
            self.reason = edit_reason

            self.elements.black_bg = ibCreateImage( 0, 0, conf.sx, conf.sy, _, parent, 0xDD000000 )
            self.elements.popup_bg = ibCreateImage( (conf.sx-176)/2, (conf.sy-246)/2, 176, 246, self.elements.tex_transfer_popup_bg, self.elements.black_bg )
        
            local parent = self.elements.popup_bg

            self.elements.label_popup  = ibCreateLabel( 0, 40, 176, 0, "Подтверждение", parent, _, _, _, "center", "center", ibFonts.bold_12 )
            self.elements.label_name   = ibCreateLabel( 0, 80, 176, 0, "Вызов:", parent, 0xAAAAAAAA, _, _, "center", "center", ibFonts.regular_10 )
            self.elements.label_name_2 = ibCreateLabel( 0, 100, 176, 10, self.name .. " (" .. numbers[ self.name ] .. ")", parent, _, _, _, "center", "center", ibFonts.regular_10  ):ibData( "wordbreak", true )
            self.elements.label_sum    = ibCreateLabel( 0, 140, 176, 0, "Причина:", parent, 0xAAAAAAAA, _, _, "center", "center", ibFonts.regular_10 )

            local reason = self.reason
            if utf8.len( reason ) > 12 then
                reason = utf8.sub( reason, 1, 12 ) .. "..."
                if utf8.len( reason ) > 96 then
                    self.reason = utf8.sub( self.reason, 1, 96 ) .. "..."
                end
            end
            self.elements.label_sum_2 = ibCreateLabel( 0, 160, 176, 0, reason, parent, _, _, _, "center", "center", ibFonts.regular_10 )

            self.elements.btn_ok = ibCreateButton(  16, 190, 60, 30, parent,
                                                    self.elements.tex_btn_ok, self.elements.tex_btn_ok, self.elements.tex_btn_ok, 
                                                    0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                triggerServerEvent( "onPhoneSendStuffRequest", localPlayer, self.name, self.reason )
                destroyElement( self.elements.black_bg )
                ShowPhoneUI( false )
            end, false )


            self.elements.btn_cancel = ibCreateButton(  82, 190, 80, 30, parent,
                                                        self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, self.elements.tex_btn_cancel, 
                                                        0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                destroyElement( self.elements.black_bg )
            end, false )
        end, false )

        REQUESTSAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        REQUESTSAPP = nil
    end,
}

BLIPS = { }
BLIPS_TIMERS = { }

function onFactionShowLocation_handler( color )
    if not isElement( source ) then return end
    onClientPlayerQuit_handler( source )
    local r, g, b = unpack( color )

    BLIPS[ source ]         = createBlipAttachedTo( source, 0, 2, r, g, b, 255, 0, 99999, root )
    BLIPS_TIMERS[ source ]  = setTimer( onClientPlayerQuit_handler, 5 * 60 * 1000, 1, source )

    addEventHandler( "onClientPlayerQuit", source, onClientPlayerQuit_handler )
end
addEvent( "onFactionShowLocation", true )
addEventHandler( "onFactionShowLocation", root, onFactionShowLocation_handler )

function hideFactionBlips_handler()
    for k, v in pairs( BLIPS ) do
        onClientPlayerQuit_handler(k)
    end
end
addEvent( "hideFactionBlips", true )
addEventHandler( "hideFactionBlips", root, hideFactionBlips_handler )

function onClientPlayerQuit_handler( player )
    local player = isElement( player ) and player or source
    if isElement( BLIPS[ player ] ) then destroyElement( BLIPS[ player ] ) end
    if isTimer( BLIPS_TIMERS[ player ] ) then killTimer( BLIPS_TIMERS[ player ] ) end
    removeEventHandler( "onClientPlayerQuit", player, onClientPlayerQuit_handler )
end
