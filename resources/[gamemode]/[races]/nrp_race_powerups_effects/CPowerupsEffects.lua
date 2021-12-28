local JUGG_SHADERS = {}
local NITRO_SHADERS = {}

EFFECT_BLASTWAVE  = 1
EFFECT_JUGGERNAUT = 2
EFFECT_NITRO      = 3
EFFECT_SPEEDBREAK = 4

EFFECTS_CONFIG = {
	[ EFFECT_BLASTWAVE ] = {
		create = function( self, element )
            return CreateBlastEffectAttachedTo( element, "img/blast.png" )
		end,
	},

    [ EFFECT_SPEEDBREAK ] = {
        create = function( self, element, is_creator )
            if is_creator then CreateBlastEffectAttachedTo( element, "img/speedbreak.png" ) end

            local shader = dxCreateShader( "fx/speedbreak.fx", 0, 70, true, "vehicle" )
			engineApplyShaderToWorldTexture( shader, "#emap*", element, false )
	        engineApplyShaderToWorldTexture( shader, "remap*", element, false )
	        engineApplyShaderToWorldTexture( shader, "@hite", element, false )
			dxSetShaderValue( shader, "color", 1, 0.1, 0.1 )
			dxSetShaderValue( shader, "speed", 0.5 )

            return shader
		end,
	},
	[ EFFECT_NITRO ] = {
		create = function( self, element )
            --[[local shader = dxCreateShader( "fx/nitro.fx", 0, 70, true, "vehicle" )
			engineApplyShaderToWorldTexture( shader, "#emap*", element, false )
	        engineApplyShaderToWorldTexture( shader, "remap*", element, false )
	        engineApplyShaderToWorldTexture( shader, "@hite", element, false )
			dxSetShaderValue( shader, "color", 1, 1, 1 )
			dxSetShaderValue( shader, "speed", 0.1 )

			return shader]]

			local tab = {}
			tab.parent = createElement( "nitro_parent" )
			tab.effect_left = createEffect( "fire_bike", element.position, Vector3( 0, 0, 180 ) - element.rotation, 0, false )
			tab.effect_left:setParent( tab.parent )

			tab.effect_right = createEffect( "fire_bike", element.position, Vector3( 0, 0, 180 ) - element.rotation, 0, false )
			tab.effect_right:setParent( tab.parent )

			tab.element = element

			table.insert(NITRO_SHADERS, tab)
			return NITRO_SHADERS
		end,
	},

	[ EFFECT_JUGGERNAUT ] = {
		create = function( self, element )
			local tab = {}
			tab.element = element

			tab.shader = dxCreateShader( "fx/juggernaut.fx", 0, 70, true, "vehicle" )
			engineApplyShaderToWorldTexture( tab.shader, "*", element, false )
			engineRemoveShaderFromWorldTexture( tab.shader, "unnamed", element )
			dxSetShaderValue( tab.shader, "sMorphSize", 5, 5, 5 )
			dxSetShaderValue( tab.shader, "sMorphColor", 1, 0.5, 0, 1 )
			
			--iprint("CREATED JUGG")

			local matrix = getElementMatrix( element )
			px, py, pz = getPositionFromElementOffset( element, 0, 0, 0, matrix )
			dxSetShaderValue( tab.shader, "pos", px, py, pz )

			table.insert(JUGG_SHADERS, tab)
			return JUGG_SHADERS
		end,
	}
}

ENABLED_EFFECTS = { }

function ApplyEffect( effect, element, ... )
    local config = EFFECTS_CONFIG[ effect ]
    if not config then return end

	local shader = config:create( element, ... )
	removeEventHandler( "onClientElementDestroy", element, RemoveAllEffects )
	addEventHandler( "onClientElementDestroy", element, RemoveAllEffects )
	
	ENABLED_EFFECTS[ element ] = ENABLED_EFFECTS[ element ] or { }
	table.insert( ENABLED_EFFECTS[ element ], shader )

	removeEventHandler("onClientPreRender", root, RenderJuggernautEffect)
	removeEventHandler("onClientPreRender", root, RenderNitroEffect)

	addEventHandler("onClientPreRender", root, RenderJuggernautEffect)
	addEventHandler("onClientPreRender", root, RenderNitroEffect)
    --iprint( "Effect applied", effect, element )
end
addEvent("RC:ApplyEffect", true)
addEventHandler("RC:ApplyEffect", root, ApplyEffect)

