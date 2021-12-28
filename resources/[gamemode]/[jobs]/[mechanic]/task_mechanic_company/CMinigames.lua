local _SCREEN_X,      _SCREEN_Y      = guiGetScreenSize( )
local _SCREEN_X_HALF, _SCREEN_Y_HALF = _SCREEN_X / 2, _SCREEN_Y / 2

GAME_STEP = nil
CURRENT_GAME = nil
CURRENT_UI_ELEMENT = nil

function createMiniGame( data )
    GAME_STEP = 0
    CURRENT_GAME = data
    createNextGameStep()    
end

function createNextGameStep()
    GAME_STEP = GAME_STEP + 1
    if CURRENT_GAME[ GAME_STEP ] then
        CURRENT_UI_ELEMENT = CURRENT_GAME[ GAME_STEP ].action()
    else
        GAME_STEP = nil
        CURRENT_GAME = nil
        CURRENT_UI_ELEMENT = nil
        createNextReplaceDetail()
    end
end

    --Нажатие кнопки мышки
function ibCreateMouseKeyPress( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }
    
    self.elements.img = ibCreateImage( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy, self.texture )

    self.key = self.key or "mouse1"
    self.key_handler = function(key, pressOrRelease)
        if key == self.key and pressOrRelease and self.check() then
            cancelEvent( )
            removeEventHandler("onClientKey",root, self.key_handler)
            self.elements.img:destroy()
            if self.callback then
                self.callback()
            end
        end
    end
    addEventHandler( "onClientKey", root, self.key_handler )

    ibUseRealFonts( fonts_real )

    self.destroy = function()
        removeEventHandler("onClientKey",root, self.key_handler)
        if isElement(  self.elements.img ) then
            self.elements.img:destroy()
        end
    end

    return self
end

    --Удержание мышки N секунд
