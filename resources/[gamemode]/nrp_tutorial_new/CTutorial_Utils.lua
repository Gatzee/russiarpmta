
function ibWebEditSetLinting( edit )
    addEventHandler( "ibOnWebInputTextChange", edit, function( value )
        if utf8.len( value ) > 0 then
            local first_letter = utf8.sub( value, 1, 1 )
            local rest_of_word = utf8.sub( value, 2, -1 )
            if first_letter == utf8.upper( first_letter ) then
                if rest_of_word == utf8.lower( rest_of_word ) then
                    return
                end
            end

            edit:ibData( "text", utf8.upper( first_letter ) .. utf8.lower( rest_of_word ) )
        end
    end )
end

function DirectToPoint( data )
	name = name or "marker"

	local marker = TeleportPoint( 
		{ 
			x = data.position.x, y = data.position.y+860, z = data.position.z, 
			radius = data.radius or 4, gps = true, 
			keypress = data.keypress or false, text = data.keytext or false, 
			interior = data.interior or localPlayer.interior, 
			dimension = data.dimension or localPlayer.dimension 
		}
	)
	marker.accepted_elements = { player = true, vehicle = true }
	marker.marker.markerType = marker_type or "checkpoint"
	marker.marker:setColor( r or 250, g or 100, b or 100, a or 150 )
	marker.elements = {}
	marker.elements.blip = createBlipAttachedTo(marker.marker, 41, 5, 250, 100, 100)
	marker.elements.blip.position = marker.marker.position

	triggerEvent( "RefreshRadarBlips", localPlayer )

	if type( data.callback ) == "function" then
		marker.PostJoin = data.callback
		marker.PreJoin = data.check
	elseif type( data.callback ) == "string" then
		marker.PostJoin = function()
			if not data.check or check( ) then
				marker.destroy( )
				triggerEvent( "RefreshRadarBlips", localPlayer )
				triggerServerEvent( callback_func, localPlayer )
			end
		end
    end
    
    return marker
end

HEADLIGHTS_SHADER_CODE = [[
    float3 light_color = float3( 1, 1, 0.45 );
    float spread = 0.09;
    float scale = 1.0;

    float2 left_pos = float2( 0, 0 );
    float2 right_pos = float2( 0, 0 );

    float left_distance = 0.5;
    float right_distance = 0.5;

    float4 createLight( float2 uv, float2 pos, float distance ) {
        float2 p = uv - pos;
        float l = 0.1 / abs( length( p ) + 0.84 * spread ) * scale * distance;
        return float4( light_color.rgb, l );
    }

    float4 ps( float2 uv: TEXCOORD0 ) : COLOR0 {
        float4 fragColor = float4( 0.0f, 0.0f, 0.0f, 0.0f );

        fragColor += createLight( uv, left_pos, left_distance );
        fragColor += createLight( uv, right_pos, right_distance );

        return fragColor;
    }

    technique nextrp {
        pass P0 {
            PixelShader = compile ps_2_0 ps();
        }
    }
]]

function CreateHeadlightsShader( vehicle )
    local self = { }

    self.shader = dxCreateShader( HEADLIGHTS_SHADER_CODE )

    self.destroy = function( )
        removeEventHandler( "onClientRender", root, self.draw )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    local dist_mul = 75
    local total_disivor = 1.4

    self.draw = function( )
        local left_headlight = vehicle.position + vehicle.matrix.forward * 4.5 - vehicle.matrix.right * 1 + vehicle.matrix.up * -0.2
        local right_headlight = vehicle.position + vehicle.matrix.forward * 4.5 + vehicle.matrix.right * 1 + vehicle.matrix.up * -0.2

        local wleftx, wlefty = getScreenFromWorldPosition( left_headlight.x, left_headlight.y, left_headlight.z, 2, true )
        local wrightx, wrighty = getScreenFromWorldPosition( right_headlight.x, right_headlight.y, right_headlight.z, 2, true )

        local vec_camera = Vector3( getCameraMatrix( ) )

        local dist_left = getDistanceBetweenPoints3D( left_headlight, vec_camera )
        local dist_right = getDistanceBetweenPoints3D( right_headlight, vec_camera )

        if wleftx and wlefty then dxSetShaderValue( self.shader, "left_pos", wleftx / _SCREEN_X, wlefty / _SCREEN_Y ) end
         if wrightx and wrighty then dxSetShaderValue( self.shader, "right_pos", wrightx / _SCREEN_X, wrighty / _SCREEN_Y ) end

        dxSetShaderValue( self.shader, "left_distance", math.max( 0, 1 - dist_left / dist_mul ) / total_disivor )
        dxSetShaderValue( self.shader, "right_distance", math.max( 0, 1 - dist_right / dist_mul ) / total_disivor )

        dxDrawImage( 0, 0, _SCREEN_X, _SCREEN_Y, self.shader )
    end

    addEventHandler( "onClientRender", root, self.draw )

    return self
end

function CreateMoneyHUD( amount )
    local self = { }

    local main_py = 20

    self.area = ibCreateDummy( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )

    self.destroy = function( )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    self.destroy_with_animation = function( self, duration )
        local duration = duration or 500
        self.area:ibAlphaTo( 0, duration )
        self.area:ibTimer( function( ) self:destroy( ) end, duration, 1 )
    end

    self.reposition_to_stripes = function( self, stripes )
        if stripes and stripes:is_shown( ) then
            self.bg:ibData( "py", main_py + stripes:get_height( ) )
        else
            self.bg:ibData( "py", main_py )
        end
    end

    self.bg = ibCreateImage( 0, main_py, 340, 45, _, self.area, 0xaa000000 )

    local symbol = amount > 0 and "+" or amount < 0 and "-" or ""
    local color = amount > 0 and 0xff00ff00 or amount < 0 and 0xffff0000 or COLOR_WHITE

    self.label = ibCreateLabel( 0, 0, 0, 0, symbol .. " " .. format_price( amount ) .. " р.", self.bg, color, _, _, "center", "center", ibFonts.bold_16 )

    self.bg:ibData( "sx", self.label:width( ) + 20 * 2 )
    self.bg:ibData( "px", _SCREEN_X - 20 - self.bg:width( ) )

    self.label:center( )

    ibSoundFX( "buy_product" )

    return self
end

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    if localPlayer then
        -- CreateHeadlightsShader( GetVehicle( -2 ) )
        --local money = CreateMoneyHUD( 1000000 )
        --setTimer( function( ) money:destroy_with_animation( 500 ) end, 2000, 1 )
    end
end )