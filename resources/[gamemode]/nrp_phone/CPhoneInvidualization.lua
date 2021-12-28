PHONEINDIVIDAPP = nil

PHONE_BACKGROUND = "bg_1"
PHONE_AVAILABLE_BACKGROUNDS = { [ "bg_1" ] = true }


PHONE_DEFAULT_SOUNDS = 
{
    [ "ringtone" ]     = "ringtone_5",
    [ "message" ]      = "message_2",
    [ "notification" ] = "notification_2",
}
PHONE_CURRENT_SOUNDS = table.copy( PHONE_DEFAULT_SOUNDS )

PHONE_AVAILABLE_SOUNDS =
{
    [ "ringtone_5" ]     = true,
    [ "message_2" ]      = true,
    [ "notification_2" ] = true,
}

APPLICATIONS.phone_individ_shop = {
    id = "phone_individ_shop",
    icon = "img/apps/phone_individ_shop.png",
    name = "Магазин",
    elements = { },
    create = function( self, parent, conf )
        self.elements.header_texture = dxCreateTexture( "img/elements/shop_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        self.elements.rt = ibCreateRenderTarget( 0, 0, conf.sx, conf.sy, parent )
        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, self.elements.rt, 0xFFFFFFFF )
        
        self.elements.btn_ringtones = ibCreateButton( 0, 55, 204, 41, self.elements.rt,
            "img/elements/individ/btn_ringtones.png", "img/elements/individ/btn_ringtones.png", "img/elements/individ/btn_ringtones.png",
            0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF)
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            self.HideContentMenu()
            self.ShowRingtonesMenu()
        end )

        self.elements.btn_wallpaper = ibCreateButton( 0, 96, 204, 41, self.elements.rt,
            "img/elements/individ/btn_wallpaper.png", "img/elements/individ/btn_wallpaper.png", "img/elements/individ/btn_wallpaper.png",
            0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF)
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            self.HideContentMenu()
            self.ShowWallPaperMenu()
        end )

        self.hide_elements = {
            self.elements.btn_ringtones,
            self.elements.btn_wallpaper,
            self.elements.header
        }

        ----------------------------------------------
        -- Меню обоев
        ----------------------------------------------
        local current_wallaper_id = 1
        local prev_wallaper_id = 1

        self.ShowWallPaperMenu = function()
            self.elements.wall_menu = ibCreateArea( -204, 0, conf.sx, conf.sy, self.elements.rt )
            
            self.elements.header_text = ibCreateLabel( 82, 24, 0, 0, "Обои", self.elements.wall_menu ):ibBatchData( { font = ibFonts.bold_12, color = 0xFFFFFFFF } )
            self.elements.header_line = ibCreateImage( 0, 54, 204, 1, _, self.elements.wall_menu, 0xFFFFFFFF )
            self.elements.btn_back = ibCreateButton( 14, 27, 18, 14, self.elements.wall_menu,
                "img/elements/arrow_back.png", "img/elements/arrow_back.png", "img/elements/arrow_back.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.HideWallPaperMenu()
                self.ShowContentMenu()
            end )

            self.elements.prev_wallpaper = ibCreateButton( 8, 172, 10, 16, self.elements.wall_menu,
                "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.SetWallaperItem( current_wallaper_id - 1 > 0 and current_wallaper_id - 1 or #CONST_WALLPAPER, false)
            end )

            self.elements.next_wallpaper = ibCreateButton( 186, 172, 10, 16, self.elements.wall_menu,
                "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibData( "rotation", 180 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.SetWallaperItem( current_wallaper_id + 1 > #CONST_WALLPAPER and 1 or current_wallaper_id + 1, true )
            end )

            local wallpaper_rt = ibCreateRenderTarget( 26, 70, 152, 208, self.elements.wall_menu )
            self.elements.wallpaper_img = ibCreateImage( 0, 0, 152, 208, "img/elements/individ/wallpaper/" .. CONST_WALLPAPER[ current_wallaper_id ].img .. ".png", wallpaper_rt )

            self.SetWallaperItem = function( index, direction )
                
                current_wallaper_id = index
                if isElement( self.elements.new_wallaper_img ) then
                    self.elements.new_wallaper_img:destroy()
                end
                
                local start_x = direction and -152 or 152
                self.elements.new_wallaper_img = ibCreateImage( start_x, 0, 152, 208, "img/elements/individ/wallpaper/" .. CONST_WALLPAPER[ index ].img .. ".png", wallpaper_rt ):ibMoveTo( 0, _, 150 )
                
                self.elements.wallpaper_img:ibMoveTo( start_x * -1, _, 150 )
                self.elements.wallpaper_img:ibAlphaTo( 0, 150 )
                
                if isElement( self.elements.new_wallaper_img ) then
                    self.elements.new_wallaper_img:ibTimer( function()
                        if isElement( self.elements.wallpaper_img ) then
                            self.elements.wallpaper_img:destroy()
                        end
                        self.elements.wallpaper_img = self.elements.new_wallaper_img
                    end, 150, 1 )
                end
                
                self.SetWallaperAction()
                
                prev_wallaper_id = current_wallaper_id
            end
            
            self.SetWallaperAction = function()

                local action_id = self.GetActionByWallpaperId()

                if isElement( self.elements.action_wallaper ) then
                    self.elements.action_wallaper:destroy()
                    self.elements.action_desc:destroy()
                end
                if isElement( self.elements.action_price ) then
                    self.elements.action_price:destroy()
                end

                local item = CONST_WALLPAPER[ current_wallaper_id ]
                if action_id == 1 then
                    if item.price then
                        self.elements.action_wallaper = ibCreateButton( 52, 317, 100, 30, self.elements.wall_menu,
                            "img/elements/individ/btn_buy.png", "img/elements/individ/btn_buy_hover.png", "img/elements/individ/btn_buy_hover.png",
                            0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            triggerServerEvent( "onServerBuyWallpaperPhone", localPlayer, item.price, item.currency, item.img )
                        end )
                        self.elements.action_desc = ibCreateLabel( 31, 288, conf.sx, 0, "Стоимость: " .. item.price, self.elements.wall_menu )
                        :ibBatchData( { font = ibFonts.regular_10, color = 0xFFFFFFFF } )
                        
                        self.elements.action_price = ibCreateImage( 0, 288, 16, 16,  "img/elements/" .. item.currency .. ".png", self.elements.wall_menu )
                        :ibData( "px", self.elements.action_desc:ibGetAfterX( 5 ))
                    end

                elseif action_id == 2 then
                    self.elements.action_wallaper = ibCreateButton( 52, 317, 100, 30, self.elements.wall_menu,
                        "img/elements/individ/btn_install.png", "img/elements/individ/btn_install_hover.png", "img/elements/individ/btn_install_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        self:UpdateTheme( item.img, item.fontColor or 0xFFFFFFFF )
                        UI_elements.background_image:ibData( "texture", "img/backgrounds/" .. PHONE_BACKGROUND .. ".png" )
                        triggerServerEvent( "onServerSetWallpaperPhone", localPlayer, PHONE_BACKGROUND )
                        self.SetWallaperAction()
                    end )
                    self.elements.action_desc = ibCreateLabel( 0, 288, conf.sx, 0, "Куплено", self.elements.wall_menu )
                    :ibBatchData( { font = ibFonts.regular_10, align_x = "center", color = 0xFFFFFFFF } )
                elseif action_id == 3 then
                    self.elements.action_wallaper = ibCreateButton( 52, 317, 100, 30, self.elements.wall_menu,
                        "img/elements/individ/btn_cancel.png", "img/elements/individ/btn_cancel_hover.png", "img/elements/individ/btn_cancel_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        self:UpdateTheme( "bg_1", 0xFFFFFFFF )
                        UI_elements.background_image:ibData( "texture", "img/backgrounds/" .. PHONE_BACKGROUND .. ".png" )
                        triggerServerEvent( "onServerSetWallpaperPhone", localPlayer, PHONE_BACKGROUND )
                        self.SetWallaperAction()
                    end )
                    self.elements.action_desc = ibCreateLabel( 0, 288, conf.sx, 0, "Установлено", self.elements.wall_menu )
                    :ibBatchData( { font = ibFonts.regular_10, align_x = "center", color = 0xFFFFFFFF } )
                end
            end
            
            self.UpdateTheme = function( self, wallpaper_id, new_color )
                PHONE_BACKGROUND = wallpaper_id
                for k, v in pairs( self.elements ) do
                    if isElement( v ) then
                        local type = v:ibData( "type" )
                        type = ( type == "ibLabel" or type == "ibImage" or type == "ibButton" ) and true or false 
                        if type and v ~= self.elements.wallpaper_img then
                            v:ibData( "color", 0xFFFFFFFF )
                        end
                    end
                end
            end

            self.GetActionByWallpaperId = function()
                local wallpaper_id = CONST_WALLPAPER[ current_wallaper_id ].img
                if wallpaper_id == PHONE_BACKGROUND then
                    return 3
                elseif PHONE_AVAILABLE_BACKGROUNDS[ wallpaper_id ] then
                    return 2
                else
                    return 1
                end
            end

            self.SetWallaperItem( current_wallaper_id )

            self.elements.wall_menu:ibMoveTo( 0, _, 150 )
        end

        self.HideWallPaperMenu = function()
            self.elements.wall_menu:ibMoveTo( -204, _, 150 )
            self.elements.wall_menu:ibTimer( function()
                self.elements.wall_menu:destroy()
            end, 150, 1 )
        end

        ----------------------------------------------
        -- Меню рингтонов
        ----------------------------------------------

        self.ShowRingtonesMenu = function()

            self.elements.ringtones_menu = ibCreateArea( -204, 0, conf.sx, conf.sy, self.elements.rt )
            self.elements.ringtone_rt = ibCreateRenderTarget( 0, 90, 204, 195, self.elements.ringtones_menu )            

            self.current_rington_target_id = 1
            local current_rington_id = 1
            local current_preview_sound_id = nil
            local preview_sound = nil

            ibCreateLabel( 64, 24, 0, 0, "Рингтоны", self.elements.ringtones_menu ):ibBatchData( { font = ibFonts.bold_12, color = 0xFFFFFFFF })
            ibCreateImage( 0, 54, 204, 1, _, self.elements.ringtones_menu, 0xFFFFFFFF )
            ibCreateButton( 14, 27, 18, 14, self.elements.ringtones_menu,
                "img/elements/arrow_back.png", "img/elements/arrow_back.png", "img/elements/arrow_back.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.HideRingtonesMenu()
                self.ShowContentMenu()
            end )

            self.elements.ringtone_target =  ibCreateLabel( 0, 65, conf.sx, 0, "Сообщения", self.elements.ringtones_menu ):ibBatchData( { font = ibFonts.regular_11, align_x = "center", color = 0xFFFFFFFF } )

            ibCreateButton( 26, 70, 6, 10, self.elements.ringtones_menu,
                "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.ChangeTargetRingtones( self.current_rington_target_id - 1 > 0 and self.current_rington_target_id - 1 or #CONST_RINGTONES, false)
            end )

            ibCreateButton( 173, 70, 6, 10, self.elements.ringtones_menu,
                "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png", "img/elements/arrow_left_bold.png",
                0xFFFFFFFF - 0x55000000, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibData( "rotation", 180 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                self.ChangeTargetRingtones( self.current_rington_target_id + 1 > #CONST_RINGTONES and 1 or self.current_rington_target_id + 1, true )
            end )

            self.ChangeTargetRingtones = function( rington_target_id, direction, refresh, buy_sound )

                self.StopPlaySoundItem()
                current_rington_id = 1
                self.current_rington_target_id = rington_target_id
                self.elements.ringtone_target:ibData( "text", CONST_RINGTONES[ self.current_rington_target_id ].name )
                
                local start_x = 0
                if not refresh then
                    start_x = direction and 204 or -204
                end
                local scrollpane, scrollbar = ibCreateScrollpane( start_x * -1, 0, 204, 195, self.elements.ringtone_rt )

                local py = 0
                for k, v in pairs( CONST_RINGTONES[ self.current_rington_target_id ].values ) do
                    self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ] = ibCreateImage( 0, py, 204, 25, _, scrollpane, 0x0026303B )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        current_rington_id = k
                        self.SetRingtoneAction()
                        self.SetSelectionItem( k )
                        ibClick()
                    end )
                    local item_name = ibCreateLabel( 20, 0, 204, 25, k .. ". " .. v.name, self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ] )
                    :ibBatchData( { font = ibFonts.regular_11, align_y = "center", disabled = true, color = 0xFFFFFFFF } )
                    self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "_play" ] = ibCreateImage( item_name:ibGetAfterX( 10 ), 9, 8, 8, "img/elements/individ/play.png", self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ], 0xFFFFFFFF  )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        self.PlaySoundItem( k )
                    end )

                    if PHONE_CURRENT_SOUNDS[ CONST_RINGTONES[ self.current_rington_target_id ].id ] == v.sound then
                        ibCreateImage( 179, 8, 11, 8, "img/elements/individ/green_check.png", self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ] )
                        if not buy_sound then
                            current_rington_id = k
                        end
                    elseif buy_sound and v.sound == buy_sound then
                        current_rington_id = k
                    end

                    py = py + 25
                end
                self.elements[ current_rington_id .. CONST_RINGTONES[ self.current_rington_target_id ].id ]:ibData( "color", 0xAA26303B )

                scrollpane:AdaptHeightToContents()
		        scrollbar:UpdateScrollbarVisibility( scrollpane )
                
                if not refresh then
                    scrollpane:ibMoveTo( 0, _, 150 )
                    if isElement( self.elements.scrollpane ) then
                        self.elements.scrollpane:ibMoveTo( start_x, _, 150 )
                        self.elements.scrollpane:ibTimer( function( element )
                            if isElement( element ) then
                                element:destroy()
                            end
                        end, 150, 1, self.elements.scrollpane )
                    end
                else
                    self.elements.scrollpane:destroy()
                end
                self.elements.scrollpane, self.elements.scrollbar = scrollpane, scrollbar
                
                self.SetRingtoneAction()
            end

            self.SetSelectionItem = function( current_id )
                for k, v in pairs( CONST_RINGTONES[ self.current_rington_target_id ].values ) do
                    if k == current_id then
                        self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ]:ibData( "color", 0xAA26303B )
                    else
                        self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id ]:ibData( "color", 0x0026303B )
                    end
                end
            end

            self.elements.StopTimerSound = nil
            self.PlaySoundItem = function( current_id )
                self.StopPlaySoundItem()
                if current_preview_sound_id == current_id then
                    self.elements[ current_id .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "_play" ]:ibData( "texture", "img/elements/individ/play.png" )
                    current_preview_sound_id = nil
                else
                    preview_sound = playSound( "sound/" .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "/" .. CONST_RINGTONES[ self.current_rington_target_id ].values[ current_id ].sound  .. ".wav"  )
                    local soundLength = getSoundLength( preview_sound )
                    self.elements.StopTimerSound = setTimer( function()
                        self.elements[ current_id .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "_play" ]:ibData( "texture", "img/elements/individ/play.png" )
                        current_preview_sound_id = nil
                    end, soundLength * 1000 - 200, 1 )

                    for k, v in pairs( CONST_RINGTONES[ self.current_rington_target_id ].values ) do
                        if k == current_id then
                            self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "_play" ]:ibData( "texture", "img/elements/individ/stop.png" )
                        else
                            self.elements[ k .. CONST_RINGTONES[ self.current_rington_target_id ].id .. "_play" ]:ibData( "texture", "img/elements/individ/play.png" )
                        end
                    end
                    current_preview_sound_id = current_id
                end                    
            end

            self.StopPlaySoundItem = function()
                if isElement( preview_sound ) then
                    stopSound( preview_sound )
                    if isTimer( self.elements.StopTimerSound ) then
                        killTimer( self.elements.StopTimerSound )
                    end
                end
            end

            self.SetRingtoneAction = function()

                local action_id = self.GetActionByRingtoneId()

                if isElement( self.elements.action_ringtone ) then
                    self.elements.action_ringtone:destroy()
                    self.elements.action_desc:destroy()
                end

                if isElement( self.elements.action_ringtoneprice ) then
                    self.elements.action_ringtoneprice:destroy()
                end
                
                if action_id == 1 then
                    
                    self.elements.action_ringtone = ibCreateButton( 52, 317, 100, 30, self.elements.ringtones_menu,
                        "img/elements/individ/btn_buy.png", "img/elements/individ/btn_buy_hover.png", "img/elements/individ/btn_buy_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        local item = CONST_RINGTONES[ self.current_rington_target_id ]
                        triggerServerEvent( "onServerBuySoundPhone", localPlayer, item.values[ current_rington_id ].price, item.values[ current_rington_id ].currency, item.id, item.values[ current_rington_id ].sound )
                    end )
                    
                    self.elements.action_desc = ibCreateLabel( 31, 288, conf.sx, 0, "Стоимость: " .. CONST_RINGTONES[ self.current_rington_target_id ].values[ current_rington_id ].price, self.elements.ringtones_menu )
                    :ibBatchData( { font = ibFonts.regular_10, color = 0xFFFFFFFF } )
                   
                    self.elements.action_ringtoneprice = ibCreateImage( 0, 288, 16, 16, "img/elements/" .. CONST_RINGTONES[ self.current_rington_target_id ].values[ current_rington_id ].currency .. ".png", self.elements.ringtones_menu )
                    :ibData( "px", self.elements.action_desc:ibGetAfterX( 5 ))

                elseif action_id == 2 then
                    
                    self.elements.action_ringtone = ibCreateButton( 52, 317, 100, 30, self.elements.ringtones_menu,
                        "img/elements/individ/btn_install.png", "img/elements/individ/btn_install_hover.png", "img/elements/individ/btn_install_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        triggerServerEvent( "onServerSetSoundPhone", localPlayer, CONST_RINGTONES[ self.current_rington_target_id ].id, CONST_RINGTONES[ self.current_rington_target_id ].values[ current_rington_id ].sound )
                    end )

                    self.elements.action_desc = ibCreateLabel( 0, 288, conf.sx, 0, "Куплено", self.elements.ringtones_menu ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", color = 0xFFFFFFFF } )

                elseif action_id == 3 then
                    
                    self.elements.action_ringtone = ibCreateButton( 52, 317, 100, 30, self.elements.ringtones_menu,
                        "img/elements/individ/btn_cancel.png", "img/elements/individ/btn_cancel_hover.png", "img/elements/individ/btn_cancel_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        if PHONE_CURRENT_SOUNDS[ CONST_RINGTONES[ self.current_rington_target_id ].id ] ~= PHONE_DEFAULT_SOUNDS[ CONST_RINGTONES[ self.current_rington_target_id ].id ] then
                            triggerServerEvent( "onServerSetSoundPhone", localPlayer, CONST_RINGTONES[ self.current_rington_target_id ].id, PHONE_DEFAULT_SOUNDS[ CONST_RINGTONES[ self.current_rington_target_id ].id ] )
                        else
                            localPlayer:ShowError( "Нельзя сбросить звук по умолчанию!")
                        end
                    end )

                    self.elements.action_desc = ibCreateLabel( 0, 288, conf.sx, 0, "Установлено", self.elements.ringtones_menu ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", color = 0xFFFFFFFF } )
                end
            end
            
            self.GetActionByRingtoneId = function()
                local sound = CONST_RINGTONES[ self.current_rington_target_id ].values[ current_rington_id ]
                if sound.sound == PHONE_CURRENT_SOUNDS[ CONST_RINGTONES[ self.current_rington_target_id ].id ] then
                    return 3
                elseif PHONE_AVAILABLE_SOUNDS[ sound.sound ] then
                    return 2
                else
                    return 1
                end
            end

            self.ChangeTargetRingtones( 1 )

            self.elements.ringtones_menu:ibMoveTo( 0, _, 150 )
        end

        self.HideRingtonesMenu = function()
            self.elements.ringtones_menu:ibMoveTo( -204, _, 150 )
            self.elements.ringtones_menu:ibTimer( function()
                self.elements.ringtones_menu:destroy()
            end, 150, 1 )
        end

        ----------------------------------------------
        -- Меню выбора саб-менюшек
        ----------------------------------------------

        self.HideContentMenu = function()
            for k, v in pairs( self.hide_elements ) do
                v:ibMoveTo( 204, _, 150 )
            end
        end

        self.ShowContentMenu = function()
            for k, v in pairs( self.hide_elements ) do
                v:ibMoveTo( 0, _, 150 )
            end
        end

        PHONEINDIVIDAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        PHONEINDIVIDAPP = nil
    end,
}

function onClientUpdateIndividualizationPhone_handler( data )
    if data.current_wallpaper then
        PHONE_BACKGROUND = data.current_wallpaper or PHONE_BACKGROUND
        if isElement( UI_elements.background_image ) then
            UI_elements.background_image:ibData( "texture", "img/backgrounds/" .. PHONE_BACKGROUND .. ".png" )
        end
    end
    if data.phone_wallpaper then
        PHONE_AVAILABLE_BACKGROUNDS = fromJSON( data.phone_wallpaper ) or PHONE_AVAILABLE_BACKGROUNDS
    end
    if data.current_sounds then
        PHONE_CURRENT_SOUNDS = fromJSON( data.current_sounds ) or PHONE_CURRENT_SOUNDS
    end
    if data.phone_sounds then
        PHONE_AVAILABLE_SOUNDS = fromJSON( data.phone_sounds ) or PHONE_AVAILABLE_SOUNDS
    end
    
    if PHONEINDIVIDAPP then
        if isElement( PHONEINDIVIDAPP.elements.wall_menu ) then
            PHONEINDIVIDAPP.SetWallaperAction()
        elseif isElement( PHONEINDIVIDAPP.elements.ringtones_menu ) then
            PHONEINDIVIDAPP.SetRingtoneAction()
            PHONEINDIVIDAPP.ChangeTargetRingtones( PHONEINDIVIDAPP.current_rington_target_id, false, true, data.buy_sound or false )
        end
    end
end
addEvent( "onClientUpdateIndividualizationPhone", true )
addEventHandler( "onClientUpdateIndividualizationPhone", root, onClientUpdateIndividualizationPhone_handler )

function GetPhoneWallpaper()
    return PHONE_BACKGROUND
end