function ibCreateMouseKeyHold( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.px, self.py = self.px or _SCREEN_X_HALF - (self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - (self.sy / 2 or 0)
    self.color = self.color or 0x80547FAF
    self.back_color = self.back_color or  0xD9212B36
    self.key = self.key or "mouse2"
    
    self.elements.area_bg = ibCreateArea(self.px, self.py, self.sx, self.sy )
    self.elements.progress_bar_back  = ibCreateImage( self.rect_x, self.rect_y, self.rect_size, self.sy, _, self.elements.area_bg, self.back_color)
    self.elements.progress_bar  = ibCreateImage( self.rect_x, self.rect_y, 0, self.sy, _, self.elements.area_bg, self.color)
    self.elements.img = ibCreateImage(0, 0, self.sx, self.sy, self.texture, self.elements.area_bg)
    
    self.start_time = nil
    self.sound = nil
    self.key_handler = function( key, pressOrRelease )
        if key ~= self.key then return end
        if not pressOrRelease then
            if self.start_time then
                local time = getTickCount() - self.start_time
                if self.sound_path and isElement( self.sound ) and time < self.hold_time then
                    stopSound( self.sound )
                end
            end
            self.elements.progress_bar:ibData( "sx", 0 )
            self.start_time = nil
            return
        else
            if self.sound_path then
                if isElement( self.sound ) then
                    stopSound( self.sound )
                end
                self.sound = playSound( self.sound_path )
                setSoundVolume( self.sound , 0.5 )
            end
        end
        self.start_time = getTickCount() 
    end
    addEventHandler( "onClientKey", root, self.key_handler )

    self.elements.img:ibOnRender(function()
        if self.start_time then
            if not self.start_time then return end
            local time = getTickCount() - self.start_time
            if time < self.hold_time then
                self.elements.progress_bar:ibData( "sx", time / self.hold_time * self.rect_size )
            elseif self.count_hold > 1 then
                self.start_time = nil
                self.count_hold = self.count_hold - 1
                self.elements.progress_bar:ibData( "sx", 0 )
            else
                removeEventHandler( "onClientKey", root, self.key_handler )
                if self.callback then self.callback() end
                self.elements.area_bg:destroy()
            end
        end
    end)
    
    self.destroy = function()
        removeEventHandler("onClientKey", root, self.key_handler)
        if isElement( self.elements.area_bg) then 
            self.elements.area_bg:destroy()
        end
    end

    ibUseRealFonts( fonts_real )

    return self
end

    --Нажтие мышки N раз
function ibCreateMouseKeyStroke( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.px, self.py = self.px or _SCREEN_X_HALF - (self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - (self.sy / 2 or 0)
    self.back_color = self.back_color or  0xD9212B36
    self.key = self.key or "mouse1"

    self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )

    self.elements.area_bg = ibCreateArea(self.px, self.py, self.sx, self.sy, self.elements.bckg )
    self.elements.img = ibCreateImage(0, 0, self.sx, self.sy, self.texture, self.elements.area_bg)
    
    self.elements.area_pb   = ibCreateArea(self.px - 28, self.py - 44, 120, 10, self.elements.bckg )
    self.elements.border_pb = ibCreateImage(0, 0, 10, 120, _, self.elements.area_pb, 0xff364754)
    self.elements.back_pb   = ibCreateImage(1, 1, 8, 118, _, self.elements.area_pb, 0xff5a6672)
    self.elements.pb        = ibCreateImage(1, 119, 8, 0, _, self.elements.area_pb, 0xffe3ca41)

    self.count_clicks = 0

    self.start_time = nil
    self.reset_time = 700
    self.elements.img:ibOnRender(function()
        if not self.start_time then return end
        local time = getTickCount() - self.start_time
        if time > self.reset_time then
            if self.count_clicks - 1 >= 0 then
                self.count_clicks = self.count_clicks - 1
                self.elements.pb:ibData( "sy", 11.8 * self.count_clicks * -1 )
            end
            self.start_time = getTickCount()
        end
    end)

    self.key_handler = function(key, pressOrRelease)
        if key ~= self.key then return end
        if pressOrRelease and self.elements.pb and isElement( self.elements.pb ) then
            self.count_clicks = self.count_clicks + 1
            self.elements.pb:ibData( "sy", 11.8 * self.count_clicks * -1 )
            cancelEvent( )
            if self.count_clicks == 10 then
                removeEventHandler("onClientKey", root, self.key_handler)
                if self.callback then self.callback() end
                self.elements.bckg:destroy()
            end
        end
        if not self.start_time then
            self.start_time = getTickCount()
        end
    end
    addEventHandler("onClientKey", root, self.key_handler)

    self.destroy = function()
        removeEventHandler("onClientKey", root, self.key_handler)
        if isElement( self.elements.bckg ) then
            self.elements.bckg:destroy()
        end
    end

    ibUseRealFonts( fonts_real )

    return self
end

    --Удержание мышки в регионе
function ibCreateMouseKeyHoldInRegion( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )

    self.elements.circle_area = ibCreateArea(_SCREEN_X_HALF - 222, 154, 445, 249, self.elements.bckg  )
    self.elements.circle_bg_img = ibCreateImage(0, 0, 445, 249, "img/circle_bg.png", self.elements.circle_area )
    self.elements.circle_region = ibCreateImage(195, 1, 56, 9, "img/region.png", self.elements.circle_bg_img):ibBatchData( { alpha = 150 } )
    self.elements.circle_arrow  = ibCreateImage(189, 15, 66, 276, "img/arrow.png", self.elements.circle_bg_img)
    self.elements.circle_center = ibCreateImage(202, 140, 45, 45, "img/center.png", self.elements.circle_bg_img)
    
    self.elements.action_area = ibCreateArea(_SCREEN_X_HALF - 226, 419, 453, 34, self.elements.bckg )
    self.elements.action_img  = ibCreateImage(0, 0, 453, 34, "img/hint7.png", self.elements.action_area ):ibData("alpha", 0)

    self.elements.pb_area = ibCreateArea(_SCREEN_X_HALF - 292, 363, 51, 57, self.elements.bckg ) 
    self.elements.pb_img_value  = ibCreateImage(0, 0, 51, 0, "img/progress_bar_value.png", self.elements.pb_area )
    self.elements.pb_img  = ibCreateImage(0, 0, 51, 57, "img/progress_bar.png", self.elements.pb_area )

    self.elements.progress_text = ibCreateLabel( _SCREEN_X_HALF - 342, 380, 40, 0, "0%", self.elements.bckg, 0xFFf4f4f5 )
    self.elements.progress_text:ibBatchData( { font = ibFonts.regular_13, align_x = "right", outline = true } )
    
    self.time = 0
    self.time_hold_in_region = 80000
    self.progress = 0
    self.is_first_step = true
    self.elements.circle_bg_img:ibOnRender(function()
        if self.end_operation then return end
        --Установка курсора в область взаимодействия с полукругом
        if self.is_first_step then self.is_first_step = false setCursorPosition(300, 100) end
        
        local cursor_x, _ = getCursorPosition()
        cursor_x = cursor_x * _SCREEN_X
        --Деление полукруга по-полам и сдвиг стрелки влево/вправо
        if cursor_x < 325 then
            cursor_x = cursor_x - math.sin(getTickCount())*12
        else
            cursor_x = cursor_x + math.sin(getTickCount())*12
        end

        --Если стрелка вышла из зоны взаимодейтсивия возвращаем назад
        if cursor_x > 775 then  cursor_x = 770  end
        setCursorPosition(cursor_x, 100)
        
        --Получаем ротацию относительно курсора и основания полукруга, поворачиваем стрелку
        local rotation = -math.deg(math.atan2(-216, cursor_x - 330))
        local rotate = rotation - 90
        self.elements.circle_arrow:ibBatchData( { rotation =  rotation > 90 and rotate * -1 or math.abs(rotate), rotation_offset_y = 10 } )
        
        --Если стрелка находится в заданном интервале, то изменяем прогресс
        if rotation < 100 and rotation > 80 then
            if self.sound_path and not isElement( self.sound ) then
                self.sound = playSound( self.sound_path )
                setSoundVolume( self.sound, 0.5 )
            end
            self.elements.circle_region:ibData( "alpha", 255 )
            
            if self.prev_time then
                self.time = self.time + getTickCount() - self.prev_time
                
                local progress = math.min( math.floor( self.time / self.time_hold_in_region * 100 ), 100 )
                self.elements.progress_text:ibData( "text", progress .. "%" )
                
                self.elements.pb_img_value:ibBatchData( { py = 57 - 0.57 * progress, sx = 51, sy = 0.57 * progress, u = 0, v = 57 - 0.57 * progress, u_size = 51, v_size = 0.57 * progress } )

                if progress >= 100 then
                    self.elements.action_img:ibData("alpha", 255)
                    self.elements.circle_arrow:ibBatchData( { rotation =  0, rotation_offset_y = 10 } )
                    localPlayer:setAnimation()
                    self.end_operation = true
                    addEventHandler("onClientKey", root, self.key_handler)
                end
            else
                if isElement( self.sound ) then
                    stopSound( self.sound )
                end
                self.prev_time = getTickCount()
            end
        else
            --иначе сбрасываем время
            self.elements.circle_region:ibData( "alpha", 155 )
            self.prev_time = nil
        end
    end)

    self.key_handler = function(key, pressOrRelease)
        if key == "mouse2" and pressOrRelease then
            removeEventHandler("onClientKey", root, self.key_handler)
            self.elements.bckg:destroy()
            self.callback()

            setCursorAlpha(255)
            showCursor(false)
        end
    end

    self.destroy = function()
        removeEventHandler("onClientKey", root, self.key_handler)
        if isElement( self.elements.bckg ) then
            self.elements.bckg:destroy()
        end
    end

    showCursor(true)
    setCursorAlpha(0)

    ibUseRealFonts( fonts_real )

    return self
end


