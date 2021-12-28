local _SCREEN_X,      _SCREEN_Y      = guiGetScreenSize( )
local _SCREEN_X_HALF, _SCREEN_Y_HALF = _SCREEN_X / 2, _SCREEN_Y / 2

GAME_STEP = nil
CURRENT_GAME = nil
CURRENT_UI_ELEMENT = nil

CURRENT_UI_DESK = nil

function createMiniGame( data )
    GAME_STEP = 0
    CURRENT_GAME = data
    createNextGameStep()    
end

function createNextGameStep()
    GAME_STEP = GAME_STEP + 1
    if CURRENT_UI_DESK then CURRENT_UI_DESK:destroy() end
    if CURRENT_UI_ELEMENT then CURRENT_UI_ELEMENT:destroy() end

    if CURRENT_GAME and CURRENT_GAME[ GAME_STEP ] then
        CURRENT_UI_ELEMENT = CURRENT_GAME[ GAME_STEP ].action()
    else
        GAME_STEP = 0
        CURRENT_GAME = nil
        CURRENT_UI_ELEMENT = nil
        CURRENT_UI_DESK = nil
    end
end

--Нажатие кнопки
function ibCreateKeyPress( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }
    
    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )

    self.elements.img = ibCreateImage( self.px and (self.px - self.sx/2) or  (_SCREEN_X_HALF - self.sx / 2), self.py and (self.py - self.sy/2) or (_SCREEN_Y_HALF - self.sy / 2), self.sx, self.sy, self.texture, self.parent or false )

    if self.text then
        self.elements.text = ibCreateLabel( 90, 31, 0, 0, self.text, self.elements.img ):ibBatchData( { font = ibFonts.regular_22 } )
    end

    self.key = self.key or "mouse1"
    self.key_handler = function( key, pressOrRelease )
        if key == self.key and pressOrRelease and self.check() then
            if self.callback then self.callback() end
            if self.sound_path then
                self.sound = Sound(self.sound_path)
                self.sound:setVolume( 0.2 )
            end
            self.destroy()
        end
    end
    addEventHandler( "onClientKey", root, self.key_handler )

    ibUseRealFonts( fonts_real )

    self.destroy = function()
        removeEventHandler( "onClientKey", root, self.key_handler )
        if isElement( self.elements.img ) then
            self.elements.img:destroy()
        end
    end

    return self
end

