
VINYL_SHADER = nil
VINYL_RT = nil
VINYL_TEXTURES = nil
DEFAULT_COLOR = nil
TEXTURE_LIST = {}

function InitialaziVinylController()
    DestroyVinylController()
    DEFAULT_COLOR = { getVehicleColor( UI_elements.vehicle, true ) }
    local SHADER_RAW = [[
		texture tTexture;

		technique tech
		{
			pass p0
			{
				Texture[0] = tTexture;
			}
		}
	]]
    VINYL_SHADER = dxCreateShader( SHADER_RAW, 1, 20, true, "vehicle" )
    VINYL_RT = dxCreateRenderTarget( MAX_VINYL_SIZE, MAX_VINYL_SIZE )
    VINYL_TEXTURES = {}
end

function DestroyVinylController()
    if isElement( VINYL_RT ) then
        destroyElement( VINYL_RT )
        VINYL_RT = nil
    end
    if isElement( VINYL_SHADER ) then
        destroyElement( VINYL_SHADER )
    end
    for k, v in pairs( VINYL_TEXTURES or {} ) do
        if not v then return end
        v:destroy()
    end
    VINYL_TEXTURES = nil
    if DEFAULT_COLOR then
        UI_elements.vehicle:setColor( unpack( DEFAULT_COLOR ) )
        DEFAULT_COLOR = nil
    end
end

function RefreshDefaultColor( color )
    if VINYL_SHADER and isElement( UI_elements.vehicle ) then
        UI_elements.vehicle:setColor( 255, 255, 255 )
    end
    DEFAULT_COLOR = color or DEFAULT_COLOR
end

function RefreshVehicleVinyl( vinyl_list )
    if BLOCKED_VINYL_VEHICLES[ DATA.vehicle.model ] then return end
    
    CURRENT_VINYL_LIST = vinyl_list or CURRENT_VINYL_LIST
    if not CURRENT_VINYL_LIST or not VINYL_RT then
        return
    end

    for i, v in pairs( VINYL_TEXTURE_NAMES ) do
		engineRemoveShaderFromWorldTexture( VINYL_SHADER, v, UI_elements.vehicle )
	end
    
    dxSetRenderTarget( VINYL_RT, true )
    dxDrawRectangle ( 0, 0, MAX_VINYL_SIZE, MAX_VINYL_SIZE, tocolor( DEFAULT_COLOR[ 1 ], DEFAULT_COLOR[ 2 ], DEFAULT_COLOR[ 3 ], 255 ) )

    for k, vinyl in pairs( CURRENT_VINYL_LIST ) do
        local vinyl_img = vinyl[ P_IMAGE ]
        local layer = vinyl[ P_LAYER_DATA ]

        if not VINYL_TEXTURES[ vinyl_img ] then
            VINYL_TEXTURES[ vinyl_img ] = dxCreateTexture( ":nrp_vinyls/img/" .. vinyl_img .. ".dds", "dxt3", false, "clamp" )
        end

        local ratio = MAX_VINYL_SIZE / 1024
        local width, height = dxGetMaterialSize( VINYL_TEXTURES[ vinyl_img ]  )
        width, height = math.floor( width * layer.size * ratio ), math.floor( height * layer.size * ratio )
        
        if layer.mirror then
            dxDrawImage( layer.x * ratio + width / 2, layer.y * ratio - height / 2, width * -1, height, VINYL_TEXTURES[ vinyl_img ], layer.rotation, 0, 0, layer.color or 0xFFFFFFFF )
        else
            dxDrawImage( layer.x * ratio - width / 2, layer.y * ratio - height / 2, width, height, VINYL_TEXTURES[ vinyl_img ], layer.rotation, 0, 0, layer.color or 0xFFFFFFFF )
        end
    end
    
    dxSetRenderTarget()
    dxSetShaderValue( VINYL_SHADER, "tTexture", VINYL_RT )
    for i, v in pairs( VINYL_TEXTURE_NAMES ) do
		engineApplyShaderToWorldTexture( VINYL_SHADER, v, UI_elements.vehicle )
	end

    if VINYL_FACTION_VEHICLES[ getElementModel( UI_elements.vehicle ) ] then
        setVehiclePaintjob( UI_elements.vehicle, 0 )
    end

end

addEventHandler( "onClientRestore", root, function( didClearRenderTargets  )
    if didClearRenderTargets and isElement( UI_elements.vehicle )  then
        RefreshVehicleVinyl( DATA.installed_vinyls )
    end
end )

function onSettingsChange_handler( changed, values )
    if changed.quality_show_vinyls then
        MAX_VINYL_SIZE = values.quality_show_vinyls
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )