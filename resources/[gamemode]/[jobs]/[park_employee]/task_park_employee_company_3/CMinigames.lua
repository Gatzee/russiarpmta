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
        CURRENT_UI_ELEMENT = CURRENT_GAME[GAME_STEP].action()
    else
        GAME_STEP = 0
        CURRENT_GAME = nil
        CURRENT_UI_ELEMENT = nil
    end
end

function ibCreateMouseKeyPress( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }
    
    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )
    self.elements.img = ibCreateImage( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy, self.texture )

    self.key = self.key or "mouse1"
    self.key_handler = function(key, pressOrRelease)
        if key == self.key and pressOrRelease then
            if self.check and not self.check() then return end
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
        if isElement( self.elements.img ) then
            self.elements.img:destroy()
        end
    end

    return self
end

--Нажтие мышки N раз
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
            if self.count_clicks == 10 then
                removeEventHandler("onClientKey", root, self.key_handler)
                self.elements.bckg:destroy()
                if self.callback then self.callback() end
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

function ibCreatePressInCircleRegion( conf )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    local self = conf or { }
    self.elements = { }

    self.texture = dxCreateTexture( self.texture )
    self.sx, self.sy = dxGetMaterialSize( self.texture )
    self.px, self.py = self.px or _SCREEN_X_HALF - (self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - (self.sy / 2 or 0)

    self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )
    self.elements.img = ibCreateImage( _SCREEN_X_HALF - self.sx / 2, _SCREEN_Y_HALF - self.sy / 2, self.sx, self.sy, self.texture, self.elements.bckg )
    
    self.last_switch = 1
    self.current_radius = 10
    self.current_color =  0x50FFFFFF
    self.is_active = false

    self.elements.img:ibOnRender( function( )
        dxDrawImage( _SCREEN_X_HALF - 49, _SCREEN_Y_HALF - 204, 98, 98, "img/circle_new.png", 0, 0, 0, 0x88FFFFFF )
        
        local fClickProgress = (getTickCount()-self.last_switch)/3000
		if fClickProgress >= 1 then
			fClickProgress = 1
			self.last_switch = getTickCount()
        end
        
        self.current_radius = interpolateBetween( 15, 0, 0, 98, 0, 0, fClickProgress, "SineCurve")
        if self.current_radius > 66 and self.current_radius < 86 then
            self.current_color =  0x5000FF00
            self.is_active = true
        else
            self.current_color =  0x50FFFFFF
            self.is_active = false
        end

        dxDrawImage( _SCREEN_X_HALF - self.current_radius/2, _SCREEN_Y_HALF - 155 - self.current_radius/2, self.current_radius, self.current_radius, "img/empty_circle.png", 0, 0, 0, self.current_color )
    end )
    
    self.key_handler = function(key, pressOrRelease)
        if key == self.key and pressOrRelease then
            if not self.is_active or self.check and not self.check() then return end
            removeEventHandler("onClientKey",root, self.key_handler)
            self.elements.img:destroy()
            if self.callback then
                self.callback()
            end
        end
    end
    addEventHandler( "onClientKey", root, self.key_handler )

    self.destroy = function()
        removeEventHandler("onClientKey", root, self.key_handler)
        if isElement( self.elements.bckg ) then
            self.elements.bckg:destroy()
        end
    end

    ibUseRealFonts( fonts_real )

    return self
end