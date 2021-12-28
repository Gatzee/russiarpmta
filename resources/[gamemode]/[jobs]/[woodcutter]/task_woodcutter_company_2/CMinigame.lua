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
            
            self.texture = dxCreateTexture( "img/hint5.png" )
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