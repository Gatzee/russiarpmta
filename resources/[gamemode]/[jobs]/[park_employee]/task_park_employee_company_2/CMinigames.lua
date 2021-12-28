local _SCREEN_X,      _SCREEN_Y      = guiGetScreenSize( )
local _SCREEN_X_HALF, _SCREEN_Y_HALF = _SCREEN_X / 2, _SCREEN_Y / 2

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
            
            if self.callback then self.callback() end
            removeEventHandler( "onClientKey", root, self.key_handler )
            self.elements.img:destroy()
        end
    end
    addEventHandler( "onClientKey", root, self.key_handler )

    ibUseRealFonts( fonts_real )

    self.destroy = function()
        if isElement( self.elements.img ) then
            removeEventHandler("onClientKey",root, self.key_handler)
            self.elements.img:destroy()
        end
    end

    return self
end

function CreateSurfacePaint( conf )
    
    local self = conf or { }
    self.elements = { }

    self.area_size = self.area_size or 15
    self.density = self.density or 20
    self.pixels =  self.area_size * self.density
    self.size_sprite = self.density * 5

    self.sprite = self.sprite or "img/texture1.png"
    self.GRASS_SHADER = dxCreateShader( "fx/grass.fx", 0, 50, true, "world,object" )
    self.GRASS_RT = dxCreateRenderTarget( self.pixels, self.pixels, true )

    if not isElement( self.GRASS_SHADER ) or not isElement( self.GRASS_RT ) then
        triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Системная ошибка инициализации стрижки травы" } )
        return
    end

    dxSetShaderValue( self.GRASS_SHADER, "tex", self.GRASS_RT )
	engineApplyShaderToWorldTexture( self.GRASS_SHADER, "*" )
	local rm = {
		"",
		"*spoiler*",
		"*particle*",
		"*light*",
		"vehicle*",
		"?emap*",
		"?hite*",
		"*92*",
		"*wheel*",
		"*interior*",
		"*handle*",
		"*body*",
		"*decal*",
		"*8bit*",
		"*logos*",
		"*badge*",
		"*plate*",
		"*sign*",
		"*headlight*",
		"*shad*",
		"coronastar",
		"tx*",
		"lod*",
		"cj_w_grad",
		"*cloud*",
		"*smoke*",
		"sphere_cj",
		"particle*",
		"*water*",
		"coral",
		"shpere",
		"*inferno*",
		"*fire*",
		"*cypress*",
		"list",
		"*brtb*",
		"*tree*",
		"*leave*",
		"*spark*",
		"*eff*",
		"*branch",
		"*ash*",
		"*fire*",
		"*rocket*",
		"*hud*",
		"bark2",
		"bchamae",
		"*sfx*",
		"*wires*",
		"*agave*",
		"*plant*",
		"neon",
		"*log*",
		"sjmshopbk", -- fence secondary
		"*sand*",
		"*radar*",
		"*skybox*", -- maps skybox
		-- "*grass*", "*dirt*", "sw_sand"
		"metalox64",
		"metal1_128",
		-- vgncarshade1,vgshseing28
		"nitro",
		"repair",
		"carchange", -- pickups
		"bullethitsmoke",
		-- the smoke from the engine
		"toll_sfw1",
		"toll_sfw3",
		"trespasign1_256",
		"steel64",
		"beachwalkway",
		"ws_greymeta",
		"telepole2128",
		"ah_barpanelm",
		"plasticdrum1_128",
		"planks01",
		"unnamed",
		"aascaff128",
		"*effect*",
		"newfx*",
		"cardebris*",
	}
	for i, v in pairs( rm ) do
		engineRemoveShaderFromWorldTexture( self.GRASS_SHADER, v )
	end

	dxSetShaderValue( self.GRASS_SHADER, "pos", self.center_area.x, self.center_area.y, self.center_area.z )
	dxSetShaderValue( self.GRASS_SHADER, "mt", 0, 0, -1 )
	dxSetShaderValue( self.GRASS_SHADER, "rt", 0, 0, 0 )
	dxSetShaderValue( self.GRASS_SHADER, "scale", self.area_size )

	dxSetRenderTarget( self.GRASS_RT, false )
	dxDrawRectangle( 0, 0, self.pixels, self.pixels, 0x80008000 )
	dxSetRenderTarget( )

    
    self.time = 5000
    self.timeout = getTickCount() + self.time
    
    self.last_percent = 0
    
    self.x1, self.y1 = self.center_area.x - self.area_size / 2, self.center_area.y - self.area_size / 2
    self.x2, self.y2 = self.center_area.x + self.area_size / 2, self.center_area.y + self.area_size / 2

    self.offset_x, self.offset_y, self.offset_z = 0 or self.offset_x, 0 or self.offset_y, 0 or self.offset_z

    self.func_paint = function()
        if not IsEleemntInArea( localPlayer, self.x1, self.y1, self.x2, self.y2 ) or not self.check() then
            return
        end

        dxSetRenderTarget( self.GRASS_RT, false )

        local player_position = getPositionFromMatrixOffset( localPlayer, self.offset_x, self.offset_y, self.offset_z )
        local tx = self.pixels / 2 + ( player_position.x - self.center_area.x ) * self.density
        local ty = self.pixels / 2 + ( player_position.y - self.center_area.y ) * self.density
        dxDrawImage( tx - self.size_sprite / 2, ty - self.size_sprite / 2, self.size_sprite, self.size_sprite, self.sprite , localPlayer.rotation.z, 0, 0, 0xFF009dff )

        dxSetRenderTarget( )

        local ticks = getTickCount()
        if ticks > self.timeout  then
            self.timeout = ticks + self.time

            local pixels = dxGetTexturePixels( self.GRASS_RT )
            local total_pixels, colored_pixels = math.pow( self.pixels, 2 ), 0
            for i = 0, self.pixels - 1 do
                for j = 0, self.pixels - 1 do
                    local r, g, b = dxGetPixelColor( pixels, i, j )
                    if g > 64 and b > 64 then 
                        colored_pixels = colored_pixels + 1 
                    end
                end
            end

            local procent = colored_pixels / total_pixels
            if procent >= 0.85 then
                self.destroy()
                if self.callback then self.callback() end
            else
                local new_percent = math.floor( procent * 100 )
                if self.last_percent  ~= new_percent then 
                    localPlayer:ShowInfo( "Вы полили ".. new_percent .."% от всего участка" )
                    self.last_percent  = new_percent 
                end
            end
        end

    end
    self.paint_timer = setTimer( self.func_paint, 100, 0 )


    self.func_client_restore = function( clean )
        if not clean then return end
        dxSetRenderTarget( self.GRASS_RT, true )
        dxDrawRectangle( 0, 0, self.pixels, self.pixels, 0x80008000 )
        dxSetRenderTarget( )
        localPlayer:ShowInfo( "Эй, ты чего отвлекся? Трава успела вырасти!" )
    end
    addEventHandler( "onClientRestore", root, self.func_client_restore )

    self.destroy = function()
        if not isTimer( self.paint_timer ) then return end
        killTimer( self.paint_timer )
		removeEventHandler( "onClientRestore", root, self.func_client_restore )
        self.GRASS_SHADER:destroy()
        self.GRASS_RT:destroy()
    end

    return self
end

function IsEleemntInArea( element, x1, y1, x2, y2 )
    local element_position = element:getPosition()
    if element_position.x > x1 and element_position.x < x2 and element_position.y > y1 and element_position.y < y2 then
        return true
    end
    return false
end

function getPositionFromMatrixOffset( element, offX, offY, offZ )
	return element:getMatrix():transformPosition( offX, offY, offZ )
end