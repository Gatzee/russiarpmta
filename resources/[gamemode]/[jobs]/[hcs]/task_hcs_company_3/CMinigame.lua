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

	self.elements.img = ibCreateImage( 0, 0, self.sx, self.sy, self.texture ):center( )

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
	
	self.px, self.py = self.px or _SCREEN_X_HALF - math.floor(self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - math.floor(self.sy / 2 or 0)
	self.back_color = self.back_color or  0xD9212B36
	self.key = self.key or "mouse1"

	self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )

	self.elements.area_bg = ibCreateArea(self.px, self.py, self.sx, self.sy, self.elements.bckg )
	self.elements.img = ibCreateImage(0, 0, self.sx, self.sy, self.texture, self.elements.area_bg)
	
	self.elements.area_pb   = ibCreateArea(self.px - 28, self.py - 44, 120, 10, self.elements.bckg )
	self.elements.border_pb = ibCreateImage(0, 0, 10, 120, _, self.elements.area_pb, 0xff364754)
	self.elements.back_pb   = ibCreateImage(1, 1, 8, 118, _, self.elements.area_pb, 0xff5a6672)
	self.elements.pb		= ibCreateImage(1, 119, 8, 0, _, self.elements.area_pb, 0xffe3ca41)

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

--Нажтие мышки N раз
function ibCreateMouseKeyStrokeTimeout( conf )
	local fonts_real = ibIsUsingRealFonts( )
	ibUseRealFonts( false )

	local self = conf or { }
	self.elements = { }

	self.texture = dxCreateTexture( self.texture )
	self.sx, self.sy = dxGetMaterialSize( self.texture )

	self.px, self.py = self.px or _SCREEN_X_HALF - math.floor(self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - math.floor(self.sy / 2 or 0)
	self.back_color = self.back_color or  0xD9212B36
	self.key = self.key or "mouse1"

	self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )

	self.elements.area_bg = ibCreateArea(self.px, self.py, self.sx, self.sy, self.elements.bckg )
	self.elements.img = ibCreateImage(0, 0, self.sx, self.sy, self.texture, self.elements.area_bg)
	
	self.elements.area_pb   = ibCreateArea(self.px - 28, self.py - 44, 120, 10, self.elements.bckg )
	self.elements.border_pb = ibCreateImage(0, 0, 10, 120, _, self.elements.area_pb, 0xff364754)
	self.elements.back_pb   = ibCreateImage(1, 1, 8, 118, _, self.elements.area_pb, 0xff5a6672)
	self.elements.pb		= ibCreateImage(1, 119, 8, 0, _, self.elements.area_pb, 0xffe3ca41)

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
	self.px, self.py = self.px or _SCREEN_X_HALF - math.floor(self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - math.floor(self.sy / 2 or 0)

	self.elements.bckg  = ibCreateBackground( 0x00000000, _, true ):ibBatchData( { priority = 0, alpha = 255 } )
	self.elements.img = ibCreateImage( 0, 0, self.sx, self.sy, self.texture, self.elements.bckg ):center( )
	
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

--Удержание мышки N секунд
function ibCreateMouseKeyHold( conf )
	local fonts_real = ibIsUsingRealFonts( )
	ibUseRealFonts( false )

	local self = conf or { }
	self.elements = { }

	self.px, self.py = self.px or _SCREEN_X_HALF - math.floor(self.sx / 2 or 0), self.py or _SCREEN_Y_HALF - math.floor(self.sy / 2 or 0)
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
				if isElement( self.elements.area_bg) then
					self.elements.area_bg:destroy()
				end
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