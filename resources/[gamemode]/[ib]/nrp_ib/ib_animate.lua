ANIMATIONS = {
    move   = { },
    resize = { },
    alpha  = { },
    rotation = { },
    scroll = { },
}
ANIMATIONS_RENDERING = nil

function ibMove( self )
    self.start_px, self.start_py = ibGetData( self.element, "px" ), ibGetData( self.element, "py" )
    if self.start_px == self.px and self.start_py == self.py and not ANIMATIONS.move[ self.element ] then return end

    if self.px == nil then self.px = self.start_px end
    if self.py == nil then self.py = self.start_py end

    self.duration = self.duration or 250
    self.easing = self.easing or "OutQuad"
    self.start = getTickCount()
    self.finish = self.start + self.duration

    ANIMATIONS.move[ self.element ] = self

    if ANIMATIONS_RENDERING == nil then
        addEventHandler( "onClientPreRender", root, ibRenderAnimations )
        ANIMATIONS_RENDERING = true
    end
end

function ibResize( self )
    self.start_sx, self.start_sy = ibGetData( self.element, "sx" ), ibGetData( self.element, "sy" )
    if self.start_sx == self.sx and self.start_sy == self.sy and not ANIMATIONS.resize[ self.element ] then return end

    if self.sx == nil then self.sx = self.start_sx end
    if self.sy == nil then self.sy = self.start_sy end

    self.duration = self.duration or 250
    self.easing = self.easing or "OutQuad"
    self.start = getTickCount()
    self.finish = self.start + self.duration

    ANIMATIONS.resize[ self.element ] = self

    if ANIMATIONS_RENDERING == nil then
        addEventHandler( "onClientPreRender", root, ibRenderAnimations )
        ANIMATIONS_RENDERING = true
    end
end

function ibRotate( self )
    self.start_rotation = ibGetData( self.element, "rotation" )
    if self.start_rotation == self.rotation and not ANIMATIONS.rotation[ self.element ] then return end

    self.duration = self.duration or 250
    self.easing = self.easing or "OutQuad"
    self.start = getTickCount()
    self.finish = self.start + self.duration

    ANIMATIONS.rotation[ self.element ] = self

    if ANIMATIONS_RENDERING == nil then
        addEventHandler( "onClientPreRender", root, ibRenderAnimations )
        ANIMATIONS_RENDERING = true
    end
end

function ibAlpha( self )
    self.start_alpha = ibGetData( self.element, "alpha" )
    if self.start_alpha == self.alpha and not ANIMATIONS.alpha[ self.element ] then return end
    self.duration = self.duration or 250
    self.easing = self.easing or "OutQuad"
    self.start = getTickCount()
    self.finish = self.start + self.duration

    ANIMATIONS.alpha[ self.element ] = self

    if ANIMATIONS_RENDERING == nil then
        addEventHandler( "onClientPreRender", root, ibRenderAnimations )
        ANIMATIONS_RENDERING = true
    end
end

function ibScroll( self )
	self.start_position = ibGetData( self.element, "position" )
    if self.start_position == self.position and not ANIMATIONS.scroll[ self.element ] then return end
    self.duration = self.duration or 250
    self.easing = self.easing or "OutQuad"
    self.start = getTickCount()
    self.finish = self.start + self.duration

    ANIMATIONS.scroll[ self.element ] = self

    if ANIMATIONS_RENDERING == nil then
        addEventHandler( "onClientPreRender", root, ibRenderAnimations )
        ANIMATIONS_RENDERING = true
    end
end


local interpolateBetween = interpolateBetween
local isElement          = isElement
local getTickCount       = getTickCount
local pairs              = pairs
local math_floor         = math.floor

function ibRenderAnimations( )
    local tick = getTickCount( )
    local drawn_animations = 0

    -- Движения
    for element, animation in pairs( ANIMATIONS.move ) do
        if isElement( element ) then
            local progress  = ( tick - animation.start ) / animation.duration
            local progress  = progress > 1 and 1 or progress < 0 and 0 or progress
            local px, py = interpolateBetween( animation.start_px, animation.start_py, 0, animation.px, animation.py, 0, progress, animation.easing )
            ibSetBatchData( element, { px = math_floor( px ), py = math_floor( py ) } )

            if progress >= 1 then
                ANIMATIONS.move[ element ] = nil
            end

            drawn_animations = drawn_animations + 1
        else
            ANIMATIONS.move[ element ] = nil
        end
    end

    -- Изменение размера
    for element, animation in pairs( ANIMATIONS.resize ) do
        if isElement( element ) then
            local progress  = ( tick - animation.start ) / animation.duration
            local progress  = progress > 1 and 1 or progress < 0 and 0 or progress
            local sx, sy = interpolateBetween( animation.start_sx, animation.start_sy, 0, animation.sx, animation.sy, 0, progress, animation.easing )
            ibSetBatchData( element, { sx = math_floor( sx ), sy = math_floor( sy ) } )

            if progress >= 1 then
                ANIMATIONS.resize[ element ] = nil
            end

            drawn_animations = drawn_animations + 1
        else
            ANIMATIONS.resize[ element ] = nil
        end
    end

    -- Изменение ротации
    for element, animation in pairs( ANIMATIONS.rotation ) do
        if isElement( element ) then
            local progress  = ( tick - animation.start ) / animation.duration
            local progress  = progress > 1 and 1 or progress < 0 and 0 or progress
            local rotation = interpolateBetween( animation.start_rotation, 0, 0, animation.rotation, 0, 0, progress, animation.easing )
            ibSetData( element, "rotation", rotation )

            if progress >= 1 then
                ANIMATIONS.rotation[ element ] = nil
            end

            drawn_animations = drawn_animations + 1
        else
            ANIMATIONS.rotation[ element ] = nil
        end
    end

    -- Изменение альфы
    for element, animation in pairs( ANIMATIONS.alpha ) do
        if isElement( element ) then
            local progress  = ( tick - animation.start ) / animation.duration
            local progress  = progress > 1 and 1 or progress < 0 and 0 or progress
            local alpha = interpolateBetween( animation.start_alpha, 0, 0, animation.alpha, 0, 0, progress, animation.easing )
            ibSetData( element, "alpha", alpha )

            if progress >= 1 then
                ANIMATIONS.alpha[ element ] = nil
            end

            drawn_animations = drawn_animations + 1
        else
            ANIMATIONS.alpha[ element ] = nil
        end
	end
	
	-- Скролл
    for element, animation in pairs( ANIMATIONS.scroll ) do
		if isElement( element ) then
            local progress  = ( tick - animation.start ) / animation.duration
            local progress  = progress > 1 and 1 or progress < 0 and 0 or progress
            local position = interpolateBetween( animation.start_position, 0, 0, animation.position, 0, 0, progress, animation.easing )
            ibSetData( element, "position", position )

            if progress >= 1 then
                ANIMATIONS.scroll[ element ] = nil
            end

            drawn_animations = drawn_animations + 1
        else
            ANIMATIONS.scroll[ element ] = nil
        end
	end

    if drawn_animations <= 0 then
        ANIMATIONS_RENDERING = nil
        removeEventHandler( "onClientPreRender", root, ibRenderAnimations )
    end
end