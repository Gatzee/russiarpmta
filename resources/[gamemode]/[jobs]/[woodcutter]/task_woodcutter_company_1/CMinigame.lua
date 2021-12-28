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
    if CURRENT_UI_ELEMENT then CURRENT_UI_ELEMENT:destroy() end
    
    if CURRENT_GAME and CURRENT_GAME[ GAME_STEP ] then
        CURRENT_UI_ELEMENT = CURRENT_GAME[ GAME_STEP ].action()
    else
        GAME_STEP = 0
        CURRENT_GAME = nil
        CURRENT_UI_ELEMENT = nil
    end
end

    --Нажатие кнопки мышки
function ibCreateMouseKeyPress( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }
    
    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )

    self.elements.img = ibCreateImage( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy, self.texture )

    self.key = self.key or "mouse1"
    self.key_handler = function( key, pressOrRelease )
        if key == self.key and pressOrRelease and self.check() then
            if self.callback then self.callback() end
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

    --Нажтие мышки N раз, без потери прогресса
function ibCreateMouseKeyStroke( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )
    
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
    self.need_clicks = self.need_clicks or 10

    self.key_handler = function( key, pressOrRelease )
        if key ~= self.key then return end
        if self.timeout and self.start_time and getTickCount() - self.start_time < self.timeout then
            return
        end
        if pressOrRelease and self.elements.pb and isElement( self.elements.pb ) and self.check() then
            self.start_time = getTickCount()
            self.count_clicks = self.count_clicks + 1
            self.elements.pb:ibData( "sy", 11.8 * self.count_clicks * -1 )
            if self.count_clicks == self.need_clicks then
                if self.callback then self.callback() end
                self.destroy()
                return
            end
            if self.click_action then self.click_action() end
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