function RemoveAllEffects( element )
    local element = isElement( element ) and element or source
    removeEventHandler( "onClientElementDestroy", element, RemoveAllEffects )
    for i, v in pairs( ENABLED_EFFECTS[ element ] or { } ) do
        if isElement( v ) then 
        	destroyElement( v )
        elseif type(v) == "table" then
        	for i, tab in pairs(v) do
        		if tab.element == element then
        			tab.element = nil
        		end
        	end
       	end
    end
	ENABLED_EFFECTS[ element ] = nil
	-- Удаляем обработчики
	removeEventHandler("onClientPreRender", root, RenderJuggernautEffect)
	removeEventHandler("onClientPreRender", root, RenderNitroEffect)
	-- Сбрасываем шейдера
	RenderJuggernautEffect()
	RenderNitroEffect()
end
addEvent("RC:RemoveAllEffects", true)
addEventHandler("RC:RemoveAllEffects", root, RemoveAllEffects)

function RenderJuggernautEffect()
	for k,v in pairs(JUGG_SHADERS) do
		if not isElement(v.element) or not isElement(v.shader) then
			if isElement(v.shader) then
				destroyElement( v.shader )
			end
			table.remove(JUGG_SHADERS, k)
			return
		end

		local matrix = getElementMatrix( v.element )
		px, py, pz = getPositionFromElementOffset( v.element, 0, 0, 0, matrix )
		dxSetShaderValue( v.shader, "pos", px, py, pz )
	end
end
addEventHandler("onClientPreRender", root, RenderJuggernautEffect)

function RenderNitroEffect()
	for k,v in pairs(NITRO_SHADERS) do
		if not isElement(v.element) then
			if isElement(v.parent) then
				destroyElement( v.parent )
			end
			table.remove(NITRO_SHADERS, k)
			return
		end

		local element = v.element

		local x, y, z = getVehicleComponentPosition( element, "wheel_rb_dummy", "world" )
		setElementPosition( v.effect_left, x, y, z )

		local x, y, z = getVehicleComponentPosition( element, "wheel_lb_dummy", "world" )
		setElementPosition( v.effect_right, x, y, z )
	end
end
addEventHandler("onClientPreRender", root, RenderNitroEffect)


function CreateBlastEffectAttachedTo( element, img )
    local shader = dxCreateShader( "fx/neon.fx", 0, 70, true, "world,object" )
    local texture = dxCreateTexture( img )

    dxSetShaderValue( shader, "tex", texture )
    engineApplyShaderToWorldTexture( shader, "*" )
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
		"sjmshopbk",
		"*sand*",
		"*radar*",
		"*skybox*",
		"metalox64",
		"metal1_128",
		"nitro",
		"repair",
		"carchange",
		"bullethitsmoke",
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
		engineRemoveShaderFromWorldTexture( shader, v )
    end

    local conf = {
        from_scale = 0,
        to_scale = 15,

        from_time = getTickCount(),
        duration = 700,

        alpha_fadein = 0.2,
        alpha_fadeout = 0.6,
    }

    local tick_start = getTickCount( )
    local minz = ( { getElementBoundingBox( element ) } )[ 3 ]
	local function RenderShader( )
		if not isElement( element ) then DestroyThisShader( ) end

        local progress = ( getTickCount() - tick_start ) / conf.duration
        progress = progress > 1 and 1 or progress < 0 and 0 or progress

        local scale = interpolateBetween( conf.from_scale, 0, 0, conf.to_scale, 0, 0, progress, "OutQuad" )

        local alpha = 1
        if progress <= conf.alpha_fadein then
            alpha = progress / conf.alpha_fadein
        elseif progress >= conf.alpha_fadeout then
            alpha = ( ( 1 - conf.alpha_fadeout ) - ( progress - conf.alpha_fadeout ) )
        end

        dxSetShaderValue( shader, "galpha", alpha )

        dxSetShaderValue( shader, "scale", scale )

        local matrix = getElementMatrix( element )
		px, py, pz = getPositionFromElementOffset( element, 0, 0, minz * 0.5, matrix )
        dxSetShaderValue( shader, "pos", px, py, pz )
        
		-- Вектор автомобиля
		mx, my, mz = getPositionFromElementOffset( element, 0, 0, -1, matrix )
        dxSetShaderValue( shader, "mt", mx - px, my - py, mz - pz )
        
		-- Поворот автомобиля в радианах
		rx, ry, rz = getElementRotation( element, "ZYX" )
		rx, ry, rz = -math.rad( rx ), -math.rad( ry ), -math.rad( rz )
		dxSetShaderValue( shader, "rt", ry, rx, rz )

    end
    
    local function DestroyThisShader( )
        removeEventHandler( "onClientPreRender", root, RenderShader )
        if isElement( texture ) then destroyElement( texture ) end
        if isElement( shader ) then destroyElement( shader ) end
    end

    addEventHandler( "onClientPreRender", root, RenderShader )

    setTimer( DestroyThisShader, conf.duration, 1 )
end

function getPositionFromElementOffset( element, offX, offY, offZ, matrix )
	local m = matrix or getElementMatrix( element )
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end