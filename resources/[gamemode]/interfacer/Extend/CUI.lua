local x, y = guiGetScreenSize()

DisableHUD = function(state)
	local states = GetDisabledHUDList() or {}
	states[THIS_RESOURCE_NAME] = state or nil
	if not next(states) then states = nil end
	triggerEvent( "onClientSetChatState", localPlayer, not state )
	triggerEvent( "ShowInventoryHotbar", localPlayer, not state )
	return setElementData( localPlayer, "hud_disabled_by", states, false )
end

GetDisabledHUDList = function()
	return getElementData( localPlayer, "hud_disabled_by" )
end


DisableGameHUD = function(state)
	local states = GetDisabledGameHUDList() or {}
	states[THIS_RESOURCE_NAME] = state or nil
	if not next(states) then states = nil end
	if states ~= nil then
		triggerEvent( "onClientSetChatState", root, false )
		--setPlayerHudComponentVisible("radar", false)
	else
		triggerEvent( "onClientSetChatState", root, true )
		--setPlayerHudComponentVisible("radar", true)
	end
	return setElementData( localPlayer, "game_hud_disabled_by", states, false )
end

GetDisabledGameHUDList = function()
	return getElementData( localPlayer, "game_hud_disabled_by" )
end




function CUI_CreateBrowser( conf )
	local self = table.copy( conf or { } )

	local screen = Vector2( guiGetScreenSize() )

	self.sx = self.sx or screen.x
	self.sy = self.sy or screen.y

	self.px = self.px or screen.x / 2 - self.sx / 2
	self.py = self.py or screen.y / 2 - self.sy / 2

	self.elements = { }

	local is_local = true
	if self.is_local ~= nil then is_local = self.is_local end

	local is_transparent = true
	if self.is_transparent ~= nil then is_transparent = self.is_transparent end

	self.elements.guibrowser = guiCreateBrowser( self.px, self.py, self.sx, self.sy, is_local, is_transparent, false )
	self.elements.browser = guiGetBrowser( self.elements.guibrowser ) --createBrowser( self.sx, self.sy, is_local, true )
	
	self.guibrowser = self.elements.guibrowser
	self.browser = self.elements.browser
	--self.elements.browser = self.elements.gui_browser.browser
	self.creation_tick = getTickCount()

	self.OnCreatedWrap = function( )
		if self.OnCreated then
			self:OnCreated( getTickCount() - self.creation_tick )
		end
		if getDevelopmentMode() then toggleBrowserDevTools( self.browser, true ) end
	end
	addEventHandler( "onClientBrowserCreated", self.browser, self.OnCreatedWrap )

	self.OnPageLoadStartWrap = function( url, is_main )
		self.load_tick = getTickCount()
		self.was_frame_load = not is_main
	end
	addEventHandler( "onClientBrowserLoadingStart", self.browser, self.OnPageLoadStartWrap )

	self.OnPageLoadWrap = function( url )
		if self.OnLoad then
			self:OnLoad( url, self.was_frame_load, getTickCount() - self.load_tick )
		end
	end
	addEventHandler( "onClientBrowserDocumentReady", self.browser, self.OnPageLoadWrap )

	self.OnPageNavigateWrap = function( ... )
		if self.OnNavigate then
			self:OnNavigate( ... )
		end
	end
	addEventHandler( "onClientBrowserNavigate", self.browser, self.OnPageNavigateWrap )

	self.destroy = function( self )
		for i, v in pairs( self.elements ) do
			if isElement( v ) then destroyElement( v ) end
			if isElement( i ) then destroyElement( i ) end
		end
		setmetatable( self, nil )
	end

	return self
end

DrawTextOutlined = function(text,px,py,sx,sy,color,font,left,top,thickness)
	local left = left or "left"
	local top = top or "top"
	local thickness = thickness or 1
	local text = tostring(text)

	local text_nohex = text:RemoveHex()
	dxDrawText( text_nohex, px+thickness,py, px+sx+thickness, py+sy, 0xff000000, 1, font, left, top, false, false, false, true )
	dxDrawText( text_nohex, px,py+thickness, px+sx, py+sy+thickness, 0xff000000, 1, font, left, top, false, false, false, true )
	dxDrawText( text_nohex, px-thickness, py, px+sx-thickness, py+sy, 0xff000000, 1, font, left, top, false, false, false, true )
	dxDrawText( text_nohex, px,py-thickness, px+sx, py+sy-thickness, 0xff000000, 1, font, left, top, false, false, false, true )
	dxDrawText( text, px, py, px+sx, py+sy, color, 1, font, left, top, false, false, false, true )
end

Browser.js = Browser.executeJavascript

function rgb2hsv(r, g, b, a)
    if not a then
        a = 255
    end

    r, g, b, a = r / 255, g / 255, b / 255, a / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
  
    local d = max - min
    if max == 0 then 
        s = 0 
    else 
        s = d / max 
    end
  
    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
            h = (g - b) / d
            if g < b then 
                h = h + 6 
            end
        elseif max == g then 
            h = (b - r) / d + 2
        elseif max == b then 
            h = (r - g) / d + 4
        end

        h = h / 6
    end
  
    return h, s, v, a
end