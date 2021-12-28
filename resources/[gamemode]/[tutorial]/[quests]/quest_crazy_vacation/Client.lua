loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateReplaceShader( texture_path, repace_texture_name )
	local shader, texture = nil, nil
	local shader = dxCreateShader( [[
		texture tTexture;
	
		technique tech
		{
			pass p0
			{
				Texture[0] = tTexture;
			}
		}
	]] )

	if not shader then return nil, nil end
	
	local texture = dxCreateTexture( texture_path )
	if not texture then 
		destroyElement( shader )
		return nil, nil 
	end

	dxSetShaderValue( shader, "tTexture", texture )

	engineApplyShaderToWorldTexture( shader, repace_texture_name )

	return shader, texture
end

function DrawBlurEffect()
	if not isElement( GEs.blur_shader ) then return end
	
	dxUpdateScreenSource( GEs.blur_screen_src )
	dxSetShaderValue( GEs.blur_shader, "BlurStrength", GEs.blur_strength )
	dxSetShaderValue( GEs.blur_shader, "ColorOffsets", GEs.color_offsets )
	dxDrawImage( 0, 0, _SCREEN_X, _SCREEN_Y, GEs.blur_shader )

	if GEs.blur_strength ~= GEs.end_blur_strength then
		local progress = (getTickCount() - GEs.start_change) / GEs.change_duration
		GEs.blur_strength = GEs.start_blur_strength + GEs.strength_diff * progress
		GEs.color_offsets = GEs.start_color_offsets + GEs.color_offsets_diff * progress
	end
end

function CreateBlurEffect()
    GEs.blur_shader = dxCreateShader( "fx/blur.fx" )
    
    if isElement( GEs.blur_shader ) then
        GEs.blur_screen_src = dxCreateScreenSource( _SCREEN_X, _SCREEN_Y )
        
        dxSetShaderValue( GEs.blur_shader, "ScreenSource", GEs.blur_screen_src )
		dxSetShaderValue( GEs.blur_shader, "UVSize", _SCREEN_X, _SCREEN_Y )
        
        GEs.blur_strength = 5
		GEs.color_offsets = Vector3( math.random(1, 10), math.random(1, 2), math.random(1, 3) )
        
        dxSetShaderValue( GEs.blur_shader, "BlurStrength", GEs.blur_strength )
		dxSetShaderValue( GEs.blur_shader, "ColorOffsets", GEs.color_offsets )
        
		GEs.change_duration = 1000
		GEs.change_parameters = function()			
			GEs.start_blur_strength = GEs.blur_strength
			GEs.end_blur_strength = math.random( GEs.strength_value.x, GEs.strength_value.y )
			GEs.strength_diff = GEs.end_blur_strength - GEs.start_blur_strength
		
			GEs.start_color_offsets = GEs.color_offsets
			GEs.end_color_offsets = Vector3( math.random(1, 3), math.random(1, 2), math.random(1, 2) )
			GEs.color_offsets_diff = GEs.end_color_offsets - GEs.start_color_offsets
			
			GEs.start_change = getTickCount()
		end

		GEs.strength_value = Vector2(5, 10)
		GEs.params_change_tmr = setTimer( GEs.change_parameters, GEs.change_duration + 50, 0 )
		GEs.change_parameters()

		addEventHandler("onClientPreRender", root, DrawBlurEffect )
	end	
	
	GEs.change_strength_blur = function( v1, v2 )
		GEs.strength_value = Vector2(v1, v2)
	end
end

function DestroyBlurEffect()
	removeEventHandler( "onClientPreRender", root, DrawBlurEffect )
	resetSkyGradient()
	setGameSpeed( 1 )
	setCameraShakeLevel( 0 )
end

function EnableDrunkControls()
    local drunk_driver_controls = { "vehicle_left", "vehicle_right" }	
	CEs.DrunkControl = function()
		if not localPlayer.vehicle then return end
		
		local control = drunk_driver_controls[ math.random( 1, #drunk_driver_controls ) ]
		if (Vector3(getElementVelocity(localPlayer.vehicle))).length > 0 then
			setPedControlState( localPlayer, control, true )
		end
		
		CEs.off_control = setTimer( function()
			setPedControlState( localPlayer, control, false )

			if not CEs.DrunkControl then return end
			CEs.new_offset_tmr = setTimer( CEs.DrunkControl, 600, 1 )
		end, 305, 1 )
	end
	CEs.DrunkControl()	
end

function SetStateMoveControls( state )
	for k, v in pairs( { "jump", "sprint", "enter_exit", "enter_passenger", "forwards", "backwards", "left", "right" } ) do
		toggleControl( v, state )
	end
end

addEvent( "onClientQuestPlayerUseDrugs" )