--Мини-игра на верстаке
function ibCreateSamwillDeskGame( conf, source_sawmill, sawmill_desk )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )
    ibInterfaceSound()
    
    local self = conf or { }
    self.elements = { }
    
    --Игрок двигает бревно?
    self.is_mouse_press = false

    self.start_x = nil
    self.prev_x = -580
    self.max_x = -490
    --Бревно уже находится в обработке?
    self.is_moved = false
    self.move_time = 9000
    self.count_rotate = 0

    --Возьмите бревно
    self.texture_take_log_help = dxCreateTexture( "img/hint5.png" )
    self.texture_take_log_help_sx, self.texture_take_log_help_sy = dxGetMaterialSize( self.texture_take_log_help )
    self.elements.take_log_help = ibCreateImage( 
        152, 
        399, 
        self.texture_take_log_help_sx, 
        self.texture_take_log_help_sy, 
        self.texture_take_log_help,
        sawmill_desk
    ):ibBatchData( { alpha = 255, disabled = true } )

    --Поместите бревно в рубанок
    self.texture_move_log_help = dxCreateTexture( "img/hint6.png" )
    self.texture_move_log_help_sx, self.texture_move_log_help_sy = dxGetMaterialSize( self.texture_move_log_help )
    self.elements.move_log_help = ibCreateImage(
        218,
        165,
        self.texture_move_log_help_sx, 
        self.texture_move_log_help_sy,
        self.texture_move_log_help,
        sawmill_desk
    ):ibBatchData( { alpha = 0, disabled = true } )
    
    --Иконка руки
    self.texture_arm = dxCreateTexture( "img/arm.png" )
    self.texture_arm_sx, self.texture_arm_sy = dxGetMaterialSize( self.texture_arm )
    source_sawmill.elements.arm = ibCreateImage( 
        _SCREEN_X_HALF - self.texture_arm_sx / 2, 
        _SCREEN_Y_HALF - self.texture_arm_sy / 2,
        self.texture_arm_sx, 
        self.texture_arm_sy,
        self.texture_arm 
    )
    :ibOnRender( function()
        if self.is_moved then return end
        
        local cx, cy = getCursorPosition()
        if not cx then return end

        local x, y = cx * _SCREEN_X, cy * _SCREEN_Y
        source_sawmill.elements.arm:ibBatchData( { px = x - self.texture_arm_sx / 2, py = y - self.texture_arm_sy / 2 } )
        
        --Перемещаем бревно, если курсор зажат и позиция новая
        if not self.start_x then return end
        local offset = x - self.start_x
        if self.is_mouse_press and offset  > 0 then
            self.start_x = x
            self.prev_x = self.prev_x + offset
            self.elements.log:ibData( "px", self.prev_x )
            self.elements.log_bark_free:ibData( "px", self.prev_x )
        end

        if self.prev_x > self.max_x then
            self.start_move_log()
            return
        end
    end )
    :ibBatchData( { alpha = 0, disabled = true } )
    
    --Бревно без коры, после обработки
    self.log_bark_free_px, self.log_bark_free_py = -580, 266
    self.texture_log_bark_free = dxCreateTexture( "img/log_barkfree.png" )
    self.texture_log_bark_free_sx, self.texture_log_bark_free_sy = dxGetMaterialSize( self.texture_log_bark_free )
    self.elements.log_bark_free = ibCreateImage(
        self.log_bark_free_px, 
        self.log_bark_free_py,
        self.texture_log_bark_free_sx, 
        self.texture_log_bark_free_sy,
        self.texture_log_bark_free,
        sawmill_desk
    ):ibBatchData( { disabled = true } )

    --Бревно, до обработки
    self.log_px, self.log_py = -580, 266
    self.texture_log = dxCreateTexture( "img/log.png" )
    self.texture_log_sx, self.texture_log_sy = dxGetMaterialSize( self.texture_log )

    self.elements.log_rt = ibCreateRenderTarget( 0, 266, self.texture_log_sx - 458, self.texture_log_sy, sawmill_desk )

    self.elements.log = ibCreateImage(
        self.log_px, 
        0,
        self.texture_log_sx, 
        self.texture_log_sy,
        self.texture_log,
        self.elements.log_rt
    )
    :ibOnClick( function( key, state )
        if key ~= "left" or self.is_moved then return end

        if state == "up" then 
            self.elements.take_log_help:ibAlphaTo( 255, 150 )
            self.elements.move_log_help:ibAlphaTo( 0, 150 )

            source_sawmill.elements.arm:ibData( "texture", "img/arm.png" )
            self.is_mouse_press = false
            self.start_x = nil
        else
            self.elements.take_log_help:ibAlphaTo( 0, 150 )
            self.elements.move_log_help:ibAlphaTo( 255, 150 )

            source_sawmill.elements.arm:ibData( "texture", "img/arm_hovered.png" )
            self.is_mouse_press = true
            local cx, _ = getCursorPosition()
            local x = cx * _SCREEN_X
            self.start_x = x
        end
    end, false )
    :ibOnHover( function( ) 
        if self.is_moved then return end

        source_sawmill.elements.arm:ibAlphaTo( 255, 150 )
        setCursorAlpha( 0 )
    end )
    :ibOnLeave( function( )
        if self.is_moved then return end

        source_sawmill.elements.arm:ibAlphaTo( 0, 150 )
        setCursorAlpha( 255 )
    end )

    --Бревно "выползающее" слева
    self.log_dummy_px, self.log_dummy_py = -950, 266
    self.elements.log_dummy = ibCreateImage(
        self.log_dummy_px, 
        self.log_dummy_py,
        self.texture_log_sx, 
        self.texture_log_sy,
        self.texture_log,
        sawmill_desk
    ):ibBatchData( { alpha = 255, disabled = true } )

    self.start_move_log = function()
        self.is_moved = true
        source_sawmill.elements.arm:ibAlphaTo( 0, 150 )
        self.elements.move_log_help:ibAlphaTo( 0, 150 )
        
        self.elements.log_bark_free:ibData( "px", self.prev_x )

        self.sound = playSound( "sfx/sawmill_s.mp3" )
        self.sound:setVolume( 0.4 )
        self.elements.log:ibMoveTo( self.prev_x + 1340, self.elements.log:ibData( "py" ), self.move_time, "Linear" )
        self.elements.log_bark_free:ibMoveTo( self.prev_x + 1340, self.elements.log_bark_free:ibData( "py" ), self.move_time, "Linear" )

        --Таймер на окончание обработки бревна
        self.elements.log:ibTimer( function( source )
            self.count_rotate = self.count_rotate + 1
            if self.count_rotate == 4 then
                self.count_log = self.count_log - 1
                if self.count_log > 0 then
                    self.help_ui = ibCreateKeyPress({
                        px = sawmill_desk:ibData("sx") / 2,
                        py = sawmill_desk:ibData("sy") / 2,
                        key = "mouse2",
                        texture = "img/hint9.png",
                        callback = function()
                            self.count_rotate = 0
                            self.start_x = nil
                            self.prev_x = -580
                            self.elements.log:ibData( "px", -580 )
                            self.elements.take_log_help:ibAlphaTo( 255, 150 )  
                            self.is_moved = false
                        end,
                        check = function() return true end,
                        sound_path = "sfx/rotate_wood_s.mp3",
                        parent = sawmill_desk
                    })
                    return
                end
                self.callback()
                createNextGameStep()
            else
                self.help_ui = ibCreateKeyPress({
                    px = sawmill_desk:ibData("sx") / 2,
                    py = sawmill_desk:ibData("sy") / 2,
                    texture = "img/hint4.png",
                    text = "Обработана " .. self.count_rotate .. " сторона из 4",
                    key = "mouse2",
                    callback = function()
                        self.start_x = nil
                        self.prev_x = -580
                        if self.count_rotate > 2 then
                            self.elements.log:ibData( "px", -580 )
                        end
                        self.elements.take_log_help:ibAlphaTo( 255, 150 )  
                        self.is_moved = false
                    end,
                    check = function() return true end,
                    sound_path = "sfx/rotate_wood_s.mp3",
                    parent = sawmill_desk
                })
            end
            
        end, self.move_time + 50, 1 )

        --Таймер на выдвижение бревна
        self.elements.log_dummy:ibTimer( function( source )
            if self.count_rotate > 1 then
                self.elements.log_dummy:ibData( "texture", "img/log_barkfree.png" )
            end
            self.elements.log_dummy:ibMoveTo( self.elements.log_dummy:ibData("px") + 370, self.elements.log_dummy:ibData("py"), 3000, "Linear" )
        end, self.move_time / 1.5, 1 )
        
        --Таймер срабатывает после выдвижения бревна
        self.elements.log_bark_free:ibTimer( function( source )
            if self.count_rotate <= 2 then
                self.elements.log:ibData( "px", -580 )
            end
            self.elements.log_bark_free:ibData( "px", -580 )
            self.elements.log_dummy:ibData( "px", -950 )
        end, self.move_time / 1.5 + 3050, 1 )

        self.start_x = nil
        self.prev_x = -580
        setCursorAlpha( 255 )
    end

    self.destroy = function()
        if isElement( self.elements.log ) then
            self.elements.take_log_help:destroy()
            self.elements.move_log_help:destroy()
            self.elements.log:destroy()
            self.elements.log_dummy:destroy()
            self.elements.log_bark_free:destroy()
            
            setCursorAlpha( 255 )
        end
        if isElement( self.help_ui ) then
            self.help_ui:destroy()
        end
        if isElement( self.sound ) then
            self.sound:stop()
            self.sound = nil
        end
    end

    return self
end

--Верстак для игры, держится в глобальной переменной
function ibCreateSawmillDesk()
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }
    self.texture = "img/desk.png"
    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )

    self.elements.rt = ibCreateRenderTarget( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy )

    self.elements.bg = ibCreateImage( 0, 0, self.sx, self.sy, self.texture, self.elements.rt )

    self.elements.button_close = ibCreateButton( self.sx - 52, 25, 24, 24, self.elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

    addEventHandler( "ibOnElementMouseClick", self.elements.button_close, function( button, state )
        if button ~= "left" or state ~= "up" then return end
        ibClick()
        self.destroy()
        createProcessMarker()
        localPlayer:setDimension( 0 )
    end, false )

    self.destroy = function()
        showCursor( false )
        if isElement( self.elements.rt ) then
            self.elements.rt:destroy()
        end
    end

    showCursor( true )

    return self, self.elements.bg
end

--Создание склада древесины
function createStockView( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.elements.black_bg = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )

    self.elements.bg_area = ibCreateArea( _SCREEN_X - 320, _SCREEN_Y_HALF, 300, 408, self.elements.black_bg )

    self.texture = dxCreateTexture( "img/stock.png" )
    self.sx, self.sy = dxGetMaterialSize( self.texture )

    self.elements.bg_stock = ibCreateImage( 0, 75, self.sx, self.sy, self.texture, self.elements.bg_area )

    self.elements.button_close = ibCreateButton( self.sx - 34, 10, 24, 24, self.elements.bg_stock,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

    addEventHandler( "ibOnElementMouseClick", self.elements.button_close, function( button, state )
        if button ~= "left" or state ~= "up" then return end
        ibClick()
        self.destroy()
        self.dest()
    end, false )

    self.RefreshStock = function( self )
        if isElement( self.elements.not_wood_info ) then
            self.elements.not_wood_info:destroy()
        elseif isElement( self.elements.stock_btn_bg ) then
            self.elements.stock_btn_bg:destroy()
        end

        if self.stock_name and STOCKS[ self.stock_name ] > 0 and isElement( self.elements.bg_stock ) then
            self.elements.stock_btn_bg = ibCreateImage( 15, 48, 60, 60, _, self.elements.bg_stock, 0xFF364658 )
            self.elements.count_rect = ibCreateImage( 40, 0, 20, 20, _, self.elements.stock_btn_bg, 0x80000000 )
            self.elements.count_text = ibCreateLabel( 0, 0, 20, 20, "x" .. STOCKS[ self.stock_name ], self.elements.count_rect, 0xFFFFFFFF, 1, 1, "center", "center" )
            :ibData("font", ibFonts.regular_8)
            self.elements.stock_button = ibCreateButton( 0, 0, 60, 60, self.elements.stock_btn_bg, "img/wood.png", "img/wood.png", "img/wood.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnHover( function()
                self.elements.stock_btn_bg:ibData( "color", 0xFF526A86 )
            end )
            :ibOnLeave( function()
                self.elements.stock_btn_bg:ibData( "color", 0xFF364658 )
            end )
            :ibOnClick( function( button, state )
                if button == "left" or state == "up" then return end
                
                if not self.check() then return end
                if self.callback then self.callback() end
                self.destroy()
            end )
            
            self.texture = dxCreateTexture( "img/hint7.png" )
            self.sx, self.sy = dxGetMaterialSize( self.texture )
    
            self.elements.help_icon = ibCreateImage( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy, self.texture, self.elements.black_bg )
        elseif isElement( self.elements.bg_area ) then
            self.texture = dxCreateTexture( "img/wait.png" )
            self.sx, self.sy = dxGetMaterialSize( self.texture )
            self.elements.not_wood_info = ibCreateImage( 0, 0, self.sx, self.sy, self.texture, self.elements.bg_area )
        end
    end
    self:RefreshStock()

    self.destroy = function()
        if isElement( self.elements.black_bg ) then
            self.elements.black_bg:destroy()
        end
        showCursor( false )
    end
    
    ibUseRealFonts( fonts_real )
    
    showCursor( true )
    return self
end